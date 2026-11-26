#!/usr/bin/env node
// Headless screenshots of STL / 3MF / SCAD files — the cloud replacement for
// `OpenSCAD -o x.png`, Blender stills and turntable GIFs. Drives viewer/render.html
// in headless Chromium (Playwright), so what you get is exactly what the
// interactive viewer shows.
//
//   tools/render model.stl                       # 2x2 sheet: iso + front/right/top (ortho)
//   tools/render plate.3mf --views iso,top       # 3MF: bed, modifiers, pause planes drawn
//   tools/render part.scad -D 'part="band"'      # runs tools/openscad first
//   tools/render model.stl --section z=2.4       # cut at a pause height (cut faces red)
//   tools/render model.stl --turntable spin.gif  # 36-frame orbit GIF
//   tools/render a.stl b.stl -o compare.png      # one sheet per file, stacked
//
// Options:
//   -o FILE            output PNG (default .renders/<name>.png at the repo root)
//   --views LIST       iso,iso2,iso_back,front,back,left,right,top,bottom (default iso,front,right,top)
//   --persp            perspective for axis views too (default: iso perspective, axis views ortho)
//   --size WxH         size of each view tile (default 800x600)
//   --scheme NAME      cornfield | tomorrow | sunset | metal | paper (default paper)
//   --edges            draw feature edges         --no-grid  hide grid/axes
//   --no-pauses        hide pause planes          --no-modifiers  hide modifier volumes
//   --section AX=V     keep the part below AX=V (x|y|z), e.g. z=2.4
//   --zoom F           >1 zooms in (default 1)
//   --turntable FILE   also write an orbit GIF (--frames N, default 36; --gif-size WxH, default 480x480)
//   --json             print stats (size, volume, tris, parts, pauses, settings) as JSON
//   -D ...             passed to OpenSCAD for .scad inputs
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";

const require = createRequire(import.meta.url);
const HERE = path.dirname(fileURLToPath(import.meta.url));
// KIT: where these tools live (resolved through symlinks). ROOT: the workspace the user's
// files live in: $CAD_ROOT, else the git top level of the current directory, else the cwd.
// They are the same directory unless the kit is vendored into a bigger repo as kit/.
const KIT = path.resolve(HERE, "../..");
const ROOT = (() => {
  if (process.env.CAD_ROOT) return path.resolve(process.env.CAD_ROOT);
  const g = spawnSync("git", ["rev-parse", "--show-toplevel"], { encoding: "utf8" });
  return g.status === 0 ? g.stdout.trim() : process.cwd();
})();
const ORIGIN = "http://prints.local";

// ---------------------------------------------------------------- args ----
const a = process.argv.slice(2);
const opt = { views: "iso,front,right,top", size: "800x600", scheme: "paper", frames: 36, gifSize: "480x480",
  zoom: 1, edges: false, grid: true, pauses: true, modifiers: true, persp: false, json: false, D: [] };
const inputs = [];
for (let i = 0; i < a.length; i++) {
  const k = a[i], next = () => a[++i];
  switch (k) {
    case "-o": opt.out = next(); break;
    case "--views": opt.views = next(); break;
    case "--size": opt.size = next(); break;
    case "--scheme": opt.scheme = next(); break;
    case "--section": opt.section = next(); break;
    case "--zoom": opt.zoom = +next(); break;
    case "--turntable": opt.turntable = next(); break;
    case "--frames": opt.frames = +next(); break;
    case "--gif-size": opt.gifSize = next(); break;
    case "--edges": opt.edges = true; break;
    case "--persp": opt.persp = true; break;
    case "--no-grid": opt.grid = false; break;
    case "--no-pauses": opt.pauses = false; break;
    case "--no-modifiers": opt.modifiers = false; break;
    case "--json": opt.json = true; break;
    case "-D": opt.D.push("-D", next()); break;
    case "-h": case "--help":
      console.log(fs.readFileSync(fileURLToPath(import.meta.url), "utf8").split("\n").slice(1, 32).map(l => l.replace(/^\/\/ ?/, "")).join("\n"));
      process.exit(0);
    default:
      if (k.startsWith("-")) { console.error(`unknown option ${k}`); process.exit(2); }
      inputs.push(path.resolve(k));
  }
}
if (!inputs.length) { console.error("usage: tools/render FILE.(stl|3mf|scad) [options]  (--help)"); process.exit(2); }
const [tw, th] = opt.size.split("x").map(Number);

