// Three-Ellipse Fidget Spinner with 608 Bearing
//
// v3 (Oct 2026): LOWER. Each plate 7.4 -> 6.8mm, assembled 15.2 -> 14.0mm.
// The height was never the dome's doing - it is the 40° pocket arches, and the
// dome only has to clear their crowns. So v3 lowers the crowns:
//   - Plate A's centre post is PERMANENT (7mm, lives in the bearing bore with
//     0.5mm radial clearance). The arch lands at r=3.5 instead of r=1.5, so its
//     span drops 9.75 -> 6.75mm and the crown drops 0.84mm.
//   - Pocket depths rebalanced 2.7/3.9 -> 3.3/3.3 so both crowns sit at ~6.15.
//   - Dome: 5 steps from z=2.4 (was 6 from 2.6), the bottom two 1.0mm deep and
//     the rest 0.8. Peak 6.8, same ~0.62mm shell over the worst crown that v2
//     had. The rim (edge) is 2.4mm, down from 2.6.
//   - Magnet floor 0.6 -> 0.4mm (2 layers), so pocket top and pause are 2.4.
//   - dome_round_top: optional smooth morph (Minkowski blend, no clipping) from
//     the triangular outline at the base to a circle at the top. Styling only -
//     it does not change the peak, because the binding direction is the
//     mid-edge and the blend holds the mid-edge radius exactly.
//
// PRINTING:
//   - Print BOTH plates flat/smooth side DOWN on smooth plate, dome faces UP
//   - PAUSE at pocket_top_z (2.4mm) to insert 6x2mm magnets and glue, then resume
//   - Bearing pocket and axle pin print correctly in this orientation — pin builds
//     up from the bed inside the pocket cavity, no supports needed
//   - Dome bridges over the bearing pocket at z=3.2mm (~22mm span)
//
// ASSEMBLY:
//   - Two different plates (A and B) plus one 608 bearing (22mm OD, 8mm ID, 7mm)
//   - Plate A: 22mm press-fit pocket holds bearing outer race
//   - Plate B: 23mm clearance pocket with integrated axle pin (7.9mm shaft)
//   - Bearing slides onto Plate B's pin from the flat side, inner race rests on
//     the 10mm shoulder at the back of the pocket
//   - Plate A press-fits onto the bearing's outer race
//   - Plate A spins freely on the bearing; Plate B is the stationary handle
//   - Plates float ~1.1mm apart (bearing height + shoulder - 2x pocket depth)
//
// MAGNETS:
//   - num_magnets = 3: magnets at the three points only, 120° apart
//     (the three edge-midpoint pockets are filled in solid)
//   - num_magnets = 6 (default): points + edge midpoints at 60° intervals
//   - Provide rotational snap/detent positions between the two plates
//
// SUPPORT (sawtooth_ceiling_a / sawtooth_ceiling_b):
//   Both pocket seats are flat roofs over an open cavity — a 0° overhang. Left
//   flat, the slicer has to grow tree support up to a whole flat face, which
//   means many contact points and a rough, hard-to-snap surface.
//
//   Instead both seats are sawtoothed into concentric 45° rings: up 45°, down
//   45°, repeating outward from the centre. Every face is then at the printable
//   limit and the ONLY thing support must reach is the valley rings. Support
//   becomes a few thin concentric tubes touching a line each, so it snaps off
//   clean and never touches the 21.9mm press-fit wall.
//
//   Amplitude is capped by dome headroom, not taste: above the pocket rim the
//   dome surface is only ~1.4mm up (mid-edge, the worst direction), so a 2mm
//   wave would punch through. sawtooth_amp_target sets the wave size and the
//   half-cycle count is fitted per plate; the echoes report the resulting shell.
//
//   Let the slicer make the support. breakaway_supports models the tubes into
//   the part instead, which is only useful if you want them deterministic.
//
// DOME (dome_style):
//   - "lobes" (default): terraced dome whose steps follow the three-lobe
//     outline, offset inward per step (ziggurat look). Each step is a 45°
//     ramp step_layers tall (4 layers = 0.8mm) followed by a flat run that
//     GROWS with each step up (lobe_flat_0 + k * lobe_flat_growth), so the
//     rim is steep and the top flattens out — a domed silhouette rather than
//     the constant-slope cone that equal steps produce.
//   - "rings": terraced dome with concentric circular steps whose radii follow
//     the contours of the original sphere envelope.
//   - "smooth": original smooth sphere-intersection dome.
//   The gentle sphere printed with ugly layer stair-stepping; the terraces make
//   that stepping deliberate. dome_start_z sits on a layer boundary so every
//   flat run lands on a whole layer.
//   - show_grooves: 6 radial V-grooves from the peak (off by default)

// === PREVIEW ===
cross_section = false;   // Set to false for full model
cross_section_z = 1.4;  // Midpoint of magnet pockets (pocket_floor_z=0.4 to pocket_top_z=2.4)
show_plate_a = true;     // Set to false to hide Plate A (press-fit side)
show_plate_b = true;     // Set to false to hide Plate B (pin side)

// === PARAMETERS ===
// Shape dimensions - three ellipses spanning triangle edges
vertex_radius = 24;      // Distance from center to the three points (virtual triangle vertices)
ellipse_bulge = 9.6;      // How much each ellipse bulges outward from edge (try 15-30)
                         // If bulge < vertex_radius/2 (20mm), center will have gap
center_fill = 12;        // Radius of center fill circle (needed if bulge is small)
total_height = 3.5;      // Total height of tile

// Dome parameters - dome sits on top, curves over magnet pockets
// Raised 2.2 -> 2.6 to make room for the 35° arches. It lands exactly on
// pocket_top_z, so the dome ramp no longer crosses the magnet pockets at all
// and the edge-midpoint wall goes back to its full 0.8mm.
// v3: back onto pocket_top_z, which itself dropped to 2.4 with the thinner
// magnet floor. This is the rim (edge) height. It cannot go below pocket_top_z
// without the first ramp thinning the 0.8mm wall beside Plate B's edge-midpoint
// magnets; the two deeper bottom steps make up the height so the peak holds.
dome_start_z = 2.4;      // Dome begins here (12 layers — flats stay on layer boundaries)
dome_height = 4.4;       // Height of the sphere envelope ("smooth" and "rings" styles)

// Stepped (terraced) dome
dome_style = "lobes";    // "lobes" | "rings" | "smooth"
layer_height = 0.2;      // Print layer height
step_layers = 4;         // Layers per 45° ramp
step_angle = 45;         // Ramp angle from horizontal
step_rise = step_layers * layer_height;          // 0.8mm per step
step_run = step_rise / tan(step_angle);          // 0.8mm horizontal per ramp

// "lobes" style: flat run widens with each step up, so the dome is steep at
// the rim and flattens toward the peak.
// v3: per-step rise, in layers, bottom step first. Each ramp stays 45°, so a
// taller step also runs further in. The bottom two are 5 layers (1.0mm) so the
// rim can sit at 2.4 while the peak still reaches 6.8: 1.0+1.0+0.8+0.8+0.8.
// Over Plate B's edge-midpoint magnets (outer edge 0.8mm in from the rim) the
// first ramp is already at z=3.2, leaving 0.8mm over the pocket top.
lobe_rise_layers = [5, 5, 4, 4, 4];
lobe_steps = len(lobe_rise_layers);   // 5 steps, 4.4mm, peak z=6.8 (v2: 6, 7.4)
function lobe_rise(k) = lobe_rise_layers[k] * layer_height;
function lobe_run(k) = lobe_rise(k) / tan(step_angle);
// Height of step k's bottom above dome_start_z
function lobe_z0(k) = k <= 0 ? 0 : lobe_z0(k - 1) + lobe_rise(k - 1);
lobe_flat_0 = 0.75;      // Flat run on the first (outermost) step. Trimmed from
                         // 1.0 so the dome climbs fast enough to be at full
                         // height by the Plate B crown radius (8.43).
