/**
  * Module: Printable plate with left and right steering servo brackets
  *
  * It is recommended to print these brackets on their sides, which increases
  * their bending strength.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

use <left_steering_servo_bracket.scad>
use <right_steering_servo_bracket.scad>

module steering_servo_brackets_print_plate(spacing=3) {
  sp = spacing / 2;
  for (i = [-1:2:1]) {
    translate([sp * i, 0, 0]) {
      if (i < 0) {
        right_steering_servo_bracket();
      } else {
        left_steering_servo_bracket();
      }
    }
  }
}

steering_servo_brackets_print_plate();