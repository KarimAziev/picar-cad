/**
  * Module: Center link (tie-bar) for dual-bellcrank steering.
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

module center_link(length=steering_center_link_len,
                   width=steering_center_link_w,
                   thickness=steering_center_link_thickness,
                   hole_d=steering_center_link_hole_d,
                   boss_od = steering_center_link_boss_od,
                   boss_h=steering_center_link_boss_h,
                   color=cobalt_blue_light_2,
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
        cuboid([bar_len + notch_d * 2, width, thickness]);
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

translate([0, -steering_center_link_boss_od / 2, 0]) {
  center_link();
}