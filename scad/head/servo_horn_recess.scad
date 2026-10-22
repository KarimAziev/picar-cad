/**
  * Module: Shared servo-horn clearance profile.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../rc_params.scad>

use <../lib/functions.scad>
use <../lib/transforms.scad>
use <../lib/trapezoids.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_servo_horn_recess_size / head_servo_horn_recess_2d
  ─────────────────────────────────────────────────────────────────────────────
  Return the [X, Y] envelope or draw the centered cross-shaped horn clearance.
  Uses the chassis pan-horn dimensions; rotate about Z to match a horn's arms.
 */
function head_servo_horn_recess_size() =
  let (d=front_chassis_head_pan_servo_screw_d,
       gap=front_chassis_head_pan_servo_screws_gap,
       step=d + gap)
  [for (len=[front_chassis_head_pan_servo_recess_y_len,
             front_chassis_head_pan_servo_recess_x_len])
    let (n=round((len / 2) / step),
         total=calc_cols_params(gap=gap, cols=n, w=d)[1])
    total * 2 + front_chassis_head_pan_servo_slot_dia + d + gap];

module head_servo_horn_recess_2d() {
  size = head_servo_horn_recess_size();
  for (i=[0, 1]) {
    rotate(i * 90) {
      mirror_copy([0, 1, 0]) {
        translate([-front_chassis_head_pan_servo_recess_thickness / 2, 0]) {
          trapezoid_rounded_top(b=front_chassis_head_pan_servo_slot_dia,
                                t=front_chassis_head_pan_servo_recess_thickness,
                                h=size[1 - i] / 2,
                                center=false,
                                r_factor=0.5);
        }
      }
    }
  }
}
