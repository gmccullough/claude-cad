# OpenSCAD User Manual: Using the 2D Subsystem

> Source: [https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_the_2D_Subsystem](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_the_2D_Subsystem)

## 2D Primitives

All 2D primitives can be transformed with 3D transformations. They are usually used as part of a 3D extrusion. Although they are infinitely thin, they are rendered with a 1-unit thickness.

**Note:** Trying to subtract with `difference()` from a 3D object will lead to unexpected results in final rendering.

### square

Creates a square or rectangle in the first quadrant. When `center` is true the square is centered on the origin. Argument names are optional if given in the order shown here.

```openscad
square(size = [x, y], center = true/false);
square(size =  x    , center = true/false);
```

**Parameters:**

| Parameter | Description |
|-----------|-------------|
| `size` | Single value: square with both sides this length. 2 value array `[x,y]`: rectangle with dimensions x and y. |
| `center` | `false` (default): 1st (positive) quadrant, one corner at (0,0). `true`: square is centered at (0,0). |

**Defaults:** `square();` yields `square(size = [1, 1], center = false);`

**Examples:**

```openscad
// Equivalent scripts
square(size = 10);
square(10);
square([10,10]);

square(10,false);
square([10,10],false);
square([10,10],center=false);
square(size = [10, 10], center = false);
square(center = false,size = [10, 10] );
```

```openscad
// Centered rectangle
square([20,10],true);
a=[20,10];square(a,true);
```

### circle

Creates a circle at the origin. All parameters, except `r`, must be named.

```openscad
circle(r=radius | d=diameter);
```

**Parameters:**

| Parameter | Description |
|-----------|-------------|
| `r` | Circle radius. `r` name is the only one optional with circle. Circle resolution is based on size, using `$fa` or `$fs`. |
| `d` | Circle diameter (only available in versions later than 2014.03). |
| `$fa` | Minimum angle (in degrees) of each fragment. |
| `$fs` | Minimum circumferential length of each fragment. |
| `$fn` | Fixed number of fragments in 360 degrees. Values of 3 or more override `$fa` and `$fs`. |

If they are used, `$fa`, `$fs` and `$fn` must be named parameters.

**Defaults:** `circle();` yields `circle($fn = 0, $fa = 12, $fs = 2, r = 1);`

For a small, high resolution circle you can make a large circle, then scale it down, or you could set `$fn` or other special variables:

```openscad
scale([1/100, 1/100, 1/100]) circle(200); // create a high resolution circle with a radius of 2.
circle(2, $fn=50);                        // Another way.
```

**Examples:**

```openscad
// Equivalent scripts
circle(10);
circle(r=10);
circle(d=20);
circle(d=2+9*2);
```

### Ellipses

An ellipse can be created from a circle by using either `scale()` or `resize()` to make the x and y dimensions unequal. See OpenSCAD User Manual/Transformations.

```openscad
// Equivalent scripts
resize([30,10])circle(d=20);
scale([1.5,.5])circle(d=20);
```

### Regular Polygons

A regular polygon of 3 or more sides can be created by using `circle()` with `$fn` set to the number of sides. The following two pieces of code are equivalent:

```openscad
circle(r=1, $fn=4);
```

```openscad
module regular_polygon(order = 4, r=1){
    angles=[ for (i = [0:order-1]) i*(360/order) ];
    coords=[ for (th=angles) [r*cos(th), r*sin(th)] ];
    polygon(coords);
}
regular_polygon();
```

These result in shapes where the polygon is inscribed within the circle with all sides (and angles) equal. One corner points to the positive x direction.

