/**
 * Module: SMT (Surface Mount Technology) Can Style Electrolytic Capacitor
 *
 * The SMT Can Style Electrolytic Capacitor is designed to be mounted
 * directly on the surface of a printed circuit board (PCB), eliminating the
 * need for additional space.
 *
 * *Marking text*
 * - Capacitance
 * - Voltage marking + Series
 * | Code | Voltage Direct Current |
 * |------|------------------------|
 * | j    | 6.3Vdc                 |
 * | A    | 10Vdc                  |
 * | C    | 16Vdc                  |
 * | E    | 25Vdc                  |
 * | V    | 35Vdc                  |
 * | H    | 50Vdc                  |
 * | J    | 63Vdc                  |
 * | K    | 80Vdc                  |
 * | 2A   | 100Vdc                 |
 * - Lot Number
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/plist.scad>
use <../lib/trapezoids.scad>
use <../lib/text.scad>
use <../lib/placement.scad>
use <../lib/functions.scad>

module smt_can_capacitor(d,
                         h,
                         base_h,
                         text_rows = [],
                         marking_color=matte_black,
                         base_color=matte_black,
                         can_color=metallic_silver_1) {

  let (chamfer=d / 6,
       cube_y=d - chamfer * 2,
       cyl_cutout_w = d * 0.9,
       cyl_h = h - base_h,
       text_len = d - cyl_cutout_w) {
    union() {
      color(base_color, alpha=1) {
        linear_extrude(height=base_h, center=false) {
          chamfered_square(size=d, chamfer=chamfer);
        }
        translate([-d / 2, -cube_y / 2 + chamfer, 0]) {
          cube([d, cube_y, base_h]);
        }
      }

      translate([0, 0, base_h]) {
        color(can_color, alpha=1) {
          cylinder(h=cyl_h - 0.01, d=d, $fn=80);
        }
        color(marking_color) {
          translate([0, 0, cyl_h - 1]) {
            difference() {
              cylinder(h=1, d=d - 0.1, $fn=80);
              notched_circle(h=cyl_h + 0.1,
                             d=d + 0.1,
                             x_cutouts_n=0,
                             y_cutouts_n=1,
                             cutout_w=cyl_cutout_w);
            }
          }
        }
        if (!is_undef(text_rows) && len(text_rows) > 0) {
          let (rows = reverse([for (v = text_rows) is_num(v) ? str(v) : v]),
               text_lengts = [for (v = rows) len(v)],
               max_len = max(text_lengts),
               gap=0.2,
               text_size=(cyl_cutout_w * 0.5) / len(rows),
               tm=textmetrics(rows[0],
                              size=text_size,
                              valign="center",
                              halign="center"),
               rows_metrics = [for (v = rows) textmetrics(v,
                                                          size=text_size,
                                                          valign="center",
                                                          halign="center").size],
               max_row_size = max([for (v = rows_metrics) v[1]])) {
            rotate([0, 0, -90]) {
              translate([0, -max_row_size, h - base_h]) {

                color(marking_color, alpha=1) {
                  rows_children(rows=len(rows),
                                w=max_row_size,
                                reverse=false,
                                gap=gap) {
                    linear_extrude(height=0.05, center=false) {
                      text(rows[$i],
                           size=max_row_size,
                           valign="top",
                           halign="center");
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
}

module smt_can_capacitor_from_plist(plist) {
  rotation = plist_get("rotation", plist);
  module capacitor() {
    smt_can_capacitor(h=plist_get("h", plist),
                      d=plist_get("d", plist),
                      base_h=plist_get("base_h", plist),
                      text_rows=plist_get("text_rows", plist, []),
                      marking_color=plist_get("marking_color", plist, matte_black),
                      can_color=plist_get("can_color", plist, metallic_silver_1));
  }
  if (is_num(rotation)) {
    rotate([0, 0, rotation]) {
      capacitor();
    }
  } else {
    capacitor();
  }
}

smt_can_capacitor_from_plist(["d", 7,
                              "base_h", 2.58,
                              "h", 6.85,
                              "marking_color", "red",
                              "can_color", metallic_silver_1,
                              "text_rows", ["47", "HFT", "S92"],
                              "rotation", 0]);
