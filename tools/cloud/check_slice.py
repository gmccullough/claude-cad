"""Slice a 3MF with the real Bambu CLI and report what Bambu actually did with it.

    python3 tools/cloud/check_slice.py plate.3mf [--plate 0] [--probe X,Y,R,Z ...] [--keep DIR]

Reports: success/return code, the effective settings Bambu wrote into the G-code
header (catches overrides silently reverted to the preset), every pause /
colour change with the height the print has reached when it fires and the layer it
comes before (Bambu runs a pause entered at top_z BEFORE printing that layer, so the
print is one layer short of top_z), filament grams and print time.
--probe X,Y,R,Z lists the features extruded within R mm of (X,Y) on the layer at
height Z, plus the spacing of parallel infill lines there (solid zig-zag ~0.43 mm
at 0.4 nozzle, sparse grid ~0.8 mm+). Use it to check a modifier volume really
went solid. Coordinates are bed coordinates (tools/render --json gives bounds).
"""
import argparse, json, math, re, statistics, subprocess, sys, tempfile
from pathlib import Path

KIT = Path(__file__).resolve().parents[2]   # the kit (resolved through symlinks)
KEYS = ["printer_model", "print_settings_id", "filament_settings_id", "layer_height", "wall_loops",
        "sparse_infill_density", "sparse_infill_pattern", "top_shell_layers", "bottom_shell_layers",
        "enable_support", "brim_type", "curr_bed_type", "seam_position"]


def slice_3mf(path, plate, out):
    cmd = [str(KIT / "tools/bambu-studio"), "--slice", str(plate), "--outputdir", str(out), str(Path(path).resolve())]
    r = subprocess.run(cmd, capture_output=True, text=True)
    res = json.loads((Path(out) / "result.json").read_text()) if (Path(out) / "result.json").exists() else {}
    return r.returncode, res


def parse(gcode):
    settings, pauses, segs = {}, [], {}
    z = feat = x = y = None
    printed = 0.0   # top of the last layer that has had plastic laid on it
    for line in open(gcode, errors="replace"):
        if line.startswith("; ") and " = " in line:
            k, v = line[2:].split(" = ", 1)
            if k in KEYS and k not in settings:
                settings[k] = v.strip()
        if line.startswith("; Z_HEIGHT:"):
            z = round(float(line.split(":")[1]), 3)
        elif line.startswith("; FEATURE:"):
            feat = line.split(":", 1)[1].strip()
        elif line.startswith("M400 U1"):
            pauses.append(("pause", printed, z))
        elif line.startswith("M600"):
            pauses.append(("colour change", printed, z))
        elif line.startswith(("G1 ", "G0 ")):
            mx, my, me = (re.search(p, line) for p in (r"X([-\d.]+)", r"Y([-\d.]+)", r"E([-\d.]+)"))
            nx = float(mx.group(1)) if mx else x
            ny = float(my.group(1)) if my else y
            if me and float(me.group(1)) > 0 and x is not None and feat:
                segs.setdefault(z, []).append((feat, x, y, nx, ny))
                if mx or my:
                    printed = z
            x, y = nx, ny
    return settings, pauses, segs


def probe(segs, cx, cy, r, z):
    zs = min(segs, key=lambda k: abs(k - z)) if segs else None
    near = [s for s in segs.get(zs, []) if math.hypot((s[1] + s[3]) / 2 - cx, (s[2] + s[4]) / 2 - cy) < r]
    feats = {}
    for f, *_ in near:
        feats[f] = feats.get(f, 0) + 1
    infill = [(a, b, c, d) for f, a, b, c, d in near if "infill" in f.lower() and math.hypot(c - a, d - b) > 0.5]
    spacing = None
    if len(infill) > 3:
        ang = statistics.median(math.atan2(d - b, c - a) % math.pi for a, b, c, d in infill)
        nx, ny = -math.sin(ang), math.cos(ang)
        offs = sorted({round((a + c) / 2 * nx + (b + d) / 2 * ny, 2) for a, b, c, d in infill})
        gaps = [j - i for i, j in zip(offs, offs[1:]) if j - i > 0.05]
        spacing = round(statistics.median(gaps), 3) if gaps else None
    return zs, feats, spacing


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("threemf")
    ap.add_argument("--plate", type=int, default=0, help="0 = all plates")
    ap.add_argument("--probe", action="append", default=[], help="X,Y,R,Z")
    ap.add_argument("--keep", help="keep G-code in this directory")
    a = ap.parse_args()
    out = Path(a.keep) if a.keep else Path(tempfile.mkdtemp(prefix="slice-"))
    out.mkdir(parents=True, exist_ok=True)
    rc, res = slice_3mf(a.threemf, a.plate, out)
    print(f"slice: exit {rc}, {res.get('error_string', 'no result.json')}")
    ok = rc == 0 and res.get("return_code") == 0
    for gc in sorted(out.glob("plate_*.gcode")):
        settings, pauses, segs = parse(gc)
        print(f"\n{gc.name}")
        for k in KEYS:
            if k in settings:
                print(f"  {k:24s} {settings[k]}")
        for kind, printed, z in pauses:
            print(f"  {kind:24s} with the print {printed} mm tall, before the layer that tops out at z={z}")
        if not pauses:
            print("  (no pauses / colour changes)")
        for p in a.probe:
            x, y, r, z = map(float, p.split(","))
            zs, feats, spacing = probe(segs, x, y, r, z)
            print(f"  probe ({x},{y}) r{r} z{zs}: {feats or 'nothing extruded'}"
                  + (f", infill line spacing {spacing} mm" if spacing else ""))
    for i, p in enumerate(res.get("sliced_plates", []), 1):
        grams = sum(f.get("main_used_g", 0) for f in p.get("filaments", []))
        t = (p.get("times") or {}).get("total")
        tt = f", {int(t // 3600)}h{int(t % 3600 // 60):02d}m print time" if isinstance(t, (int, float)) else ""
        print(f"\nplate {i}: {grams:.2f} g filament{tt}")
    if not a.keep:
        print(f"(G-code in {out})")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
