# OpenSCAD Tutorial - Chapter 9

> Source: https://en.wikibooks.org/wiki/OpenSCAD_Tutorial/Chapter_9

---

< [Chapter 8](chapter-8.md) | **Chapter 9** | [Table of Contents](index.md) >

## Doing Math Calculations in OpenSCAD

So far you have learned that OpenSCAD variables can hold only one value throughout the execution of a script, the last value that has been assigned to them. You have also learned that a common use of OpenSCAD variables is to provide parameterization of your models. In this case every parameterized model would have a few independent variables, whose values you can change to tune that model. These variables are usually directly assigned a value as in the following examples.

```openscad
wheel_diameter = 12;
body_length = 70;
wheelbase = 40;
// etc.
```

Another thing that you have seen a few times already, but which has not been mentioned explicitly is the ability to perform mathematical operations using variables and hard-coded values in your script. One example of this is in implementing the car's wheelbase. Recall that the car's axles and wheels were translated along the X axis and away from the origin by half the value of the wheelbase. Since in this case the wheelbase is a variable that has already been defined in your script, you can calculate the amount of units by dividing the wheelbase variable by two. A similar thing was done with the track variable to place the left and right wheels of the car. Recall that the left and right wheels were translated along the Y axis and away from the origin by half the value of the track.

**axle_with_wheelset.scad**

```openscad
use <vehicle_parts.scad>
$fa = 1;
$fs = 0.4;

wheelbase = 40;
track = 35;

translate([-wheelbase/2, track/2])
    simple_wheel();
translate([-wheelbase/2, -track/2])
    simple_wheel();
translate([-wheelbase/2, 0, 0])
    axle(track=track);
```

Addition, subtraction, multiplication and division are represented in OpenSCAD with the signs `+`, `-`, `*` and `/`. Apart from these fundamental operations, there are also a number of additional mathematical operations that can be useful when building more complex models. Two examples of this are the cosine and sine functions that you used to define a circular pattern of cars. Specifically, you used the cosine and sine functions to transform the polar coordinates of each car into Cartesian coordinates in order to translate it in its proper position. You can find all available math functions briefly listed in the cheat sheet.

**circular_pattern_of_cars.scad**

```openscad
r = 140; // pattern radius
n = 12; // number of cars
step = 360/n;
for (i=[0:step:359]) {
    angle = i;
    dx = r*cos(angle);
    dy = r*sin(angle);
    translate([dx,dy,0])
        rotate([0,0,angle])
        car();
}
```

In the above case you are not only using available mathematical operations in your script, but you are also defining two additional variables `dx` and `dy` to store the result of your calculations in order to increase the readability of your script. This is something that could also be done in your car models. Take for example the following car model.

**car.scad**

```openscad
use <vehicle_parts.scad>
$fa = 1;
$fs = 0.4;

wheelbase = 40;
track = 35;

// Body
body();
// Front left wheel
translate([-wheelbase/2,-track/2,0])
    simple_wheel();
 // Front right wheel
translate([-wheelbase/2,track/2,0])
    simple_wheel();
// Rear left wheel
translate([wheelbase/2,-track/2,0])
    simple_wheel();
// Rear right wheel
translate([wheelbase/2,track/2,0])
    simple_wheel();
// Front axle
translate([-wheelbase/2,0,0])
    axle(track=track);
// Rear axle
translate([wheelbase/2,0,0])
    axle(track=track);
```

In the above model, mathematical operations are used to calculate the required amount of translation for each wheel and axle along the X and Y axis.

### Exercise

Modify the above script in order to improve its readability and avoid repeating the same mathematical operations multiple times. To do so you should introduce two new variables named `half_wheelbase` and `half_track`. Use the corresponding mathematical calculation to set these variables equal to half the value of the wheelbase and the track variables accordingly. Replace the repeating mathematical operations in the translation commands with the use of these two variables.

## Creating Any 2D Object with the Polygon Primitive

Aside from the circle and square 2D primitives, there is another primitive that lets you design practically any 2D object. This is the `polygon` primitive, which lets you define 2D objects by providing a list that contains the coordinates of their points. Let's say you want to design a custom 2D part.

One way to go about designing this part without using the polygon primitive would be to start from a square that corresponds to the outer dimensions of this part and then subtract a properly rotated and translated square from its top right corner. Calculating the proper angle of rotation and amount of translation would be a time-consuming task. Additionally, following this strategy for a more complex object wouldn't be possible. Instead, you can create this object using the polygon primitive in the following way.

**profile_1_polygon.scad**

