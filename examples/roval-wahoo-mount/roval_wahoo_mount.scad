// Roval cockpit out-front mount, v10: bracket + straight arm, bolt 15 deg nose-down,
// GoPro as two through-slots just behind the computer, prong tips standing proud.
// - Bar section TRACED from photos (section/: IMG_2551, held-out 2550, contour gauge 2584):
//   vertical face, a shoulder curving back into a top that rises to the rear, long shallow nose.
// - Bolt: M4 socket cap, 15 deg NOSE-DOWN, square to the bar surface at z ~7 (IMG_2586-2588: hex
//   key in the bolt, 13.5-15.3 deg; old mount's tab, IMG_2594: 15.4 deg off its arm; its back edge
//   matches our traced bar to 0.16 mm rms). Head pocket opens DOWNWARD only.
// - Arm: the top edge is ONE straight line from the bracket across the top of the Wahoo holder;
//   the underside slopes down from the holder to the bracket's bottom (a wedge, deep at the bar).
// Integrated Wahoo receiver. GoPro: the arm IS the 3-prong side: two rectangular slots straight
// through it (open top and bottom) and the thumbscrew horizontally through its side.
// Spec, photo-derived dimensions and confidence: AGENTS.md (this folder)
//
// The Wahoo quarter-turn receiver is NOT modelled here: extract_receiver.py cuts
// it from Wahoo's own Bolt 2 cradle into ref/wahoo_receiver.stl, grafted onto
// the head. Do not hand-model it.
//
// Side view through the bike centreline (bike moving to the right):
//
//       __shoulder (curves back)
//   bar|  ________________________________________________ top_z: one straight top edge
//      | |=bolt (15 deg down, z~7)=> head pocket          ( Wahoo head )
//      | |bracket    `-.__ underside slopes up to the head __/
//       \_ nose  shell     [GoPro: 2 through-slots + side screw, underside dips a little here]
//
// Coordinates: x=0 on the bar's front face, +X forward, +Y rider's left,
// z=0 at the old arm's underside where it met the bar (the old strap's bottom).

// === PREVIEW ===
part          = "mount";   // "mount" (arm + insert, assembled) | "arm" | "insert" | "gopro_coupon" | "insert_coupon" | "bar"
gopro         = true;      // keel + two accessory slots under the arm
cross_section = false;     // cut at y=0
show_bar      = false;     // ghost the bar in F5 preview

// === PARAMETERS ===  (~) = from photos, see AGENTS.md

// -- bar section at the centreline: TRACED (section/build_profile.py -> bar_profile.scad) --
// bar_pts (closed x-z polygon), bar_front (x as a function of z on the front), bar_top_z
// (18.4), bar_bot_z (-7.6). Front face vertical z 9.4-18.4; 3.5 mm back at z 0; long shallow
// lower nose (-6 at ~14 back). Scale +-4% (rule ticks). See AGENTS.md "Bar section, traced".
bar_w         = 60.0;   // modelled width of the straight centre section
bar_clear     = 0.25;   // mount-to-bar clearance

// -- bolt: 15 deg nose-down, square to the bar surface (IMG_2586-2588, 2594) --
bolt_tilt_deg = 15.0;   // (~) 13-17: key in the bolt 13.5/15.0/14.5; old tab 15.4 off its arm
bolt_z        = 7.0;    // (~) 6.2-7.5: where the traced surface faces 15 deg down; mid old tab
bolt_d        = 4.0;    // M4 socket cap (IMG_2587-2589)
slot_w        = 4.4;
slot_travel   = 2.0;    // +-1 along the bar face
slot_down     = 0.75;   // extra slot travel DOWNWARD only (as on the bike): more upward tilt for the
                        // second bike's bar (the designer, 2026-11-25: at the first bike's limit, too nose-down on the second; 1.5 was too much).
                        // The top end is unchanged, so every old position (and top_z) still works.
head_d        = 7.0;    // M4 socket cap head
wall_t        = 4.5;    // clamped wall thickness, along the bolt axis
top_skin      = 1.6;    // material over the head pocket (8 layers); sets top_z

