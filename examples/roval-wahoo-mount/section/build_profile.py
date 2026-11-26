"""Traced section points -> a smooth closed bar section for the model: bar_profile.scad.

Run after trace_2551.py: python3.9 build_profile.py. It writes bar_profile.scad, with:
  bar_pts      closed polygon (x, z) in mm: x = 0 on the front face, z = 0 at the old arm's underside
  bar_front    [[z, x], ...] front surface as x(z), for lookup() (bolt point and normal)
  bar_top_z, bar_bot_z

Evidence per stretch (see AGENTS.md, "Bar section, traced"):
  MEASURED  front face x = 0 for z 9.4..18.4 (IMG_2551)
  MEASURED  face/arm junction z 0..2.3 and lower nose to 18 mm back (IMG_2551; 2550 within ~1 mm)
  GAUGE     z 2.6..9.4: shadowed in the photo; contour-gauge pins (IMG_2584, fit_gauge.py),
            both up/down readings, which agree here to ~0.3 mm
  SMOOTHED  everything below the face is one smoothing spline x(z) (sigma 0.12 mm, the stiffest that fits where trace and gauge agree without a curvature
            reversal; 0.08 starts chasing pins): the bar is
            smooth and continuous, so stray pins and trace noise are averaged out
  TRACED    top: the face curves back into a top rising gently to the rear (IMG_2551's top edge,
            plus the gauge pins near the corner up to z 20.5); one parametric smoothing spline
  GUESSED   the top level beyond ~17 mm back, the bottom flattening to its asymptote, the back
            (nothing behind ~22 mm is seen; the mount never reaches it)
"""
import json
import os

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
a = json.load(open(os.path.join(HERE, "section_2551.json")))

face_top = max(p[1] for p in a["face_mm"])                     # 18.4
junc = np.array(sorted([p for p in a["junction_mm"] if p[1] <= 2.4], key=lambda p: -p[1]))
nose = np.array(a["nose_mm"])

TOP_R = 2.0           # GUESSED top corner
FACE_LOW = 9.4        # lowest traced face point that's clearly on the face
BACK = 45.0           # modelled depth (only the front matters)

# --- the front-lower curve as x(z): face, blend, junction, nose ------------------------
# nose: x(z) is single-valued while it's still descending; keep z strictly decreasing
nz = nose[np.argsort(-nose[:, 1])]
keep = [0]
for i in range(1, len(nz)):
    if nz[i, 1] < nz[keep[-1], 1] - 0.05:
        keep.append(i)
nz = nz[keep]
# smooth the noisy traces with a running mean in z
def smooth(arr, w=5):
    if len(arr) < w:
        return arr
    k = np.ones(w) / w
    xs = np.convolve(arr[:, 0], k, mode="valid")
    zs = np.convolve(arr[:, 1], k, mode="valid")
    return np.stack([xs, zs], 1)

lower = np.concatenate([smooth(junc, 3), smooth(nz, 5)])
lower = lower[np.argsort(-lower[:, 1])]
# Contour gauge (IMG_2584, fit_gauge.py): its pins in the shadowed band are data where the photo
# trace has none. Both up/down readings agree there to ~0.3 mm, so both are used.
gauge_band = []
gf_path = os.path.join(HERE, "gauge_fit.json")
if os.path.exists(gf_path):
    gf = json.load(open(gf_path))
    for reading in gf.values():
        for x, z in reading["points_mm"]:
            if 2.6 < z < 9.4:
                gauge_band.append((x, z))
gauge_band = np.array(gauge_band).reshape(-1, 2)

# One smoothing spline x(z) through everything below the vertical face: the bar is smooth and
# continuous, so no single pin or trace point is followed exactly (sigma ~0.25 mm).
from scipy.interpolate import UnivariateSpline
# the traced face itself (not imposed knots): the data decide where the face starts to recede
face_pts = np.array([p for p in a["face_mm"] if p[1] >= FACE_LOW and abs(p[0]) < 1.0])
face_pts = smooth(face_pts[np.argsort(face_pts[:, 1])], 5)
data = np.concatenate([lower, gauge_band, face_pts])
data = data[np.argsort(data[:, 1])]
zd, xd = data[:, 1], data[:, 0]
zd = zd + np.arange(len(zd)) * 1e-6                      # strictly increasing for the spline
spl = UnivariateSpline(zd, xd, s=len(zd) * 0.12 ** 2, k=3)   # sigma 0.12: stiffest with no curvature reversal that fits where trace + gauge agree
z_bot_traced = zd[0]
zs = np.arange(z_bot_traced, face_top - TOP_R + 1e-6, 0.25)
xs = np.minimum(spl(zs), 0.0)          # x = 0 is the face: nothing sits in front of it
xs[zs >= FACE_LOW + 2.0] = 0.0            # the traced face is vertical from here up
front = np.stack([xs, zs], 1)          # (x, z), bottom to top


class _F:                               # x(z) for the report below
    def __call__(self, z):
        return float(np.interp(z, zs, xs))


f = _F()

