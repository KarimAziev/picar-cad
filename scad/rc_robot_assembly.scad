/**
  * Module: Assembly for RC-style robot with suspension.
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
include <colors.scad>
include <parameters.scad>
include <rc_params.scad>
include <suspension/front_chassis/computed_params.scad>

use <head/head_neck.scad>
use <lib/debug.scad>
use <lib/functions.scad>
use <lib/plist.scad>
use <lib/shapes3d.scad>
use <lib/slots.scad>
use <lib/transforms.scad>
use <lib/trapezoids.scad>
use <lipo_pack_case/multi_lipo_pack_case.scad>
use <motor_brackets/rc/gearbox_bracket.scad>
use <placeholders/dservo.scad>
use <placeholders/lidar.scad>
use <placeholders/rpi_5.scad>
use <power/power_case.scad>
use <suspension/bellcrank/bellcrank_drive.scad>
use <suspension/bellcrank/bellcrank_idler.scad>
use <suspension/bellcrank/bellcrank_slots.scad>
use <suspension/bellcrank/center_link.scad>
use <suspension/bellcrank_steering_assembly.scad>
use <suspension/bellcrank_steering_slots.scad>
use <suspension/bulkhead/front_bulkhead_chassis.scad>
use <suspension/bulkhead/front_bulkhead_housing.scad>
use <suspension/computed.scad>
use <suspension/front_chassis/front_chassis.scad>
use <suspension/front_chassis/front_chassis_controls.scad>
use <suspension/front_chassis/front_chassis_front_frame.scad>
use <suspension/front_suspension_assembly.scad>
use <suspension/middle_chassis/middle_chassis.scad>
use <suspension/rear_chassis/computed_params.scad>
use <suspension/rear_chassis/rear_chassis.scad>
use <suspension/steering_servo_bracket/steering_servo_bracket_assembly.scad>
use <suspension/steering_servo_bracket/steering_servo_chassis_slots.scad>
use <suspension/wishbone_arms/front_lower_arm.scad>

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
show_front_rpi                              = true;
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
head_chassis_joint_spacing                  = 0; // [0:1:30]
rear_chassis_joint_spacing                  = 0; // [0:1:30]
rear_suspension_joint_spacing               = 0; // [0:1:50]

show_rear_chassis                           = true;
show_rear_chassis_components                = true;
show_rear_gearbox_bracket                   = true;
show_rear_motor                             = true;
show_rear_gearbox                           = true;
show_drive_shaft                            = true;
show_extra_drive_shaft                      = true;
show_drive_shaft_seeve                      = true;
show_motor_encoder_bracket                  = true;
show_motor_encoder                          = true;
show_motor_encoder_magnet                   = true;
show_rear_equipment                         = true;
show_rear_suspension_mount                  = true;
show_rear_power_wiring                      = true;
show_rear_panel_stack                       = true;

show_middle_chassis_motor_slots             = true;

show_rear_power_case                        = true;
show_rear_lipo_packs                        = true;
show_rear_power_standoffs                   = true;
show_rear_lidar                             = true;
show_rear_lidar_lid                         = true;

show_middle_chassis                         = false;
show_middle_chassis_components              = false;
show_middle_chassis_power_case              = true;
show_middle_chassis_lipo_packs              = true;
show_middle_chassis_lidar                   = true;
show_middle_chassis_lidar_support           = true;

show_middle_chassis_rpi                     = true;
show_front_controls                         = true;
show_front_controls_slots                   = true;
show_front_access_slots                     = true;
show_middle_camera_slots                    = true;
show_middle_chassis_power_case_slots        = true;
show_middle_chassis_rpi_slots               = true;

// Steering angle
steering_servo_angle                        = 0; // [-25:1:25]

show_ideal_length                           = false;

chassis_ideal_wheelbase                     = 260;

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
                              show_front_rpi=show_front_rpi,
                              front_chassis_joint_spacing=front_chassis_joint_spacing,
                              head_chassis_joint_spacing=head_chassis_joint_spacing,
                              rear_suspension_joint_spacing=rear_suspension_joint_spacing,
                              show_middle_chassis=show_middle_chassis,
                              show_middle_chassis_components=show_middle_chassis_components,
                              show_middle_chassis_power_case=show_middle_chassis_power_case,
                              show_middle_chassis_lipo_packs=show_middle_chassis_lipo_packs,
                              show_middle_chassis_lidar=show_middle_chassis_lidar,
                              show_middle_chassis_lidar_support=show_middle_chassis_lidar_support,
                              show_front_access_slots=show_front_access_slots,
                              rear_chassis_joint_spacing=rear_chassis_joint_spacing,
                              show_rear_chassis=show_rear_chassis,
                              show_rear_chassis_components=show_rear_chassis_components,
                              show_rear_motor=show_rear_motor,
                              show_rear_gearbox=show_rear_gearbox,
                              show_rear_power_case=show_rear_power_case,
                              show_rear_lipo_packs=show_rear_lipo_packs,
                              show_rear_power_standoffs=show_rear_power_standoffs,
                              show_rear_lidar=show_rear_lidar,
                              show_rear_lidar_lid=show_rear_lidar_lid,
                              show_rear_gearbox_bracket=show_rear_gearbox_bracket,
                              show_drive_shaft=show_drive_shaft,
                              show_extra_drive_shaft=show_extra_drive_shaft,
                              show_drive_shaft_seeve=show_drive_shaft_seeve,
                              show_motor_encoder_bracket=show_motor_encoder_bracket,
                              show_motor_encoder=show_motor_encoder,
                              show_motor_encoder_magnet=show_motor_encoder_magnet,
                              show_rear_suspension_mount=show_rear_suspension_mount,
                              show_rear_power_wiring=show_rear_power_wiring,
                              show_rear_panel_stack=show_rear_panel_stack) {
  lipo_pack_case_props = multi_lipo_pack_props(plist=multi_lipo_packs_case);

  full_lipo_pack_size = plist_get("size", lipo_pack_case_props);
  body_width = suspension_chassis_width(include_middle=show_middle_chassis);
  rear_layout = rear_chassis_layout(min_width=body_width);

  front_chassis(width=body_width,
                show_front_frame=show_chassis_front_frame,
                show_rear_frame=show_chassis_rear_frame,
                debug=false,
                spacing=front_chassis_joint_spacing,
                head_spacing=head_chassis_joint_spacing,
                show_access_slots=show_front_access_slots);

  if (show_front_chassis_components && show_front_rpi) {
    translate([0, -front_chassis_joint_spacing, 0]) {
      front_chassis_rpi(slot_mode=false);
    }
  }

  if (show_front_chassis_components) {
    if (show_steering_assembly) {
      translate([0, 0, chassis_thickness]) {
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
               chassis_thickness]) {
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
               front_chassis_head_center_y() + head_chassis_joint_spacing,
               front_chassis_head_mount_z()]) {
      head_neck(center_pan_servo_slot=true,
                pan_servo_rotation=0);
    }
  }

  translate([0, front_chassis_y_joint_2_end - front_chassis_joint_spacing, 0]) {
    middle_chassis_assembly(width=body_width,
                            show_middle_chassis=show_middle_chassis,
                            show_middle_chassis_components=show_middle_chassis_components,
                            show_middle_chassis_power_case=show_middle_chassis_power_case,
                            show_middle_chassis_lipo_packs=show_middle_chassis_lipo_packs,
                            show_middle_chassis_lidar_support=show_middle_chassis_lidar_support,
                            show_middle_chassis_lidar=show_middle_chassis_lidar,
                            power_case_plist=multi_lipo_packs_case);
  }

  if (show_rear_chassis) {
    // The tongue fills the existing front socket; the rear deck starts at its lip.
    translate([0,
               front_chassis_y_joint_2_end - front_chassis_joint_spacing
               - (show_middle_chassis ? full_lipo_pack_size[1] : 0)
               - rear_chassis_joint_spacing,
               0]) {
      rotate([0, 0, 180]) {
        rear_chassis(anchor=[0, 1, 1],
                     layout=rear_layout,
                     front_joint=!show_middle_chassis,
                     show_power_case=show_rear_chassis_components && show_rear_power_case,
                     show_lipo_packs=show_rear_chassis_components && show_rear_lipo_packs,
                     show_power_standoffs=show_rear_chassis_components && show_rear_power_standoffs,
                     show_lidar=show_rear_chassis_components && show_rear_lidar,
                     show_gearbox=show_rear_chassis_components && show_rear_gearbox,
                     show_lidar_lid=show_rear_chassis_components && show_rear_lidar_lid,
                     show_motor=show_rear_chassis_components && show_rear_motor,
                     show_gearbox_bracket=show_rear_chassis_components && show_rear_gearbox_bracket,
                     show_drive_shaft=show_drive_shaft,
                     show_extra_drive_shaft=show_extra_drive_shaft,
                     show_drive_shaft_seeve=show_drive_shaft_seeve,
                     show_motor_encoder_bracket=show_motor_encoder_bracket,
                     show_motor_encoder=show_motor_encoder,
                     show_motor_encoder_magnet=show_motor_encoder_magnet,
                     rear_suspension_joint_spacing=rear_suspension_joint_spacing,
                     show_rear_suspension_mount=show_rear_suspension_mount,
                     show_power_wiring=show_rear_power_wiring,
                     show_panel_stack=show_rear_panel_stack);
      }
    }
  }
}

front_chassis_assembly();
if (show_ideal_length) {
  translate([0, front_bulkhead_len / 2, 0]) {
    #cuboid(size=[200, chassis_ideal_wheelbase, 40], anchor=[0, -1, 1]);
  }
 }
