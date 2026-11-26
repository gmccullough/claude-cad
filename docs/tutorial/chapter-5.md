# OpenSCAD Tutorial - Chapter 5

> Source: https://en.wikibooks.org/wiki/OpenSCAD_Tutorial/Chapter_5

---

## Creating and utilizing modules as separate scripts

In the previous chapter you learned one of the most powerful features of OpenSCAD, the module, and how it can be used for parametric design. You also had the chance to separate the car into different modules and then recombine them to create a different type of vehicle. Using modules can be also seen as a way to organize your creations and to build your own library of objects. The wheel module could potentially be used in a plethora of designs, so it would be great to have it easily available whenever desired without having to redefine it inside the script of your current design. To do so you need to define and save the wheel module as a separate script.

**Exercise:**
Define the following simple_wheel module in a separate script file. In the same script make a call to the simple_wheel module so that you visually see what object this module creates. Save the script file as a scad file named simple_wheel.scad.

**simple_wheel.scad**

```openscad
$fa = 1;
$fs = 0.4;
module simple_wheel(wheel_radius=10, wheel_width=6) {
    rotate([90,0,0])
        cylinder(h=wheel_width,r=wheel_radius,center=true);
}
simple_wheel();
```

Now it's time to utilize this saved module in another design. First you need to create a new design.

**Exercise:**
Create a new script with the following car design. Give the script any name you like but save the script in the same working directory as the simple_wheel module.

There are two ways in which the simple_wheel.scad script can be utilized in your car design. It can be either included or used. To include the script, you have to add the following statement at the top of car's script.

```openscad
include <simple_wheel.scad>
```

You should notice that something unexpected happened. A wheel has been created at the origin. This is the object of the simple_wheel script. When you use `include`, OpenSCAD treats the whole external script that you are including as if it was a part of your current script. In the simple_wheel.scad script, aside from the simple_wheel module definition, there is also a call to the simple_wheel module which creates a wheel object. As a result of using the include command this object is also created in the car's model. This is something that you are going to change by using the `use` instead of the `include` command, but don't bother about it for a moment.

**Exercise:**
The car's wheels are currently created with the cylinder command. Since the simple_wheel.scad script has been included in the car's script, the simple_wheel module should be available. Replace the cylinder commands with calls to the simple_wheel module. Do any rotate commands become unnecessary? The calls to the simple_wheel module shall not contain any definition of parameters.

**Exercise:**
Define the wheel_radius and wheel_width parameters in the calls to the simple_wheel module. To do so use the existing wheel_radius variable as well as a wheel_width variable that you are going to define. Set the variables equal to values that you like.

From the above examples you should keep in mind that when you include an external script in your current script, the modules of the external script become available in your current script, but additionally any objects that were created in the external script are also created in the current one. Since the wheel at the origin is not desired in this case, it's time to use the `use` command instead of the `include`.

**Exercise:**
Replace the include command of the last example with a use command.

You should notice that a wheel is no longer created at the origin. You should keep in mind that the `use` command works like the `include` command with the only difference being that the `use` command doesn't create any objects, but rather just makes the modules of the external script available in the current script.

## Using a script with multiple modules

In the previous example, the simple_wheel.scad script had only one module. The simple_wheel module. This doesn't have to always be the case.

**Exercise:**
Add the following module in the simple_wheel.scad script. Rename the simple_wheel.scad script to wheels.scad.

```openscad
module complex_wheel(wheel_radius=10, side_spheres_radius=50, hub_thickness=4, cylinder_radius=2) {
    cylinder_height=2*wheel_radius;
    difference() {
        // Wheel sphere
        sphere(r=wheel_radius);
        // Side sphere 1
        translate([0,side_spheres_radius + hub_thickness/2,0])
            sphere(r=side_spheres_radius);
        // Side sphere 2
        translate([0,- (side_spheres_radius + hub_thickness/2),0])
            sphere(r=side_spheres_radius);
        // Cylinder 1
        translate([wheel_radius/2,0,0])
            rotate([90,0,0])
            cylinder(h=cylinder_height,r=cylinder_radius,center=true);
        // Cylinder 2
        translate([0,0,wheel_radius/2])
            rotate([90,0,0])
            cylinder(h=cylinder_height,r=cylinder_radius,center=true);
        // Cylinder 3
        translate([-wheel_radius/2,0,0])
            rotate([90,0,0])
            cylinder(h=cylinder_height,r=cylinder_radius,center=true);
        // Cylinder 4
        translate([0,0,-wheel_radius/2])
            rotate([90,0,0])
            cylinder(h=cylinder_height,r=cylinder_radius,center=true);
    }
}
```