```openscad
// Script for polygon examples
translate([-42,  0]){circle(20,$fn=3);%circle(20,$fn=90);}
translate([  0,  0]) circle(20,$fn=4);
translate([ 42,  0]) circle(20,$fn=5);
translate([-42,-42]) circle(20,$fn=6);
translate([  0,-42]) circle(20,$fn=8);
translate([ 42,-42]) circle(20,$fn=12);

color("black"){
    translate([-42,  0,1])text("3",7,,center);
    translate([  0,  0,1])text("4",7,,center);
    translate([ 42,  0,1])text("5",7,,center);
    translate([-42,-42,1])text("6",7,,center);
    translate([  0,-42,1])text("8",7,,center);
    translate([ 42,-42,1])text("12",7,,center);
}
```

### polygon

Creates a multiple sided shape from a list of x,y coordinates. A polygon is the most powerful 2D object. It can create anything that circle and squares can, as well as much more. This includes irregular shapes with both concave and convex edges. In addition it can place holes within that shape.

```openscad
polygon(points = [ [x, y], ... ], paths = [ [p1, p2, p3..], ...], convexity = N);
```

**Parameters:**

| Parameter | Description |
|-----------|-------------|
| `points` | The list of x,y points of the polygon: A vector of 2 element vectors. Note: points are indexed from 0 to n-1. |
| `paths` | **default**: If no path is specified, all points are used in the order listed. **single vector**: The order to traverse the points. Uses indices from 0 to n-1. May be in a different order and use all or part of the points listed. **multiple vectors**: Creates primary and secondary shapes. Secondary shapes are subtracted from the primary shape (like `difference()`). Secondary shapes may be wholly or partially within the primary shape. A closed shape is created by returning from the last point specified to the first. |
| `convexity` | Integer number of "inward" curves, i.e. expected path crossings of an arbitrary line through the polygon. |

**Defaults:** `polygon();` yields `polygon(points = undef, paths = undef, convexity = 1);`

#### Without holes

```openscad
// Equivalent scripts
polygon(points=[[0,0],[100,0],[130,50],[30,50]]);
polygon([[0,0],[100,0],[130,50],[30,50]], paths=[[0,1,2,3]]);
polygon([[0,0],[100,0],[130,50],[30,50]],[[3,2,1,0]]);
polygon([[0,0],[100,0],[130,50],[30,50]],[[1,0,3,2]]);

a=[[0,0],[100,0],[130,50],[30,50]];
b=[[3,0,1,2]];
polygon(a);
polygon(a,b);
polygon(a,[[2,3,0,1,2]]);
```

#### One hole

```openscad
// Equivalent scripts
polygon(points=[[0,0],[100,0],[0,100],[10,10],[80,10],[10,80]], paths=[[0,1,2],[3,4,5]],convexity=10);

triangle_points =[[0,0],[100,0],[0,100],[10,10],[80,10],[10,80]];
triangle_paths =[[0,1,2],[3,4,5]];
polygon(triangle_points,triangle_paths,10);
```

The 1st path vector, `[0,1,2]`, selects the points `[0,0],[100,0],[0,100]` for the primary shape. The 2nd path vector, `[3,4,5]`, selects the points `[10,10],[80,10],[10,80]` for the secondary shape. The secondary shape is subtracted from the primary (think `difference()`). Since the secondary is wholly within the primary, it leaves a shape with a hole.

#### Multi hole

*(Requires version 2015.03 for use of `concat()`)*

```openscad
//example polygon with multiple holes
a0 = [[0,0],[100,0],[130,50],[30,50]];     // main
b0 = [1,0,3,2];
a1 = [[20,20],[40,20],[30,30]];            // hole 1
b1 = [4,5,6];
a2 = [[50,20],[60,20],[40,30]];            // hole 2
b2 = [7,8,9];
a3 = [[65,10],[80,10],[80,40],[65,40]];    // hole 3
b3 = [10,11,12,13];
a4 = [[98,10],[115,40],[85,40],[85,10]];   // hole 4
b4 = [14,15,16,17];
a  = concat (a0,a1,a2,a3,a4);
b  = [b0,b1,b2,b3,b4];
polygon(a,b);
//alternate
polygon(a,[b0,b1,b2,b3,b4]);
```