// .scad -> .stl via tools/openscad
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "render-"));
const files = inputs.map((f, i) => {
  if (!/\.scad$/i.test(f)) return { path: f, label: path.relative(ROOT, f).startsWith("..") ? f : path.relative(ROOT, f) };
  const stl = path.join(tmp, `${i}_${path.basename(f, ".scad")}.stl`);
  const r = spawnSync(path.join(KIT, "tools/openscad"), [...opt.D, "-o", stl, f], { stdio: ["ignore", "inherit", "inherit"] });
  if (r.status !== 0 || !fs.existsSync(stl)) { console.error(`openscad failed on ${f}`); process.exit(1); }
  const defs = opt.D.filter((_, j) => j % 2).join(" ");
  return { path: stl, label: path.relative(ROOT, f) + (defs ? `  ${defs}` : "") };
});

// --------------------------------------------------------------- browser ----
const { chromium } = require("playwright");
const browser = await chromium.launch({ args: ["--use-gl=angle", "--use-angle=swiftshader", "--enable-unsafe-swiftshader", "--ignore-gpu-blocklist"] });
const page = await browser.newPage({ viewport: { width: Math.max(tw, 800), height: Math.max(th, 600) } });
const errors = [];
page.on("pageerror", e => errors.push(String(e)));
page.on("console", m => { if (m.type() === "error") errors.push(m.text()); });
await page.route(`${ORIGIN}/**`, async route => {
  const u = new URL(route.request().url());
  let p;
  if (u.pathname === "/__file") p = u.searchParams.get("p");
  else p = path.join(KIT, decodeURIComponent(u.pathname));
  try {
    const body = fs.readFileSync(p);
    const type = /\.html$/.test(p) ? "text/html" : /\.m?js$/.test(p) ? "text/javascript" : "application/octet-stream";
    await route.fulfill({ status: 200, body, contentType: type });
  } catch { await route.fulfill({ status: 404, body: "not found" }); }
});
await page.goto(`${ORIGIN}/viewer/render.html`);
await page.waitForFunction(() => window.__ready === true, null, { timeout: 30000 }).catch(() => {
  console.error("viewer failed to start:\n" + errors.join("\n")); process.exit(1);
});

const views = opt.views.split(",").map(s => s.trim()).filter(Boolean);
const sheets = [], allStats = [];
for (const f of files) {
  const stats = await page.evaluate(async ({ url, name, o }) => {
    const v = window.__viewer;
    v.setScheme(o.scheme);
    v.set({ edges: o.edges, helpers: o.grid, pauses: o.pauses, modifiers: o.modifiers, bed: false });
    if (o.section) { const [ax, val] = o.section.split("="); v.setSection(ax, +val); } else v.setSection(null);
    return await window.__load(url, name);
  }, { url: `${ORIGIN}/__file?p=${encodeURIComponent(f.path)}`, name: f.path, o: opt }).catch(e => {
    console.error(`failed to load ${f.path}: ${e.message.split("\n")[0]}`); process.exit(1);
  });
  allStats.push({ file: f.label, ...stats });

  // one composite sheet per file, built in the page with a 2D canvas
  const png = await page.evaluate(async ({ views, tw, th, o, label, stats }) => {
    const v = window.__viewer;
    const cols = views.length >= 4 ? 2 : views.length, rows = Math.ceil(views.length / cols);
    const head = 64;
    const c = document.createElement("canvas");
    c.width = cols * tw; c.height = rows * th + head;
    const g = c.getContext("2d");
    g.fillStyle = "#fff"; g.fillRect(0, 0, c.width, c.height);
    const load = src => new Promise(r => { const im = new Image(); im.onload = () => r(im); im.src = src; });
    for (let i = 0; i < views.length; i++) {
      const view = views[i], isAxis = !view.startsWith("iso");
      const url = v.snapshot({ view, ortho: isAxis && !o.persp, w: tw, h: th, scale: 1 / o.zoom });
      const im = await load(url);
      const x = (i % cols) * tw, y = head + Math.floor(i / cols) * th;
      g.drawImage(im, x, y);
      g.strokeStyle = "#d0d4da"; g.strokeRect(x + 0.5, y + 0.5, tw - 1, th - 1);
      g.fillStyle = "#334"; g.font = "bold 18px sans-serif";
      g.fillText(view + (isAxis && !o.persp ? " (ortho)" : ""), x + 12, y + 26);
    }
    const s = stats.size.map(n => n.toFixed(1)).join(" × ");
    g.fillStyle = "#111"; g.font = "bold 22px sans-serif"; g.fillText(label, 12, 28);
    g.font = "16px sans-serif"; g.fillStyle = "#444";
    const bits = [`${s} mm`, `${(stats.volume_mm3 / 1000).toFixed(2)} cm³`, `${stats.tris.toLocaleString()} tris`];
    const objs = new Set(stats.parts.filter(p => p.kind === "normal").map(p => p.object));
    if (objs.size > 1) bits.push(`${objs.size} objects`);
    const mods = stats.parts.filter(p => p.kind !== "normal").length;
    if (mods) bits.push(`${mods} modifier/negative parts (blue/red)`);
    if (stats.pauses?.length) bits.push("pauses at z=" + stats.pauses.map(p => p.z).join(", ") + " (orange)");
    if (o.section) bits.push(`section ${o.section} (cut faces red)`);
    g.fillText(bits.join("   ·   "), 12, 52);
    return c.toDataURL("image/png");
  }, { views, tw, th, o: opt, label: f.label, stats });
  sheets.push(png);
}