**Exercise:**
Use the wheels.scad script in your car script. Use the simple_wheel module to create the front wheels and the complex_wheel module to create the rear wheels.

With this example it should be clear that the name of the script doesn't have to be the same as the name of the module as well as that a script can contain multiple modules. There is no right or wrong way on how you should go about organizing your library of modules. In the last example a wheels.scad script which defines the different wheel modules was used. Alternatively you could have saved each module as a separate *.scad script.

**Exercise:**
Create a vehicle_parts.scad script. Inside this script define a simple_wheel, complex_wheel, body and axle module. Use this script in another script named vehicle_concept to make the corresponding modules available. Use the modules to create a vehicle concept.

## Using the MCAD library

The MCAD library (https://github.com/openscad/MCAD) is a library of components commonly used in mechanical designs that comes with OpenSCAD. You can utilize objects of the MCAD library by using the corresponding OpenSCAD script and calling the desired modules. For example, there is a boxes.scad script which contains the model of a rounded box. The boxes.scad script contains one module, which can be used to create the corresponding box. You can open this script to check what the parameters of this module are and then use it to add rounded boxes in your design. You can create a fully rounded box with side lengths of 10, 20 and 30 units as well as fillet radius of 3 units using the following script.

**completely_rounded_box.scad**

```openscad
use <MCAD/boxes.scad>
$fa=1;
$fs=0.4;
roundedBox(size=[10,20,30],radius=3,sidesonly=false);
```

By setting the sidesonly parameter equal to true you can create a box of similar dimension that has only 4 rounded sides.

**sides_only_rounded_box.scad**

```openscad
use <MCAD/boxes.scad>
$fa=1;
$fs=0.4;
roundedBox(size=[10,20,30],radius=3,sidesonly=true);
```

The boxes.scad script is located in the MCAD directory which is under the libraries directory. The latter can be found in OpenSCAD's installation folder. Should you wish to have any of your own libraries accessible from any directory, you can add it in the libraries directory. You can also browse other available OpenSCAD libraries at https://www.openscad.org/libraries.html. Though, you should be aware that there are a very wide number of libraries available on GitHub and Thingiverse that far exceed those linked at OpenSCAD's libraries page.

**Exercise:**
Use the boxes.scad script of the MCAD library to create a fully rounded box with side lengths of 50, 20 and 15 units as well as fillet radius of 5 units.

**Exercise:**
Use the boxes.scad script of the MCAD library to create a rounded box with only 4 rounded sides with side lengths of 50, 50 and 15 units as well as fillet radius of 20 units.

## Creating even more parameterizable modules

So far, the only input to the modules that have been created was through the module's input parameters that were defined for each case. The complex_wheel module for example was able to create a plethora of parameterized wheels according to the chosen input parameters such as wheel_radius, hub_thickness etc.

In your vehicle designs you have been using body, wheel and axle modules which when combined can produce various types of vehicles. In all the vehicle designs, two wheels along with an axle have been used together to form a set of wheels. You may have considered the need for an axle_wheelset module to simultaneously define all three objects with a single statement. And you would have been right to consider it! But there is a reason this module hasn't been created yet, and you are now going to find out why.

Throughout the previous chapters you have created two different wheel designs (simple_wheel and complex_wheel) and a single axle design. You can use your existing knowledge to combine the simple_wheel and axle modules in the following way.

**axle_with_simple_wheelset_from_module.scad**

```openscad
use <vehicle_parts.scad>
$fa = 1;
$fs = 0.4;
module axle_wheelset(wheel_radius=10, wheel_width=6, track=35, radius=2) {
    translate([0,track/2,0])
        simple_wheel(wheel_radius=wheel_radius, wheel_width=wheel_width);
    axle(track=track, radius=radius);
    translate([0,-track/2,0])
        simple_wheel(wheel_radius=wheel_radius, wheel_width=wheel_width);
}
axle_wheelset();
```

If you simply wanted to only use the above set of simple_wheels, that approach would be just fine. The problem though is that this axle_wheelset module is not really flexible and parameterizable to the desired degree. On one hand you can customize all input parameters, but on the other hand, could you swap the simple_wheel design with the complex one? The fact is that with the above approach in order to do so you would have to define a completely new module.

**axle_with_complex_wheelset_from_module.scad**

```openscad
use <vehicle_parts.scad>
$fa = 1;
$fs = 0.4;
module axle_wheelset_complex(wheel_radius=10, side_spheres_radius=50, hub_thickness=4, cylinder_radius=2, track=35, radius=2) {
    translate([0,track/2,0])
        complex_wheel(wheel_radius=10, side_spheres_radius=50, hub_thickness=4, cylinder_radius=2);
    axle(track=track, radius=radius);
    translate([0,-track/2,0])
        complex_wheel(wheel_radius=10, side_spheres_radius=50, hub_thickness=4, cylinder_radius=2);
}
axle_wheelset_complex();
```

If you can't see yet how this is a problem, imagine the case where you had six different wheel designs and two different axle designs in your library. If you wanted to implement the axle_wheelset module you would need to define 12 different modules to cover all combinations of wheel and axle designs. Furthermore, if you were to add a new wheel or axle design in your collection, you would need to define a number of additional axle_wheelset modules which would make maintaining your library very hard.

The good thing is that the two modules above look very similar. If you could keep the structure of the module the same but have the specific choice of wheel design parameterized, then the problem could be solved. Fortunately, OpenSCAD supports this functionality and parameterizing the specific choice of wheel design can be achieved in the following way.

**axle_with_simple_wheelset_from_parameterized_module.scad**

```openscad
use <vehicle_parts.scad>
$fa = 1;
$fs = 0.4;
module axle_wheelset(track=35, radius=2) {
    translate([0,track/2,0])
        children(0);
    axle(track=track, radius=radius);
    translate([0,-track/2,0])
        children(0);
}
axle_wheelset() {
    simple_wheel();
}
```

The wheel design can now be effortlessly changed, making this module a truly parametric one.

**axle_with_complex_wheelset_from_parameterized_module.scad**

```openscad
axle_wheelset() {
    complex_wheel();
}
```

**axle_with_large_complex_wheelset_from_parameterized_module.scad**

```openscad
axle_wheelset(radius=5) {
    complex_wheel(wheel_radius=20);
}
```

There is a very important concept that you should grasp here. The first thing you should notice is the definition of this new module. This new module is similar to the previous ones with the difference that the command `children(0)` is used in place of a call to a specific wheel module. The second thing you should notice is the call to the axle_wheelset module. The call to the axle_wheelset module contains a pair of curly brackets inside of which the specific wheel design to be used by module is defined each time. OpenSCAD keeps an ordered list of the objects that have been defined inside the curly brackets and numbers them starting from zero. These objects can then be referenced by the `children` command. The number that is passed inside the children command corresponds to the first, second, third etc. object that was defined inside the curly brackets, counting from zero. In the above example, only one object is defined inside the curly brackets. That is either a simple_wheel or a complex wheel object. This object is created every time the `children(0)` command is used. The children command is in essence a way to pass objects as input to a module.

The next examples can help make this concept more concrete. In the previous example there is no way to use the axle_wheelset module and end up creating an axle that has different wheels on each side. This would not happen even if you passed/defined two different objects inside the curly brackets when calling the axle_wheelset module, because only the first one, `children(0)`, is referenced for both sides of the axle.

**axle_with_same_wheels_from_module.scad**

```openscad
axle_wheelset() {
    complex_wheel();
    simple_wheel();
}
```

In order to create an axle with different wheels on each side, the definition of the axle_wheelset module would need to be modified. Instead of referencing the first object, `children(0)`, for both sides, the axle_wheelset module would need to reference the first object, `children(0)`, for one side and the second object, `children(1)`, for the second side.

```openscad
module axle_wheelset(track=35, radius=2) {
    translate([0,track/2,0])
        children(0);
    axle(track=track, radius=radius);
    translate([0,-track/2,0])
        children(1);
}
```

By defining two different wheel objects inside the curly brackets, the following model would be created.

**axle_with_different_wheels_from_parameterized_module.scad**

```openscad
axle_wheelset() {
    complex_wheel();
    simple_wheel();
}
```

**Exercise:**
Try swapping the order in which the wheels are defined inside the curly brackets when calling the axle_wheelset module. What happens?

**Exercise:**
Try defining only one wheel inside the curly brackets? Do you get an error message?

**Exercise:**
Add an axle_wheel module on the vehicle_parts.scad script. Make use of the children command to parameterize the specific choice of wheel design. Use the vehicle_parts.scad script on another script to create any vehicle design that you like.

## Challenge

The material you have been learning in the last two chapters gives you a powerful set of tools to start creating your own library of objects that can be flexibly combined and customized to create new designs.

**Exercise:**
Think of any model that you would like to create. Break it down into different parts. Come up with alternative designs for each part and define modules that create them. What should the input parameters of each module be? Define one or more modules using the children functionality in order to flexibly combine the various parts that you have created.