```openscad
p0 = [0, 0];
p1 = [0, 30];
p2 = [15, 30];
p3 = [35, 20];
p4 = [35, 0];
points = [p0, p1, p2, p3, p4];
polygon(points);
```

There are a few things you should notice regarding the use of the polygon primitive. The polygon primitive uses a list of points as inputs. The points, or vertices, are represented using pairs of X and Y coordinates, and are provided in order. When defining the list, you may start with any vertex you like and you can traverse them in either a clockwise or counterclockwise order. In the example above, the first vertex is at the origin (0,0), while the remaining vertices are listed in a clockwise direction. All vertices (pairs of X and Y coordinates) p0, p1, ..., p4 are placed inside a list named `points`. This list is then passed to the polygon command to create the corresponding object.

Whether a variable has only a single value or it's a list of values, you can print its content on the console using the `echo` command.

```openscad
echo(points);
```

The output in the console is: `[[0, 0], [0, 30], [15, 30], [35, 20], [35, 0]]`

Naming each point separately (p0, p1, ...) is not required but it's recommended to better keep track of your design. You could also directly define the list of points to be passed to the polygon command.

```openscad
points = [[0, 0], [0, 30], [15, 30], [35, 20], [35, 0]];
```

Moreover, you don't even have to define a variable to store the list of points. You can directly define the list of points when calling the polygon command.

```openscad
polygon([[0, 0], [0, 30], [15, 30], [35, 20], [35, 0]]);
```

The above practices are not recommended. Instead the use of additional variables as in the first example is encouraged in order to make your scripts more readable and extendable.

You could also parameterize the definition of the points' coordinates according to the given dimensions, which will give you the ability to rapidly modify the dimensions of your object. This can be achieved by introducing one variable for each given dimension and by defining the coordinates of the points using appropriate mathematical expressions.

**profile_1_polygon_parametric.scad**

```openscad
// Given dimensions
d1 = 15;
d2 = 20;
h1 = 20;
h2 = 10;
// Points
p0 = [0, 0];
p1 = [0, h1 + h2];
p2 = [d1, h1 + h2];
p3 = [d1 + d2, h1];
p4 = [d1 + d2, 0];
points = [p0, p1, p2, p3, p4];
// Polygon
polygon(points);
```

### Exercise

Create a custom 2D object using the polygon primitive. To do this you will need to define a list that contains the pairs of X and Y coordinates of the object's points. Remember that the points should be defined in an appropriate order. You should first store the coordinates of each point on separate variables named p0, p1, p2, ... and then define a list of all points and store it in a variable named `points`. This list will be passed on the polygon command. The definition of each point's coordinates should be parametric in relation to the given dimensions which can be achieved by using appropriate mathematical expressions. To do this you will also need to define a variable for each given dimension.

### Exercise

Using the `linear_extrude` and `rotate_extrude` commands create a tube and a ring respectively that have the above profile. The tube should have a height of 100 units. The ring should have an inner diameter of 100 units. How many units do you need to translate the 2D profile along the positive direction of the X axis to achieve this?

### Exercise - Racing Car Body

It's time to use your new skills to create a racing car!

Create a car body using the polygon command. To do so you will have to define each point of the design, add them all on a list and pass this list to the polygon command. The definition of each point's coordinates should be parametric in relation to the given dimensions. Remember that in order to do this you will have to define a variable for each given dimension and calculate each point's coordinates from these variables using appropriate mathematical expressions. You should extrude the created 2D profile to a height of 14 units.

### Exercise - Readability

As mentioned previously, you can use additional variables to increase the readability of your script and to avoid repeating mathematical operations. Can you find a way to do so in the above script?

### Exercise - Complete the Car

Try completing the racing car design by adding the remaining objects to the above body.

## Creating More Complex Objects Using the Polygon Primitive and Math

From the above examples it should be quite obvious that the polygon primitive opens up possibilities to create objects that would hardly be possible by just using the fundamental 2D or 3D primitives. In these examples you created custom 2D profiles by defining the coordinates of their points according to a given design. To unlock the true power of the polygon command though, and to create even more complex and impressive designs, you have to programmatically define the points of your profiles using math. This is because defining each point separately is not scalable to the hundreds of points that are required to design smooth non-square profiles. One example of this is a heart shape. Can you manually define the required points to create it? There is no way.

Instead of manually defining each point, which would be practically impossible, this model was programmatically defined using the following parametric equations:

```
x = 16 * sin(t)^3
y = 13 * cos(t) - 5 * cos(2*t) - 2 * cos(3*t) - cos(4*t)
```

