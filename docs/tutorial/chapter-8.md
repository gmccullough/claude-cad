# OpenSCAD Tutorial - Chapter 8

> Source: https://en.wikibooks.org/wiki/OpenSCAD_Tutorial/Chapter_8

---

< [Chapter 7](chapter-7.md) | **Chapter 8** | [Chapter 9](chapter-9.md) >

## Rotationally Extruding 3D Objects from 2D Objects

So far you have been creating a lot of models and customizing your car designs while developing solid parametric modelling skills and exploring different features of OpenSCAD. It's quite impressive when you consider that every model you have created so far makes use of just three primitives: the sphere, the cube and the cylinder. By combining these primitives with the transformation commands you can create a plethora of models, but there are still models that can't be created by using these primitives alone. One such example is a wheel design that requires the creation of an object that looks like a donut.

This donut shaped object can't be created with the use of the sphere, cube and cylinder primitives. Instead it requires the use of 2D primitives and a new command which can create 3D shapes from 2D profiles. Specifically, the donut can be created by first defining a circular 2D profile using the circle primitive and then rotationally extruding this profile using the `rotate_extrude` command.

**circular_profile.scad**

```openscad
$fa = 1;
$fs = 0.4;
wheel_radius = 12;
tyre_diameter = 6;
translate([wheel_radius - tyre_diameter/2, 0])
    circle(d=tyre_diameter);
```

**extruded_donut.scad**

```openscad
$fa = 1;
$fs = 0.4;
wheel_radius = 12;
tyre_diameter = 6;
rotate_extrude(angle=360) {
    translate([wheel_radius - tyre_diameter/2, 0])
        circle(d=tyre_diameter);
}
```

There are a few things you should notice about the 2D profile that you have created. In this case, the 2D profile is created using the `circle` command, and the diameter is set equal to the `tyre_diameter` variable. This was done because the donut-shaped object will correspond to the tyre of the wheel. Later on, you may discover other 2D primitives like the `square` command.

Any 2D profiles you plan to extrude should be created on the X-Y plane, and typically in the region where X is positive. Defined mathematically, 2D profiles usually reside where X >= 0, and Z = 0. Also, 2D profiles always have zero thickness. This means that 2D profiles are never used directly as a part of the model, but are instead used in conjunction with the `rotate_extrude` and `linear_extrude` commands to define 3D objects.

You should notice a few things about the use of the `rotate_extrude` command as well. The rotate extrude command is used to create 3D objects, and always requires a 2D profile as an input. The commands that create the desired 2D profile need to be placed inside the pair of curly brackets that follows the `rotate_extrude` command. The 3D object that is created by the `rotate_extrude` command is the result of rotating the 2D profile around the Y axis. The resulting 3D object is then placed so that its axis of rotation lies along the Z-axis. This quirk can take some getting used to at first, so it may help to review the process one step at a time.

1. First, the `rotate_extrude` command takes a 2D profile as an input.
2. Then it creates a 3D object which is the result of rotating the supplied 2D profile around the Y axis.
3. Finally, it places the 3D model as if it were rotated by 90 degrees around the X axis. The result is that the Y axis which the model was revolved around has been rotated up to align with the Z axis.

The `rotate_extrude` command has one input parameter named `angle`. The angle parameter is used to define how many degrees the 2D profile will be rotated around the Y axis. In this case the angle parameter is set equal to 360 degrees which corresponds to a full circle.

Setting the angle parameter equal to 60 degrees would create a partial extrusion. While setting it equal to 270 degrees would create a larger partial extrusion. And so forth.

### Exercise - Complete the Wheel

Complete the new wheel design by defining the missing cylinder object. The height of the cylinder should be equal to the value of a `wheel_width` variable, while the radius of the cylinder should be equal to `wheel_radius - tyre_diameter/2`. The cylinder should be centred on the origin.

### Exercise - Rounded Simple Wheel Module

To make this wheel compatible with the models from the previous chapters rotate it by 90 degrees around the X axis. Turn this wheel design into a module named `rounded_simple_wheel` and add it on your `vehicle_parts.scad` script for later use.