lobe_flat_growth = 0.2;  // Extra flat added per step going up. With flat_0 this
                         // puts the plateau at 8.65mm inradius, covering BOTH
                         // crown radii, while the peak stays at 7.4mm — the 40°
                         // arches cost no extra part height.

// Round top: each step's footprint morphs smoothly from the eroded outline
// (bottom step) to a circle (top step) - a Minkowski blend, see lobe_footprint.
// The mid-edge profile - the one every clearance check uses - is identical
// either way.
dome_round_top = true;

// Flat run and cumulative inward offset at step k
function lobe_flat_at(k) = lobe_flat_0 + k * lobe_flat_growth;
function lobe_offset(k) = k <= 0 ? 0
                          : lobe_offset(k - 1) + lobe_run(k - 1) + lobe_flat_at(k - 1);

// Height of the lobed dome surface at a given inward offset, i.e. at mid-edge
// radius (2*ellipse_bulge - offset). Mid-edge is the worst case: for a given z
// the outline is closer to the axis there than in any other direction.
function dome_z_at_offset(d) =
    d >= lobe_offset(lobe_steps - 1) + lobe_run(lobe_steps - 1) ? dome_peak_z :
    max([ for (k = [0 : lobe_steps - 1])
            (d >= lobe_offset(k) && d <= lobe_offset(k) + lobe_run(k))
              ? dome_start_z + lobe_z0(k) + (d - lobe_offset(k))
          : (d > lobe_offset(k) + lobe_run(k) && d < lobe_offset(k + 1))
              ? dome_start_z + lobe_z0(k + 1)
          : 0 ]);

// Inward offset of the dome surface at absolute height z (for clearance checks)
function lobe_offset_at_z(z) =
    let (h = z - dome_start_z,
         ks = [ for (k = [0 : lobe_steps - 1]) if (lobe_z0(k) <= h) k ],
         k = len(ks) > 0 ? max(ks) : -1)
    k < 0 ? 0 : lobe_offset(k) + min(h - lobe_z0(k), lobe_run(k));

// "rings" style: steps follow the sphere envelope contours
ring_steps = ceil(dome_height / step_rise);      // 6 steps for 4.4mm envelope

dome_peak_z = dome_style == "lobes"  ? dome_start_z + lobe_z0(lobe_steps) :
              dome_style == "rings"  ? dome_start_z + ring_steps * step_rise :
                                       dome_start_z + dome_height;

// Dome grooves flag - 6 radial V-grooves from the peak
show_grooves = false;

// Magnet specifications (6x2mm magnets)
magnet_diameter = 6;     // 6mm diameter magnets
magnet_height = 2;       // 2mm thick magnets
magnet_clearance = 0.2;  // Extra clearance for easy insertion

// Magnet pocket position (close to mating surface for strong attraction)
// v3: 0.6 -> 0.4 (3 layers -> 2). Lowers the pocket top, and with it the rim,
// by 0.2mm; the magnets also sit closer to the mating face, so a firmer snap.
pocket_floor_z = 0.4;    // Solid floor thickness before pockets (2 layers at 0.2mm)
pocket_top_z = pocket_floor_z + magnet_height;  // 2.4mm - PAUSE HEIGHT

// Magnet pocket dimensions
pocket_diameter = magnet_diameter + magnet_clearance;
pocket_depth = magnet_height;

// Magnet placement - distance from center
// Magnets go at the three points (vertex directions: -90°, 30°, 150°)
// and at the three edge midpoints (90°, 210°, 330°)
// Wall thickness at points = vertex_radius - magnet_distance - pocket_radius
// Must be less than (vertex_radius - pocket_diameter/2) to stay inside shape at vertices
magnet_distance = 15.3;  // Places magnets with ~3.9mm wall at vertices (30 - 23 - 3.1)

// Number of magnets per plate — the 3-vs-6 flag.
//   3 = pockets at the three points only (edge-midpoint pockets filled in)
//   6 = points AND edge midpoints (original layout)
// Point pockets have ~5.6mm of wall outboard; edge-midpoint pockets only ~0.8mm,
// and the dome ramp thins that further over the top of the pocket — see the
// MAGNET WALL echoes at the bottom of this file.
num_magnets = 3;

// Which 3 to keep when num_magnets = 3.
//   false -> the three POINTS (vertex directions, 30/150/270°), thick wall
//   true  -> the three EDGE MIDPOINTS (90/210/330°), where the outline is
//            narrowest. Thin wall - check the MAGNET WALL echo.
// Ignored at num_magnets = 6, which covers both sets.
magnets_at_midpoints = true;
magnet_phase = magnets_at_midpoints ? 90 : 30;

// Stagger: give the two plates DIFFERENT pocket sets. Plate A takes the LOBES
// (the three points), Plate B takes the SIDES (the three edge midpoints), so a
// pocket on one plate always faces solid material on the other.
// Each plate still has 3 magnets 120° apart, so there are still 3 snap
// positions per turn - they just land 60° round from where they used to.
// Only meaningful at num_magnets = 3; at 6 both sets are present anyway.
stagger_magnets = true;
magnet_phase_a = stagger_magnets ? 30 : magnet_phase;   // Plate A -> lobes/points
magnet_phase_b = stagger_magnets ? 90 : magnet_phase;   // Plate B -> sides/midpoints

// Bearing (608 style: 22mm OD, 8mm ID, 7mm height)
bearing_od = 22;
bearing_id = 8;
bearing_height = 7;

// Bearing pockets (open from flat/smooth bottom side)
bearing_press_diameter = 21.9;      // Plate A: slight interference fit with 22mm OD
bearing_clearance_diameter = 23;    // Plate B: 1mm oversize for clearance
// Depths split the 6.6mm of bearing insertion (gap stays 7 - 6.6 = 0.4mm), but
// NOT evenly. Plate A's arch spans 9.75mm and Plate B's only 6.5mm, so Plate A's
// crown rises much further for the same angle. Shifting depth toward B lowers
// the springing on the long span and lifts it on the short one, levelling the
// two crowns. At 40°: 3.3/3.3 gives crowns of 7.39 and 6.18 (worst 7.39);
// 2.7/3.9 gives 6.79 and 6.78 (worst 6.79). That is 0.6mm of headroom for free,
// with no extra part height.
// v3: the permanent post shortens Plate A's span to 6.75mm, close to B's 6.5,
// so the split comes back to even. 3.3/3.3 gives crowns of 6.13 (A) and 6.18
// (B). Bonus: Plate A's press-fit now grips 3.3mm of the outer race, not 2.7.
pocket_depth_a = 3.3;               // Plate A (press-fit side) depth
pocket_depth_b = 3.3;               // Plate B (pin side) depth
// --- Bearing contact geometry ---------------------------------------------
// ONLY two surfaces may touch the bearing, and they set its axial position:
//   Plate A: the flat annular seat, outer_race_face_id/2 -> bore, on the OUTER
//            race (Plate A spins WITH the outer race).
//   Plate B: the pin shoulder top, on the INNER race (Plate B holds the inner).
// Everything else - and every sawtooth ridge - must stand off the bearing face
// by bearing_face_clearance. A ridge valley left level with the face would rub
// the shield, or worse, bridge inner race to outer race and lock the spin.
outer_race_face_id = 19;        // Flat land on the 608 outer race face (~18.5-19.5).
                                // MEASURE yours: too small and the seat fouls the
                                // shield, too large and it misses the race.
