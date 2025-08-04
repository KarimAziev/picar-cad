/**
 * Module: Robot Build Plate Arrangement
 *
 * This file arranges all robot parts on the printer’s build plate for fabrication.
 *
 * It assembles a robot chassis with a four-wheeled configuration:
 *    - The front wheels are steered via a servo mechanism.
 *    - The rear wheels are driven by two motors.
 *
 * In addition, the design prioritizes mounting options for multiple independent power modules - for example:
 *    - One for the servo HAT,
 *    - One for the motor driver HAT, and
 *    - One for a UPS module (e.g., UPS_Module_3S) that can power the Raspberry Pi 5.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <parameters.scad>
use <chassis.scad>
use <head/head_mount.scad>
use <head/head_neck_mount.scad>
use <front_panel.scad>

color("white") {
  chassis();
  half_wheels_distance = steering_panel_length * 0.5;

  translate([(chassis_width / 2 + head_plate_width * 0.5) + 6, 0, 0]) {
    head_mount();
    translate([0, -head_plate_height, 0]) {
      head_neck_mount();
    }
  }

  translate([-(steering_panel_length / 2) - front_panel_height * 0.5,
             chassis_len * 0.5 - front_panel_width * 0.5,
             0]) {
    rotate([0, 0, 90]) {
      front_panel_back_mount();
    }
  }
}
