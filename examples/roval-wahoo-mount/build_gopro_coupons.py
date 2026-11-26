#!/usr/bin/env python3
"""GoPro fit coupons: the arm's GoPro station in three slot widths, printed top-down like the arm.

    python3 examples/roval-wahoo-mount/build_gopro_coupons.py -> out/gopro_fit_coupons.3mf

Left to right on the plate: slot 3.05, 3.15, 3.25 (tang 3.1 in all). Try the accessory in each:
pick the one that slides in by hand and grips with light screw pressure, then set gp_slot_w
(and gp_web if the tang is what binds) in roval_wahoo_mount.scad.
"""
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = next(d for d in HERE.parents if (d / "tools" / "bambu3mf.py").exists())   # repo root, wherever the example sits
sys.path.insert(0, str(ROOT / "tools"))
import bambu3mf  # noqa: E402

WIDTHS = (3.05, 3.15, 3.25)


def main():
    import numpy as np
    import trimesh
    T = trimesh.transformations
    (HERE / "out" / "print").mkdir(parents=True, exist_ok=True)
    stls = []
    for w in WIDTHS:
        raw = HERE / "out" / "print" / f"gopro_coupon_{w:.2f}_raw.stl"
        subprocess.run([str(ROOT / "tools" / "openscad"), "-o", str(raw), "-D", 'part="gopro_coupon"',
                        "-D", f"gp_slot_w={w}", str(HERE / "roval_wahoo_mount.scad")], check=True, capture_output=True)
        m = trimesh.load(raw)
        m.apply_transform(T.rotation_matrix(np.pi, [1, 0, 0]))          # top-down, like the arm
        m.apply_translation(-m.bounds[0])
        out = HERE / "out" / "print" / f"gopro_coupon_{w:.2f}.stl"
        m.export(out)
        raw.unlink()
        stls.append(out)
    out = HERE / "out" / "gopro_fit_coupons.3mf"
    bambu3mf.build(out, stls, profile=ROOT / "tools" / "profiles" / "p2s_pla_0.20mm.json",
                   overrides={"wall_loops": 4, "sparse_infill_density": "40%", "enable_support": 0},
                   spacing=8.0)
    print(f"wrote {out}  (left to right: slot {', '.join(str(w) for w in WIDTHS)})")


if __name__ == "__main__":
    main()