When the range of the `t` variable covers values from 0 to 360 degrees, the above equations give the X and Y coordinates for the outline of the heart, starting from the top middle point and moving in a clockwise direction. Using the above equations, a list that contains each point's coordinates can be generated in the following way.

```openscad
points = [ for (t=[0:step:359.999]) [16*pow(sin(t),3), 13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t)]];
```

There are a few things you should notice about the syntax of list generation. First the name of the variable where the list will be stored is typed out. Then follows the equal sign (as in every variable assignment) and a pair of square brackets. Inside the pair of square brackets, the first thing that is typed out is the keyword `for`. After the keyword `for` follows a pair of parentheses inside of which the consecutive values that the corresponding variable is going to take are defined. This variable is similar to the for loop variable encountered in for loops. The number of elements that the generated list is going to have is equal to the number of values that this variable is going to take. For every value that this variable takes, one element of the list is defined. What each element of the list is going to be, is specified after the closing parenthesis. In this case each element of the generated list is itself a list that has two elements, one for each coordinate of the corresponding point. The `t` variable goes from 0 to 360 which is the required range to produce the whole outline of the heart. Since the polygon shouldn't include duplicate points, 359.999 is used instead of 360. By choosing a smaller or bigger value for the `step` variable, the amount of points that will be created can be controlled. Specifically, in order to create n points the step variable needs to be defined in the following way.

```openscad
step = 360/n;
```

Putting all these together, the heart can be created with the following script.

**heart.scad**

```openscad
n = 500;
h = 10;
step = 360/n;
points = [ for (t=[0:step:359.999]) [16*pow(sin(t),3), 13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t)]];
linear_extrude(height=h)
    polygon(points);
```

You can see that by using 500 points the resolution of the outline is very good.

### Exercise

Modify the above script so that the outline of the heart is consisted out of 20 points.

### Exercise - List Generation Practice

Time for some quick list generation practice before you move on. Use the newly introduced syntax (`variable = [ for (i=[start:step:end]) ... ];`) to generate the following lists:

1. `[1, 2, 3, 4, 5, 6]`
2. `[10, 8, 6, 4, 2, 0, -2]`
3. `[[3, 30], [4, 40], [5, 50], [6, 60]]`

Note that when no step is provided, a default of 1 is used.

### Custom Functions

OpenSCAD also allows you to define your own mathematical functions, which can be useful when a mathematical expression is particularly long, or when you would like to use it multiple times. These functions work similarly to modules, except that instead of defining a design they define a mathematical process. After a function has been defined, you can use it by invoking its name and providing the necessary input parameters. For example, you can define a function that accepts the parameter `t`, and returns the X and Y coordinates of the corresponding point of the heart's outline.

```openscad
function heart_coordinates(t) = [16*pow(sin(t),3), 13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t)];
```

In this case the script that creates the heart would take the following form.

```openscad
n = 500;
h = 10;
step = 360/n;
function heart_coordinates(t) = [16*pow(sin(t),3), 13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t)];
points = [ for (t=[0:step:359.999]) heart_coordinates(t)];
linear_extrude(height=h)
    polygon(points);
```

There are a few things you should notice about the definition of a function. First the word `function` is typed out. Then follows the name that you want to give to the function. In this case the function is named `heart_coordinates`. After the name of the function follows a pair of parentheses that contains the input parameters of the function. Like module parameters, the input parameters in a function can have default values. In this case, the only input parameter is the polar angle of the current step `t` and it's not given a default value. After the closing parenthesis follows the equal sign and the command that defines the pair of X and Y coordinates of the heart's outline.

The generation of the list of points can also be turned into a function. This can be done in a similar fashion as follows.

```openscad
function heart_points(n=50) = [ for (t=[0:360/n:359.999]) heart_coordinates(t)];
```

In this case the script that creates the heart would take the following form.

```openscad
n=20;
h = 10;
function heart_coordinates(t) = [16*pow(sin(t),3), 13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t)];
function heart_points(n=50) = [ for (t=[0:360/n:359.999]) heart_coordinates(t)];
points = heart_points(n=n);
linear_extrude(height=h)
    polygon(points);
```

In short you should remember that any command that returns a single value or a list of values can be turned into a function. Like modules, functions should be used to organize your designs and make them reusable.

### Exercise - Heart Module

Since you have already defined the function for generating the list of points that is required to create a heart, it would be a good idea to also define a module that creates a heart. Create a module named `heart`. The module should have two input parameters `h` and `n` corresponding to the height of the heart and the number of points used. The module should call the `heart_points` function to create the required list of points and then pass that list to a polygon command to create the 2D profile of the heart. This profile should be extruded to the specified height.

