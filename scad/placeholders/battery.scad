/**
 * Module: Placeholder for batteries
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../lib/functions.scad>
use <../lib/text.scad>

module battery(d=battery_dia,
               h=battery_height,
               positive_pole_dia=battery_positive_pole_dia,
               positive_pole_h=battery_positive_pole_height,
               top_border_h=0.7,
               positive_color="white",
               contact_color=metallic_silver_1,
               color="springgreen",
               fn=25) {

  base_len = h - top_border_h;
  minus_dia = d * 0.8;
  minus_h = 0.2;

  union() {
    difference() {
      color(color) {
        cylinder(d=d, h=base_len, $fn=fn);
      }
      translate([0, 0, -minus_h]) {
        cylinder(d=minus_dia, h=minus_h * 2);
      }
    }
    color(contact_color, alpha=1) {
      cylinder(d=minus_dia, h=minus_h);
    }

    translate([0, 0, base_len]) {
      color(positive_color) {
        cylinder(d=d, h=top_border_h);
      }
      translate([0, 0, top_border_h]) {
        color(contact_color, alpha=1) {
          let (r = positive_pole_dia / 2,
               r1 = r,
               r2 = r * 0.9) {
            cylinder(r1=r1, r2=r2, h=positive_pole_h, $fn=10);
          }
        }
      }
    }
  }
}

sizes = [[battery_18650_dia, battery_18650_h, "18650", "springgreen",
          metallic_silver_7],
         [battery_21700_dia, battery_21700_h, "21700", ir_1, "black"]];

let (spacing = 4) {
  for (i = [0 : len(sizes) - 1]) {
    let (prev_dias = map_idx(sizes, 0),
         d = sizes[i][0],
         h = sizes[i][1],
         txt = sizes[i][2],
         colr = sizes[i][3],
         txt_colr = sizes[i][4],
         offst = sum(prev_dias, i) + d / 2 + spacing * i) {
      translate([offst, 0, 0]) {
        battery(d=d, h=h, color=colr);
        if (!is_undef(txt)) {
          let (txt_size = 6) {
            translate([0, -d / 2, h / 2 - (txt_size * len(txt)) / 2]) {
              rotate([90, -90, 0]) {

                color(txt_colr, alpha=1) {
                  linear_extrude(height=0.2, center=false) {
                    text(txt,
                         size=txt_size,
                         halign="left",
                         valign="center");
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}