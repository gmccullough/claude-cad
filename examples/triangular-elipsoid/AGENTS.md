# Triangular Elipsoid Spinner

Three-ellipse fidget spinner with a 608 bearing instead of a pivot pin. Two non-identical plates (A and B) plus one bearing.

## 608 Bearing Integration

- Bearing specs: 22mm OD, 8mm ID, 7mm height
- **Plate A** (press-fit side): 21.9mm pocket holds bearing outer race with slight interference; flat seat from r=9.5 stops it at 3.0mm depth
- **Plate B** (pin side): 23mm clearance pocket with integrated 8.3mm axle pin
  - Pin has a 9.1mm chamfered shoulder for the inner race to rest on
  - Roof lifts 0.3mm clear of the bearing face everywhere outboard of that shoulder
- Assembly: bearing slides onto Plate B pin, Plate A press-fits over outer race
- Plates float ~1.1mm apart when assembled

## Dual-Plate A/B Assembly

Unlike the symmetric flip-assembly of hex/triangle tiles, this spinner uses two *different* plates:
- Both printed dome-up (flat/smooth side down on bed)
- Bearing pocket opens from the flat bottom side
- Pin on Plate B builds up from the bed inside the pocket cavity — no supports needed

## Three-Ellipse Shape

The 2D outline is created by unioning three ellipses at 120° intervals. Each ellipse is a `scale()`-ed circle positioned at `vertex_radius` from center with `ellipse_bulge` controlling width. A center fill circle covers any gap if bulge is small relative to vertex radius.

## Dome

`dome_style` picks the top surface (Sept 2026):

- **`"lobes"`** (default): terraced ziggurat that follows the three-lobe outline. Step k is the hull of the outline eroded by `lobe_offset(k)` (bottom) and by that plus `step_run` (top), giving a 45° ramp 4 layers (0.8mm) tall. The flat run **widens with each step up** — `lobe_flat_0 + k * lobe_flat_growth`, currently 1.0mm growing +0.5mm — so the rim is steep and the top flattens into a domed silhouette. Equal-width steps read as a cone instead. Five steps, peak z=6.2mm, triangular top plateau reaching 13mm at the vertices (8.2mm inradius at the mid-edges). The outline is convex (verified numerically), so `hull()` is exact.
- **`"rings"`**: concentric circular terraces whose ramp radii follow the old sphere envelope contours at 0.8mm intervals. Equal-ish steps, peak z=7.0mm.
- **`"smooth"`**: original sphere-intersection dome. Peak z=6.6mm.

Why terraces: the smooth sphere is such a gentle incline (~10° average) that the printer's layer stair-stepping showed as ugly artifacts. The terraces make the stepping deliberate.

**Pocket clearance:** the dome must be solid across each bearing pocket at that pocket's ceiling. The outline's inradius at the mid-edges is only 19.2mm (2 × `ellipse_bulge`), so the binding case is Plate B, whose 23mm pocket reaches r=11.5 at z=4.0. `lobe_offset_at_z()` computes the dome's inward offset at any height and the echo output prints both margins — currently 3.4mm on Plate B and 7.5mm on Plate A. Re-check those echoes after changing `lobe_flat_0`, `lobe_flat_growth`, or `dome_start_z`.

`dome_start_z` is 2.2 (was 2.1) so every flat run lands on a 0.2mm layer boundary.

`show_grooves` toggles the 6 radial V-grooves from the peak (off by default; `groove_z` tracks `dome_peak_z`).

## Magnets

`num_magnets` is the flag: **6** (current default) puts 6x2mm magnets at the three points *and* the three edge midpoints at 60° intervals; **3** drops the edge-midpoint pockets and keeps only the points. All at 15.3mm from center, pause at 2.6mm to insert.

**The edge-midpoint pockets carry the thinnest wall in the part.** The outline's inradius at the mid-edges is 19.2mm, so those pockets have only 0.8mm of outboard wall at the pocket floor. The dome ramp starts at z=2.2, below the pocket top at z=2.6, and erodes that wall to **0.4mm** over the pocket's top 0.4mm — one perimeter at a 0.4mm nozzle. Verified enclosed (not breached) by cross-section at z=2.55. The point pockets are comfortable at 5.6mm, thinning to 5.2mm.

The `MAGNET WALL` echoes print both numbers. Re-check them after changing `dome_start_z`, `magnet_distance`, or the step parameters. If the mid-edge wall ever prints too fragile, options are lowering `magnet_distance`, raising `dome_start_z` above `pocket_top_z`, or going back to `num_magnets = 3`.

## Bearing Contact Surfaces

ISO 582 / DIN 620-6 give `rs min = 0.3` for a 608, but that is a tolerance *zone*, not a dimension:

