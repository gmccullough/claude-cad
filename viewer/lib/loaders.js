// Model loaders shared by the interactive viewer and the headless renderer.
//
//   parseModel(name, arrayBuffer) -> Promise<{
//     parts:  [{ name, object, kind, geometry }],   // geometry in world (bed) coords
//     pauses: [{ z, type, gcode }],                 // Bambu custom G-code layers
//     bed:    { w, h } | null,                      // printable area, 3MF only
//     settings: { key: value } | null,              // headline print settings
//   }>
//
// kind is "normal" for printed geometry, otherwise the Bambu part subtype
// ("modifier_part", "negative_part", "support_blocker", "support_enforcer").
// 3MF support covers core 3MF + the production extension (components that
// point into 3D/Objects/*.model), which is what Bambu Studio and
// tools/bambu3mf.py write. No zip library: the browser's DecompressionStream
// inflates the entries.
import * as THREE from "three";
import { STLLoader } from "three/addons/loaders/STLLoader.js";

const stlLoader = new STLLoader();

export async function parseModel(name, buf) {
  const lower = name.toLowerCase();
  if (lower.endsWith(".3mf")) return parse3MF(buf);
  if (lower.endsWith(".stl")) {
    const geometry = stlLoader.parse(buf);
    return { parts: [{ name, object: name, kind: "normal", geometry }], pauses: [], bed: null, settings: null };
  }
  throw new Error(`unsupported file type: ${name}`);
}

