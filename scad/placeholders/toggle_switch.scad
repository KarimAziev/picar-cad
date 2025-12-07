/**
 * Module: Toggle Switch Button
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

use <../lib/shapes3d.scad>
use <../lib/transforms.scad>

module toggle_switch() {
  union() {
    translate([0, 0, toggle_switch_terminal_size[2]]) {
      color(brown_3, alpha=1) {
        rounded_cube(size=[toggle_switch_size[0],
                           toggle_switch_size[1],
                           toggle_switch_size[2]
                           - toggle_switch_metallic_head_h]);
      }
      translate([0, 0, toggle_switch_size[2]
                 - toggle_switch_metallic_head_h]) {
        color(metallic_silver_1, alpha=1) {
          rounded_cube(size=[toggle_switch_size[0],
                             toggle_switch_size[1],
                             toggle_switch_metallic_head_h]);
        }
      }
    }
    mirror_copy([1, 0, 0]) {
      color(metallic_silver_1, alpha=1) {
        translate([toggle_switch_size[0] / 2
                   - toggle_switch_terminal_size[0] / 2 - 0.1, 0, 0]) {
          rounded_cube(toggle_switch_terminal_size);
        }
      }
    }

    translate([0, 0, toggle_switch_terminal_size[2] + toggle_switch_size[2]]) {
      color(metallic_silver_1, alpha=1) {
        cylinder(h=toggle_switch_nut_out_h,
                 d=toggle_switch_out_d, $fn=6);
        translate([0, 0, toggle_switch_nut_out_h]) {
          cylinder(h=toggle_switch_nut_upper_h,
                   d=toggle_switch_nut_dia, $fn=30);
          translate([0, 0, toggle_switch_nut_out_h]) {
            rotate([0, -30, 0]) {
              cylinder(h=toggle_switch_lever_h,
                       r1=toggle_switch_lever_dia_1 / 2,
                       r2=toggle_switch_lever_dia_2 / 2,
                       $fn=30);
            }
          }
        }
      }
    }
  }
}

toggle_switch();