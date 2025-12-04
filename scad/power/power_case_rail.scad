/**
 * Module: Rail joints for Power Case modules
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

use <../placeholders/lipo_pack.scad>;
use <../slider.scad>;
use <power_lid.scad>
use <../lib/transforms.scad>

module power_case_rail(h=power_case_rail_height,
                       w=power_case_side_wall_thickness,
                       l=power_case_length,
                       angle=power_case_rail_angle,
                       r=power_case_rail_rad) {

  difference() {
    translate([0, 0, h / 2]) {
      rotate([90, 0, 0]) {
        linear_extrude(height=l,
                       center=true) {
          dovetail_rib(w=w,
                       h=h,
                       angle=angle,
                       r=r,
                       center=true);
        }
      }
    }
    mirror_copy([0, 1, 0]) {
      translate([0,
                 l / 2 -
                 power_case_groove_edge_distance,
                 h / 2 + 0.1]) {
        cube([power_case_groove_w,
              power_case_groove_thickness,
              h + 0.1],
             center=true);
        translate([0,
                   -power_case_groove_thickness / 2
                   - power_case_rail_screw_dia / 2
                   - power_case_rail_screw_groove_distance
                   , 0]) {
          rotate([0, 90, 0]) {
            cylinder(h=w + 1, r=power_case_rail_screw_dia / 2,
                     center=true,
                     $fn=360);
          }
        }
      }
    }
  }
}

module power_case_rail_relief_cutter(h=power_case_rail_height,
                                     w=power_case_side_wall_thickness
                                     + power_case_rail_tolerance,
                                     l=power_case_length,
                                     angle=power_case_rail_angle,
                                     r=power_case_rail_rad,
                                     edge_land=steering_rail_edge_land,
                                     relief_depth=power_case_rail_relief_depth) {
  d_parallel = relief_depth / cos(angle);
  translate([0, 0, h / 2]) {
    rotate([90, 0, 90]) {
      linear_extrude(height=l,
                     center=true,
                     convexity=2) {
        intersection() {
          offset(r=d_parallel) {
            dovetail_rib(w=w, h=h, angle=angle, r=r, center=true);
          }

          offset(r=-edge_land) {
            offset(r = edge_land) {
              dovetail_rib(w=w, h=h, angle=angle, r=r, center=true);
            }
          }
        }
      }
    }
  }
}

power_case_rail();