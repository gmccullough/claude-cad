#!/usr/bin/env python3
"""Build a ready-to-slice .3mf for the triangular ellipsoid spinner.

Runs OpenSCAD for each plate, reads the model's own echo output for the magnet
pause height, and emits a .3mf with print settings and the pause baked in.

    python3 triangular-elipsoid/build_3mf.py        # v3 (default)
    python3 triangular-elipsoid/build_3mf.py v2

The point of reading PAUSE HEIGHT from the echo rather than typing it: it is
pocket_top_z, the same number the geometry uses. It has moved several times
during design, and a hand-entered pause silently drifts out of step with the
pocket it exists to serve. v3 scrapes the pin and post sizes the same way.
"""

import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = next(d for d in HERE.parents if (d / "tools" / "bambu3mf.py").exists())   # repo root
sys.path.insert(0, str(ROOT / "tools"))
import bambu3mf  # noqa: E402

OPENSCAD = os.environ.get("OPENSCAD") or next(  # tools/openscad: Mac app if installed, else wasm
    str(d / "tools/openscad") for d in Path(__file__).resolve().parents if (d / "tools/openscad").exists())

# Solid infill for slender columns that 15% sparse would leave mostly air.
# Density alone is NOT enough. The profile's sparse pattern is grid, and grid
# lays two crossing line sets, each spaced 2 line widths apart at 100% - so
# every layer has an open square in every cell, and they stack into vertical
# holes. That printed as visibly hollow pins at 99%, and Bambu (2.08) does not
# promote 100% to solid infill either: both still slice as "Sparse infill" in
# the same grid (checked with the Bambu CLI). zig-zag - the profile's own
# internal_solid_infill_pattern - lays parallel lines one width apart, which
# at 100% is solid.
SOLID = {"sparse_infill_density": "100%",
         "sparse_infill_pattern": "zig-zag",
         "skeleton_infill_density": "100%",
         "skin_infill_density": "100%"}

# 2 perimeters left the axle pin hollow-ish and the thin dome shell over the
# arch crown under-filled. 3 puts real material in both.
BASE_OVERRIDES = {"wall_loops": 3}

# --- v2 -------------------------------------------------------------------
# Drop the printed sacrificial post and let Bambu build that column instead,
# as a support_enforcer volume. The enforcer only fires when support is enabled
# AND support_type is one of the "(manual)" variants, which build support ONLY
# inside enforcer volumes and nowhere else.
V2_USE_SUPPORT_ENFORCER = True


def v2_config(echo_a: str, echo_b: str):
    volumes = [
        # Plate B: the axle pin is a slender solid column that at 15% sparse
        # infill is mostly air. A modifier over it forces near-solid infill for
        # its whole height, bed to shoulder. 11mm across clears the 10mm
        # shoulder; everything outside the pin at that height is pocket void,
        # so nothing else is caught.
        {"object": 1, "x": 0.0, "y": 0.0, "z": 0.0, "d": 11.0, "h": 4.2,
         "subtype": "modifier_part", "name": "pin-solid", "settings": SOLID},
    ]
    if V2_USE_SUPPORT_ENFORCER:
        # Plate A: build the centre column with slicer support instead of a
        # printed post. 8mm across covers the descending inner flank of the
        # arch, which is the only part of that roof with nothing beneath it.
        volumes.insert(0, {"object": 0, "x": 0.0, "y": 0.0, "z": 0.0, "d": 8.0, "h": 8.0,
                           "subtype": "support_enforcer", "name": "centre-column"})
    overrides = dict(BASE_OVERRIDES)
    # Support is enabled but in MANUAL mode, so nothing is auto-generated -
    # it only builds inside the enforcer volume over the pocket centre. The
    # 40 deg arches and the seat ridge are left to bridge as designed.
    overrides.update({
        "enable_support": 1 if V2_USE_SUPPORT_ENFORCER else 0,
        "support_type": "tree(manual)" if V2_USE_SUPPORT_ENFORCER else "tree(auto)",
        "support_threshold_angle": 30,
    })
    return volumes, overrides


