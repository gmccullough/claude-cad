#!/usr/bin/env node
// Builds a SINGLE self-contained .html file with three.js, the STL loader,
// orbit controls, AND a chosen STL all inlined. The result opens by
// double-click from the filesystem (file://) in any modern browser —
// no server, no network, no build step at view time.
//
// Why inline everything: Chrome blocks fetch() of local files from file://
// (origin "null"), so the geometry is base64-embedded. The JS uses classic
// <script> tags + a global THREE (no ES modules / import maps), which is the
// only thing iOS Quick Look and older in-app WebViews reliably execute.
//
// Usage:
//   node viewer/build-standalone.mjs <path-to.stl> [output.html] [Title]
//
// Example:
//   node viewer/build-standalone.mjs myproj/part.stl

import { readFile, writeFile, stat } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join, basename, resolve, relative } from "node:path";

const viewerDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(viewerDir, "..");

const stlArg = process.argv[2];
if (!stlArg) {
  console.error("Usage: node viewer/build-standalone.mjs <path-to.stl> [output.html] [Title]");
  process.exit(1);
}
const stlPath = resolve(repoRoot, stlArg);
const modelName = basename(stlPath);
const title = process.argv[4] || modelName.replace(/\.stl$/i, "");
const outPath = resolve(
  repoRoot,
  process.argv[3] || join(viewerDir, "standalone", modelName.replace(/\.stl$/i, "") + ".html")
);

// Classic (non-module) three.js global build + classic loaders. This avoids ES
// modules, import maps, and data: URLs entirely — all of which iOS Quick Look /
// older in-app WebViews can refuse to execute. Plain <script> + a global THREE
// is the widest-compatibility option and renders the same everywhere.
const threeSrc = await readFile(join(viewerDir, "vendor-classic", "three.min.js"), "utf8");
const orbitSrc = await readFile(join(viewerDir, "vendor-classic", "OrbitControls.js"), "utf8");
const stlSrc = await readFile(join(viewerDir, "vendor-classic", "STLLoader.js"), "utf8");

const stlBuf = await readFile(stlPath);
const stlInfo = await stat(stlPath);
const stlB64 = stlBuf.toString("base64");

