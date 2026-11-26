#!/usr/bin/env node
// OpenSCAD CLI for the cloud container: OpenSCAD 2025 compiled to WebAssembly,
// run under Node. Drop-in for the desktop binary for everything except PNG
// export (no GL in wasm) — `-o x.png` is handed to tools/render instead.
//
//   tools/openscad [normal openscad args...]
//
// The wasm build only has an in-memory filesystem, so before running we copy
// in (at their real absolute paths) every file the model can reach: the input
// .scad, everything its include<>/use<>/import()/surface() statements name,
// recursively, plus the small data files sitting next to it (catches imports
// whose path is computed with str()). After the run, every -o/-d/-m output is
// copied back out to disk. BOSL2 (cloned by setup.sh) and the system Liberation
// / DejaVu fonts are staged too, so text() and BOSL2 includes just work.
//
// Default backend is Manifold (what the Mac scripts use); pass --backend=cgal
// to override. Exit code is OpenSCAD's own.
import { createOpenSCAD } from "openscad-wasm-prebuilt";
import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(HERE, "../..");
const LIBDIRS = [
  path.join(HERE, ".cache/libraries"),
  ...(process.env.OPENSCADPATH || "").split(":").filter(Boolean),
];
const VALUE_OPTS = new Set(["-o", "-D", "-p", "-P", "-d", "-m", "--export-format",
  "--camera", "--imgsize", "--projection", "--colorscheme", "--view", "--backend",
  "--render", "--csglimit", "--summary", "--summary-file", "--enable", "--viewall"]);
const NO_VALUE = new Set(["--viewall", "--autocenter", "--render", "--preview", "--hardwarnings",
  "--check-parameters", "--check-parameter-ranges", "--info", "--version", "-h", "--help",
  "--quiet", "-q", "--trust-python", "--debug", "--animate"]);
const DATA_EXT = /\.(scad|stl|svg|dxf|dat|png|off|obj|3mf|amf|csv|json|txt)$/i;
const MAX_SIBLING = 40 * 1024 * 1024;

const argv = process.argv.slice(2);

// ---- parse just enough of the command line to find inputs and outputs ----
const outputs = [];   // [flag, path]
const inputs = [];
let hasBackend = false;
for (let i = 0; i < argv.length; i++) {
  const a = argv[i];
  if (a.startsWith("--backend")) hasBackend = true;
  if (a.includes("=") && a.startsWith("--")) continue;
  if (NO_VALUE.has(a)) continue;
  if (VALUE_OPTS.has(a)) {
    const v = argv[i + 1];
    if (["-o", "-d", "-m", "--summary-file"].includes(a)) outputs.push([a, v]);
    i++;
    continue;
  }
  if (!a.startsWith("-")) inputs.push(a);
}

// PNG: no OpenGL in wasm. Two routes:
//  1. native OpenSCAD (apt 2021.01) under Xvfb — real OpenSCAD camera ($vpt/$vpr/$vpd,
//     --camera, --viewall), colour schemes and color(). 2021's --render drops color(),
//     which 2025+Manifold keeps, so --render becomes --preview (OpenCSG keeps colours);
//     --backend is dropped (2021 has no Manifold).
//  2. otherwise: render the mesh with wasm, then screenshot it with tools/render.
const pngOut = outputs.find(([f, p]) => f === "-o" && /\.png$/i.test(p));
const which = b => spawnSync("sh", ["-c", `command -v ${b}`]).status === 0;
if (pngOut && !process.env.OPENSCAD_PNG_VIA_VIEWER && !(which("openscad") && which("xvfb-run")))
  spawnSync(path.join(HERE, "need"), ["openscad-native"], { stdio: ["ignore", "inherit", "inherit"] });
if (pngOut && which("openscad") && which("xvfb-run") && !process.env.OPENSCAD_PNG_VIA_VIEWER) {
  const nargs = argv.filter(a => !a.startsWith("--backend")).map(a => a === "--render" ? "--preview" : a);
  for (let k; (k = nargs.indexOf("--backend")) >= 0;) nargs.splice(k, 2);
  const r = spawnSync("xvfb-run", ["-a", "-s", "-screen 0 1280x1024x24", "openscad", ...nargs], { stdio: "inherit" });
  process.exit(r.status ?? 1);
}
if (pngOut) {
  const tmp = path.join(fs.mkdtempSync("/tmp/oscad-"), "model.stl");
  const args = argv.slice();
  args[args.indexOf(pngOut[1])] = tmp;
  for (const drop of ["--camera", "--imgsize", "--projection", "--colorscheme", "--view"]) {
    let k; while ((k = args.indexOf(drop)) >= 0) args.splice(k, 2);
  }
  const keep = args.filter(a => !/^--(autocenter|viewall|preview|render)$/.test(a) &&
                                !/^--(camera|imgsize|projection|colorscheme|view)=/.test(a));
  const r1 = spawnSync(process.execPath, [fileURLToPath(import.meta.url), ...keep], { stdio: "inherit" });
  if (r1.status !== 0) process.exit(r1.status ?? 1);
  const size = (argv.find(a => a.startsWith("--imgsize=")) || "").split("=")[1];
  const r2 = spawnSync(process.execPath, [path.join(HERE, "render.mjs"), tmp, "-o", pngOut[1],
    "--views", "iso", ...(size ? ["--size", size.replace(",", "x")] : [])], { stdio: "inherit" });
  process.exit(r2.status ?? 1);
}

