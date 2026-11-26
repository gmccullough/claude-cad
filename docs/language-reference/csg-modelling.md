# OpenSCAD User Manual - CSG Modelling

> Source: [https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/CSG_Modelling](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/CSG_Modelling)

## Boolean Overview

### 2D Examples

| Operation | Description | Code |
|-----------|-------------|------|
| `union` (or) | circle + square | `union(){square(10);circle(10);}` |
| `difference` (and not) | square - circle | `difference(){square(10);circle(10);}` |
| `difference` (and not) | circle - square | `difference(){circle(10);square(10);}` |
| `intersection` (and) | circle and square overlap | `intersection(){square(10);circle(10);}` |

```openscad
union()       {square(10);circle(10);} // square or  circle
difference()  {square(10);circle(10);} // square and not circle
difference()  {circle(10);square(10);} // circle and not square
intersection(){square(10);circle(10);} // square and circle
```

### 3D Examples

| Operation | Description | Code |
|-----------|-------------|------|
| `union` (or) | sphere + cube | `union(){cube(12, center=true); sphere(8);}` |
| `difference` (and not) | cube - sphere | `difference(){cube(12, center=true); sphere(8);}` |
| `difference` (and not) | sphere - cube | `difference(){sphere(8); cube(12, center=true);}` |
| `intersection` (and) | cube and sphere overlap | `intersection(){cube(12, center=true); sphere(8);}` |

```openscad
union()       {cube(12, center=true); sphere(8);} // cube or  sphere
difference()  {cube(12, center=true); sphere(8);} // cube and not sphere
difference()  {sphere(8); cube(12, center=true);} // sphere and not cube
intersection(){cube(12, center=true); sphere(8);} // cube and sphere
```

## union

Creates a union of all its child nodes. This is the sum of all children (logical or).
May be used with either 2D or 3D objects, but don't mix them.

```openscad
union() {
    cylinder (h = 4, r=1, center = true, $fn=100);
    rotate ([90,0,0]) cylinder (h = 4, r=0.9, center = true, $fn=100);
}
```

**Remark:** `union` is implicit when not used. But it is mandatory, for example, in `difference` to group first child nodes into one.

**Important:** It is mandatory for all unions, explicit or implicit, that external faces to be merged not be coincident. Failure to follow this rule results in a design with undefined behavior, and can result in a render which is not manifold (with zero volume portions, or portions inside out), which typically leads to a warning and sometimes removal of a portion of the design from the rendered output. (This can also result in flickering effects during the preview.) This requirement is not a bug, but an intrinsic property of floating point comparisons and the fundamental inability to exactly represent irrational numbers such as those resulting from most rotations.

**Invalid example:**

```openscad
// Invalid!
size = 10;
rotation = 17;
union() {
    rotate([rotation, 0, 0])
        cube(size);
    rotate([rotation, 0, 0])
        translate([0, 0, size])
        cube([2, 3, 4]);
}
```

**Correct solution using epsilon overlap:**

```openscad
// Correct!
size = 10;
rotation = 17;
eps = 0.01;
union() {
    rotate([rotation, 0, 0])
        cube(size);
    rotate([rotation, 0, 0])
        translate([0, 0, size-eps])
        cube([2, 3, 4+eps]);
}
```

The solution is to always use a small value called an epsilon when merging adjacent faces to guarantee overlap. Note the `0.01` eps value used in TWO locations, so that the external result is equivalent to what was intended.

## difference

Subtracts the 2nd (and all further) child nodes from the first one (logical and not).
May be used with either 2D or 3D objects, but don't mix them.

```openscad
difference() {
    cylinder (h = 4, r=1, center = true, $fn=100);
    rotate ([90,0,0]) cylinder (h = 4, r=0.9, center = true, $fn=100);
}
```

**Important:** It is mandatory that surfaces that are to be removed by a difference operation have an overlap, and that the negative piece being removed extends fully outside of the volume it is removing that surface from. Failure to follow this rule can cause preview artifacts and can result in non-manifold render warnings or the removal of pieces from the render output. See the description above in union for why this is required and an example of how to do this by using a small epsilon value.

### difference with Multiple Children

Note, in the second instance, the result of adding a union of the 1st and 2nd children.

```openscad
$fn=90;
difference() {
                                            cylinder(r=5, h=20, center=true);
    rotate([00,140,-45]) color("LightBlue") cylinder(r=2, h=25, center=true);
    rotate([00,40,-50])                     cylinder(r=2, h=30, center=true);
    translate([0,0,-10]) rotate([00,40,-50]) cylinder(r=1.4, h=30, center=true);
}

// second instance with added union
translate([10,10,0]) {
    difference() {
        union() {        // combine 1st and 2nd children
                                                    cylinder(r=5, h=20, center=true);
            rotate([00,140,-45]) color("LightBlue") cylinder(r=2, h=25, center=true);
        }
        rotate([00,40,-50])                         cylinder(r=2, h=30, center=true);
        translate([0,0,-10]) rotate([00,40,-50])     cylinder(r=1.4, h=30, center=true);
    }
}
```

## intersection

Creates the intersection of all child nodes. This keeps the overlapping portion (logical and).
Only the area which is common or shared by all children is retained.
May be used with either 2D or 3D objects, but don't mix them.

```openscad
intersection() {
    cylinder (h = 4, r=1, center = true, $fn=100);
    rotate ([90,0,0]) cylinder (h = 4, r=0.9, center = true, $fn=100);
}
```

## render

> **Warning:** Using `render` always calculates the CSG model for this tree (even in OpenCSG preview mode). This can make previewing very slow and OpenSCAD to appear to hang/freeze.

```openscad
render(convexity = 1) { ... }
```

| Parameter | Description |
|-----------|-------------|
| `convexity` | Integer. The convexity parameter specifies the maximum number of front and back sides a ray intersecting the object might penetrate. This parameter is only needed for correctly displaying the object in OpenCSG preview mode and has no effect on the polyhedron rendering. |

A 2D shape with a convexity of 4 means a ray crosses the 2D shape a maximum of 4 times. The convexity of a 3D shape would be determined in a similar way. Setting it to 10 should work fine for most cases.
