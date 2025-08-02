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
use <placeholders/rpi_5.scad>
use <wheels/rear_wheel.scad>
use <motor_brackets/n20_motor_bracket.scad>

module assembly_view(motor_type=motor_type,
                     show_motor=true,
                     show_wheels=true,
                     show_rear_panel=true,
                     show_front_panel=true,
                     show_ackermann_triangle=true,
                     show_ups_hat=true,
                     show_steering=true,
                     show_wheels=true,
                     show_bearing=true,
                     show_brackets=true,
                     show_rpi=true,
                     show_head=true) {
  chassis_assembly(show_motor=show_motor,
                   show_wheels=show_wheels,
                   motor_type=motor_type,
                   show_ups_hat=show_ups_hat,
                   show_rear_panel=show_rear_panel,
                   show_front_panel=show_front_panel,
                   show_ackermann_triangle=show_ackermann_triangle,
                   show_rpi=show_rpi,
                   show_steering=show_steering,
                   show_bearing=show_bearing,
                   show_brackets=show_brackets) {
    if (show_head) {
      translate([0, steering_panel_y_position_from_center
                 + pan_servo_y_offset_from_steering_panel,
                 chassis_thickness]) {
        translate([-2, 0, 25.9]) {
          rotate([0, 0, 180]) {
            head_assembly();
          }
        }
      }
    }
  }
}

assembly_view(show_wheels=true,
              show_motor=true,
              show_rear_panel=true,
              show_front_panel=true,
              show_ups_hat=true,
              show_rpi=true,
              show_ackermann_triangle=false,
              show_steering=true,
              show_bearing=true,
              show_brackets=true,
              show_head=true);