/**
  * Module: Shared computed parameters
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../steering_params.scad>

use <../../placeholders/dservo.scad>
use <../bellcrank_steering_slots.scad>
use <../bulkhead/front_bulkhead.scad>
use <../steering_servo_bracket/helpers.scad>
use <../wishbone_arms/util.scad>

bellcrank_params        = bellcrank_steering_servo_position();
bellcrank_x_dist        = abs(bellcrank_params[0]);
bellcrank_y_dist        = bellcrank_params[1];
bellcrank_zone_y_len    = bellcrank_params[2];

bulkhead_barrel_size    = front_lower_arm_mount_cutout_size();
bulkhead_barrel_len     = bulkhead_barrel_size[1]
                           - front_bulkhead_barrel_hinge_clearance;
bulkhead_transition_len = front_bulkhead_len
                           - bulkhead_barrel_len
                           - front_bulkhead_barrel_y_offset;

bulkhead_base_size = front_bulkhead_base_size(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                              d=front_bulkhead_mount_bolt_d,
                                              padding_x=front_chassis_bulkhead_padding_x,
                                              padding_y=front_chassis_bulkhead_padding_y);
bellcrank_mount_d       = max(bellcrank_idler_od,
                              front_chassis_bellcrank_bolt_d,
                              front_chassis_bellcrank_bolt_bore_d);

bellcrank_mount_r       = bellcrank_mount_d / 2;

servo_chassis_reach     = steering_encoder_plist
                           ? max(dsservo_height_after_flange(),
                           steering_servo_encoder_chassis_reach())
                           : dsservo_height_after_flange();

servo_slot_min_w        = servo_chassis_reach + bellcrank_x_dist;

bulkhead_size_x         = bulkhead_base_size[0];
bulkhead_size_y         = bulkhead_base_size[1];

bellcrank_x             = chassis_bellcrank_spacing / 2;

joint_l                 = abs(bellcrank_y_dist) - bellcrank_mount_r;

joint_rail_w            = front_chassis_joint_bolt_spacing - front_chassis_joint_bolt_pad
                           - front_chassis_joint_bolt_d;

joint_w                 = bellcrank_x * 2 + front_chassis_joint_bolt_d + front_chassis_joint_bolt_pad;

joint_rail_h            = (front_chassis_thickness / 2);

joint_base_h            = (front_chassis_thickness - joint_rail_h) / 2;

joint_recess_w          = joint_rail_w * 0.35;

front_frame_x_end       = bellcrank_x
                           + front_chassis_bellcrank_tool_access_hole_pad_x
                           + max(bellcrank_mount_r,
                           front_chassis_bellcrank_tool_access_hole_d / 2);

chassis_joint_wide_w           = servo_slot_min_w * 2;
chassis_joint_wide_rail_w      = chassis_joint_wide_w
                                  - (front_chassis_joint_bolt_d
                                     + front_chassis_joint_bolt_pad) * 2;
chassis_joint_wide_bolt_edge_x = chassis_joint_wide_w / 2
                                  - front_chassis_joint_bolt_pad
                                  - front_chassis_joint_bolt_d / 2;
chassis_joint_wide_bolt_step   = chassis_joint_wide_bolt_edge_x * 2
                                  / (suspension_chassis_joint_wide_bolt_cols - 1);
chassis_joint_wide_bolt_xs     = [for (i = [0 : suspension_chassis_joint_wide_bolt_cols - 1])
                                     -chassis_joint_wide_bolt_edge_x
                                     + i * chassis_joint_wide_bolt_step];
chassis_joint_wide_pin_spacing = chassis_joint_wide_rail_w / 2;
