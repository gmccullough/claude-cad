"""Pack the repo's STL/3MF files compactly for the artifact viewer.

STL -> welded indexed mesh: header JSON line + float32 xyz + uint32 tris, gzipped,
then base64 inside a small JSON file ({"name","kind","b64"}). 3MF is already a zip,
so it is base64'd as is. Writes <out>/models/<id>.json and <out>/models/index.json.

    python3 tools/cloud/pack_models.py OUT_DIR [--budget-mb 55] [--max-mb 12] [paths...]
"""
import argparse, base64, gzip, json, os, re, struct, subprocess, sys
from pathlib import Path
try:
    import numpy as np
    import trimesh
except ImportError:   # first use in a fresh container: install the Python deps, then retry
    import subprocess
    subprocess.run([str(Path(__file__).with_name("need")), "python"], check=True)
    import numpy as np
    import trimesh

KIT = Path(__file__).resolve().parents[2]   # the kit itself (resolved through symlinks)


def _root():
    """The workspace holding the user's models: $CAD_ROOT, else the git top level of the
    current directory, else the cwd. Same as KIT unless the kit is vendored as kit/."""
    if os.environ.get("CAD_ROOT"):
        return Path(os.environ["CAD_ROOT"]).resolve()
    g = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True)
    return Path(g.stdout.strip()) if g.returncode == 0 else Path.cwd()


REPO = _root()
SKIP = {".git", "node_modules", ".cache", "vendor", ".renders"}


def find():
    for root, dirs, files in os.walk(REPO):
        dirs[:] = [d for d in dirs if d not in SKIP and not d.startswith(".")]
        for f in files:
            if f.lower().endswith((".stl", ".3mf")):
                yield Path(root) / f


def pack_stl(p):
    m = trimesh.load(p, force="mesh", process=True)   # merges duplicate vertices
    v = np.ascontiguousarray(m.vertices, dtype="<f4")
    f = np.ascontiguousarray(m.faces, dtype="<u4")
    head = struct.pack("<II", len(v), len(f))
    return gzip.compress(head + v.tobytes() + f.tobytes(), 9), "mesh"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out")
    ap.add_argument("--budget-mb", type=float, default=55)
    ap.add_argument("--max-mb", type=float, default=12)
    ap.add_argument("paths", nargs="*")
    a = ap.parse_args()
    out = Path(a.out) / "models"
    out.mkdir(parents=True, exist_ok=True)
    files = [Path(p).resolve() for p in a.paths] or sorted(find())
    packed, skipped, total = [], [], 0
    for p in sorted(files, key=lambda p: p.stat().st_size):
        rel = p.relative_to(REPO).as_posix()
        try:
            data, kind = (p.read_bytes(), "3mf") if p.suffix.lower() == ".3mf" else pack_stl(p)
        except Exception as e:
            skipped.append((rel, f"unreadable: {e}")); continue
        b64 = base64.b64encode(data).decode()
        size = len(b64)
        if size > a.max_mb * 2**20 or total + size > a.budget_mb * 2**20:
            skipped.append((rel, f"{size/2**20:.1f} MB packed")); continue
        ident = re.sub(r"[^a-z0-9]+", "-", rel.lower()).strip("-")
        (out / f"{ident}.json").write_text(json.dumps({"name": p.name, "kind": kind, "b64": b64}))
        total += size
        packed.append({"id": ident, "path": rel, "name": p.name, "project": rel.split("/")[0] if "/" in rel else "(root)",
                       "bytes": p.stat().st_size, "packed": size})
    packed.sort(key=lambda m: m["path"])
    (out / "index.json").write_text(json.dumps({"models": packed, "skipped": [{"path": r, "why": w} for r, w in skipped]}))
    print(f"packed {len(packed)} files, {total/2**20:.1f} MB; skipped {len(skipped)}", file=sys.stderr)
    for r, w in skipped:
        print(f"  skipped {r}: {w}", file=sys.stderr)


if __name__ == "__main__":
    main()