| | min | max |
|---|---|---|
| radial extent | 0.3 | 0.6 |
| axial extent | 0.3 | 1.0 |

So the chamfer angle legally runs from 45° to about 73°, and on real bearings it looks steep (~60°). **Never seat on the chamfer** — a cone rides its inner corner, whose radius floats across that band, taking seating depth with it. Land on the flat race face instead, which is what the standard's maximums exist to make possible.

Both plates do that, with no flat surface on either roof:

**Plate B — flat land on top of a cone.** The shoulder land is the top face of a 45° cone growing off the shaft, so it is a *top* surface and free to print. Clears the inner race bore chamfer (to r=4.6), gives `seat_contact_width` of flat contact out to r=5.0. Seats exactly at `pocket_depth_b`.

**Plate A — a seat RIDGE, not a ledge.** Off the bore the roof bevels *up* at 45° purely to buy airspace over the race chamfer, crests at a small hump (0.35mm), then comes back *down* to a ridge whose tip is the bearing's bottom-out point. `seat_ridge_offset` (0.7mm) puts that tip just inboard of the widest the chamfer can ever be (0.6mm), so it lands on the race's **flat face** at r=10.25. Contact is a line at a known radius, seating depth is exactly `pocket_depth_a`, and there is no flat face anywhere on the roof. From the tip a 45° flank climbs through `bearing_face_clearance` into the regular waves.

Plate gap is 0.4mm (7 − 4.0 − 2.6) and does **not** drift with the chamfer band, since both seats land on flat faces. Worst-case 1.0mm axial chamfer still leaves 1.6mm of the 2.6mm bore engaged.

**The seat ridge is a local low point, so slicer support reaches it** — that is unavoidable for a downward ridge and is by design. It is a line contact, so the scarring is minimal and the press-fit race beds into it. Every *other* Plate A ridge is lifted `bearing_face_clearance` (0.3mm) above the race face and touches nothing.

## Support / Sawtooth Pocket Roofs

Printed dome-up, every pocket roof is a flat face over an open cavity — a 0° overhang. Left flat, the slicer grows tree support up to a whole flat plane: many contact points, and snapping them off leaves a rough seat.

**Both roofs are ridged into concentric 45° rings** (Sept 2026): out from the centre, up 45°, down 45°, repeating. Every face then sits at the printable limit, so support only climbs to the *valley rings* — thin concentric tubes touching a line each. Each pocket is open to the build plate, so that support grows from the bed; "support on build plate only" is enough.

Crucially every ridge except Plate A's seat ridge is **raised clear of the bearing** by `bearing_face_clearance`. See Bearing Contact Surfaces above for how Plate A's roof leaves the bore and why its first ridge deliberately touches. Plate B's ridges lift off the pin shoulder edge via a 45° ramp and sit 0.3mm above the shoulder top. A valley left level with the bearing face would rub the shield — an earlier revision had exactly that, and so did the original flat Plate B ceiling, which was coplanar with the pin shoulder and would have pressed on the outer race.

| Roof | Span | Amplitude | Valley rings | Shell above peaks |
|---|---|---|---|---|
| Plate A | r 9.95 → 0 | 0.55mm | 9 | 1.95mm |
| Plate B | r 11.5 → 5.3 | 0.44mm | 6 | 0.66mm |

**Amplitude is capped by dome headroom, not preference.** Above the pocket rim the dome is only ~1.4mm up in the mid-edge direction (worst of the three), and raising the roof for bearing clearance spends 0.3mm of that. `sawtooth_amp_allowed()` computes the largest wave leaving `sawtooth_min_shell` (0.6mm, 3 layers) over the outermost peak, and `sawtooth_n()` takes the smaller of that and `sawtooth_amp_target`, fitting the half-cycle count with `ceil` so rounding can never push the amplitude back over the cap. Plate B gets shrunk from 0.6 to 0.48 this way. A 2mm wave is nowhere near possible; buying one would mean climbing the dome faster at the rim via a smaller `lobe_flat_0`.

**Pin shoulder.** The original square 8.3 → 10mm step projected 0.85mm in 0.4mm of rise, about 25° from horizontal, and needed support. It is now a 45° cone 0.85mm tall rising to the same 10mm land, so it is self-supporting *and* keeps the full flat seat. That land is also the anchor the Plate B ridging ramps off.

`breakaway_supports` (default **off**) models the holder tubes into the part instead of letting the slicer generate them. They occupy the bearing's space and must be broken out.

## Axle Pin Fit

Pin shaft was 8.1mm and sat loose in the 8mm bearing ID. Bumped to 8.3mm (Sept 2026). Adjust `pin_shaft_diameter` if it's now too tight to seat.

## v2 — Arched Roofs (experimental)

