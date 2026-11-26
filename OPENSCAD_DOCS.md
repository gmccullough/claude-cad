# OpenSCAD notes for the builds these tools run

This is not a language tutorial and doesn't need reading at session start. It records which
OpenSCAD build runs where, which newer features each build lacks or hides behind a flag, and
the pitfalls as they actually behave on those builds. Consult it before using a feature newer
than OpenSCAD 2021.01, and when a model builds on one machine but not on another.

Everything marked *checked* was run on both builds on 2026-11-25. Re-check after upgrading
either one, and update this file.

## Which build runs where

| Where | Build | Used for |
|---|---|---|
| Desktop: `tools/openscad` execs the installed app | whatever is installed; checked on development snapshot **2026.02.19** | everything |
| Cloud or any Linux: `tools/openscad` runs wasm | **2025.01.19** (`openscad-wasm-prebuilt` 1.2.0) | STL, CSG, `echo` output |
| Cloud PNG export (`-o x.png`) | apt's **2021.01** release under Xvfb | PNG only, always as a preview |

- Both the desktop snapshot and the wasm build render with Manifold by default (the wasm
  wrapper passes `--backend=manifold`), so there is no need to ask for it. Only the 2021.01 PNG
  path is CGAL/OpenCSG.
- **Write for the oldest build the model will meet.** A model that may ever be built in a cloud
  session has to parse on the wasm build.
- 2021.01 predates everything the manual marks "Development snapshot" (`fill()`, bitwise
  operators and the rest of the table below). A model that uses those can't be PNG-exported
  through it: set `OPENSCAD_PNG_VIA_VIEWER=1` or use `tools/render`, which screenshots the mesh
  the wasm build made.

## Newer features: what each build does (checked)

| Feature | Desktop snapshot 2026.02 | Cloud wasm 2025.01 |
|---|---|---|
| `fill()`, function literals, `each`, `^`, `assert`/`echo` inside expressions, `rotate_extrude(angle=)`, vector `scale` in `linear_extrude`, `intersection_for`, `resize(auto=)`, tail recursion | works | works |
| Bitwise operators `\|` `&` `<<` `>>` `~` | works | **syntax error: the whole file fails to parse** |
| Hex constants (`0xff`) | works | warns "unknown variable", gives `undef` |
| `textmetrics()`, `fontmetrics()` | needs `--enable=textmetrics` | needs `--enable=textmetrics` |
| `import("data.json")` used as a function | needs `--enable=import-function` | needs `--enable=import-function` |
| `object()` | needs `--enable=object-function` | not available at all |

**An experimental function that isn't enabled does not stop the build.** OpenSCAD prints
`WARNING: Experimental builtin function '…' is not enabled`, the call returns `undef`, and the
model exports anyway with whatever geometry `undef` produces. So:

- Pass the flag wherever the model is built, including the project's `build_3mf.py`
  (`tools/openscad --enable=textmetrics -o out.stl model.scad`), and note it in the project's
  `AGENTS.md`.
- Build with `--hardwarnings` when a model uses any of these. It turns that warning into exit
  code 1 on both builds.
- Avoid `object()` in anything that must build in the cloud.

## Pitfalls (checked)

### Coincident faces: fine in a render, wrong in a preview
A flush boolean renders correctly under Manifold. A through-cut with no overlap came out
watertight at exactly the expected volume, and two cubes sharing a face union into one body.
The old "always add an epsilon or the render fails" rule belongs to CGAL.

The preview still gets it wrong: OpenCSG z-fights on coincident faces and draws a shredded skin
across the mouth of a flush cut. Cloud PNG export is always a preview, so:

```openscad
difference() { cube(20); translate([10, 10, -0.01]) cylinder(h = 20.02, r = 5); }  // overlap for previews
```

Never judge a boolean from a preview image. Use `tools/render`, or a mesh check.

### Undersized holes
A circle is drawn as an inscribed polygon, so a hole comes out smaller than specified across
its flats. For a hole that must clear a pin: `r_actual = r / cos(180 / $fn)`.

### Variables are constants
The last assignment wins everywhere. `a = 1; echo(a); a = 2;` prints `2` (with a warning).

### Float ranges can drop the last step
`[0:0.2:1]` gave six values on both builds, but an accumulated float step can stop one short.
Step in integers and divide: `for (i = [0:5]) x = i / 5;`

