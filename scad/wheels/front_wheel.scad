/**
 * Module: Front wheel without tires.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
use <../util.scad>
use <wheel.scad>
use <wheel_hub.scad>

wheel_dia       = 50;
wheel_w         = 22;
wheel_thickness = 1.0;
wheel_rim_h     = 1.8;
wheel_rim_w     =  1;
wheel_rim_bend  = 0.8;

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
                   screws_dia=wheel_hub_screws,
                   screws_n=wheel_screws_n,
                   screw_boss_h=wheel_screw_boss_h,
                   screw_boss_w=wheel_screw_boss_w) {

  inner_d = wheel_inner_d(d, rim_h);
  full_h = wheel_hub_full_height(hub_h, hub_inner_rim_h);

  difference() {
    union() {
      wheel(d=d,
            w=w, thickness=thickness,
            rim_h=rim_h,
            rim_w=rim_w,
            rim_bend=rim_bend);

      translate([0, 0, -(w / 2 - full_h / 2 + rim_w)]) {
        difference() {
          wheel_hub_lower(d=hub_d,
                          outer_d=inner_d,
                          h=hub_h,
                          inner_rim_h=hub_inner_rim_h,
                          inner_rim_w=hub_inner_rim_w,
                          screws_dia=wheel_hub_screws,
                          screws_n=wheel_screws_n,
                          screw_boss_h=screw_boss_h,
                          screw_boss_w=screw_boss_w);
        }
      }
    }
  }
}

union() {
  front_wheel();
}
