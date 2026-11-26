# OpenSCAD User Manual

> **Source:** <https://en.wikibooks.org/wiki/OpenSCAD_User_Manual>

## Introduction

OpenSCAD is software for creating solid 3D CAD objects. It is free software and available for GNU/Linux, Microsoft Windows and Mac OS X.

Unlike most free software for creating 3D models (such as the well-known application Blender), OpenSCAD does not focus on the artistic aspects of 3D modelling, but instead focuses on the CAD aspects. So it might be the application you are looking for when you are planning to create 3D models of machine parts, but probably is not what you are looking for when you are more interested in creating computer-animated movies or organic life-like models.

OpenSCAD, unlike many CAD products, is not an interactive modeler. Instead it is something like a 2D/3D-compiler that reads in a program file that describes the object and renders the model from this file. This gives you (the designer) full control over the modelling process. This enables you to easily change any step in the modelling process and make designs that are defined by configurable parameters.

OpenSCAD has two main operating modes, Preview and Render. Preview is relatively fast using 3D graphics and the computer's GPU, but is an approximation of the model and can produce artifacts; Preview uses OpenCSG and OpenGL. Render generates exact geometry and a fully tessellated mesh. It is not an approximation and as such it is often a lengthy process, taking minutes or hours for larger designs. Render uses CGAL as its geometry engine.

OpenSCAD provides two types of 3D modelling:

- **Constructive Solid Geometry (CSG)**
- **Extrusion of 2D primitives into 3D space**

SVG is used for 2D while Autocad DXF files can be used as well for the data exchange format for 2D outlines. In addition to 2D paths for extrusion it is also possible to read design parameters from DXF files. Besides DXF files, OpenSCAD can read and create 3D models in the open 3mf, STL, OFF and many more file formats.

OpenSCAD can be downloaded from <https://www.openscad.org/>.

## Additional Resources

- An [interactive web version of OpenSCAD](https://ochafik.com/openscad2/) can be used to play with an scad script
- A clear guided introduction is available in the [OpenSCAD Tutorial](https://en.wikibooks.org/wiki/OpenSCAD_Tutorial)
- The [Mastering OpenSCAD](https://mastering-openscad.eu/) website has a nice tutorial on the basics and offers complex examples
- A [cheat sheet](https://openscad.org/cheatsheet/) is a useful quick reference for the OpenSCAD language

---

## The OpenSCAD User Manual

- [Introduction](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Introduction)
- [First Steps](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/First_Steps)
- [The OpenSCAD User Interface](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_User_Interface)
- [Input Devices](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Input_Devices)
- [Customizer](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Customizer)
- [Import - STL, 3MF, OFF, AMF, DXF, SVG, CSG](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Importing_Geometry)
  - [SVG Import](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/SVG_Import)
- [Export - STL, 3MF, OFF, AMF, DXF, SVG, CSG, PNG](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Exporting_Geometry)
  - [STL Export](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/STL_Export)
  - [CSG Export](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/CSG_Export)
- [DXF Extrusion](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/DXF_Extrusion)
- [Other 2D formats](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Other_2D_formats)
- [Example Projects](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Example_Projects)
  - [Strandbeest](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Strandbeest)
- [Paths](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Paths)
- [Using an external Editor with OpenSCAD](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_an_external_Editor_with_OpenSCAD)
- [Integration with other applications](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Integration_with_other_applications)
- [Using OpenSCAD in a command line environment](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment)
- [Building OpenSCAD from Sources](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Building_OpenSCAD_from_Sources)
  - [Building on Linux/UNIX](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Building_on_Linux/UNIX)
  - [Cross-compiling for Windows on Linux or Mac OS X](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Cross-compiling_for_Windows_on_Linux_or_Mac_OS_X)
  - [Building on Windows (Outdated)](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Building_on_Windows)
  - [Building on Windows (New)](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Building_on_Windows_(New))
  - [Building on Mac OS X](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Building_on_Mac_OS_X)
  - [Submitting patches](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Submitting_patches)
- [Frequently Asked Questions](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/FAQ)
- [Libraries](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries)
- [Tips and Tricks](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Tips_and_Tricks)
- [Command Glossary](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Command_Glossary) -- Very short name and syntax reference

---

## The OpenSCAD Language Reference

- [The OpenSCAD Language](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language)
- [General](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/General) -- READ THIS FIRST -- comments, values and data types, variables, vectors, objects, getting input

### 3D Objects

- [3D Primitive Solids](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids) -- cube, sphere, cylinder, polyhedron
- [3D to 2D Projection](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/3D_to_2D_Projection)

### 2D Objects

- [2D Primitives](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/2D_Primitives) -- square, circle, polygon
- [Text](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Text) -- Generate text using installed or user supplied font files; functions to retrieve text metrics
- [2D to 3D](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/2D_to_3D_Extrusion) -- linear_extrude, rotate_extrude

### Transform

- [color](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Transformations#color)
- [rotate, translate, mirror, multmatrix](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Transformations)
- [scale, resize](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Transformations#scale)
- [offset, minkowski, hull](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Transformations#offset)
- [Combining transformations](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Transformations#Combining_transformations)

### Boolean Combination

- [union, difference, intersection, render](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/CSG_Modelling)

### Other Functions and Operators

- [Conditional and Iterator Functions](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Conditional_and_Iterator_Functions) -- for, intersection_for, if, conditional ? :, assign, let

#### Mathematical Operators

- General, Vectors, Matrix multiplication

#### Mathematical Functions

- **Trigonometric:** cos, sin, tan, acos, asin, atan, atan2
- **Other:** abs, ceil, concat, cross, exp, floor, ln, len, let, log, lookup, max, min, norm, pow, rands, round, sign, sqrt

#### String Functions

- str, chr, ord

#### Type Test Functions

- is_undef, is_bool, is_num, is_string, is_list, is_object

- [List Comprehensions](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/List_Comprehensions)
- [Other Language Features](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Other_Language_Features) -- Special '$' variables, echo, render, surface, search, version(), version_num(), parent_module(n) and $parent_modules, assert
- [User-Defined Functions and Modules](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/User-Defined_Functions_and_Modules) -- Functions, Modules, Children
- [Debugging aids](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Debugging_aids) -- % # ! * echo

### External Libraries and Code Files

- [include](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Include_Statement) -- SCAD, CSG
- [use](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Use_Statement) -- SCAD
- [import](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Importing_Geometry) -- STL, OFF, DXF
- import_dxf -- Deprecated
- import_stl -- Deprecated
- [export](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Exporting_Geometry) -- STL, OFF, AMF, 3MF, DXF, SVG, PNG, CSG
- [surface](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Other_Language_Features#surface) -- PNG

---

## Work in Progress

This section contains documentation about ongoing work which is available as experimental features in snapshot versions of OpenSCAD or not yet integrated at all and pending in a branch or pull-request at the [OpenSCAD github repository](https://github.com/openscad/openscad).

---

*This page was last edited on 6 December 2025. Text is available under the Creative Commons Attribution-ShareAlike License.*
