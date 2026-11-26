# OpenSCAD User Manual: Using OpenSCAD in a command line environment

> Source: [https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment)

## Command line usage

OpenSCAD can not only be used as a GUI, but also handles command line arguments.

### OpenSCAD (DEV/nightly) 2025.08.17 options

```
Usage: openscad.exe [options] file.scad
Allowed options:
  --export-format arg               overrides format of exported scad file when
                                    using option '-o', arg can be any of its
                                    supported file extensions.  For ascii stl
                                    export, specify 'asciistl', and for binary
                                    stl export, specify 'binstl'.  Ascii export
                                    is the current stl default, but binary stl
                                    is planned as the future default so
                                    asciistl should be explicitly specified in
                                    scripts when needed.

  -o [ --o ] arg                    output specified file instead of running
                                    the GUI. The file extension specifies the
                                    type: stl, off, wrl, amf, 3mf, csg, dxf,
                                    svg, pdf, png, echo, ast, term, nef3,
                                    nefdbg, param, pov. May be used multiple
                                    times for different exports. Use '-' for
                                    stdout.

  -O [ --O ] arg                    pass settings value to the file export
                                    using the format section/key=value, e.g
                                    export-pdf/paper-size=a3. Use --help-export
                                    to list all available settings.
  -D [ --D ] arg                    var=val -pre-define variables
  -p [ --p ] arg                    customizer parameter file
  -P [ --P ] arg                    customizer parameter set
  --enable arg                      enable experimental features (specify 'all'
                                    for enabling all available features): roof
                                    | input-driver-dbus | lazy-union |
                                    vertex-object-renderers-indexing |
                                    textmetrics | import-function |
                                    predictible-output

  -h [ --help ]                     print this help message and exit
  --help-export                     print list of export parameters and values
                                    that can be set via -O
  -v [ --version ]                  print the version
  --info                            print information about the build process

  --camera arg                      camera parameters when exporting png:
                                    =translate_x,y,z,rot_x,y,z,dist or
                                    =eye_x,y,z,center_x,y,z
  --autocenter                      adjust camera to look at object's center
  --viewall                         adjust camera to fit object
  --backend arg                     3D rendering backend to use: 'CGAL'
                                    (old/slow) [default] or 'Manifold'
                                    (new/fast)
  --imgsize arg                     =width,height of exported png
  --render arg                      for full geometry evaluation when exporting
                                    png
  --preview arg                     [=throwntogether] -for ThrownTogether
                                    preview png
  --animate arg                     export N animated frames
  --animate_sharding arg            Parameter <shard>/<num_shards> - Divide
                                    work into <num_shards> and only output
                                    frames for <shard>. E.g. 2/5 only outputs
                                    the second 1/5 of frames. Use to
                                    parallelize work on multiple cores or
                                    machines.
  --view arg                        =view options: axes | crosshairs | edges |
                                    scales
  --projection arg                  =(o)rtho or (p)erspective when exporting
                                    png
  --csglimit arg                    =n -stop rendering at n CSG elements when
                                    exporting png
  --summary arg                     enable additional render summary and
                                    statistics: all | cache | time | camera |
                                    geometry | bounding-box | area
  --summary-file arg                output summary information in JSON format
                                    to the given file, using '-' outputs to
                                    stdout
  --colorscheme arg                 =colorscheme: *Cornfield | Metallic |
                                    Sunset | Starnight | BeforeDawn | Nature |
                                    Daylight Gem | Nocturnal Gem | DeepOcean |
                                    Solarized | Tomorrow | Tomorrow Night |
                                    ClearSky | Monotone

  -d [ --d ] arg                    deps_file -generate a dependency file for
                                    make
  -m [ --m ] arg                    make_cmd -runs make_cmd file if file is
                                    missing
  -q [ --quiet ]                    quiet mode (don't print anything *except*
                                    errors)
  --hardwarnings                    Stop on the first warning
  --trace-depth arg                 =n, maximum number of trace messages
  --trace-usermodule-parameters arg =true/false, configure the output of user
                                    module parameters in a trace
  --check-parameters arg            =true/false, configure the parameter check
                                    for user modules and functions
  --check-parameter-ranges arg      =true/false, configure the parameter range
                                    check for builtin modules
  --debug arg                       special debug info - specify 'all' or a set
                                    of source file names
  -s [ --s ] arg                    stl_file deprecated, use -o
  -x [ --x ] arg                    dxf_file deprecated, use -o
```

### Export help (2025.08.17)

