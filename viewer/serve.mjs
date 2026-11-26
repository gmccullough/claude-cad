#!/usr/bin/env node
// Zero-dependency server for the viewer. Serves the repo root, so the viewer at
// /viewer/ can fetch any STL/3MF in the tree, plus a live file list at /__manifest.
//
//   tools/view [port]        (default 8000; HOST env to change bind address)
//   open http://localhost:8000/viewer/?file=examples/triangular-elipsoid/triangular_elipsoid_v3.3mf
import { createServer } from "node:http";
import { readFile, stat } from "node:fs/promises";
import { normalize, join, extname } from "node:path";
import { scan, repoRoot, kitRoot } from "./generate-manifest.mjs";

const port = Number(process.argv[2] || process.env.PORT) || 8000;
const host = process.env.HOST || "127.0.0.1";
const TYPES = {
  ".html": "text/html; charset=utf-8", ".js": "text/javascript; charset=utf-8", ".mjs": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8", ".css": "text/css; charset=utf-8", ".png": "image/png", ".gif": "image/gif",
  ".jpg": "image/jpeg", ".svg": "image/svg+xml", ".stl": "model/stl", ".3mf": "model/3mf",
};

createServer(async (req, res) => {
  try {
    let urlPath = decodeURIComponent(new URL(req.url, "http://x").pathname);
    if (urlPath === "/__manifest") {
      res.writeHead(200, { "Content-Type": TYPES[".json"], "Cache-Control": "no-cache" });
      return res.end(JSON.stringify(await scan()));
    }
    if (urlPath === "/") { res.writeHead(302, { Location: "/viewer/" }); return res.end(); }
    if (urlPath.endsWith("/")) urlPath += "index.html";
    const base = urlPath.startsWith("/viewer/") ? kitRoot : repoRoot;   // viewer from the kit, models from the workspace
    const filePath = normalize(join(base, urlPath));
    if (!filePath.startsWith(normalize(base)) || /\/\.git(\/|$)/.test(filePath)) return res.writeHead(403).end("Forbidden");
    const info = await stat(filePath);
    if (!info.isFile()) return res.writeHead(404).end("Not found");
    res.writeHead(200, { "Content-Type": TYPES[extname(filePath).toLowerCase()] || "application/octet-stream",
      "Content-Length": info.size, "Cache-Control": "no-cache" });
    res.end(await readFile(filePath));
  } catch {
    res.writeHead(404).end("Not found");
  }
}).listen(port, host, () => console.log(`viewer: http://localhost:${port}/viewer/`));
