"""2D gate: traced bar section (IMG_2551, held-out IMG_2550) vs the model's bar2d(), in mm.
Frame: x = 0 on the bar's front face, +x forward, z = 0 at the old arm's underside."""
import json
import os

import matplotlib
import numpy as np
from shapely.geometry import Point, box
from shapely.ops import unary_union

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
a = json.load(open(os.path.join(HERE, "section_2551.json")))
b = json.load(open(os.path.join(HERE, "section_2550.json")))

face = np.array(a["face_mm"])
junc = np.array([p for p in a["junction_mm"] if p[1] <= 3.6])      # reliable part only (z <= 3.5)
nose = np.array(a["nose_mm"])
j0 = junc[np.argmin(np.abs(junc[:, 1]))]                           # the junction point, z ~ 0
n50 = np.array(b["nose_rel_mm"]) + [j0[0], 0.0]                   # 2550, anchored at the same junction

# the model's bar2d() (roval_wahoo_mount.scad defaults)
top, bot, top_r, nose_r, depth = 20.0, -7.0, 3.0, 12.0, 45.0
model = unary_union([Point(-top_r, top - top_r).buffer(top_r, 64),
                     Point(-nose_r, bot + nose_r).buffer(nose_r, 128),
                     box(-depth, bot, -depth + 1, top)]).convex_hull

fig, ax = plt.subplots(figsize=(9, 8))
mx, mz = model.exterior.xy
ax.plot(mx, mz, "-", color="#999", lw=1.5, label="model bar2d() now (R12 nose, top 20)")
ax.plot(face[:, 0], face[:, 1], "o", ms=3, color="#2a9d8f", label="2551 front face (traced)")
ax.plot(junc[:, 0], junc[:, 1], "o", ms=3, color="#e76f51", label="2551 face/arm junction (traced)")
ax.plot(nose[:, 0], nose[:, 1], "o", ms=3, color="#f4a261", label="2551 lower nose (traced)")
ax.plot(n50[:, 0], n50[:, 1], "x", ms=4, color="#264653", label="2550 lower nose (held-out, same junction)")
ax.axhspan(3.6, 9.4, xmin=0, xmax=1, color="#ffd166", alpha=0.25, label="not traceable (face in shadow next to the arm)")
ax.axhline(0, color="m", lw=0.8)
ax.axvline(0, color="c", lw=0.8)
ax.plot([0, 0], [14.5, 0], color="k", lw=6, alpha=0.15, solid_capstyle="butt", label="old root contact patch (z 0-14.5)")
ax.set_xlim(-24, 4)
ax.set_ylim(-10, 22)
ax.set_aspect("equal")
ax.grid(alpha=0.3)
ax.set_xlabel("x mm (0 = bar front face, + forward)")
ax.set_ylabel("z mm (0 = old arm underside)")
ax.set_title("Roval bar centre section: traced from photos vs the model")
ax.legend(loc="lower left", fontsize=8)
fig.tight_layout()
fig.savefig(os.path.join(HERE, "gate_section.png"), dpi=110)
print("junction", j0.round(2), " top of face z", face[:, 1].max().round(2))
