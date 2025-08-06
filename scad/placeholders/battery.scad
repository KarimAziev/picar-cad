/**
 * Module: Mockup for 18650 batteries
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

module battery(d=battery_dia,
               h=battery_height,
               positive_pole_dia=battery_positive_pole_dia,
               positive_pole_h=battery_positive_pole_height,
               top_border_h=1,
               fn=25) {

  base_len = battery_height -
    ((top_border_h * 2) - battery_positive_pole_height);
  union() {
    color("springgreen") {
      translate([0, 0, 1]) {

        linear_extrude(height=base_len, center=false) {
          circle(r=d / 2, $fn=fn);
        }
      }
    }

    color("white", alpha=1) {
      translate([0, 0, battery_height - top_border_h]) {
        linear_extrude(height=1, center=false) {
          circle(r=d / 2, $fn=fn);
        }
      }
      linear_extrude(height=top_border_h, center=false) {
        circle(r=d / 2, $fn=fn);
      }
      translate([0, 0, battery_height]) {
        linear_extrude(height=positive_pole_h, center=false) {
          circle(r=positive_pole_dia / 2, $fn=fn);
        }
      }
    }
  }
}

battery();