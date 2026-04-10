/**
  * Module: Bellcrank insert post
  *
  * The bellcrank post is a cylindrical shaft inserted into the bellcrank
  * cylinder. Two bearings are placed on the post-one at the top and one at the
  * bottom. The post has two bolt holes.
  *
  * At the bottom, it has a wider, thin cylinder (shoulder) to prevent the
  * bottom bearing from sliding out.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/threading/thread_funcs.scad>
use <../../lib/threading/threads.scad>
use <../../lib/transforms.scad>
use <../../placeholders/bolt.scad>

// The central cylindrical hub/housing that the bellcrank rotates about
module bellcrank_post(color=metallic_silver_1,
                      h=bellcrank_post_h,
                      od=bellcrank_post_od,
                      shoulder_d=bellcrank_post_flang_d,
                      shoulder_h=bellcrank_post_flang_h,
                      bolt_d=bellcrank_post_bolt_d,
                      lower_hole_depth=bellcrank_post_lower_hole_depth,
                      upper_hole_depth=bellcrank_post_upper_hole_depth,
                      use_screw_thread=bellcrank_post_use_threading) {

  fn = $preview ? 16 : 360;

  difference() {
    color(color) {
      cylinder(d=od, h=h, $fn=fn);
      cylinder(d=shoulder_d, h=shoulder_h, $fn=6);
    }
    if (use_screw_thread) {
      pitch = thread_pitch(bolt_d);
      if (lower_hole_depth > 0) {
        translate([0, 0, -0.01]) {
          screw_thread(od=bolt_d, height=lower_hole_depth + 0.01, pitch=pitch);
        }
      }

      if (upper_hole_depth > 0) {
        translate([0, 0, h - upper_hole_depth + 0.01]) {
          screw_thread(od=bolt_d, height=upper_hole_depth + 0.01, pitch=pitch);
        }
      }
    } else {
      translate([0, 0, -0.01]) {
        cylinder(d=bolt_d, h=lower_hole_depth + 0.01, $fn=fn);
      }

      translate([0, 0, h - upper_hole_depth + 0.01]) {
        cylinder(d=bolt_d, h=upper_hole_depth + 0.01, $fn=fn);
      }
    }
  }
}

bellcrank_post();