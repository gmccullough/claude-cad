"""Fit the contour-gauge curve (trace_gauge.py) to the photo-traced section (trace_2551.py), then
smooth it into the bar's front profile.

The gauge has no rule in shot, so the fit solves its scale and offset (rotation fixed at 0: pins
level on the bar and straight across the photo), for both readings of which way is up. The two
readings fit the trace equally (~0.3 mm) but need different pin pitches: as photographed
~1.74 mm, flipped ~2.30 mm. Measuring the gauge's pin thickness picks one. Writes gauge_fit.json and gauge_fit.png.
"""
import json
import os

import matplotlib
import numpy as np
import shapely
from scipy.optimize import least_squares
from shapely.geometry import LineString

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))


def load_trace():
    a = json.load(open(os.path.join(HERE, "section_2551.json")))
    face = np.array([p for p in a["face_mm"] if p[1] >= 9.4 and abs(p[0]) < 1])
    junc = np.array([p for p in a["junction_mm"] if p[1] <= 2.4])
    nose = np.array(a["nose_mm"])
    tr = np.concatenate([face, junc, nose])
    return tr[np.argsort(-tr[:, 1])]


def transform(P, p, flip):
    s, th, tx, tz = p
    u, v = P[:, 1], P[:, 0]
    zs = 1.0 if flip else -1.0
    X = s * (u * np.cos(th) - zs * v * np.sin(th)) + tx
    Z = s * (zs * v * np.cos(th) + u * np.sin(th)) + tz
    return np.stack([X, Z], 1)


def fit(P, tr, flip):
    """Rotation fixed at 0 (pins level on the bar and straight across the photo). Scan the
    scale; for each, solve the offset; keep the best."""
    curve = LineString(tr)
    zlo, zhi = tr[:, 1].min(), tr[:, 1].max()
    v_mid = P[np.argmax(P[:, 1]), 0]
    best = None
    for sc in np.linspace(1 / 70, 1 / 18, 120):
        def resid(t):
            Q = transform(P, [sc, 0.0, t[0], t[1]], flip)
            inside = (Q[:, 1] >= zlo - 0.5) & (Q[:, 1] <= zhi + 0.5)
            return np.where(inside, shapely.distance(curve, shapely.points(Q)), 0.6)
        for tz0 in np.linspace(-40, 60, 21):
            t0 = [-sc * P[:, 1].max(), tz0 + (sc * v_mid if not flip else -sc * v_mid)]
            r = least_squares(resid, t0, loss="soft_l1", f_scale=0.3)
            Q = transform(P, [sc, 0.0, *r.x], flip)
            inside = (Q[:, 1] >= zlo) & (Q[:, 1] <= zhi)
            if inside.sum() < 10:
                continue
            rms = float(np.sqrt(np.mean(shapely.distance(curve, shapely.points(Q[inside])) ** 2)))
            if best is None or rms < best[2]:
                best = (np.array([sc, 0.0, *r.x]), None, rms, int(inside.sum()))
    return best[0], best[2], best[3]


def main():
    g = json.load(open(os.path.join(HERE, "gauge_IMG_2584.json")))
    P = np.array(g["pins_px"])
    tr = load_trace()
    res = {}
    fig, axs = plt.subplots(1, 2, figsize=(13, 7), sharey=True)
    for ax, flip in zip(axs, (False, True)):
        x, rms, n = fit(P, tr, flip)
        Q = transform(P, x, flip)
        label = "flipped (image up = bike down)" if flip else "as photographed (image up = bike up)"
        res["flipped" if flip else "as_photographed"] = {
            "params": x.tolist(), "rms_mm": rms, "pins_in_range": n,
            "px_per_mm": 1 / x[0], "pin_pitch_mm": g["pitch_px"] * x[0], "rotation_deg": float(np.degrees(x[1])),
            "points_mm": Q.tolist()}
        ax.plot(tr[:, 0], tr[:, 1], ".", color="#999", ms=4, label="photo trace (IMG_2551)")
        ax.plot(Q[:, 0], Q[:, 1], "o-", color="#e63946", ms=4, lw=0.8, label="gauge pin tips (IMG_2584)")
        ax.set_title(f"{label}\nrms {rms:.2f} mm, rotation {np.degrees(x[1]):.1f} deg, "
                     f"pin pitch {g['pitch_px'] * x[0]:.2f} mm")
        ax.set_aspect("equal")
        ax.grid(alpha=0.3)
        ax.set_xlabel("x mm (0 = front face)")
        ax.legend(fontsize=8, loc="lower left")
    axs[0].set_ylabel("z mm (0 = old arm underside)")
    fig.tight_layout()
    fig.savefig(os.path.join(HERE, "gauge_fit.png"), dpi=90)
    json.dump(res, open(os.path.join(HERE, "gauge_fit.json"), "w"), indent=1)
    for k, v in res.items():
        print(f"{k}: rms {v['rms_mm']:.2f} mm over {v['pins_in_range']} pins, rotation {v['rotation_deg']:.1f} deg, "
              f"pitch {v['pin_pitch_mm']:.2f} mm")


if __name__ == "__main__":
    main()
