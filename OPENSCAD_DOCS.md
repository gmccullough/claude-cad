# OpenSCAD Language Reference — Key Features & Hidden Gems

Local documentation mirror: `docs/` (from [openscad.org/documentation](https://openscad.org/documentation.html))

## New / Recent Features

### Objects (Dictionaries)
Proper key-value maps. Copy-and-modify pattern, computed keys, iteration.
```openscad
o = object(a = 1, b = "hello");
o2 = object(o, c = 42);           // copy-and-modify
o3 = object([for (i=[1:3]) [str("x",i), i*i]]);  // computed keys
for (name = o) echo(name, o[name]);               // iterate
```
See: [docs/language-reference/general.md](docs/language-reference/general.md)

### Function Literals (Lambdas) — 2021.01+
First-class functions. Pass as arguments, return from functions, store in variables.
```openscad
func = function (x) x * x;
echo(func(5));  // 25
```
See: [docs/language-reference/user-defined-functions-and-modules.md](docs/language-reference/user-defined-functions-and-modules.md)

### textmetrics() / fontmetrics()
Query exact text dimensions before rendering. No more guessing sizes.
```openscad
tm = textmetrics("Hello", size=20, font="Liberation Serif");
echo(tm.size);      // [width, height]
echo(tm.advance);   // where next character would go
translate(tm.position) square(tm.size);  // perfectly-sized background
```
See: [docs/language-reference/text.md](docs/language-reference/text.md)

### fill()
Removes internal holes from 2D shapes (letters like O, D, A).
```openscad
linear_extrude(2) offset(4) fill() text("OpenSCAD", 50);
```
See: [docs/language-reference/transformations.md](docs/language-reference/transformations.md)

### JSON Import
Data-driven designs from external files.
```openscad
t = import("data.json");
echo(t.people[0].name);
```
See: [docs/language-reference/importing-geometry.md](docs/language-reference/importing-geometry.md)

### rotate_extrude with angle — 2019.05+
Partial sweeps for hooks, arcs, pipe elbows.
```openscad
rotate_extrude(angle=270) translate([40,0]) circle(10);
```
See: [docs/language-reference/2d-to-3d-extrusion.md](docs/language-reference/2d-to-3d-extrusion.md)

### linear_extrude with vector scale
Non-uniform scaling during extrusion. Blade profiles, flared shapes.
```openscad
linear_extrude(height=10, scale=[1,5]) circle(r=1);
```
See: [docs/language-reference/2d-to-3d-extrusion.md](docs/language-reference/2d-to-3d-extrusion.md)

### Manifold Backend
Dramatically faster geometry engine. Use `--backend Manifold` on the CLI.

See: [docs/user-manual/command-line.md](docs/user-manual/command-line.md)

### Binary / Bitwise Operators
`|`, `&`, `<<`, `>>`, `~` and exponent `^` operator.

See: [docs/language-reference/mathematical-operators.md](docs/language-reference/mathematical-operators.md)

---

## Non-Obvious Power Techniques

### C-style For in List Comprehensions
Stateful iteration — carry values across iterations without recursion.
```openscad
// Fibonacci:
echo([for (a=0, b=1; a<1000; x=a+b, a=b, b=x) a]);

// Cumulative sum:
function cumsum(v) = [for (a=v[0]-v[0], i=0; i<len(v); a=a+v[i], i=i+1) a+v[i]];
```
See: [docs/language-reference/list-comprehensions.md](docs/language-reference/list-comprehensions.md)

### `each` for Flattening
Mix ranges and individual values into a single flat list.
```openscad
A = [-2, each [1:2:5], each [6:-2:0], -1];  // [-2,1,3,5,6,4,2,0,-1]
```
See: [docs/language-reference/list-comprehensions.md](docs/language-reference/list-comprehensions.md)

### 2D Offset Fillet / Round
Double-offset for rounded corners without computing arcs.
```openscad
offset(r=-3) offset(delta=+3) polygon(pts);  // fillet concave corners
offset(r=+3) offset(delta=-3) polygon(pts);  // round convex corners
offset(-r) offset(r) offset(r) offset(-r) polygon(pts);  // round ALL corners
```
See: [docs/language-reference/transformations.md](docs/language-reference/transformations.md)

### Hull Chaining for Smooth Lofts
Hull consecutive cross-section pairs for organic shapes.
```openscad
for (i = [1:18])
    hull() {
        translate([0,0,i])   cylinder(.1, d1=10*sin(i*9));
        translate([0,0,i+1]) cylinder(.1, d1=10*sin((i+1)*9));
    }
```
See: [docs/user-manual/tips-and-tricks.md](docs/user-manual/tips-and-tricks.md)

### multmatrix for Skewing/Shearing
The only way to do shearing transforms.
```openscad
M = [[1,0,0,0], [0,1,0.7,0], [0,0,1,0], [0,0,0,1]];
multmatrix(M) cylinder(r=10, h=10);
```
See: [docs/language-reference/transformations.md](docs/language-reference/transformations.md)

### $preview for Dual-Purpose Scripts
Different geometry for F5 preview vs F6 render.
```openscad
$fn = $preview ? 32 : 128;
if ($preview) assembled_view(); else print_plate_layout();
```
See: [docs/language-reference/other-language-features.md](docs/language-reference/other-language-features.md)

### Dynamic Scoping with $-Variables
`$`-prefixed variables propagate through the entire call stack. Use for context without threading parameters.
```openscad
$exploded = true;
my_assembly();  // every sub-module can read $exploded
```
See: [docs/language-reference/other-language-features.md](docs/language-reference/other-language-features.md)

### Echo as Expression (Inline Debugging)
Debug without disrupting data flow — prints before evaluating.
```openscad
r = echo("computing:", a, b) a * b;
```
See: [docs/language-reference/other-language-features.md](docs/language-reference/other-language-features.md)

### Tail Recursion Elimination
Tail-recursive functions support up to 1,000,000 depth (vs ~3,000 normal).
```openscad
// Tail-recursive (accumulator pattern):
function sum(n, acc=0) = n==0 ? acc : sum(n-1, acc+n);
```
See: [docs/language-reference/user-defined-functions-and-modules.md](docs/language-reference/user-defined-functions-and-modules.md)

### Projection for Cross-Sections
Get 2D slices or shadow outlines from 3D geometry.
```openscad
projection(cut=true) translate([0,0,-5]) my_model();   // cross-section
projection(cut=false) my_model();                       // shadow outline
```
See: [docs/language-reference/3d-to-2d-projection.md](docs/language-reference/3d-to-2d-projection.md)

### Surface from PNG Heightmaps
Lithophanes, terrain, grip textures from grayscale images.
```openscad
scale([1, 1, 0.1]) surface(file = "terrain.png", center = true);
```
See: [docs/language-reference/other-language-features.md](docs/language-reference/other-language-features.md)

### intersection_for()
Intersect (not union) across loop iterations. Creates gem/crystal shapes.
```openscad
intersection_for(n = [1:6])
    rotate([0,0,n*60]) translate([5,0,0]) sphere(r=12);
```
See: [docs/language-reference/conditional-and-iterator-functions.md](docs/language-reference/conditional-and-iterator-functions.md)

### resize with auto
Proportional scaling to a target dimension.
```openscad
resize([7, 0, 0], auto=true) cube([1, 2, 0.5]);  // -> 7x14x3.5
```
See: [docs/language-reference/transformations.md](docs/language-reference/transformations.md)

### mirror_copy Pattern
`mirror()` replaces, doesn't copy. This helper retains both:
```openscad
module mirror_copy(v=[1,0,0]) { children(); mirror(v) children(); }
```
See: [docs/user-manual/tips-and-tricks.md](docs/user-manual/tips-and-tricks.md)

### search() as Index Finder
Search vectors of vectors by any column — lookup tables without loops.
```openscad
data = [["a",1], ["b",2], ["c",3]];
echo(search(2, data, index_col_num=1));  // [1]
```
See: [docs/language-reference/other-language-features.md](docs/language-reference/other-language-features.md)

### Dot-Product Sum Trick
Sum a vector in O(n) without recursion.
```openscad
function sum(v) = [for(p=v) 1]*v;
```
See: [docs/user-manual/tips-and-tricks.md](docs/user-manual/tips-and-tricks.md)

### assert() for Defensive Modeling
Stop execution with clear messages on bad parameters.
```openscad
function f(a, b) = assert(a > 0, "a must be positive") a * b;
```
See: [docs/language-reference/other-language-features.md](docs/language-reference/other-language-features.md)

---

## Critical Pitfalls

### Epsilon Rule (Coincident Faces)
Objects sharing exact boundaries = render failures. Always extend cutting geometry.
```openscad
difference() { cube(20); cylinder(h=20.01, r=5); }  // NOT h=20
```
See: [docs/language-reference/csg-modelling.md](docs/language-reference/csg-modelling.md), [docs/user-manual/faq.md](docs/user-manual/faq.md)

### Undersized Holes
Inscribed polygon approximation makes holes smaller than specified.
```openscad
r_actual = r / cos(180/$fn);  // circumscribed correction
```
See: [docs/language-reference/primitive-solids.md](docs/language-reference/primitive-solids.md)

### Variables Are Constants
Last assignment wins everywhere. `a=1; echo(a); a=2;` prints `2` for both.

See: [docs/language-reference/general.md](docs/language-reference/general.md)

### Float Range Off-by-One
`[0:0.2:1]` may produce 5 or 6 iterations. Use integer steps with division.
```openscad
for (i = [0:5]) echo(i/5);  // safe
```
See: [docs/language-reference/general.md](docs/language-reference/general.md)

### % Modifier Excludes from Render
Not just visual — removes geometry from F6 output entirely.

See: [docs/user-manual/faq.md](docs/user-manual/faq.md)

### 2D/3D Mixing
Cannot `difference()` a 2D object from a 3D object. 2D primitives are infinitely thin.

See: [docs/language-reference/2d-primitives.md](docs/language-reference/2d-primitives.md)

---

## Performance Tips

- **Hull in 2D then extrude** is dramatically faster than hulling 3D objects
- **`$preview ? 32 : 128`** for `$fn` — fast preview, smooth render
- **Manifold backend** (`--backend Manifold`) for fast CLI rendering
- **Tail recursion** for processing large point arrays (1M depth limit)
- **`render()`** caches geometry in preview, speeds up repeated CSG

---

## Documentation Map

| Directory | Contents |
|-----------|----------|
| [docs/cheatsheet.md](docs/cheatsheet.md) | Quick syntax reference |
| [docs/tutorial/](docs/tutorial/) | 9 chapters, beginner to advanced |
| [docs/language-reference/](docs/language-reference/) | 21 files covering the full language |
| [docs/user-manual/](docs/user-manual/) | UI, CLI, libraries, FAQ, tips & tricks |

Key reference files:
- [docs/language-reference/general.md](docs/language-reference/general.md) — variables, types, objects, scoping
- [docs/language-reference/transformations.md](docs/language-reference/transformations.md) — all transforms including offset, hull, minkowski
- [docs/language-reference/list-comprehensions.md](docs/language-reference/list-comprehensions.md) — C-style for, each, let
- [docs/language-reference/other-language-features.md](docs/language-reference/other-language-features.md) — special variables, echo, surface, search, assert
- [docs/language-reference/user-defined-functions-and-modules.md](docs/language-reference/user-defined-functions-and-modules.md) — modules, functions, lambdas, recursion
- [docs/user-manual/tips-and-tricks.md](docs/user-manual/tips-and-tricks.md) — advanced patterns, bbox, mirror_copy, surfaceData
- [docs/user-manual/customizer.md](docs/user-manual/customizer.md) — GUI parameter system
