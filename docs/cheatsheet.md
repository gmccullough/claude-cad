# OpenSCAD CheatSheet (v2021.01)

> **Source:** <https://openscad.org/cheatsheet/index.html>

## Syntax

```openscad
var = value;
var = cond ? value_if_true : value_if_false;
var = function (x) x + x;
module name(...) { ... }   name();
function name(...) = ...   name();
include <....scad>
use <....scad>
```

## Constants

| Constant | Description |
|----------|-------------|
| `undef` | Undefined value |
| `PI` | Mathematical constant pi (~3.14159) |

## Operators

### Arithmetic

- `n + m` -- Addition
- `n - m` -- Subtraction
- `n * m` -- Multiplication
- `n / m` -- Division
- `n % m` -- Modulo
- `n ^ m` -- Exponentiation

### Relational

- `n < m` -- Less Than
- `n <= m` -- Less or Equal
- `b == c` -- Equal
- `b != c` -- Not Equal
- `n >= m` -- Greater or Equal
- `n > m` -- Greater Than

### Logical

- `b && c` -- Logical And
- `b || c` -- Logical Or
- `!b` -- Negation

## Special Variables

| Variable | Purpose |
|----------|---------|
| `$fa` | Minimum angle |
| `$fs` | Minimum size |
| `$fn` | Number of fragments |
| `$t` | Animation step |
| `$vpr` | Viewport rotation angles (degrees) |
| `$vpt` | Viewport translation |
| `$vpd` | Viewport camera distance |
| `$vpf` | Viewport camera field of view |
| `$children` | Number of module children |
| `$preview` | True in F5 preview, false for F6 |

## Modifier Characters

- `*` -- Disable
- `!` -- Show only
- `#` -- Highlight / debug
- `%` -- Transparent / background

## 2D Primitives

```openscad
circle(radius | d=diameter)
square(size, center)
square([width, height], center)
polygon([points])
polygon([points], [paths])
text(t, size, font, halign, valign, spacing, direction, language, script)
import("....ext formats: DXF|SVG", convexity)
projection(cut)
```

## 3D Primitives

```openscad
sphere(radius | d=diameter)
cube(size, center)
cube([width, depth, height], center)
cylinder(h, r|d, center)
cylinder(h, r1|d1, r2|d2, center)
polyhedron(points, faces, convexity)
import("....ext formats: STL|OFF|AMF|3MF", convexity)
linear_extrude(height, center, convexity, twist, slices)
rotate_extrude(angle, convexity)
surface(file = "....ext formats: DAT|PNG", center, convexity)
```

## Transformations

```openscad
translate([x, y, z])
rotate([x, y, z])
rotate(a, [x, y, z])
scale([x, y, z])
resize([x, y, z], auto, convexity)
mirror([x, y, z])
multmatrix(m)
color("colorname", alpha)
color("#hexvalue #rgb|#rgba|#rrggbb|#rrggbbaa")
color([r, g, b, a])
offset(r|delta, chamfer)
hull()
minkowski(convexity)
```

## Lists

```openscad
list = [..., ..., ...];           // Create a list
var = list[2];                    // Index a list (from 0)
var = list.z;                     // Dot notation indexing (x/y/z)
```

## Boolean Operations

```openscad
union()
difference()
intersection()
```

## List Comprehensions

```openscad
[ for (i = range|list) i ]                           // Generate
[ each i ]                                            // Flatten
[ for (i = ...) if (condition(i)) i ]                 // Conditions
[ for (i = ...) if (condition(i)) x else y ]          // Conditions
[ for (i = ...) let (assignments) a ]                 // Assignments
```

## Flow Control

```openscad
for (i = [start:end]) { ... }
for (i = [start:step:end]) { ... }
for (i = [..., ..., ...]) { ... }
for (i = ..., j = ..., ...) { ... }
intersection_for(i = [start:end]) { ... }
intersection_for(i = [start:step:end]) { ... }
intersection_for(i = [..., ..., ...]) { ... }
if (...) { ... }
let (...) { ... }
```

## Type Test Functions

- `is_undef`
- `is_bool`
- `is_num`
- `is_string`
- `is_list`
- `is_function`

## Other Functions

```openscad
echo(...)
render(convexity)
children([idx])
assert(condition, message)
assign (...) { ... }
```

## String and Utility Functions

- `concat`
- `lookup`
- `str`
- `chr`
- `ord`
- `search`
- `version`
- `version_num`
- `parent_module(idx)`

## Mathematical Functions

- `abs`, `sign`
- `sin`, `cos`, `tan`
- `acos`, `asin`, `atan`, `atan2`
- `floor`, `round`, `ceil`
- `ln`, `log`, `pow`, `sqrt`, `exp`
- `len`, `let`
- `rands`
- `min`, `max`
- `norm`, `cross`

---

**Links:** [Official website](https://openscad.org/) | [Manual](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual) | [GitHub](https://github.com/openscad/openscad)

*By Peter Uithoven @ Fablab Amersfoort (CC-BY)*
