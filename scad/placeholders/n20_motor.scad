/**
 * Module: A dummy mockup of the N20-Motor
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/shapes3d.scad>
use <../lib/text.scad>
use <../wheels/rear_wheel.scad>
use <motor.scad>

module n20_motor_reductor() {
  cylinder(h=n20_reductor_height, r=n20_reductor_dia / 2, center=false);
}

module n20_motor_shaft() {
  notched_circle(d=n20_shaft_dia,
                 cutout_w=n20_shaft_cutout_w,
                 h=n20_shaft_height,
                 x_cutouts_n=1,
                 y_cutouts_n=0);
}

module n20_motor_can() {
  union() {
    total_end_cap_h = n20_end_cap_h + n20_end_circle_h;
    translate([0, 0, n20_can_height - n20_end_cap_h]) {
      union() {
        difference() {
          color(black_1) {
            notched_circle(h=n20_end_cap_h,
                           d=n20_can_dia,
                           cutout_w=n20_can_cutout_w,
                           x_cutouts_n=2,
                           $fn=360);
            translate([0, 0, n20_end_cap_h]) {
              linear_extrude(height=n20_end_circle_h) {
                circle(d=n20_end_cap_circle_dia, $fn=30);
              }
            }
          }

          translate([0, 0, -total_end_cap_h / 2]) {
            linear_extrude(height=total_end_cap_h + 1) {
              circle(d=n20_end_cap_circle_hole_dia, $fn=30);
            }
          }
        }

        x = 1;
        y = 1.2;

        color("silver") {
          for (pos = [[0, -n20_end_cap_circle_dia + 2, y],
                      [0, n20_end_cap_circle_dia - 2, y]]) {
            translate(pos) {
              rotate([90, 0, 0]) {
                linear_extrude(height=0.4, center=true) {
                  difference() {
                    square(size = [x, y], center = true);
                    translate([0, y * 0.4 / 2, 0]) {
                      square(size = [x * 0.8, y * 0.4], center = true);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    color("silver") {
      notched_circle(h=n20_can_height - n20_end_cap_h,
                     d=n20_can_dia,
                     cutout_w=n20_can_cutout_w,
                     x_cutouts_n=2);
    }
  }
}

module n20_motor() {
  translate([0, 0, n20_shaft_height]) {
    union() {
      color(dark_gold_1) {
        n20_motor_reductor();
      }
      translate([0, 0, -n20_reductor_height]) {
        color(metallic_silver_3) {
          n20_motor_shaft();
        }
      }
      translate([0, 0, n20_reductor_height]) {
        n20_motor_can();
      }
    }
  }
}

translate([0, -40, 0]) {
  translate([-10, 0, 0]) {
    rotate([180, 0, 0]) {
      text_from_plist("n20", ["color", "gold"]);
    }
  }
  rotate([0, 90, 0]) {
    n20_motor();
  }
}

translate([40, 0, 0]) {
  translate([-40, 0, 0]) {
    rotate([180, 0, 0]) {
      text_from_plist("Standard", ["color", "gold"]);
    }
  }

  motor();
}