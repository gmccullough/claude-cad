#!/usr/bin/env python3
"""Insert fit coupons for an already printed ring: the insert's flange, its ridge's lower part and the first
3 mm of its body (thin rings, no receiver), at three sizes, printed flange-down like the insert.

    python3 examples/roval-wahoo-mount/build_insert_coupons.py -> out/insert_fit_coupons.3mf

Left to right: ins_grow 0.05, 0.10, 0.15 (radial growth over the nominal; the ring's clearance is
0.15, so these leave 0.10 / 0.05 / 0.00). Push each up into the ring from below: pick the one that
goes in by hand with no wobble, then set ins_grow in roval_wahoo_mount.scad.
"""
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = next(d for d in HERE.parents if (d / "tools" / "bambu3mf.py").exists())   # repo root, wherever the example sits
sys.path.insert(0, str(ROOT / "tools"))
import bambu3mf  # noqa: E402

GROWS = (0.05, 0.10, 0.15)


def main():
    import numpy as np
    import trimesh
    T = trimesh.transformations
    (HERE / "out" / "print").mkdir(parents=True, exist_ok=True)
    stls = []
    for g in GROWS:
        raw = HERE / "out" / "print" / f"insert_coupon_{g:.2f}_raw.stl"
        subprocess.run([str(ROOT / "tools" / "openscad"), "-o", str(raw), "-D", 'part="insert_coupon"',
                        "-D", f"ins_grow={g}", str(HERE / "roval_wahoo_mount.scad")], check=True, capture_output=True)
        m = trimesh.load(raw)
        m.apply_transform(T.rotation_matrix(-np.pi / 2, [0, 0, 1]))
        m.apply_translation(-m.bounds[0])
        out = HERE / "out" / "print" / f"insert_coupon_{g:.2f}.stl"
        m.export(out)
        raw.unlink()
        stls.append(out)
    out = HERE / "out" / "insert_fit_coupons.3mf"
    bambu3mf.build(out, stls, profile=ROOT / "tools" / "profiles" / "p2s_pla_0.20mm.json",
                   overrides={"wall_loops": 4, "enable_support": 0}, spacing=8.0)
    print(f"wrote {out}  (left to right: ins_grow {', '.join(str(g) for g in GROWS)})")


if __name__ == "__main__":
    main()
