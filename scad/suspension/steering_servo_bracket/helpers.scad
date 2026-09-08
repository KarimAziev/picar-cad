/**
  * Module: Common helpers used in both the assembly and slot modules
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

function steering_servo_encoder_bracket_bend_reach(plist=steering_encoder_plist,
                                                    magnet_h=steering_magnet_h,
                                                    arm_base_h=steering_servo_arm_base_h,
                                                    side_thickness=steering_encoder_side_thickness,
                                                    magnet_distance=steering_encoder_magnet_distance) =
  !plist
  ? 0
  : dsservo_output_attachment_height()
  + arm_base_h
  + dsservo_encoder_bracket_arm_offset(plist=plist,
                                       magnet_h=magnet_h,
                                       side_thickness=side_thickness,
                                       magnet_distance=magnet_distance);

function steering_servo_encoder_chassis_reach(plist=steering_encoder_plist,
                                               magnet_h=steering_magnet_h,
                                               arm_base_h=steering_servo_arm_base_h,
                                               side_thickness=steering_encoder_side_thickness,
                                               magnet_distance=steering_encoder_magnet_distance,
                                               bottom_pan_bolt_d=steering_encoder_bottom_pan_bolt_d,
                                               bottom_pan_bolt_pad=steering_encoder_bottom_pan_bolt_pad) =
  !plist
  ? 0
  : steering_servo_encoder_bracket_bend_reach(plist=plist,
                                               magnet_h=magnet_h,
                                               arm_base_h=arm_base_h,
                                               side_thickness=side_thickness,
                                               magnet_distance=magnet_distance)
  + bottom_pan_bolt_pad
  + bottom_pan_bolt_d;

module steering_servo_encoder_bracket_position(plist=steering_encoder_plist,
                                               magnet_h=steering_magnet_h,
                                               arm_base_h=steering_servo_arm_base_h,
                                               side_thickness=steering_encoder_side_thickness,
                                               magnet_distance=steering_encoder_magnet_distance,
                                               target_h=dsservo_size[1] / 2,
                                               center_y=false) {
  bend_x = steering_servo_encoder_bracket_bend_reach(plist=plist,
                                                      magnet_h=magnet_h,
                                                      arm_base_h=arm_base_h,
                                                      side_thickness=side_thickness,
                                                      magnet_distance=magnet_distance);
  output_shaft_y = -dsservo_size[0] / 2 + dsservo_gearbox_d1 / 2;

  maybe_translate([0, center_y ? 0 : -dsservo_flange_w / 2, 0]) {
    translate([-bend_x,
               output_shaft_y,
               dsservo_size[1] / 2 - target_h]) {
      // In the assembled servo orientation, the bracket's local +Y points
      // toward chassis -X while its local +X points toward chassis +Y.
      rotate([0, 0, 90]) {
        children();
      }
    }
  }
}

module servo_l_bracket_chassis_slot_child(skip_rotation=false) {
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
