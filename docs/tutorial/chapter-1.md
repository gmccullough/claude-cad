# OpenSCAD Tutorial - Chapter 1

> Source: https://en.wikibooks.org/wiki/OpenSCAD_Tutorial/Chapter_1

---

## A few words about OpenSCAD

OpenSCAD is for crafting 3D models through the art of Constructive Solid Geometry. It unlocks a world of creativity, where elementary operations are like our building blocks.

Let's shape up some fun.

## Getting started with the Tutorial

This tutorial will be your trusted guide. We'll be exploring examples and unveil the secrets of OpenSCAD. By the end of this tutorial, you will have the tools to forge your own unique 3D models, line by line.

With each step, you'll gain confidence and expertise, honing your skills as an image creator. You will breathe code into your designs, crafting intricate structures and bringing your design ideas to fruition.

Throughout this tutorial, we'll be your companion, offering guidance to unlock the full potential of OpenSCAD.

You'll explore, learn, and create.

## User Interface

After starting OpenSCAD the window should look similar to the image below.

The Window is divided in three columns.

- In the **left column**, is the built-in text editor, where the true magic unfolds. As you enter keyboard commands you can view the transformation of code into art.
- In the **middle column**, the displayed 3D View is where your design creations come to life. At the bottom lies the operations sequence console, always ready to lend a helping hand. It unravels the mysteries of mistakes and guides you towards mastery. It is your trusted guidance companion.
- And note the **right column**, the GUI Customizer. It offers the user a gift of ease toolbar, a graphical interface to tweak and twist your model's parameters.

## Creating your first object

Your first object is going to be a perfect cube with side length of 10. In order to create it you need to type the following code in the text editor and hit the preview (first) icon on the action bar below the reference axes.

**a_small_cube.scad**

```openscad
cube(10);
```

There are a few fundamental concepts that you should learn from the start regarding the OpenSCAD scripting language, especially if you don't have a programming background. The word 'cube' is part of OpenSCAD scripting language and is used to command OpenSCAD to create a cube. The 'cube' command is followed by a pair of parentheses, inside of which the parameter size is defined to be 10. Any definition of parameters that a command may require is always done inside a pair of matching parentheses that follow the command word. The semicolon after the last parenthesis indicates the end of that statement, and helps OpenSCAD parse the script that you typed in the text editor. Because a semicolon is used to indicate the end of each statement you have the freedom to format your code in any way you like by inserting whitespace.

**Exercise:**
Try adding some whitespace between the word 'cube' and the first parenthesis and then hit (select) the "preview" option. Is your cube created? Do you get any error message? Try adding some additional whitespace in different places and hit "preview" again to see what you can get away with before getting an error message in the console. What happens if you add whitespace between the syllables 'cu' and 'be' of the word 'cube' and hit "preview"? What happens if you delete the semicolon?

You just read "hit preview" three times in the last paragraph. When you hit "preview" OpenSCAD parses your script and creates the appropriate model. Every time you make a change to your script (e.g. adding whitespace) or later, when adding additional statements, you need to hit "preview" to see the effect of these changes. In case you haven't found the "preview" icon yet, it is the dotted line cube with the two ">>" characters under it. It can also be selected by hitting the F5 key.

**Exercise:**
Try changing the size of the cube to 20 and see what happens. Did you remember to hit preview in order to see your changes take place?

## Creating a slightly different cube

A cube doesn't have to be perfect (equal distance). A cube can have different side lengths. Use the following statement to create a cube (cubical) with side lengths of 25, 35 and 55.

**a_different_cube.scad**

```openscad
cube([25,35,55]);
```

This cube is quite large compared to the previous one. In fact, it is so large it doesn't fit in the viewport. To fix that, hover your mouse over the viewport and scroll out until you can see the entire cube. Zoom in and out by hovering your mouse over the viewport and rotating the scroll wheel. Alternatively, you can use the zoom in (fourth) and out (fifth) icons on the action bar below the viewport. You can let OpenSCAD automatically choose a convenient zoom level by using the view all (third) icon in the same action bar.

**Exercise:**
Try moving your mouse over the viewport and using the scroll wheel to zoom in and out. Try zooming in and out using the corresponding icons. Let OpenSCAD choose a zoom level for you.

Apart from zooming in and out, you can also move and rotate the view of your model. To do so, you need to hover your mouse over the viewport while holding down the right button to move or drag the object. Hold down the left button to rotate the object. Reset the view by clicking on the reset view (sixth) icon on the action bar below the viewport.

