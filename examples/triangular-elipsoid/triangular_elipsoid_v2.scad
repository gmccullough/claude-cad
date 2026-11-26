// Three-Ellipse Fidget Spinner with 608 Bearing
//
// PRINTING:
//   - Print BOTH plates flat/smooth side DOWN on smooth plate, dome faces UP
//   - PAUSE at pocket_top_z (2.6mm) to insert 6x2mm magnets and glue, then resume
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
cross_section_z = 1.6;  // Midpoint of magnet pockets (pocket_floor_z=0.6 to pocket_top_z=2.6)
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
dome_start_z = 2.6;      // Dome begins here (13 layers — flats stay on layer boundaries)
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
lobe_steps = 6;          // 6 x 0.8 = 4.8mm dome, peak z=7.4
lobe_flat_0 = 0.75;      // Flat run on the first (outermost) step. Trimmed from
                         // 1.0 so the dome climbs fast enough to be at full
                         // height by the Plate B crown radius (8.43).
lobe_flat_growth = 0.2;  // Extra flat added per step going up. With flat_0 this
                         // puts the plateau at 8.65mm inradius, covering BOTH
                         // crown radii, while the peak stays at 7.4mm — the 40°
                         // arches cost no extra part height.

// Flat run and cumulative inward offset at step k
function lobe_flat_at(k) = lobe_flat_0 + k * lobe_flat_growth;
function lobe_offset(k) = k * (step_run + lobe_flat_0)
                          + lobe_flat_growth * k * (k - 1) / 2;

// Height of the lobed dome surface at a given inward offset, i.e. at mid-edge
// radius (2*ellipse_bulge - offset). Mid-edge is the worst case: for a given z
// the outline is closer to the axis there than in any other direction.
function dome_z_at_offset(d) =
    d >= lobe_offset(lobe_steps - 1) + step_run ? dome_peak_z :
    max([ for (k = [0 : lobe_steps - 1])
            (d >= lobe_offset(k) && d <= lobe_offset(k) + step_run)
              ? dome_start_z + k * step_rise + (d - lobe_offset(k))
          : (d > lobe_offset(k) + step_run && d < lobe_offset(k + 1))
              ? dome_start_z + (k + 1) * step_rise
          : 0 ]);

// Inward offset of the dome surface at absolute height z (for clearance checks)
function lobe_offset_at_z(z) =
    let (k = floor((z - dome_start_z) / step_rise),
         frac = z - dome_start_z - k * step_rise)
    k < 0 ? 0 : lobe_offset(k) + min(frac, step_run);

// "rings" style: steps follow the sphere envelope contours
ring_steps = ceil(dome_height / step_rise);      // 6 steps for 4.4mm envelope

dome_peak_z = dome_style == "lobes"  ? dome_start_z + lobe_steps * step_rise :
              dome_style == "rings"  ? dome_start_z + ring_steps * step_rise :
                                       dome_start_z + dome_height;

// Dome grooves flag - 6 radial V-grooves from the peak
show_grooves = false;

// Magnet specifications (6x2mm magnets)
magnet_diameter = 6;     // 6mm diameter magnets
magnet_height = 2;       // 2mm thick magnets
magnet_clearance = 0.2;  // Extra clearance for easy insertion

// Magnet pocket position (close to mating surface for strong attraction)
pocket_floor_z = 0.6;    // Solid floor thickness before pockets (3 layers at 0.2mm)
pocket_top_z = pocket_floor_z + magnet_height;  // 2.6mm - PAUSE HEIGHT

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
pocket_depth_a = 2.7;               // Plate A (press-fit side) depth
pocket_depth_b = 3.9;               // Plate B (pin side) depth
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
sacrificial_post = true;
support_post_base_d = 8.0;      // Cone base at the bed
support_post_neck_d = 3.0;      // Snap point under the roof, and the cone's top
support_post_neck_h = 0.4;      // Straight land at the top so the break is clean

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
// of the outline eroded by lobe_offset(k) (bottom) and by that plus step_run
// (top), giving a 45° ramp; the next slab's smaller footprint leaves the flat
// run. The outline is convex (checked), so hull() is exact.
module lobe_dome_solid() {
    eps = 0.01;
    for (k = [0 : lobe_steps - 1]) {
        d0 = lobe_offset(k);
        translate([0, 0, k * step_rise])
            hull() {
                linear_extrude(height = eps) eroded_outline(d0);
                translate([0, 0, step_rise - eps])
                    linear_extrude(height = eps) eroded_outline(d0 + step_run);
            }
    }
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
    pr = support_post_neck_d / 2;
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
    rotate_extrude($fn = 256)
        polygon([[0, -0.1], [br, -0.1], [br, zs],
                 [seat_hump_r, seat_hump_z],
                 [seat_ridge_r, zs],
                 [cr, cz],
                 [pr, zs], [0, zs]]);
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
    rotate_extrude($fn = 256)
        polygon([[r_in, z_in - 0.1], [r_out, z_in - 0.1], [r_out, z_out],
                 [cr, cz], [r_in, z_in]]);
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
    translate([0, 0, -0.1])
        cylinder(h = pocket_depth_b + 0.1, d = bearing_clearance_diameter, $fn = 256);
    plate_b_roof_void();
}

