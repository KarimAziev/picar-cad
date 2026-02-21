/**
 * Module: Placeholder for heat insert nut
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>


module heat_insert_nut(h=5.14,
                       d=3.8,
                       hole_d=3.0,
                       flang_d=4.0,
                       flang_h=1.8,
                       fn1=60,
                       fn2=20,
                       color=metallic_gold_2) {
  inner_h = h - flang_h * 2;
  color(color, alpha=1) {
    difference() {
      union() {
        cylinder(d=flang_d, h=flang_h, $fn=fn2);
        translate([0, 0, flang_h]) {
          cylinder(d=d, h=inner_h, $fn=fn1);
          translate([0, 0, inner_h]) {
            cylinder(d=flang_d, h=flang_h, $fn=fn2);
          }
        }
      }
      translate([0, 0, -0.5]) {
        cylinder(d=hole_d, h=h + 1, $fn=fn1);
      }
    }
  }
}

heat_insert_nut();