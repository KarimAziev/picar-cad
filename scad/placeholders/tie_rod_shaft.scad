/**
 * Module: Tie rod shaft
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>
include <../steering_params.scad>

use <../lib/functions.scad>
use <bolt.scad>

module tie_rod_shaft(body_len,
                     body_d,
                     body_end_len,
                     thread_len,
                     thread_d,
                     fn=6,
                     color=metallic_silver_1,
                     show_nuts=true) {

  color(color, alpha=1) {
    translate([0, 0, thread_len]) {
      if (!is_undef(body_end_len) && body_end_len > 0) {
        cylinder(d1=thread_d, d2=body_d, h=body_end_len, $fn=fn);
        translate([0, 0, body_end_len]) {
          cylinder(d=body_d, h=body_len - body_end_len * 2, $fn=fn);
          translate([0, 0, body_len - body_end_len * 2]) {
            cylinder(d1=body_d, d2=thread_d, h=body_end_len, $fn=fn);
          }
        }
      } else {
        cylinder(d=body_d, h=body_len, $fn=fn);
      }

      translate([0, 0, body_len]) {
        bolt(d=thread_d,
             h=thread_len,
             head_type="none",
             show_nut=show_nuts,
             nut_head_distance=thread_len);
      }
    }
    bolt(d=thread_d,
         h=thread_len,
         head_type="none",
         show_nut=show_nuts,
         nut_head_distance=0);
  }
}

tie_rod_shaft(body_len=steering_servo_tie_rod_body_len,
              body_d=steering_servo_tie_rod_body_d,
              body_end_len=steering_servo_tie_rod_body_end_len,
              thread_len=steering_servo_tie_rod_thread_len,
              thread_d=steering_servo_tie_rod_thread_d,
              fn=steering_servo_tie_rod_fn,
              color=steering_servo_tie_rod_color);