// ---------------------------------------------------------------- zip ----
async function readZip(buf) {
  const dv = new DataView(buf);
  let eocd = -1;
  for (let i = buf.byteLength - 22; i >= Math.max(0, buf.byteLength - 65557); i--) {
    if (dv.getUint32(i, true) === 0x06054b50) { eocd = i; break; }
  }
  if (eocd < 0) throw new Error("not a zip file");
  const count = dv.getUint16(eocd + 10, true);
  let p = dv.getUint32(eocd + 16, true);
  const dec = new TextDecoder();
  const entries = new Map();
  for (let n = 0; n < count; n++) {
    if (dv.getUint32(p, true) !== 0x02014b50) throw new Error("bad zip central directory");
    const method = dv.getUint16(p + 10, true);
    const csize = dv.getUint32(p + 20, true);
    const nlen = dv.getUint16(p + 28, true), xlen = dv.getUint16(p + 30, true), clen = dv.getUint16(p + 32, true);
    const local = dv.getUint32(p + 42, true);
    const fname = dec.decode(new Uint8Array(buf, p + 46, nlen));
    p += 46 + nlen + xlen + clen;
    const start = local + 30 + dv.getUint16(local + 26, true) + dv.getUint16(local + 28, true);
    entries.set(fname.replace(/^\//, ""), { method, data: new Uint8Array(buf, start, csize) });
  }
  return {
    names: [...entries.keys()],
    async text(path) {
      const e = entries.get(path.replace(/^\//, ""));
      if (!e) return null;
      if (e.method === 0) return dec.decode(e.data);
      if (e.method !== 8) throw new Error(`zip method ${e.method} unsupported`);
      const stream = new Blob([e.data]).stream().pipeThrough(new DecompressionStream("deflate-raw"));
      return await new Response(stream).text();
    },
  };
}

// ---------------------------------------------------------------- 3mf ----
const byTag = (el, tag) => el.getElementsByTagNameNS("*", tag);

function matrixFrom3MF(str) {
  const m = new THREE.Matrix4();
  if (!str) return m;
  const v = str.trim().split(/\s+/).map(Number);
  // 3MF stores a 4x3 row-vector matrix: p' = p * M
  m.set(v[0], v[3], v[6], v[9],
        v[1], v[4], v[7], v[10],
        v[2], v[5], v[8], v[11],
        0, 0, 0, 1);
  return m;
}

function meshGeometry(meshEl) {
  const vEls = byTag(meshEl, "vertex"), tEls = byTag(meshEl, "triangle");
  const verts = new Float32Array(vEls.length * 3);
  for (let i = 0; i < vEls.length; i++) {
    const e = vEls[i];
    verts[i * 3] = +e.getAttribute("x"); verts[i * 3 + 1] = +e.getAttribute("y"); verts[i * 3 + 2] = +e.getAttribute("z");
  }
  const idx = new Uint32Array(tEls.length * 3);
  for (let i = 0; i < tEls.length; i++) {
    const e = tEls[i];
    idx[i * 3] = +e.getAttribute("v1"); idx[i * 3 + 1] = +e.getAttribute("v2"); idx[i * 3 + 2] = +e.getAttribute("v3");
  }
  const g = new THREE.BufferGeometry();
  g.setAttribute("position", new THREE.BufferAttribute(verts, 3));
  g.setIndex(new THREE.BufferAttribute(idx, 1));
  return g.toNonIndexed();   // flat-ish shading + simple volume maths downstream
}

async function parse3MF(buf) {
  const zip = await readZip(buf);
  const parser = new DOMParser();
  const docs = new Map();
  async function doc(path) {
    path = path.replace(/^\//, "");
    if (!docs.has(path)) {
      const txt = await zip.text(path);
      docs.set(path, txt ? parser.parseFromString(txt, "application/xml") : null);
    }
    return docs.get(path);
  }
  const rels = await zip.text("_rels/.rels");
  const rootPath = (rels && /Target="([^"]+\.model)"/.exec(rels)?.[1]) || "3D/3dmodel.model";
  const root = await doc(rootPath);
  if (!root) throw new Error("3MF has no model part");

  // Bambu metadata: part names + subtypes, pauses, settings
  const names = new Map(), subtypes = new Map();
  const cfg = await zip.text("Metadata/model_settings.config");
  if (cfg) {
    const c = parser.parseFromString(cfg, "application/xml");
    for (const o of c.getElementsByTagName("object")) {
      const oname = [...o.children].find(x => x.tagName === "metadata" && x.getAttribute("key") === "name");
      if (oname) names.set("o" + o.getAttribute("id"), oname.getAttribute("value"));
      for (const part of o.getElementsByTagName("part")) {
        subtypes.set(part.getAttribute("id"), part.getAttribute("subtype") || "normal_part");
        const pn = [...part.children].find(x => x.tagName === "metadata" && x.getAttribute("key") === "name");
        if (pn) names.set("p" + part.getAttribute("id"), pn.getAttribute("value"));
      }
    }
  }
  const pauses = [];
  const cg = await zip.text("Metadata/custom_gcode_per_layer.xml");
  if (cg) {
    const TYPES = { 0: "color change", 1: "pause", 2: "tool change", 3: "template", 4: "custom" };
    for (const l of parser.parseFromString(cg, "application/xml").getElementsByTagName("layer"))
      pauses.push({ z: +l.getAttribute("top_z"), type: TYPES[l.getAttribute("type")] || "custom", gcode: l.getAttribute("gcode") || "" });
  }
  let bed = null, settings = null;
  const ps = await zip.text("Metadata/project_settings.config");
  if (ps) {
    try {
      const j = JSON.parse(ps);
      const area = [].concat(j.printable_area || []).map(s => s.split("x").map(Number));
      if (area.length) bed = { w: Math.max(...area.map(a => a[0])), h: Math.max(...area.map(a => a[1])) };
      const first = v => Array.isArray(v) ? v[0] : v;
      const pick = ["printer_model", "print_settings_id", "layer_height", "wall_loops", "sparse_infill_density",
        "sparse_infill_pattern", "enable_support", "brim_type", "curr_bed_type", "filament_settings_id"];
      settings = {};
      for (const k of pick) if (j[k] !== undefined) settings[k] = first(j[k]);
    } catch { /* not JSON (older formats) */ }
  }

  // resolve objects (possibly in other model parts) into world-space parts
  const parts = [];
  async function findObject(path, id) {
    const d = await doc(path);
    if (!d) return null;
    for (const o of byTag(d, "object")) if (o.getAttribute("id") === id) return o;
    return null;
  }
  async function emit(path, id, mat, objName, depth = 0) {
    if (depth > 8) return;
    const o = await findObject(path, id);
    if (!o) return;
    const mesh = byTag(o, "mesh")[0];
    if (mesh && mesh.parentNode === o) {
      const g = meshGeometry(mesh);
      g.applyMatrix4(mat);
      const st = subtypes.get(id) || (o.getAttribute("type") === "support" ? "support_blocker" : "normal_part");
      parts.push({
        name: names.get("p" + id) || o.getAttribute("name") || objName || `object ${id}`,
        object: objName || o.getAttribute("name") || `object ${id}`,
        kind: st === "normal_part" ? "normal" : st,
        geometry: g,
      });
    }
    for (const c of byTag(o, "component")) {
      if (c.parentNode.parentNode !== o) continue;
      const cp = c.getAttribute("p:path") || c.getAttributeNS("*", "path") || path;
      const m = mat.clone().multiply(matrixFrom3MF(c.getAttribute("transform")));
      await emit(cp, c.getAttribute("objectid"), m, objName, depth + 1);
    }
  }
  for (const item of byTag(root, "item")) {
    const id = item.getAttribute("objectid");
    const objEl = await findObject(rootPath, id);
    const objName = names.get("o" + id) || objEl?.getAttribute("name") || `object ${id}`;
    await emit(rootPath, id, matrixFrom3MF(item.getAttribute("transform")), objName);
  }
  return { parts, pauses, bed, settings };
}
