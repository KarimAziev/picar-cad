/**
 * Module: Assembly view.
 *
 * The module shows the complete 3D assembled model for demonstration purposes.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <parameters.scad>
use <head/head_assembly.scad>
use <head/head_mount.scad>
use <head/head_neck_mount.scad>
use <chassis.scad>
use <steering_system/rack_and_pinion_assembly.scad>
use <placeholders/motor.scad>
use <wheels/rear_wheel.scad>

module assembly_view() {
  union() {
    translate([chassis_width / 2 + wheel_w + wheel_w / 2 + 5, 0, wheel_dia / 2 + 25]) {
      translate([0, steering_servo_chassis_offset, steering_servo_panel_thickness]) {
        rotate([0, 0, 0])
          steering_system_assembly();
      }

      translate([0, steering_servo_chassis_offset + pan_servo_wheels_y_offset, chassis_thickness]) {
        translate([-2, 0, 25.9]) {
          rotate([0, 0, 180]) {
            head_assembly();
          }
        }
      }
      rotate([0, 180, 0]) {
        chassis_plate(show_motor_and_rear_wheels=true);
      }
    }
  }
}

assembly_view();