# OpenSCAD Tutorial - Chapter 7

> Source: https://en.wikibooks.org/wiki/OpenSCAD_Tutorial/Chapter_7

---

< [Chapter 6](chapter-6.md) | **Chapter 7** | [Chapter 8](chapter-8.md) >

## Creating Repeating Patterns of Parts/Models - For Loops

In the previous chapter you used if statements to control whether some part of your design should be created or not. In this chapter you are going to find out how you can create multiple parts or objects when they form a specific pattern.

Given the following car model as an example you are going to learn how to create such patterns.

**single_car.scad**

```openscad
use <vehicle_parts.scad>
$fa=1;
$fs=0.4;

// Variables
track = 30;
wheelbase=40;
// Body
body();
// Front left wheel
translate([-wheelbase/2,-track/2,0])
    rotate([0,0,0])
    simple_wheel();
 // Front right wheel
translate([-wheelbase/2,track/2,0])
    rotate([0,0,0])
    simple_wheel();
// Rear left wheel
translate([wheelbase/2,-track/2,0])
    rotate([0,0,0])
    simple_wheel();
// Rear right wheel
translate([wheelbase/2,track/2,0])
    rotate([0,0,0])
    simple_wheel();
// Front axle
translate([-wheelbase/2,0,0])
    axle(track=track);
// Rear axle
translate([wheelbase/2,0,0])
    axle(track=track);
```

### Exercise

Take the above car example and modify it in order to create another car. To avoid duplicating the code that creates the car you should create a car module. The module should have two input parameters, the track and the wheelbase of the car. The default value of the track and the wheelbase should be 30 and 40 units respectively. The first car should be positioned at the origin as the example above, the second car should be translated along the positive direction of the Y axis by 50 units.

### Exercise

Create eight additional cars along the positive direction of the Y axis so that you have ten cars in total. Every next car should be translated 50 units along the positive direction of the Y axis in comparison to the previous car.

---

After the previous exercise, you have probably realized that creating a pattern of cars in this manner is not very efficient; a new statement has to be written for every car, and this results in a lot of code duplication in your script. Typically, you can use a for loop to achieve the same results a lot easier. The for loop provides a way to repeat the same set of statements a certain number of times, with small, predictable changes applied each time. Take a look at the following example.

**row_of_ten_cars_along_y_axis_with_for_loop.scad**

```openscad
for (dy=[0:50:450]) {
    translate([0,dy,0])
        car();
}
```

There are a few things you should notice about the syntax of the for loop. First the keyword `for` is typed out followed by a pair of parentheses. Inside the parentheses the variable of the for loop is defined. It's advisable to give a descriptive name to the for loop variables when applicable. In this case the variable is named `dy` because it represents the number of units that each car needs to be translated along the Y axis. The definition of the variable indicates that its first value will be 0 units and all following values will be incremented by 50 units each until the value 450 is reached. This means that the variable `dy` will take ten different values in total throughout the execution of the for loop repetitions. These values are 0, 50, 100, 150, 200, 250, 300, 350, 400 and 450. These values form a vector, which in contrast to a single value is a sequence of values. In the first repetition the variable will take the first value of the vector, which is 0. In the second repetition the second value, which is 50. And so forth. The different consecutive values that the for loop variable takes throughout the repetitions of the for loop is the key concept which makes the for loop suitable for creating patterns of multiple parts or models. Finally, after the closing parenthesis follows a pair of curly brackets. Inside the curly brackets exist the statements that will be executed repeatedly as many times as the number of values of the for loop variable. In this case the single statement inside the curly brackets will be executed 10 times which is the number of values that the `dy` variable will take. To avoid creating 10 cars that are completely overlapping the amount of translation along the Y axis on each repetition of the for loop is parameterized using the `dy` variable. The `dy` variable has a different value on each repetition of the for loop thus creating the desired pattern.

### Exercise

Use a for loop to create a pattern of cars. The first car should be centered at the origin. Every next car should be placed behind the previous car. Specifically, every next car should be translated 70 units along the positive direction of the X axis in comparison to the previous car. The pattern should be consisted out of 8 cars in total. The for loop variable should be named `dx`.

## Creating More Complex Patterns

In the previous examples the for loop variable `dy` was used directly to modify some aspect of each individual model that composes the pattern. The only aspect that was modified was the translation of each model along the Y or X axis. On each repetition the value of the `dy` variable was equal to the desired translation on each model.

When more than one aspect of the model needs to be modified it's a better practice for the for loop variable to take integer values 0, 1, 2, 3 etc. The required values for modifying different aspects of the model (ex. translation along some axis, scaling of some part) are then produced from those integer values that the for loop variable takes. In the following example this concept is used to simultaneously translate each car 50 and 70 units along the positive direction of the Y and X axis.

