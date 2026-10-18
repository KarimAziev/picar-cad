/**
  * Module: Empty assembly for RC-style robot with suspension.
  *
  * Assembles the front chassis, including its front and rear frame sections,
  * together with the front suspension, bellcrank steering assembly, and
  * steering servo components, electronics and rear drivetrain.
  * This is the suspension vehicle entry point. Joint-spacing controls are measured
  * in millimeters; zero assembles the frames and positive values separate them
  * along Y. The servo follows the rear front-chassis frame, the bellcranks stay
  * on the front frame.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <colors.scad>
include <parameters.scad>
include <rc_params.scad>
include <suspension/front_chassis/computed_params.scad>

use <head/head_neck.scad>
use <lib/plist.scad>
use <suspension/bellcrank_steering_assembly.scad>
use <suspension/chassis_dimensions.scad>
use <suspension/computed.scad>
use <suspension/front_bumper/common.scad>
use <suspension/front_bumper/front_bumper_assembly.scad>
use <suspension/front_chassis/front_chassis.scad>
use <suspension/front_chassis/front_chassis_controls.scad>
use <suspension/front_chassis/front_chassis_joint.scad>
use <suspension/front_chassis/front_frame_util.scad>
use <suspension/front_chassis/head_frame/head_joint.scad>
use <suspension/front_suspension_assembly.scad>
use <suspension/rc_wheels.scad>
use <suspension/rear_chassis/computed_params.scad>
use <suspension/rear_chassis/rear_chassis.scad>
use <suspension/rear_suspension/rear_suspension_joint.scad>
use <suspension/upper_steering_plate.scad>

show_head_frame                             = true;
show_chassis_front_frame                    = true;
show_chassis_rear_frame                     = true;
show_rear_chassis                           = true;
show_rear_suspension_mount                  = true;

// Joint separation for assembly inspection.
front_chassis_joint_spacing                 = 0; // [0:1:30]
head_chassis_joint_spacing                  = 0; // [0:1:30]
rear_chassis_joint_spacing                  = 0; // [0:1:30]
rear_suspension_joint_spacing               = 0; // [0:1:50]

show_front_wheels                           = false;
show_front_bumper_top_plate                 = false;
show_front_bumper_foam                      = false;
show_front_bumper_bolts                     = false;
show_rear_wheels_preview                    = false;
show_wheel_tires                            = false;

show_upper_steering_plate                   = false;
show_upper_steering_plate_bolts             = false;
show_bellcrank_drive                        = false;
show_bellcrank_drive_idler_lever            = false;
show_bellcrank_drive_servo_lever            = false;
show_bellcrank_drive_upper_cap              = false;

show_bellcrank_idler                        = false;
show_bellcrank_post                         = false;
show_bellcrank_idler_lever                  = false;

show_idler_upper_bearing                    = false;
show_idler_lower_bearing                    = false;

show_steering_servo                         = false;
show_steering_servo_bracket_bolt            = false;
show_steering_servo_chassis_bolt            = false;
show_steering_servo_chassis_bolt_nut        = false;
show_steering_servo_bracket_bolt_nut        = false;
show_steering_servo_brackets                = false;
show_steering_servo_encoder                 = false;
show_steering_servo_encoder_bracket         = false;
show_steering_servo_magnet                  = false;

show_steering_assembly                      = false;

show_center_link                            = false;

show_front_lower_arm                        = false;
show_front_lower_arm_pin                    = false;
show_front_lower_pin_e_clip                 = false;
show_front_lower_arm_ball_stud              = false;

show_front_upper_arm                        = false;

show_front_bulkhead                         = false;
show_front_bulkhead_upper_suspension_holder = false;

// Raspberry PI
show_front_rpi                              = false;
show_rpi_sd_card                            = false;
show_rpi_standoffs                          = false;
show_rpi_usb_c_plug                         = false;
show_rpi_ai_hat                             = false;
show_rpi_motor_driver_hat                   = false;
show_rpi_servo_driver_hat                   = false;
show_rpi_gpio_expansion_board               = false;

show_upper_arm_ball_stud                    = false;
show_front_upper_arm_pin                    = false;

show_front_shock_tower                      = false;
show_front_suspension_arm_pad               = false;

show_left_knuckle                           = false;
show_right_knuckle                          = false;
show_knuckle_bushing                        = false;
show_knuckle_inner_bearing                  = false;
show_knuckle_outer_bearing                  = false;
show_knuckle_tie_rod                        = false;

show_front_bulkhead_housing                 = false;
show_head                                   = false;
show_front_chassis_components               = false;

show_rear_chassis_components                = false;
show_rear_gearbox_bracket                   = false;
show_rear_motor                             = false;
show_rear_gearbox                           = false;
show_drive_shaft                            = false;
show_extra_drive_shaft                      = false;
show_drive_shaft_seeve                      = false;
show_drive_shaft_encoder_sleeve             = false;
show_motor_encoder_bracket                  = false;
show_motor_encoder                          = false;
show_motor_encoder_magnet                   = false;
show_rear_chassis_nuts                      = false;
show_rear_chassis_mount_bolts               = false;
show_rear_chassis_equipment                 = false;
show_rear_chassis_equipment_zones           = false;
show_motor_gearbox_bosses                   = false;

show_rear_equipment                         = false;
show_rear_power_wiring                      = false;
show_rear_panel_stack                       = false;

show_rear_power_case                        = false;
show_rear_lipo_packs                        = false;
show_rear_power_standoffs                   = false;
show_rear_lidar                             = false;
show_rear_lidar_lid                         = false;

show_front_controls                         = false;
show_front_controls_slots                   = true;
show_front_access_slots                     = true;

// Preview-only pin passages with fit allowances and translucent chassis plates.
show_debug_pins                             = false;

// Prescribed suspension pose; positive arm angle lowers the wheel.
// This closes the wheel linkages, not the servo/center-bar calibration.
solve_front_linkage                         = false;
front_lower_arm_angle                       = 0; // [-15:1:25]
front_steering_hole                         = 0; // [0,1]

// Steering angle
steering_servo_angle                        = 0; // [-25:1:25]

// Measurements use the assembled reference pose and nominal tire envelopes.
show_wheelbase                              = true;
show_track_width                            = true;
show_ground_clearance                       = true;
show_overall_length                         = true;
show_chassis_width                          = true;

module rc_chassis(show_bellcrank_drive=show_bellcrank_drive,
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
                  solve_front_linkage=solve_front_linkage,
                  front_lower_arm_angle=front_lower_arm_angle,
                  front_steering_hole=front_steering_hole,
                  show_chassis_front_frame=show_chassis_front_frame,
                  show_chassis_rear_frame=show_chassis_rear_frame,
                  show_head=show_head,
                  show_front_chassis_components=show_front_chassis_components,
                  show_front_rpi=show_front_rpi,
                  show_rpi_sd_card=show_rpi_sd_card,
                  show_rpi_standoffs=show_rpi_standoffs,
                  show_rpi_usb_c_plug=show_rpi_usb_c_plug,
                  show_rpi_ai_hat=show_rpi_ai_hat,
                  show_rpi_motor_driver_hat=show_rpi_motor_driver_hat,
                  show_rpi_servo_driver_hat=show_rpi_servo_driver_hat,
                  show_rpi_gpio_expansion_board=show_rpi_gpio_expansion_board,
                  front_chassis_joint_spacing=front_chassis_joint_spacing,
                  head_chassis_joint_spacing=head_chassis_joint_spacing,
                  rear_suspension_joint_spacing=rear_suspension_joint_spacing,
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
                  show_rear_panel_stack=show_rear_panel_stack,
                  show_upper_steering_plate=show_upper_steering_plate,
                  show_upper_steering_plate_bolts=show_upper_steering_plate_bolts,
                  show_front_wheels=show_front_wheels,
                  show_rear_wheels_preview=show_rear_wheels_preview,
                  show_wheel_tires=show_wheel_tires,
                  show_head_frame=show_head_frame,
                  show_front_bumper_top_plate=show_front_bumper_top_plate,
                  show_front_bumper_foam=show_front_bumper_foam,
                  show_front_bumper_bolts=show_front_bumper_bolts,
                  show_motor_encoder_bracket=show_motor_encoder_bracket,
                  show_rear_chassis_nuts=show_rear_chassis_nuts,
                  show_rear_chassis_mount_bolts=show_rear_chassis_mount_bolts,
                  show_rear_chassis_equipment=show_rear_chassis_equipment,
                  show_rear_chassis_equipment_zones=show_rear_chassis_equipment_zones,
                  show_drive_shaft_encoder_sleeve=show_drive_shaft_encoder_sleeve,
                  show_motor_gearbox_bosses=show_motor_gearbox_bosses,
                  show_debug_pins=show_debug_pins,
                  show_wheelbase=show_wheelbase,
                  show_track_width=show_track_width,
                  show_ground_clearance=show_ground_clearance,
                  show_overall_length=show_overall_length,
                  show_chassis_width=show_chassis_width) {
  chassis_dimension_annotations(wheelbase=show_wheelbase,
                                track=show_track_width,
                                clearance=show_ground_clearance,
                                length=show_overall_length,
                                width=show_chassis_width,
                                bumper_top_plate=show_front_bumper_top_plate,
                                bumper_foam=show_front_bumper_foam,
                                bumper_pl=front_bumper_plist);
  resolved_front_chassis_joint_spacing = split_front_chassis
                                         ? front_chassis_joint_spacing
                                         : 0;
  resolved_head_chassis_joint_spacing = split_head_chassis
                                        ? head_chassis_joint_spacing
                                        : 0;
  resolved_rear_chassis_joint_spacing = split_rear_chassis
                                        ? rear_chassis_joint_spacing
                                        : 0;
  resolved_rear_suspension_joint_spacing = split_rear_suspension
                                           ? rear_suspension_joint_spacing
                                           : 0;
  body_width = suspension_chassis_width();
  rear_layout = rear_chassis_layout(min_width=body_width);

  module _pin_inspection_context() {
    if ($preview && show_debug_pins) {
      %color([0.7, 0.7, 0.7, 0.25]) {
        children();
      }
    } else {
      children();
    }
  }

  _pin_inspection_context() {
    front_chassis(width=body_width,
                  show_front_frame=show_chassis_front_frame,
                  show_rear_frame=show_chassis_rear_frame,
                  debug=false,
                  spacing=resolved_front_chassis_joint_spacing,
                  head_spacing=resolved_head_chassis_joint_spacing,
                  show_access_slots=show_front_access_slots,
                  show_head_frame=show_head_frame);
  }

  if ($preview && show_debug_pins) {
    // Pins follow the tongue plate, or the socket when only it is visible.
    head_visible = is_undef(show_head_frame)
                   ? show_chassis_front_frame
                   : show_head_frame;
    if (split_head_chassis && (head_visible || show_chassis_front_frame)) {
      translate([0, head_visible ? resolved_head_chassis_joint_spacing : 0, 0]) {
        #front_chassis_head_joint_pins();
      }
    }
    if (split_front_chassis && (show_chassis_front_frame || show_chassis_rear_frame)) {
      translate([0,
                 y_front_chassis_rear_frame_joint_1_start
                 - (show_chassis_front_frame ? 0 : resolved_front_chassis_joint_spacing),
                 0]) {
        #front_chassis_pin_joint_holes();
      }
    }
    if (split_rear_chassis && show_chassis_rear_frame && !show_rear_chassis) {
      translate([0,
                 front_chassis_y_joint_2_end + joint_l - resolved_front_chassis_joint_spacing,
                 0]) {
        #front_chassis_pin_joint_holes(pin_spacing=front_chassis_body_joint_pin_spacing(body_width));
      }
    }
  }

  if (show_front_chassis_components && show_front_rpi) {
    translate([0, -resolved_front_chassis_joint_spacing, 0]) {
      front_chassis_rpi(slot_mode=false,
                        show_rpi_sd_card=show_rpi_sd_card,
                        show_rpi_standoffs=show_rpi_standoffs,
                        show_rpi_usb_c_plug=show_rpi_usb_c_plug,
                        show_rpi_ai_hat=show_rpi_ai_hat,
                        show_rpi_motor_driver_hat=show_rpi_motor_driver_hat,
                        show_rpi_servo_driver_hat=show_rpi_servo_driver_hat,
                        show_rpi_gpio_expansion_board=show_rpi_gpio_expansion_board);
    }
  }

  if (show_front_chassis_components) {
    if (show_steering_assembly) {
      translate([0, 0, suspension_chassis_mount_h]) {
        front_suspension_assembly(show_wheels=show_front_wheels,
                                  show_tires=show_wheel_tires,
                                  solve_linkage=solve_front_linkage,
                                  lower_arm_angle=front_lower_arm_angle,
                                  bellcrank_angle=steering_servo_angle,
                                  steering_hole=front_steering_hole,
                                  show_front_lower_arm=show_front_lower_arm,
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
               suspension_chassis_mount_h]) {
      if (show_upper_steering_plate) {
        upper_steering_plate_position() {
          upper_steering_plate(show_bolts=show_upper_steering_plate_bolts);
        }
      }
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
                                  steering_servo_spacing=resolved_front_chassis_joint_spacing);
    }
  }

  translate(front_bumper_position(front_bumper_plist)
            + [0, resolved_head_chassis_joint_spacing, 0]) {
    front_bumper_assembly(pl=front_bumper_plist,
                          show_top_plate=show_front_bumper_top_plate,
                          show_foam=show_front_bumper_foam,
                          show_bolts=show_front_bumper_bolts);
  }

  if (show_head) {
    translate([0,
               front_chassis_head_center_y() + resolved_head_chassis_joint_spacing,
               front_chassis_head_mount_z()]) {
      head_neck(center_pan_servo_slot=true,
                pan_servo_rotation=0);
    }
  }

  if (show_rear_chassis) {
    // The tongue fills the existing front socket; the rear deck starts at its lip.
    translate([0,
               front_chassis_y_joint_2_end - resolved_front_chassis_joint_spacing
               - resolved_rear_chassis_joint_spacing,
               0]) {
      rotate([0, 0, 180]) {
        if ($preview && show_debug_pins) {
          if (split_rear_suspension) {
            translate([0, -plist_get("min_y", rear_layout), 0]) {
              #rear_suspension_chassis_joint_pins(layout=rear_layout);
            }
          }
          if (split_rear_chassis) {
            #front_chassis_pin_joint_holes(pin_spacing=front_chassis_body_joint_pin_spacing(plist_get("join_w", rear_layout)));
          }
        }
        _pin_inspection_context() {
          rear_chassis(anchor=[0, 1, 1],
                       layout=rear_layout,
                       front_joint=split_rear_chassis,
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
                       rear_suspension_joint_spacing=resolved_rear_suspension_joint_spacing,
                       show_rear_suspension_mount=show_rear_suspension_mount,
                       show_power_wiring=show_rear_power_wiring,
                       show_panel_stack=show_rear_panel_stack,
                       show_nuts=show_rear_chassis_nuts,
                       show_mount_bolts=show_rear_chassis_mount_bolts,
                       show_equipment=show_rear_chassis_equipment,
                       show_equipment_zones=show_rear_chassis_equipment_zones,
                       show_drive_shaft_encoder_sleeve=show_drive_shaft_encoder_sleeve,
                       show_motor_gearbox_bosses=show_motor_gearbox_bosses) {
            if (show_rear_wheels_preview) {
              translate([0, resolved_rear_suspension_joint_spacing, 0]) {
                rc_rear_wheels_preview(layout=rear_layout,
                                       show_tire=show_wheel_tires);
              }
            }
          }
        }
      }
    }
  }
}

rc_chassis();