### Exercise - Axisymmetric Wheel

The above wheel is an axisymmetric object, which means it exhibits symmetry around an axis. Specifically, the axis of symmetry is the axis around which the 2D profile was rotated to form the 3D object. When an object is axisymmetric it can be created with just one `rotate_extrude` command as long as the appropriate 2D profile is supplied. This is not the case with the above wheel design as the center part was added with a cylinder command separate from the rotational extrusion. Remove the cylinder command from the above module and make appropriate additions on the supplied 2D profile so that the whole wheel is created by the `rotate_extrude` command.

You should remember that axisymmetric objects can be completely created out of a `rotate_extrude` command. The previous wheel design is a concrete example of this. Whether you decide to create an axisymmetric object by supplying the 2D profile of the whole object and by using a single `rotate_extrude` or by using a `rotate_extrude` command only for its parts that can't be created in any other way, depends on each case and is up to you. If you wanted for example to further modularize your wheel designs and separate them into combinable tire and rim modules, you would inevitably need to create the donut-shaped tire using a `rotate_extrude` command. Since in this case the rim of the wheel would be a separate module without a `rotate_extrude` command already present in it, the simplest and most straight forward way to create it would be by using a cylinder command.

## Challenge

It's time to put your new knowledge into practice to create a rim for a mini robot car project.

### Exercise - Mounting Hole

Extend the `rounded_simple_wheel` module, so that the wheel design has a hole on its hub that can be used for mounting it on an axle. To do so you would need to subtract a cylinder from the existing model using a `difference` command. The diameter of the hole should be equal to a new module input parameter named `axle_diameter`. The default value of this parameter should be 3 units. By the way in which you define the height of the cylinder you should guarantee that the cylinder is always a bit longer than the width of the wheel to avoid any errors when using the `difference` command. After saving the modified module you should use it to create a version of a wheel with `wheel_radius`, `wheel_width`, `tire_diameter` and `axle_diameter` of 20, 6, 4 and 5 units respectively.

### Exercise - Robot Rim

This wheel design looks about right for a mini robot car application, but you could do something to give more traction to your robot. Instead of 3D printing the whole wheel, you could just 3D print the rim and then add an O-ring or rubber band as the tire for more traction.

Using the `rounded_simple_wheel` module as a guide, create a new module named `robot_rim`. The `robot_rim` module should have the same input parameters as the `rounded_simple_wheel` module. Add all necessary commands to the `robot_rim` module so that it creates the rim design. There are two ways in which you can do this.

**First approach:** Subtract the circle that corresponds to the tire from the square that corresponds to the rim in the definition of the design's 2D profile inside the `rotate_extrude` command and then additionally subtract the axle's cylinder from the resulting 3D object to get the final rim design.

**Second approach:** Subtract a donut-shaped object that corresponds to the tire and the cylinder that corresponds to the axle hole from the larger cylinder that corresponds to the rim.

Remember, while there is some conventional wisdom surrounding good design practices, there is no objectively right or wrong choice. In practice you would most likely go with the option that first came to mind or that made the most sense to you. For the sake of this exercise, consider trying it both ways to see which approach you like the most.

### Manufacturing Considerations

Often, it's helpful to consider the manufacturing process that will be used in an object's creation when designing a new part. Usually, this consideration promotes designs that accommodate the manufacturing method at hand, but it can guide your modeling process as well.

For example, consider a scenario where instead of using additive manufacturing like 3D printing to manufacture this robot wheel, you used subtractive manufacturing like lathe or a mill. In this case you might opt to use the second approach, since it would more closely replicate the manufacturing process at hand, and could give you a better estimate of how many steps the final manufacturing process might take.

## Linearly Extruding 3D Objects from 2D Objects

