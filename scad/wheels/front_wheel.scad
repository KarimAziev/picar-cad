/**
 * Module: Front wheel without tires.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>

use <../lib/shapes3d.scad>
use <../placeholders/ball_bearing.scad>
use <../placeholders/bearing.scad>
use <../placeholders/bolt.scad>
use <tire.scad>
use <wheel.scad>
use <wheel_hub_new.scad>

assembled_hub_h = wheel_hub_full_h();

knuckle_w       = wheel_shoulder_bolt_unthreaded_l - (assembled_hub_h * 2);

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
                   bolts_dia=wheel_hub_bolt_dia,
                   bolts_n=wheel_bolts_n,
                   bolt_boss_h=wheel_bolt_boss_h,
                   bolt_boss_w=wheel_bolt_boss_w,
                   show_tire=false,
                   show_upper_hub=false,
                   show_extra_lower_hub=false,
                   show_extra_upper_hub=false,
                   show_bearing=false,
                   show_extra_bearing=false,
                   bearing_n=2,
                   wheel_color="white",
                   hub_color="white") {

  inner_d = wheel_inner_d(d, rim_h);
  hub_h = wheel_hub_full_h();

  union() {
    translate([0, 0, -w / 2 - rim_w]) {
      translate([0, 0, w / 2 + rim_w]) {
        color(wheel_color) {
          wheel(d=d,
                w=w,
                thickness=thickness,
                rim_h=rim_h,
                rim_w=rim_w,
                rim_bend=rim_bend);
        }
      }

      for (i = [0 : bearing_n - 1]) {
        translate([0, 0, (hub_h * 2) * i]) {
          let (lower_d = i == 0 ? inner_d : wheel_hub_outer_d) {

            wheel_hub_assembly(show_lower_hub=i == 0 || show_extra_lower_hub,
                               lower_d=lower_d,
                               show_bearing=i == 0 ? show_bearing : show_extra_bearing,
                               show_upper_hub=i == 0
                               ? show_upper_hub
                               : show_extra_upper_hub,
                               color=hub_color);
          }
        }
      }
    }

    if (show_tire) {
      color(black_1) {
        tire();
      }
    }
  }
}

module front_wheel_animated(show_bearing=true) {
  rotate([0, 0, -360 * $t]) {
    front_wheel(show_bearing=show_bearing);
    color(black_1) {
      tire();
    }
  }
}

module assembled_wheel(show_bearing=true, show_upper_hub=true, show_tire=false) {
  front_wheel(show_bearing=show_bearing,
              show_upper_hub=show_upper_hub);
  if (show_tire) {
    color(black_1) {
      tire();
    }
  }
}

union() {
  front_wheel(show_upper_hub=false,
              show_extra_lower_hub=false,
              show_tire=true,
              show_extra_upper_hub=false,
              show_bearing=false);
}

// translate([0, 0, assembled_hub_h]) {

//   wheel_hub_assembly();
// }