**Exercise:**
Try dragging your mouse over the viewport while holding down the right or left button to move or rotate your model.

In order to create a cube with different side lengths, you need to define a pair of brackets with three values inside the parentheses. The pair of brackets is used to denote vector values. The values of the vector need to be comma separated, and correspond to the cube side lengths along the X, Y and Z axes. Previously, you used the cube command to create a perfect cube by defining the value of the size parameter. Most OpenSCAD commands can be used with different parameters, some with more, less or no parameters to achieve different results.

**Exercise:**
Try using the cube command with no parameters. What happens? Use the cube command to create a cube with side lengths of 50, 5 and 10. Use the cube command to create a perfect cube with side length of 17.25.

You should notice that every cube is created on the first octant. You can define an additional parameter named center and set it equal to true, in order to draw the cube centered on the origin.

Here's an example of the complete statement:

**a_centered_cube_with_different_side_lengths.scad**

```openscad
cube([20,30,50],center=true);
```

Notice that when more than one parameter is defined inside the parentheses, they need to be separated with a comma.

**Exercise:**
Try creating a perfect cube or a cube with different side lengths. Use an appropriate additional input parameter to make this cube centered on the origin. If you like, add some whitespace before and after the comma that separates the two parameters.

## Adding more objects and translating objects

The constructive solid modelling approach uses a number of fundamental objects along with a number of ways to transform and combine these objects to create more complex models. The cube that you have been using in the previous examples is one such fundamental object. The fundamental objects are called primitives and are directly available in the OpenSCAD scripting language. A car for example, is not an OpenSCAD primitive, as there is no corresponding keyword in the scripting language. This makes absolute sense because OpenSCAD is a set of modelling tools rather than a library of predefined models. Using the available tools, you can combine the available primitives to create your own car. To do this, you need to know how to add more than one object to your model.

First create a cube with side lengths of 60, 20 and 10 that is centered on the origin.

```openscad
cube([60,20,10],center=true);
```

In order to add a second cube to your model, type an identical statement in the next line of the text editor.

Change the side lengths to 30, 20 and 10.

**a_smaller_cube_covered_by_a_bigger_cube.scad**

```openscad
cube([60,20,10],center=true);
cube([30,20,10],center=true);
```

You should not see any change in your model because the second cube is not larger than the first cube in any dimension, and is currently completely covered by the first cube. By modifying the second statement in the following way, you can translate the second cube to place it on top of the first cube.

**two_cubes.scad**

```openscad
cube([60,20,10],center=true);
translate([0,0,5])
    cube([30,20,10],center=true);
```

You achieve this by using the "translate" command - one of the available transformations. The translate command, as well as the rest of the transformations don't create an object on their own. Rather, they are applied to existing objects to modify them. The translate command can be used to move an object to any point in space. The input parameter for the translate command is a vector of three values. Each value indicates the amount of units that the object will be moved along the X, Y and Z axes. Notice there is no semicolon after the translate command. What follows the translate command is the definition of the object that you wish to translate. The semicolon is added at the end to indicate the completion of the statement.

**Exercise:**
Try changing the input parameter of the translate command, so the cube is translated 5 units along the X axis and 10 units along the Z axis. Try adding some whitespace if you would like to format this statement in a different way. Try adding a semicolon after the translate command.

**two_cubes_barely_touching.scad**

```openscad
cube([60,20,10],center=true);
translate([0,0,10])
    cube([30,20,10],center=true);
```

In the example above, the second cube sits exactly on top of the first cube. This is something that should be avoided, as it's not clear to OpenSCAD whether the two cubes form one object together. This issue can be easily solved by always maintaining a small overlap of about 0.001 - 0.002 between the corresponding objects. One way to do so is by decreasing the amount of translation along the Z axis from 10 unit to 9.999 units.

**two_cubes_with_small_overlap.scad**

```openscad
cube([60,20,10],center=true);
translate([0,0,9.999])
    cube([30,20,10],center=true);
```

Another way to do so more explicitly is by subtracting 0.001 units from the corresponding value on the script.

**two_cubes_with_explicit_small_overlap.scad**

```openscad
cube([60,20,10],center=true);
translate([0,0,10 - 0.001])
    cube([30,20,10],center=true);
```

