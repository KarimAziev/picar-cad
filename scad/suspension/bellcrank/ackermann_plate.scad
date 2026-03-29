/**
  * Module: Ackermann Plate (tie-bar) for dual-bellcrank steering.
  *
  * Creates a flat “dogbone” plate with two boss rings and through-holes.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../steering_params.scad>

use <../../lib/functions.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>

module ackermann_plate(length=ackermann_plate_len,
                       width=ackermann_plate_w,
                       thickness=ackermann_plate_thickness,
                       hole_d=ackermann_plate_hole_d,
                       boss_od = ackermann_plate_boss_od,
                       boss_h=ackermann_plate_boss_h,
                       color=cobalt_blue_metallic,
                       center_z_bar=false) {
  assert(boss_od >= width, "Boss outer diameter must be at least plate width");
  assert(boss_od > hole_d,
         "Boss outer diameter must be greater than hole diameter");
  assert(thickness > 0 && length > (boss_od * 2) && width > 0 && hole_d > 0 && boss_h >= thickness,
         "Invalid parameters: ensure positive dimensions, length > boss_od, and boss_h >= thickness");

  bar_len = length - boss_od * 2;
  max_h = max(boss_h, thickness);
  notch_d = notch_depth(boss_od, width);

  maybe_color(color) {
    translate([0, 0, center_z_bar ? max_h / 2 : 0]) {
      if (center_z_bar) {
        cube([bar_len + notch_d * 2, width, thickness], center=true);
      } else {
        cube_3d([bar_len + notch_d * 2, width, thickness], center=true);
      }

      mirror_copy([1, 0, 0]) {
        translate([bar_len / 2 + boss_od / 2,
                   0,
                   center_z_bar ? -boss_h / 2 : 0]) {
          ring(outer_d=boss_od, d=hole_d, h=boss_h, fn=$preview ? 30 : 360);
        }
      }
    }
  }
}

translate([0, -ackermann_plate_boss_od / 2, 0]) {
  ackermann_plate();
}