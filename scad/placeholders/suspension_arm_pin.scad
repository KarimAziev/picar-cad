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
                          pad_l,
                          pad_w,
                          groove_w,
                          groove_offset) {
  fn = is_undef(fn) ? 30 : fn;
  pad_l = with_default(pad_l, 0);
  pad_w = with_default(pad_w, 0);

  is_all = groove_side == "all";
  is_bottom = groove_side == "bottom";
  groove_d = with_default(groove_d, d - 0.4);
  groove_w = with_default(groove_w, 0.4);

  module _pad() {
    color(color, alpha=1) {
      intersection() {
        cylinder(d=d, h=pad_l, $fn=fn);
        cube_3d([d, pad_w, pad_l]);
      }
    }
  }

  module _with_pad() {
    if (pad_l > 0 && pad_w > 0) {
      union() {
        y = is_bottom ? -0.1 : 0;
        z = is_bottom ? l - pad_l : -0.1;
        difference() {
          children();
          translate([0, y, z]) {
            cube_3d([d + 0.1, d + 0.1, pad_l + 0.1]);
          }
        }
        translate([0, is_bottom ? 0 : y, is_bottom ? z : 0]) {
          _pad();
        }
      }
    } else {
      children();
    }
  }

  module _main() {
    color(color, alpha=1) {
      cylinder(d=d, h=l, $fn=fn);
    }
  }
  if (is_undef(groove_offset) || groove_offset == 0) {
    _with_pad() {
      _main();
    }
  } else {
    z_top = l - groove_offset - groove_w;
    z = (is_all || is_bottom) ? groove_offset : z_top;
    union() {
      _with_pad() {
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
          translate([0,
                     0,
                     groove_offset + (groove_w - e_clip_thickness) / 2]) {
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
                   l=39.5,
                   pad_l=5.5,
                   pad_w=2.5,
                   color=undef,
                   groove_side="top",
                   show_e_clip=false);