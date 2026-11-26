# CAD with Claude: OpenSCAD for 3D printing

This repo is a working setup for designing printable parts with an AI coding agent. Claude
writes parametric OpenSCAD, builds it, looks at the result, and hands you a ready-to-slice
Bambu `.3mf`. This file is the agent's standing guide: shared patterns, tolerances, the photo
measuring practice and the tooling. Each project directory has its own `AGENTS.md` with its
status, measurements and print results.

## Where knowledge lives (repo docs, not agent memory)

Everything worth knowing next time goes **into the repo**, so every clone and every cloud
session gets it. Don't rely on an agent's private memory for it: nobody else can see that, and
it drifts away from the code. `.claude/settings.json` turns Claude Code's auto-memory off for
this repo to enforce that.

| What you learned | Where it goes |
|---|---|
| A project's status, measurements, print results, open questions, lessons | that project's `AGENTS.md` (dated entries; supersede, don't just append contradictions) |
| Cross-project modeling rules and conventions | this file |
| A tool's gotcha (OpenSCAD, Bambu, trimesh, cloud setup) | `tools/README.md`, `tools/cloud/README.md` or `tools/cloud/BAMBU.md` |
| Photo-measurement accuracy after a real-world check | the calibration log under "Measuring from photos" below |
| Photos, scans or reference files the user sends | the project's `ref/` (photos in `ref/photos/`), the same turn they arrive |
| A step-by-step process that failed and then worked | the process doc it belongs to (e.g. `photo-to-cad-process.md`) |

Record lessons **as they happen**: one line when something fails and gets fixed, not a
write-up at the end. Commit doc updates with the work they describe.

## Working with the person printing

- Expect iteration: simple prototype → print → real-world test → refine. Before changing a
  design that's out for printing, ask how the print went.
- People talk in physical terms (layers, thickness, diameter). Translate to print-ready values:
  "layers" = 0.2 mm print layers, and thicknesses snap to 0.2 mm multiples (see Print Settings).
- People edit parameters by hand between sessions. Read the current files before regenerating
  anything, and never overwrite hand-tuned values.
- When a result "looks wrong" to them, assume the target was misunderstood (wrong station,
  wrong feature) before blaming stale files or caching. Restate the target in model
  coordinates first.
- When you name an output file (`.3mf`, `.stl`, a render), give its full absolute path. Only
  full paths render as clickable links in the Claude Code terminal.

## Always build through to the .3mf

Any change to a printable part isn't finished at the STL. Regenerate the ready-to-slice Bambu
`.3mf`: run the project's `build_3mf.py`, or write one with `tools/bambu3mf.py` if the project
has none. End the reply with the .3mf's full path on its own line. `*.3mf` is gitignored, so
the file only exists on disk and a commit won't carry it.

## Examples

| Directory | What it shows |
|---|---|
| [examples/triangular-elipsoid/](examples/triangular-elipsoid/) | Fidget spinner with a 608 bearing and magnets: two different plates, terraced dome, magnet pause read from the model's own echo into the `.3mf` |
| [examples/roval-wahoo-mount/](examples/roval-wahoo-mount/) | Out-front bike computer mount: bar section traced from photos, OEM receiver grafted from the maker's STL, 20+ versions of print-and-report iteration in its `AGENTS.md` |

## Measuring from photos (standing practice)

Whenever the user sends photos of a part, bike, or anything being designed around, **do not
wait to be asked**: estimate every dimension the design needs from the photos, then report:

1. **A value and an ~80% range for each one** (e.g. `65 mm, 62–69`), plus the basis: which
   photo, what was used as the scale, and what limits the accuracy (parallax, perspective,
   a guessed reference size).
2. **Which assumptions are structural, with a confidence %**: which way a bolt points, whether
   a part is centred, what touches what. These sink a design faster than a 2 mm error.
3. **Targeted follow-up measurements**, only for values whose range is wider than the design
   can tolerate. Say exactly what to measure, from where to where, and with what tool.

Build with the estimates anyway: mark them `(~)` in the `.scad` and record the confidence table
in the project's AGENTS.md. Don't block on measurements.

**Save every photo the user sends into the project, the same turn it arrives:**
`<project>/ref/photos/`, as originals (HEIC is fine; also keep a converted JPEG if you work
from one). Name them by the camera's file name (`IMG_2551.HEIC`) and refer to them by those
names in the project's AGENTS.md. Photos attached in chat or left in a downloads folder
disappear, and then the numbers taken from them can't be re-checked or re-traced.

**Technique that works:**
- Scale from a rule or object **in the same plane** as the feature. A rule laid behind or below
  a feature reads it big or small; correct for that, or widen the range.
- Prefer photos taken square-on to the measured feature. Oblique shots are good for topology
  (what connects to what), not for size.
- Read rules at both ends of a span; don't trust a single tick next to a blurred edge.
- Cross-check one value from two photos. If they disagree, the range must cover both.
- Use known objects for scale: bolt heads (M4 button 7.6, M5 button 9.5, M5 SHCS 8.5), GoPro
  prongs (3.0 thick, 5 mm screw), 700c wheels, Garmin/Wahoo pucks.
- Reference meshes beat photos. When the user can supply an OEM STL, cut the needed feature
  out of it instead of re-modelling it (see `examples/roval-wahoo-mount/extract_receiver.py`).

**Replicating a shape from photos (organic or multi-feature parts):**
- Work 2D-first: [photo-to-cad-process.md](photo-to-cad-process.md) is the full pipeline. It
  covers SVGs in mm as the shared artifact, at least two agreeing scale anchors, and a
  cross-section station plan reviewed while still 2D. 3D is only a loft of approved stations,
  checked by slicing the mesh back onto them. It exists because three 3D-first attempts at
  one part failed.
- A silhouette match proves the outline, not what each feature is. One replica's flutes
  matched every overlay and were still the wrong feature. A fresh-context critic caught it.
  Test feature-identity claims on photos you didn't fit to.
- Before claiming a match, render the real model (`tools/render`, or OpenSCAD
  `--render --camera=...`) at each reference photo's angle and list what still differs.
  Matplotlib previews and section plots hide form errors.
- Hand-trace masks for glossy black parts; automatic segmentation follows the reflections.

### Calibration log (append after every real-world check)

Each entry: project, what was estimated, the range given, the true value, and the lesson.
Over time this shows which estimates are reliable and which need a follow-up measurement.

| Date | Project | Estimate (range) | Actual | Lesson |
|---|---|---|---|---|
| 2026-11-15 | roval-wahoo-mount | arm "off-centre" from an oblique photo | centred (from-below shot) | Read topology from square-on views. |
| 2026-11-15 | roval-wahoo-mount | bolt axis vertical into bar underside (60%) | horizontal into the bar's front face | A bolt head seen face-on in an upward photo does NOT mean the bolt is vertical; the camera was looking up-and-back at the bar's front face. Cross-check bolt direction against a side view. Below ~75% confidence, ask before building on it. |
| 2026-11-15 | roval-wahoo-mount | bar section from 4 side photos | — | A rule standing on the part, square to the camera, gave two photos agreeing to 0.1 mm. Ask for that setup. Silhouettes of a bar seen end-on show the NEAREST section, so its height is an upper-bound-ish read of the centre. |

## Tooling: what each kind of request needs (cloud or desktop)

Nothing is preinstalled. Each capability installs itself the first time a tool needs it
(`tools/cloud/need <cap>`, idempotent, ~1 s when already present). **Set up only what the
request needs.** A question about a model's design, parameters or history usually needs
nothing: read the `.scad`, the project's `AGENTS.md` and its echo output.

| The request needs… | Use | Capability (auto-installs on first use) |
|---|---|---|
| Answers about design, parameters, history | Read the `.scad` / docs | none |
| Numbers from a mesh: bbox, volume, sections, fit checks | `trimesh`/`manifold3d` in Python, or `tools/render FILE --json` | `python` (~30 s) |
| Build STL from `.scad` (incl. project `build*.py`) | `tools/openscad` | `openscad` (wasm 2025 + BOSL2, ~5 s) |
| You (the agent) looking at a model | `tools/render FILE.(stl\|3mf\|scad)`, then read the PNG in `.renders/` | `render` (Playwright, preinstalled in Claude cloud sessions) |
| Showing a model to the person | `tools/cloud/build_artifact.py`, then publish with the Artifact tool | `python` |
| OpenSCAD's own look/camera as PNG | `tools/openscad … -o x.png` | `openscad-native` (apt, ~30 s) |
| Build a Bambu 3MF | the project's `build_3mf.py` (uses `tools/bambu3mf.py`) | `python` + `openscad` |
| Check what Bambu really does with a 3MF | `python3 tools/cloud/check_slice.py plate.3mf [--probe X,Y,R,Z]` | `bambu` (~20 s; needs GitHub release downloads allowed) |
| Photoreal renders | `tools/blender -b -P render.py` | `blender` (apt, ~1 min) |

If a script fails with `ImportError`, run `tools/cloud/need python` and retry.
`tools/cloud/need all` installs everything at once.

**Looking at a model (agent):** `tools/render` writes a sheet (iso + fitted ortho views). Options:
- `--section z=<h>` cuts at a height, e.g. a magnet pause; cut faces show red.
- `--json` gives size, volume, parts, pauses and settings to assert on.
- `--turntable x.gif` writes an orbit GIF.

**Showing a model to the person:** build a single-file viewer page, then publish it.
```bash
python3 tools/cloud/build_artifact.py <scratchpad>/name.html "Readable Name" \
  "Assembly=proj/out/a.stl,proj/out/b.stl" "Part A=proj/out/a.stl"   # one tab per Label=paths
```
- The page is a private claude.ai link that works on a phone: orbit, pinch zoom, Z cut, size
  and volume readout. STL and 3MF both work; STLs pack about 30x smaller. Keep it under 16 MB.
- When the model changes, republish the same file path so the link stays the same.
- Do this instead of telling the person to open files in OpenSCAD or Bambu Studio.

**Checking a 3MF by slicing it:** `check_slice.py` reports the settings Bambu actually applied
(catches overrides silently reverted), the layer each pause lands after, grams of filament, and
infill line spacing at probe points (about 0.43 mm means a modifier really went solid).

**Desktop:** the wrappers prefer the Mac apps (`tools/openscad`, `tools/bambu-studio`,
`tools/blender`) when installed. `tools/render` needs Playwright once:
`npm i -g playwright && npx playwright install chromium`. `tools/view` serves an interactive
viewer on localhost:8000.

Details: [tools/README.md](tools/README.md), [tools/cloud/README.md](tools/cloud/README.md).

## OpenSCAD Language Reference

**On session start**: Read [OPENSCAD_DOCS.md](OPENSCAD_DOCS.md) for key language features,
hidden gems, pitfalls, and links to the full local documentation in `docs/`. Consult the linked
docs files when working with specific features.

Construction priority for any new part: topology → shape → size → detail. Choose primitives by
aspect ratio (`rotate_extrude` for round bodies, hull chains of discs or spheres for tapered
or swept ones), and compute `$fn` from radius rather than hardcoding it.

## OpenSCAD Basics

- **Preview (F5)** is fast but shows boolean operations as coloured overlays (green =
  subtraction volume, not the final result). **Render (F6)** computes the real CSG. Always
  verify cross-sections and booleans with a render.

### Cross-Section Visualization

```openscad
cross_section = true;  // Toggle at top of file

module cut_plane() {
    translate([-100, 0, -1]) cube([200, 100, 50]);  // Cuts at y=0
}

difference() {
    your_model();
    if (cross_section) cut_plane();
}
```

**Common mistake**: the cut plane must actually intersect the model. If parts are translated,
the cut plane must account for their positions. (`tools/render --section z=<h>` does this
without editing the model.)

## Key OpenSCAD Patterns

### Rounded Polygons (2D)
Double-offset rounds corners while keeping the size:
```openscad
module rounded_polygon_2d(size, radius) {
    offset(r = radius) offset(r = -radius) your_polygon_2d(size);
}
```

### Creating Domes

**Wrong: `hull()` creates a linear taper, not a curve:**
```openscad
hull() {   // a truncated cone, NOT a dome
    linear_extrude(0.1) circle(r = 25);
    translate([0, 0, 10]) linear_extrude(0.1) circle(r = 5);
}
```

**Right: sphere intersection:**
```openscad
// R = (base_r² + dome_h²) / (2 * dome_h)
sphere_r = (25*25 + 3*3) / (2*3);  // ≈ 106mm for a gentle curve

intersection() {
    linear_extrude(height = dome_height) your_base_shape();
    translate([0, 0, dome_height - sphere_r]) sphere(r = sphere_r, $fn = 128);  // top touches z = dome_height
}
```

Gentle domes (~10° average slope) show ugly layer stair-stepping. Deliberate terraces at
0.2 mm-multiple heights often print better (see `examples/triangular-elipsoid`).

### Wavy Surfaces
For surfaces that vary with angle (radial waves):
```openscad
function wave_z(angle, base, amplitude, num_waves) =
    base + amplitude * (1 + sin(num_waves * angle)) / 2;
// Build with hull() segments around the circumference, vertices at each angle's height.
```

### Conditional Geometry
Keep optional geometry inside the operation it modifies rather than switching whole models:
```openscad
difference() {
    main_model();
    if (cross_section) cut_plane();
}
```

## Magnet Pocket Design

### Pause-and-Insert Workflow
Design pockets so magnets can be inserted mid-print:

1. **Pockets on the top surface** (not the bottom): print most of the part first
2. **Pause at the pocket's top** and insert the magnets
3. **Resume to seal**: cover layers bridge over the magnets

```openscad
magnet_diameter = 8;
magnet_height = 2;
magnet_clearance = 0.2;      // extra diameter for easy insertion
cover_layers = 2;
layer_height = 0.2;
cover_thickness = cover_layers * layer_height;  // 0.4mm

pocket_diameter = magnet_diameter + magnet_clearance;
pocket_depth = magnet_height;
pocket_z = total_height - cover_thickness - pocket_depth;
pause_height = total_height - cover_thickness;   // for the slicer

module magnet_pocket() {
    translate([0, 0, pocket_z]) cylinder(h = pocket_depth, d = pocket_diameter, $fn = 32);
}
```

`echo()` the pause height and have `build_3mf.py` read it from the OpenSCAD output, so the
pause in the `.3mf` can never drift from the pocket it serves
(`examples/triangular-elipsoid/build_3mf.py` does this).

## Tolerances for Fit

| Feature | Clearance | Notes |
|---------|-----------|-------|
| Magnet pockets | +0.2mm diameter | Easy insertion |
| Pivot holes | +0.2mm diameter | Smooth rotation |
| Pivot pins | -0.1mm diameter | Combined with hole clearance = 0.15mm per side |
| Press-fit | -0.1 to -0.2mm | Tight friction fit |

Clearances depend on printer and filament. When a fit matters, print a small fit coupon with
three or four variants first and record which one won in the project's AGENTS.md.

## Multi-Part Assembly

### Identical Parts That Flip
When two identical parts assemble with one flipped 180°, features on TOP of the printed part
become BOTTOM when assembled. Put holes and pins on the same (top) side; they align when one
part is flipped.

### Magnetic Snap Positions
For N clicks per rotation, use N magnets at 360/N° intervals. A triangle with 6 magnets clicks
at the corners (0°, 120°, 240°) and between them (60°, 180°, 300°).

## Hardware standards and fastening rules

- **Garmin quarter-turn: 20.00 mm** centre-to-centre is the standard.
- **M3 brass heat-set inserts** (6.0 long, OD 4.4 max / 4.2 min): a bore of **3.6 x 7.0 deep**
  with a 0.5 mm mouth chamfer, at least 2 mm of wall and floor, and a 5.0 x 0.6 counterbore on
  flat mating pads worked in PLA. 3.6 is empirical, not the ~4.0 a spec sheet gives; check it
  against your inserts.
- **Only use inserts where the iron goes straight in on a flat, open face.** On a tilted face at
  the bottom of a recess they press in crooked. Otherwise use a through-bolt with a captive nut.
- **No PLA living hinges or single-layer parts that get handled.** A 0.2 mm folded PLA sheet
  cracks at the creases and when peeled.
- **Push-on clips pry their jaws across layer lines at the web.** Never thin or notch the web to
  avoid a small bridge; a clip with a 1.35 mm V-groove at the web broke there.

## Editing existing STL meshes

When someone wants to change a scanned or downloaded mesh, keep it a mesh. Don't rebuild it as
OpenSCAD primitives and don't try to convert it to CAD surfaces.
- Morph regions with Python/trimesh: select vertices by region, deform with a smooth falloff
  into the neighbouring geometry, and export. Pin features that must stay put (holes, mounting
  faces) with tagged vertex groups or a cage.
- Heal scans with `pymeshfix` before any boolean, then cut features (bolt holes)
  parametrically in OpenSCAD over the healed mesh (`import()` the healed STL and `difference()`).
- To graft a feature from an OEM STL, cut it out with manifold3d and `import()` it
  (`examples/roval-wahoo-mount/extract_receiver.py`).

## Print Settings Recommendations

- **Default layer height**: 0.2mm. "Layers" means print layers at this height ("two layers" =
  0.4mm, "5 layers" = 1.0mm). Snap all vertical dimensions to 0.2mm multiples so they align
  with print layers.
- **Layer height (detail)**: 0.12mm
- **Infill**: 20-40% for small parts and toys
- **Walls**: 3-4 perimeters for strength
- **Top/bottom layers**: 4+ for good bridging over magnet pockets
- **Supports**: design them out where possible (flat bottoms, 45° overhangs)

## File Structure

Each design should include:
- `design_name.scad`: OpenSCAD source with parameters at the top
- `AGENTS.md`: purpose, parameters, measurements with confidence, print results and lessons
  (dated)
- `build_3mf.py`: STL export + `.3mf` via `tools/bambu3mf.py`

```openscad
// Title and description, key specifications

// === PREVIEW ===
cross_section = false;

// === PARAMETERS ===
// Dimensions, tolerances, etc. Mark photo estimates with (~).

// === MODULES ===

// === FINAL MODEL ===

// === INFO ===
echo(str("PAUSE HEIGHT: ", pause_height));
```

## Common Mistakes

1. **Cut plane misses the model**: account for translated parts
2. **Using preview to verify geometry**: render booleans
3. **`hull()` for domes**: makes a linear taper; use sphere intersection
4. **Pockets on the bottom**: put them on top for pause-and-insert
5. **Forgetting cover thickness**: account for it in `pocket_z`
6. **Through-holes vs pockets**: through-holes don't need a cover calculation

## CLI Rendering & Self-Testing

`tools/openscad` runs anywhere: the Mac app if installed, else OpenSCAD 2025 compiled to wasm
(Linux, cloud).

### Quick error check (after every edit)

Export CSG: it validates syntax and evaluates the model tree without the expensive geometry
computation, catching syntax errors, undefined variables, assertion failures and missing
modules in seconds.

```bash
tools/openscad -o /tmp/check.csg model.scad
```

Don't use `-o /dev/null`: OpenSCAD picks the output format from the extension.

### Looking at it

Use `tools/render` for a full visual check at milestones, when the person asks to see it, or
when spatial relationships need verifying. Don't render after every small edit.

For OpenSCAD's own look: `tools/openscad --render --autocenter --viewall --imgsize=1600,1000
--projection=p --colorscheme=Tomorrow -o /tmp/render.png model.scad`. Camera format:
`--camera=translate_x,y,z,rot_x,y,z,distance`.

### Common CLI error messages
| Error | Meaning |
|-------|---------|
| `Parser error: syntax error` | Syntax error in .scad file |
| `WARNING: ... is not defined` | Undefined variable or module |
| `ERROR: Assertion ... failed` | BOSL2 or library assertion (e.g., wrong bezier point count) |
| `CGAL error` | Geometry error (non-manifold, etc.) |

### BOSL2 notes
BOSL2 is staged automatically by `tools/cloud/need openscad`.
- `bezpath_curve(points, N=3)` requires `3*k + 1` points for cubic
- `bezpath_curve(points, N=2)` requires `2*k + 1` points for quadratic
- Read BOSL2 assertion errors carefully; they usually mean a parameter is wrong.
