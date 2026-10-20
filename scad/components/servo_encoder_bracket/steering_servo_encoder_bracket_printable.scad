/**
  * Module: Steering Servo Encoder Bracket Printable
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../rc_params.scad>

use <steering_servo_encoder_bracket.scad>

module steering_servo_encoder_bracket_printable(
  x_offset=steering_encoder_x_offset) {
  rotate([90, 0, 0]) {
    steering_servo_encoder_bracket(show_encoder=false, x_offset=x_offset);
  }
}

steering_servo_encoder_bracket_printable();