```
List of settings that can be given using the -O option using the
format '<section>/<key>=value', e.g.:
openscad -O export-pdf/paper-size=a6 -O export-pdf/show-grid=false

Section 'export-pdf':
  - paper-size (enum): [a6,a5,<a4>,a3,letter,legal,tabloid]
  - orientation (enum): [<portrait>,landscape,auto]
  - show-filename (bool): <true>/false
  - show-scale (bool): <true>/false
  - show-scale-message (bool): <true>/false
  - show-grid (bool): <true>/false
  - grid-size (double): 1.000000 : <10.000000> : 100.000000
  - add-meta-data (bool): <true>/false
  - meta-data-title (string): ""
  - meta-data-author (string): ""
  - meta-data-subject (string): ""
  - meta-data-keywords (string): ""

Section 'export-3mf':
  - color-mode (enum): [<model>,none,selected-only]
  - unit (enum): [micron,<millimeter>,centimeter,meter,inch,foot]
  - color (string): "#f9d72c"
  - material-type (enum): [color,<basematerial>]
  - decimal-precision (int): 1 : <6> : 16
  - add-meta-data (bool): <true>/false
  - meta-data-title (string): ""
  - meta-data-designer (string): ""
  - meta-data-description (string): ""
  - meta-data-copyright (string): ""
  - meta-data-license-terms (string): ""
  - meta-data-rating (string): ""
```

### OpenSCAD 2021.01 options

```
Usage: openscad [options] file.scad
Allowed options:
  --export-format arg          overrides format of exported scad file when
                               using option '-o', arg can be any of its
                               supported file extensions.  For ascii stl
                               export, specify 'asciistl', and for binary stl
                               export, specify 'binstl'.

  -o [ --o ] arg               output specified file instead of running the
                               GUI, the file extension specifies the type: stl,
                               off, wrl, amf, 3mf, csg, dxf, svg, pdf, png,
                               echo, ast, term, nef3, nefdbg

  -D [ --D ] arg               var=val -pre-define variables
  -p [ --p ] arg               customizer parameter file
  -P [ --P ] arg               customizer parameter set
  --enable arg                 enable experimental features

  -h [ --help ]                print this help message and exit
  -v [ --version ]             print the version
  --info                       print information about the build process

  --camera arg                 camera parameters when exporting png
  --autocenter                 adjust camera to look at object's center
  --viewall                    adjust camera to fit object
  --imgsize arg                =width,height of exported png
  --render                     for full geometry evaluation when exporting png
  --preview arg                [=throwntogether] -for ThrownTogether preview png
  --animate arg                export N animated frames
  --view arg                   =view options: axes | crosshairs | edges |
                               scales | wireframe
  --projection arg             =(o)rtho or (p)erspective when exporting png
  --csglimit arg               =n -stop rendering at n CSG elements
  --summary arg                enable additional render summary and statistics
  --summary-file arg           output summary information in JSON format
  --colorscheme arg            =colorscheme

  -d [ --d ] arg               deps_file -generate a dependency file for make
  -m [ --m ] arg               make_cmd -runs make_cmd file if file is missing
  -q [ --quiet ]               quiet mode
  --hardwarnings               Stop on the first warning
  --check-parameters arg       =true/false
  --check-parameter-ranges arg =true/false
  --debug arg                  special debug info
```

## Export options

When called with the `-o` option, OpenSCAD does not start the GUI, but executes the given file and exports to the output_file in a format depending on the extension (`.stl` / `.off` / `.dxf`, `.csg`).

Some versions use `-s`/`-d`/`-o` to determine the output file format instead; check with `openscad --help`.

If the option `-d` is given in addition to an export command, all files accessed while building the mesh are written in the argument of `-d` in the syntax of a Makefile.

For at least 2015.03-2+, specifying the extension `.echo` causes openscad to produce a text file containing error messages and the output of all `echo()` calls in filename as they would appear in the console window visible in the GUI. Multiple output files are not supported, so using this option you cannot also obtain the model that would have normally been generated.

**Note:** When exporting to STL, the GUI defaults to binary STL (smaller, faster) and the CLI defaults to ASCII STL (larger, slower). Post-processing pipelines may prefer ASCII STL; they should explicitly say `--export-format asciistl` in preparation for the default eventually changing to binary STL.

### Camera and image output

For 2013.05+, the option to output a `.png` image was added. There are two types of cameras available for the generation of images.

The first camera type is a **'gimbal' camera** that uses Euler angles, translation, and a camera distance, like OpenSCAD's GUI viewport display at the bottom of the OpenSCAD window.

The second camera type is a **'vector' camera**, with an 'eye' camera location vector and a 'lookat' center vector.

`--imgsize x,y` chooses the `.png` dimensions and `--projection` chooses orthogonal or perspective, as in the GUI.

By default, cmdline `.png` output uses Preview mode (F5) with OpenCSG. For some situations it may be desirable to output the full render, with CGAL. This is done by adding `--render` as an option.

### Constants

In order to pre-define variables, use the `-D` option. It can be given repeatedly. Each occurrence of `-D` must be followed by an assignment. Unlike normal OpenSCAD assignments, these assignments don't define variables, but constants, which cannot be changed inside the program, and can thus be used to overwrite values defined in the program at export time.

If you want to assign the `-D` variable to another variable, the `-D` variable MUST be initialized in the main `.scad` program:

```openscad
param1=17;       // must be initialized
val=param1;      // param1 passed via -D on cmd-line
echo(val,param1); // outputs 17,17
```

Without the first line, `val` would be undefined.

The right hand sides can be arbitrary OpenSCAD expressions, including mathematical operations and strings.

