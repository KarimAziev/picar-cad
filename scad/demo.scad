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
use <wheels/front_wheel.scad>

module motor_right() {
  translate([-9, 15, -14]) {
    translate([(chassis_width * 0.5) - (motor_mount_panel_thickness * 0.5),
               (-chassis_len * 0.5 + motor_mount_panel_width * 0.5) + 17,
               -1.5]) {
      rotate([90, 0, -90]) {
        motor();
      }
    }
  }
}

module rear_wheel_right() {
  translate([17, 18.2, -17]) {
    translate([(chassis_width * 0.5) - (motor_mount_panel_thickness * 0.5),
               (-chassis_len * 0.5 + motor_mount_panel_width * 0.5) + 20,
               0.5]) {

      rotate([180, 90, 0]) {
        rear_wheel();
      }
    }
  }
}

module front_wheel_right() {
  translate([18, 159.6, -15]) {
    translate([(chassis_width * 0.5) - (motor_mount_panel_thickness * 0.5),
               (-chassis_len * 0.5 + motor_mount_panel_width * 0.5) + 20,
               0.5]) {
      rotate([0, 90, 0]) {
        front_wheel();
      }
    }
  }
}

union() {
  translate([0, 65, -24]) {
    rotate([0, 0, 0]) {
      color("#191919") {
        steering_system_assembly();
      }
    }
  }

  translate([0, wheels_offset_y + pan_servo_wheels_y_offset - cam_pan_servo_slot_height * 0.5 - 1,
             chassis_thickness]) {
    translate([-2, 7.4, 25.9]) {
      rotate([0, 0, 180]) {
        head_assembly();
      }
    }
  }
  color("white") {

    rotate([0, 180, 0]) {
      chassis_plate();
    }
  }
  motor_right();
  mirror([1, 0, 0]) {
    motor_right();
  }

  color("grey") {
    rear_wheel_right();
    mirror([1, 0, 0]) {
      rear_wheel_right();
    }
    front_wheel_right();
    mirror([1, 0, 0]) {
      front_wheel_right();
    }
  }
}