**diagonal_row_of_five_cars.scad**

```openscad
for (i=[0:1:4]) {
    translate([i*70,i*50,0])
        car();
}
```

There are a few things you should notice. The for loop variable is now named `i`. When the for loop variable is used in this way it's usually called index and given the name `i`. Since the for loop variable takes integer values you need to multiply it by a proper number to produce the desired amount of translation along each axis. Specifically, the desired amount of translation along the Y axis is produced by multiplying the for loop variable by 50. Similarly the desired amount of translation along the X axis is produced by multiplying the for loop variable by 70.

### Exercise

Add a rotation transformation to the previous example in order to turn the car around the Z axis. The first car shouldn't be turned at all. Each next car should be turned by 90 degrees around the positive direction of rotation of the Z axis in comparison to the previous car. The positive direction of rotation of the Z axis is the one that would rotate the X axis towards the Y axis. Does the rotation transformation need to be applied before or after the translation transformation in order to keep the cars in the same position?

---

The patterns you are creating are already becoming cooler, here is an interesting one.

**circular_pattern_of_ten_cars.scad**

```openscad
r = 200;
for (i=[0:36:359]) {
    translate([r*cos(i),r*sin(i),0])
        car();
}
```

In the above pattern the cars have been placed at equally spaced points at the circumference of a perfect circle that has a radius of 200 units. There are a few important points you should pay attention to if you wish to create such patterns.

The first is that in order to create a circular pattern you need to use polar coordinates. Depending on your background you may have noticed the use of polar coordinates just by glancing at the code or you may have no idea what it is. In the latter case, the only thing that you need to know is that polar coordinates are a way to produce the X and Y coordinates of a given point of a circle when you know the radius of the circle and the angle that corresponds to that point. The angle 0 corresponds to the point of the circle that belongs to the positive direction X axis. The positive counting direction of the angle is from the X to the Y axis. This means the positive Y axis corresponds to 90 degrees, the negative X axis to 180 degrees, the negative Y axis to 270 degrees and if you complete the circle the positive X axis to 360 degrees. According to the polar coordinates the X coordinate can be calculated by multiplying the radius of the circle by the cosine of the angle, while the Y coordinate can be calculated by multiplying the radius of the circle by the sine of the angle. This is how the desired amount of translation along the X and Y axis is produced.

The second thing you should notice is what values the for loop variable `i` takes. The variable `i` starts from 0 and is incremented by 36 on each repetition in order to position 10 equally spaced cars on the circle (360/10 = 36). The first car that is created at 0 angle and the car that correspond to 360 degrees would be exactly overlapping. In order to avoid this, you need to instruct the for loop variable to stop incrementing before it reaches 360. If you are lazy calculating 360 - 36 = 324, you can just put the limit at 359. This will work fine because the for loop variable will only take the values 0, 36, 72, 108 144, 180, 216, 252, 288 and 324, since incrementing by another 36 units would result in 360 which exceeds 359.

By using additional variables and naming them properly you can make your scripts more descriptive and usable so that it's easier for anyone (or even you at a later point in time) to understand what they are doing and how to use them. For example, the previous script can take the following form.

```openscad
r = 200; // pattern radius
n = 10; // number of cars
step = 360/n;
for (i=[0:step:359]) {
    angle = i;
    dx = r*cos(angle);
    dy = r*sin(angle);
    translate([dx,dy,0])
        car();
}
```

On the above script it is self-explanatory that the for loop variable `i` corresponds to the angle. It is also clearer what the amount of translation along each axis is. In addition, it is easy to customize this pattern by changing the radius and/or the number of cars.

### Exercise

Modify the appropriate values on the above script in order to create a pattern of 14 equally spaced cars on the circumference of circle with radius of 160 units.

### Exercise

If you are not familiar with polar coordinates play around with the following script. Try assigning different values to the radius and the angle variables and see what the resulting position of the car is.

## Challenge

**parametric_circular_pattern_of_fourteen_cars.scad**

```openscad
r = 160; // pattern radius
n = 14; // number of cars
step = 360/n;
for (i=[0:step:359]) {
    angle = i;
    dx = r*cos(angle);
    dy = r*sin(angle);
    translate([dx,dy,0])
        car();
}
```

### Exercise

The above script was used to create a circular pattern of cars. Modify the above script by adding a rotation transformation in order to make all cars face the origin. Use your modified script to create a pattern that has 12 cars and a radius of 140 units.

### Exercise

Make appropriate changes to the above script to create:
1. One pattern where all cars are facing away from the origin
2. One pattern where all cars are oriented tangentially as if driving counter clockwise around a circle
3. And one as if driving clockwise around a circle

---

Now that you are getting a hold of using for loops to create patterns it's time to put your new skills in the development of a more sophisticated wheel design!

