This repository contains the 3D model source files for a four-wheeled robot chassis and steering system, written entirely in [OpenSCAD](https://openscad.org/). The design supports 3D printing and does not rely on external libraries.

![Demo](./demo/picar-cad-assembly.gif)

![Photo](./demo/picar-cad-real-photo.jpg)

## Overview

The robot model is designed around the following core elements:

- **Ackermann Steering**: Front wheels are steered via a pinion and rack assembly driven by a standard servo.
- **Rear-Wheel Drive**: Two individual motors drive the rear wheels. Both standard yellow DC motors and N20-type motors are supported.
- **Modular Head Mount**: The head mount is designed to accommodate two Raspberry Pi Camera Module 2 sensors (e.g., day/night configuration).
- **Extendable Power Tiers**: Side and center slots allow for independent modules for power management: servo driver HAT, motor driver HAT, UPS for Raspberry Pi 5, etc.
- **Raspberry Pi**: The chassis includes placements and screw holes for the Raspberry Pi 5 and multiple 18650 battery holders.

## Structure

The project is organized into several reusable modules under the `scad/` directory:

- `parameters.scad`: Central configuration for physical dimensions (units in millimeters).
- `chassis.scad`: Main robot chassis, mounting platforms, wiring cutouts.
- `steering_system/`: Rack-and-pinion implementation based on Ackermann geometry.
- `head/`: Mounting system for dual Raspberry Pi cameras.
  ![Demo Head](./demo/picar-cad-head-demo.gif)
- `motor_brackets/`: Brackets for both "yellow" and N20-style motors.
- `wheels/`: Components for rear and front wheels, including hubs and tires.
- `placeholders/`: Placeholder geometry for components such as Raspberry Pi, servo and DC-motors, batteries holders, HATs.