As briefly mentioned, there is another OpenSCAD command that can be used to create 3D objects from supplied 2D profiles. This is the `linear_extrude` command. In contrast to the `rotate_extrude` command, `linear_extrude` creates a 3D object by extending along the Z axis a 2D profile that lies on the XY plane. Similar to the `rotate_extrude` command, `linear_extrude` can be used when the 3D object you want to create can't be directly created by combining available 3D primitives. One such example is the following.

**extruded_ellipse.scad**

```openscad
$fa = 1;
$fs = 0.4;
linear_extrude(height=50)
    scale([2,1,1])
    circle(d=10);
```

The above object is a tube that has the following profile.

**ellipse_profile.scad**

```openscad
$fa = 1;
$fs = 0.4;
scale([2,1,1])
    circle(d=10);
```

There are a few points you should notice regarding the use of `linear_extrude`. The syntax of `linear_extrude` is similar to the syntax of the `rotate_extrude` command. The commands that create the 2D profile that will be extruded along the Z axis need to be placed inside a pair of curly brackets that follows the `linear_extrude` command. The parameter `height` is used to define how many units along the Z axis the 2D profile is going to be extruded. By default, the 2D profile is extruded along the positive direction of the Z axis by an amount of units equal to the value assigned to the `height` parameter.

### Center Parameter

By passing an additional parameter named `center` and setting it equal to true, the 2D profile is extruded along both directions of the Z axis. The total length of the resulting object will still be equal to the `height` parameter.

**centered_extrusion.scad**

```openscad
linear_extrude(height=50,center=true)
    scale([2,1,1])
    circle(d=10);
```

### Twist Parameter

An additional parameter named `twist` can also be used to twist the resulting 3D object around the Z axis by the specified angle.

**extrusion_with_twist.scad**

```openscad
linear_extrude(height=50,center=true,twist=120)
    scale([2,1,1])
    circle(d=10);
```

### Scale Parameter

Finally, another parameter named `scale` can be used to scale one end of the resulting 3D by the specified scaling factor.

**extrusion_with_twist_and_scale.scad**

```openscad
linear_extrude(height=50,center=true,twist=120,scale=1.5)
    scale([2,1,1])
    circle(d=10);
```

### Summary

It should be pretty clear by now how the `rotate_extrude` and `linear_extrude` commands give you the ability to create objects that wouldn't be possible by directly combining the available 3D primitives. You can use these commands to create more abstract and artistic designs but let's see how you could use the `linear_extrude` command to create a new car body.

### Exercise - Extruded Car Body

Use the `linear_extrude` command similar to the above examples in order to create a new car body. You should create a new module named `extruded_car_body`. The module should have a `length`, `rear_height`, `rear_width` and `scaling_factor` input parameter. The default values of the parameters should be 80, 20, 25 and 0.5 units respectively. The length and scaling factor parameters of the module will be used in the call to `linear_extrude` command to set the values of its `height` and `scale` parameters. The supplied 2D profile should be a circle that has been resized according to the `rear_height` and `rear_width` parameters.

### Exercise - Rounded Extruded Body

Extend the previous module by adding a boolean input parameter named `rounded`. The default value of the parameter should be false. If the `rounded` parameter is set to true, then two additional objects should be created at the front and rear of the body in order to make it rounded. These two objects are spheres that have been resized and scaled. Try figuring out an appropriate way to resize and scale the sphere to achieve a rounded result.

### Exercise - Use the New Body

Use the new rounded body in any car design that you like.

### Looking Ahead

As mentioned, the `rotate_extrude` and `linear_extrude` commands can also be used to create more abstract objects. When the supplied 2D profile is created using the available circle and square 2D primitives and when the twist and scale parameters of the `linear_extrude` command are not utilized, then the resulting 3D object could also be directly created using the available 3D primitives. What really makes the use of these commands much more powerful is the ability to create any 2D profile that is not a combination of circles and squares but rather an arbitrary shape. This ability is available through the use of the `polygon` 2D primitive which you are going to learn about in the next chapter.

---

*This page was last edited on 26 February 2024, at 18:37.*
*Text is available under the Creative Commons Attribution-ShareAlike License.*
