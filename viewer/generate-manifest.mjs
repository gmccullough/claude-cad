#!/usr/bin/env node
// Scans the repository for .stl / .3mf files. tools/view serves this list live
// at /__manifest; running this script writes a static viewer/manifest.json for
// other static servers (python3 -m http.server, etc.).
//
// Usage:  node viewer/generate-manifest.mjs
import { readdir, stat, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join, relative, sep, resolve } from "node:path";
import { spawnSync } from "node:child_process";

const viewerDir = dirname(fileURLToPath(import.meta.url));
export const kitRoot = join(viewerDir, "..");
// The workspace whose models are listed: $CAD_ROOT, else the git top level of the cwd, else
// the kit itself. Differs from kitRoot when the kit is vendored into a bigger repo as kit/.
export const repoRoot = (() => {
  if (process.env.CAD_ROOT) return resolve(process.env.CAD_ROOT);
  const g = spawnSync("git", ["rev-parse", "--show-toplevel"], { encoding: "utf8" });
  return g.status === 0 ? g.stdout.trim() : kitRoot;
})();
const IGNORE_DIRS = new Set([".git", "node_modules", "vendor"]);
const EXT = /\.(stl|3mf)$/i;

async function walk(dir, out) {
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    if (entry.name.startsWith(".")) continue;
    const full = join(dir, entry.name);
    if (entry.isDirectory()) { if (!IGNORE_DIRS.has(entry.name)) await walk(full, out); }
    else if (entry.isFile() && EXT.test(entry.name)) out.push(full);
  }
}

export async function scan() {
  const files = [];
  await walk(repoRoot, files);
  files.sort();
  const models = await Promise.all(files.map(async full => {
    const info = await stat(full);
    const rel = relative(repoRoot, full).split(sep).join("/");
    return { path: rel, name: rel.split("/").pop(), project: rel.includes("/") ? rel.split("/")[0] : "(root)",
             bytes: info.size, modified: info.mtime.toISOString() };
  }));
  return { generated: new Date().toISOString(), count: models.length, models };
}

if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  const manifest = await scan();
  const outPath = join(viewerDir, "manifest.json");
  await writeFile(outPath, JSON.stringify(manifest, null, 2) + "\n");
  console.log(`Wrote ${relative(repoRoot, outPath)} with ${manifest.count} model(s)`);
}