### `%` removes geometry from the output
The background modifier is not only visual: `%cube(10);` exports nothing.

### 2D and 3D don't mix
`difference() { cube(10); circle(3); }` warns "Mixing 2D and 3D objects is not supported" and
ignores the 2D child. Extrude it first.

### `search()` with a named `index_col_num`
`search(2, data, index_col_num = 1)` returns `[]` on both builds. Pass the arguments by
position: `search(2, data, 1, 1)` returns `[1]` for `data = [["a",1], ["b",2], ["c",3]]`.

## Techniques worth remembering

All of these exist in every build above, 2021.01 included.

```openscad
// Stateful iteration without recursion (C-style for in a list comprehension)
function cumsum(v) = [for (a = v[0] - v[0], i = 0; i < len(v); a = a + v[i], i = i + 1) a + v[i]];

// Flatten ranges and values into one list
A = [-2, each [1:2:5], each [6:-2:0], -1];          // [-2, 1, 3, 5, 6, 4, 2, 0, -1]

// 2D rounding without computing arcs
offset(r = -3) offset(delta = +3) polygon(pts);     // fillet concave corners
offset(r = +3) offset(delta = -3) polygon(pts);     // round convex corners
offset(-r) offset(r) offset(r) offset(-r) polygon(pts);  // round all corners

// Loft by hulling consecutive sections
for (i = [1:18]) hull() {
    translate([0, 0, i])     cylinder(.1, d1 = 10 * sin(i * 9));
    translate([0, 0, i + 1]) cylinder(.1, d1 = 10 * sin((i + 1) * 9));
}

// Shear: only multmatrix can do it
multmatrix([[1, 0, 0, 0], [0, 1, 0.7, 0], [0, 0, 1, 0], [0, 0, 0, 1]]) cylinder(r = 10, h = 10);

// mirror() replaces; this keeps both halves
module mirror_copy(v = [1, 0, 0]) { children(); mirror(v) children(); }

// Sections and shadows from 3D
projection(cut = true) translate([0, 0, -5]) my_model();   // slice at z = 5
projection(cut = false) my_model();                        // outline

// Inline debugging and guards
r = echo("computing:", a, b) a * b;
function f(a, b) = assert(a > 0, "a must be positive") a * b;

// Sum a vector without recursion
function sum(v) = [for (p = v) 1] * v;
```

- `$`-prefixed variables are dynamically scoped: set `$exploded = true;` once and every module
  called below it can read it.
- `$preview` is true in a preview and false in a render, for cheap previews of heavy models.
- Tail-recursive functions (accumulator pattern) run to about a million deep; others stop near
  3,000.
- `surface(file = "x.png")` builds a heightmap (lithophanes, grip texture).
- Hull or offset in 2D and then extrude: far faster than hulling 3D solids.

## Documentation map

`docs/` is a copy of the OpenSCAD manual from
[openscad.org/documentation](https://openscad.org/documentation.html), taken in February 2026,
without the beginner tutorial and the pages about the GUI or building OpenSCAD from source. It
describes development snapshots: before using anything it marks "Development snapshot", check
the table above.

| Path | Contents |
|---|---|
| [docs/cheatsheet.md](docs/cheatsheet.md) | Syntax at a glance, for the 2021.01 release (nothing newer) |
| [docs/language-reference/](docs/language-reference/) | The full language, one file per topic |
| [docs/user-manual/](docs/user-manual/) | Command line, libraries, STL import and export, customizer, FAQ, tips and tricks |

Where to look first:
- [general.md](docs/language-reference/general.md): variables, types, ranges, scoping
- [transformations.md](docs/language-reference/transformations.md): every transform, with `offset`, `hull`, `minkowski`, `fill`
- [list-comprehensions.md](docs/language-reference/list-comprehensions.md): C-style `for`, `each`, `let`
- [other-language-features.md](docs/language-reference/other-language-features.md): special variables, `echo`, `surface`, `search`, `assert`
- [user-defined-functions-and-modules.md](docs/language-reference/user-defined-functions-and-modules.md): modules, functions, function literals, recursion
- [command-line.md](docs/user-manual/command-line.md): every CLI option, including `--enable` and `--hardwarnings`
- [tips-and-tricks.md](docs/user-manual/tips-and-tricks.md): bounding boxes, `mirror_copy`, data-driven patterns
