"""Build a single-file viewer page (for a claude.ai artifact) with models embedded.

    python3 tools/cloud/build_artifact.py OUT.html "Page Title" \
        "Assembly=myproj/out/plate_a.stl,myproj/out/plate_b.stl" \
        "Plate A=myproj/out/plate_a.stl" ...

Each "Label=path[,path...]" becomes one view (files in a view are shown together,
one colour each). STLs are welded and gzipped (~30x smaller than ASCII/binary STL);
3MFs are embedded as is. three.js r160 loads from jsDelivr (allowed by the
artifact CSP); the viewer core is inlined from viewer/lib/*.js, so the page is
our ~25 KB of code plus the packed models.
"""
import base64, html, json, re, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from pack_models import pack_stl, REPO, KIT  # noqa: E402

THREE = "https://cdn.jsdelivr.net/npm/three@0.160.0"


def strip_module(src):
    src = re.sub(r'^import .*?;\s*$', "", src, flags=re.M)
    return re.sub(r'^export (?=(async )?function|const|let)', "", src, flags=re.M)


def main():
    out, title, *specs = sys.argv[1:]
    views, blobs = [], {}
    for spec in specs:
        label, paths = spec.split("=", 1)
        files = []
        for rel in paths.split(","):
            p = Path(rel).resolve() if Path(rel).exists() else (REPO / rel).resolve()
            key = p.relative_to(REPO).as_posix() if p.is_relative_to(REPO) else p.name
            if key not in blobs:
                data, kind = (p.read_bytes(), "3mf") if p.suffix.lower() == ".3mf" else pack_stl(p)
                blobs[key] = {"name": p.name, "kind": kind, "b64": base64.b64encode(data).decode()}
            files.append(key)
        slug = re.sub(r"[^a-z0-9]+", "-", label.lower()).strip("-")
        views.append({"id": slug, "label": label, "files": files})
    lib = KIT / "viewer/lib"
    code = strip_module((lib / "loaders.js").read_text()) + "\n" + strip_module((lib / "viewer.js").read_text())
    page = (Path(__file__).parent / "artifact_template.html").read_text()
    page = (page.replace("{{TITLE}}", html.escape(title))
                .replace("{{THREE}}", THREE)
                .replace("/*{{CORE}}*/", code)
                .replace("{{DATA}}", json.dumps({"views": views, "blobs": blobs}).replace("</", "<\\/")))
    Path(out).write_text(page)
    models = sum(len(b["b64"]) for b in blobs.values())
    print(f"wrote {out}: {len(page)/1024:.0f} KB total, models {models/1024:.0f} KB, "
          f"code+UI {(len(page)-models)/1024:.0f} KB (three.js from CDN)", file=sys.stderr)


if __name__ == "__main__":
    main()