// -- bracket: the arm itself, run back past the bar's face with the traced bar subtracted --
brk_bot       = 0.0;    // the underside slope passes z 0 at x ab_x0 (the old strap's bottom)
// underside style (2026-11-25, the designer: the gradual slope prints jagged):
//   "slope": v18, one ~8 deg line from the bar to the ring
//   "flat":  flat at flat_bot from the bar through the GoPro, then a step_deg step up to the ring.
//            flat_bot is set by the bar bolt: under the slot's lowest edge and the head's lowest seat.
underside     = "slope";
flat_bot      = 0.8;
step_deg      = 30;
arm_back_x    = -6.0;   // the arm runs back to here; the bar (+ clearance) is cut out of it

// -- receiver placement / arm --
reach_x       = 65.0;   // (~) bar face -> receiver centre
min_skin      = 0.4;    // at least 2 layers (0.2) of continuous floor under every cut in the insert
arm_w         = 16.0;   // ONE width from the bar to the ring (3.3 walls + 2 x 3.15 slots + 3.1 tang)
arm_chamfer   = 0.6;    // the same 45 deg chamfer on every top and bottom edge, arm and ring
seat_raise    = 1.0;    // the insert's seat stands this far proud of the arm's flat top

// -- Wahoo insert: a separate part, pushed UP through a ring at the end of the arm --
// Its flange bears on the ring's underside, so the computer pulling up on the receiver pulls the
// flange into the ring; glue only locates it. Printed seat-up; the arm prints top-down.
ins_wall      = 0.8;    // insert wall around the receiver (2 perimeters)
bore_clear    = 0.15;   // radial, insert body in the ring's bore
fl_over       = 1.5;    // flange overlap past the bore, bearing on the ring's underside
fl_t          = 1.6;    // flange thickness (8 layers); recessed flush into the ring's underside
cb_clear      = 0.15;   // flange in its counterbore
ring_wall     = 1.6;    // ring wall outside the counterbore: 4 perimeters (was 2.25; the designer: slimmer ring, 2026-11-23)
// locating ridge: ONE vertical triangular (45 deg flank) ridge on the insert's body, on the bar side
// (back), in a V-groove up the ring's bore. It replaces the flange's tongue (the designer: the underside is a
// clean circle, and the ridge guides the insert in from the start). One ridge = only one way in; a
// second, smaller front ridge was dropped as confusing (2026-11-23). Add more as [angle, height].
ridges        = [[180, 1.5]];   // [angle (0 = forward, 180 = back toward the bar), radial height]
ridge_clear   = 0.1;    // groove flanks offset from the ridge's (normal)
ridge_tip     = 0.3;    // groove runs this much deeper than the ridge tip (printed V tips round off)
ridge_lead    = 0.4;    // 45 deg flare at the groove's mouth
// INSERT-ONLY fit: grows the insert's body and flange (NOT the ring). The nominal 0.15
// radial clearance printed sloppy in the bore (large round fits print near nominal). 0.10 leaves
// 0.05 radial: TESTED 2026-11-23 (the designer: "the new insert tolerances are great").
ins_grow      = 0.10;

// -- receiver graft --
graft_r       = 15.8;
graft_depth   = 5.6;
head_round    = 0.8;    // insert's top edge rounding
finger_relief = 1.2;

// -- GoPro: the arm IS the 3-prong side --
// Two slots straight through the arm (open top and bottom); the web between them and the
// two side walls are the 3 prongs; the thumbscrew goes horizontally through the side.
// The middle prong (web) only acts as a washer for the thumbscrew to squash into: the bolt's
// head pocket runs straight on through it (the designer), so it's only material around the screw.
// The prong tips stand proud of the top, just behind the computer's rear edge.
gp_tip_gap    = 2.5;    // the proud prong tips end this far behind the computer's rear edge
// Fit: our outer prongs are the arm's own walls (fixed top and bottom), so unlike a normal GoPro
// mount they can't flex in to take up play: the fit has to come from the dimensions. Accessory:
// 2 prongs x 3.0 with a ~3.2 gap (9.2 across). v16 had 3.4 + 3.0 + 3.4 = 9.8 (0.6 play, sloppy).
// Tune with part="gopro_coupon" (build_gopro_coupons.py prints slot widths 3.05/3.15/3.25).
gp_slot_w     = 3.05;   // coupons picked 3.15, but on the bike 3.15 felt sloppy: -0.1 (the designer, 2026-11-23)
gp_web        = 3.1;    // middle prong, into the accessory's ~3.2 gap
gp_tip_r      = 7.8;    // accessory prong tip radius 7.5 + clearance: slot half-length
gp_hole_d     = 5.3;    // M5 GoPro thumbscrew
gp_skin_above = 1.6;    // wall material above the screw hole (sets the screw height)
gp_wall_below = 1.6;    // wall material below the screw hole (sets the arm's depth there)
// captive nut: a shallow hex recess sunk into one outer wall (no boss); the nut sits partly in it
nut_af        = 8.0;    // M5 nut across flats
nut_clear     = 0.2;    // added to the across-flats
nut_depth     = 1.5;    // recess depth into the 3.1 wall (1.6 left to the slot)
nut_side      = -1;     // -1 = rider's right (-Y), +1 = left
// -- computer: Wahoo ELEMNT BOLT V2 (IMG_2599, rule from its rear end): the boss's rear tang
// is 20 mm from the rear end and the boss centre ~34 mm --
device_rear_x = 65.0 - 34.0;   // = 31: the rear edge, 34 behind the receiver centre

