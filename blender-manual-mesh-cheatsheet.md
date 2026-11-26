# Blender Manual Mesh Manipulation — Cheat Sheet

Scope: hand-deforming an imported STL. No remesh, no auto-repair.
Units: 1 Blender unit = 1 mm on this part. Type real numbers.

---

## 0. One-time setup (do this once, saves pain forever)

| Action | Where |
|---|---|
| Orbit around what you're looking at | Preferences → Navigation → **Orbit Around Selection** ✓ |
| Fix the object's pivot | Object Mode → Object → Set Origin → **Origin to Geometry** |
| Frame the selected object | **Numpad-period** (or View → Frame Selected) |
| Import an STL | File → Import → STL |

---

## 1. Know which mode you're in

Everything below depends on this. Top-left dropdown.

- **Object Mode** — move/rotate/scale the whole object. Modifiers live here.
- **Edit Mode** (`Tab`) — vertex-level. Precise, numeric, box-select.
- **Sculpt Mode** — brush-based. Tactile, organic, no selection needed.

`Tab` toggles Object ↔ Edit. Use the dropdown to reach Sculpt.

---

## 2. Grab a region and stretch it — *Edit Mode*

The core move. Proportional editing is what makes neighbors flex along.

1. `Tab` → Edit Mode
2. `Alt+Z` → **X-ray on** (without this you only grab front-facing verts and the deform tears)
3. `B` → box-select the band of vertices you want
4. `O` → **Proportional Editing on** (circle icon lights up in header)
5. `G` → then `X` / `Y` / `Z` — *watch which way it slides before committing; you can swap axes mid-grab*
6. **Scroll wheel** → sizes the falloff circle. This is your "how much of the rest flexes" dial.
7. Type the distance (e.g. `2`) → `Enter`

Falloff shape (Smooth / Sphere / Root) is the dropdown next to the proportional icon.

**Note on STL topology:** there are no clean edge loops. `Alt+click` loop-select won't work. Box-select by hand.

---

## 3. Build volume up — *Sculpt Mode*

Order matters. **Build first, smooth last.**

| Brush | Does | Notes |
|---|---|---|
| **Clay Strips** | Deposits material in slabs | Best for rebuilding a collapsed/chopped area |
| **Draw** | Pushes surface out along normal | `Ctrl+click` inverts → carves in |
| **Inflate** | Puffs a whole region outward | Good for a dented patch swelling back |
| **Smooth** | Averages what's there | **Cannot add material** — finisher only |

- `F` → brush size
- `Shift+F` → brush strength
- **`Shift`+drag** → temporarily switches *any* brush to Smooth
- `Ctrl`+drag → inverts the current brush

**Sequence:** Clay Strips to overshoot → `Ctrl+Draw` to knock down highs → light Shift-drag Smooth to blend the seam.

**If brushes feel like they do nothing:** that patch is low-poly. Brushes can only move vertices that exist. Turn on **Dyntopo** (header button) so geometry is added as you paint.

---

## 4. Smooth a region — two ways

**Tactile:** Sculpt Mode → hold `Shift` → drag over the messy area.

**Precise/repeatable:** Edit Mode → `Alt+Z` → `B` select the verts → Vertex menu → **Smooth Vertices** → `F9` → set **Smoothing** factor and **Repeat** (5–10).

⚠️ **Shade Smooth is not this.** It only changes lighting. Geometry stays as lumpy as it was and exports identically bad.

---

## 5. Diagnostics

| Check | How | Reading it |
|---|---|---|
| Bad/open faces | Overlays dropdown → **Face Orientation** | Blue = good. **Red = backface or open boundary** |
| Open edges | Edit Mode → Select → All by Trait → **Non Manifold** | Highlights every open rim |
| Real hole vs. overlap | Orbit the view | Shimmers/crawls = overlapping faces. Sits still = real hole |

**Red is not a bump.** No brush fixes it. Flipped face → `Shift+N` (recalc) or `Alt+N → Flip`. Open gap → select boundary → `F` to bridge.

---

## 6. Manual cleanup (Edit Mode, select all with `A`)

- `M` → **By Distance** — merge doubled verts
- `Shift+N` — recalculate normals outward
- Mesh → Clean Up → **Delete Loose** — remove floating debris
- Select boundary → `F` — bridge a gap into a face
- Face → **Grid Fill** — cleaner cap on a roughly-round hole

---

## 7. Export

File → Export → STL. Numbers go out exactly as they read in Blender, so 104 → 104 mm in your slicer.

---

## Gotchas worth remembering

- The `m` suffix in the Dimensions panel is cosmetic. Don't "fix" it by scaling — you'd corrupt the export.
- Save incrementally (`v3`, `v4`…). `Ctrl+Z` has limits; a good file on disk doesn't.
- Never `Ctrl+S` over a good file when the mesh looks wrong on screen.
- Smooth pulls edges inward. If something looks "chopped off," you smoothed instead of built.
