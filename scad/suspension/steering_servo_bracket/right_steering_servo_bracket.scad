/**
  * Module: Printable right-side bracket for the steering servo
  *
  * It is recommended to print this bracket lying on its side, which will
  * increase its bending strength.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <left_steering_servo_bracket.scad>

module right_steering_servo_bracket() {
  mirror([1, 0, 0]) {
    left_steering_servo_bracket();
  }
}

right_steering_servo_bracket();