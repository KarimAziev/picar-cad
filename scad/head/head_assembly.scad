/**
 * Module: Head assembly view.
 *
 * The module demonstrates the assembly of the head and neck with two servos (tilt and pan).
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
use <head_mount.scad>
use <head_neck_mount.scad>

module head_assembly(head_color="white",
                     neck_color="white",
                     pan_servo_color="#343434",
                     tilt_servo_color="#343434",
                     animation_z_offset=-12) {
  union() {
    rotate([30 * sin(360 * $t), 0, 0]) {
      translate([0, 0, animation_z_offset]) {
        translate([0, -head_side_panel_width * 0.5,
                   head_side_panel_height * 0.5]) {
          rotate([90, 0, 180]) {
            color(head_color) {
              head_mount();
            }
          }
        }
      }
    }

    translate([0, 0, animation_z_offset]) {
      translate([-2, 6, -(cam_pan_servo_slot_height + cam_pan_servo_height) * 0.5 + 2]) {
        rotate([0, 0, -90]) {
          head_neck_assembly(neck_color=neck_color,
                             pan_servo_color=pan_servo_color,
                             tilt_servo_color=tilt_servo_color);
        }
      }
    }
  }
}

head_assembly();