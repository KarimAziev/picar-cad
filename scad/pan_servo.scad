/**
 * Module: A slot for pan servo
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <parameters.scad>
use <util.scad>

module pan_servo_screws_2d(servo_screw_d = m2_hole_dia) {
  step = servo_screw_d + 0.5;
  servo_screws_x = number_sequence(from = -16, to = -5, step = step);
  translate([servo_screw_d / 2, 0, 0]) {
    dotted_screws_line_y(servo_screws_x, y=0, d=m2_hole_dia);
  }
}

module pan_servo_cutout_2d() {
  translate([0, steering_servo_chassis_offset + pan_servo_wheels_y_offset, 0]) {
    circle(r=pan_servo_slot_dia / 2, $fn=360);
    pan_servo_screws_2d();
    mirror([1, 0, 0]) {
      pan_servo_screws_2d();
    }

    // translate([0, 20, 0]) {
    //   square([20, 5], center = true);
    // }
    // translate([0, 10, 0]) {
    //   square([30, 5], center = true);
    // }
    translate([0, -30, 0]) {
      square([36, 5], center = true);
    }
  }
}

color("white") {
  pan_servo_cutout_2d();
}
