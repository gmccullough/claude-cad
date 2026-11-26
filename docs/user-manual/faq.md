# OpenSCAD User Manual: FAQ

> Source: [https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/FAQ](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/FAQ)

## General

### How is OpenSCAD pronounced?

The intended pronunciation is: Open - ESS - CAD

### What is the meaning of the S in OpenSCAD?

The S stands for Solid as in Solid modeling.

### Why Is There No Preview on Windows in a Virtual Machine?

It is likely that your VM or session does not support the required version of OpenCSG/OpenGL for correct preview rendering.

**Note:** Also applies when working via Remote desktop using RDP (Windows) or XfreeRDP (Linux).

A solution is to use software rendering via the Mesa driver from the MSYS2 package. Download the repository for the version for your version of Windows:

- 64bit - mingw64 repository
- 32bit - mingw32 repository

**Deprecated:** Windows as a 32-bit Operating System is deprecated and will be removed in a future release. Use a 64 bit version of Windows instead.

A decompression app like 7-zip or WinRAR will be needed to extract the contents of the `*pkg.tar.xz` file.

Find the file `mingw64\bin\opengl32.dll` in the extracted folder. Note that even in a 64 bit system the name of the .dll still has "32" in it.

Copy `opengl32.dll` to the OpenSCAD installation directory, which is normally `c:\program files` (for 64bits) or `c:\program files(x86)` (for 32bits).

Restart OpenSCAD and preview should function normally.

## Display

### Why Isn't Preview Working?

Some systems, in particular Intel GPUs on Windows, tend to have old or broken OpenGL drivers. This affects preview rendering when using difference or intersection operators.

The following tends to improve the situation: **Edit->Preferences->Advanced->Force Goldfeather**.

### What are those strange flickering artifacts in the preview?

This is typically caused by differencing objects that share one or more faces, e.g.:

```openscad
cube_size = 20;
difference() {
  cube(cube_size, center = true);
  cylinder(r = 10, h = cube_size, center = true);
}
```

In some cases the final render works fine, but designs with coincident resulting faces should be considered a design with undefined behavior, as a proper render result is not guaranteed. The fundamental source of the issue is not a bug, but an intrinsic property of the inability to rigorously compare floating point values which might have undergone trigonometric operations (like rotations) resulting in irrational values that simply cannot be represented exactly in any manner.

The solution to this is to always provide a clear overlap for surfaces which are to be removed, such as by adding a small value called an epsilon:

```openscad
cube_size = 20;
difference() {
  cube(cube_size, center = true);
  cylinder(r = 10, h = cube_size+0.01, center = true);
}
```

Note that a similar issue occurs with unions, where coincident faces to be merged must also be given an epsilon value to guarantee they are always inside.

