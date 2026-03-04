/**
 * Module: Bushing for the ball stud
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../steering_params.scad>

use <../../lib/transforms.scad>

module knuckle_bushing(bushing_d=knuckle_bushing_d,
                       hole_d=knuckle_bushing_hole_d,
                       hole_border_w=knuckle_bushing_hole_border_w,
                       h=knuckle_bushing_h,
                       thickness=knuckle_bushing_thickness,
                       color=matte_black) {
  fn = $preview ? 40 : 360;
  hole_ring_d = hole_d + hole_border_w * 2;
  maybe_color(color) {
    difference() {
      cylinder(d=bushing_d, h=h, $fn=fn);
      translate([0, 0, thickness]) {
        translate([0, 0, bushing_d / 2]) {
          sphere(d=bushing_d, $fn=fn);
        }
      }
      translate([0, 0, -0.5]) {
        cylinder(d=hole_d, h=h + 1, $fn=fn);
      }
      translate([0, 0, thickness]) {
        cylinder(d=hole_ring_d, h=h + 1, $fn=fn);
      }
    }
  }
}

knuckle_bushing();