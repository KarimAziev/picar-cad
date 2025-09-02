/**
 * Module: Front wheel without tires.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <../placeholders/bearing.scad>
use <wheel.scad>
use <wheel_hub.scad>
use <tire.scad>

module front_wheel(w=wheel_w,
                   d=wheel_dia,
                   thickness=wheel_thickness,
                   rim_h=wheel_rim_h,
                   rim_w=wheel_rim_w,
                   rim_bend=wheel_rim_bend,
                   hub_d=wheel_hub_d,
                   hub_h=wheel_hub_h,
                   hub_inner_rim_h=wheel_hub_inner_rim_h,
                   hub_inner_rim_w=wheel_hub_inner_rim_w,
                   screws_dia=wheel_hub_screw_dia,
                   screws_n=wheel_screws_n,
                   screw_boss_h=wheel_screw_boss_h,
                   screw_boss_w=wheel_screw_boss_w,
                   show_bearing=false,
                   wheel_color="white",
                   hub_lower_color="white") {

  inner_d = wheel_inner_d(d, rim_h);
  full_h = wheel_hub_full_height(hub_h, hub_inner_rim_h);

  difference() {
    union() {
      color(wheel_color) {
        wheel(d=d,
              w=w, thickness=thickness,
              rim_h=rim_h,
              rim_w=rim_w,
              rim_bend=rim_bend);
      }

      translate([0, 0, -(w / 2 - full_h / 2 + rim_w)]) {
        color(hub_lower_color) {
          wheel_hub_lower(d=hub_d,
                          outer_d=inner_d,
                          h=hub_h,
                          inner_rim_h=hub_inner_rim_h,
                          inner_rim_w=hub_inner_rim_w,
                          screws_dia=screws_dia,
                          screws_n=screws_n,
                          screw_boss_h=screw_boss_h,
                          screw_boss_w=screw_boss_w);
        }
      }
      if (show_bearing) {
        translate([0, 0, -(w / 2 - full_h / 2 + rim_w) - 7]) {
          bearing(rings=[[2, metalic_yellow_silver],
                         [1, onyx]]);
        }
      }
    }
  }
}

module front_wheel_animated() {
  rotate([0, 0, -360 * $t]) {
    front_wheel(show_bearing=true);
    color(black_1) {
      tire();
    }
  }
}

union() {
  // front_wheel_animated();
  front_wheel();
  // translate([0, 0, 20]) {
  //   rotate([180, 0, 0]) {
  //     wheel_hub_upper();
  //   }
  // }
}
