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
//   - 6 magnets per plate at 60° intervals, 20mm from center
//   - Provide rotational snap/detent positions between the two plates
//
// DOME CLEARANCE:
//   - Bearing pocket is 3.2mm deep; dome peaks at ~4.5mm at center
//   - Thinnest shell above pocket: ~0.9mm at pocket edge, ~1.3mm at center

// === PREVIEW ===
cross_section = true;   // Set to false for full model
cross_section_z = 1.6;  // Midpoint of magnet pockets (pocket_floor_z=0.6 to pocket_top_z=2.6)
show_plate_a = true;     // Set to false to hide Plate A (press-fit side)
show_plate_b = true;     // Set to false to hide Plate B (pin side)

// === PARAMETERS ===
// Shape dimensions - three ellipses spanning triangle edges
vertex_radius = 30;      // Distance from center to the three points (virtual triangle vertices)
ellipse_bulge = 12;      // How much each ellipse bulges outward from edge (try 15-30)
                         // If bulge < vertex_radius/2 (20mm), center will have gap
center_fill = 12;        // Radius of center fill circle (needed if bulge is small)
total_height = 3.5;      // Total height of tile

// Dome parameters - dome sits on top, curves over magnet pockets
dome_start_z = 1.6;      // Dome begins curving from this height (lowered 1mm)
dome_height = 3.9;       // Height of dome section (extra 1mm for groove clearance)

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
magnet_distance = 20;  // Places magnets with ~3.9mm wall at vertices (30 - 23 - 3.1)

// Number of magnets (6 for snap positions at corners AND between corners)
num_magnets = 6;

// Bearing (608 style: 22mm OD, 8mm ID, 7mm height)
bearing_od = 22;
bearing_id = 8;
bearing_height = 7;

// Bearing pockets (open from flat/smooth bottom side)
bearing_press_diameter = 22;        // Plate A: exact OD for press fit
bearing_clearance_diameter = 23;    // Plate B: 1mm oversize for clearance
bearing_pocket_depth = 3.4;         // Depth on both sides
bearing_counterbore_diameter = 12;  // Clearance for inner race/balls to spin freely
bearing_counterbore_depth = 0.2;    // Shallow recess at pocket ceiling

// Axle pin (integrated into Plate B, rises from pocket floor)
pin_shoulder_diameter = 10;         // Wide base - bearing inner race sits on this
pin_shoulder_height = 0.2;          // Shoulder height
pin_shaft_diameter = 8;             // Match bearing ID exactly
pin_shaft_height = bearing_pocket_depth - pin_shoulder_height;  // Fills remaining pocket depth (2.7mm)

// Dome grooves - V-shaped radial channels cut into dome surface
groove_size = 2;                    // Diagonal of diamond cross-section (1mm deep, 2mm wide, 90° V)
groove_start_r = 0;                 // Start from center (dome peak)
groove_end_r = magnet_distance + pocket_diameter/2;  // Extend to magnet pocket edge
groove_angle = 6;                   // Downward tilt from peak to edges (degrees, ~5.7° follows dome slope)
groove_z = 6.5;  // Z height at center (default: dome peak)

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

// Main body with flat bottom, curved dome on top
module tri_body() {
    sphere_r = dome_sphere_radius(vertex_radius, dome_height);

    // Lower section (flat bottom to dome start) - straight walls
    linear_extrude(height = dome_start_z)
        three_ellipse_2d(vertex_radius, ellipse_bulge, center_fill);

    // Dome section - curved top created by sphere intersection
    translate([0, 0, dome_start_z])
    intersection() {
        // Ellipse prism for dome region
        linear_extrude(height = dome_height + 0.1)
            three_ellipse_2d(vertex_radius, ellipse_bulge, center_fill);

        // Large sphere positioned so it curves from flat at bottom to peak at center top
        translate([0, 0, -sphere_r + dome_height])
            sphere(r = sphere_r, $fn = 64);
    }
}

