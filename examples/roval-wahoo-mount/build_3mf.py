#!/usr/bin/env python3
"""Ready-to-slice Bambu P2S .3mf for the Roval Wahoo mount: two parts, no support.

    python3 examples/roval-wahoo-mount/build_3mf.py   -> out/roval_wahoo_mount.3mf
    python3 examples/roval-wahoo-mount/build_3mf.py flat   -> out/roval_wahoo_mount_flat.3mf
        (a variant: underside="flat"; its STLs get the same _flat suffix, incl. out/mount_flat.stl)

- ARM, printed TOP-DOWN: its flat top (the show face) is the first layer, on the bed. Everything
  else faces up or sideways (GoPro slots, bolt pocket, ring bore, the flange counterbore); only
  the tops of small holes and the nut recess bridge.
- WAHOO INSERT, printed SEAT-UP: the receiver as Wahoo builds it. The flange's flat bottom (the
  assembly's underside) is on the bed; the seat is ironed. The receiver floor and fingers bridge
  over the finger relief, as in every earlier print.
Both are turned so their bar-side ends face the back of the bed, where seams go.

Assembly: push the insert UP through the ring from below, its ridge toward the bar (it only goes in one way); a little
epoxy in the bore locates it. The computer's quarter-turn pulls the flange into the ring.

Filament stays the profile's Generic PLA so the GUI opens clean. For a part that lives on the
bike, pick PETG or ASA in the slicer.
"""
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = next(d for d in HERE.parents if (d / "tools" / "bambu3mf.py").exists())   # repo root, wherever the example sits
sys.path.insert(0, str(ROOT / "tools"))
import bambu3mf  # noqa: E402

OVERRIDES = {
    "wall_loops": 4,
    "sparse_infill_density": "40%",
    "enable_support": 0,            # neither part needs it in its print orientation
    "ironing_type": "top",          # the insert's seat (and the arm's hidden underside)
    "ironing_flow": "10%",
    "ironing_spacing": 0.15,
    "top_surface_speed": 120,
    "top_shell_layers": 6,
    "seam_position": "back",
}


def main():
    variant = sys.argv[1] if len(sys.argv) > 1 else ""
    sfx = f"_{variant}" if variant else ""
    defs = ["-D", f'underside="{variant}"'] if variant else []
    import numpy as np
    import trimesh
    T = trimesh.transformations
    scad = HERE / "roval_wahoo_mount.scad"
    (HERE / "out" / "print").mkdir(parents=True, exist_ok=True)
    prints = []
    if variant:   # the assembled model too, for the viewer
        subprocess.run([str(ROOT / "tools" / "openscad"), "-o", str(HERE / "out" / f"mount{sfx}.stl"),
                        "-D", 'part="mount"', *defs, str(scad)], check=True, capture_output=True)
    for part, flip in (("arm", True), ("insert", False)):
        stl = HERE / "out" / f"{part}{sfx}.stl"
        subprocess.run([str(ROOT / "tools" / "openscad"), "-o", str(stl), "-D", f'part="{part}"', *defs, str(scad)],
                       check=True, capture_output=True)
        m = trimesh.load(stl)
        if flip:                                    # top-down: the flat top onto the bed
            m.apply_transform(T.rotation_matrix(np.pi, [1, 0, 0]))
        m.apply_transform(T.rotation_matrix(-np.pi / 2, [0, 0, 1]))   # bar side -> back (+Y)
        m.apply_translation(-m.bounds[0])
        out_stl = HERE / "out" / "print" / f"{part}{sfx}_print.stl"
        m.export(out_stl)
        prints.append(out_stl)
    out = HERE / "out" / f"roval_wahoo_mount{sfx}.3mf"
    bambu3mf.build(out, prints, profile=ROOT / "tools" / "profiles" / "p2s_pla_0.20mm.json",
                   overrides=OVERRIDES, spacing=10.0)
    print(f"wrote {out}")
    if variant:
        return
    # the insert on its own, for reprinting it into an arm you already have
    out1 = HERE / "out" / "insert_only.3mf"
    bambu3mf.build(out1, [prints[1]], profile=ROOT / "tools" / "profiles" / "p2s_pla_0.20mm.json",
                   overrides=OVERRIDES, spacing=10.0)
    print(f"wrote {out1}")


if __name__ == "__main__":
    main()
