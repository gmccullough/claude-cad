"""Held-out check: trace the lower nose in IMG_2550, relative to the arm-underside junction.
The rule covers the bar's face in this photo, so only the nose is compared (see gate.py).
Output: section_2550.json."""
import json
import os

import cv2
import numpy as np
from scipy.signal import find_peaks

HERE = os.path.dirname(os.path.abspath(__file__))
im = cv2.imread(os.path.join(HERE, "..", "ref", "photos", "jpg", "IMG_2550.jpg"), cv2.IMREAD_GRAYSCALE).astype(float)

# scale from the rule ticks next to the bar: the column with the most ticks
best = None
for x in range(2880, 3000, 10):
    col = im[1300:2060, x - 3:x + 4].mean(1)
    col = col - np.convolve(col, np.ones(61) / 61, mode="same")
    pk, _ = find_peaks(-col, distance=25, prominence=8)
    if len(pk) > 8 and (best is None or len(pk) > best[0]):
        best = (len(pk), x, pk + 1300, np.median(np.diff(pk)))
n, x, ys, med = best
k = np.concatenate([[0], np.cumsum(np.round(np.diff(ys) / med))])
s, _ = np.polyfit(k, ys, 1)

g = cv2.GaussianBlur(im, (0, 0), 3.0)
gy = np.diff(g, axis=0)
J = (3335, 2085)    # where the arm's underside highlight meets the bar (read off a grid crop)
pts = []
for xx in range(J[0] + 20, 4250, 25):
    yy = 2080 + int(np.argmax(gy[2080:2500, xx]))     # dark bar -> bright background below it
    pts.append((xx, yy))
rel = [(-(px - J[0]) / s, -(py - J[1]) / s) for px, py in pts]
json.dump({"px_per_mm": s, "junction_px": J, "nose_px": pts, "nose_rel_mm": rel},
          open(os.path.join(HERE, "section_2550.json"), "w"), indent=1)
print(f"scale {s:.2f} px/mm from {n} ticks; {len(rel)} nose points")