### Exercise - Spoked Wheel

If you feel confident with your OpenSCAD skills or if you would like to experiment a bit more, try to build a new module named `spoked_wheel` that creates a spoked wheel design.

If you feel more comfortable with some additional guidance, follow these steps:

#### Step 1 - Wheel Ring

Create a new module named `spoked_wheel` that has 5 input parameters. The input parameters should be named `radius`, `width`, `thickness`, `number_of_spokes` and `spoke_radius`. Give these variables the default values of 12, 5, 5, 7 and 1.5 respectively. Use the `cylinder` and `difference` commands to create the ring of the wheel by subtracting a small cylinder from a bigger one. For this step you are only going to use the `radius`, `width` and `thickness` variables. Remember that when you are subtracting one object from another it needs to clear the face of the other object to avoid any errors. Keep this in mind when defining the height of the small cylinder. You will also need to calculate the radius of the small cylinder from the `radius` and `thickness` variables. You can use a variable named `inner_radius` to store the result of the appropriate calculation and then use it to define the radius of the smaller cylinder.

#### Step 2 - Spokes

Extend the previous module to additionally create the spokes of the wheel. The spokes of the wheel need to be cylindrical. The length of the spokes needs to be appropriate so that each spoke spans from the center of the ring to its half thickness. You will have to use a for loop to create the spokes as a pattern.

#### Step 3 - Rotation

For the new wheel design to be compatible with the existing wheel designs and modules that you have created throughout the tutorial, it needs to be rotated to stand straight. Add an appropriate rotation transformation to do so.

#### Step 4 - Integration

Add the `spoked_wheel` module to the `vehicle_parts.scad` script. Use the new wheel design in one of your car models.

## Creating Patterns of Patterns - Nested For Loops

The following script creates a row of cars along the Y axis.

**row_of_six_cars_along_y_axis.scad**

```openscad
n = 6; // number of cars
y_spacing = 50;
for (dy=[0:y_spacing:n*y_spacing-1]) {
    translate([0,dy,0])
        car();
}
```

### Exercise

Modify the above script to create 4 additional rows of cars. Each row should be translated by 70 units along the positive direction of the X axis in comparison to the previous row.

---

If you have been paying close attention to the tutorial so far, you may have noticed that the script above is not very efficient. It has a lot of code duplication and the number of rows can't be easily modified. You faced a similar situation in the beginning of this chapter when you wanted to create a row of cars. To solve that problem, you wrapped the statement that creates a piece of the pattern (a single car) inside a for loop. This generated the whole pattern (a row of cars) without having to type out a statement for each individual car. The same principle can be applied here. In this case, the repeating pattern will be the row of cars, which itself is a repeating pattern of individual cars. Following the same process as before, the statements that create a row of cars will be placed inside a for loop in order to create the pattern of rows of cars. The result is that a for loop is placed inside of another for loop. For loops that are used in this way are called nested for loops. The following example demonstrates this concept.

**five_rows_of_six_cars_with_nested_for_loops.scad**

```openscad
n_cars = 6;
y_spacing = 50;
n_rows = 5;
x_spacing = 70;
for (dx=[0:x_spacing:n_rows*x_spacing-1]) {
    for (dy=[0:y_spacing:n_cars*y_spacing-1]) {
        translate([dx,dy,0])
            car();
    }
}
```

You should notice the following concept. During the first repetition of the outer for loop, all iterations of the inner for loop are executed, thus creating the first row of cars. During the second repetition of the outer for loop all repetitions of the inner for loop are executed, thus creating the second row of cars. And so forth. Each row is positioned by the `dx` variable, which holds the parameterized translation along the X axis. During each iteration of the outer loop, a new value of `dx` is used. This value then holds steady while the inner loop executes and modifies the `dy` value. In this way, a row of cars is generated at each value of `dx`.

### Exercise

Use nested for loops to create three circular patterns of cars. The for loop variable of the outer loop should be used to parameterize the radius of each pattern. The radius of the circular patterns should be 140, 210 and 280 units respectively. Each pattern should be consisted of 12 cars.

### Exercise

Modify the script of the previous exercise so that not only the radius but also the number of cars is different for each pattern. To do so use an index variable `i` as the variable of the outer loop instead of the variable `r` that corresponds to the radius. The variable `r` should be calculated at each repetition of the outer for loop according to the formula `r = 70 + i*70`. Additionally, on each repetition of the outer for loop the `n` variable should take different values according to the formula `n = 12 + i*2`. The `step` variable also needs to be updated on each repetition of the outer for loop. The `i` variable should take the values 1, 2 and 3.

---

*This page was last edited on 26 February 2024, at 18:36.*
*Text is available under the Creative Commons Attribution-ShareAlike License.*
