# OpenSCAD User Manual: Customizer

> Source: [https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Customizer](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Customizer)

**Note: Requires version 2019.05**

The Customizer feature provides a graphic user interface for editing model parameters. With this feature one does not need to edit the code to change the values of the parameters / variables. Programmers can create templates for a given model, and customize these further to adapt to different needs / users. Sets of parameter values can also be saved, which effectively saves a variant of a particular model.

## Activation of Customizer panel

If the Customizer panel is not displayed, use the menu toggle **Window > Hide customizer** to make it visible.

## Supported Variables

The customizer displays all variables that meet the following criteria:

- The variable is assigned in the main file. Customizer will not display variables from files brought in via `include` and `use` (though with `include`, they can still be referenced in the calling script).
- The variable has a simple literal value -- string, number, or boolean -- or a list of up to four numeric literals.
- The variable is not assigned in a "Hidden" section, as defined by a line containing only the comment `/* [Hidden] */` (details below).
- The assignment statement must appear before the first `{` syntax element. Some scripts contain an empty module near the top for just this purpose, for instance:

```openscad
module __Customizer_Limit__ () {}  // Hide following assignments from Customizer.
debug_mode = false;
```

Because it appears after a `{`, the Customizer does not display the variable `debug_mode`. This is an old-fashioned way of ending the list of customizable parameters -- the comment `/* [Hidden] */` is considered a best-practice way to do this now.

**Note:** It is possible to enter a module or function containing no `{` character, which would not stop the Customizer from displaying subsequent variables.

```openscad
module does_not_stop_customizer () echo("Some text");
shown_by_customizer = true;        // still displayed by Customizer
```

As mentioned above, only simple literals and arrays of up to four numbers are available as parameters. Examples for literals are:

```openscad
a = "Text";
b = 123;
c = 456.789;
d = [1,2,3,4];
```

Expressions (even trivial examples) like:

```openscad
e = str("String"," ","concat");
f = 12 + 0.5;
```

are not supported as parameters.

## Syntax support for generation of the customization form

```openscad
// variable description
variable name = defaultValue; // possible values
```

The description comment must be adjusted to the left column of the source file, without spaces.

Following is the syntax for how to define different types of widgets in the form:

### Drop down box

```openscad
// combo box for number
Numbers=2; // [0, 1, 2, 3]

// combo box for string
Strings="foo"; // [foo, bar, baz]

//labeled combo box for numbers
Labeled_values=10; // [10:S, 20:M, 30:L]

//labeled combo box for string
Labeled_value="S"; // [S:Small, M:Medium, L:Large]
```

### Slider

Only numbers are allowed in this one, specify any of the following:

```openscad
// slider widget for number with max. value
sliderWithMax =34; // [50]

// slider widget for number in range
sliderWithRange =34; // [10:100]

//step slider for number
stepSlider=2; //[0:5:100]

// slider widget for number in range
sliderCentered =0; // [-10:0.1:10]
```

Note that this:

```openscad
// slider widget for number with max. value
sliderWithMax =34; // [50]
```

is mainly for compatibility with Thingiverse.

### Checkbox

Not supported by Thingiverse.

```openscad
//description
Variable = true;
```

### Spinbox

```openscad
// spinbox with step size 1
Spinbox= 5;

// spinbox with step size 0.5
Spinbox= 5.5; // .5
```

### Textbox

**NOTE:** The text box example only works in release version 2021.01, it may not work in future versions!

```openscad
// Text box for string
String="hello";

// Text box for string with length 8
String="length"; //8
```

### Special vector

```openscad
//Spin box for vector with less than or equal to 4 elements
Vector2=[12,34];
Vector3=[12,34,45];
Vector4=[12,34,45,23];
```

You can also set a range for the vector:

```openscad
VectorRange3=[12,34,46]; //[1:2:50]
VectorRange4=[12,34,45,23]; //[1:50]
```

### Unavailable customizations

Some desirable customization constraints are not supported currently.

- Multi-line text boxes.
- Directly editable (non-spinbox) numeric values:

```openscad
SerialNumber = 0; //[::non-negative integer]
Offset = 10.0;    //[::float]
```

## Creating Tabs

Parameters can be grouped into tabs. This feature allows related parameters to be associated into groups. The syntax is very similar the Thingiverse rules for tabs. To create a tab, use a multi-line block comment like this:

```openscad
/* [Tab Name] */
```

Also possible, but not recommended:

```openscad
/* [Tab] [Name] */
```

Three tab names have a special functionality:

### [Global]

Parameters in the Global tab are always shown on every tab no matter which tab is selected. No tab is shown for Global parameters; they appear in all the tabs.

### [Hidden]

Parameters in the Hidden tab (with first letter uppercase) are never displayed. Not even the tab is shown. This prevents global variables that have not been parameterized for the Thingiverse or OpenSCAD Customizer from showing up in the Customizer interface or widget. Included for compatibility with Thingiverse.

You can have multiple segments under the Hidden group. See also hidden parameters below.

### parameters

Parameters that are not under any tab are displayed under a tab named "parameters". In Thingiverse, these parameters are listed with no tab.

## Example showcasing most features