// Single magnet pocket - opens upward for drop-in during print pause
module magnet_pocket() {
    // Pocket extends from pocket_floor_z to pocket_top_z only (dome closes over)
    translate([0, 0, pocket_floor_z])
        cylinder(h = pocket_depth, d = pocket_diameter, $fn = 32);
}

// All magnet pockets arranged in pattern
// 6 magnets at 60° intervals for snapping at corners and between
module all_magnet_pockets() {
    for (i = [0:num_magnets-1]) {
        angle = 60 * i + 30;  // Offset by 30° to place between vertices
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

// === FINAL MODEL ===

// Plate A bearing pocket - press fit for outer race, with counterbore for inner race clearance
module bearing_pocket_press() {
    translate([0, 0, -0.1])
        cylinder(h = bearing_pocket_depth + 0.1, d = bearing_press_diameter, $fn = 256);
    // Counterbore at pocket ceiling - gives inner race/balls room to spin
    translate([0, 0, bearing_pocket_depth])
        cylinder(h = bearing_counterbore_depth, d = bearing_counterbore_diameter, $fn = 256);
}

// Plate B bearing pocket - clearance for outer race
module bearing_pocket_clearance() {
    translate([0, 0, -0.1])
        cylinder(h = bearing_pocket_depth + 0.1, d = bearing_clearance_diameter, $fn = 256);
}

// Axle pin - sits inside Plate B's bearing pocket, flush with surface
module axle_pin() {
    // Shaft first - bearing slides onto this from the open bottom
    cylinder(h = pin_shaft_height, d = pin_shaft_diameter, $fn = 256);
    // Wide shoulder at top - bearing inner race rests against this
    translate([0, 0, pin_shaft_height])
        cylinder(h = pin_shoulder_height, d = pin_shoulder_diameter, $fn = 256);
}

// Plate A - press fit side (bearing outer race press-fits into 22mm pocket)
module plate_a() {
    difference() {
        tri_body();
        all_magnet_pockets();
        bearing_pocket_press();
        dome_grooves();
    }
}

// Plate B - clearance side with integrated axle pin
module plate_b() {
    difference() {
        tri_body();
        all_magnet_pockets();
        bearing_pocket_clearance();
        dome_grooves();
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
echo(str("Magnet diameter: ", magnet_diameter, "mm"));
echo(str("Magnet pocket diameter: ", pocket_diameter, "mm"));
echo(str("Magnet pocket: z=", pocket_floor_z, " to z=", pocket_top_z, "mm"));
echo(str("Magnet distance from center: ", magnet_distance, "mm"));
echo(str("Wall at points: ", vertex_radius - magnet_distance - pocket_diameter/2, "mm"));
echo(str("Number of magnets per tile: ", num_magnets));
echo(str(">>> PAUSE HEIGHT: ", pocket_top_z, "mm  (insert magnets, glue, resume) <<<"));
echo(str("Bearing: ", bearing_od, "mm OD x ", bearing_id, "mm ID x ", bearing_height, "mm"));
echo(str("Plate A pocket: ", bearing_press_diameter, "mm dia x ", bearing_pocket_depth, "mm deep (press fit)"));
echo(str("Plate B pocket: ", bearing_clearance_diameter, "mm dia x ", bearing_pocket_depth, "mm deep (clearance)"));
echo(str("Axle pin: ", pin_shaft_diameter, "mm shaft on ", pin_shoulder_diameter, "mm x ", pin_shoulder_height, "mm shoulder"));
echo(str("Pin total height: ", pin_shoulder_height + pin_shaft_height, "mm (flush with pocket)"));
echo(str("Dome shell above pocket (center): ", dome_start_z + dome_height - bearing_pocket_depth, "mm"));
echo(str("Gap between plates: ", bearing_height + pin_shoulder_height - 2 * bearing_pocket_depth, "mm"));
