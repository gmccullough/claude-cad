# OpenSCAD User Manual: Command Glossary

> Source: [https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Command_Glossary](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Command_Glossary)

This is a Quick Reference; a short summary of all the commands without examples, just the basic syntax. The headings are links to the full chapters.

**Please be warned:** The Command Glossary is presently outdated (03 2015).

Please have a look at the Cheatsheet, instead: [http://www.openscad.org/cheatsheet/](http://www.openscad.org/cheatsheet/)

## Mathematical Operators

```openscad
+
-   // also as unary negative
*
/
%  // this is mod

<
<=
==
!=
>=
>

&&   // logical and
||   // logical or
!    // logical not

<boolean> ? <valIfTrue> : <valIfFalse>
```

## Mathematical Functions

```openscad
abs ( <value> )

cos ( <degrees> )
sin ( <degrees> )
tan ( <degrees> )
asin ( <value> )
acos ( <value> )
atan ( <value> )
atan2 ( <y_value>, <x_value> )

pow( <base>, <exponent> )

len ( <string> )   len ( <vector> )   len ( <vector_of_vectors> )
min ( <value1>, <value2> )
max ( <value1>, <value2> )
sqrt ( <value> )
round ( <value> )
ceil ( <value> )
floor ( <value> )
lookup( <in_value>, <vector_of_vectors> )
```

## String Functions

```openscad
str(string, value, ...)
```

## Primitive Solids

```openscad
cube(size = <value or vector>, center = <boolean>);

sphere(r = <radius>);

cylinder(h = <height>, r1 = <bottomRadius>, r2 = <topRadius>, center = <boolean>);
cylinder(h = <height>, r = <radius>);

polyhedron(points = [[x, y, z], ... ], triangles = [[p1, p2, p3..], ... ], convexity = N);
```

## Transformations

```openscad
scale(v = [x, y, z]) { ... }

// In versions > 2013.03
resize(newsize=[x,y,z], auto=(true|false)) { ... }
resize(newsize=[x,y,z], auto=[xaxis,yaxis,zaxis]) { ... }  // #axis is true|false
resize([x,y,z],[xaxis,yaxis,zaxis]) { ... }
resize([x,y,z]) { ... }

rotate(a = deg, v = [x, y, z]) { ... }
rotate(a=[x_deg,y_deg,z_deg]) { ... }

translate(v = [x, y, z]) { ... }

mirror([ 0, 1, 0 ]) { ... }

multmatrix(m = [transformationMatrix]) { ... }

color([r, g, b, a]) { ... }
color([ R/255, G/255, B/255, a]) { ... }
color("blue",a) { ... }
```

## Conditional and Iterator Functions

```openscad
for (<loop_variable_name> = <vector> ) {...}

intersection_for (<loop_variable_name> = <vector_of_vectors>) {...}

if (<boolean condition>) {...} else {...}

assign (<var1>= <val1>, <var2>= <val2>, ...) {...}
```

## CSG Modelling

```openscad
union() {...}

difference() {...}

intersection() {...}

render(convexity = <value>) { ... }
```

## Modifier Characters

```openscad
! { ... } // Ignore the rest of the design and use this subtree as design root
* { ... } // Ignore this subtree
% { ... } // Ignore CSG of this subtree and draw it in transparent gray
# { ... } // Use this subtree as usual but draw it in transparent pink
```

## Modules

```openscad
module name(<var1>, <var2>, ...) { ...<module code>...}
```

Variables can be default initialized: `<var1>=<defaultvalue>`

In a module you can use `children()` to refer to all child nodes, or `children(i)` where `i` is between 0 and `$children`.

## Include Statement

After 2010.02:

```openscad
include <filename.scad>  // appends whole file

use <filename.scad>      // appends ONLY modules and functions
```

`filename` could use directory (with `/` char separator).

Prior to 2010.02:

```openscad
<filename.scad>
```

## Other Language Features

```openscad
$fa  // is the minimum angle for a fragment. The default value is 12 (degrees)
$fs  // is the minimum size of a fragment. The default value is 1.
$fn  // is the number of fragments. The default value is 0.
```

When `$fa` and `$fs` are used to determine the number of fragments for a circle, then OpenSCAD never uses less than 5 fragments.

```openscad
$t   // The $t variable is used for animation.
```

If you enable the animation frame with View->Animate and give a value for "FPS" and "Steps", the "Time" field shows the current value of `$t`.

```openscad
function name(<var>) = f(<var>);

echo(<string>, <var>, ...);

render(convexity = <val>) {...}

surface(file = "filename.dat", center = <boolean>, convexity = <val>);
```

## 2D Primitives

```openscad
square(size = <val>, center=<boolean>);
square(size = [x,y], center=<boolean>);

circle(r = <val>);

polygon(points = [[x, y], ... ], paths = [[p1, p2, p3..], ... ], convexity = N);
```

## 3D to 2D Projection

```openscad
projection(cut = <boolean>)
```

## 2D to 3D Extrusion

```openscad
linear_extrude(height = <val>, center = <boolean>, convexity = <val>,
               twist = <degrees>[, slices = <val>, $fn=..., $fs=..., $fa=...]) {...}

rotate_extrude(convexity = <val>[, $fn = ...]) {...}
```

## DXF Extrusion

```openscad
linear_extrude(height = <val>, center = <boolean>, convexity = <val>,
               twist = <degrees>[...])
import (file = "filename.dxf", layer = "layername")

rotate_extrude(origin = [x,y], convexity = <val>[, $fn = ...])
import (file = "filename.dxf", layer = "layername")
```

## STL Import

```openscad
import("filename.stl", convexity = <val>);
```