#### Extruding a 3D shape from a polygon

```openscad
translate([0,-20,10]) {
    rotate([90,180,90]) {
        linear_extrude(50) {
            polygon(
                points = [
                    [-2.8,0],
                    [-7.8,0],
                    [-15.3633,10.30],
                    [15.3633,10.30],
                    [7.8,0],
                    [2.8,0],
                    [5.48858,5.3],
                    [-5.48858,5.3],
                ]
            );
        }
    }
}
```

#### convexity

The convexity parameter specifies the maximum number of front sides (back sides) a ray intersecting the object might penetrate. This parameter is needed only for correct display of the object in OpenCSG preview mode and has no effect on the polyhedron rendering.

A 2D shape with a convexity of 2 means a ray crosses the 2D shape's outside-to-inside (or inside-to-outside) boundary a maximum of 2 times. The convexity of a 3D shape would be determined in a similar way. Setting it to 10 should work fine for most cases.

### import_dxf

**Deprecated:** `import_dxf()` is deprecated and will be removed in a future release. Use `import()` instead.

Read a DXF file and create a 2D shape.

```openscad
linear_extrude(height = 5, center = true, convexity = 10)
    import_dxf(file = "example009.dxf", layer = "plate");
```

## Text

The `text` module creates text as a 2D geometric object, using fonts installed on the local system or provided as separate font file.

*(Requires version 2015.03)*

### Parameters

| Parameter | Description |
|-----------|-------------|
| `text` | String. The text to generate. |
| `size` | Decimal. The generated text has an ascent (height above the baseline) of approximately this value. Default is 10. The formula to convert the size value to "points" is `pt = size * 3.937`, so a size argument of 3.05 will give about 12pt text. |
| `font` | String. The name of the font that should be used. This is not the name of the font file, but the logical font name (internally handled by the fontconfig library). This can also include a style parameter. |
| `halign` | String. The horizontal alignment for the text. Possible values are `"left"`, `"center"` and `"right"`. Default is `"left"`. |
| `valign` | String. The vertical alignment for the text. Possible values are `"top"`, `"center"`, `"baseline"` and `"bottom"`. Default is `"baseline"`. |
| `spacing` | Decimal. Factor to increase/decrease the character spacing. The default value of 1 results in the normal spacing for the font, giving a value greater than 1 causes the letters to be spaced further apart. |
| `direction` | String. Direction of the text flow. Possible values are `"ltr"` (left-to-right), `"rtl"` (right-to-left), `"ttb"` (top-to-bottom) and `"btt"` (bottom-to-top). Default is `"ltr"`. |
| `language` | String. The language of the text (e.g., `"en"`, `"ar"`, `"ch"`). Default is `"en"`. |
| `script` | String. The script of the text (e.g., `"latin"`, `"arabic"`, `"hani"`). Default is `"latin"`. |
| `$fn` | Used for subdividing the curved path segments provided by freetype. |

### Basic Example

```openscad
text("OpenSCAD");
```

### Unicode Characters

To allow specification of particular Unicode characters, you can specify them in a string with the following escape codes:

| Escape Code | Description |
|-------------|-------------|
| `\x03` | Hex char-value (only hex values from 01 to 7f are supported) |
| `\u0123` | Unicode char with 4 hexadecimal digits (note: lowercase `\u`) |
| `\U012345` | Unicode char with 6 hexadecimal digits (note: uppercase `\U`) |

The null character (NUL) is mapped to the space character (SP).

```openscad
assert(version() == [2019, 5, 0]);
assert(ord(" ") == 32);
assert(ord("\x00") == 32);
assert(ord("\u0000") == 32);
assert(ord("\U000000") == 32);
```

```openscad
t="\u20AC10 \u263A"; // 10 euro and a smiley
```

### Using Fonts & Styles

Fonts are specified by their logical font name; in addition a style parameter can be added to select a specific font style like "bold" or "italic":

