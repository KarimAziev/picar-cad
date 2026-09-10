/**
  * Module: Front chassis assembly.
  *
  * Assembles the front chassis, including its front and rear frame sections,
  * together with the front suspension, bellcrank steering assembly, and
  * steering servo components, middle chassis, electronics and rear drivetrain.
  * This is the suspension vehicle entry point. Joint-spacing controls are measured
  * in millimeters; zero assembles the frames and positive values separate them
  * along Y. The servo follows the rear front-chassis frame, the bellcranks stay
  * on the front frame, and the middle payload follows the middle frame.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>
include <computed_params.scad>
include <../middle_chassis/computed_params.scad>

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>
use <../../head/head_neck.scad>
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
use <front_chassis_front_frame.scad>
use <../middle_chassis/middle_chassis.scad>
use <../rear_chassis/rear_chassis_assembly.scad>

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
show_steering_servo_encoder                 = true;
show_steering_servo_encoder_bracket         = true;
show_steering_servo_magnet                  = true;

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
show_head                                   = true;
show_front_chassis_components               = true;

// Joint separation for assembly inspection.
front_chassis_joint_spacing                 = 0; // [0:1:30]
middle_chassis_joint_spacing                = 0; // [0:1:30]
rear_chassis_joint_spacing                  = 0; // [0:1:30]
rear_motor_spacing                         = 0; // [0:1:40]

show_rear_chassis                           = true;
show_rear_chassis_components                = true;
show_rear_motor_carrier                     = true;
show_rear_motor                             = true;
show_rear_gearbox                           = true;
show_rear_driveshaft                        = true;
show_rear_dogbone                           = true;
show_rear_unused_shaft                      = true;
show_rear_differential_envelope             = false;
show_rear_motor_slots                       = true;

show_middle_chassis                        = true;
show_middle_chassis_components             = true;
show_middle_chassis_power_cases            = true;
show_middle_chassis_rpi                    = true;
show_middle_chassis_panel_stack            = true;
show_middle_chassis_power_case_slots       = true;
show_middle_chassis_rpi_slots              = true;
show_middle_chassis_panel_stack_slots      = true;

// Steering angle
steering_servo_angle                        = 0; // [-25:1:25]

module front_chassis_assembly(show_bellcrank_drive=show_bellcrank_drive,
                              show_bellcrank_idler=show_bellcrank_idler,
                              show_bellcrank_post=show_bellcrank_post,
                              show_bellcrank_idler_lever=show_bellcrank_idler_lever,
                              show_idler_upper_bearing=show_idler_upper_bearing,
                              show_idler_lower_bearing=show_idler_lower_bearing,
                              show_steering_servo=show_steering_servo,
                              show_steering_servo_bracket_bolt=show_steering_servo_bracket_bolt,
                              show_steering_servo_chassis_bolt=show_steering_servo_chassis_bolt,
                              show_steering_servo_chassis_bolt_nut=show_steering_servo_chassis_bolt_nut,
                              show_steering_servo_bracket_bolt_nut=show_steering_servo_bracket_bolt_nut,
                              show_steering_servo_brackets=show_steering_servo_brackets,
                              show_steering_servo_encoder=show_steering_servo_encoder,
                              show_steering_servo_encoder_bracket=show_steering_servo_encoder_bracket,
                              show_steering_servo_magnet=show_steering_servo_magnet,
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
                              show_chassis_front_frame=show_chassis_front_frame,
                              show_chassis_rear_frame=show_chassis_rear_frame,
                              show_head=show_head,
                              show_front_chassis_components=show_front_chassis_components,
                              front_chassis_joint_spacing=front_chassis_joint_spacing,
                              middle_chassis_joint_spacing=middle_chassis_joint_spacing,
                              show_middle_chassis=show_middle_chassis,
                              show_middle_chassis_components=show_middle_chassis_components,
                              show_middle_chassis_power_cases=show_middle_chassis_power_cases,
                              show_middle_chassis_rpi=show_middle_chassis_rpi,
                              show_middle_chassis_panel_stack=show_middle_chassis_panel_stack,
                              show_middle_chassis_power_case_slots=show_middle_chassis_power_case_slots,
                              show_middle_chassis_rpi_slots=show_middle_chassis_rpi_slots,
                              show_middle_chassis_panel_stack_slots=show_middle_chassis_panel_stack_slots,
                              rear_chassis_joint_spacing=rear_chassis_joint_spacing,
                              rear_motor_spacing=rear_motor_spacing,
                              show_rear_chassis=show_rear_chassis,
                              show_rear_chassis_components=show_rear_chassis_components,
                              show_rear_motor_carrier=show_rear_motor_carrier,
                              show_rear_motor=show_rear_motor,
                              show_rear_gearbox=show_rear_gearbox,
                              show_rear_driveshaft=show_rear_driveshaft,
                              show_rear_dogbone=show_rear_dogbone,
                              show_rear_unused_shaft=show_rear_unused_shaft,
                              show_rear_differential_envelope=show_rear_differential_envelope,
                              show_rear_motor_slots=show_rear_motor_slots) {
  front_chassis(show_front_frame=show_chassis_front_frame,
                show_rear_frame=show_chassis_rear_frame,
                debug=false,
                spacing=front_chassis_joint_spacing);

  if (show_front_chassis_components) {
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
                                  show_steering_servo_encoder=show_steering_servo_encoder,
                                  show_steering_servo_encoder_bracket=show_steering_servo_encoder_bracket,
                                  show_steering_servo_magnet=show_steering_servo_magnet,
                                  steering_servo_angle=steering_servo_angle,
                                  steering_servo_spacing=front_chassis_joint_spacing);
    }
  }

  if (show_head) {
    translate([0,
               front_chassis_head_center_y(),
               front_chassis_head_mount_z()]) {
      head_neck(center_pan_servo_slot=true,
                pan_servo_rotation=0);
    }
  }

  translate([0,
             -bellcrank_y_distance_from_bulkhead + bellcrank_zone_y_len
             - front_chassis_joint_spacing - middle_chassis_joint_spacing,
             0]) {
    middle_chassis_assembly(
      show_middle_chassis=show_middle_chassis,
      show_middle_chassis_components=show_middle_chassis_components,
      show_middle_chassis_power_cases=show_middle_chassis_power_cases,
      show_middle_chassis_rpi=show_middle_chassis_rpi,
      show_middle_chassis_panel_stack=show_middle_chassis_panel_stack,
      show_middle_chassis_power_case_slots=show_middle_chassis_power_case_slots,
      show_middle_chassis_rpi_slots=show_middle_chassis_rpi_slots,
      show_middle_chassis_panel_stack_slots=show_middle_chassis_panel_stack_slots,
      anchor=[0, -1, 1]);
    translate([0, -middle_chassis_size()[1] + joint_l - rear_chassis_joint_spacing, 0]) {
      rear_chassis_assembly(
        show_rear_chassis=show_rear_chassis,
        show_rear_chassis_components=show_rear_chassis_components,
        show_rear_motor_carrier=show_rear_motor_carrier,
        show_rear_motor=show_rear_motor,
        show_rear_gearbox=show_rear_gearbox,
        show_rear_driveshaft=show_rear_driveshaft,
        show_rear_dogbone=show_rear_dogbone,
        show_rear_unused_shaft=show_rear_unused_shaft,
        show_rear_differential_envelope=show_rear_differential_envelope,
        show_rear_motor_slots=show_rear_motor_slots,
        rear_motor_spacing=rear_motor_spacing);
    }
  }
}

front_chassis_assembly();
