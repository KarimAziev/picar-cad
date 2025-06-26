// This file shows the complete 3D assembled model for demonstration purposes.

include <parameters.scad>
use <head_mount.scad>
use <chassis.scad>
use <steering_system/ackermann.scad>
use <steering_system/knuckle.scad>
use <steering_system/ackermann_assembly.scad>
use <placeholders/motor.scad>
use <placeholders/wheel.scad>
use <head_neck_mount.scad>

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
        wheel();
      }
    }
  }
}

module front_wheel_right() {
  translate([18, 159.6, -15]) {
    translate([(chassis_width * 0.5) - (motor_mount_panel_thickness * 0.5),
               (-chassis_len * 0.5 + motor_mount_panel_width * 0.5) + 20,
               0.5]) {
      rotate([180, 90, 0]) {
        front_wheel();
      }
    }
  }
}

union() {
  translate([0, 70, -14]) {
    rotate([0, 0, 0]) {
      ackermann_assembly_demo();
    }
  }

  translate([0, wheels_offset_y + pan_servo_wheels_y_offset - cam_pan_servo_slot_height * 0.5 - 1,
             chassis_thickness]) {
    rotate([0, 0, 90]) {
      head_neck_assembly();
    }
    translate([pan_servo_extra_h * 0.01, 29.8, 38.5]) {
      rotate([90, 0, 0]) {
        color("white") {
          head_mount();
        }
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