// ---- boot OpenSCAD ----
const out = [], err = [];
const inst = await createOpenSCAD({
  print: s => process.stdout.write(s + "\n"),
  printErr: s => { if (!/Could not initialize localization/.test(s)) process.stderr.write(s + "\n"); },
});
const M = inst.getInstance();
const FS = M.FS;
const mkdirp = d => { try { FS.mkdirTree(d); } catch { /* exists */ } };

const staged = new Set();
function stageFile(abs) {
  if (staged.has(abs)) return true;
  let st; try { st = fs.statSync(abs); } catch { return false; }
  if (!st.isFile()) return false;
  mkdirp(path.dirname(abs));
  FS.writeFile(abs, fs.readFileSync(abs));
  staged.add(abs);
  return true;
}
function stageTree(dir, filter) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory() && !e.name.startsWith(".")) stageTree(p, filter);
    else if (e.isFile() && filter(p)) stageFile(p);
  }
}

// libraries: anything under a LIBDIRS entry is mirrored to /libraries/<name>
const stagedLibs = new Set();
function resolveLib(rel) {
  for (const L of LIBDIRS) {
    const cand = path.join(L, rel);
    if (fs.existsSync(cand)) {
      const top = rel.split("/")[0];
      const root = path.join(L, top);
      if (!stagedLibs.has(root)) {
        stagedLibs.add(root);
        if (fs.statSync(root).isDirectory()) {
          // copy to the real path AND expose under /libraries via OPENSCADPATH below
          stageTree(root, p => /\.scad$/i.test(p));
        } else stageFile(root);
      }
      return cand;
    }
  }
  return null;
}

const REF = [
  /\b(?:include|use)\s*<([^>]+)>/g,
  /\bimport\s*\(\s*(?:file\s*=\s*)?"([^"]+)"/g,
  /\bsurface\s*\(\s*(?:file\s*=\s*)?"([^"]+)"/g,
];
function crawl(file) {
  if ((crawl.seen ??= new Set()).has(file)) return;
  crawl.seen.add(file);
  if (!stageFile(file) || !/\.scad$/i.test(file)) return;
  const src = fs.readFileSync(file, "utf8").replace(/\/\*[\s\S]*?\*\//g, "").replace(/\/\/.*$/gm, "");
  for (const re of REF) {
    for (const m of src.matchAll(re)) {
      const ref = m[1];
      const local = path.isAbsolute(ref) ? ref : path.resolve(path.dirname(file), ref);
      const hit = fs.existsSync(local) ? local : (!path.isAbsolute(ref) ? resolveLib(ref) : null);
      if (hit && !crawl.seen.has(hit)) crawl(hit);
    }
  }
}

const cwd = process.cwd();
mkdirp(cwd);
for (const inp of inputs) {
  const abs = path.resolve(cwd, inp);
  crawl(abs);
  const dir = path.dirname(abs);
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isFile() && DATA_EXT.test(e.name) && fs.statSync(p).size < MAX_SIBLING) stageFile(p);
  }
}
for (const [, p] of outputs) mkdirp(path.dirname(path.resolve(cwd, p)));
FS.chdir(cwd);

// fonts for text()
mkdirp("/fonts"); mkdirp("/etc/fonts");
for (const d of ["/usr/share/fonts/truetype/liberation", "/usr/share/fonts/truetype/dejavu",
                 "/System/Library/Fonts/Supplemental"]) {
  if (!fs.existsSync(d)) continue;
  for (const f of fs.readdirSync(d)) if (/\.(ttf|otf)$/i.test(f) && fs.statSync(path.join(d, f)).size < 3e6)
    FS.writeFile("/fonts/" + f, fs.readFileSync(path.join(d, f)));
}
const conf = `<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig><dir>/fonts</dir><cachedir>/tmp/fc</cachedir></fontconfig>`;
FS.writeFile("/fonts/fonts.conf", conf); FS.writeFile("/etc/fonts/fonts.conf", conf);

// libraries reachable by include <BOSL2/std.scad>: wasm OpenSCAD's resource path
// is the working directory, so its built-in library dir is <cwd>/libraries.
const libHome = path.join(cwd, "libraries");
mkdirp(libHome);
for (const root of stagedLibs) {
  try { FS.symlink(root, path.join(libHome, path.basename(root))); } catch { /* exists */ }
}

const args = hasBackend || argv.some(a => ["--version", "-v", "--help", "-h", "--info"].includes(a))
  ? argv : ["--backend=manifold", ...argv];
let rc;
try { rc = M.callMain(args); } catch (e) { process.stderr.write(String(e) + "\n"); rc = 1; }

// copy outputs back to disk
for (const [, p] of outputs) {
  if (!p || p === "-") continue;
  const abs = path.resolve(cwd, p);
  try { fs.writeFileSync(abs, FS.readFile(abs)); } catch { /* not produced */ }
}
process.exit(rc ?? 0);
