/**
 * Module: Demonstrates both front and rear wheels.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
use <../util.scad>
use <wheel.scad>
use <front_wheel.scad>
use <rear_wheel.scad>

module front_and_rear_wheels(w=wheel_w,
                             d=wheel_dia,
                             thickness=wheel_thickness,
                             rim_h=wheel_rim_h,
                             rim_w=wheel_rim_w,
                             rim_bend=wheel_rim_bend,
                             shaft_offset=wheel_rear_shaft_protrusion_height,
                             spokes=wheel_rear_spokes_count,
                             spoke_w=wheel_rear_wheel_spoke_w,
                             shaft_d=wheel_rear_shaft_outer_dia,
                             hub_d=wheel_hub_d,
                             hub_h=wheel_hub_h,
                             hub_inner_rim_h=wheel_hub_inner_rim_h,
                             hub_inner_rim_w=wheel_hub_inner_rim_w,
                             screws_dia=wheel_hub_screws,
                             screws_n=wheel_screws_n,
                             screw_boss_h=wheel_screw_boss_h,
                             screw_boss_w=wheel_screw_boss_w,
                             y_distance=5,
                             x_distance=5,
                             front_n=2,
                             rear_n=2) {
  union() {
    if (front_n > 0) {
      for (i = [0:front_n - 1]) {
        y_offst = i == 0 ? 0 : (d + y_distance) * i;
        translate([d * 0.5 + x_distance, y_offst, 0]) {
          front_wheel(w=w,
                      d=d,
                      thickness=thickness,
                      rim_h=rim_h,
                      rim_w=rim_w,
                      rim_bend=rim_bend,
                      hub_d=hub_d,
                      hub_h=hub_h,
                      hub_inner_rim_h=hub_inner_rim_h,
                      hub_inner_rim_w=hub_inner_rim_w,
                      screws_dia=screws_dia,
                      screws_n=screws_n,
                      screw_boss_h=screw_boss_h,
                      screw_boss_w=screw_boss_w);
        }
      }
    }

    if (rear_n > 0) {
      for (i = [0:rear_n - 1]) {
        y_offst = i == 0 ? 0 : (d + y_distance) * i;
        translate([-d * 0.5 - x_distance, y_offst, 0]) {
          rear_wheel(w=w,
                     d=d,
                     thickness = thickness,
                     rim_h = rim_h,
                     rim_w = rim_w,
                     rim_bend = rim_bend,
                     shaft_offset=shaft_offset,
                     spokes=spokes,
                     spoke_w=spoke_w,
                     shaft_d=shaft_d);
        }
      }
    }
  }
}

front_and_rear_wheels();