// -- bolt access --
bolt_len      = 12.0;   // (~) shank length: the pocket must take bolt + head along the axis

eps = 0.01;
$fn = 64;

include <section/bar_profile.scad>

// === DERIVED ===
// bolt: on the traced surface, axis forward-down by bolt_tilt_deg
function front_x(z) = lookup(z, bar_front);
phi      = -bolt_tilt_deg;
P        = [front_x(bolt_z), bolt_z];
bolt_tilt = bolt_tilt_deg;
W        = P + wall_t * [cos(phi), sin(phi)];   // head seat (wall front face) centre
// one flat top for bracket, arm and seat: high enough to cover the head pocket where it's
// highest (at the head seat: the axis falls away forward)
// snapped UP to the 0.2 layer grid, so the flat top (and the seat above it) are whole layers:
// the show face prints as a full, ironed top layer instead of a rounded-down partial one
top_z    = ceil((W[1] + (slot_travel / 2 + (head_d + 1.0) / 2) * cos(bolt_tilt) + top_skin) / 0.2) * 0.2;
seat_z   = top_z + seat_raise;            // the insert's seat (the computer sits here)
deepest_cut = 5.45 + finger_relief;       // floor underside + finger relief, below the seat
ring_x   = reach_x;
ins_r    = graft_r + ins_wall;            // insert body radius
bore_r   = ins_r + bore_clear;
fl_r     = ins_r + fl_over;               // flange radius
ring_r   = fl_r + cb_clear + ring_wall;   // the ring's outer radius
head_r   = ring_r;                        // (the end of the arm is now the ring)
floor_z  = seat_z - 5.45;
// GoPro station: screw as high as the skin above its hole allows; underside just below the hole
nut_half = (nut_af + nut_clear) / 2;       // hex lies flats top/bottom: half its height
gp_z     = top_z - max(gp_skin_above + gp_hole_d / 2, nut_half + min_skin);
// screw x: the proud part of the prong tips ends gp_tip_gap behind the computer's rear edge
gp_x     = device_rear_x - gp_tip_gap - sqrt(gp_tip_r * gp_tip_r - (top_z - gp_z) * (top_z - gp_z));
gp_bot   = gp_z - max(gp_hole_d / 2 + gp_wall_below, nut_half + min_skin);
gp_x0    = gp_x - gp_tip_r - 1;   gp_x1 = gp_x + gp_tip_r + 1;   // flat-bottomed station
// arm underside: ONE straight slope from the bracket's bottom at the bar to the ring's flat underside
// (the designer: the GoPro and light both clear a line like this). The slope is set by the tightest point,
// the end of the captive nut's bottom flat, which needs min_skin under it.
ab_x0  = 0.5;
x_flat = ring_x - fl_r - cb_clear - 1.0;   // flat from just before the flange's counterbore
gp_xg  = gp_x + (nut_af + nut_clear) / (2 * sqrt(3));   // far end of the nut's bottom flat
gp_zg  = gp_z - nut_half - min_skin;                    // underside must be at or below this there
sl_k   = (gp_zg - brk_bot) / (gp_xg - ab_x0);           // slope
function sl_at(x) = brk_bot + sl_k * (x - ab_x0);
// the ring's flat underside: the receiver's depth + 2 layers below the seat, or lower if the slope
// hasn't reached it by x_flat; on the 0.2 layer grid
head_bot = floor(min(seat_z - ceil((deepest_cut + min_skin) / 0.2) * 0.2, sl_at(x_flat)) / 0.2) * 0.2;
head_depth = seat_z - head_bot;           // insert height
// x_knee: where the underside leaves its back (bar-side) run; x_meet: where it reaches the ring's flat
x_meet = underside == "flat" ? x_flat : ab_x0 + (head_bot - brk_bot) / sl_k;
x_knee = underside == "flat" ? x_flat - (head_bot - flat_bot) / tan(step_deg) : x_meet;
function arm_bot_at(x) = underside == "flat"
    ? (x <= x_knee ? flat_bot : min(head_bot, flat_bot + (x - x_knee) * tan(step_deg)))
    : min(sl_at(x), head_bot);                          // the slope runs straight back to the bar too