```openscad
font="Liberation Sans:style=Bold Italic"
```

The font list dialog (available under Help > Font List) shows the font name and the font style for each available font.

OpenSCAD includes the fonts **Liberation Mono**, **Liberation Sans**, and **Liberation Serif**. Use of these included fonts is recommended for portability across platforms. Liberation Sans is the default font.

In addition to installed fonts (for Windows, only fonts installed as admin for all users), it's possible to add project specific font files. Supported font file formats are TrueType Fonts (`*.ttf`) and OpenType Fonts (`*.otf`). The files need to be registered with `use<>`:

```openscad
use <ttf/paratype-serif/PTF55F.ttf>
```

OpenSCAD uses fontconfig to find and manage fonts. You can list system configured fonts on command line:

```bash
$ fc-list -f "%-60{{%{family[0]}%{:style[0]=}}}%{file}\n" | sort
```

Under Windows, fonts are stored in the Windows Registry:

```
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /s > List_Fonts_Windows.txt
```

### Font Example

```openscad
square(10);

translate([15, 15]) {
  text("OpenSCAD", font = "Liberation Sans");
}

translate([15, 0]) {
  text("OpenSCAD", font = "Liberation Sans:style=Bold Italic");
}
```

### Vertical Alignment

| Value | Description |
|-------|-------------|
| `"top"` | The text is aligned so the top of the tallest character is at the given Y coordinate. |
| `"center"` | The text is aligned with the center of the bounding box at the given Y coordinate. This bounding box is based on the actual sizes of the letters, so taller letters and descenders will affect the positioning. |
| `"baseline"` | The text is aligned with the font baseline at the given Y coordinate. This is the default, and is the only option that makes different pieces of text align vertically, as if they were written on lined paper, regardless of character heights and descenders. |
| `"bottom"` | The text is aligned so the bottom of the lowest-reaching character is at the given Y coordinate. |

```openscad
text = "Align";
font = "Liberation Sans";

valign = [
  [  0, "top"],
  [ 40, "center"],
  [ 75, "baseline"],
  [110, "bottom"]
];

for (a = valign) {
  translate([10, 120 - a[0], 0]) {
    color("red") cube([135, 1, 0.1]);
    color("blue") cube([1, 20, 0.1]);
    linear_extrude(height = 0.5) {
      text(text = str(text,"_",a[1]), font = font, size = 20, valign = a[1]);
    }
  }
}
```

The `text()` module doesn't support multi-line text, but you can make a separate call for each line, using `translate()` to space them. A spacing of `1.4*size` is the minimum required to prevent lines overlapping (if they include descenders). `1.6*size` is approximately the default single-spacing in many word processing programs. To get evenly spaced lines, use `"baseline"` vertical alignment.

### Horizontal Alignment

| Value | Description |
|-------|-------------|
| `"left"` | The text is aligned with the left side of the bounding box at the given X coordinate. This is the default. |
| `"center"` | The text is aligned with the center of the bounding box at the given X coordinate. |
| `"right"` | The text is aligned with the right of the bounding box at the given X coordinate. |

```openscad
text = "Align";
font = "Liberation Sans";

halign = [
  [10, "left"],
  [50, "center"],
  [90, "right"]
];

for (a = halign) {
  translate([140, a[0], 0]) {
    color("red") cube([115, 2,0.1]);
    color("blue") cube([2, 20,0.1]);
    linear_extrude(height = 0.5) {
      text(text = str(text,"_",a[1]), font = font, size = 20, halign = a[1]);
    }
  }
}
```

### 3D Text

Text can be changed from a 2 dimensional object into a 3D object by using `linear_extrude`:

```openscad
//3d Text Example
linear_extrude(4)
    text("Text");
```

### Metrics

*(Requires Development snapshot)*

#### textmetrics()

The `textmetrics()` function accepts the same parameters as `text()`, and returns an object describing how the text would be rendered.