const app = `
(function () {
"use strict";
// Everything comes off the global THREE (classic build), including the addons.
const {
  WebGLRenderer, Scene, PerspectiveCamera, DirectionalLight, AmbientLight,
  ShaderMaterial, Color, Mesh, PlaneGeometry, AxesHelper, Group, GridHelper,
  Vector3, MeshStandardMaterial, DoubleSide, LineSegments, EdgesGeometry, LineBasicMaterial,
  OrbitControls, STLLoader,
} = THREE;

/* ---- viewer app ---- */
const STL_NAME = ${JSON.stringify(modelName)};
const STL_B64 = "${stlB64}";

const SCHEMES = {
  cornfield: { bgTop: 0xfdfcdf, bgBot: 0xf4eeb6, model: 0xf9d72c, edge: 0x4d4422, grid: 0xcabf73 },
  tomorrow:  { bgTop: 0x2b303b, bgBot: 0x1d2026, model: 0xc7d0e0, edge: 0x10121a, grid: 0x3a414f },
  sunset:    { bgTop: 0x3a2740, bgBot: 0x20141f, model: 0xff9d5c, edge: 0x3a1f10, grid: 0x5a3a52 },
  metal:     { bgTop: 0x404652, bgBot: 0x21252c, model: 0xc9ccd1, edge: 0x15171b, grid: 0x4a515c },
};

const wrap = document.getElementById("stage");
const renderer = new WebGLRenderer({ antialias: true });
renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
wrap.appendChild(renderer.domElement);

const scene = new Scene();
const camera = new PerspectiveCamera(45, 1, 0.01, 100000);
const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true; controls.dampingFactor = 0.08; controls.autoRotateSpeed = 2.0;

const key = new DirectionalLight(0xffffff, 2.0);
const fill = new DirectionalLight(0xffffff, 0.7);
const back = new DirectionalLight(0xffffff, 0.5);
scene.add(key, fill, back, new AmbientLight(0xffffff, 0.45));

// gradient background
const bgMesh = (() => {
  const mat = new ShaderMaterial({
    uniforms: { top: { value: new Color() }, bot: { value: new Color() } },
    vertexShader: "varying vec2 vUv; void main(){ vUv=uv; gl_Position=vec4(position.xy,1.0,1.0); }",
    fragmentShader: "varying vec2 vUv; uniform vec3 top; uniform vec3 bot; void main(){ gl_FragColor=vec4(mix(bot,top,vUv.y),1.0); }",
    depthWrite: false, depthTest: false,
  });
  const m = new Mesh(new PlaneGeometry(2, 2), mat);
  m.frustumCulled = false; m.renderOrder = -1; return m;
})();
scene.add(bgMesh);

const axes = new AxesHelper(50);
const helpers = new Group(); helpers.add(axes); scene.add(helpers);
let grid = null, modelMesh = null, edgeLines = null, modelRadius = 50, currentScheme = "cornfield";
const state = { wireframe: false, edges: false, helpers: true, rotate: false };

function applyScheme(name) {
  currentScheme = name; const s = SCHEMES[name];
  bgMesh.material.uniforms.top.value.setHex(s.bgTop);
  bgMesh.material.uniforms.bot.value.setHex(s.bgBot);
  if (modelMesh) {
    modelMesh.material.color.setHex(s.model);
    modelMesh.material.metalness = name === "metal" ? 0.85 : 0.0;
    modelMesh.material.roughness = name === "metal" ? 0.35 : 0.55;
  }
  if (edgeLines) edgeLines.material.color.setHex(s.edge);
  if (grid) { grid.material.color.setHex(s.grid); grid.material.opacity = 0.6; grid.material.transparent = true; }
}

function alignGrid(size) {
  const span = Math.max(size.x, size.y, 1);
  if (grid) { helpers.remove(grid); grid.geometry.dispose(); grid.material.dispose(); }
  grid = new GridHelper(span * 2.2, 20);
  grid.rotation.x = Math.PI / 2; grid.position.z = -size.z / 2;
  helpers.add(grid);
  axes.position.set(-span * 1.1, -span * 1.1, -size.z / 2);
}

function meshVolume(geometry) {
  const p = geometry.attributes.position.array; let vol = 0;
  for (let i = 0; i < p.length; i += 9) {
    const ax=p[i],ay=p[i+1],az=p[i+2], bx=p[i+3],by=p[i+4],bz=p[i+5], cx=p[i+6],cy=p[i+7],cz=p[i+8];
    vol += (ax*(by*cz-bz*cy) - ay*(bx*cz-bz*cx) + az*(bx*cy-by*cx)) / 6;
  }
  return Math.abs(vol);
}
const fmt = (n, dp = 1) => Number(n).toFixed(dp);

function showGeometry(geometry, label) {
  if (modelMesh) { modelMesh.geometry.dispose(); modelMesh.material.dispose(); scene.remove(modelMesh); }
  if (edgeLines) { edgeLines.geometry.dispose(); edgeLines.material.dispose(); }
  geometry.computeBoundingBox(); geometry.computeVertexNormals();
  const bb = geometry.boundingBox;
  const center = bb.getCenter(new Vector3());
  const size = bb.getSize(new Vector3());
  geometry.translate(-center.x, -center.y, -center.z);

  const s = SCHEMES[currentScheme];
  modelMesh = new Mesh(geometry, new MeshStandardMaterial({
    color: s.model, metalness: 0, roughness: 0.55, side: DoubleSide,
  }));
  scene.add(modelMesh);
  edgeLines = new LineSegments(new EdgesGeometry(geometry, 18), new LineBasicMaterial({ color: s.edge }));
  edgeLines.visible = state.edges; modelMesh.add(edgeLines);

  geometry.computeBoundingSphere();
  modelRadius = Math.max(geometry.boundingSphere.radius, 1);
  alignGrid(size); applyScheme(currentScheme); applyToggles(); frameModel();

  document.getElementById("d-size").textContent = fmt(size.x)+" × "+fmt(size.y)+" × "+fmt(size.z)+" mm";
  document.getElementById("d-tris").textContent = (geometry.attributes.position.count/3).toLocaleString();
  document.getElementById("d-vol").textContent = fmt(meshVolume(geometry)/1000, 2)+" cm³";
}

function applyToggles() {
  if (modelMesh) modelMesh.material.wireframe = state.wireframe;
  if (edgeLines) edgeLines.visible = state.edges && !state.wireframe;
  helpers.visible = state.helpers;
  controls.autoRotate = state.rotate;
}

function frameModel() {
  // Fit the bounding sphere by whichever of vertical/horizontal FOV is tighter,
  // so the model stays fully in frame in portrait (narrow) and landscape alike.
  const vFOV = camera.fov * Math.PI / 180;
  const aspect = camera.aspect || 1;
  const hFOV = 2 * Math.atan(Math.tan(vFOV / 2) * aspect);
  const dist = modelRadius / Math.sin(Math.min(vFOV, hFOV) / 2) * 1.1;
  setView(document.getElementById("sel-view").value, dist);
}
function setView(preset, distOverride) {
  const d = distOverride ?? (camera.position.length() || modelRadius * 3);
  const dirs = { iso:[1,-1,0.8], front:[0,-1,0], back:[0,1,0], left:[-1,0,0], right:[1,0,0], top:[0,0,1], bottom:[0,0,-1] };
  camera.position.copy(new Vector3(...(dirs[preset]||dirs.iso)).normalize().multiplyScalar(d));
  camera.up.set(0, 0, 1);
  controls.target.set(0, 0, 0);
  camera.near = Math.max(d/1000, 0.01); camera.far = d*1000; camera.updateProjectionMatrix();
  controls.update();
}

// toolbar
const toggleBtn = (id, k) => { const el = document.getElementById(id);
  el.addEventListener("click", () => { state[k] = !state[k]; el.classList.toggle("on", state[k]); applyToggles(); }); };
toggleBtn("btn-wire","wireframe"); toggleBtn("btn-edges","edges"); toggleBtn("btn-rotate","rotate");
const axBtn = document.getElementById("btn-axes"); axBtn.classList.add("on");
axBtn.addEventListener("click", () => { state.helpers = !state.helpers; axBtn.classList.toggle("on", state.helpers); applyToggles(); });
document.getElementById("btn-fit").addEventListener("click", () => modelMesh && frameModel());
document.getElementById("sel-scheme").addEventListener("change", e => applyScheme(e.target.value));
document.getElementById("sel-view").addEventListener("change", e => modelMesh && setView(e.target.value));
addEventListener("keydown", e => { if (e.target.tagName === "SELECT") return;
  ({ f:"btn-fit", w:"btn-wire", e:"btn-edges", r:"btn-rotate", g:"btn-axes" })[e.key.toLowerCase()]
    && document.getElementById(({ f:"btn-fit", w:"btn-wire", e:"btn-edges", r:"btn-rotate", g:"btn-axes" })[e.key.toLowerCase()]).click(); });

// Re-fit on resize until the user first interacts. The initial canvas size
// isn't always final when the model first loads (mobile layout settling), and
// this also re-frames cleanly when a phone is rotated portrait<->landscape.
let userInteracted = false;
controls.addEventListener("start", () => { userInteracted = true; });
function resize() {
  const w = wrap.clientWidth, h = wrap.clientHeight;
  renderer.setSize(w, h); camera.aspect = w/h; camera.updateProjectionMatrix();
  if (modelMesh && !userInteracted) frameModel();
}
new ResizeObserver(resize).observe(wrap); resize();

function tick() {
  requestAnimationFrame(tick);
  key.position.copy(camera.position);
  fill.position.copy(camera.position).applyAxisAngle(new Vector3(0,0,1), 2.4);
  back.position.copy(camera.position).multiplyScalar(-1);
  controls.update(); renderer.render(scene, camera);
}

// decode embedded STL and go
const bin = Uint8Array.from(atob(STL_B64), c => c.charCodeAt(0));
const geo = new STLLoader().parse(bin.buffer);
applyScheme("cornfield");
camera.position.set(80, -80, 64); setView("iso", 200);
showGeometry(geo, STL_NAME);
document.getElementById("d-name").textContent = STL_NAME;
tick();
})();
`;