bearing_face_clearance = 0.3;   // Standoff from the bearing face to any ridged roof
// ISO 582 / DIN 620-6 chamfer limits for rs min = 0.3, which is what a 608
// carries. The chamfer is a tolerance ZONE, not a dimension:
//     radial extent  0.3 .. 0.6      axial extent  0.3 .. 1.0
// so its angle runs anywhere from 45° to about 73°. That is why a seat must
// NOT try to land on the chamfer: a cone rides the chamfer's inner corner,
// whose radius floats across that band, and seating depth floats with it
// (0.3mm of scatter at 45°, 0.8mm at 70° - steeper is worse). The standard
// exists so an abutment can be designed to CLEAR the chamfer and bear on the
// flat race face, which is the only repeatable locating surface.
race_chamfer_radial_max = 0.6;  // How far in the chamfer can eat before flat face
race_chamfer_axial_max = 1.0;   // How far down the race OD cylinder starts
race_chamfer_radial_min = 0.3;  // ...and the shallow end of the same band
seat_contact_width = 0.4;       // Flat-face contact on Plate B's shoulder land

// Plate A takes NO flat seat. Off the bore the roof bevels UP at 45° purely to
// buy airspace over the race's chamfer, crests, and comes back DOWN to a ridge
// whose tip is the bearing's bottom-out point. That tip is placed just inboard
// of the widest the chamfer can ever be, so it lands on the race's FLAT face:
//     seat_ridge_offset (0.7) > race_chamfer_radial_max (0.6)
// Contact is therefore a flat-face line at a known radius, and seating depth is
// exactly pocket_depth_a with NO chamfer scatter - better than a conical seat
// and still with no flat surface anywhere on the roof.
// Every ridge after that one is lifted by bearing_face_clearance so it touches
// nothing.
seat_ridge_offset = 0.7;        // Contact ridge, radially in from the bore

// === v2 ARCHED ROOFS ======================================================
// v1 rode concentric 45° ridges, and every ridge valley was a free-floating
// ring the slicer never supported. v2 drops the ridges: each pocket roof is one
// ARCH springing from the pocket wall, cresting, and landing on a centre post.
// Material then grows from two solid anchors and there are no islands at all
// (bar Plate A's seat ridge, which is a functional stop).
//
// roof_angle is the experiment. 45° was v1. At 20° each 0.2mm layer steps
// 0.55mm inward - more than one 0.4mm nozzle width - so this is past the usual
// self-support limit and is exactly the thing to print-test.
roof_angle = 40;                // Degrees from HORIZONTAL. 20° and 35° both
                                // drooped on the printer. 40° steps 0.24mm per
                                // 0.2mm layer, well inside one nozzle width.
roof_slope = tan(roof_angle);
// Plate A's sacrificial centre post. A straight 0.6mm pillar 3.3mm tall was far
// too flimsy off the bed, so it is a tree: a wide foot for adhesion that tapers
// fast onto a slim shaft for the rest of the run. The taper narrows going UP,
// so it is self-supporting however steep it is.
// A straight shaft on a tapered foot kept failing at every diameter tried
// (0.6, 1.0, 2.0, 3.0). Going straight up is the problem: the column is only as
// strong as its thinnest point over its whole length. So it is now ONE cone
// running the full height - widest at the bed, narrowing continuously to the
// snap point. Every layer is bigger than the one above it, so it is both
// self-supporting and progressively stiffer toward the base.
// Set false to omit the printed post entirely and let the SLICER build that
// column instead, via a support_enforcer volume placed by build_3mf.py. The
// printed post failed at 0.6/1.0/2.0/3.0mm straight and is a cone now; slicer
// support is purpose-built to break away, so it is worth trying instead.
//
// v3: the post can stay. It sits inside the bearing BORE (8mm), which nothing
// else uses on this side: B's pin fills the other end of the bore, and since
// both pin and post are flush with their plate's mating face, the tip-to-tip
// gap is exactly the plate gap. A spins with the outer race, so the post turns
// against the inner race - hence the radial clearance.
//   "permanent"   - 7mm column, part of Plate A. Arch lands at its edge.
//   "sacrificial" - v2's snap-off cone; arch lands at the 3mm neck.
//   "none"        - no post; slicer support builds the column (build_3mf.py).
plate_a_post = "permanent";
centre_post_d = 7.0;            // 0.5mm radial clearance to the 8mm bore
centre_post_chamfer = 0.4;      // 45° at the bed edge: eats elephant's foot, and
                                // leads the post into the bore on assembly
support_post_base_d = 8.0;      // Cone base at the bed
support_post_neck_d = 3.0;      // Snap point under the roof, and the cone's top
support_post_neck_h = 0.4;      // Straight land at the top so the break is clean
// Where Plate A's arch lands
plate_a_arch_land_r = plate_a_post == "permanent" ? centre_post_d / 2
                                                  : support_post_neck_d / 2;

// Arch crown for flanks at roof_angle springing from (r_out,z_out) to (r_in,z_in)
function arch_crown_r(r_out, z_out, r_in, z_in) =
    (r_out + r_in) / 2 + (z_out - z_in) / (2 * roof_slope);
function arch_crown_z(r_out, z_out, r_in, z_in) =
    z_out + (r_out - arch_crown_r(r_out, z_out, r_in, z_in)) * roof_slope;

// Plate A roof, derived.
seat_ridge_r = bearing_press_diameter / 2 - seat_ridge_offset;   // 10.25 - the stop
plate_a_valley_z = pocket_depth_a + bearing_face_clearance;      // every OTHER ridge
plate_a_saw_r_out = seat_ridge_r - bearing_face_clearance;       // regular waves start
// The airspace hump between the bore and the seat ridge
seat_hump_r = (bearing_press_diameter / 2 + seat_ridge_r) / 2;
seat_hump_z = pocket_depth_a + seat_ridge_offset / 2;

// === SUPPORT-FRIENDLY POCKET SEAT ===
sawtooth_ceiling_a = true;   // Ridge Plate A's raised roof (inboard of the seat)
sawtooth_ceiling_b = true;   // Ridge Plate B's raised roof (outboard of the shoulder)
sawtooth_amp_target = 0.6;   // Target wave height (= radial half-period, 45°).
                             // Half-cycle count is fitted per plate from the span
                             // and forced EVEN so both ends land on valleys.
                             // Bigger = fewer support rings but thinner shell.
sawtooth_min_shell = 0.6;    // Floor on material above a peak (3 layers). The wave
                             // is shrunk below sawtooth_amp_target when headroom
                             // demands it, rather than punching into the dome.
breakaway_supports = false;  // Model the tubes into the part instead of letting
                             // the slicer generate support. Normally off.
support_wall = 0.4;          // Tube wall = one nozzle width
support_gap = 0.2;           // Z gap under each ring (one layer) so it snaps free

// Axle pin (integrated into Plate B, rises from pocket floor)
pin_shaft_diameter = 8.3;           // Interference fit with 8mm bearing ID (8.1 was too loose, +0.2)

