"""Trace the bar's centre section from IMG_2551 (side view along the bar, rule on the arm root).

Why the LEFT outline is the centre section: the camera looks roughly along the bar, so
nearer parts of the bar project farther from the vanishing point (image centre). The bar's
leftmost outline (front face, top corner, lower nose) therefore comes from its farthest
visible section: the one at the stem, which the mount clamps and where the rule stands.
The top edge rising to the right is the nearer bar, magnified, and is ignored.

Frame (same as roval_wahoo_mount.scad): x = 0 on the bar's front face, +x forward (toward the
arm), z = 0 at the old arm's underside where it meets the bar. Output: section_2551.json.
"""
import json
import os

import cv2
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
PHOTO = os.path.join(HERE, "..", "ref", "photos", "jpg", "IMG_2551.jpg")

# Scale: rule ticks nearest the bar (y 1226-1343) are 29.25 px/mm; the whole rule fits 30.8
# (it leans away a little). Local value is used, both give the range.
PX_PER_MM = 29.3
PX_PER_MM_RANGE = (28.5, 30.8)
FACE_X = 2262      # front face, measured below (median of the face rows)
ARM_UNDERSIDE_Y = 1795   # z = 0: the old arm's lower edge highlight where it meets the bar

im = cv2.imread(PHOTO)
g = cv2.GaussianBlur(cv2.cvtColor(im, cv2.COLOR_BGR2GRAY).astype(float), (0, 0), 2.0)


def face_rows(y0, y1):
    """Front face: per row, the background->bar step left of the bar (strongest negative x-gradient
    is bar edge; the bar is darker than the white door/bottles behind it at these rows)."""
    out = []
    gx = np.diff(g, axis=1)
    for y in range(y0, y1, 4):
        seg = gx[y, 2200:2330]
        x = 2200 + int(np.argmax(np.abs(seg)))
        out.append((x, y))
    return out


def nose_cols(x0, x1):
    """Lower nose: per column, the lit bar -> dark background step below the arm (strongest
    negative y-gradient between y 1790 and 2060)."""
    out = []
    gy = np.diff(g, axis=0)
    for x in range(x0, x1, 10):
        seg = gy[1790:2060, x]
        y = 1790 + int(np.argmin(seg))
        out.append((x, y))
    return out


def junction_rows(y0, y1, thresh=55):
    """Lower face, beside the arm root: per row, where the glossy black arm (~20-40) gives way
    to the matte grey bar (~70-100), scanning right from the arm."""
    out = []
    for y in range(y0, y1, 6):
        row = g[y, 2230:2450]
        idx = np.nonzero(row > thresh)[0]
        if len(idx):
            out.append((2230 + int(idx[0]), y))
    return out


face = face_rows(1255, 1500)
junction = junction_rows(1500, 1795)
nose = nose_cols(2380, 2800)
face_x = float(np.median([p[0] for p in face]))


def to_mm(p, s=PX_PER_MM):
    return (-(p[0] - face_x) / s, (ARM_UNDERSIDE_Y - p[1]) / s)


res = {
    "photo": "ref/photos/IMG_2551.HEIC",
    "px_per_mm": PX_PER_MM, "px_per_mm_range": PX_PER_MM_RANGE,
    "face_x_px": face_x, "arm_underside_y_px": ARM_UNDERSIDE_Y,
    "face_px": face, "junction_px": junction, "nose_px": nose,
    "face_mm": [to_mm(p) for p in face], "junction_mm": [to_mm(p) for p in junction],
    "nose_mm": [to_mm(p) for p in nose],
}
with open(os.path.join(HERE, "section_2551.json"), "w") as f:
    json.dump(res, f, indent=1)

# overlay for the 2D gate
ov = im.copy()
for (x, y) in face:
    cv2.circle(ov, (x, y), 5, (0, 255, 0), -1)
for (x, y) in nose:
    cv2.circle(ov, (x, y), 5, (0, 200, 255), -1)
for (x, y) in junction:
    cv2.circle(ov, (x, y), 5, (255, 80, 0), -1)
cv2.line(ov, (2000, ARM_UNDERSIDE_Y), (3000, ARM_UNDERSIDE_Y), (255, 0, 255), 2)
cv2.line(ov, (int(face_x), 1150), (int(face_x), 2100), (255, 255, 0), 1)
crop = ov[1100:2150, 1950:3024]
cv2.imwrite(os.path.join(HERE, "trace_2551_overlay.jpg"), crop)
print(f"face x = {face_x:.0f} px (spread {np.ptp([p[0] for p in face])} px over {len(face)} rows)")
for (x, z), (px, py) in zip(res["junction_mm"], junction):
    print(f"  face/arm junction: x {x:6.1f} mm, z {z:5.1f} mm   (px {px},{py})")
for (x, z), (px, py) in list(zip(res["nose_mm"], nose))[::5]:
    print(f"  nose: x {x:6.1f} mm, z {z:5.1f} mm   (px {px},{py})")