# --- v3 -------------------------------------------------------------------
# Plate A's centre post is permanent, so there is nothing for support to do:
# support stays off and both columns (A's post, B's pin) get the solid-infill
# modifier instead. Sizes come from the model's echo.
def echo_column(log: str, label: str):
    m = re.search(rf">>> {label}: d=([0-9.]+)mm h=([0-9.]+)mm", log)
    if not m:
        sys.exit(f"could not find '{label}' in the OpenSCAD echo output")
    return float(m.group(1)), float(m.group(2))


def v3_config(echo_a: str, echo_b: str):
    post_d, post_h = echo_column(echo_a, "PLATE A POST")
    pin_d, pin_h = echo_column(echo_b, "PLATE B PIN")
    volumes = [
        # 1mm over the column's diameter. Around each column, up to its top, is
        # pocket void, so the margin catches nothing else.
        {"object": 0, "x": 0.0, "y": 0.0, "z": 0.0, "d": post_d + 1.0, "h": post_h,
         "subtype": "modifier_part", "name": "post-solid", "settings": SOLID},
        {"object": 1, "x": 0.0, "y": 0.0, "z": 0.0, "d": pin_d + 1.0, "h": pin_h,
         "subtype": "modifier_part", "name": "pin-solid", "settings": SOLID},
    ]
    overrides = dict(BASE_OVERRIDES)
    overrides.update({"enable_support": 0, "support_type": "tree(auto)"})
    return volumes, overrides


VERSIONS = {
    "v2": {"scad": "triangular_elipsoid_v2.scad", "out": "triangular_elipsoid_v2.3mf",
           "defines_a": {"sacrificial_post": "false" if V2_USE_SUPPORT_ENFORCER else "true"},
           "config": v2_config},
    "v3": {"scad": "triangular_elipsoid_v3.scad", "out": "triangular_elipsoid_v3.3mf",
           "defines_a": {}, "config": v3_config},
}


def run_openscad(scad: Path, out_stl: Path, defines: dict) -> str:
    cmd = [OPENSCAD, "-o", str(out_stl)]
    for k, v in defines.items():
        cmd += ["-D", f"{k}={v}"]
    cmd.append(str(scad))
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        sys.exit(f"OpenSCAD failed:\n{proc.stderr}")
    return proc.stderr  # echoes land on stderr


def main() -> None:
    version = sys.argv[1] if len(sys.argv) > 1 else "v3"
    if version not in VERSIONS:
        sys.exit(f"unknown version {version!r}; pick one of {', '.join(VERSIONS)}")
    cfg = VERSIONS[version]
    scad = HERE / cfg["scad"]
    out_path = HERE / cfg["out"]

    tmp = Path(tempfile.mkdtemp())
    plates, logs = [], []
    for name, defines in (
        ("plate_a.stl", {"show_plate_a": "true", "show_plate_b": "false", **cfg["defines_a"]}),
        ("plate_b.stl", {"show_plate_a": "false", "show_plate_b": "true"}),
    ):
        stl = tmp / name
        logs.append(run_openscad(scad, stl, defines))
        plates.append(stl)
        print(f"  rendered {name} ({stl.stat().st_size // 1024} KB)")

    m = re.search(r"PAUSE HEIGHT:\s*([0-9.]+)mm", logs[1])
    if not m:
        sys.exit("could not find PAUSE HEIGHT in the OpenSCAD echo output")
    pause_z = float(m.group(1))
    print(f"  pause height from model: {pause_z}mm")

    volumes, overrides = cfg["config"](*logs)
    out, parts, settings = bambu3mf.build(
        out_path,
        plates,
        profile=ROOT / "tools" / "profiles" / "p2s_pla_0.20mm.json",
        overrides=overrides,
        pauses=[(pause_z, "M400 U1")],
        volumes=volumes,
    )
    print(f"\nwrote {out}  ({out.stat().st_size // 1024} KB)")
    for p in parts:
        print(f"  object {p['object_id']}: {p['name']}  {p['face_count']} faces "
              f"at {tuple(round(v, 2) for v in p['translate'])}")
    print(f"  wall_loops={settings['wall_loops']}  "
          f"support={'ON ' + settings['support_type'] if settings['enable_support'] == '1' else 'OFF'}  "
          f"pause at z={pause_z}")
    for v in volumes:
        print(f"  {v['subtype']:18} {v['d']}x{v['h']}mm on "
              f"{'plate A' if v['object'] == 0 else 'plate B'}"
              + (f"  {v['settings']}" if v.get("settings") else ""))


if __name__ == "__main__":
    main()