// The shoulder is a 45° cone rising to a FLAT land, and that land is what the
// inner race sits on. Unlike Plate A's seat this costs nothing to print: it
// faces UP, so it is a top surface, not an overhang. The land has to clear the
// inner race's bore chamfer (up to 0.6 radial off the 8mm bore, so from r=4.6)
// and then give seat_contact_width of real flat contact:
//     r = 4.0 + 0.6 + 0.4 = 5.0  ->  the 10mm shoulder
// Height then follows from holding the cone at 45°.
pin_shoulder_diameter = 10;         // Land outer diameter - inner race rests here
pin_shoulder_height = (pin_shoulder_diameter - pin_shaft_diameter) / 2;  // 0.85mm at 45°
pin_shoulder_top_d = pin_shoulder_diameter;
pin_shaft_height = pocket_depth_b - pin_shoulder_height;  // 3.15mm

// Dome grooves - V-shaped radial channels cut into dome surface
groove_size = 2;                    // Diagonal of diamond cross-section (1mm deep, 2mm wide, 90° V)
groove_start_r = 0;                 // Start from center (dome peak)
groove_end_r = magnet_distance + pocket_diameter/2;  // Extend to magnet pocket edge
groove_angle = 8;                   // Downward tilt from peak to edges (degrees, ~5.7° follows dome slope)
groove_z = dome_peak_z + 0.9;  // Z height at center (just above dome peak)

// === MODULES ===

// Create a 2D shape from three ellipses spanning triangle edges
// Each ellipse connects two adjacent vertices and bulges outward
// Key relationship: ellipse center distance = bulge (ensures proper overlap)
module three_ellipse_2d(vertex_radius, bulge, center_r = 0) {
    semi_minor = bulge;

    union() {
        for (i = [0:2]) {
            // Two adjacent vertex angles
            angle1 = 120 * i - 90;       // -90°, 30°, 150°
            angle2 = 120 * (i + 1) - 90; // 30°, 150°, 270°

            // Vertex positions
            v1x = vertex_radius * cos(angle1);
            v1y = vertex_radius * sin(angle1);
            v2x = vertex_radius * cos(angle2);
            v2y = vertex_radius * sin(angle2);

            // Edge midpoint direction (bisector of the two vertex angles)
            mid_angle = (angle1 + angle2) / 2;

            // KEY: Ellipse center at distance = bulge from origin
            // This ties overlap to bulge - smaller bulge = more overlap at center
            cx = bulge * cos(mid_angle);
            cy = bulge * sin(mid_angle);

            // Edge direction angle (line connecting the two vertices)
            edge_dir = atan2(v2y - v1y, v2x - v1x);

            // Calculate semi_major so ellipse passes through vertices
            // Transform vertex to local ellipse coordinates (center at origin, major axis along X)
            dx = v1x - cx;
            dy = v1y - cy;
            local_x = dx * cos(-edge_dir) - dy * sin(-edge_dir);
            local_y = dx * sin(-edge_dir) + dy * cos(-edge_dir);

            // From ellipse equation: (x/a)² + (y/b)² = 1, solve for a
            denom = max(0.001, 1 - (local_y * local_y) / (semi_minor * semi_minor));
            semi_major = abs(local_x) / sqrt(denom);

            // Place ellipse
            translate([cx, cy])
            rotate([0, 0, edge_dir])
            scale([semi_major, semi_minor])
                circle(r = 1, $fn = 256);
        }

        // Center fill (may still be needed for very small bulge values)
        if (center_r > 0) {
            circle(r = center_r, $fn = 256);
        }
    }
}

// Calculate sphere radius for dome curvature
// Formula: R = (r² + h²) / (2h) where r=base radius, h=dome height
function dome_sphere_radius(base_r, height) =
    (base_r * base_r + height * height) / (2 * height);

// Radius at which the sphere envelope reaches height h above dome_start_z
function dome_contour_r(h) =
    let (R = dome_sphere_radius(vertex_radius, dome_height),
         d = R - dome_height + h)
    d >= R ? 0 : sqrt(R * R - d * d);

// "rings": stacked frustums. Step k ramps at 45° from the contour radius of
// the previous level, then the next frustum's flat bottom forms the horizontal
// run. Each frustum is built from the envelope contour *below* it, so the
// terraces sit on or above the sphere everywhere.
module ring_dome_solid() {
    for (k = [0 : ring_steps - 1]) {
        r_outer = dome_contour_r(k * step_rise);
        translate([0, 0, k * step_rise])
            cylinder(h = step_rise, r1 = r_outer, r2 = r_outer - step_run, $fn = 256);
    }
}

// Outline eroded inward by d
module eroded_outline(d) {
    offset(r = -d)
        three_ellipse_2d(vertex_radius, ellipse_bulge, center_fill);
}

// "lobes": stacked chamfered slabs following the outline. Step k is the hull
// of the outline eroded by lobe_offset(k) (bottom) and by that plus
// lobe_run(k) (top), giving a 45° ramp; the next slab's smaller footprint
// leaves the flat run. The outline is convex (checked), so hull() is exact.
module lobe_dome_solid() {
    eps = 0.01;
    for (k = [0 : lobe_steps - 1]) {
        d0 = lobe_offset(k);
        translate([0, 0, lobe_z0(k)])
            hull() {
                linear_extrude(height = eps) lobe_footprint(k, d0);
                translate([0, 0, lobe_rise(k) - eps])
                    linear_extrude(height = eps) lobe_footprint(k, d0 + lobe_run(k));
            }
    }
}

// Morph fraction for step k: 0 on the bottom step (pure outline), 1 on the top
// step (pure circle).
function round_top_t(k) = lobe_steps > 1 ? k / (lobe_steps - 1) : 1;

// Mid-edge radius of the outline eroded by d - the outline's nearest point.
function mid_edge_r(d) = 2 * ellipse_bulge - d;

// Round top as a MINKOWSKI BLEND, not a clip: (1-t) x eroded outline, grown
// by a round margin of t x its mid-edge radius. (A first cut intersected the
// outline with a circle, which left a crease wherever the circle crossed the
// sides.) Every step is then one smooth convex curve; the points are rounded
// over with radius t*m, growing up the dome until the top step is a circle.
//
// Why it keeps every number: a blend's support function is the blend of the
// two support functions. At the mid-edge both are m, so the blend is still m,
// and the mid-edge profile that all the clearance checks use is untouched.
// At the points it gives m + 4.8*(1-t). And eroding the input by a step's run
// moves the blend in by exactly that run in EVERY direction, so each ramp is
// still a true 45°. Flats come out a little wider toward the points, by up
// to 4.8mm x (1/(lobe_steps-1)), and the steps still nest.
// Convex in, convex out, so hull() in lobe_dome_solid stays exact.
module lobe_footprint(k, d) {
    t = round_top_t(k);
    if (!dome_round_top || t <= 0)
        eroded_outline(d);
    else if (t >= 1)
        circle(r = mid_edge_r(d), $fn = 256);
    else
        offset(r = t * mid_edge_r(d), $fn = 256)
            scale([1 - t, 1 - t]) eroded_outline(d);
}

// Smooth sphere-intersection dome (original)
module smooth_dome_solid() {
    sphere_r = dome_sphere_radius(vertex_radius, dome_height);
    translate([0, 0, -sphere_r + dome_height])
        sphere(r = sphere_r, $fn = 256);
}

// Main body with flat bottom, domed top (stepped or smooth)
module tri_body() {
    // Lower section (flat bottom to dome start) - straight walls
    linear_extrude(height = dome_start_z)
        three_ellipse_2d(vertex_radius, ellipse_bulge, center_fill);

    // Dome section - clipped to the three-ellipse outline
    translate([0, 0, dome_start_z])
    intersection() {
        linear_extrude(height = dome_peak_z - dome_start_z + 0.1)
            three_ellipse_2d(vertex_radius, ellipse_bulge, center_fill);

        if (dome_style == "lobes") lobe_dome_solid();
        else if (dome_style == "rings") ring_dome_solid();
        else smooth_dome_solid();
    }
}

