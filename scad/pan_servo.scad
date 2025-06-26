// This module defines a slot for pan servo

include <parameters.scad>
use <util.scad>

module pan_servo_screws_2d(servo_screw_d = m2_hole_dia) {
  step = servo_screw_d + 0.5;
  servo_screws_x = number_sequence(from = -18, to = 0, step = step);
  translate([1.2, 0, 0]) {
    dotted_screws_line_y(servo_screws_x, y=0, d=m2_hole_dia);
  }
}

module pan_servo_cutout_2d() {
  translate([0, wheels_offset_y + pan_servo_wheels_y_offset, 0]) {
    circle(r=pan_servo_slot_dia / 2, $fn=360);
    servo_screw_d = m2_hole_dia;
    step = servo_screw_d + 0.5;
    end = (chassis_width / 2) - pan_servo_slot_dia;
    servo_screws_x = number_sequence(from = -16, to = -6, step = step);

    pan_servo_screws_2d();
    mirror([1, 0, 0]) {
      pan_servo_screws_2d();
    }

    translate([0, 20, 0]) {
      square([20, 5], center = true);
    }

    translate([0, 10, 0]) {
      square([30, 5], center = true);
    }
    translate([0, -10, 0]) {
      square([30, 5], center = true);
    }
    translate([0, -18, 0]) {
      square([30, 5], center = true);
    }
  }
}

color("white") {
  pan_servo_cutout_2d();
}