### Exercise - Reusable Heart Library

You can save the `heart_coordinates` and `heart_points` functions along with the heart module on a script named `heart.scad` and add it on your libraries. Every time you want to include a heart on a design that you are working on, you can use the `use` command to make the functions and modules of this script available to you.

## Another Challenge

You are going to put your new skills into practice to create an aerodynamic spoiler for your racing car!

### Exercise - NACA Airfoil Half Thickness Function

You are going to use a symmetrical 4-digit NACA 00xx airfoil for your spoiler. The half thickness of such an airfoil on a given point x is given by the following formula:

```
y_t = 5 * t * (0.2969 * sqrt(x) - 0.1260 * x - 0.3516 * x^2 + 0.2843 * x^3 - 0.1015 * x^4)
```

In the above formula, `x` is the position along the chord with 0 corresponding to the leading edge and 1 to the trailing edge, while `t` is the maximum thickness of the airfoil expressed as a percentage of the chord. Multiplying `t` by 100 gives the last two digits in the NACA 4-digit denomination.

Create a function named `naca_half_thickness`. The function should have two input parameters: `x` and `t`. Given `x` and `t`, the function should return the half thickness of the corresponding NACA airfoil. The `x` and `t` input parameters shouldn't have any default value.

### Exercise - Top Coordinates Function

Create a function named `naca_top_coordinates`. This function should return a list of the X and Y coordinates for the top half of the airfoil. The first point should correspond to the leading edge while the last point should correspond to the trailing edge.

The function should have two input parameters: `t` and `n`. The parameter `t` should correspond to the airfoil's maximum thickness, while the parameter `n` should correspond to the number of created points. The list of points should be generated using an appropriate list generation command. You will need to call the `naca_half_thickness` function.

### Exercise - Bottom Coordinates Function

Create a similar function named `naca_bottom_coordinates` that returns a list of points for the bottom half of the airfoil. This time the points should be given in reverse order. The first point should correspond to the trailing edge while the last point should correspond to the leading edge. This is done so that when the lists that are generated from the `naca_top_coordinates` and `naca_bottom_coordinates` functions are joined, all points of the airfoil are defined in a clockwise direction starting from the leading edge, thus making the resulting list suitable for use with the polygon command.

### Exercise - Combined Coordinates Function

Create a function named `naca_coordinates` that joins the two lists of points. You can use OpenSCAD's built in function `concat` to join lists together. Pass both lists as inputs to `concat` to join them together.

### Exercise - Create the Airfoil Profile

Try using the `naca_coordinates` function to create a list that contains the points for an airfoil with a maximum thickness of 0.12 and with 300 points on each half. The list should be stored in a variable named `points`. The `points` variable should be passed to a polygon command to create the airfoil's 2D profile.

### Exercise - Scale the Airfoil

The chord of the above airfoil is 1 unit. Can you use an appropriate `scale` command to enlarge the airfoil? The desired chord should be defined on a variable named `chord` and the scale command should be defined in relation to this variable. Create an airfoil that has a chord of 20 units.

### Exercise - NACA Airfoil Module

Turn the above script into a module named `naca_airfoil`. The module should have three input parameters, `chord`, `t` and `n`. There shouldn't be default values for any of the input parameters.

### Exercise - NACA Wing Module

All you have to do now to create a wing out of the airfoil is to apply a `linear_extrude` command on the 2D airfoil profile. Create a module named `naca_wing` that does that. The `naca_wing` module should have two additional input parameters compared to the `naca_airfoil` module, `span` and `center`. The `span` parameter should correspond to the height of the extrusion while the `center` parameter should dictate whether the extrusion is executed along only the positive direction of the Z axis or along both directions. The `span` parameter shouldn't have a default value while the default value of the `center` parameter should be false. Can you use the `naca_wing` module to create the following wing? The wing has a span of 50 units, while the airfoil of the wing has a chord of 20 units, a maximum thickness of 0.12 and 500 points on each half. You will have to additionally use a rotation transformation to place the wing properly.

### Exercise - Spoiler with End Plates

Use the `naca_wing` module to add two smaller vertical wings on the previous example in order to create the spoiler of the car. The smaller wings should have a span of 15 units as well as a chord of 15 units.

### Exercise - Complete the Racing Car

Add the above spoiler on the racing car design to complete it.

---

*This page was last edited on 5 November 2024, at 13:18.*
*Text is available under the Creative Commons Attribution-ShareAlike License.*
