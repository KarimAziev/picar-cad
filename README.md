This repository contains the 3D model source files for a custom four-wheeled robot with a head mount for two Raspberry Pi Camera Module 2 sensors, and side panels for mounting to a pan-servo setup. The models are written entirely in [OpenSCAD](https://openscad.org/), do not require any external libraries, and are designed to be 3D-printed.

![Demo](./demo/picar-cad-assembly.gif)

![Demo Full](./demo/picar-cad-full.jpg)

The design focuses on a four-wheeled robot with the following features:

- The front wheels are steered by a servo mechanism using Ackermann geometry.
- The rear wheels are driven by two motors.
- A head mount is designed to support two Raspberry Pi Camera Modules.
- Multiple independent power modules can be mounted (for example, one for the Servo HAT, one for the Motor Driver HAT, and one for a UPS module that powers a Raspberry Pi 5).

![Demo Head](./demo/picar-cad-head-demo.gif)
