/**
 * Module: Nut placeholder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/transforms.scad>

module nut(d,
           outer_d,
           h,
           nut_color = metallic_silver_2,
           txt,
           text_color=red_1,
           show_text=true,
           fn) {
  union() {
    difference() {
      color(nut_color, alpha=1) {
        cylinder(d=outer_d, h, $fn=with_default(fn, 6));
      }
      translate([0, 0, -0.1]) {
        cylinder(d=d, h + 0.2, $fn=8);
      }
    }
    if (show_text) {
      let (txt = with_default(txt, str("M", d)),
           spacing = 0.9,
           size = h / 2,
           tm = textmetrics(text=txt,
                            spacing=spacing,
                            halign="center",
                            size=size)) {

        #color(text_color, alpha=1) {
          translate([0,
                     outer_d / 2 -
                     (outer_d * 0.06) - 0.1,
                     size / 2]) {
            rotate([90, 0, 180]) {
              linear_extrude(height=0.1, center=false) {
                text(text=txt,
                     spacing=spacing,
                     halign="center",
                     size=size);
              }
            }
          }
        }
      }
    }
  }
}

module lock_nut(d,
                outer_d,
                h,
                flanged_h,
                nut_color = metallic_silver_2,
                show_text=true,
                txt,
                text_color=red_1,
                reverse = false,
                flanged_fn=12,
                flanged_dia,
                nylon_cap_dia,
                nylon_cap_fn,
                outer_fn,
                nylon_cap_h) {
  base_h = h - flanged_h - with_default(nylon_cap_h, 0);
  flanged_dia = with_default(flanged_dia, outer_d * 0.8);
  has_cap = !is_undef(nylon_cap_h) && !is_undef(nylon_cap_dia) && nylon_cap_dia > 0 && nylon_cap_h > 0;
  module base_nut() {
    nut(d=d,
        outer_d=outer_d,
        h=base_h,
        text_color=text_color,
        txt=txt,
        nut_color=nut_color,
        show_text=show_text,
        fn=outer_fn);
  }

  module _cap() {
    inner_step = 0.7;
    nylon_h = has_cap ? nylon_cap_h : 0.4;
    if (has_cap) {
      color(nut_color, alpha=1) {
        difference() {
          cylinder(d=nylon_cap_dia,
                   h=nylon_cap_h,
                   $fn=with_default(nylon_cap_fn, 40));
          translate([0, 0, -0.1]) {
            cylinder(d=d, h + 0.2, $fn=10);
          }
        }
      }
    }
    translate([0, 0, -0.1]) {
      color(cobalt_blue_metallic, alpha=1) {
        difference() {
          cylinder(d=d + inner_step, h=nylon_h, $fn=12);
          translate([0, 0, -0.1]) {
            cylinder(d=d - 0.1, nylon_h + 0.2, $fn=10);
          }
        }
      }
    }
  }
  module _flanged() {
    union() {
      color(nut_color, alpha=1) {
        difference() {
          cylinder(d=flanged_dia,
                   h=flanged_h,
                   $fn=with_default(flanged_fn, 12));
          translate([0, 0, -0.1]) {
            cylinder(d=d, h + 0.2, $fn=10);
          }
        }
      }
    }
  }

  module _lock_nut() {
    union() {
      base_nut();
      maybe_translate([0, 0, base_h]) {
        _flanged();
        translate([0, 0, flanged_h]) {
          _cap();
        }
      }
    }
  }

  if (reverse) {
    translate([0, 0, h]) {
      rotate([180, 0, 0]) {
        _lock_nut();
      }
    }
  } else {
    _lock_nut();
  }
}

lock_nut(d=6.0,
         h=m6_lock_nut_h,
         outer_d=m6_lock_nut_dia,
         flanged_h=4.94,
         flanged_fn=6,
         outer_fn=60,
         nylon_cap_h=1.6,
         nylon_cap_dia=9.2,
         reverse=true);