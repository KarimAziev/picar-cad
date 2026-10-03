/**
  * Module: Upper steering bridge in the articulated front suspension.
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../rc_params.scad>

use <bellcrank_steering_assembly.scad>
use <front_suspension_assembly.scad>
use <upper_steering_plate.scad>

lower_arm_angle = 10; // [-15:1:25]
steering_angle  = 0; // [-25:1:25]
show_plate      = true;
show_bolts      = true;
show_wheels     = true;

translate([0, bellcrank_y_distance_from_bulkhead, 0]) {
  front_suspension_assembly(show_wheels=show_wheels,
                            solve_linkage=true,
                            lower_arm_angle=lower_arm_angle,
                            bellcrank_angle=steering_angle);
}

bellcrank_steering_assembly(steering_servo_angle=steering_angle,
                            show_steering_servo=false,
                            show_steering_servo_brackets=false,
                            show_steering_servo_encoder=false,
                            show_steering_servo_encoder_bracket=false,
                            show_steering_servo_magnet=false);
if (show_plate) {
  upper_steering_plate_position() {
    upper_steering_plate(show_bolts=show_bolts);
  }
 }
