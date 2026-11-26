# tools/cloud — run the repo without the Mac

Everything the projects do on the laptop (OpenSCAD exports, `build_3mf.py`
pipelines, trimesh/manifold checks, PNG renders, turntables) runs in a Linux
cloud container (a Claude Code cloud session) or on any Linux box.

Nothing needs installing up front. Each tool installs what it needs on first use through
`tools/cloud/need <capability>` (python, openscad, openscad-native, render, blender, bambu). It's idempotent
and takes about 1 s when the capability is already installed. `tools/cloud/setup.sh [--blender] [--bambu]`
installs everything at once.

```bash
tools/openscad -o x.stl model.scad          # OpenSCAD 2025 + Manifold (wasm)
tools/render model.stl|plate.3mf|part.scad  # PNG sheet -> .renders/<name>.png
tools/view                                  # interactive viewer on :8000
```

## What replaces what

| On the Mac | In the cloud | Notes |
|---|---|---|
| `/Applications/OpenSCAD.app` | `tools/openscad` → `cloud/openscad.mjs` | OpenSCAD **2025.01** compiled to WebAssembly, run by Node. Defaults to `--backend=manifold`. BOSL2 and the Liberation/DejaVu fonts are staged automatically. On a Mac with the app installed, `tools/openscad` just execs the app. |
| `OpenSCAD -o x.png` | same command | wasm has no OpenGL, so PNG export goes to apt's native **OpenSCAD 2021** under Xvfb (real `$vpt/$vpr/$vpd`, `--camera`, colour schemes). 2021's `--render` drops `color()` (2025+Manifold keeps it), so `--render` is swapped for `--preview`, which keeps colours. Without apt/Xvfb, or with `OPENSCAD_PNG_VIA_VIEWER=1`, it renders with `tools/render` instead. Verified: output matches the Mac renders. |
| Opening STLs/3MFs in OpenSCAD/Bambu to look | `tools/render` (headless) and `tools/view` (interactive) | Same three.js code (`viewer/lib/`). Reads Bambu 3MF: objects at bed position, modifier/negative parts, pause layers, headline print settings. |
| Blender stills | `tools/blender` (installs on first use), or `tools/render` | apt Blender 4.0.2 runs Cycles headless on CPU. Blender render scripts run unchanged in the cloud (10 renders in about 2 min) and match the Mac output. Scripts should switch to 4.0's auto-smooth when the 4.1 operator is missing. Ubuntu's build has no OpenImageDenoise, so they drop denoising and use 4x samples. |
| `/opt/homebrew/bin/python3.9` | `python3` (3.13) + `requirements.txt` | numpy, scipy, trimesh(+rtree), manifold3d, shapely, matplotlib, pillow, opencv-headless, pymeshfix. |
| Bambu Studio CLI `--slice` | `tools/bambu-studio`, `check_slice.py` | Linux AppImage v02.09.01.70, installed on first use (`need bambu` → `install_bambu.sh`). Needs GitHub release downloads, which your cloud environment must allow (see BAMBU.md). Verified against the Mac results. The process and the upgrade steps are in [BAMBU.md](BAMBU.md). |

Scripts that hard-coded the OpenSCAD path now use
`os.environ.get("OPENSCAD")`, falling back to `tools/openscad` found by walking up from the script.

## tools/render

```
tools/render FILE... [-o out.png] [--views iso,front,right,top] [--persp] [--size 800x600]
                     [--scheme paper|cornfield|tomorrow|sunset|metal] [--edges] [--no-grid]
                     [--section z=2.4] [--zoom 1.5] [--turntable spin.gif --frames 36]
                     [--json] [-D var=value ...]
```

- Default sheet: iso (perspective) plus front/right/top (orthographic, fitted to the part), with a header giving size, volume, triangle count, objects, modifiers and pauses.
- `--section z=<pause height>` cuts the part there. Cut faces show red, so magnet pockets read as holes at the pause layer.
- `--json` prints the numbers (bbox, volume, parts, pauses, settings) so a script or agent can assert on them.
- Several input files stack into one image for before/after comparison.
- Runs headless Chromium through Playwright (SwiftShader WebGL). A sheet takes about 3 s.

## tools/view

`tools/view [port]` serves the repo with a live file list (every `.stl`/`.3mf`,
generated ones too) and the viewer at `/viewer/`. It binds to 127.0.0.1. Deep links work:
`/viewer/?file=examples/triangular-elipsoid/triangular_elipsoid_v3.3mf`. It handles touch gestures (pinch, orbit) on phones.

## Network notes (cloud sessions)

`npm`, `pip` and `git clone` of public GitHub repos work by default. Downloads
from `files.openscad.org`, `download.blender.org` and GitHub release assets are
blocked by the default policy, which is why OpenSCAD comes from npm (wasm) and
apt rather than an AppImage.

## Sharing a model to a phone (claude.ai artifact)

`build_artifact.py` writes one self-contained HTML page that a Claude session publishes as a private
claude.ai artifact, protected by your Claude login. Each `Label=path[,path]` argument becomes one tab:

```bash
python3 tools/cloud/build_artifact.py /tmp/myproj.html "My Project" \
  "Assembly=myproj/out/plate_a.stl,myproj/out/plate_b.stl" \
  "Plate A=myproj/out/plate_a.stl"
```

STLs are repacked as welded, gzipped meshes (a 5.5 MB STL packs to about 336 KB), and 3MFs are embedded as is.
Our viewer code and UI add about 33 KB. three.js (1.3 MB, about 260 KB compressed) loads from jsDelivr,
so it adds nothing to the page. An artifact page is limited to 16 MB. `pack_models.py` packs files the same way in bulk.
