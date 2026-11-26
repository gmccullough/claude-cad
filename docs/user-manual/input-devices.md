# OpenSCAD User Manual: Input Devices

> Source: [https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Input_Devices](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Input_Devices)

## Introduction

**Note: Requires version 2019.05**

The input driver enables the use of devices such as a gamepad, or a 3D mouse, in OpenSCAD.

Currently, the following drivers are in development:

- **HIDAPI** - Used on MacOS and Windows - needs the USB IDs / it works on Linux too, but needs additional privileges, so it's not ideal for the user
- **Joystick driver** - uses the Linux joystick device (currently fixed `/dev/input/js0`)
- **SpaceNav driver** - via the spacenavd daemon
- **DBus driver** - Linux only. Not for actual devices, but for remote control
- **QGamepad** - Used for cross-platform joystick support - This seems to require some additional configuration on Qt level currently. Needs some more work to make it easy to use

The default axes mapping is for 3D mice.

## How to try it out

The input driver is currently part of the current development snapshots and nightly builds.

These builds can be found here: [http://www.openscad.org/downloads.html#snapshots](http://www.openscad.org/downloads.html#snapshots)

## Joystick and gamepads

On Linux, you have the option to use the native joystick driver or the cross-platform QGamepad driver. The native Joystick driver is recommended.

On other platforms, OpenSCAD is currently limited to QGamepad.

### Joystick driver

#### Linux

The Joystick input driver uses the device `/dev/input/js0`.

On Ubuntu, you need to have the joystick package installed to enable joystick support.

Almost any controller that your Linux computer recognizes should work.

**Example Input Mapping for an Xbox 360 controller with Linux, using the native Joystick Driver:**
- Notice the increased dead zone due to worn out joysticks.
- Axis 5 and 2 are triggers, they have a trim of 1 applied as their ideal value is typical -1.0 and are mapped to zoom.

### QGamepad driver

QGamepad can be used with Windows and Linux.

The QGamepad driver makes assumptions about the gamepad that might not be true. Using an Xbox 360 or compatible controller works best.

Other controllers might be limited by QGamepad. (e.g. unable to map buttons and/or axes)

QGamepad treats the D-Pad of the Xbox 360 Controller as buttons.

## 3D mouse

### Linux

On Linux, the easiest way to use the Space Mouse Wireless is to go through the Joystick driver that is normally enabled on most systems.

#### Spacenav

Spacenav is also supported. See [http://spacenav.sourceforge.net/](http://spacenav.sourceforge.net/) and [https://wiki.archlinux.org/index.php/3D_Mouse#Open_Source_Drivers](https://wiki.archlinux.org/index.php/3D_Mouse#Open_Source_Drivers)

```bash
sudo apt-get spacenavd
```

On Debian:

```bash
sudo apt install libspnav-dev
```

(requires a restart)

#### HIDAPI

In order to use the HIDAPI with Linux, OpenSCAD needs to be able to access the system with root privileges.

This is not recommended, but it may be helpful for temporary troubleshooting.

The recommended approach is to figure out which vendor ID and product ID your device has and then add a udev rule that allows non-privileged users to use the device.

To figure out your product's ID, use the `lsusb` command. This is how a relevant line of output from lsusb might look:

```
$ lsusb
[...]
Bus 002 Device 006: ID 046d:c627 Logitech, Inc. 3Dconnexion Space Explorer 3D Mouse
```

Both the vendor and product IDs are contained in the string `ID 046d:c627`. The vendor ID is the first part: `046d`. The device ID is the second part: `c627`.

This Stack Overflow answer has an example of a udev rule. You can also refer to the Arch Linux Wiki entry for 3D mice and creating udev rules for regular users.

### Windows

OpenSCAD interacts directly with the 3D mouse using the HIDAPI.

Therefore, the device manufacturer's driver is not required.

#### Disabling the device manufacturer's driver

If the device manufacturer's driver is installed, it has to be stopped.

Here are two ways to stop the driver:

1. In your Start menu, you should have a folder called "3Dconnexion". Open the "Stop Driver" item from that folder.
2. You can also try to run the following command: `"C:\Program Files\3Dconnexion\3DxWare\3DxWinCore64\3DxService.exe" -shutdown`

#### Using a wireless receiver

The wireless version (3DX-700066) of the 3D mouse has a receiver that registers multiple HID devices - you might need to disable some of them ('HID-compliant vendor-defined device') in the Device Manager to get it to pick up the correct one.

If your 3D mouse works when it is connected via the cable, but not via the wireless receiver (and OpenSCAD detects a 3D mouse, but doesn't detect any input), this is potentially the problem you're having.

### macOS

As with other platforms, you have to disable the native 3DConnexion drivers completely, as OpenSCAD does not use them.

To enable the built-in driver for the SpaceMouse, go to Preferences > Axes, turn on the HIDAPI setting, and restart OpenSCAD.

The following devices have been tested and are known to work with OpenSCAD on macOS Mojave:

- SpaceMouse Compact (USB)
- SpaceMouse Wireless

## DBus

The D-Bus driver can be used for remote controlling OpenSCAD. This is mainly intended for programmers. For example, it can be used to write a custom input driver.

### Debug and testing

For debugging and testing, D-Feet can be used. OpenSCAD can be found on the Session Bus under `org.openscad.OpenSCAD`.

`qdbus` is NOT recommended as it has issues with some of the more complex data structures.

### Example

An example for QT/C++ can be found on the wiki page.

### Camera System

Note that OpenSCAD's camera behavior and system does not behave in a standard way. Via DBus, you are directly interacting with OpenSCAD's camera. Note: the camera system and its interface may be refactored at some point in the future.

### Actions

Please note that the actions exposed via DBus are mostly the ones from OpenSCAD's menu bar. Keep in mind that the menu bar might change at some point and that compatibility with the DBus driver is not a priority for development.

## FAQ

### Which button is which?

Open preferences, go to the button tab, then press the button you want to assign. The text next to the relevant ComboBox appears red and bold.

### View is drifting

If your view is drifting, please re-calibrate the neutral position and deadzone of your input device. This can be done within OpenSCAD or with the tools of the operating system.

### Where are my settings stored?

See OpenSCAD's Github wiki.

### Y+Viewport-rel-translation (VRT) Channel is not responding to input

You are in orthogonal view. Please change it to perspective to see what it does.

Or look in the bottom left corner, where translate = changes. This is not a bug, this is a very specific feature. When you map zoom to one axis and Y+Viewport-rel-translation to another while in perspective view, you should get the vertigo effect.

Most users use zoom as it works in both orthogonal and perspective.

If you're wondering why you can map two axes to zoom: Many game controllers have two analog shoulder triggers. This has little to no real world use, but is about giving the user as much control as possible.
