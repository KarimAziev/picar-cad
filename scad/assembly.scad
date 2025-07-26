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
use <steering_system/knuckle_shaft.scad>
use <wheels/rear_wheel.scad>

module assembly_view(motor_type=motor_type,
                     show_motor=true,
                     show_wheels=true,
                     show_rear_panel=true,
                     show_front_panel=true,
                     show_ackermann_triangle=true) {
  union() {
    translate([chassis_width / 2 + front_wheel_offset() + wheel_w,
               0,
               knuckle_shaft_vertical_len + knuckle_shaft_dia
               + tire_thickness +
               wheel_rim_h * 2]) {
      translate([0,
                 steering_servo_chassis_y_offset,
                 rack_mount_panel_thickness / 2]) {
        steering_system_assembly();
      }

      translate([0, steering_servo_chassis_y_offset
                 + pan_servo_y_offset_from_steering_panel,
                 chassis_thickness]) {
        translate([-2, 0, 25.9]) {
          rotate([0, 0, 180]) {
            head_assembly();
          }
        }
      }
      rotate([0, 180, 0]) {
        chassis_plate(show_motor=show_motor,
                      show_wheels=show_wheels,
                      motor_type=motor_type,
                      show_rear_panel=show_rear_panel,
                      show_front_panel=show_front_panel,
                      show_ackermann_triangle=show_ackermann_triangle);
      }
    }
  }
}

assembly_view();