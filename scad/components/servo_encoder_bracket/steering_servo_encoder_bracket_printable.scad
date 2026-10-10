/**
  * Module: Steering Servo Encoder Bracket Printable
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

use <steering_servo_encoder_bracket.scad>

module steering_servo_encoder_bracket_printable() {
  rotate([90, 0, 0]) {
    steering_servo_encoder_bracket(show_encoder=false);
  }
}

steering_servo_encoder_bracket_printable();