# --- bottom: from the last traced nose point, flatten to its asymptote ------------------
x_last, z_last = front[0]
slope = (front[4, 1] - front[0, 1]) / (front[4, 0] - front[0, 0])      # dz/dx at the end, > 0
BOT_ASYM = z_last - 0.6                   # GUESSED: about 0.6 mm more drop (2550 had flattened)
xs_b = np.linspace(x_last, -BACK, 60)
# exponential approach to the asymptote, matching the slope at the joint
k = slope / max(z_last - BOT_ASYM, 1e-3)
zs_b = BOT_ASYM + (z_last - BOT_ASYM) * np.exp(k * (xs_b - x_last))
bottom = np.stack([xs_b, zs_b], 1)[::-1]  # from the back toward the nose

# --- top: the face curves back into a top that rises gently toward the rear -----------------
# Data: the traced face, the gauge pins near the corner (z <= 20.5, where both readings agree
# with the photo), and IMG_2551's top edge. The photo's outline can only OVERSTATE the centre
# section's top (nearer sections project higher), so gauge pins above it can't be on the bar.
from scipy.interpolate import splprep, splev
Z_JOIN = 14.0
top_edge = np.array([p for p in a.get("top_mm", []) if p[0] <= -0.3 and p[0] >= -17.0])
# the top edge is smooth: drop points that stray from a quadratic through it (a bottle edge behind
# the bar caught a few), repeating until none are off by more than 0.35 mm
keep = np.ones(len(top_edge), bool)
for _ in range(4):
    c = np.polyfit(top_edge[keep, 0], top_edge[keep, 1], 2)
    r = np.abs(top_edge[:, 1] - np.polyval(c, top_edge[:, 0]))
    new = r < max(0.35, 2.5 * np.median(r[keep]))
    if (new == keep).all():
        break
    keep = new
top_edge = top_edge[keep]
gauge_sh = []
if os.path.exists(gf_path):
    for reading in gf.values():
        for x, z in reading["points_mm"]:
            if 17.0 < z <= 20.5 and x <= 0.2:
                gauge_sh.append((min(x, 0.0), z))
gauge_sh = np.array(gauge_sh).reshape(-1, 2)
face_hi = face_pts[face_pts[:, 1] >= Z_JOIN]
face_hi[:, 0] = np.minimum(face_hi[:, 0], 0.0)
seed = np.array([[0.0, Z_JOIN - 1.0], [0.0, Z_JOIN]])          # tangent: still vertical at the join
up_pts = np.concatenate([seed, face_hi, gauge_sh, top_edge])
# order along the outline: up the face, then back along the top (sort by a monotone arc proxy)
key = up_pts[:, 1] - up_pts[:, 0] * 3.0
up_pts = up_pts[np.argsort(key)]
tck, _ = splprep([up_pts[:, 0], up_pts[:, 1]], s=len(up_pts) * 0.2 ** 2, k=3)
uu = np.linspace(0, 1, 120)
ux, uz = splev(uu, tck)
upper = np.stack([np.minimum(ux, 0.0), uz], 1)
upper = upper[upper[:, 1] >= Z_JOIN - 1e-6]
z_top_end = float(upper[-1, 1])
top = np.array([[-BACK, z_top_end]])
front = front[front[:, 1] < upper[0, 1] - 0.05]
face_top = float(upper[:, 1].max())

# closed polygon, counter-clockwise in (x, z): back-bottom -> nose -> face -> shoulder -> top -> back
poly = np.concatenate([[[-BACK, BOT_ASYM]], bottom, front[1:], upper, top])
# drop near-duplicates
d = np.r_[True, np.linalg.norm(np.diff(poly, axis=0), axis=1) > 0.05]
poly = poly[d]

# x(z) on the front, bottom to top: the lower spline, then the shoulder while it's single-valued
mono = [upper[0]]
for q in upper[1:]:
    if q[1] > mono[-1][1] + 0.02:
        mono.append(q)
table = [[float(z), float(x)] for x, z in np.concatenate([front, np.array(mono)])]
with open(os.path.join(HERE, "bar_profile.scad"), "w") as fh:
    fh.write("// GENERATED by section/build_profile.py from the traced photos. Do not edit.\n")
    fh.write("// x = 0 on the bar's front face, +x forward; z = 0 at the old arm's underside.\n")
    fh.write(f"bar_top_z = {face_top:.2f};\n")
    fh.write(f"bar_bot_z = {BOT_ASYM:.2f};\n")
    fh.write(f"bar_front_zmin = {front[0, 1]:.2f};\n")
    fh.write("bar_pts = [" + ", ".join(f"[{x:.3f}, {z:.3f}]" for x, z in poly) + "];\n")
    fh.write("bar_front = [" + ", ".join(f"[{z:.3f}, {x:.3f}]" for z, x in table) + "];\n")
print(f"profile: {len(poly)} points, top {face_top:.2f}, bottom asymptote {BOT_ASYM:.2f}, "
      f"front traced down to z {front[0, 1]:.2f} at x {front[0, 0]:.2f}")
for zq in (9, 6, 4, 2, 0, -2, -4, -6):
    print(f"  front x at z {zq:+d}: {float(f(zq)):.2f}")
