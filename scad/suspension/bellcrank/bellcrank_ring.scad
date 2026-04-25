/**
  * Module: Bellcrank ring.
  *
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/threading/threads.scad>

module bellcrank_ring(color=cobalt_blue_metallic,
                      parent_od=bellcrank_idler_od,
                      h,
                      thickness=bellcrank_arm_thickness,
                      border_w=bellcrank_lever_border_w) {

  h = is_undef(h) ? thickness : h;

  fn=$preview ? 20 : 100;

  render() {
    difference() {
      color(color, alpha=1) {
        cylinder(d=parent_od + border_w * 2, h=h, $fn=fn);
      }
      translate([0, 0, -0.1]) {
        screw_hole_thread(d=parent_od, h=h + 0.2);
      }
    }
  }
}

bellcrank_ring();