// === MODULES ===
module bar2d() { polygon(bar_pts); }      // x-z section, traced (bar_profile.scad)
module xz(w) { rotate([90, 0, 0]) linear_extrude(w, center = true) children(); }
module bar3d(grow = 0) { xz(bar_w) offset(r = grow) bar2d(); }

module rrect2(w, z0, z1, r) {
    hull() for (y = [-w/2 + r, w/2 - r], z = [z0 + r, z1 - r]) translate([y, z]) circle(r = r, $fn = 24);
}
module yz_slab(x) { translate([x, 0, 0]) rotate([90, 0, 90]) linear_extrude(0.2, center = true) children(); }
// the one arm section: a rectangle with the same 45 deg chamfer c on all four corners
module sec2d(w, z0, z1, c) {
    polygon([[-w/2, z0 + c], [-w/2 + c, z0], [w/2 - c, z0], [w/2, z0 + c],
             [w/2, z1 - c], [w/2 - c, z1], [-w/2 + c, z1], [-w/2, z1 - c]]);
}
// arm cross-section at x: full height from the local underside up to the flat top
module arm_sec(x) { yz_slab(x) sec2d(arm_w, arm_bot_at(x), top_z, arm_chamfer); }

// the ring at the end of the arm: flat top and underside, the same chamfer on both edges
module ring_body() {
    c = arm_chamfer;
    translate([ring_x, 0, 0]) hull() {
        translate([0, 0, head_bot]) cylinder(h = 0.01, r = ring_r - c, $fn = 128);
        translate([0, 0, head_bot + c]) cylinder(h = top_z - head_bot - 2 * c, r = ring_r, $fn = 128);
        translate([0, 0, top_z - 0.01]) cylinder(h = 0.01, r = ring_r - c, $fn = 128);
    }
}
// the insert's flange outline (2D, about the ring centre): a plain disc
module flange2d(grow = 0) { circle(r = fl_r + grow, $fn = 128); }

// locating ridges (2D, about the ring centre): a 45 deg triangle standing h off radius r0 at angle a
// (0 = forward, 180 = back toward the bar), rooted 0.5 into the body
function ridge_hh(i) = ridges[i][1];
module ridge2d(i, r0) {
    h = ridge_hh(i);
    rotate(ridges[i][0]) polygon([[r0 - 0.5, -(h + 0.5)], [r0 + h, 0], [r0 - 0.5, h + 0.5]]);
}
module groove2d(i, r0, extra = 0) {
    h = ridge_hh(i);
    offset(delta = extra) hull() {
        offset(delta = ridge_clear) ridge2d(i, r0);
        rotate(ridges[i][0]) translate([r0 + h + ridge_clear * sqrt(2) + ridge_tip, 0]) circle(r = 0.01);
    }
}
ridge_z0   = head_bot + fl_t;            // ridges stand on the flange
groove_z1  = top_z - min_skin;           // grooves stop under 2 layers: the ring's top stays clean
ridge_z1   = groove_z1 - 0.2;            // ridge tips (45 deg roof)

// bracket: the arm's own section, run back past the bar's face; the traced bar (+ clearance)
// is subtracted in mount(), so the arm meets the bar in one continuous surface from z 0 to the top

