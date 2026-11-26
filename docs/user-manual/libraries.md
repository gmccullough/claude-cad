# OpenSCAD User Manual: Libraries

> Source: [https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries)

## Library locations

OpenSCAD uses three library locations, the installation library, built-in library, and user-defined libraries.

- **The Installation library** location is the libraries directory under the directory where OpenSCAD is installed.
- **The Built-In library** location is O/S dependent. Since version 2014.03, it can be opened in the system specific file manager using the "File->Show Library Folder..." menu entry.
  - **Windows:** `My Documents\OpenSCAD\libraries`
  - **Linux:** `$HOME/.local/share/OpenSCAD/libraries`
  - **Mac OS X:** `$HOME/Documents/OpenSCAD/libraries`
- **The User-Defined library path** can be created using the `OPENSCADPATH` Environment Variable to point to the library(s). `OPENSCADPATH` can contain multiple directories in case you have library collections in more than one place, separate directories with a semi-colon for Windows, and a colon for Linux/Mac OS.

Examples:

- **Windows:** `C:\Users\A_user\Documents\OpenSCAD\MyLib;C:\Thingiverse Stuff\OpenSCAD Things;D:\test_stuff`
- **Linux/Mac OS:** `/usr/lib:/home/mylib:.`

OpenSCAD must be restarted to recognize any change to the `OPENSCADPATH` Environment Variable.

When you specify a non-fully qualified path and filename in the `use <...>` or `include <...>` statement OpenSCAD looks for the file in the following directories in the following order:

1. The directory of the calling `.scad` file
2. The User-Defined library paths (`OPENSCADPATH`)
3. The Built-In library (i.e. the O/S dependent locations above)
4. The Installation library

In the case of a library file itself having `use <...>` or `include <...>` the directory of the library `.scad` file is the 'calling' file, i.e. when looking for libraries within a library, it does not check the directory of the top level `.scad` file.

For example, with the following locations and files defined (with `OPENSCADPATH=/usr/lib:/home/lib_os:.`):

```
1. <installation library>/lib1.scad
2. <built-in library>/lib2.scad
3. <built-in library>/sublib/lib2.scad
4. <built-in library>/sublib/lib3.scad
5. /usr/lib/lib2.scad
6. /home/lib_os/sublib/lib3.scad
```

The following `include <...>` statements match to the nominated library files:

```openscad
include <lib1.scad>          // #1.
include <lib2.scad>          // #5.
include <sublib/lib2.scad>   // #3.
include <sublib/lib3.scad>   // #6.
```

Since 2014.03, the currently active list of locations can be verified in the "Help->Library Info" dialog.

The details info shows both the content of the `OPENSCADPATH` variable and the list of all library locations. The locations are searched in the order they appear in this list:

```
OPENSCADPATH: /data/lib1:/data/lib2
OpenSCAD library path:
  /data/lib1
  /data/lib2
  /home/user/.local/share/OpenSCAD/libraries
  /opt/OpenSCAD/libraries
```

## Setting OPENSCADPATH

### Windows

Windows 11, any version:

1. Access the environment variable editor from the Control Panel > System > About panel
   - Right Click "This PC" icon on the desktop, OR
   - Start Menu > Settings > System > (scroll down) About, OR
   - Start Menu > Settings and search for "env"
2. Scroll down to between Device Specifications and Windows Specifications
3. Select Advanced System Options
4. A pop-up will let you confirm that you allow access to admin level System Properties
5. Select the Advanced Tab, then the Environment Variables button
6. Best to set `OPENSCADPATH` as a personal env var, rather than a System Variable
7. Click the New... button
8. Set `OPENSCADPATH` as the new name
9. Set `%USERPROFILE%\Documents\OpenSCAD\libraries` as the content

**Note:** The folder `~/AppData/Local/OpenSCAD/` is not normally used by OpenSCAD for libraries.

### On Linux

The environment variable may be set for all users by using a command to append the definition to the end of the global profile definition file in a terminal session:

**Note:** the use of `sudo` gives the required admin privilege to the command so be prepared with the admin password.

```bash
# shell
sudo sh -c 'echo "OPENSCADPATH=$HOME/openscad/libraries" >>/etc/profile'

# bash
sudo bash -c 'echo "export OPENSCADPATH=$HOME/openscad/libraries" >>/etc/profile'

# zsh
sudo zsh -c 'echo "export OPENSCADPATH=$HOME/openscad/libraries" >>/etc/profile'

# csh
sudo csh -c 'echo "setenv OPENSCADPATH $HOME/openscad/libraries" >>/etc/csh.cshrc'
```

**Warning:** the shell profile setup files `.bashrc` or `.zshrc` are only used when starting new interactive sessions. Variables that should be available for headless operations, like `OPENSCADPATH`, should be set as suggested above.

Or, the variable may be set only for one's own account without sudo:

```bash
# shell
sh -c 'echo "OPENSCADPATH=$HOME/openscad/libraries" >>~/profile'

# bash
bash -c 'echo "export OPENSCADPATH=$HOME/openscad/libraries" >>~/.bash_profile'

# zsh
zsh -c 'echo "export OPENSCADPATH=$HOME/openscad/libraries" >>~/.zprofile'

# csh
csh -c 'echo "setenv OPENSCADPATH $HOME/openscad/libraries" >>~/.cshrc'
```

If there is a chance that `OPENSCADPATH` has been set globally, and the personal folder should be appended to the global PATH:

```bash
export OPENSCADPATH=$OPENSCADPATH:~/.config/openscad/libraries
# OR perhaps
export OPENSCADPATH=$OPENSCADPATH:$XDG_CONFIG_HOME/openscad/libraries
```

### Mac OS X

To set the `OPENSCADPATH` globally so that it is set for all users to a folder in each users' home folder give this command in a terminal window:

```bash
launchctl setenv OPENSCADPATH "$HOME/my/own/path"
```

For more control on environment variables, you'll need to edit the configuration files. On Mac, you need to modify the `/etc/launchd.conf`:

```bash
sudo sh -c 'echo "setenv OPENSCADPATH /Users/myuser/my/own/path" >>/etc/launchd.conf'
```

The variable will be available at next reboot. To avoid rebooting and use it immediately:

```bash
egrep "^setenv\ " /etc/launchd.conf | xargs -t -L 1 launchctl
killall Dock
killall Spotlight
```

## MCAD

OpenSCAD bundles the MCAD library.

MCAD bundles a lot of stuff, of varying quality, including:

- Many common shapes like rounded boxes, regular polygons and polyhedra in 2D and 3D
- Gear generator for involute gears and bevel gears
- Stepper motor mount helpers, stepper and servo outlines
- Nuts, bolts and bearings
- Screws and augers
- Material definitions for common materials
- Mathematical constants, curves
- Teardrop holes and polyholes

The git repo also contains python code to scrape OpenSCAD code, a testing framework and SolidPython, an external python library for solid cad.

More details on using MCAD are in a later chapter, [OpenSCAD User Manual/MCAD](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/MCAD).

## Other libraries

- **Belfry OpenScad Library** - has many shapes, masks, manipulators, and support for threading, gears, polylines and beziers.
- **Bevel library for OpenScad**
- **BOLTS** - tries to build a standard part and vitamin library that can be used with OpenSCAD and other CAD tools.
- **Celtic knot library** - used for the generation of celtic knots.
- **Colorspace converter** - for working with colors in HSV and RGB.
- **Dimensioned Drawings** - provides tools to create proper 2D technical drawings of your 3D objects.
- **DotSCAD** - comprehensive library of 2D and 3D operations and transforms including extrusion along arbitrary paths, shape bending, etc.
- **Fillets** - a comprehensive fillets library by Stephanie Shaltes.
- **Local.scad** - provides a flexible method for positioning parts of a design. Is also used in BOLTS.
- **Michigan Tech's Open Sustainability Technology Lab (MOST) libraries**
- **Obiscad** - contains various useful tools, notably a framework for attaching modules on other modules in a simple and modular way.
- **OpenSCAD threads library** - provides ISO conform metric and imperial threads and support internal and external threads and multiple starts.
- **Pinball Library** - provides many components for pinball design work, including models for 3d printing of the parts, 3d descriptions of mount holes for CNC drilling and 2d descriptions of parts footprint.
- **Regular shapes library** by Giles Bathgates - provides regular polygons and polyhedra and is included in MCAD.
- **Roller Chain Sprockets OpenSCAD Module** - lets you create sprockets for ANSI chains and motorcycle chains. Contains hard coded fudge factors, may require tweaking.
- **SCADBoard** - a library for designing 3D printed PCBs in OpenSCAD.
- **Shapes library** - contains many shapes like rounded boxes, regular polygons. It is also included in MCAD.
- **The 2D connection library** - helps with connections between 2D sheets, which is useful for laser cut designs.
- **Ruler** - helps in determining the size of things in OpenSCAD.
- **Knurled surface library** by aubenc
- **Text module** - based on technical lettering style.
- **Round corners for OpenSCAD**
- **Unit test framework**
- **Utility function collection**
- **Workflow library** - full workflows, by Ulrich Bar

There is also a list with more libraries here: [https://github.com/openscad/openscad/wiki/Libraries](https://github.com/openscad/openscad/wiki/Libraries)

## Other OpenSCAD tutorials and documentation

- [OpenSCAD User Manual](http://www.openscad.org/documentation.html)
- [Know only 10 things to be dangerous in OpenSCAD](https://cubehero.com/2013/11/19/know-only-10-things-to-be-dangerous-in-openscad/)
- [OpenScad beginners tutorial](http://edutechwiki.unige.ch/en/OpenScad_beginners_tutorial)
- [How to use Openscad, tricks and tips to design a parametric 3D object](http://www.tridimake.com/2014/09/how-to-use-openscad-tricks-and-tips-to.html)
- [OpenSCAD discussion forum](http://forum.openscad.org)