// Single magnet pocket - opens upward for drop-in during print pause
module magnet_pocket() {
    // Pocket extends from pocket_floor_z to pocket_top_z only (dome closes over)
    translate([0, 0, pocket_floor_z])
        cylinder(h = pocket_depth, d = pocket_diameter, $fn = 32);
}

// All magnet pockets arranged in pattern
// Evenly spaced from magnet_phase.
//   phase 30 -> 30°, 150°, 270°  (the three points)
//   phase 90 -> 90°, 210°, 330°  (the three edge midpoints)
//   num_magnets = 6 -> both sets regardless of phase
module all_magnet_pockets(phase = undef) {
    ph = is_undef(phase) ? magnet_phase : phase;
    for (i = [0:num_magnets-1]) {
        angle = (360 / num_magnets) * i + ph;
        translate([magnet_distance * cos(angle), magnet_distance * sin(angle), 0])
            magnet_pocket();
    }
}

// 6 radial V-grooves cut into dome surface along magnet directions
// Diamond cross-section ($fn=4) gives a 90° V-groove
// Positioned at dome peak height — grooves are ~2mm deep at center,
// tapering shallower toward edges as dome curves down
module dome_grooves() {
    for (i = [0:5]) {
        angle = 60 * i + 30;
        rotate([0, 0, angle])
            translate([groove_start_r, 0, groove_z])
                rotate([0, 90 + groove_angle, 0])
                    cylinder(h = groove_end_r - groove_start_r,
                             r = groove_size / 2, $fn = 4);
    }
}

// === SAWTOOTH POCKET SEAT ===

// Biggest wave that still leaves sawtooth_min_shell of material over the
// outermost peak. The dome is lowest at the rim, so measuring headroom at r_out
// is the conservative case; every peak further in has more room.
function sawtooth_amp_allowed(r_out, z_valley) =
    dome_z_at_offset(2 * ellipse_bulge - r_out) - z_valley - sawtooth_min_shell;

// Half-cycles across a roof: fitted to the span, forced even so the profile
// starts and ends on a valley (both ends then sit on an anchored edge).
function sawtooth_n(r_out, r_in, z_valley) =
    let (amp = min(sawtooth_amp_target, sawtooth_amp_allowed(r_out, z_valley)))
    // ceil, not round: rounding DOWN would make the fitted amplitude exceed the
    // cap and eat into the shell.
    max(2, 2 * ceil((r_out - r_in) / (2 * max(amp, 0.1))));

// Radial step per half-cycle. Equal to the rise, which is what makes it 45°.
function sawtooth_amp(r_out, r_in, n) = (r_out - r_in) / n;

// Profile points from r_out inward to r_in. Even i = valley (z0), odd i = peak.
function sawtooth_pts(r_out, r_in, z0, n) =
    let (a = sawtooth_amp(r_out, r_in, n))
    [ for (i = [0 : n]) [ r_out - i * a, z0 + (i % 2 == 1 ? a : 0) ] ];

// Valley rings that float. i=0 is anchored to the pocket wall so it is skipped;
// the innermost is skipped too when something (the pin) already holds it up.
function sawtooth_valley_radii(r_out, r_in, n, inner_anchored = false) =
    let (a = sawtooth_amp(r_out, r_in, n),
         last = inner_anchored ? n - 2 : n)
    [ for (i = [2 : 2 : last]) r_out - i * a ];

// Plate A's roof, v2. Working inward from the bore:
//   bore top -> 45° hump (airspace over the race chamfer)
//            -> down to the SEAT RIDGE tip, the bearing's bottom-out point
//            -> ARCH up at roof_angle, crest, down onto the sacrificial post
// Plate A spins WITH the outer race, so the shallow rise brushing the outer
// race just inboard of the seat ridge is harmless. Only the shield and inner
// race (r < ~9.5) need real clearance, and the arch is 0.27mm clear by there.
module plate_a_roof_void() {
    br = bearing_press_diameter / 2;
    zs = pocket_depth_a;
    pr = plate_a_arch_land_r;
    // Void floor runs to -0.1 rather than zs-0.1: at zs-0.1 (=2.6) it landed
    // exactly on dome_start_z, stacking three coincident planes. Everything
    // below zs is inside the bore void anyway, so dropping it costs nothing and
    // avoids the coincidence. NOTE: this did NOT cure the genus artifact below;
    // it is kept because avoiding coincident planes is good practice regardless.
    //
    // KNOWN, BENIGN: with a STEPPED dome this arch void leaves the body at
    // genus 31 (smooth dome gives genus 1, the expected post-through-pocket
    // handle). The mesh is still watertight, manifold, consistently oriented,
    // and every cross-section from z=0.4 to 7.2 has exactly the loops it should
    // - the 26 sub-1e-4mm2 sliver triangles are what carry the topology. It
    // slices correctly. Plate B is genus 0.
    cr = arch_crown_r(seat_ridge_r, zs, pr, zs);
    cz = arch_crown_z(seat_ridge_r, zs, pr, zs);
    // v3, permanent post: the inner flank carries on 0.3mm PAST the post edge
    // and plate_a() subtracts the post from this void. The flank then crosses
    // the post's side cleanly instead of ending exactly on its edge, which is
    // what left a ring of non-manifold edges there.
    over = plate_a_post == "permanent" ? 0.3 : 0;
    rotate_extrude($fn = 256)
        polygon([[0, -0.1], [br, -0.1], [br, zs],
                 [seat_hump_r, seat_hump_z],
                 [seat_ridge_r, zs],
                 [cr, cz],
                 [pr - over, zs - over * roof_slope], [0, zs - over * roof_slope]]);
}

// Plate B's roof, v2: one arch from the pocket wall onto the pin shoulder edge.
// Springs bearing_face_clearance above the race face so it never touches the
// OUTER race (which Plate B must not drag on), and lands on the shoulder.
module plate_b_roof_void() {
    r_out = bearing_clearance_diameter / 2;
    z_out = pocket_depth_b + bearing_face_clearance;
    r_in = pin_shoulder_top_d / 2;
    z_in = pocket_depth_b;
    cr = arch_crown_r(r_out, z_out, r_in, z_in);
    cz = arch_crown_z(r_out, z_out, r_in, z_in);
    // v3: same trick as Plate A's post. The flank runs 0.3mm on into the pin
    // and the pin is subtracted from the void, so the two cross instead of
    // meeting edge-on (v2 left 256 non-manifold edges on this ring). The void
    // also spans r=0 now, standing in for the top of the pocket cylinder, so no
    // third surface passes through that ring.
    over = 0.3;
    rotate_extrude($fn = 256)
        polygon([[0, z_in - 0.5], [r_out, z_in - 0.5], [r_out, z_out],
                 [cr, cz], [r_in - over, z_in - over * roof_slope],
                 [0, z_in - over * roof_slope]]);
}

// Sacrificial centre post for Plate A - the stand-in for Plate B's pin. Rises
// from the bed inside the pocket to carry the crown. SNAP IT OFF before fitting
// the bearing; it sits in the bearing's space.
module plate_a_support_post() {
    cone_h = pocket_depth_a - support_post_neck_h;
    // One cone, base to neck
    cylinder(h = cone_h, d1 = support_post_base_d, d2 = support_post_neck_d, $fn = 96);
    // Straight land at the top: the deliberate break point, flush under the roof
    translate([0, 0, cone_h])
        cylinder(h = support_post_neck_h, d = support_post_neck_d, $fn = 96);
}

