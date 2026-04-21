/**
  * Module: Steering servo bracket
  *
  * This module provides two mirrored brackets, one for each side of the servo's
  * mounting flange.
  *
  * Each bracket consists of two walls:
  * - one for attaching the servo to its mounting flange. All parameters of this
  *   wall, except for the thickness and hole diameter, are calculated
  *   automatically from the servo mounting flange parameters.
  * - one for attaching the bracket to the chassis. Since the servo is mounted
  *   on the chassis while lying on its side, the thickness of this wall is
  *   calculated automatically based on the servo mounting flange and the outer
  *   diameter of the nut used to fasten the servo. Its length is also
  *   calculated automatically based on the position of the wire socket on the
  *   servo body. At the same time, the bolt diameter, number of bolts, and
  *   spacing between them are defined by parameters.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/functions.scad>
use <../../lib/l_bracket.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../placeholders/bolt.scad>
use <../../placeholders/dservo.scad>
use <../../placeholders/nut.scad>
use <../../placeholders/tie_rod_end.scad>
use <../../placeholders/tie_rod_shaft.scad>
use <../bellcrank/bellcrank_drive.scad>
use <util.scad>

module servo_l_bracket_chasis_slot_child(skip_rotation=false) {
  params = steering_servo_bracket_params();
  bracket_w = params[0];
  servo_bracket_y = params[2];
  chassis_bolt_y = params[5];

  chassis_bolt_step = steering_servo_bracket_chassis_bolt_gap
    + steering_servo_mount_bolt_d;

  module _main() {
    translate([bracket_w / 2, chassis_bolt_y, 0]) {
      for (i = [0 : steering_servo_bracket_chassis_bolt_n - 1]) {
        let (y = i * chassis_bolt_step) {
          translate([0, -y, 0]) {
            children();
          }
        }
      }
    }
  }

  if (skip_rotation) {
    _main() {
      children();
    }
  } else {

    translate([0, servo_bracket_y, 0]) {
      rotate([-90, 0, 0]) {
        _main() {
          children();
        }
      }
    }
  }
}

module servo_l_bracket_slots_children(servo_size=dsservo_size,
                                      flange_h=dsservo_flange_h,
                                      flange_z_offset=dsservo_flange_z_offset,
                                      bracket_thickness=steering_servo_bracket_thickness) {
  servo_l = servo_size[0];
  servo_w = servo_size[1];
  servo_h = servo_size[2];
  bracket_extra_h = (servo_w - flange_h) / 2;

  translate([-dsservo_height_after_flange(servo_h=servo_h,
                                          flange_z_offset=flange_z_offset)
             + bracket_thickness,
             0,
             flange_h / 2 + bracket_extra_h]) {
    rotate([90, 0, -90]) {
      translate([servo_l / 2, 0, 0]) {
        children();
      }
      translate([-servo_l / 2, 0, 0]) {
        mirror([1, 0, 0]) {
          children();
        }
      }
    }
  }
}
