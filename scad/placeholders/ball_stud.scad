/**
 * Module: Placeholder for ball stud
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>

use <../lib/functions.scad>
use <bolt.scad>

module ball_stud(d,
                 unthreaded_len=0,
                 ball_d,
                 ball_hole_d=0,
                 h,
                 ball_fn=30,
                 ball_hole_depth,
                 color=metallic_silver_1,
                 fn=35) {
  unthreaded_len = with_default(unthreaded_len, 0);
  ball_hole_d = with_default(ball_hole_d, 0);
  ball_hole_depth = with_default(ball_hole_depth, ball_d * 0.3);
  notch_dep = notch_depth(ball_d, d);

  color(color, alpha=1) {
    union() {
      translate([0, 0, ball_d / 2 + h - notch_dep]) {
        difference() {
          sphere(r=ball_d / 2, $fn=ball_fn);
          translate([0, 0, ball_d / 2 + ball_hole_depth / 2 - ball_hole_depth]) {
            cylinder(d=ball_hole_d,
                     h=ball_hole_depth + 0.2,
                     center=true,
                     $fn=6);
          }
        }
      }
      bolt(d=d, h=h, head_type="none");

      if (unthreaded_len > 0) {
        translate([0, 0, h - unthreaded_len]) {
          cylinder(d=d, h=unthreaded_len, $fn=fn);
        }
      }
    }
  }
}

ball_stud(d=5, ball_d=8.6, ball_hole_d=3.3, h=16.0, unthreaded_len=5);