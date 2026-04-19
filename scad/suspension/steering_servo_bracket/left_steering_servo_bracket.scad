/**
  * Module: Printable left-side bracket for the steering servo.
  *
  * It is recommended to print this bracket lying on its side, which will
  * increase its bending strength.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../steering_params.scad>

use <servo_bracket.scad>

module left_steering_servo_bracket() {
  translate([steering_servo_bracket_thickness, 0, 0]) {
    rotate([90, 90, -90]) {
      servo_l_bracket(show_chassis_bolt_nut=false,
                      show_servo_bolt_nut=false,
                      show_servo_bolt=false,
                      show_chassis_bolt=false);
    }
  }
}
left_steering_servo_bracket();