// stack sheets vertically if several inputs
const finalPng = sheets.length === 1 ? sheets[0] : await page.evaluate(async sheets => {
  const ims = await Promise.all(sheets.map(s => new Promise(r => { const i = new Image(); i.onload = () => r(i); i.src = s; })));
  const c = document.createElement("canvas");
  c.width = Math.max(...ims.map(i => i.width)); c.height = ims.reduce((h, i) => h + i.height, 0);
  const g = c.getContext("2d"); let y = 0;
  for (const i of ims) { g.drawImage(i, 0, y); y += i.height; }
  return c.toDataURL("image/png");
}, sheets);

const stem = path.basename(inputs[0]).replace(/\.(stl|3mf|scad)$/i, "");
const out = path.resolve(opt.out || path.join(ROOT, ".renders", `${stem}.png`));
fs.mkdirSync(path.dirname(out), { recursive: true });
fs.writeFileSync(out, Buffer.from(finalPng.split(",")[1], "base64"));
console.error(`wrote ${out}`);

// ------------------------------------------------------------ turntable ----
if (opt.turntable) {
  const [gw, gh] = opt.gifSize.split("x").map(Number);
  const fdir = path.join(tmp, "frames");
  fs.mkdirSync(fdir);
  for (let i = 0; i < opt.frames; i++) {
    const url = await page.evaluate(({ az, gw, gh, z }) =>
      window.__viewer.snapshot({ view: "iso", w: gw, h: gh, azimuth: az, scale: 1 / z }),
      { az: (360 * i) / opt.frames, gw, gh, z: opt.zoom });
    fs.writeFileSync(path.join(fdir, `f${String(i).padStart(3, "0")}.png`), Buffer.from(url.split(",")[1], "base64"));
  }
  const gif = path.resolve(opt.turntable);
  const py = `import sys,glob\nfrom PIL import Image\nfs=sorted(glob.glob(sys.argv[1]+'/*.png'))\nim=[Image.open(f).convert('RGB').quantize(colors=128, method=Image.Quantize.MEDIANCUT) for f in fs]\nim[0].save(sys.argv[2],save_all=True,append_images=im[1:],duration=int(sys.argv[3]),loop=0,optimize=True)`;
  const r = spawnSync("python3", ["-c", py, fdir, gif, String(Math.round(3000 / opt.frames))], { stdio: "inherit" });
  if (r.status === 0) console.error(`wrote ${gif}`);
}

if (opt.json) console.log(JSON.stringify(files.length === 1 ? allStats[0] : allStats, null, 2));
if (errors.length) console.error("page errors:\n  " + errors.join("\n  "));
await browser.close();
fs.rmSync(tmp, { recursive: true, force: true });