const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>${title} — STL Viewer</title>
<style>
  :root { --panel:#23262e; --line:#383d49; --text:#e7e9ee; --muted:#9aa3b2; --accent:#f9d72c; --accent-dim:#cdb024; }
  * { box-sizing: border-box; }
  html, body { margin: 0; height: 100%; overflow: hidden; }
  body { font: 13px/1.45 system-ui, -apple-system, Segoe UI, Roboto, sans-serif; color: var(--text); background:#1b1d23; }
  #stage { position: absolute; inset: 0; }
  canvas { display: block; }
  .toolbar { position: absolute; top: 12px; left: 12px; right: 12px; z-index: 5; display: flex; gap: 6px; flex-wrap: wrap; align-items: center; pointer-events: none; }
  .toolbar > * { pointer-events: auto; }
  button.tool, select.tool { background: rgba(35,38,46,.92); color: var(--text); border: 1px solid var(--line); border-radius: 6px; padding: 6px 10px; font-size: 12px; cursor: pointer; backdrop-filter: blur(4px); }
  button.tool:hover, select.tool:hover { border-color: var(--accent-dim); }
  button.tool.on { background: var(--accent); color:#1b1d23; border-color: var(--accent); font-weight: 600; }
  .title { background: rgba(35,38,46,.92); border:1px solid var(--line); border-radius:6px; padding:6px 10px; font-weight:600; }
  .spacer { flex: 1; }
  .info { position: absolute; bottom: 12px; left: 12px; z-index: 5; background: rgba(35,38,46,.92); border: 1px solid var(--line); border-radius: 8px; padding: 10px 12px; min-width: 200px; backdrop-filter: blur(4px); }
  .info h2 { margin: 0 0 6px; font-size: 12px; }
  .info table { border-collapse: collapse; font-size: 11px; }
  .info td { padding: 1px 0; } .info td.k { color: var(--muted); padding-right: 12px; } .info td.v { font-variant-numeric: tabular-nums; }
  .hint { position:absolute; bottom:12px; right:12px; z-index:5; color: var(--muted); font-size: 11px; }
</style>
</head>
<body>
  <div id="stage"></div>
  <div class="toolbar">
    <span class="title">${title}</span>
    <button class="tool" id="btn-fit" title="Fit (F)">⤢ Fit</button>
    <button class="tool" id="btn-rotate" title="Spin (R)">↻ Spin</button>
    <button class="tool" id="btn-wire" title="Wireframe (W)">▱ Wireframe</button>
    <button class="tool" id="btn-edges" title="Edges (E)">◳ Edges</button>
    <button class="tool" id="btn-axes" title="Axes/grid (G)">✛ Axes</button>
    <span class="spacer"></span>
    <select class="tool" id="sel-scheme" title="Color scheme">
      <option value="cornfield">Cornfield</option><option value="tomorrow">Tomorrow</option>
      <option value="sunset">Sunset</option><option value="metal">Metal</option>
    </select>
    <select class="tool" id="sel-view" title="Camera">
      <option value="iso">Isometric</option><option value="front">Front</option><option value="back">Back</option>
      <option value="left">Left</option><option value="right">Right</option><option value="top">Top</option><option value="bottom">Bottom</option>
    </select>
  </div>
  <div class="info">
    <h2 id="d-name">—</h2>
    <table>
      <tr><td class="k">Size (X×Y×Z)</td><td class="v" id="d-size">—</td></tr>
      <tr><td class="k">Triangles</td><td class="v" id="d-tris">—</td></tr>
      <tr><td class="k">Volume</td><td class="v" id="d-vol">—</td></tr>
    </table>
  </div>
  <div class="hint">drag to orbit · scroll to zoom · right-drag to pan</div>

<!-- Classic scripts (no ES modules / import maps) for maximum compatibility,
     including iOS Quick Look and older in-app browsers. -->
<script>${threeSrc}</script>
<script>${orbitSrc}</script>
<script>${stlSrc}</script>
<script>
${app}
</script>
</body>
</html>
`;

await import("node:fs/promises").then(fs => fs.mkdir(dirname(outPath), { recursive: true }));
await writeFile(outPath, html);
const mb = (html.length / 1e6).toFixed(1);
console.log(`Wrote ${relative(repoRoot, outPath)}  (${mb} MB, STL ${(stlInfo.size/1e6).toFixed(1)} MB embedded)`);
console.log("Open it by double-clicking — no server needed.");