// the arm: ONE constant section swept straight from behind the bar's face to where the slope meets
// the ring's flat, then blended tangent into the ring
module arm_body() {
    hull() { arm_sec(arm_back_x); arm_sec(x_knee); }
    hull() { arm_sec(x_knee); arm_sec(x_meet); }
    hull() { arm_sec(x_meet); ring_body(); }
}
// where the insert goes: the bore, the flange's counterbore in the underside, the ridge grooves
module insert_cuts() {
    translate([ring_x, 0, head_bot - 1]) cylinder(h = top_z - head_bot + 2, r = bore_r, $fn = 128);
    translate([0, 0, head_bot - 1]) linear_extrude(fl_t + 1)
        translate([ring_x, 0]) flange2d(cb_clear);
    // grooves from the counterbore's ceiling up, with a flared mouth (guides the ridge tips in)
    for (i = [0 : len(ridges) - 1]) translate([ring_x, 0, 0]) {
        translate([0, 0, ridge_z0 - 0.01]) linear_extrude(groove_z1 - ridge_z0 + 0.01) groove2d(i, ins_r + ins_grow);
        hull() {
            translate([0, 0, ridge_z0 - 0.01]) linear_extrude(0.01) groove2d(i, ins_r + ins_grow, ridge_lead);
            translate([0, 0, ridge_z0 + ridge_lead]) linear_extrude(0.01) groove2d(i, ins_r + ins_grow);
        }
    }
}

// place children on the bolt axis: origin at P, +Z along the axis (forward-down by bolt_tilt)
module on_bolt() { translate([P[0], 0, P[1]]) rotate([0, 90 + bolt_tilt, 0]) children(); }

module bolt_cuts() {
    // slot through the wall, elongated along the bar face
    on_bolt() hull() for (s = [-slot_travel / 2, slot_travel / 2 + slot_down])   // local +x = down the face
        translate([s, 0, -10]) cylinder(h = wall_t + 11, d = slot_w, $fn = 32);
    // ONE continuous channel under the arm, as wide as the GoPro slot pair, open to the bottom:
    // from the bolt head's flat seat (square to the bolt) forward to the end of the GoPro slots.
    // Its ceiling runs parallel to the bolt axis down from the head pocket, levels off at the GoPro
    // screw axis and runs flat to the end, so the middle tang is a bar hanging from the top with
    // a half-round notch where the screw passes.
    xz(2 * ch_hw) polygon(ch_pts);
}

// channel outline (x-z), about the bolt axis: d = axis direction, u = perpendicular, up/back
ch_hw  = gp_web / 2 + gp_slot_w;             // half-width: the GoPro slot pair
ch_d   = [cos(-bolt_tilt), sin(-bolt_tilt)];
ch_u   = [sin(bolt_tilt), cos(bolt_tilt)];
ch_r   = (head_d + 1.0) / 2 + slot_travel / 2;  // head clearance + travel, either side of the axis
ch_c0  = W + ch_r * ch_u;                     // top of the head seat
ch_s0  = W - (ch_r + slot_down) * ch_u;       // bottom of the head seat (covers the slot's extra travel down)
ch_t1  = (ch_c0[1] - gp_z) / sin(bolt_tilt);  // along the axis until the ceiling reaches gp_z
ch_c1  = ch_c0 + ch_t1 * ch_d;
ch_x2  = gp_x + gp_tip_r;
ch_pts = [[ch_s0[0], -50], ch_s0, ch_c0, ch_c1, [ch_x2, gp_z], [ch_x2, -50]];

// GoPro: two rectangular slots straight through the arm, and the screw through its side
module gopro_cuts() {
    for (sy = [-1, 1])
        translate([gp_x - gp_tip_r, sy * (gp_web / 2 + gp_slot_w / 2) - gp_slot_w / 2, -50])
            cube([2 * gp_tip_r, gp_slot_w, 100]);
    translate([gp_x, 0, gp_z]) rotate([90, 0, 0]) cylinder(h = 40, d = gp_hole_d, center = true, $fn = 32);
    // captive-nut hex recess, flats top and bottom, sunk nut_depth into the outer wall
    translate([gp_x, nut_side * (arm_w / 2 - nut_depth), gp_z])
        rotate([nut_side < 0 ? 90 : -90, 0, 0])
            cylinder(h = nut_depth + 2, r = (nut_af + nut_clear) / sqrt(3), $fn = 6);
}

module graft_space(grow = 0) { translate([ring_x, 0, seat_z - graft_depth]) cylinder(h = graft_depth + 1, r = graft_r + grow, $fn = 96); }
module finger_relief_space() {
    translate([ring_x, 0, floor_z - finger_relief]) intersection() {
        cylinder(h = finger_relief + eps, r = graft_r - 0.6);
        translate([-14, -7.5, 0]) cube([28, 15, finger_relief + eps]);
    }
}
module receiver_graft() {
    intersection() {
        translate([ring_x, 0, seat_z]) import("ref/wahoo_receiver.stl", convexity = 10);
        graft_space();
    }
}