// Permanent centre post for Plate A (v3). Bed to bearing face, where the roof
// takes over above it. Chamfered at the bed: that edge is a 45° overhang, fine.
// It is SUBTRACTED from the pocket void rather than unioned on afterwards, so
// it runs past both ends: below the bed (clipped by the body) and up into the
// solid roof.
module plate_a_centre_post() {
    c = centre_post_chamfer;
    translate([0, 0, -1])
        cylinder(h = 1, d = centre_post_d - 2 * c, $fn = 256);
    cylinder(h = c, d1 = centre_post_d - 2 * c, d2 = centre_post_d, $fn = 256);
    translate([0, 0, c])
        cylinder(h = pocket_depth_a - c + 0.5, d = centre_post_d, $fn = 256);
}

// Ridged roof that stands off the bearing face by `clear`, joined back down to
// an anchor ring (the pin shoulder edge) by a 45° ramp. Valleys sit at
// z_face + clear, so nothing in the ridging can reach the bearing.
module raised_sawtooth_ceiling(r_out, r_anchor, z_face, clear) {
    r_saw = r_anchor + clear;              // ramp rises 45°: clear out, clear up
    zv = z_face + clear;                   // valley plane
    n = sawtooth_n(r_out, r_saw, zv);
    rotate_extrude($fn = 256)
        polygon(concat([[r_anchor, z_face - 0.1], [r_out, z_face - 0.1]],
                       sawtooth_pts(r_out, r_saw, zv, n),
                       [[r_anchor, z_face]]));
}

// Extra void above a pocket, shaped as concentric 45° V's
module sawtooth_ceiling_void(r_out, r_in, z0, n) {
    rotate_extrude($fn = 256)
        polygon(concat([[r_in, z0 - 0.1], [r_out, z0 - 0.1]],
                       sawtooth_pts(r_out, r_in, z0, n)));
}

// Free-standing breakaway tubes under the floating valley rings. They stand on
// the bed inside the pocket, touch nothing but the ring they hold, and sit in
// the bearing's space so they MUST be broken out before assembly.
module breakaway_tubes(r_out, r_in, z0, n, inner_anchored = false) {
    for (r = sawtooth_valley_radii(r_out, r_in, n, inner_anchored))
        if (r > support_wall)
            difference() {
                cylinder(h = z0 - support_gap, r = r + support_wall / 2, $fn = 128);
                translate([0, 0, -0.1])
                    cylinder(h = z0 - support_gap + 0.2, r = r - support_wall / 2, $fn = 128);
            }
}

// === FINAL MODEL ===

// Plate A bearing pocket - press fit for outer race, with counterbore for inner race clearance
module bearing_pocket_press() {
    // v3: with the arched roof, its void already spans the whole bore from
    // below the bed, so the cylinder is redundant - and its top face sat
    // exactly on the seat ridge tip, leaving a non-manifold ring there.
    if (!sawtooth_ceiling_a)
    translate([0, 0, -0.1])
        cylinder(h = pocket_depth_a + 0.1, d = bearing_press_diameter, $fn = 256);
    // Counterbore at pocket ceiling - gives inner race/balls room to spin
    // Bevel straight off the bore at 45°, no flat anywhere. It climbs past the
    // chamfer band and the bearing-face standoff before the first wave turns
    // over, so every valley clears the race face.
    if (sawtooth_ceiling_a)
        plate_a_roof_void();
    else
        translate([0, 0, pocket_depth_a - 0.1])
            cylinder(h = bearing_face_clearance + 0.1, d = outer_race_face_id, $fn = 256);
}

// Plate B bearing pocket - clearance for outer race
module bearing_pocket_clearance() {
    // Stops 0.3 short of the ceiling; the roof void (from z_in - 0.5) covers
    // the rest, overlapping so no faces are coplanar.
    translate([0, 0, -0.1])
        cylinder(h = pocket_depth_b - 0.3 + 0.1, d = bearing_clearance_diameter, $fn = 256);
    plate_b_roof_void();
}

// Axle pin - sits inside Plate B's bearing pocket, flush with surface
module axle_pin() {
    // v3: subtracted from the pocket void, so it overshoots both ends - down
    // below the bed, and the cone carries on 0.5mm up into the solid roof. The
    // cone (45°) stays above the arch flank (40°) everywhere past r=5, so the
    // overshoot never eats into the arch void.
    over = 0.5;
    // Shaft first - bearing slides onto this from the open bottom
    translate([0, 0, -1])
        cylinder(h = pin_shaft_height + 1, d = pin_shaft_diameter, $fn = 256);
    // Wide shoulder at top - bearing inner race rests against this
    // 45° cone up to the flat land the inner race sits on. Faces up, so the
    // flat costs nothing to print.
    translate([0, 0, pin_shaft_height])
        cylinder(h = pin_shoulder_height + over, d1 = pin_shaft_diameter,
                 d2 = pin_shoulder_top_d + 2 * over, $fn = 256);
}

// Plate A - press fit side (bearing outer race press-fits into 22mm pocket)
module plate_a() {
    difference() {
        tri_body();
        all_magnet_pockets(magnet_phase_a);
        // Permanent post: left standing by keeping it OUT of the void
        difference() {
            bearing_pocket_press();
            if (plate_a_post == "permanent") plate_a_centre_post();
        }
        if (show_grooves) dome_grooves();
    }
    if (plate_a_post == "sacrificial") plate_a_support_post();
}

// Plate B - clearance side with integrated axle pin
module plate_b() {
    difference() {
        tri_body();
        all_magnet_pockets(magnet_phase_b);
        // Axle pin: left standing by keeping it OUT of the pocket void (v3;
        // v2 unioned it on afterwards)
        difference() {
            bearing_pocket_clearance();
            axle_pin();
        }
        if (show_grooves) dome_grooves();
    }
}

// Cutting plane - horizontal slice at layer height to see magnet/bearing pockets
module cut_plane() {
    translate([-100, -100, cross_section_z]) cube([200, 200, 50]);
}

// Render plates based on show flags
module render_all() {
    if (show_plate_a)
        translate([show_plate_b ? -(vertex_radius + 2) : 0, 0, 0])
            rotate([0, 0, 90])
                plate_a();

    if (show_plate_b)
        translate([show_plate_a ? (vertex_radius + 2) : 0, 0, 0])
            rotate([0, 0, 90])
                plate_b();
}

// Apply cross-section if enabled
difference() {
    render_all();
    if (cross_section) cut_plane();
}

