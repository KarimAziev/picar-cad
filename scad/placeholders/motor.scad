/**
 * Module: A dummy mockup of the cheap and popular yellow motor.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

use <../wheels/rear_wheel.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>

module motor_can(h=standard_motor_can_len,
                 r=standard_motor_can_rad,
                 cutted_w=4) {
  translate([0, 0, -standard_motor_body_neck_len * 0.5]) {
    union() {
      union() {
        full_len = h + standard_motor_body_neck_len;
        color(standard_motor_can_color) {
          cylinder_cutted(h=full_len, r=r, cutted_w=cutted_w);
        }

        translate([0, 0, full_len * 0.5]) {
          color(standard_motor_can_color) {
            cylinder(h = standard_motor_endcap_len, r = 1.6, center = false);
          }
          color(standard_motor_endcap_color) {
            cylinder_cutted(h=standard_motor_endcap_len,
                            r=standard_endcap_rad, cutted_w=cutted_w);
            head_h = 6;
            translate([0, 0, head_h * 0.5]) {
              cylinder_cutted(h=head_h, r=5, cutted_w=2);
            }
          }
        }
      }
    }
  }
}

module motor_gearbox() {
  color(standard_motor_gearbox_color) {
    linear_extrude(height = standard_motor_gearbox_side_height, center=true) {
      difference() {
        rounded_rect_two([standard_motor_gearbox_height,
                          standard_motor_gearbox_body_main_len],
                         r=3,
                         center=true);
        offst_a = 7.8;
        offst_b = 1.6;
        offst_c = 3.0;
        for (x = [[-offst_a, offst_b, -offst_c],
                  [offst_a, -offst_b, -offst_c]]) {
          translate([x[0], -standard_motor_gearbox_body_main_len * 0.5
                     + 6, 0]) {
            circle(r = standard_motor_bracket_motor_bolt_hole / 2, $fn=60);
            translate([x[1], x[2], 0]) {
              circle(r = m25_hole_dia / 2, $fn=60);
            }
          }
        }
      }
    }
  }
}

module motor(show_wheel=false) {
  difference() {
    union() {
      rotate([0, 0, 90]) {
        motor_gearbox();
      }

      translate([standard_motor_gearbox_body_main_len * 0.5
                 + standard_motor_body_neck_len * 0.5,
                 0,
                 0]) {
        rotate([0, 90, 0]) {
          union() {
            color(standard_motor_gearbox_color) {
              difference() {
                cylinder_cutted(h=standard_motor_body_neck_len,
                                r=standard_gearbox_neck_rad,
                                cutted_w=5);
                cube([standard_motor_gearbox_side_height, 5, 2], center=true);
              }
            }

            translate([0, 0, standard_motor_can_len]) {
              motor_can();
            }
          }
        }
      }

      translate([-standard_motor_gearbox_body_main_len * 0.5 +
                 standard_motor_shaft_offset, 0, 0]) {
        rotate([0, 0, 90]) {
          color(standard_motor_shaft_color) {
            difference() {
              rotate([0, 0, 360 * $t]) {
                cylinder_cutted(h=standard_motor_shaft_len,
                                r=standard_motor_shaft_rad,
                                cutted_w=2);
              }

              cylinder(h=standard_motor_shaft_len + 1,
                       r=0.7,
                       center=true,
                       $fn=60);
            }
          }
        }
        translate([10, 0, 10]) {
          color(standard_motor_gearbox_color) {
            cylinder(h=2, r=2, $fn=50, center=true);
          }
        }

        translate([0, 0, standard_motor_gearbox_height / 2 + wheel_w]) {
          if (show_wheel) {
            rotate([0, 180, 0]) {
              rear_wheel_animated();
            }
          }
        }
      }

      x = 5;
      y = 5;
      z = 3;

      translate([-standard_motor_gearbox_body_main_len * 0.5 - x / 2, 0, 0]) {
        difference() {
          color(standard_motor_gearbox_color) {
            cube([x, y, z], center=true);
          }

          cylinder(h = z + 1, r = 1.5, center = true, $fn=60);
        }
      }
    }
  }
}
