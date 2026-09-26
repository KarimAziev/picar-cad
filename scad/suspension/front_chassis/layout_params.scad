/**
  * Module: Front hardware datums and minimum width before vehicle-wide sizing.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../steering_params.scad>

use <../../placeholders/dservo.scad>
use <../../placeholders/rpi_5.scad>
use <../bellcrank_steering_slots.scad>
use <../bulkhead/front_bulkhead.scad>
use <../steering_servo_bracket/helpers.scad>
use <../wishbone_arms/util.scad>

bellcrank_params                         = bellcrank_steering_servo_position();
bellcrank_x_dist                         = abs(bellcrank_params[0]);
bellcrank_y_dist                         = bellcrank_params[1];
bellcrank_zone_y_len                     = bellcrank_params[2];

bulkhead_barrel_size                     = front_lower_arm_mount_cutout_size();
bulkhead_barrel_len                      = bulkhead_barrel_size[1]
                                            - front_bulkhead_barrel_hinge_clearance;
bulkhead_transition_len                  = front_bulkhead_len
                                            - bulkhead_barrel_len
                                            - front_bulkhead_barrel_y_offset;

bulkhead_base_size = front_bulkhead_base_size(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                              d=front_bulkhead_mount_bolt_d,
                                              padding_x=front_chassis_bulkhead_padding_x,
                                              padding_y=front_chassis_bulkhead_padding_y);
bellcrank_mount_d                        = max(bellcrank_idler_od,
                                               front_chassis_bellcrank_bolt_d,
                                               front_chassis_bellcrank_bolt_bore_d);

bellcrank_mount_r                        = bellcrank_mount_d / 2;

servo_chassis_reach                      = steering_encoder_plist
                                            ? max(dsservo_height_after_flange(),
                                            steering_servo_encoder_chassis_reach())
                                            : dsservo_height_after_flange();

servo_slot_min_w                         = servo_chassis_reach + bellcrank_x_dist;

bulkhead_size_x                          = bulkhead_base_size[0];
bulkhead_size_y                          = bulkhead_base_size[1];

bellcrank_x                              = chassis_bellcrank_spacing / 2;

joint_l                                  = abs(bellcrank_y_dist) - bellcrank_mount_r;

joint_rail_w                             = front_chassis_joint_bolt_spacing - front_chassis_joint_bolt_pad
                                            - front_chassis_joint_bolt_d;

joint_w                                  = bellcrank_x * 2 + front_chassis_joint_bolt_d + front_chassis_joint_bolt_pad;

joint_rail_h                             = (front_chassis_thickness / 2);

joint_base_h                             = (front_chassis_thickness - joint_rail_h) / 2;

joint_recess_w                           = joint_rail_w * 0.35;

front_frame_x_end                        = bellcrank_x
                                            + front_chassis_bellcrank_tool_access_hole_pad_x
                                            + max(bellcrank_mount_r,
                                            front_chassis_bellcrank_tool_access_hole_d / 2);

servo_end_y                              = -bellcrank_y_distance_from_bulkhead + bellcrank_zone_y_len;
y_front_chassis_rear_frame_joint_1_start = -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r;
y_front_chassis_rear_frame_main_start    = -bellcrank_y_distance_from_bulkhead + bellcrank_y_dist;

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_rpi_bounds
  ─────────────────────────────────────────────────────────────────────────────
  Return the RPi reference bounds on the rear section of the front chassis.
  **Parameters:**
  - `orientation`: Flat PCB orientation, `"wlh"` or `"lwh"`.
  - `x_offset`: Minimum X of the oriented reference box.
  - `y_offset`: Maximum Y relative to the rear frame's main-section start.
  **Returns:** `[minimum_xyz, maximum_xyz]` with the mounting reference at Z=0.
  Uses the same `[1, -1, 1]` anchor as the component and its mounting cutters.
 */
function front_chassis_rpi_bounds(orientation=front_rpi_orientation,
                                  x_offset=front_rpi_x_offset,
                                  y_offset=front_rpi_y_offset) =
  assert(orientation == "wlh" || orientation == "lwh",
         "Front RPi mounting requires a flat PCB (wlh or lwh)")
  let (size = rpi_5_oriented_size(orientation),
       y = y_front_chassis_rear_frame_main_start + y_offset)
  [[x_offset, y - size[1], 0], [x_offset + size[0], y, size[2]]];

front_rpi_bounds                        = front_chassis_rpi_bounds();
front_chassis_required_w                 = max(chassis_body_min_w,
                                               servo_slot_min_w * 2,
                                               2 * max(abs(front_rpi_bounds[0][0]),
                                                       abs(front_rpi_bounds[1][0])));

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_required_width
  ─────────────────────────────────────────────────────────────────────────────
  Return the minimum width required by the front hardware and configured floor.
 */
function front_chassis_required_width() = front_chassis_required_w;