```openscad
/* [Drop down box:] */
// combo box for number
Numbers=2; // [0, 1, 2, 3]

// combo box for string
Strings="foo"; // [foo, bar, baz]

//labeled combo box for numbers
Labeled_values=10; // [10:L, 20:M, 30:XL]

//labeled combo box for string
Labeled_value="S"; // [S:Small, M:Medium, L:Large]

/*[ Slider ]*/
// slider widget for number
slider =34; // [10:100]

//step slider for number
stepSlider=2; //[0:5:100]

/* [Checkbox] */

//description
Variable = true;

/*[Spinbox] */

// spinbox with step size 1
Spinbox = 5;

/* [Textbox] */

// Text box for string
String="hello";

/* [Special vector] */
//Text box for vector with less than or equal to 4 elements
Vector1=[12]; //[0:2:50]
Vector2=[12,34]; //[0:2:50]
Vector3=[12,34,46]; //[0:2:50]
Vector4=[12,34,46,24]; //[0:2:50]

/* [Hidden] */
debugMode = true;
```

## Saving Parameters value in JSON file

This feature gives the user the ability to save the values of all parameters. JSON parameter values can be then reused through the command line.

### Cmdline

```bash
openscad -o model-2.stl -p parameters.json -P model-2 model.scad

openscad -o <output-file> -p <parametric-file (JSON File)> -P <NameOfSet> <input-file SCAD file>
```

- `-p` is used to give input JSON file in which parameters are saved.
- `-P` is used to give the name of the set of the parameters written in JSON file.

And JSON file is written in the following format:

```json
{
    "parameterSets":
    {
        "FirstSet": {
            "Labeled_values": "13",
            "Numbers": "18",
            "Spinbox": "35",
            "Vector": "[2, 34, 45, 12, 23, 56]",
            "slider": "2",
            "stepSlider": "12",
            "string": "he"
        },
        "SecondSet": {
            "Labeled_values": "10",
            "Numbers": "8",
            "Spinbox": "5",
            "Vector": "[12, 34, 45, 12, 23, 56]",
            "slider": "12",
            "stepSlider": "2",
            "string": "hello"
        }
    },
    "fileFormatVersion": "1"
}
```

General format:

```json
{
    "parameterSets":{
        "set-name":{
            "parameter-name": "value",
            "parameter-name": "value"
        },
        "set-name":{
            "parameter-name": "value",
            "parameter-name": "value"
        }
    },
    "fileFormatVersion": "1"
}
```

### GUI

Through GUI you can easily apply and save Parameters in a JSON file using the Preset section in Customizer explained below.

In customizer, the first line of options is as follows:

- **Automatic Preview:** If checked, the preview of the model is automatically updated when you change any parameter in Customizer, else you must click the preview button or press F5 after you update parameters in the Customizer.
- **Show Details:**
  - **Show Details:** If chosen, the description for the parameter appears below the parameter name.
  - **Inline Details:** If chosen, the description for the parameter appears next to the parameter name. Long descriptions get clipped. This option is a compromise between vertical space usage and retaining part of the description.
  - **Hide Details:** Details are suppressed although you still can view the description by hovering the cursor over the input widget.
- **Reset button:** When clicked, it resets the values of all input widgets for the parameter to the defaults provided in SCAD file.

Next comes Preset section: It consists of four buttons:

- **combo Box** - It is used to select the set of parameters to be used
- **+ button** - add new set of the parameters
- **- button** - It is used to delete the set selected in combo Box.
- **save preset button** - save/overwrite the current preset

And finally below Preset Section is the place where you can play with the parameters.

You can also refer to two examples that are part of OpenSCAD to learn more:

- `Parametric/sign.scad`
- `Parametric/candlStand.scad`

### Manually create datasets

You can manually create a dataset by modifying the JSON file according to the above format and defining your own variables. When a dataset is loaded, only the parameters defined in the dataset are modified, other parameters are not set to defaults. This allows one to create partial datasets consisting of modifiers, not complete datasets.

### Hidden parameters

Variables belonging to the hidden group are stored in the JSON file, but are not retrieved from the JSON file.

Meaning: If a variable is moved from the hidden group to another group, it also becomes applicable. This allows a designer to use the hidden group for reserved variables, that become customizable (and assigned with a different default) in a future version, without breaking existing presets.

A hidden variable can also be used as a "last saved with" indicator, that can be read by manually viewing the JSON file.

The idea is, that the customizer only modifies variables that the user can see and control from the customizer UI.

## Tips and Tricks

### Set Range and Stepping

The customizer tries to guess an appropriate range and stepping, but may give inconsistent results depending on your design intent. For example, the customizer also treats numbers like 0.0, 1.0, 2.0 etc. as integers. The customizer also does not know whether negative numbers make sense. It is therefore recommended to supply range and step as comments. Keep in mind, that if in doubt, the user can always modify the SCAD file.

Do not hesitate to limit the range. For instance, in the design of a smart phone holder, limit the size to reasonable smart phone sizes. If someone wants to use your smart phone holder as a tablet holder, they always can directly edit the SCAD file itself. This act also makes the user aware, that the design was not meant as a tablet holder and that they might need for example to modify the support structure.

### Scroll Wheel

The buttons on the spinboxes are small, but you can use the scroll wheel on your mouse to change the value comfortably. First, click on the spin box to focus the spin box.

## Examples

### color

```openscad
cubeColor = [1,0.5,0]; //[0:0.1:1]
sphereColor = "blue"; // [red, green, blue]

echo(cubeColor);

color(cubeColor)
cube();

color(sphereColor)
sphere();
```