// the arm: one part, printed top-down (its flat top on the bed)
module arm() {
    difference() {
        intersection() {
            arm_body();
            translate([-200, -200, -200]) cube([400, 400, 200 + top_z]);
        }
        bar3d(bar_clear);
        bolt_cuts();
        if (gopro) gopro_cuts();
        insert_cuts();
    }
}

// the Wahoo insert: body up through the ring to the seat, a round flange below, two locating ridges.
// Printed seat-up (flange on the bed). Modelled in place (assembled position).
module insert() {
    g = ins_grow;
    difference() {
        union() {
            translate([ring_x, 0, 0]) hull() {
                translate([0, 0, head_bot]) cylinder(h = 0.01, r = ins_r + g, $fn = 128);
                translate([0, 0, seat_z - head_round])
                    rotate_extrude($fn = 128) translate([ins_r + g - head_round, 0]) circle(r = head_round, $fn = 16);
            }
            translate([0, 0, head_bot]) linear_extrude(fl_t) translate([ring_x, 0]) flange2d(g);
            insert_ridges();
        }
        graft_space();
        finger_relief_space();
    }
    receiver_graft();
}

// fit test for the insert in a printed ring: the flange, the ridges' lower part and the first
// 3 mm of the body, as thin rings (no receiver); printed flange-down like the insert
// the ridges on the insert's body (surface radius ins_r + ins_grow), with a 45 deg roof at the top
module insert_ridges() {
    for (i = [0 : len(ridges) - 1]) translate([ring_x, 0, 0]) hull() {
        translate([0, 0, ridge_z0 - 0.01]) linear_extrude(ridge_z1 - ridge_hh(i) - ridge_z0 + 0.01)
            ridge2d(i, ins_r + ins_grow);
        translate([0, 0, ridge_z1 - 0.01]) linear_extrude(0.01)
            intersection() { ridge2d(i, ins_r + ins_grow); rotate(ridges[i][0]) translate([0, -5]) square([ins_r + ins_grow, 10]); }
    }
}

module insert_coupon() {
    g = ins_grow; t = 1.6; h = 3.0;
    translate([-ring_x, 0, -head_bot]) {
        difference() {
            union() {
                translate([0, 0, head_bot]) linear_extrude(fl_t) translate([ring_x, 0]) flange2d(g);
                translate([ring_x, 0, head_bot]) cylinder(h = fl_t + h, r = ins_r + g, $fn = 128);
            }
            translate([ring_x, 0, head_bot - 1]) cylinder(h = fl_t + h + 2, r = ins_r + g - t, $fn = 128);
        }
        intersection() { insert_ridges(); translate([0, 0, head_bot]) cylinder(h = fl_t + h, r = 100); }
    }
}

module mount() { arm(); insert(); }

// fit test: just the GoPro station of the arm (slots, tang, screw hole, nut recess), printed
// top-down like the arm
module gopro_coupon() {
    translate([-gp_x, 0, 0]) intersection() {
        arm();
        translate([gp_x - gp_tip_r - 2.5, -20, -10]) cube([2 * gp_tip_r + 5, 40, 40]);
    }
}

// === RENDER ===
difference() {
    if (part == "mount") mount();
    else if (part == "arm") arm();
    else if (part == "insert") insert();
    else if (part == "gopro_coupon") gopro_coupon();
    else if (part == "insert_coupon") insert_coupon();
    else if (part == "bar") bar3d();
    if (cross_section) translate([-100, 0, -100]) cube([300, 100, 200]);
}
if (show_bar && part == "mount") %bar3d();

// === INFO ===
// tip stiffness of a tapered cantilever, approximated by the section at mid-span
mid_x  = (ab_x0 + ring_x - head_r) / 2;
h_mid  = top_z - arm_bot_at(mid_x);
I_arm  = arm_w * pow(h_mid, 3) / 12;
k_arm  = 3 * 2000 * I_arm / pow(ring_x - ab_x0, 3);
// keys from the head seat W: straight along the axis, or a ball end up to 25 deg steeper
function key_z_at(x, a) = W[1] - (x - W[0]) * tan(a);
echo(str("bolt (M", bolt_d, ", ", bolt_tilt, " deg nose-down) at x=", P[0], " z=", P[1], "; head seat at ", W,
         "; top_z ", top_z, " (skin over the head pocket ", top_z - W[1] - (slot_travel / 2 + (head_d + 1.0) / 2) * cos(bolt_tilt), ")"));
