/**
  * Module: Steering servo bracket
  *
  * This module provides a single bracket for for the servo's mounting flange.
  *
  * The bracket consists of two walls:
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
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../placeholders/bolt.scad>
use <../../placeholders/dservo.scad>
use <../bellcrank/bellcrank_drive.scad>
use <helpers.scad>
use <util.scad>

show_servo_bolt       = false;
show_servo_bolt_nut   = false;

show_chassis_bolt     = false;
show_chassis_bolt_nut = false;

module servo_l_bracket(color=white_smoke_1,
                       lower_thickness_clearance=steering_servo_bracket_lower_thickness_clearance,
                       chassis_thickness=upper_chassis_t,
                       w_clearance=steering_servo_bracket_w_clearance,
                       show_servo_bolt=show_servo_bolt,
                       show_chassis_bolt=show_chassis_bolt,
                       show_chassis_bolt_nut=show_chassis_bolt_nut,
                       show_servo_bolt_nut=show_servo_bolt_nut) {
  hole_fn = $preview ? 16 : 200;
  servo_bolt_through_l = dsservo_hat_thickness + steering_servo_bracket_thickness;

  bolt_spec = find_bolt_nut_spec(steering_servo_bracket_servo_bolt_d,
                                 default=[]);

  lock_nut_spec = plist_get("lock_nut", bolt_spec, []);
  servo_nut_h = plist_get("height", lock_nut_spec);

  servo_bolt_h = servo_nut_h + servo_bolt_through_l;

  servo_w = dsservo_size[0];

  params = steering_servo_bracket_params(lower_thickness_clearance=lower_thickness_clearance);

  bracket_w = params[0];
  chassis_mount_pan_l = params[1];
  servo_bracket_y = params[2];
  bracket_extra_h = params[3];
  lower_thickness = params[4];

  union() {
    maybe_color(color) {
      linear_extrude(height=steering_servo_bracket_thickness, center=false) {
        difference() {
          translate([w_clearance, servo_bracket_y, 0]) {
            rounded_rect([bracket_w - w_clearance,
                          dsservo_hat_h + bracket_extra_h],
                         center=false,
                         side="top",
                         r_factor=0.5);
          }
          translate([-servo_w / 2, 0, 0]) {
            four_corner_children(size=dsservo_bolt_spacing, center=true) {
              circle(d=steering_servo_bracket_servo_bolt_d, $fn=hole_fn);
            }
          }
        }
      }

      translate([0, servo_bracket_y, 0]) {
        rotate([-90, 0, 0]) {
          linear_extrude(height=lower_thickness, center=false) {
            difference() {
              translate([w_clearance, 0, 0]) {
                rounded_rect([bracket_w - w_clearance, chassis_mount_pan_l],
                             center=false,
                             r_factor=0.5,
                             side="top");
              }
              servo_l_bracket_chasis_slot_child(skip_rotation=true) {
                circle(d=steering_servo_mount_bolt_d, $fn=hole_fn);
              }
            }
          }
        }
      }
    }
    if (show_chassis_bolt) {
      let (nut_head_dist = chassis_thickness
           + lower_thickness
           - steering_servo_mount_bolt_bore_h) {
        servo_l_bracket_chasis_slot_child() {
          translate([0,
                     0,
                     chassis_thickness
                     + lower_thickness
                     + steering_servo_mount_bolt_bore_h]) {
            rotate([0, 180, 0]) {
              bolt(d=steering_servo_mount_bolt_d,
                   h=servo_l_bracket_chassis_bolt_h,
                   head_type=steering_servo_chassis_mount_bolt_head_type,
                   nut_head_distance=nut_head_dist,
                   show_nut=show_chassis_bolt_nut);
            }
          }
        }
      }
    }
    if (show_servo_bolt) {
      translate([-servo_w / 2, 0, -servo_bolt_h + servo_bolt_through_l]) {
        four_corner_children(size=dsservo_bolt_spacing, center=true) {
          if ($x_i == 1) {
            rotate([0, 0, 90]) {
              bolt(d=steering_servo_bracket_servo_bolt_d,
                   h=servo_bolt_h,
                   head_type=servo_l_bracket_bolt_head_type,
                   nut_head_distance=servo_bolt_through_l,
                   lock_nut=false,
                   show_nut=show_servo_bolt_nut);
            }
          }
        }
      }
    }
  }
}

servo_l_bracket();