// === INFO ===
echo(str("Shape: Three edge-spanning ellipses"));
echo(str("Vertex radius: ", vertex_radius, "mm (points extend this far)"));
echo(str("Ellipse bulge: ", ellipse_bulge, "mm"));
echo(str("Center fill radius: ", center_fill, "mm"));
echo(str("Total height: ", total_height, "mm"));
echo(str("Dome starts at z=", dome_start_z, "mm, height=", dome_height, "mm"));
echo(str("Dome sphere radius: ", dome_sphere_radius(vertex_radius, dome_height), "mm"));
echo(str("Dome style: ", dome_style, ", peak z=", dome_peak_z, "mm"));
if (dome_style == "lobes") {
    echo(str("Steps: ", lobe_steps, " at ", step_angle, "°, rise in layers ", lobe_rise_layers,
             ", flat run ", lobe_flat_0, "mm growing +", lobe_flat_growth, "mm per step"));
    for (k = [0 : lobe_steps - 1])
        echo(str("  step ", k + 1, ": rise ", lobe_rise(k), "mm, flat ", lobe_flat_at(k),
                 "mm, ramp offset ", lobe_offset(k), " -> ", lobe_offset(k) + lobe_run(k),
                 "mm (mid-edge r=", 2 * ellipse_bulge - lobe_offset(k) - lobe_run(k),
                 "), z=", dome_start_z + lobe_z0(k), " -> ", dome_start_z + lobe_z0(k + 1)));
    // Top face = top of the LAST step: lobe_offset(lobe_steps-1) + its run.
    // (Using lobe_offset(lobe_steps) tacks on a flat run for a step that does
    // not exist and understates the plateau.)
    plateau_offset = lobe_offset(lobe_steps - 1) + lobe_run(lobe_steps - 1);
    // Shell over Plate B's edge-midpoint magnets: their outer edge is the
    // magnet wall in from the rim, and that is where the dome is lowest
    mag_wall = 2 * ellipse_bulge - magnet_distance - pocket_diameter / 2;
    echo(str("  CHECK shell over edge-midpoint magnets (", mag_wall, "mm in from the rim): ",
             dome_z_at_offset(mag_wall) - pocket_top_z, "mm over the pocket top"));
    echo(str("  top plateau: mid-edge inradius ", 2 * ellipse_bulge - plateau_offset,
             "mm, vertex reach ", vertex_radius - plateau_offset, "mm"));
    // Clearance: dome must be solid across each bearing pocket at its ceiling
    echo(str("  CHECK Plate B pocket ceiling z=", pocket_depth_b, ": dome inradius ",
             2 * ellipse_bulge - lobe_offset_at_z(pocket_depth_b), "mm vs pocket r ",
             bearing_clearance_diameter / 2, "mm -> margin ",
             2 * ellipse_bulge - lobe_offset_at_z(pocket_depth_b) - bearing_clearance_diameter / 2, "mm"));
    echo(str("  CHECK Plate A pocket ceiling z=", pocket_depth_a, ": dome inradius ",
             2 * ellipse_bulge - lobe_offset_at_z(pocket_depth_a), "mm vs pocket r ",
             bearing_press_diameter / 2, "mm -> margin ",
             2 * ellipse_bulge - lobe_offset_at_z(pocket_depth_a) - bearing_press_diameter / 2, "mm"));
}
if (dome_style == "rings") {
    echo(str("Steps: ", ring_steps, " x ", step_rise, "mm rise at ", step_angle, "° (", step_layers, " layers each)"));
    for (k = [0 : ring_steps - 1])
        echo(str("  step ", k + 1, ": ramp starts r=", round(dome_contour_r(k * step_rise) * 10) / 10,
                 "mm, z=", dome_start_z + k * step_rise, " -> ", dome_start_z + (k + 1) * step_rise));
}
echo(str("Grooves: ", show_grooves ? "on" : "off"));
echo(str("Magnet diameter: ", magnet_diameter, "mm"));
echo(str("Magnet pocket diameter: ", pocket_diameter, "mm"));
echo(str("Magnet pocket: z=", pocket_floor_z, " to z=", pocket_top_z, "mm"));
echo(str("Magnet distance from center: ", magnet_distance, "mm"));
// Outboard wall beside each magnet pocket, at the pocket floor and at its top.
// Above dome_start_z the dome ramp erodes the outline, thinning the wall.
erode_at_pocket_top = dome_style == "lobes" ? lobe_offset_at_z(pocket_top_z)
                                            : max(0, pocket_top_z - dome_start_z);
function phase_name(ph) = ph == 30 ? "LOBES (the three points)"
                                  : "SIDES (the three edge midpoints)";
using_points = (num_magnets == 6) || (magnet_phase_a == 30) || (magnet_phase_b == 30);
using_midpts = (num_magnets == 6) || (magnet_phase_a == 90) || (magnet_phase_b == 90);
echo(str("MAGNET LAYOUT: ", num_magnets, " pockets per plate; stagger ",
         stagger_magnets ? "ON" : "off"));
if (num_magnets == 6)
    echo(str("  both plates carry points AND edge midpoints (phase is moot at 6)"));
else {
    echo(str("  Plate A -> ", phase_name(magnet_phase_a), ", wall ",
             magnet_phase_a == 30 ? vertex_radius - magnet_distance - pocket_diameter/2
                                  : 2 * ellipse_bulge - magnet_distance - pocket_diameter/2, "mm"));
    echo(str("  Plate B -> ", phase_name(magnet_phase_b), ", wall ",
             magnet_phase_b == 30 ? vertex_radius - magnet_distance - pocket_diameter/2
                                  : 2 * ellipse_bulge - magnet_distance - pocket_diameter/2, "mm"));
    if (stagger_magnets)
        echo(str("  staggered: still 3 snap positions per turn, offset 60° from unstaggered"));
}
if (using_points)
    echo(str("  wall at points (r=", vertex_radius, "): ",
             vertex_radius - magnet_distance - pocket_diameter/2, "mm at floor, ",
             vertex_radius - erode_at_pocket_top - magnet_distance - pocket_diameter/2,
             "mm at pocket top"));
if (using_midpts)
    echo(str("  wall at edge midpoints (r=", 2 * ellipse_bulge, "): ",
             2 * ellipse_bulge - magnet_distance - pocket_diameter/2, "mm at floor, ",
             2 * ellipse_bulge - erode_at_pocket_top - magnet_distance - pocket_diameter/2,
             "mm at pocket top  <<< thinnest wall in the part"));
if (using_midpts)
    echo(str("  to thicken it, pull magnet_distance in: ", magnet_distance,
             " -> ", 2 * ellipse_bulge - erode_at_pocket_top - pocket_diameter/2 - 0.8,
             " would restore 0.8mm at the pocket top"));
echo(str("Number of magnets per tile: ", num_magnets));
echo(str(">>> PAUSE HEIGHT: ", pocket_top_z, "mm  (insert magnets, glue, resume) <<<"));
// --- support / sawtooth report ---
module sawtooth_report(label, r_out, r_in, z0, n, inner_anchored) {
    a = sawtooth_amp(r_out, r_in, n);
    peaks = [ for (i = [1 : 2 : n - 1]) r_out - i * a ];
    shells = [ for (r = peaks) dome_z_at_offset(2 * ellipse_bulge - r) - (z0 + a) ];
    rings = sawtooth_valley_radii(r_out, r_in, n, inner_anchored);
    echo(str(label, " sawtooth seat: r ", r_out, " -> ", r_in, " (span ", r_out - r_in,
             "mm), ", n, " half-cycles, amplitude ", a, "mm at 45°, peaks at z=", z0 + a));
    echo(str("  shell above peaks (mid-edge, worst case): ", min(shells), "mm",
             min(shells) < sawtooth_min_shell
               ? str("  <<< THIN, below sawtooth_min_shell=", sawtooth_min_shell) : ""));
    echo(str("  support only reaches ", len(rings), " valley rings, r = ", rings,
             len(rings) > 0
               ? str("  (wall at r=", r_out, ", nearest ring clears it by ",
                     r_out - max(rings), "mm)")
               : ""));
}
acr = arch_crown_r(seat_ridge_r, pocket_depth_a, plate_a_arch_land_r, pocket_depth_a);
acz = arch_crown_z(seat_ridge_r, pocket_depth_a, plate_a_arch_land_r, pocket_depth_a);
bcr = arch_crown_r(bearing_clearance_diameter / 2, pocket_depth_b + bearing_face_clearance,
                   pin_shoulder_top_d / 2, pocket_depth_b);