// Axle pin - sits inside Plate B's bearing pocket, flush with surface
module axle_pin() {
    // Shaft first - bearing slides onto this from the open bottom
    cylinder(h = pin_shaft_height, d = pin_shaft_diameter, $fn = 256);
    // Wide shoulder at top - bearing inner race rests against this
    // 45° cone up to the flat land the inner race sits on. Faces up, so the
    // flat costs nothing to print.
    translate([0, 0, pin_shaft_height])
        cylinder(h = pin_shoulder_height, d1 = pin_shaft_diameter,
                 d2 = pin_shoulder_top_d, $fn = 256);
}

// Plate A - press fit side (bearing outer race press-fits into 22mm pocket)
module plate_a() {
    difference() {
        tri_body();
        all_magnet_pockets(magnet_phase_a);
        bearing_pocket_press();
        if (show_grooves) dome_grooves();
    }
    if (sacrificial_post) plate_a_support_post();
}

// Plate B - clearance side with integrated axle pin
module plate_b() {
    difference() {
        tri_body();
        all_magnet_pockets(magnet_phase_b);
        bearing_pocket_clearance();
        if (show_grooves) dome_grooves();
    }
    // Axle pin rises from pocket floor
    axle_pin();
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
    echo(str("Steps: ", lobe_steps, " x ", step_rise, "mm rise at ", step_angle, "° (", step_layers,
             " layers each), flat run ", lobe_flat_0, "mm growing +", lobe_flat_growth, "mm per step"));
    for (k = [0 : lobe_steps - 1])
        echo(str("  step ", k + 1, ": flat ", lobe_flat_at(k), "mm, ramp offset ", lobe_offset(k),
                 " -> ", lobe_offset(k) + step_run,
                 "mm (mid-edge r=", 2 * ellipse_bulge - lobe_offset(k) - step_run,
                 "), z=", dome_start_z + k * step_rise, " -> ", dome_start_z + (k + 1) * step_rise));
    // Top face = top of the LAST step: lobe_offset(lobe_steps-1) + step_run.
    // (Using lobe_offset(lobe_steps) tacks on a flat run for a step that does
    // not exist and understates the plateau.)
    plateau_offset = lobe_offset(lobe_steps - 1) + step_run;
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
acr = arch_crown_r(seat_ridge_r, pocket_depth_a, support_post_neck_d / 2, pocket_depth_a);
acz = arch_crown_z(seat_ridge_r, pocket_depth_a, support_post_neck_d / 2, pocket_depth_a);
bcr = arch_crown_r(bearing_clearance_diameter / 2, pocket_depth_b + bearing_face_clearance,
                   pin_shoulder_top_d / 2, pocket_depth_b);
bcz = arch_crown_z(bearing_clearance_diameter / 2, pocket_depth_b + bearing_face_clearance,
                   pin_shoulder_top_d / 2, pocket_depth_b);
echo(str("ARCHED ROOFS at ", roof_angle, "° from horizontal (layer steps inward ",
         layer_height / roof_slope, "mm per ", layer_height, "mm layer; one nozzle width is 0.4)"));
echo(str("  Plate A: springs r=", seat_ridge_r, " z=", pocket_depth_a,
         " -> crown r=", acr, " z=", acz, " -> post neck r=", support_post_neck_d / 2,
         ";  shell over crown ", dome_z_at_offset(2 * ellipse_bulge - acr) - acz, "mm"));
echo(str("  Plate B: springs r=", bearing_clearance_diameter / 2, " z=",
         pocket_depth_b + bearing_face_clearance, " -> crown r=", bcr, " z=", bcz,
         " -> shoulder r=", pin_shoulder_top_d / 2,
         ";  shell over crown ", dome_z_at_offset(2 * ellipse_bulge - bcr) - bcz, "mm"));
echo(str("  Plate A clearance to the SHIELD at r=9.5: ",
         (seat_ridge_r - 9.5) * roof_slope, "mm (outer race contact is harmless, A spins with it)"));
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