`triangular_elipsoid_v2.scad`. v1's concentric 45° ridges left every ridge valley as a free-floating ring that the slicer never supported — with Bambu's 30° threshold angle, a 45° flank isn't even flagged as an overhang, so no internal support is generated at all and the roof just closes.

v2 drops the ridges. Each pocket roof is **one arch** springing from the pocket wall, cresting, and landing on a centre post, so material grows from two solid anchors with no islands (bar Plate A's seat ridge, which is a functional stop).

- `roof_angle` = **40°** from horizontal. 20° and 35° both drooped on the printer. 40° steps 0.24mm inward per 0.2mm layer, well inside a 0.4mm nozzle width.
- **Depths are split unevenly on purpose.** Plate A's arch spans 9.75mm and Plate B's only 6.5mm, so for the same angle Plate A's crown rises much further. Shifting insertion toward B lowers the springing on the long span and lifts it on the short one, levelling the crowns. At 40°, 3.3/3.3 gives crowns of 7.39 and 6.18 (worst 7.39); **2.7/3.9 gives 6.79 and 6.78**. That is 0.6mm of headroom for free, with no extra part height. Gap stays 0.4mm.
- **Dome climbs faster, same peak.** `lobe_flat_0` 1.0 → 0.75 and `lobe_flat_growth` 0.4 → 0.2 put the plateau at 8.65mm inradius, covering *both* crown radii (5.38 and 8.43), while the peak stays at **7.4mm**. So 40° cost no height — only a wider flat top. Going to 7 steps instead would give a more domed profile (plateau 6.1) at a peak of 8.2mm.
- **Side benefit**: `dome_start_z` (2.6) lands exactly on `pocket_top_z`, so the dome ramp no longer crosses the magnet pockets and the edge-midpoint wall is a full 0.8mm top to bottom instead of thinning to 0.4mm.
- **Plate A sacrificial post**: a tree, not a pillar. A straight 0.6mm × 3.3mm post (5.5:1) was far too flimsy off the bed, and a 1mm shaft was still too spindly to hold the crown. Now a **5mm foot** (19.6mm² of bed contact) tapering over 0.8mm onto a **2mm shaft**, ending in a **1mm neck × 0.4mm** right under the roof. The taper narrows going *up*, so it is self-supporting at any steepness; the neck makes the post break flush at the roof instead of anywhere along the shaft. **It sits in the bearing's space — snap it off before assembly.**
- **Magnets staggered between the plates.** `stagger_magnets = true` gives each plate a *different* pocket set: Plate A takes the **lobes** (the three points, 30/150/270°), Plate B takes the **sides** (the three edge midpoints, 90/210/330°). A pocket on one plate therefore always faces solid material on the other. Each plate still has 3 magnets 120° apart, so there are still 3 snap positions per turn — they just land 60° round from the unstaggered layout. Only meaningful at `num_magnets = 3`; at 6 both sets are present anyway.

  Walls differ per plate as a result: **5.6mm** on Plate A at the lobes, **0.8mm** on Plate B at the sides, the latter being the thinnest wall in the part. `magnets_at_midpoints` sets the unstaggered phase; `magnet_phase_a` / `magnet_phase_b` derive from it and are what the plates actually use.

| | Springs from | Crown | Lands on | Shell over crown |
|---|---|---|---|---|
| Plate A | r 10.25, z 2.7 | r 5.38, z 6.79 | sacrificial post | 0.61mm |
| Plate B | r 11.5, z 4.2 | r 8.43, z 6.78 | pin shoulder | 0.62mm |

Plate A spins *with* the outer race, so the rise brushing the outer race just inboard of the seat ridge is harmless; only the shield and inner race (r < ~9.5) need real clearance, and at 40° the arch is 0.63mm clear by then.

## v3 — Lower (Oct 2026)

`triangular_elipsoid_v3.scad`. Each plate **7.4 → 6.8mm**, assembled **15.2 → 14.0mm** (nominal 0.4mm gap; see the Plate B seating caveat below).

The height was never the dome's doing. It is the 40° pocket arches: a 40° tent over a 6.5-9.75mm span has to rise 2.6-3.7mm, and the dome only exists to clear those crowns with ~0.6mm of shell. So v3 lowers the crowns:

- **Plate A's centre post is permanent** (`plate_a_post = "permanent"`, 7mm, 0.4mm bed chamfer). It lives in the bearing **bore**, which nothing else uses on this side: 0.5mm radial clearance to the 8mm bore (A spins against the inner race), and tip-to-tip with B's pin equals the plate gap because both sit flush with their mating faces. The arch lands at r=3.5 instead of r=1.5, so its span drops 9.75 → 6.75mm and the crown drops 0.84mm. `"sacrificial"` / `"none"` bring back the v2 behaviours.
- **Depths back to 3.3/3.3.** With A's span now close to B's, an even split levels the crowns (6.13 A, 6.18 B). Press-fit engagement grows 2.7 → 3.3mm.
- **Dome: 5 steps from z=2.4** (was 6 from 2.6). Per-step rise via `lobe_rise_layers = [5, 5, 4, 4, 4]`: the bottom two are 1.0mm deep, the rest 0.8, all still 45°. Peak 6.8, shells over the crowns 0.67 (A) / 0.62 (B) — the same as v2's worst. Plateau 10.6mm inradius.
- **Rim (edge) height 2.4mm, set by the magnets.** Magnet floor is 0.4mm (2 layers, was 0.6), so pocket tops and the pause are at 2.4. The rim must not go below `pocket_top_z`: Plate B's edge-midpoint pockets are only 0.8mm from the rim, and a ramp starting lower thins that wall (v2 at 2.2 took it to 0.4). The deeper first ramp is already at z=3.2 over the pockets' outer edge, so 0.8mm covers them (the `CHECK shell over edge-midpoint magnets` echo). Going lower means moving those magnets: they can't come inward (0.7mm from the bearing pocket), so it would mean un-staggering them to the points.
- **`dome_round_top`** (default on): step footprints morph smoothly from the full triangle at the bottom step to a circle at the top, as a **Minkowski blend**: `offset(r = t*m) scale(1-t) eroded_outline(d)`, with t = k/(steps-1) and m the step's mid-edge radius. Every step is one smooth convex curve, with the points rounded over at radius t·m. The first version *clipped* the outline with a circle instead, which left sharp creases where the circle crossed the sides; don't go back to that.
  - **Styling only.** A blend's support function is the blend of the two, so the mid-edge radius stays exactly m (the binding direction, so every clearance echo is unchanged), the points reach m + 4.8(1-t), and eroding by `step_run` moves the whole curve in by exactly `step_run`, so every ramp is still a true 45°. Flats come out up to 1.2mm wider toward the points.
  - **Mesh-check gotcha:** merge vertices at 5-6 decimals when checking these STLs. At 4 decimals a real sub-0.1µm facet edge collapses and looks like 3 non-manifold edges.
- **Clean meshes.** Post and pin are now *subtracted from the pocket void* (with the arch flank carried 0.3mm past their edge) instead of unioned on afterwards. v2's Plate B had 256 non-manifold edges where the arch landed edge-on on the pin shoulder; v3 plates are watertight with zero.
- `build_3mf.py` defaults to v3 (`build_3mf.py v2` for the old one): support OFF, solid-infill modifiers on both A's post and B's pin, sized from `>>> PLATE A POST` / `>>> PLATE B PIN` echoes.
  - **Solid modifier = 100% AND `sparse_infill_pattern: zig-zag`.** The v2/early-v3 modifiers were 99% density only, and the pins printed visibly hollow: the profile's grid pattern crosses two line sets spaced ~0.81mm (two line widths), leaving an open square in every cell, stacked into vertical holes. Bambu 2.08 does *not* promote 100% to solid infill either; it is still grid. Zig-zag at 100% lays parallel lines 0.43mm apart. Verified by slicing headless (`BambuStudio --slice 0 --outputdir <dir> <file>.3mf`) and measuring the G-code inside the pins.

**Plate B seating caveat (inherited from v2):** the pin's "shoulder land" at z = `pocket_depth_b` is flush with the roof, so it is not an exposed surface. The cone below it widens toward the roof, and the bearing's bore chamfer meets that cone first: the inner race stops at about z = 2.3 + chamfer radial (0.3-0.6) = **2.6-2.9 instead of 3.3**. The real plate gap is therefore ~0.8-1.1mm, not 0.4 (consistent with v1's "plates float ~1.1mm apart"), and the contact is chamfer-on-cone, with the depth scatter the contact-surface notes try to avoid. A true down-facing land means a ~0.7mm horizontal overhang off the pin.

## Version History

- `triangular_elipsoid_v1.scad` — earlier version (preserved for reference)
- `triangular_elipsoid.scad` — current version with refined pocket depths and dome clearance
- `triangular_elipsoid_v3.scad` / `.stl` / `.3mf` — v3 lower: permanent post, 3.3/3.3 depths, 5-step dome, round top
- `triangular_elipsoid_v2_6mag.stl` — v2 arched roofs, 6 magnets
- `triangular_elipsoid_6mag.stl` — v1 default: 6 magnets, 8.3mm pin, lobed stepped dome, sawtooth seat + breakaway tubes (both plates)
- `triangular_elipsoid_3mag.stl` — same as above, 3 magnets (points only)
