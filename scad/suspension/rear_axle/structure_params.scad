/**
  * Module: Rear axle printed structure settings.
  *
  * Clearances are diametral for bores and per face for cavities. Dimensions
  * without a cited hardware reference are adjustable design dimensions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>
include <../rear_suspension/rear_suspension_params.scad>
include <rear_camber_link_params.scad>

use <../../lib/plist.scad>
use <../rear_chassis/computed_params.scad>
use <../rc_wheels.scad>
use <../wishbone_arms/util.scad>
use <../bulkhead/util.scad>

// The motor-side floor edge clears the raised suspension joint shoulder.
rear_housing_chassis_layout = rear_chassis_layout();
rear_housing_base_step_y    = plist_get("bulkhead_2_y",
                                     rear_housing_chassis_layout)
                               - rear_suspension_mount_recess_end_y(rear_housing_chassis_layout);

rear_housing_mount_nut_h = 2.6;

rear_housing_spec = ["body_w", front_bulkhead_w,
                     "body_l", front_bulkhead_len,
                     "base_h", front_bulkhead_housing_h,
                     "barrel_w", front_bulkhead_barrel_hinge_w,
                     "barrel_l", front_lower_arm_mount_cutout_size()[1]
                                   - front_bulkhead_barrel_hinge_clearance,
                     "hinge_axis_y", front_bulkhead_len / 2
                                       - front_bulkhead_barrel_y_offset
                                       - (front_lower_arm_mount_cutout_size()[1]
                                          - front_bulkhead_barrel_hinge_clearance) / 2,
                     "hinge_axis_z", front_bulkhead_housing_h / 2,
                     "differential_axis_z", 22.6,
                     "pinion_axis_z", 22.6,
                     "input_support_wall", 2,
                     "tower_mount_thickness", front_bulkhead_shock_tower_mount_thickness,
                     "tower_lower_bolt_z", front_bulkhead_housing_h
                                             + front_bulkhead_shock_tower_mount_offset
                                             + front_shock_tower_bolt_d / 2
                                             + front_shock_tower_damper_holes_pad_y,
                     "upper_h", front_bulkhead_shock_tower_mount_offset
                                  + shock_tower_mount_size_y()
                                  + front_bulkhead_shock_tower_mount_pad_y_top,
                     "mount_tab_h", front_bulkhead_hinge_thickness,
                     "base_step_y", rear_housing_base_step_y,
                     "base_step_h", suspension_chassis_mount_recess,
                     "base_step_clearance", 0.2,
                     "bearing_lip", 2,
                     "bearing_clearance", 0.15,
                     "bearing_axial_clearance", 0.1,
                     "shaft_clearance", 0.4,
                     "gear_clearance", 0.6,
                     "crown_cover_wall", 2,
                     "crown_cover_edge_r", 1,
                     "mount_bolt_d", rear_suspension_chassis_bolt_d,
                     "mount_pad", 2.5,
                     "mount_fastener_indices", [0, 1, 2, 3],
                     "mount_nut_af", 5.7,
                     "mount_nut_h", rear_housing_mount_nut_h,
                     "mount_nut_floor", front_bulkhead_housing_h
                                         + front_bulkhead_hinge_thickness
                                         - rear_housing_mount_nut_h,
                     "hinge_axis_x", front_bulkhead_w / 2
                                     + front_bulkhead_barrel_hinge_w
                                     - front_bulkhead_barrel_pin_hole_offset
                                     - front_lower_arm_hinge_barrel_hole_d / 2,
                     "hinge_pin_d", front_lower_arm_hinge_barrel_hole_d,
                     "pinion_mesh_y", 12, // Bevel mesh datum; physical gear pair must be measured.
                     "pinion_axis_x", 0,
                     "link_ear_w", 4,
                     "tower_bolt_d", 3.2,
                     "tower_insert_d", 4.6,
                     "tower_insert_l", 4,
                     "csg_epsilon", 0.02,
                     "fn", 64,
                     "color", "#277d9e"];

// 02042 documented envelope:82×34mm. The mounting pattern follows the shared
// front bulkhead interface; thickness, adjustment rows and reliefs are design dimensions.
rear_tower_spec = ["w", 82,
                   "h", 34,
                   "thickness", 4,
                   "mount_bolt_spacing", front_shock_tower_bolt_spacing,
                   "mount_z", 5,
                   "mount_bolt_d", 3.2,
                   "mount_pad", 4,
                   "shock_hole_x", [34, 28],
                   "shock_hole_z", [29, 25],
                   "shock_bolt_d", 3.2,
                   "shock_boss_d", 8,
                   "shock_boss_h", 2,
                   "link_x", 25,
                   "link_z", 9,
                   "link_bolt_d", 3.2,
                   "window_w", 37,
                   "window_h", 7,
                   "window_z", 24,
                   "rib_w", 4,
                   "corner_r", 2,
                   "csg_epsilon", 0.02,
                   "fn", 48,
                   "color", "#277d9e"];

rear_axle_settings = ["show_housing", true,
                      "wheel_center_z", rc_rear_level_wheel_center_z(),
                      "hub_camber_angle", 0,
                      "show_lid", true,
                      "show_arms", true,
                      "show_hubs", true,
                      "show_tower", true,
                      "show_drivetrain", true,
                      "show_bearings", true,
                      "show_shocks", true,
                      "show_links", true,
                      "show_sleeve", true,
                      "show_fasteners", true,
                      "show_mount", false,
                      "require_stock_fit", false,
                      "fit_tolerance", 0.25,
                      "lid_lift", 0,
                      "shock_hole", 0,
                      "shock_mount_gap", 0.5,
                      "shock_tower_side", -1,
                      "show_fit_markers", true,
                      "fit_marker_d", 2,
                      "link_standoff", 0.5,
                      "coupling_axial_gap", 1,
                      "camber_link", rear_camber_link_spec,
                      "fn", 48];

// M3 visual hardware and design clearances; lengths follow the mounting stack.
rear_fastener_spec = ["d", 3,
                      "head_d", 5.5,
                      "head_h", 3,
                      "nut_af", 5.5,
                      "nut_h", 2.4,
                      "washer_d", 7,
                      "thread_projection", 1,
                      "fn", 32,
                      "color", "Silver"];