echo(str("insert: body r ", ins_r, " up through a bore r ", bore_r, " to the seat at z ", seat_z, " (", seat_raise,
         " proud); ", head_depth, " tall (receiver needs ", deepest_cut, " + skin); flange r ", fl_r, " x ", fl_t,
         " flush in the underside (bears ", fl_over, " on the ring)"));
echo(str("ridge(s) [angle, height]: ", ridges, " (45 deg), z ", ridge_z0, "..", ridge_z1,
         "; grooves to z ", groove_z1, " (", top_z - groove_z1, " under the top), flank clearance ", ridge_clear,
         "; engage after ", seat_z - ridge_z1, " of insertion"));
echo(str("ring: outer r ", ring_r, " (", 2 * ring_r, " across), wall ", ring_wall, " outside the counterbore; flat underside at z ", head_bot));
echo(str("arm: top flat at z ", top_z, "; underside from z ", brk_bot, " at the bar to ", head_bot,
         " under the head; ", h_mid, " deep at mid-span"));
pocket_end_x = ch_x2;
tip_up   = gp_z + gp_tip_r - top_z;                      // how far the prong tips stand proud
tip_half = tip_up > 0 ? sqrt(gp_tip_r * gp_tip_r - (top_z - gp_z) * (top_z - gp_z)) : 0;
echo(str("GoPro: screw axis x=", gp_x, " z=", gp_z, "; slots x ", gp_x - gp_tip_r, "..", gp_x + gp_tip_r,
         " through the arm; underside under the screw z ", arm_bot_at(gp_x), " (arm ", top_z - arm_bot_at(gp_x), " deep)"));
echo(str("GoPro walls (tangs) deep: slot back end x ", gp_x - gp_tip_r, " ", top_z - arm_bot_at(gp_x - gp_tip_r),
         ", screw ", top_z - arm_bot_at(gp_x), ", slot front end x ", gp_x + gp_tip_r, " ", top_z - arm_bot_at(gp_x + gp_tip_r),
         "; screw axis to underside ", gp_z - arm_bot_at(gp_x - gp_tip_r), "..", gp_z - arm_bot_at(gp_x + gp_tip_r)));
if (underside == "flat") echo(str("underside: FLAT at z ", flat_bot, " from the bar to x ", x_knee, ", then ", step_deg,
         " deg up to the ring's flat z ", head_bot, " at x ", x_meet, "; bar end ", top_z - flat_bot, " tall"));
else echo(str("underside: one slope ", atan(sl_k), " deg from z ", brk_bot, " at x ", ab_x0, " to the ring's flat z ", head_bot,
         " at x ", x_meet, " (flat needed from x ", x_flat, "); nut-flat end x ", gp_xg, " needs <= ", gp_zg));
echo(str("channel: ", 2 * ch_hw, " wide, head seat at x ", ch_s0[0], "..", ch_c0[0], ", ceiling ", ch_c0[1],
         " (skin ", top_z - ch_c0[1], ") down along the axis to z ", gp_z, " at x ", ch_c1[0], ", flat to x ", ch_x2));
echo(str("captive nut: ", nut_af, " AF hex recess ", nut_depth, " deep in the ", nut_side < 0 ? "right (-Y)" : "left (+Y)",
         " wall; ", arm_w / 2 - gp_web / 2 - gp_slot_w - nut_depth, " left to the slot; skin above ",
         top_z - gp_z - nut_half, ", below ", gp_z - nut_half - gp_bot));
echo(str("prong tips stand ", tip_up, " proud from x ", gp_x - tip_half, " to ", gp_x + tip_half,
         "; computer rear edge ~x ", device_rear_x, " -> ", device_rear_x - gp_x - tip_half, " clear"));
echo(str("key at the GoPro (x ", gp_x - gp_tip_r, "): straight along the axis z ", key_z_at(gp_x - gp_tip_r, bolt_tilt),
         ", ball end +25 deg z ", key_z_at(gp_x - gp_tip_r, bolt_tilt + 25), "; arm underside ", gp_bot));
echo(str("arm tip stiffness ~", k_arm, " N/mm (PETG E 2000)"));