Be aware that your shell (bash, cmd, etc.) parses the arguments before passing them to openscad, therefore you need to properly quote or escape arguments with special characters like spaces or quotation marks. For example to assign a string "production" to a quality parameter one has to ensure the `"` characters OpenSCAD expects aren't stripped by the shell. In bash one could write:

```bash
openscad -o my_model_production.stl -D 'quality="production"' my_model.scad
```

Or from the Windows prompt:

```cmd
openscad.com -o my_model_production.stl -D "quality=""production""" my_model.scad
```

Or you may need to escape the inner quotes instead:

```bash
openscad -o my_model_production.stl -D "quality=\"production\"" my_model.scad
```

Note that this sort of double-escaping isn't necessary when executing OpenSCAD from another process that isn't using a shell, because each argument is passed separately. For example a Java application might start a process like so:

```java
pb = new ProcessBuilder("/usr/bin/openscad",
  "-o", "my_model_production.stl",
  "-D", "quality=\"production\"",
  "my_model.scad");
```

### Command to build required files

In a complex build process, some missing files required by an OpenSCAD file can be generated if they are defined in a Makefile. If OpenSCAD is given the option `-m make`, it starts `make file` the first time it tries to access a missing file.

### Processing all .scad files in a folder

Example to convert all the `.scad` in a folder into `.stl`:

In a folder with `.scad` files, make a `.bat` file with text:

```bat
FOR %%f in (*.scad)  DO openscad -o "%%~nf.stl" "%%f"
```

If it closes without processing, check to set the PATH by adding openscad directory to:

Start - Settings - Control Panel - System - Advanced tab - Environment Variables - System Variables, select Path, then click Edit.

Add the openscad directory to the list.

## Makefile example

The `-d` and `-m` options only make sense together. (`-m` without `-d` would not consider modified dependencies when building exports, `-d` without `-m` would require the files to be already built for the first run that generates the dependencies.)

Here is an example of a basic Makefile that creates an `.stl` file from an `.scad` file of the same name:

```makefile
# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

%.stl: %.scad
	openscad -m make -o $@ -d $@.deps $<
```

When `make my_example.stl` is run for the first time, it finds no `.deps` files, and must depend on `my_example.scad`. Because `my_example.stl` is not yet present, it gets created unconditionally. If OpenSCAD finds missing files, it calls make to build them, and it lists all used files in `my_example.stl.deps`.

When `make my_example.stl` is called subsequently, it finds and includes `my_example.stl.deps` and checks if any of the files listed there, including `my_example.scad`, changed since `my_example.stl` was built, based on their time stamps. Only if that is the case, it builds `my_example.stl` again.

### Automatic targets

When building similar `.stl` files from a single `.scad` file, there is a way to automate that too:

```makefile
# match "module foobar() { // `make` me"
TARGETS=$(shell sed '/^module [a-z0-9_-]*().*make..\?me.*$$/!d;s/module //;s/().*/.stl/' base.scad)

all: ${TARGETS}

# auto-generated .scad files with .deps make make re-build always. keeping the
# scad files solves this problem. (explanations are welcome.)
.SECONDARY: $(shell echo "${TARGETS}" | sed 's/\.stl/.scad/g')

# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

%.scad:
	echo -ne 'use <base.scad>\n$*();' > $@

%.stl: %.scad
	openscad -m make -o $@ -d $@.deps $<
```

All objects that are supposed to be exported automatically have to be defined in `base.scad` in their own module with their future file name (without the ".stl"), and have a comment like `// make me` in the line of the module definition. The `TARGETS=` line picks these out of the base file and creates the file names. These are built when `make all` (or `make`, for short) is called.

As the convention from the last example is to create the `.stl` files from `.scad` files of the same base name, for each of these files, an `.scad` file must be generated. This is done in the `%.scad:` paragraph; `my_example.scad` is a simple OpenSCAD file:

```openscad
use <base.scad>
my_example();
```

The `.SECONDARY` line is there to keep make from deleting the generated `.scad` files.

## Windows notes

On Windows, `openscad.com` should be called from the command line as a wrapper for `openscad.exe`. This is because OpenSCAD uses the 'devenv' solution to the Command-Line/GUI output issue. Typing `openscad` at the `cmd.exe` prompt calls the `.com` program wrapper by default.

## MacOS notes

On MacOS the binary is normally hidden inside the App folder. If OpenSCAD is installed in the global Applications folder, it can be called from command line like in the following example that just shows the OpenSCAD version:

```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -v
# OpenSCAD version 2013.06
```

Alternatively, you may create a symbolic link to the binary to make calls from the command line easier:

```bash
sudo ln -sf /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD /usr/local/bin/openscad
```

Now you can call openscad directly without having to type in the full path:

```bash
openscad -v
# OpenSCAD version 2015.03-3
```

On some versions of MacOS, you might get the following error when attempting to run openscad via that link:

```
This application failed to start because it could not find or load the Qt platform plugin "cocoa".

Reinstalling the application may fix this problem.
Abort trap: 6
```

You can fix this by creating a wrapper script to invoke the executable directly:

```bash
sudo rm -f /usr/local/bin/openscad
echo '#!/bin/sh' > test
echo '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD "$@"' >> test
chmod +x test ; sudo mv test /usr/local/bin/openscad
```
