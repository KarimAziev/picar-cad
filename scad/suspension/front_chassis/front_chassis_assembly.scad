/**
  * Module: Front chassis assembly.
  *
  * Assembles the front chassis, including its front and rear frame sections,
  * together with the front suspension, bellcrank steering assembly, and
  * steering servo components.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>
use <../../placeholders/dservo.scad>
use <../../placeholders/rpi_5.scad>
use <../../power/power_case.scad>
use <../bellcrank/bellcrank_drive.scad>
use <../bellcrank/bellcrank_idler.scad>
use <../bellcrank/bellcrank_slots.scad>
use <../bellcrank/center_link.scad>
use <../bellcrank_steering_assembly.scad>
use <../bellcrank_steering_slots.scad>
use <../bulkhead/front_bulkhead_chassis.scad>
use <../bulkhead/front_bulkhead_housing.scad>
use <../front_suspension_assembly.scad>
use <../steering_servo_bracket/steering_servo_bracket_assembly.scad>
use <../steering_servo_bracket/steering_servo_chassis_slots.scad>
use <../wishbone_arms/front_lower_arm.scad>
use <front_chassis.scad>

show_chassis_front_frame                    = true;
show_chassis_rear_frame                     = true;
show_bellcrank_drive                        = true;
show_bellcrank_drive_idler_lever            = true;
show_bellcrank_drive_servo_lever            = true;
show_bellcrank_drive_upper_cap              = false;

show_bellcrank_idler                        = true;
show_bellcrank_post                         = true;
show_bellcrank_idler_lever                  = true;

show_idler_upper_bearing                    = true;
show_idler_lower_bearing                    = true;

show_steering_servo                         = true;
show_steering_servo_bracket_bolt            = true;
show_steering_servo_chassis_bolt            = true;
show_steering_servo_chassis_bolt_nut        = true;
show_steering_servo_bracket_bolt_nut        = true;
show_steering_servo_brackets                = true;

show_steering_assembly                      = true;

show_center_link                            = true;

show_front_lower_arm                        = true;
show_front_lower_arm_pin                    = true;
show_front_lower_pin_e_clip                 = true;
show_front_lower_arm_ball_stud              = true;

show_front_upper_arm                        = true;

show_front_bulkhead                         = true;
show_front_bulkhead_upper_suspension_holder = true;

show_upper_arm_ball_stud                    = true;
show_front_upper_arm_pin                    = true;

show_front_shock_tower                      = true;
show_front_suspension_arm_pad               = true;

show_left_knuckle                           = true;
show_right_knuckle                          = true;
show_knuckle_bushing                        = true;
show_knuckle_inner_bearing                  = true;
show_knuckle_outer_bearing                  = true;
show_knuckle_tie_rod                        = true;

show_front_bulkhead_housing                 = true;

// Steering angle
steering_servo_angle                        = 0; // [-25:1:25]

module front_chassis_assembly(show_bellcrank_drive=show_bellcrank_drive,
                              show_bellcrank_idler=show_bellcrank_idler,
                              show_bellcrank_post=show_bellcrank_post,
                              show_bellcrank_idler_lever=show_bellcrank_idler_lever,
                              show_idler_upper_bearing=show_idler_upper_bearing,
                              show_idler_lower_bearing=show_idler_lower_bearing,
                              show_steering_servo=show_steering_servo,
                              show_steering_servo=show_steering_servo,
                              show_steering_servo_bracket_bolt=show_steering_servo_bracket_bolt,
                              show_steering_servo_chassis_bolt=show_steering_servo_chassis_bolt,
                              show_steering_servo_chassis_bolt_nut=show_steering_servo_chassis_bolt_nut,
                              show_steering_servo_bracket_bolt_nut=show_steering_servo_bracket_bolt_nut,
                              show_steering_servo_brackets=show_steering_servo_brackets,
                              show_steering_assembly=show_steering_assembly,
                              show_center_link=show_center_link,
                              show_front_lower_arm=show_front_lower_arm,
                              show_front_lower_arm_pin=show_front_lower_arm_pin,
                              show_front_lower_pin_e_clip=show_front_lower_pin_e_clip,
                              show_front_lower_arm_ball_stud=show_front_lower_arm_ball_stud,
                              show_front_upper_arm=show_front_upper_arm,
                              show_front_bulkhead=show_front_bulkhead,
                              show_front_bulkhead_upper_suspension_holder=show_front_bulkhead_upper_suspension_holder,
                              show_upper_arm_ball_stud=show_upper_arm_ball_stud,
                              show_front_upper_arm_pin=show_front_upper_arm_pin,
                              show_front_shock_tower=show_front_shock_tower,
                              show_front_suspension_arm_pad=show_front_suspension_arm_pad,
                              show_left_knuckle=show_left_knuckle,
                              show_right_knuckle=show_right_knuckle,
                              show_knuckle_bushing=show_knuckle_bushing,
                              show_knuckle_inner_bearing=show_knuckle_inner_bearing,
                              show_knuckle_outer_bearing=show_knuckle_outer_bearing,
                              show_knuckle_tie_rod=show_knuckle_tie_rod,
                              show_front_bulkhead_housing=show_front_bulkhead_housing,
                              show_bellcrank_drive_idler_lever=show_bellcrank_drive_idler_lever,
                              show_bellcrank_drive_servo_lever=show_bellcrank_drive_servo_lever,
                              show_bellcrank_drive_upper_cap=show_bellcrank_drive_upper_cap,
                              steering_servo_angle=steering_servo_angle,
                              show_chassis_rear_frame=show_chassis_rear_frame) {
  front_chassis(show_front_frame=show_chassis_front_frame,
                show_rear_frame=show_chassis_rear_frame,
                debug=false);

  if (show_steering_assembly) {
    translate([0, 0, front_chassis_thickness]) {
      front_suspension_assembly(show_front_lower_arm=show_front_lower_arm,
                                show_front_upper_arm=show_front_upper_arm,
                                show_knuckle_bushing=show_knuckle_bushing,
                                show_knuckle_inner_bearing=show_knuckle_inner_bearing,
                                show_knuckle_outer_bearing=show_knuckle_outer_bearing,
                                show_knuckle_tie_rod=show_knuckle_tie_rod,
                                show_front_bulkhead=show_front_bulkhead,
                                show_front_shock_tower=show_front_shock_tower,
                                show_front_bulkhead_upper_suspension_holder=show_front_bulkhead_upper_suspension_holder,
                                show_front_suspension_arm_pad=show_front_suspension_arm_pad,
                                show_upper_arm_ball_stud=show_upper_arm_ball_stud,
                                show_front_upper_arm_pin=show_front_upper_arm_pin,
                                show_front_lower_arm_pin=show_front_lower_arm_pin,
                                show_front_lower_pin_e_clip=show_front_lower_pin_e_clip,
                                show_front_lower_arm_ball_stud=show_front_lower_arm_ball_stud,
                                show_left_knuckle=show_left_knuckle,
                                show_right_knuckle=show_right_knuckle,
                                show_front_bulkhead_housing=show_front_bulkhead_housing);
    }
  }

  translate([0,
             -bellcrank_y_distance_from_bulkhead,
             front_chassis_thickness]) {
    bellcrank_steering_assembly(show_bellcrank_drive=show_bellcrank_drive,
                                show_bellcrank_drive_idler_lever=show_bellcrank_drive_idler_lever,
                                show_bellcrank_drive_servo_lever=show_bellcrank_drive_servo_lever,
                                show_bellcrank_drive_upper_cap=show_bellcrank_drive_upper_cap,
                                show_bellcrank_idler=show_bellcrank_idler,
                                show_bellcrank_post=show_bellcrank_post,
                                show_bellcrank_idler_lever=show_bellcrank_idler_lever,
                                show_idler_upper_bearing=show_idler_upper_bearing,
                                show_idler_lower_bearing=show_idler_lower_bearing,
                                show_center_link=show_center_link,
                                show_steering_servo=show_steering_servo,
                                show_steering_servo_bracket_bolt=show_steering_servo_bracket_bolt,
                                show_steering_servo_chassis_bolt=show_steering_servo_chassis_bolt,
                                show_steering_servo_chassis_bolt_nut=show_steering_servo_chassis_bolt_nut,
                                show_steering_servo_bracket_bolt_nut=show_steering_servo_bracket_bolt_nut,
                                show_steering_servo_brackets=show_steering_servo_brackets,
                                steering_servo_angle=steering_servo_angle);
  }
}

front_chassis_assembly();
