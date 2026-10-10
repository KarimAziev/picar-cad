/**
  * Module: Wired Servo Magnet Sleeve for encoder
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../rc_params.scad>

use <servo_magnet_sleeve.scad>

module rc_steering_magnet_sleeve(alpha=1,
                                 color=black_1,
                                 magnet_d=steering_magnet_d,
                                 magnet_h=steering_magnet_h,
                                 show_bolt=false,
                                 show_magnet=false) {
  servo_magnet_sleeve(bolt_d=steering_servo_arm_bolt_d,
                      bolt_head_h=steering_servo_arm_gear_bolt_head_h,
                      bolt_head_d=steering_servo_arm_gear_bolt_head_d,
                      bolt_h=steering_servo_arm_gear_bolt_h,
                      magnet_d_clearance=steering_magnet_sleeve_d_clearance,
                      magnet_h_outer_h=steering_magnet_sleeve_outer_h,
                      magnet_d=magnet_d,
                      magnet_h=magnet_h,
                      thickness=steering_magnet_sleeve_wall_thickness,
                      bottom_thickness=steering_magnet_sleeve_bottom_thickness,
                      bolt_head_h_clearance=steering_magnet_sleeve_bolt_head_h_clearance,
                      bolt_head_d_clearance=steering_magnet_sleeve_bolt_head_d_clearance,
                      alpha=alpha,
                      show_bolt=show_bolt,
                      color=color,
                      show_magnet=show_magnet);
}
