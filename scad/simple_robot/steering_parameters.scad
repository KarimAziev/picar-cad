/**
 * Module: Simple robot steering parameters
 *
 * Legacy rack-and-pinion, knuckle, servo and Ackermann dimensions in mm.
 * Includes the simple robot chassis and wheel defaults plus shared hardware.
 * Complete assemblies use parameters.scad in this directory.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <chassis_parameters.scad>
include <wheel_parameters.scad>

use <../lib/functions.scad>
use <chassis/knuckle_util.scad>

assembly_use_front_steering                   = false;
assembly_shaft_use_front_steering             = true;

// ─────────────────────────────────────────────────────────────────────────────
// Steering Knuckle
// ─────────────────────────────────────────────────────────────────────────────

// The height of the steering knuckle
knuckle_height                                = 14.0;

// Diameter of the steering knuckle
knuckle_dia                                   = 14.0;

// The outside diameter of the 685-Z bearing (5x11x5) that is inserted into the
// knuckle
knuckle_bearing_outer_dia                     = 11.0;

// The inside diameter (plus tolerance) of the 685-Z bearing (5x11x5).
// They are placed on the each side of the steering panel
knuckle_bearing_inner_dia                     = 5.20;

// The height of the 685-Z bearing placeholder used in the knuckle assembly
knuckle_bearing_height                        = 5;

// The height of the flange of the 685-Z bearing placeholder
knuckle_bearing_flanged_height                = 0.5;

// The width of the 685-Z bearing placeholder used in the knuckle assembly
knuckle_bearing_flanged_width                 = 0.5;

// Do not edit, used for Ackermann geometry calculations
knuckle_border_w                              = (knuckle_dia - knuckle_bearing_outer_dia) / 2;

// The diameter of the knuckle’s wheel shaft for the 608ZZ bearing
knuckle_shaft_dia                             = 8;

// The diameter of the knuckle's connector into which the shaft is inserted. It
// should be larger than the shaft itself.
knuckle_shaft_connector_dia                   = knuckle_shaft_dia * 1.4;

// The diameter of the fastening bolts on the knuckle connector for the wheel
// shaft.
knuckle_shaft_bolt_dia                        = m25_hole_dia;

knuckle_shaft_bolt_cbore_dia                  = m25_pan_head_dia + 0.2;

// The distance from the top of the shaft to the bolt holes
knuckle_shaft_bolts_offset                    = 2;

// distance between bolt holes on the shaft
knuckle_shaft_bolts_distance                  = 3;

// The length of the vertical part of the (curved) axle shaft that connects the
// steering knuckle to the wheel hub
knuckle_shaft_vertical_len                    = knuckle_height +
                                                       (motor_type == "n20"
                                                        ? 21.5
                                                        : 26.5);

// The additional length of the connector for the shaft in the knuckle and the
// corresponding curved axle shaft
knuckle_shaft_connector_extra_len             = 2;

knuckle_shaft_connector_extra_arm_len         = 1;

// The additional length of the for the shaft itself
knuckle_shaft_extra_len                       = assembly_shaft_use_front_steering
                                                       &&
                                                       assembly_use_front_steering
                                                        ? 5
                                                        : 0;

// The length of the lower horizontal part of the (curved) axle shaft that is
// inserted into the wheel hub
knuckle_shaft_lower_horiz_len                 = 27;

// The height of the upper pins on each side of the frame onto which the
// steering knuckle bearings are mounted
knuckle_pin_bearing_height                    = 8.0;

// The height of the chamfer at the top of the bearing pin
knuckle_pin_chamfer_height                    = 2.5;

// The height of the lower pins on each side of the frame that have bearing pins
// at the top
knuckle_pin_lower_height                      = 5.6;

// The height of the wider lower part of the pin that prevents contact between
// the bearing and the frame
knuckle_pin_stopper_height                    = 1;

// The length of the rotated shaft that connects the knuckle with the bracket
// steering_knuckle_bracket_connector_len          = 12.2;

// The height (thickness) of the knuckle connector with the 685-Z bearing that
// is connected to the rack link
knuckle_rack_link_arm_height                  = 6;

knuckle_tie_rod_shaft_arm_len                 = 12.4;

// ─────────────────────────────────────────────────────────────────────────────
// Steering servo
// ─────────────────────────────────────────────────────────────────────────────
// Dimensions for the slot that accommodates the steering servo motor.
// Tested with the EMAX ES08MA II servo (23 x 11.5 x 24 mm).
//
// The popular SG90 servo measures approximately 23mm x 12.2mm x 29mm, so you
// may want to adjust steering_servo_slot_width and steering_servo_slot_height
// as needed.

steering_servo_slot_width                     = 12;
steering_servo_slot_height                    = 23.6;
steering_servo_size                           = [23.48, 11.7, 20.3];

// offset between the servo slot and the fastening bolts
steering_servo_bolts_offset                   = 1;

steering_servo_flange_w                       = 33;
steering_servo_flange_h                       = steering_servo_size[1];
steering_servo_flange_thickness               = 1.6;
steering_servo_flange_z_offset                = 4;
steering_servo_gearbox_x_offset               = 3;
steering_servo_gearbox_mode                   = "hull";
steering_servo_text                           = pan_servo_text;
steering_servo_text_plist                     = pan_servo_text_plist;
steering_servo_text_size                      = 3;
steering_servo_gearbox_h                      = 4;
steering_servo_gearbox_size                   = [[0.4, 6.09, matte_black],
                                                        [0.5, 4.35, dark_gold_2, 8],
                                                        [0.8, 2, dark_gold_2],
                                                        [2.45, 4, dark_gold_2, 10],
                                                        [0.05, 2.6, licorice, 8]];
steering_servo_gearbox_d1                     = 8;

steering_servo_gearbox_d2                     = 6;
steering_servo_color                          = jet_black;
steering_servo_cut_len                        = 3;

// ─────────────────────────────────────────────────────────────────────────────
// Steering panel
// ─────────────────────────────────────────────────────────────────────────────

// The length of the panel that holds the rack and the pins for the steering
// knuckles at each side
steering_panel_length                         = 134;

// The width of the panel that holds the rack and the pins for the steering
// knuckles at each side
steering_rack_support_width                   = 8;

// The diameter of the fastening bolts for the servo
steering_servo_bolt_dia                       = 2;

// The thickness of the panel that holds the rack and the pins for the steering
// knuckles at each side
steering_rack_support_thickness               = 5;

// The thickness of the vertical panel with the servo slot
steering_vertical_panel_thickness             = 3;

// Position of the steering panel relative to the chassis center. This panel
// houses the rack and pinion assembly implementing Ackermann steering geometry
// for the wheels.

steering_panel_distance_from_top              = 70; // position from the start of the chassis
steering_panel_hinge_length                   = 10;
steering_panel_hinge_w                        = 8;
steering_panel_hinge_x_offset                 = 1;
steering_panel_hinge_corner_rad               = 0.5;
steering_panel_hinge_bolt_dia                 = m25_hole_dia;
steering_panel_hinge_bore_dia                 = steering_panel_hinge_bolt_dia * 2;
steering_panel_hinge_chassis_bore_dia         = steering_panel_hinge_bolt_dia * 2.2;
steering_panel_hinge_bore_h                   = chassis_counterbore_h;
steering_panel_hinge_bolt_head_type           = "pan";

steering_panel_hinge_bolt_distance            = 1;
steering_panel_hinge_bolt_x_distance          = 1;

// ─────────────────────────────────────────────────────────────────────────────
// Rack and Pinion
// ─────────────────────────────────────────────────────────────────────────────

// Length of the toothed section of the steering rack (excluding side connectors)
steering_rack_teethed_length                  = 45.5;

// The width of the steering rack
steering_rack_width                           = 6;

steering_rack_z_distance_from_panel           = 1;

// The height of the steering rack, excluding the height of the teeth
steering_rack_base_height                     = 7.4;

// The height of the cylindrical pedestals on each side of the rack onto which
// the bearing shaft that connects with the bracket’s bearing is placed
steering_rack_pin_base_height                 = 5;

// The diameter of the steering pinion
steering_pinion_d                             = 28.8;

// The diameter of the hole for the servo at the center of the pinion
steering_pinion_center_hole_dia               = 6.5;

// Thickness of the pinion
steering_pinion_thickness                     = 2;

// The diamater of the screw holes for the servo arm around the steering_pinion_center_hole_dia
steering_pinion_screw_dia                     = 1.5;

// Number of teeth on the pinion
steering_pinion_teeth_count                   = 24;

steering_pinion_bolts_spacing                 = 0.5;

steering_pinion_bolts_servo_distance          = 0.8;
steering_pinion_clearance                     = 0.1;
steering_pinion_backlash                      = 0.05;

// The number of degrees of the straightness of the tooth
steering_pinion_pressure_angle                = 20;

// The height of the wider part of the shaft on the L-bracket connector and the
// rack connector. In the first case, this prevents friction between the knuckle
// and the bracket, and in the second case, between the bracket and the rack.
steering_rack_link_bearing_stopper_height     = 1;

// The height of the shaft on the L-bracket connector that is inserted into the
// 685-Z bearing on the knuckle
steering_rack_link_bearing_pin_height         = 5;

// The height of the cylindrical pedestal on which the bearing shaft is placed
// on the bracket
steering_rack_link_bearing_bearing_pin_base_h = 5;

// The outside diameter of the flanged bearing 693 ZZ / 2Z (3x8x4) that is
// inserted into the bearing connector
steering_rack_link_bearing_outer_d            = 10.0;

// The outside diameter of the flanged bearing 693 ZZ / 2Z (3x8x4) that is
// inserted into the bearing connector
steering_rack_link_bearing_d                  = 8.0;

// The inside diameter (plus tolerance) of the flanged 693 2Z bearing (3x8x4)
steering_rack_link_bearing_shaft_d            = 3.05;

// The height of the bearing placeholder in the bracket assembly
steering_rack_link_bearing_height             = 4;

// The height of the flanges of the bearing placeholder in the bracket assembly
steering_rack_link_bearing_flanged_height     = 0.5;

// The width of the flanges of the bearing placeholder in the bracket assembly
steering_breacket_bearing_flanged_width       = 0.5;

// The width of the L-bracket connector
steering_rack_link_linkage_width              = 5;

// The thickness of the L-bracket connector
steering_rack_link_linkage_thickness          = steering_rack_link_bearing_bearing_pin_base_h;

// The length of the rail in the center of the steering panel that holds the rack
steering_panel_rail_len                       = steering_panel_length
                                                       - knuckle_dia * 2;

steering_panel_rail_rad                       = 0.5;

// The height of the rails at the center of the steering panel that holds the rack
steering_panel_rail_height                    = min(4,
                                                           steering_rack_base_height - 1);

// The tolerance to add to the hole for the rail
steering_rack_rail_tolerance                  = 0.7;

// The thickness of the rail in the center of the steering panel that holds the rack
steering_panel_rail_thickness                 = 2.8;

// The angle of the rail's dovetail rib in the center of the steering panel that holds the rack
steering_panel_rail_angle                     = 30;

steering_rail_edge_land                       = 0.45;

steering_rail_relief_depth                    = 0.12; // 0.12…0.15

steering_rack_anti_tilt_key_thickness         = 0.8;
steering_rack_anti_tilt_rack_x_offset         = -0.3;
steering_rack_anti_tilt_key_height            = steering_rack_z_distance_from_panel + 0.1;

steering_kingpin_post_bolt_dia                = m25_hole_dia;
steering_kingpin_post_border_w                = 2;
steering_kingpin_post_bolt_head_type          = "pan";

steering_servo_bolt_distance_from_top         = 1;
steering_servo_mount_width                    = 23.5;
steering_servo_mount_height                   = 39.5;
steering_servo_mount_length                   = 5.5;
steering_servo_mount_connector_length         = 2.5;
steering_servo_mount_connector_thickness      = steering_rack_support_thickness  * 0.65;
steering_servo_mount_connector_bolt_dia       = m3_hole_dia;
steering_servo_mount_connector_bolt_x         = 3;
steering_servo_mount_connector_bolt_head_type = "pan";

// Knuckle center along X. Do not edit, used for Ackermann geometry calculations
steering_x_left_knuckle                       = -steering_panel_length / 2
                                                       + knuckle_dia / 2;

// Diameter and width of the tie rod
tie_rod_outer_dia                             = 14.0;

// The outside diameter of the 685-Z bearing (5x11x5) that is inserted into the
// tie rod
tie_rod_bearing_outer_dia                     = 11.0;

// The inside diameter (plus tolerance) of the 685-Z bearing (5x11x5).
// They are placed on the each side of the steering panel
tie_rod_bearing_inner_dia                     = 5.20;

// The height of the 685-Z bearing placeholder used in the tie rod assembly
tie_rod_bearing_height                        = 5;

// The height of the flange of the 685-Z bearing placeholder
tie_rod_bearing_flanged_height                = 0.5;

// The width of the 685-Z bearing placeholder used in the tie rod assembly
tie_rod_bearing_flanged_width                 = 0.5;

// The thickness of the tie rod
tie_rod_thickness                             = tie_rod_bearing_height + 0.5;

tie_rod_bearing_x_offset                      = 2;

tie_rod_shaft_dia                             = 8.0;

tie_rod_shaft_knuckle_arm_dia                 = tie_rod_shaft_dia * 1.4;
tie_rod_shaft_bolt_dia                        = m2_hole_dia;
tie_rod_shaft_knuckle_cbore_dia               = m2_pan_head_dia + 0.2;
tie_rod_shaft_bolt_offset                     = 1;
tie_rod_shaft_bolt_distance                   = 2.0;
tie_rod_shaft_len                             = knuckle_shaft_vertical_len + 6;

tie_rod_shaft_knuckle_arm_height              = 9;
tie_rod_shaft_bearing_pin_height              = 8;
tie_rod_shaft_bearing_pin_chamfer_height      = 1.5;

// ─────────────────────────────────────────────────────────────────────────────
// Ackermann geometry computed. You're unlikely to need to edit this.
// ─────────────────────────────────────────────────────────────────────────────

// center of the left wheel
wheel_center_offset                           = wheel_w / 2 +
                                                       (wheel_rear_shaft_protrusion_height
                                                        - (knuckle_shaft_dia / 2));

// distance between centers of the front wheels
wheels_track_width                            = steering_panel_length
                                                       + (wheel_center_offset * 2)
                                                       - knuckle_shaft_dia / 2;

// The full lateral length of the knuckle tie-rod arm.
// This value is used as the side length of the Ackermann trapezoid when computing
// the required tie-rod top width for a given steering angle.
steering_arm_full_len = calc_knuckle_connector_full_len(length=knuckle_tie_rod_shaft_arm_len,
                                                        parent_dia=knuckle_dia,
                                                        outer_d=tie_rod_shaft_knuckle_arm_dia,
                                                        border_w=knuckle_border_w)
                        + knuckle_dia / 2
                        - knuckle_border_w
                        + ((tie_rod_shaft_knuckle_arm_dia - tie_rod_shaft_dia) / 2) / 2;

// Do not edit, used for Ackermann geometry calculations
steering_rack_link_bearing_border_w           = (steering_rack_link_bearing_outer_d
                                                        - steering_rack_link_bearing_d)
                                                       / 2;

// X-coordinate of the steering-rack bearing connector center
steering_rack_connector_x_pos                 = -steering_rack_teethed_length
                                                        / 2
                                                       - steering_rack_link_bearing_outer_d
                                                       / 2
                                                       + steering_rack_link_bearing_border_w;

// X-axis distance between the kingpin post and the steering-rack bearing connector center
steering_distance_between_kingpin_and_rack    = abs(steering_x_left_knuckle)
                                                       - abs(steering_rack_connector_x_pos);

// The length of the L-bracket part that is connected to the rack
steering_rack_link_rack_side_h_length         = knuckle_shaft_connector_extra_len
                                                       + knuckle_shaft_connector_dia
                                                       + knuckle_shaft_connector_extra_arm_len
                                                       + steering_rack_link_bearing_outer_d / 2
                                                       + steering_rack_link_bearing_border_w;

// The length of the L-shaped rack link that is connected to the knuckle
steering_rack_link_rack_side_w_length         = steering_distance_between_kingpin_and_rack
                                                       - steering_rack_link_bearing_d
                                                       - steering_rack_link_bearing_border_w;

// wheelbase, calculated from the center of the rear axle
steering_wheelbase_effective                  = abs(chassis_len
                                                           - steering_panel_distance_from_top
                                                           - n20_motor_bolts_panel_len / 2
                                                           - n20_motor_chassis_y_distance);

// The angle of the tie-rod arms that forms the Ackermann trapezoid
steering_angle_deg                            = atan(abs(steering_x_left_knuckle / steering_wheelbase_effective));

// "Technical" angle of the tie-rod arms required due to the knuckle's implementation details
steering_alpha_deg                            = steering_angle_deg + 90;

// Length of the tie rod
// Distance between the bearing centers on the tie rod (Ackermann top width)
tie_rod_bearing_center_distance               = calc_isosceles_trapezoid_top_width(steering_panel_length - knuckle_dia,
                                                                                          steering_arm_full_len,
                                                                                          steering_angle_deg);

// Overall tie rod length including bearing landings and offsets
tie_rod_len                                   = tie_rod_bearing_center_distance
                                                       + tie_rod_bearing_outer_dia
                                                       + tie_rod_bearing_x_offset * 2;