See also: [Z-fighting](https://en.wikipedia.org/wiki/Z-fighting)

### Why are some parts (e.g. holes) of the model not rendered correctly?

In complex cases, the convexity of the objects is not known. For these objects, the convexity parameter can be used to specify the value. Note that higher values cause a slowdown in preview.

```openscad
difference() {
    linear_extrude(height = 15 /* , convexity = 2 */) {
        difference() {
            square([50, 50]);
            translate([10, 10]) circle(5);
        }
    }
    translate([25, 25]) cube([5, 5, 40], center = true);
}
```

This figure has a convexity of 2.

The convexity parameter specifies the maximum number of front sides (or back sides) a ray intersecting the object might penetrate. For example, the convexity of a sphere is one and the convexity of a torus is two. This parameter is only needed for correctly displaying the object in OpenCSG preview mode when using the standard Goldfeather algorithm and has no effect on mesh rendering.

**Hint:** Finding the right convexity value can be difficult. Setting it to 10 should work fine for most cases.

Another workaround might be to use `render()` to force the generation of a mesh even in preview mode.

### Why does difference (or intersection) sometimes not work in preview?

```openscad
difference() {
    sphere(10);
    cube(100);
}
```

In perspective mode, the previewer does not process differences or intersections where the camera is inside the invisible object. This is most commonly seen when using a large object to cut away significant parts of the model.

**Workarounds:**

- Keep the camera outside the invisible objects.
- Keep the invisible objects modest-sized so that it is easier to keep the camera outside them.
- Wrap `render()` around the difference or intersection.
- Use orthogonal mode.

### Why is my model appearing with F5 but not F6?

This can be caused by polyhedra with flipped faces.

This can be visualized in "Thrown Together" display mode. See misordered faces for details.

```openscad
points = [[5,5,0],[5,-5,0],[-5,-5,0],[-5,5,0],[0,0,3]];
faces = [[0,1,4],[1,2,4],[2,3,4],[3,4,0],[1,0,3],[2,1,3]];
polyhedron(points, faces);
```

If the model imports external STL files, see also the import related question. It is confusing that the error only occurs if there is more than one object involved, i.e. it "works" until you add another item.

### Why is the preview so slow?

Intersections or difference operations that use objects to cut holes, chamfer, or generally remove part of a solid are expensive. The preview rendering expects to have only primitive objects used as negatives so anything more complex has to be unpacked.

For example (using A+B = union() / A-B = difference() / A*B = intersection()):

```
A - B*C - D*E
```

becomes: `A-B-D + A-B-E + A-C-D + A-C-E`

And if A is more complex:

```
A+B - C*D - E*F
```

becomes: `A-C-E + A-C-F + A-D-E + A-D-F + B-C-E + B-C-F + B-D-E + B-D-F`

All combinations have to be rendered, which can take some time, especially on older GPUs, and especially on low-end Intel GPUs.

## Import

### How can I Clean Up STL Issues?

To work well the meshes in an STL file should be manifold, not contain holes, nor intersect itself. Even with such issues the import process may well succeed and show something in the preview panel. However, operating on that object, or doing a full render, will likely:

- emit warnings about it not being manifold
- cause it to disappear
- emit CGAL errors

There are several ways to clean an STL file:

**MeshLab** - This free software can fix all issues.

Using MeshLab, you can do:

1. Render > Show non Manif Edges
2. Render > Show non Manif Vertices
3. If bad edges or vertices are found, use menu: Filters > Selection > Select non Manifold Edges (or Select non Manifold Vertices) and then Apply and Close.
4. If there are bad items a button "Delete the current set of selected vertices..." should be used to remove them.
5. Fill holes: Select a hole, click Fill, then Accept, and repeat until the mesh is correct.
6. Use menu File > Export Mesh to export to STL.

**Using Blender** is a possible alternative:

1. Start Blender
2. `X, 1` to remove the default object
3. File > Import > STL
4. `Tab` to edit the mesh
5. `A` to de-select all vertices
6. `Alt+Ctrl+Shift+M` to select all non-manifold vertices
7. `MMB` to rotate, `Shift+MMB` to pan, `wheel` to zoom
8. `C` for "circle" select, `Esc` to finish
9. `Alt+M, 1` to merge or `Space` and search for "merge" as alternative

### Why is my imported STL file appearing with F5 but not F6?

This is mostly caused by bad geometry in the STL file. Use an app like Blender, MeshLab, NetFabb, or Prusa Slicer to import, repair and re-export the clean version. In essence the model needs to be manifold to be processed in OpenSCAD.

A specific issue are the so called "Zero faces" where the 3 points of a triangle are co-linear, which is currently not handled well in OpenSCAD.

**Using MeshLab:**

MeshLab has a filter to remove zero faces by flipping edges of polygons:

```
Filters -> Cleaning and Repairing -> Remove T-Vertices by Edge-Flip
```

Set the Ratio to a high value (e.g. 1000000), otherwise it's possible the model gets distorted.

**Using Blender:**

Blender has a 3D-Printing-Toolbox Plug-in (needs to be enabled in the UserSettings) that can show issues with the STL file.

**Prusa Slicer:**

In the menu File > Repair STL will take a file and make it acceptable to Slicer, if it can.

### What are "Unsupported DXF Entity" warnings?

Warning messages like `Unsupported DXF Entity 'SPLINE' (1c1) in "file.dxf"` mean that the DXF file was written using features that the import processor does not support. The importer will still import the parts it can, but your model may be incomplete.

When using Inkscape to draw a design it is good practice to convert all Bezier curves to short line segments using:

```
Extensions > Modify Path > Flatten Beziers ...
```

which pops up a dialog with a setting for the max length of the line segments to use. When exporting select format "AutoCAD DXF R14".

### Can I Import Inkscape 2D Models to OpenSCAD?

Inkscape is an open source drawing program. Tutorials for transferring 2d DXF drawings from Inkscape to OpenSCAD are available. Exporting to SVG or DXF will work with the `import()` module to bring your drawing into OpenSCAD.

## Export

### How can I export multiple parts from one script?

There is no way to directly export multiple parts from one script in one run. However, you can write your script so that it will generate each part separately, and run it multiple times.

In this example, the variable PART controls which part is being exported in the current run:

```openscad
PART = "all"; // [ all, tree, trunk, base]

module tree() {
  color("green") cylinder(r1 = 12, r2 = 1, h = 30);
}

module trunk() {
  color("brown") cylinder(r = 3, h = 10);
}

module base() {
  color("white") translate([-10, -10, 0]) cube([20, 20, 5]);
}

if (PART == "tree") tree();
if (PART == "trunk") trunk();
if (PART == "base") base();

if (PART == "all") {
  base();
  translate([0, 0, 5]) trunk();
  translate([0, 0, 15]) tree();
}
```

When working interactively, you can use the Customizer to set the PART variable and control which part is generated.

It's possible to automate the process of exporting all of the parts by writing a shell script:

```bash
# export parts as STL
openscad -DPART=\"tree\" -o tree.stl model.scad
openscad -DPART=\"trunk\" -o trunk.stl model.scad
openscad -DPART=\"base\" -o base.stl model.scad

# export image of all the parts combined
openscad -DPART=\"all\" -o model.png model.scad
```

### How can I export screenshots with higher resolution than the current window?

Right now that is not possible from the GUI, as the images are restricted to the actual display context. Using the File->Export->Export As Image menu always exports at viewport resolution.

It is however possible to generate higher resolution images via command line using the `--imgsize` parameter:

```bash
openscad --imgsize 16000,16000 -o CSG.png CSG.scad
```

## Language

### Why am I getting an error when writing a = a + 1?

The short answer is that variables cannot be changed; they can only be assigned once.

There are several ways to replace iteration; for some examples see the Tips and Tricks section.

When we add in the effect of block statements opening local scopes it is possible that an assignment may look like it is breaking this rule. But reusing a variable name, like "x", inside a block is defining a new, local variable so using the "x" from outside the block on the RHS of the "=" sign is allowed:

```openscad
x=12;
if(true) {
  x=x+1;   // local = global + 1
  echo(x); // ECHO: 13
}
echo(x); //ECHO: 12
```

The deeper answer is based on OpenSCAD being a declarative functional language. In a functional language a script is list of instructions (statements) that are compiled into a run-able form using a script's initial conditions as the basis for every calculation, decision, and loop carried out in strict order. Statements in the script are only ever visited once and every variable that receives the value of a calculation can only be set once, effectively making it a constant.

### Are measures being considered to help procedural programmers?

The view that "variables may not be changed" is a limitation can hopefully be changed by showing how to better exploit the opportunities.

- A "reduce" function to help with collecting information depending on a list of input
- **Recursion is fine** - we already detect and handle Tail-End Recursion now, but additional help features are possible
- **Disallow Reassignment** - The editor could be enhanced to fail with an error when `x=x+1` is detected
- **Command-Line Variable Override** - a new syntax or other mechanism for achieving this

**Aspects of the Zen of Functional Language Processing:**

- Imagine that all the expressions in a script are executed in parallel. Any dependency of one expression on another must be made explicit by hierarchical grouping. This view makes iterating to accumulate information unnecessary.
- OpenSCAD functions operate the way that a spreadsheet cell does. A spreadsheet formula cannot increment itself as that would be a circular reference.

See also for help: List Comprehension, Tips & Tricks, Recursive Functions

## User Interface

### OpenSCAD isn't adhering to my GTK desktop theme

You may need to install package `qt5-style-plugins` on Debian-based systems and `qt5-qtstyleplugins` on Fedora-based systems, then set environment variable when calling openscad:

```bash
QT_QPA_PLATFORMTHEME=gtk2 openscad
```

To make the setting permanent, add `export QT_QPA_PLATFORMTHEME=gtk2` to your user's `~/.profile`.

### OpenSCAD GUI is not scaled in Gnome on a 4K / HIDPI Monitor

The GUI Framework Qt used by OpenSCAD seems to need an extra hint to automatically scale correctly for 4K / HIDPI Monitors on Gnome/X11.

1. Copy `openscad.desktop` from `/usr/share/applications/` to `~/.local/share/applications`
2. Change `Exec=openscad` to `Exec=env QT_AUTO_SCREEN_SCALE_FACTOR=1 openscad`

### I'm not getting any menubar when running OpenSCAD in Ubuntu, how can I get it back?

This seems to be caused by Ubuntu messing with Qt to move the menubar somewhere else (e.g. top of the screen).

Two things that could help:

1. Set the `QT_QPA_PLATFORMTHEME` environment variable to an empty string: `QT_QPA_PLATFORMTHEME= openscad`
2. Remove the `appmenu-qt5` package to globally disable menubar changes for all applications

### Why are the error line numbers wrong?

That is a limitation/bug in the current parser that handles `include<>` basically as copy & paste of content. In some cases it's possible to work around the issue by placing the `include<>` statements at the end of the file.

When depending on libraries, it's recommended to use `use<>` instead which does not have that problem and also automatically inhibits any top-level geometry of that file.

### I don't like the editor, can I use my favourite editor instead?

Yes, OpenSCAD supports a special mode that reloads the files if they are modified externally. To enable this mode, check the **Design -> Automatic Reload and Preview** option and just close the editor window (or use **View -> Hide Editor**).

See also: [Using an external Editor with OpenSCAD](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_an_external_Editor_with_OpenSCAD)

Example bash script that runs vim as editor and also starts OpenSCAD:

```bash
#!/bin/bash

FILE="$1"
AUTHOR="Your Name Here"
YEAR="$(date "+%Y")"
LICENSE="// Created in $YEAR by $AUTHOR.\n// This work is released with CC0 into the public domain.\n// https://creativecommons.org/publicdomain/zero/1.0/"

# increase stack size to allow deeper recursion
ulimit -s 65536

if [ "$FILE" == "" ]
then
  TEMPF=`mktemp --suffix=.scad`
  openscad "$TEMPF" >/dev/null 2>/dev/null &
  vim "$TEMPF"
  rm -f "$TEMPF"
  exit
fi

if [ ! -e "$FILE" ]
then
  echo -e "$LICENSE" >> "$FILE"
fi

openscad "$FILE" >/dev/null 2>/dev/null &
vim "$FILE"
```

## Errors / Problems

### Why am I getting "no top level geometry to render"?

This can have different reasons, some common ones include:

**Missing / Commented out module call:**

```openscad
module model() {
  cube(20);
}
%model();
```

Using the `%` modifier does not only make the part transparent, it also causes the part to be excluded in the final render!

**Difference / Intersection with wrong translated objects:**

The easiest way to solve this type of issues is to highlight the objects using the `#` modifier and see if the objects are placed at the position where they should be.

**Importing broken STL files:**

See the import FAQ section above.

### OpenSCAD crashed/was killed, are my unsaved changes lost?

Before starting a preview or render a backup file is made of the current .scad file. It is saved in the user's Documents folder in an "OpenSCAD" folder:

- **Windows 11:** `C:\Users\xxxx\Documents\OpenSCAD\backups`
- **Linux:** `$HOME/.local/share/OpenSCAD/backups`

The path can be seen in the app in the pop-up window shown by menu item Help > Library Info dialog titled "Backup Path".

### OpenSCAD crashes when clicking "New" or loading a file on Windows

OpenSCAD crashes on some machines with Intel graphics drivers. See [GitHub issue #2442](https://github.com/openscad/openscad/issues/2442) for details.

### OpenSCAD fails to run due to missing DLLs

This is an issue with the special Windows N (Europe) and KN (Korea) versions from which the Windows Media Framework was removed.

The missing files are `EVR.dll`, `MF.dll`, or `MFPlat.dll`.

OpenSCAD, starting with release 2019.05, depends on some of the features so it fails to run on those systems.

The missing Windows Media Framework can be added by installing the correct "Media Feature Pack for N versions" from Microsoft. Starting with Windows 10 1909 you can install it via: Windows Settings > Apps > Apps and Features > Optional Features > Add a Feature and find the Media Feature Pack in the list.

## Reporting bugs, Requesting features

### How do I report bugs?

Bugs in OpenSCAD are best reported in the [GitHub issue tracking system](https://github.com/openscad/openscad/issues). If you are not sure it's a bug ask about it in the IRC chat.

Please search existing issues if the bug was already reported. Make your report as complete as possible so that we can reproduce it. Include:

- The OpenSCAD version (Menu Help > About and Help > Library Info, or `openscad --info`)
- The Operating System name and version
- Describe your workflow that led to the problem
- Graphics issues: the OpenGL driver information
- Your script (if relevant)

### How do I request new features?

New features or changes/extensions to existing features can be requested in the [GitHub issue tracking system](https://github.com/openscad/openscad/issues).

Please make an effort to clearly explain the new feature / change as detailed as possible. Including some background about why you think this feature would be useful helps a lot and increases the chances of it being implemented.

### Best Way to Report OS Specific Bugs?

The versions for Windows and Mac OS X are currently maintained by the OpenSCAD team, so please use the GitHub issue tracker.

The OpenSCAD versions in the various Linux distributions are usually maintained by them. Bugs specific to an OS should be reported in their respective systems:

- **Debian** - See "please report it" directions
- **Ubuntu** - See "Report a bug" directions
- **Fedora / Red Hat** - See the current list and use their page to report
- **Arch Linux** - See "reporting bug guidelines" directions