There is a third way. To avoid losing 0.001 from the top, we can add a third cube with the X-Y dimensions of the smaller cube, and height of 0.002 ([30, 20, 0.002]). The third cube will close the gap.

**third_cube_close_small_gap.scad**

```openscad
cube([60,20,10],center=true);
translate([0,0,10])
    cube([30,20,10],center=true);
translate([0,0,5 - 0.001])
    cube([30,20,0.002],center=true);
```

You will encounter this throughout the tutorial. Instead of two objects just touching each other, always guarantee a small overlap by subtracting or adding a tolerance of 0.001 units.

## The cylinder primitive and rotating objects

The model that you just created looks like the body of a car that has bad aerodynamics. That's ok. You will be making the car look a lot more interesting and aerodynamic in the following chapters. For now, you are going to use the cylinder primitive and the rotate transformation to add wheels and axles to your car. You can create a wheel by adding a third statement that consists of the cylinder command. You will need to define two input parameters, `h` and `r`.

- `h` is the height of the cylinder.
- `r` is its radius.

**a_cylinder_covered_by_cubes.scad**

```openscad
cube([60,20,10],center=true);
translate([5,0,10 - 0.001])
    cube([30,20,10],center=true);
cylinder(h=3,r=8);
```

Notice the cylinder is hidden by the other objects. Use the translate command to make the cylinder visible by translating it 20 units along the negative direction of the Y axis.

**two_cubes_and_a_cylinder.scad**

```openscad
cube([60,20,10],center=true);
translate([5,0,10 - 0.001])
    cube([30,20,10],center=true);
translate([0,-20,0])
    cylinder(h=3,r=8);
```

The wheel is now visible, but your car won't go anywhere if its not properly placed. You can use the rotate command to make the wheel stand up straight. To do so, you need to rotate it 90 degrees around the X axis.

**two_cubes_and_a_rotated_cylinder.scad**

```openscad
cube([60,20,10],center=true);
translate([5,0,10 - 0.001])
    cube([30,20,10],center=true);
rotate([90,0,0])
    translate([0,-20,0])
    cylinder(h=3,r=8);
```

Notice the absence of a semicolon between the rotate and translate command. By now, you should be getting familiar with this concept. The semicolon is only added at the end of a statement. You can keep adding as many transformation commands as you like, but you should not include a semicolon between them.

The second thing to make note of is the rotate command has one input parameter, which is a vector of three values. Analogous to the translate command, each value indicates how many degrees an object will be rotated around the X, Y and Z axes.

The third thing to note is the wheel is standing straight but as a result of its rotation around the x axis it has moved below the car. This happened because the object was moved away from the origin before it was rotated. A good practice for placing objects inside your model is to rotate them first, then translate them to the desired position. Note that OpenSCAD generates the object, then applies the object transformations starting with the one immediately before the object definition, then working backwards. So in order to rotate your object, then move it with a translation, specify the translation first, followed by the rotation, followed by the object definition.

**Exercise:**
Try first rotating the wheel and then translating it, by changing the order of the rotate and translate commands.

**two_cubes_and_a_rotated_and_translated_cylinder.scad**

```openscad
cube([60,20,10],center=true);
translate([5,0,10 - 0.001])
    cube([30,20,10],center=true);
translate([0,-20,0])
    rotate([90,0,0])
    cylinder(h=3,r=8);
```

It already looks a lot better than the previous position of the wheel.

**Exercise:**
Try modifying the input parameter of the translate command to make this wheel the front left wheel of your car.

**car_body_and_front_left_wheel.scad**

```openscad
cube([60,20,10],center=true);
translate([5,0,10 - 0.001])
    cube([30,20,10],center=true);
translate([-20,-15,0])
    rotate([90,0,0])
    cylinder(h=3,r=8);
```

**Exercise:**
Try adding the front right wheel of the car by duplicating the last statement and changing only the sign of one value.

**car_body_and_misaligned_front_wheels.scad**

```openscad
cube([60,20,10],center=true);
translate([5,0,10 - 0.001])
    cube([30,20,10],center=true);
translate([-20,-15,0])
    rotate([90,0,0])
    cylinder(h=3,r=8);
translate([-20,15,0])
    rotate([90,0,0])
    cylinder(h=3,r=8);
```

You should notice that the position of the wheels is not symmetric. This happened because the cylinder was not created centered on the origin.

**Exercise:**
Try adding an additional input parameter to the cylinder commands to tell OpenSCAD both wheels should be centered on the origin when first created. Is the position of your wheels symmetric now?

