# tools/

## bambu3mf.py — generate Bambu Studio .3mf projects from the repo

A Bambu `.3mf` is a ZIP of OPC parts. `bambu3mf.build()` writes the ones that
matter and lets the slicer regenerate the rest (thumbnails, slice cache).

```python
import bambu3mf
bambu3mf.build(
    "out.3mf",
    ["plate_a.stl", "plate_b.stl"],          # one object each, laid out along X
    profile="tools/profiles/p2s_pla_0.20mm.json",
    overrides={"wall_loops": 3},             # deltas from the stock profile
    pauses=[(2.6, "M400 U1")],               # (top_z, gcode) — M400 U1 is pause
)
```

`places=[(x, y), ...]` puts each object's bounding-box centre at a bed
position instead of the X row, and raises if anything leaves `printable_area`
(spin parts in the SCAD, since build() only translates).
`object_settings={index: {...}}` writes per-object overrides into
model_settings.config, e.g. a brim on one tall part while the rest of the plate
stays brim-free.

Stdlib only. Reads ASCII or binary STL and welds duplicate vertices, which is
what takes ~8.7 MB of STL down to ~310 KB of 3mf.

### Traps, all hit and fixed

**Every setting in `project_settings.config` is a string.** Bambu writes
`"wall_loops": "2"`, not `2`. Passing an int is silently ignored and the stock
default is used, so `wall_loops: 3` showed up in the slicer as 2. `build()` now
coerces overrides to strings and raises on a key that isn't in the base profile,
so a typo fails loudly instead of doing nothing.

**Internal object ids must be unique across the package.** Each
`3D/Objects/object_N.model` declares its own `<object id=...>`. If two files both
declare `id="1"`, Bambu resolves the component by id and the second silently
renders as the first — both plates came out identical. Inner ids are now
`1000 + i` and distinct from the outer ids.

**Writing the value is only half the job.** Bambu does not read
`project_settings.config` as-is. It loads the named *system* preset
(`print_settings_id`) and then applies only the keys named in
`different_settings_to_system` — a 3-element list of `;`-joined buckets for
[print, filament, printer]. Any key you changed that is missing from that list
is silently reverted to the preset value. That is why `wall_loops: 3` kept
showing up in the slicer as 2 while `enable_support: 0` worked: support happened
to already be in the list. `build()` now registers every override there.

This one is nasty because the JSON in the file looks correct. You have to check
`different_settings_to_system`, not just the value.

**A clean CLI slice doesn't prove the GUI will open it.** Overriding `filament_start_gcode`
or `filament_end_gcode` makes the GUI stop on a "Modified G-code" warning, with the project
stuck on "Loading..." and the window still titled "Untitled" until you respond. The CLI never
shows it. Set only the filament values you need, and open the `.3mf` in the Bambu Studio GUI
once to confirm it loads.

**"Solid" modifiers need 100% *and* zig-zag.** With the P2S profile's `grid` sparse
pattern, 99% and even 100% density still slice as sparse infill: crossing lines ~0.81 mm
apart, which stack into open vertical holes. Bambu 2.08 doesn't promote 100% to solid. Set
`sparse_infill_density: 100%` with `sparse_infill_pattern: zig-zag` (found when the v3 spinner
pins printed hollow). Verify by slicing headless (`tools/cloud/check_slice.py --probe`):
solid reads ~0.43 mm line spacing. Bambu re-centres each object's meshes on load but moves the
modifier parts with them, so modifiers placed in the STL's own coordinates stay put.

### Why generate rather than click

The magnet pause is `pocket_top_z` from the model. It moved several times during
the spinner's design, and a hand-entered pause drifts out of step with the
pocket it exists to serve. `examples/triangular-elipsoid/build_3mf.py` scrapes it
from the model's own `PAUSE HEIGHT` echo, so geometry and pause share one source.

## profiles/

`p2s_pla_0.20mm.json` — the stock Bambu P2S / Generic PLA / 0.20mm Standard
profile, all 537 keys, lifted from a project Bambu Studio saved. Treat it as a
baseline and express project settings as overrides so the diff stays readable.

## OpenSCAD PNG renders

**Preview PNGs get colours wrong in pockets.** A `-o x.png` without `--render` is an OpenCSG
preview, and it paints the floor of a subtracted pocket in the colour of the object it was cut
from, even when a differently coloured part fills the space beneath: dark inlays in white
pockets came out white. Previews also z-fight on coincident faces, so a flush cut shows a
shredded skin across its mouth.

On a desktop, use `--render` for colour-accurate PNGs. A current build renders with Manifold,
which keeps `color()` and is fast (about 1 s for a 60-part assembly). In the cloud a PNG always
comes from the 2021.01 preview (see `cloud/README.md`), so both traps apply there: judge
geometry from `tools/render`, not from that PNG. Which OpenSCAD build runs where is in
`OPENSCAD_DOCS.md`.
