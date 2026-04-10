/**
  * Module: Placeholder for the suspension arm pin
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../colors.scad>

use <../lib/functions.scad>
use <../lib/shapes3d.scad>
use <e_clip.scad>

module suspension_arm_pin(d,
                          l,
                          fn,
                          color=metallic_silver_1,
                          show_e_clip=false,
                          e_clip_thickness=0.4,
                          groove_d,
                          groove_side="all", // "top" | "bottom" | "all"
                          groove_w,
                          groove_offset) {
  fn = is_undef(fn) ? 30 : fn;

  module _main() {
    cylinder(d=d, h=l, $fn=fn);
  }
  if (is_undef(groove_offset)) {
    color(color, alpha=1) {
      _main();
    }
  } else {
    is_all = groove_side == "all";
    is_bottom = groove_side == "bottom";
    groove_d = with_default(groove_d, d - 0.4);
    groove_w = with_default(groove_w, 0.4);
    z_top = l - groove_offset - groove_w;
    z = (is_all || is_bottom) ? groove_offset : z_top;
    union() {
      color(color, alpha=1) {
        difference() {
          _main();
          translate([0, 0, z]) {
            ring(outer_d=d + 1, d=groove_d, h=groove_w);
          }
          if (is_all) {
            translate([0, 0, z_top]) {
              ring(outer_d=d + 1, d=groove_d, h=groove_w);
            }
          }
        }
      }
      if (show_e_clip) {
        if (is_all || is_bottom) {
          translate([0, 0, groove_offset + (groove_w - e_clip_thickness) / 2]) {
            e_clip(d, thickness=e_clip_thickness);
          }
        }
        if (is_all || !is_bottom) {
          translate([0,
                     0,
                     l - groove_offset - (groove_w + e_clip_thickness) / 2]) {
            e_clip(d, thickness=e_clip_thickness);
          }
        }
      }
    }
  }
}

suspension_arm_pin(d=3,
                   l=44.7,
                   groove_offset=1,
                   groove_side="top",
                   show_e_clip=true);