bcz = arch_crown_z(bearing_clearance_diameter / 2, pocket_depth_b + bearing_face_clearance,
                   pin_shoulder_top_d / 2, pocket_depth_b);
echo(str("ARCHED ROOFS at ", roof_angle, "° from horizontal (layer steps inward ",
         layer_height / roof_slope, "mm per ", layer_height, "mm layer; one nozzle width is 0.4)"));
echo(str("  Plate A: springs r=", seat_ridge_r, " z=", pocket_depth_a,
         " -> crown r=", acr, " z=", acz, " -> post r=", plate_a_arch_land_r,
         ";  shell over crown ", dome_z_at_offset(2 * ellipse_bulge - acr) - acz, "mm"));
echo(str("  Plate B: springs r=", bearing_clearance_diameter / 2, " z=",
         pocket_depth_b + bearing_face_clearance, " -> crown r=", bcr, " z=", bcz,
         " -> shoulder r=", pin_shoulder_top_d / 2,
         ";  shell over crown ", dome_z_at_offset(2 * ellipse_bulge - bcr) - bcz, "mm"));
echo(str("  Plate A clearance to the SHIELD at r=9.5: ",
         (seat_ridge_r - 9.5) * roof_slope, "mm (outer race contact is harmless, A spins with it)"));
// Inner flank of A's arch over the inner race face (bore edge, r = bearing_id/2)
echo(str("  Plate A clearance over the INNER race at the bore edge r=", bearing_id / 2, ": ",
         (bearing_id / 2 - plate_a_arch_land_r) * roof_slope, "mm",
         (bearing_id / 2 - plate_a_arch_land_r) * roof_slope < bearing_face_clearance
           ? "  <<< BELOW bearing_face_clearance - A would drag the inner race" : ""));
if (plate_a_post == "permanent") {
    echo(str("  Centre post (permanent): ", centre_post_d, "mm x ", pocket_depth_a,
             "mm, ", centre_post_chamfer, "mm chamfer at the bed. Radial clearance to the bore ",
             (bearing_id - centre_post_d) / 2, "mm; tip to B's pin tip ",
             bearing_height - pocket_depth_a - pocket_depth_b, "mm (= plate gap)"));
    echo(str(">>> PLATE A POST: d=", centre_post_d, "mm h=", pocket_depth_a, "mm <<<"));
}
echo(str(">>> PLATE B PIN: d=", pin_shoulder_top_d, "mm h=", pocket_depth_b, "mm <<<"));
if (dome_round_top)
    for (k = [0 : lobe_steps - 1])
        echo(str("  round top step ", k + 1, ": blend t=", round_top_t(k),
                 ", points rounded at r=", round_top_t(k) * mid_edge_r(lobe_offset(k)),
                 ", reach at points ", mid_edge_r(lobe_offset(k))
                     + (vertex_radius - 2 * ellipse_bulge) * (1 - round_top_t(k)),
                 " (triangle ", vertex_radius - lobe_offset(k), "), mid-edge ",
                 mid_edge_r(lobe_offset(k))));
if (plate_a_post == "sacrificial")
echo(str("  Sacrificial post: solid cone ", support_post_base_d, "mm -> ",
         support_post_neck_d, "mm over ", pocket_depth_a - support_post_neck_h,
         "mm, then a ", support_post_neck_h, "mm straight land. Bed footprint ",
         round(PI * pow(support_post_base_d / 2, 2) * 10) / 10,
         "mm2; side slope ",
         round(atan(2 * (pocket_depth_a - support_post_neck_h) /
                    (support_post_base_d - support_post_neck_d))),
         "deg from horizontal (narrows upward, self-supporting). SNAP OFF before assembly"));

// --- what actually touches the bearing ---
echo(str("BEARING CONTACT Plate A: seat RIDGE tip at r=", seat_ridge_r, ", z=", pocket_depth_a,
         " (", seat_ridge_offset, "mm in from the bore). NO flat face on the roof."));
echo(str("  tip clears the widest chamfer (", race_chamfer_radial_max, "mm -> r=",
         bearing_press_diameter / 2 - race_chamfer_radial_max, ") by ",
         seat_ridge_offset - race_chamfer_radial_max,
         "mm, so it lands on the race FLAT face: ",
         seat_ridge_offset > race_chamfer_radial_max ? "OK, no depth scatter"
                                                     : "FAIL - tip sits on the chamfer"));
echo(str("  airspace hump between bore and seat ridge peaks at z=", seat_hump_z,
         " (", seat_hump_z - pocket_depth_a, "mm over the race face)"));
echo(str("BEARING CONTACT Plate B: shoulder land r ", pin_shaft_diameter / 2, " to ",
         pin_shoulder_top_d / 2, " at z=", pocket_depth_b,
         "; clears the bore chamfer to r ", bearing_id / 2 + race_chamfer_radial_max,
         ", so FLAT-FACE contact is ",
         pin_shoulder_top_d / 2 - (bearing_id / 2 + race_chamfer_radial_max), "mm wide"));
echo(str("RIDGE STANDOFF: the seat ridge TOUCHES by design (z=", pocket_depth_a,
         "); every other A ridge sits at z=", plate_a_valley_z, " -> ",
         bearing_face_clearance, "mm clear. B ridges z=",
         pocket_depth_b + bearing_face_clearance, " -> ", bearing_face_clearance, "mm clear"));
echo(str("  Support rings on Plate A: the seat ridge at ", seat_ridge_offset,
         "mm in from the bore (it is a local low point, so support reaches it),",
         " then the regular valleys listed above."));
echo(str("Pin shoulder: 45° cone ", pin_shaft_diameter, " -> ", pin_shoulder_top_d,
         "mm over ", pin_shoulder_height, "mm, land r ",
         pin_shaft_diameter / 2, " to ", pin_shoulder_top_d / 2));
echo(str("Breakaway tubes: ", breakaway_supports ? "modelled" : "off",
         ", wall ", support_wall, "mm, z-gap ", support_gap, "mm"));
echo(str("Bearing: ", bearing_od, "mm OD x ", bearing_id, "mm ID x ", bearing_height, "mm"));
echo(str("Plate A pocket: ", bearing_press_diameter, "mm dia x ", pocket_depth_a, "mm deep (press fit)"));
echo(str("Plate B pocket: ", bearing_clearance_diameter, "mm dia x ", pocket_depth_b, "mm deep (clearance)"));
echo(str("Axle pin: ", pin_shaft_diameter, "mm shaft on ", pin_shoulder_diameter, "mm x ", pin_shoulder_height, "mm shoulder"));
echo(str("Pin total height: ", pin_shoulder_height + pin_shaft_height, "mm (flush with pocket)"));
echo(str("Dome shell above pocket A (center): ", dome_peak_z - pocket_depth_a, "mm"));
echo(str("Dome shell above pocket B (center): ", dome_peak_z - pocket_depth_b, "mm"));
plate_gap = bearing_height - pocket_depth_b - pocket_depth_a;
echo(str("Gap between plates: ", plate_gap, "mm  (bearing ", bearing_height, " - into B ",
         pocket_depth_b, " - into A ", pocket_depth_a, ")",
         plate_gap < 0.2 ? "  <<< TOO TIGHT" : ""));
echo(str("  Both seats land on FLAT race faces, so the gap does NOT drift with the",
         " chamfer tolerance band."));
echo(str("  press-fit engagement, worst-case ", race_chamfer_axial_max,
         "mm axial chamfer: ", pocket_depth_a - race_chamfer_axial_max,
         "mm of the ", pocket_depth_a, "mm bore"));
