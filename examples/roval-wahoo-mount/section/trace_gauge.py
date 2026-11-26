"""Trace the contour-gauge photos (IMG_2583-2585): pin tips -> one profile sample per pin.

The gauge is a stack of printed pins in a clamp frame, pressed onto the bar's front with the
pins horizontal (fore-aft) and stacked vertically. Each pin's tip sits where the bar pushed it,
so the tips' positions along the pins ARE the bar's front profile, x(z), in pin units: z = pin
index x pitch. Pins are segmented by hue (blue, pink and yellow filament vs the wood table and
its shadow). Then the outline's extreme point in each window one pin-pitch tall is that pin's tip.

Usage: python3.9 trace_gauge.py  -> gauge_<photo>.json (pixel samples) + overlay JPEGs
"""
import json
import os

import cv2
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
JPG = os.path.join(HERE, "..", "ref", "photos", "jpg")

# per photo: region of the pin tips, which side the tips face, and the frame to exclude
PHOTOS = {
    # contact end, close up: tips face LEFT; frame at the right edge
    "IMG_2584": dict(box=(1650, 1860, 2750, 3450), tips="left"),
    # the other end, close up: tips face RIGHT
    "IMG_2585": dict(box=None, tips="right"),
}


def pin_mask(im):
    hsv = cv2.cvtColor(im, cv2.COLOR_BGR2HSV).astype(int)
    H, S, V = hsv[..., 0], hsv[..., 1], hsv[..., 2]
    blue = (H >= 95) & (H <= 135) & (S > 50)
    pink = ((H >= 140) | (H <= 4)) & (S > 50) & (V > 80)
    yellow = (H >= 23) & (H <= 40) & (S > 90) & (V > 120)
    m = (blue | pink | yellow).astype(np.uint8)
    return cv2.morphologyEx(m, cv2.MORPH_OPEN, np.ones((3, 3), np.uint8)).astype(bool)


def outline(mask, box, tips, min_run=25):
    x0, y0, x1, y1 = box
    ys, xs = [], []
    for y in range(y0, y1):
        r = mask[y, x0:x1]
        idx = np.nonzero(r)[0]
        if len(idx) < min_run:
            continue
        runs = [rr for rr in np.split(idx, np.nonzero(np.diff(idx) > 3)[0] + 1) if len(rr) >= min_run]
        if not runs:
            continue
        ys.append(y)
        xs.append(x0 + (runs[0][0] if tips == "left" else runs[-1][-1]))
    return np.array(ys), np.array(xs, float)


def pitch_from_outline(ys, xs):
    """Pin pitch in px: the staircase repeats every pin; autocorrelate the outline's steps."""
    d = np.abs(np.diff(xs))
    d = d - d.mean()
    ac = np.correlate(d, d, "full")[len(d) - 1:]
    lo = 25
    return lo + int(np.argmax(ac[lo:120]))


def tips_per_pin(ys, xs, pitch, tips):
    """One sample per pin: the most extended outline point in each pitch-tall window."""
    out = []
    y = ys.min()
    while y + pitch <= ys.max() + 1:
        sel = (ys >= y) & (ys < y + pitch)
        if sel.sum() > pitch * 0.5:
            k = np.argmin(xs[sel]) if tips == "left" else np.argmax(xs[sel])
            out.append((float(ys[sel][k]), float(xs[sel][k])))
        y += pitch
    return np.array(out)


def main():
    for name, cfg in PHOTOS.items():
        im = cv2.imread(os.path.join(JPG, name + ".jpg"))
        mask = pin_mask(im)
        box = cfg["box"]
        if box is None:
            continue
        ys, xs = outline(mask, box, cfg["tips"])
        pitch = pitch_from_outline(ys, xs)
        pins = tips_per_pin(ys, xs, pitch, cfg["tips"])
        json.dump({"photo": name, "tips": cfg["tips"], "pitch_px": pitch,
                   "outline": [[int(a), float(b)] for a, b in zip(ys, xs)],
                   "pins_px": pins.tolist()},
                  open(os.path.join(HERE, f"gauge_{name}.json"), "w"), indent=1)
        vis = im.copy()
        for y, x in zip(ys, xs):
            cv2.circle(vis, (int(x), int(y)), 2, (0, 255, 0), -1)
        for y, x in pins:
            cv2.circle(vis, (int(x), int(y)), 12, (0, 0, 255), 3)
        x0, y0, x1, y1 = box
        crop = vis[y0 - 40:y1 + 40, x0 - 40:x1 + 40]
        cv2.imwrite(os.path.join(HERE, f"gauge_{name}_overlay.jpg"),
                    cv2.resize(crop, (crop.shape[1] * 1000 // crop.shape[0], 1000)))
        print(f"{name}: pitch {pitch} px, {len(pins)} pins")


if __name__ == "__main__":
    main()