**car_body_and_aligned_front_wheels.scad**

```openscad
cube([60,20,10],center=true);
translate([5,0,10 - 0.001])
    cube([30,20,10],center=true);
translate([-20,-15,0])
    rotate([90,0,0])
    cylinder(h=3,r=8,center=true);
translate([-20,15,0])
    rotate([90,0,0])
    cylinder(h=3,r=8,center=true);
```

## Completing your first model

**Exercise:**
Try using what you have learned to add the rear missing wheels to the car. Try adding a connecting axle to the front and rear wheels.

**completed_car.scad**

```openscad
cube([60,20,10],center=true);
translate([5,0,10 - 0.001])
    cube([30,20,10],center=true);
translate([-20,-15,0])
    rotate([90,0,0])
    cylinder(h=3,r=8,center=true);
translate([-20,15,0])
    rotate([90,0,0])
    cylinder(h=3,r=8,center=true);
translate([20,-15,0])
    rotate([90,0,0])
    cylinder(h=3,r=8,center=true);
translate([20,15,0])
    rotate([90,0,0])
    cylinder(h=3,r=8,center=true);
translate([-20,0,0])
    rotate([90,0,0])
    cylinder(h=30,r=2,center=true);
translate([20,0,0])
    rotate([90,0,0])
    cylinder(h=30,r=2,center=true);
```

Notice on the model above, there is an overlap between the axles and the wheels that is equal to half the thickness of the wheels. If the model was created in a way that the wheels and the axles were just touching each other, then there would be a need to ensure a small overlap between them as was done with the two cubes of the car's body.

One thing you may have noticed is the resolution of the wheels. Until now you have been using OpenSCAD's default resolution settings. There are special commands in OpenSCAD language which allow you to have full control over the resolution of your models. Increasing the resolution of your model will also increase the required rendering time every time you update your design. For this reason, it is advised that you keep the default resolution settings when you are building your model, and increase the resolution only after completing your design. Since the car example is completed, you can increase the resolution by adding the following two statements in your script.

```openscad
$fa = 1;
$fs = 0.4;
```

Try adding the above two statements at the beginning of the car's script. Do you notice any changes in the resolution of the wheels?

**completed_car_higher_resolution.scad**

```openscad
$fa = 1;
$fs = 0.4;
cube([60,20,10],center=true);
translate([5,0,10 - 0.001])
    cube([30,20,10],center=true);
translate([-20,-15,0])
    rotate([90,0,0])
    cylinder(h=3,r=8,center=true);
translate([-20,15,0])
    rotate([90,0,0])
    cylinder(h=3,r=8,center=true);
translate([20,-15,0])
    rotate([90,0,0])
    cylinder(h=3,r=8,center=true);
translate([20,15,0])
    rotate([90,0,0])
    cylinder(h=3,r=8,center=true);
translate([-20,0,0])
    rotate([90,0,0])
    cylinder(h=30,r=2,center=true);
translate([20,0,0])
    rotate([90,0,0])
    cylinder(h=30,r=2,center=true);
```

`$fa` and `$fs` are special variables that determine the resolution of the model according to the values that have been assigned to them. Their exact function will be explained later, and is something that you should not worry about yet. The only thing you need to keep in mind, is that you can add these two statements in any script to achieve a resolution that is universally good for 3D printing. These two statements will be used in all examples throughout the tutorial in order to have visually appealing renderings.

Before sharing your script with your friends, it would be nice to include some comments to help them understand your script. You can use a double slash at the start of a line to write anything you like without affecting your model. By using a double slash, OpenSCAD knows that what follows is not part of the scripting language and simply ignores it.

**Exercise:**
Try adding a comment above each statement to let your friends know what part of your model is created with each statement.

It's time to save your model. Hit the save (third) icon on the action bar above the editor to save your script as a `*.scad` file. When you are creating a new model remember to save early, then save often, to avoid accidentally losing your work.

If you would like to 3D print your car you can export it as an STL file. First click on the render (second) icon on the action bar below the viewport to generate the STL file, then click on the export as STL icon on the action bar above the editor, to save an STL file of your model.

## Creating a second model

**Exercise:**
Try using everything you learned to create a new simple model. It can be a house, an airplane or anything you like. Don't worry about making your model look perfect, just experiment with your new skills! You will keep learning more techniques to create awesome models in the following chapters.
