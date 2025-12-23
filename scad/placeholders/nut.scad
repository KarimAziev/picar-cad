/**
 * Module: Nut placeholder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>
use <../lib/functions.scad>

module nut(d,
           outer_d,
           h,
           nut_color = metallic_silver_2,
           txt,
           text_color=red_1,
           show_text=true) {
  union() {
    difference() {
      color(nut_color, alpha=1) {
        cylinder(d=outer_d, h, $fn=6);
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

        color(text_color, alpha=1) {
          translate([0, outer_d / 2 -
                     (outer_d * 0.06) - 0.1, size / 2]) {
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
                reverse = false) {
  base_h = h - flanged_h;
  flanged_dia = outer_d * 0.8;
  module base_nut() {
    nut(d=d,
        outer_d=outer_d,
        h=base_h,
        text_color=text_color,
        txt=txt,
        nut_color=nut_color,
        show_text=show_text);
  }
  module flanged() {
    inner_step = 0.7;
    union() {
      color(nut_color, alpha=1) {
        difference() {
          cylinder(d=flanged_dia, h=flanged_h, $fn=12);
          translate([0, 0, -0.1]) {
            cylinder(d=d, h + 0.2, $fn=10);
          }
        }
      }
      color(cobalt_blue_metallic, alpha=1) {
        difference() {
          cylinder(d=d + inner_step, h=flanged_h + 0.1, $fn=12);
          translate([0, 0, -0.1]) {
            cylinder(d=d, h + 0.2, $fn=10);
          }
        }
      }
    }
  }
  union() {
    translate([0, 0, reverse ? flanged_h : 0]) {
      base_nut();
    }
    translate([0, 0, reverse ? 0 : base_h]) {
      flanged();
    }
  }
}

lock_nut(d=3, h=m3_lock_nut_h, outer_d=m3_lock_nut_dia, flanged_h=m3_lock_nut_h - m3_nut_h,
         reverse=true);