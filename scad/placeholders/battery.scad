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
               fn=25) {
  union() {
    color("springgreen") {
      translate([0, 0, 1]) {

        linear_extrude(height=battery_height - 2, center=false) {
          circle(r=d / 2, $fn=fn);
        }
      }
    }

    color("white", alpha=1) {
      translate([0, 0, battery_height - 1]) {
        linear_extrude(height=1, center=false) {
          circle(r=d / 2, $fn=fn);
        }
      }
      translate([0, 0, 0]) {
        linear_extrude(height=1, center=false) {
          circle(r=d / 2, $fn=fn);
        }
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