The returned object has these members:

| Member | Description |
|--------|-------------|
| `position` | The position of the lower-left corner of the generated text. |
| `size` | The size of the generated text. |
| `ascent` | The amount that the text extends above the baseline. |
| `descent` | The amount that the text extends below the baseline. |
| `offset` | The origin of the text after aligning. Text typically starts slightly right of this point. |
| `advance` | The "other end" of the text, the point at which additional text should be positioned, relative to "offset". Text generally ends slightly left of this point. |

```openscad
s = "Hello, World!";
size = 20;
font = "Liberation Serif";

tm = textmetrics(s, size=size, font=font);
echo(tm);
translate([0,0,1]) text("Hello, World!", size=size, font=font);
color("black") translate(tm.position) square(tm.size);
```

Output (reformatted for readability):

```
ECHO: {
    position = [0.7936, -4.2752];
    size = [149.306, 23.552];
    ascent = 19.2768;
    descent = -4.2752;
    offset = [0, 0];
    advance = [153.09, 0];
}
```

#### fontmetrics()

The `fontmetrics()` function accepts a font size and a font name, both optional, and returns an object describing global characteristics of the font.

**Parameters:**

| Parameter | Description |
|-----------|-------------|
| `size` | Decimal, optional. The size of the font, as described above for `text()`. |
| `font` | String, optional. The name of the font, as described above for `text()`. |

Note that omitting the size and/or font may be useful to get information about the default font.

**Returns an object:**

| Member | Description |
|--------|-------------|
| `nominal.ascent` | Usual height above the baseline for a glyph. |
| `nominal.descent` | Usual depth below the baseline for a glyph. |
| `max.ascent` | Maximum height above the baseline for a glyph. |
| `max.descent` | Maximum depth below the baseline for a glyph. |
| `interline` | Design distance from one baseline to the next. |
| `font.family` | The font family name. |
| `font.style` | The style (Regular, Italic, et cetera). |

```openscad
echo(fontmetrics(font="Liberation Serif"));
```

Output (reformatted for readability):

```
ECHO: {
    nominal = {
        ascent = 12.3766;
        descent = -3.0043;
    };
    max = {
        ascent = 13.6312;
        descent = -4.2114;
    };
    interline = 15.9709;
    font = {
        family = "Liberation Serif";
        style = "Regular";
    };
}
```

## 3D to 2D Projection

Using `projection()`, you can create 2D drawings from 3D models, and export them to the DXF format. It works by projecting a 3D model to the (x,y) plane, with z at 0. If `cut=true`, only points with z=0 are considered (effectively cutting the object); with `cut=false` (the default), points above and below the plane are considered as well (creating a proper projection).

```openscad
// 'cut' projection - gives you the 'slice' of the x-y plane with z=0
projection(cut = true) example002();
```

```openscad
// 'ordinary' projection - gives a sort of 'shadow' of the object onto the xy plane
projection(cut = false) example002();
```

```openscad
// Side view using projection
translate([0,0,25]) rotate([90,0,0]) example002();
projection() translate([0,0,25]) rotate([90,0,0]) example002();
```

## 2D to 3D Extrusion

See [2D to 3D Extrusion](2d-to-3d-extrusion.md) for detailed coverage of `linear_extrude()` and `rotate_extrude()`.

## DXF Extrusion

With the `import()` and extrusion modules it is possible to convert 2D objects read from DXF files to 3D objects.

### Linear Extrude

```openscad
linear_extrude(height = fanwidth, center = true, convexity = 10)
   import (file = "example009.dxf", layer = "fan_top");
```

### Rotate Extrude

```openscad
rotate_extrude(convexity = 10)
   import (file = "example009.dxf", layer = "fan_side", origin = fan_side_center);
```

### Getting Inkscape to work

Inkscape is an open source drawing program. Several tutorials are available for transferring 2D DXF drawings from Inkscape to OpenSCAD.
