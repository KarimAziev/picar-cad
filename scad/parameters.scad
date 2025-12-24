/**
 * Module: Parameters
 * This file defines most of the robot parameters
 * All dimensions are in millimeters (mm)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <colors.scad>

use <lib/functions.scad>
use <steering_system/knuckle_util.scad>

assembly_use_front_steering                      = false;
assembly_shaft_use_front_steering                = true;

// ─────────────────────────────────────────────────────────────────────────────
// ATC ATO Blade Fuse Holder
// ─────────────────────────────────────────────────────────────────────────────

atc_ato_blade_fuse_holder_top_cover_h            = 35.3;
atc_ato_blade_fuse_holder_top_cover_w            = 27.10;
atc_ato_blade_fuse_holder_top_cover_thickness    = 13.9;
atc_ato_blade_fuse_holder_top_rad                = 5;

atc_ato_blade_fuse_holder_top_joint_h            = 7.8;
atc_ato_blade_fuse_holder_top_joint_thickness    = 1.5;

atc_ato_blade_mounting_wall_h                    = 17.45;
atc_ato_blade_mounting_wall_w                    = 25.0;
atc_ato_blade_mounting_wall_thickness            = 3.30;

atc_ato_blade_fuse_y_distance                    = 33.0;

atc_ato_blade_fuse_holder_bottom_cover_h         = 12.22;
atc_ato_blade_fuse_holder_bottom_cover_w         = 24;
atc_ato_blade_fuse_holder_bottom_cover_thickness = 14.56;
atc_ato_blade_fuse_holder_bottom_rad             = 5;

// ─────────────────────────────────────────────────────────────────────────────
// Inline ATM fuse holder
// ─────────────────────────────────────────────────────────────────────────────

atm_fuse_holder_body_thickness                   = 11.60;
atm_fuse_holder_body_bottom_l                    = 20.42;
atm_fuse_holder_body_top_l                       = 25.5;
atm_fuse_holder_body_h                           = 11.90;

atm_fuse_holder_lid_thickness                    = 10.50;
atm_fuse_holder_lid_top_l                        = 20.93;
atm_fuse_holder_lid_bottom_l                     = 25.66;
atm_fuse_holder_lid_h                            = 19.50;

atm_fuse_holder_body_wiring_d                    = 3.8;

atm_fuse_holder_body_rib_l                       = 9.8;
atm_fuse_holder_body_rib_h                       = 5.00;
atm_fuse_holder_body_rib_n                       = 3;
atm_fuse_holder_body_rib_distance                = 2;
atm_fuse_holder_body_rib_thickness               = 1.415;

atm_fuse_holder_lid_rib_l                        = 9.8;
atm_fuse_holder_lid_rib_h                        = 6.06;
atm_fuse_holder_lid_rib_n                        = 3;
atm_fuse_holder_lid_rib_distance                 = 2;
atm_fuse_holder_lid_rib_thickness                = 1.415;

atm_fuse_holder_mounting_hole_l                  = 21.8;
atm_fuse_holder_mounting_hole_h                  = 6.7;
atm_fuse_holder_mounting_hole_depth              = 5.2;
atm_fuse_holder_mounting_hole_r                  = 2.8;

atm_fuse_holder_2_body_wiring_d                  = 3.8;
atm_fuse_holder_2_body_bottom_l                  = 28.50;
atm_fuse_holder_2_body_top_l                     = 28.9;
atm_fuse_holder_2_body_h                         = 15.070;
atm_fuse_holder_2_body_thickness                 = 12.20;

atm_fuse_holder_2_lid_thickness                  = 11.60;
atm_fuse_holder_2_lid_top_l                      = 23.07;
atm_fuse_holder_2_lid_bottom_l                   = 24.60;
atm_fuse_holder_2_lid_h                          = 21.64;

atm_fuse_holder_2_body_rib_thickness             = 1.415;
atm_fuse_holder_2_body_rib_h                     = 10.00;
atm_fuse_holder_2_body_rib_l                     = 19.03;
atm_fuse_holder_2_body_rib_n                     = 5;
atm_fuse_holder_2_body_rib_distance              = 3;

atm_fuse_holder_2_lid_rib_thickness              = 1.415;
atm_fuse_holder_2_lid_rib_h                      = 14.30;

atm_fuse_holder_2_lid_rib_l                      = 13.3;
// numer of the ribs
atm_fuse_holder_2_lid_rib_n                      = 7;
atm_fuse_holder_2_lid_rib_distance               = 6.22;

atm_fuse_holder_2_mounting_hole_l                = 22.0;
atm_fuse_holder_2_mounting_hole_h                = 8.0;
atm_fuse_holder_2_mounting_hole_depth            = 5.2;
atm_fuse_holder_2_mounting_hole_r                = 5.0;

// ─────────────────────────────────────────────────────────────────────────────
// Fusers holder
// ─────────────────────────────────────────────────────────────────────────────
fuse_panel_row_gap                               = 2;
fuse_panel_thickness                             = 3;
fuse_panel_default_toggle_switch_spec            = ["slot",
                                                    [atm_fuse_holder_2_mounting_hole_h + 2,
                                                     atm_fuse_holder_2_mounting_hole_l + 1,
                                                     atm_fuse_holder_2_mounting_hole_r,
                                                     atm_fuse_holder_2_mounting_hole_depth],
                                                    "body",
                                                    [atm_fuse_holder_2_body_top_l,
                                                     atm_fuse_holder_2_body_bottom_l,
                                                     atm_fuse_holder_2_body_thickness,
                                                     atm_fuse_holder_2_body_h,
                                                     matte_black_2],
                                                    "body_ribs",
                                                    [atm_fuse_holder_2_body_rib_l,
                                                     atm_fuse_holder_2_body_rib_h,
                                                     atm_fuse_holder_2_body_rib_n,
                                                     atm_fuse_holder_2_body_rib_distance,
                                                     atm_fuse_holder_2_body_rib_thickness],
                                                    "lid",
                                                    [atm_fuse_holder_2_lid_top_l,
                                                     atm_fuse_holder_2_lid_bottom_l,
                                                     atm_fuse_holder_2_lid_thickness,
                                                     atm_fuse_holder_2_lid_h,
                                                     matte_black_2],
                                                    "lid_ribs",
                                                    [atm_fuse_holder_2_lid_rib_l,
                                                     atm_fuse_holder_2_lid_rib_h,
                                                     atm_fuse_holder_2_lid_rib_n,
                                                     atm_fuse_holder_2_lid_rib_distance,
                                                     atm_fuse_holder_2_lid_rib_thickness]];

fuse_panels_specs                                = [(fuse_panel_default_toggle_switch_spec),
                                                    fuse_panel_default_toggle_switch_spec,
                                                    fuse_panel_default_toggle_switch_spec,];

m1_hole_dia                                      = 1.2; // M1 bolt hole diameter
m2_hole_dia                                      = 2.4; // M2 bolt hole diameter
m25_hole_dia                                     = 2.6; // M2.5 bolt hole diameter
m3_hole_dia                                      = 3.2; // M3 bolt hole diameter

m2_pan_head_dia                                  = 3.5;
m25_pan_head_dia                                 = 4.3;
m3_pan_head_dia                                  = 4.8;

m2_pan_head_h                                    = 1.38;
m25_pan_head_h                                   = 1.6;
m3_pan_head_h                                    = 1.5;

m2_round_head_dia                                = 3.5;
m25_round_head_dia                               = 5.2;
m3_round_head_dia                                = 5.62;
m2_round_head_h                                  = 1.38;
m25_round_head_h                                 = 2.10;
m3_round_head_h                                  = 2.90;

m2_countersunk_head_dia                          = 3.5;
m25_countersunk_head_dia                         = 4.04;
m3_countersunk_head_dia                          = 6.50;
m2_countersunk_head_h                            = 1.38;
m25_countersunk_head_h                           = 1.1;
m3_countersunk_head_h                            = 1.7;

m2_hex_head_dia                                  = 3.5;
m25_hex_head_dia                                 = 5.2;
m3_hex_head_dia                                  = 5.62;
m2_hex_head_h                                    = 1.38;
m25_hex_head_h                                   = 2.10;
m3_hex_head_h                                    = 2.90;

m2_nut_dia                                       = 3.95;
m2_nut_h                                         = 1.74;
m25_nut_dia                                      = 4.92;
m25_nut_h                                        = 1.98;
m3_nut_dia                                       = 5.5;
m3_nut_h                                         = 2.34;

m2_lock_nut_dia                                  = 3.95;
m2_lock_nut_h                                    = 2.96;
m25_lock_nut_dia                                 = 4.92;
m25_lock_nut_h                                   = 3.52;
m3_lock_nut_dia                                  = 5.5;
m3_lock_nut_h                                    = 4.0;

bolt_specs                                       = [[1,
                                                     ["nut", ["outer_dia", m2_nut_dia * 0.8,
                                                              "height", m2_nut_h * 0.9],
                                                      "lock_nut", ["outer_dia", m2_lock_nut_dia * 0.8,
                                                                   "height", m2_lock_nut_h * 0.9,
                                                                   "color", metallic_silver_2],
                                                      "colors", ["hex", matte_black,
                                                                 "pan", metallic_silver_2,
                                                                 "countersunk", metallic_silver_1,
                                                                 "round", matte_black],
                                                      "head", ["pan", ["dia", m2_pan_head_dia * 0.7,
                                                                       "height", m2_pan_head_h],
                                                               "hex", ["dia", m2_hex_head_dia  * 0.7,
                                                                       "height", m2_hex_head_h],
                                                               "round", ["dia", m2_round_head_dia  * 0.7,
                                                                         "height", m2_round_head_h],
                                                               "countersunk", ["dia", m2_countersunk_head_dia  * 0.7,
                                                                               "height", m2_countersunk_head_h]]]],
                                                    [3,
                                                     ["nut", ["outer_dia", m3_nut_dia,
                                                              "height", m3_nut_h],
                                                      "lock_nut", ["outer_dia", m3_lock_nut_dia,
                                                                   "height", m3_lock_nut_h,
                                                                   "color", metallic_silver_2],
                                                      "colors", ["hex", matte_black,
                                                                 "pan", metallic_silver_2,
                                                                 "countersunk", metallic_silver_1,
                                                                 "round", matte_black],
                                                      "head", ["pan", ["dia", m3_pan_head_dia,
                                                                       "height", m3_pan_head_h],
                                                               "hex", ["dia", m3_hex_head_dia,
                                                                       "height", m3_hex_head_h],
                                                               "round", ["dia", m3_round_head_dia,
                                                                         "height", m3_round_head_h],
                                                               "countersunk", ["dia", m3_countersunk_head_dia,
                                                                               "height", m3_countersunk_head_h]],
                                                      "heights", [2, 4, 6, 10, 12, 14, 16]]],
                                                    [2,
                                                     ["nut", ["outer_dia", m2_nut_dia,
                                                              "height", m2_nut_h],
                                                      "lock_nut", ["outer_dia", m2_lock_nut_dia,
                                                                   "height", m2_lock_nut_h,
                                                                   "color", metallic_silver_2],
                                                      "colors", ["hex", matte_black,
                                                                 "pan", metallic_silver_2,
                                                                 "countersunk", metallic_silver_1,
                                                                 "round", matte_black],
                                                      "head", ["pan", ["dia", m2_pan_head_dia,
                                                                       "height", m2_pan_head_h],
                                                               "hex", ["dia", m2_hex_head_dia,
                                                                       "height", m2_hex_head_h],
                                                               "round", ["dia", m2_round_head_dia,
                                                                         "height", m2_round_head_h],
                                                               "countersunk", ["dia", m2_countersunk_head_dia,
                                                                               "height", m2_countersunk_head_h]],
                                                      "heights", [2, 4, 6, 10, 12, 14, 16]]],
                                                    [2.5,
                                                     ["nut", ["outer_dia", m25_nut_dia,
                                                              "height", m25_nut_h],
                                                      "lock_nut", ["outer_dia", m25_lock_nut_dia,
                                                                   "height", m25_lock_nut_h,
                                                                   "color", metallic_silver_2],
                                                      "colors", ["hex", matte_black,
                                                                 "pan", metallic_silver_2,
                                                                 "countersunk", metallic_silver_1,
                                                                 "round", matte_black],
                                                      "head", ["pan", ["dia", m25_pan_head_dia,
                                                                       "height", m25_pan_head_h],
                                                               "hex", ["dia", m25_hex_head_dia,
                                                                       "height", m25_hex_head_h],
                                                               "round", ["dia", m25_round_head_dia,
                                                                         "height", m25_round_head_h],
                                                               "countersunk", ["dia", m25_countersunk_head_dia,
                                                                               "height", m25_countersunk_head_h]],
                                                      "heights", [2, 4, 6, 10, 12, 14, 16]]]];

panel_stack_bolt_dia                             = m3_hole_dia;
panel_stack_bolt_cbore_dia                       = panel_stack_bolt_dia * 2;
panel_stack_corner_radius_factor                 = 0.05;
panel_stack_bolt_padding                         = 2;
panel_stack_padding_x                            = 2;
panel_stack_padding_y                            = 1;

chassis_panel_stack_x_offset                     = 0;
chassis_panel_stack_y_offset                     = 1;
chassis_panel_stack_orientation                  = "horizontal"; // [horizontal, vertical]

control_panel_row_gap                            = 0.8;

// Each element is a list of: [diameter, body diameter, thread height, [body heights], number of vertices, color]
standoff_specs                                   = [["thread_d", 3,
                                                     "body_d", 5.20,
                                                     "thread_h", 5,
                                                     "body_heights", [20, 15, 10, 9, 8, 6, 5],
                                                     "fn", 6],
                                                    ["thread_d", 2.5,
                                                     "body_d", 4.20,
                                                     "thread_h", 4,
                                                     "body_heights", [20, 15, 10, 9, 8, 6, 5],
                                                     "fn", 6],
                                                    ["thread_d", 2,
                                                     "body_d", 3.0,
                                                     "thread_h", 3.0,
                                                     "body_heights", [20, 15, 10, 9, 8, 6, 5],
                                                     "fn", 12]];

// ─────────────────────────────────────────────────────────────────────────────
// Battery holder at the top of the chassis behind Raspberry Pi
// (defaults dimensions are for Uninterruptible Power Supply Module 3S
// https://www.waveshare.com/ups-module-3s.html)
// ─────────────────────────────────────────────────────────────────────────────
battery_ups_size                                 = [93, 60, 1.82];
battery_ups_holder_size                          = [77.8, 60, 22.0];
battery_ups_holder_thickness                     = 1.86;

// Y offset for the UPS HAT slot, measured from the end of the chassis
battery_ups_offset                               = 2;

// The Y and X dimensions of the bolt positions for the UPS HAT slot.
// This forms a square with a bolt hole centered on each corner.
battery_ups_module_bolt_spacing                  = [86, 46];

battery_ups_module_bolts_enabled                 = false;

// the diameter for fastening bolts
battery_ups_bolt_dia                             = m3_hole_dia;

// ─────────────────────────────────────────────────────────────────────────────
// Battery holders under the case
// ─────────────────────────────────────────────────────────────────────────────

// Starting Y-offset for extra battery bolts
battery_bolts_y_start                            = -30;

// Ending Y-offset for extra battery bolts
battery_bolts_y_offset_end                       = 0;

// Step/increment along the Y-axis for extra battery bolts
battery_bolts_y_offset_step                      = 10;

// Dimensions for the bolt hole pattern (width, height)
battery_holder_bolt_holes_size                   = [20, 10]; // [width, height] of the bolt pattern

// Diameter of the bolt holes
battery_holder_bolt_dia                          = m25_hole_dia;

// Number of fragments for rendering circle (defines resolution)
battery_bolts_fn_val                             = 360;

// X-offset for positioning bolts relative to the center
battery_bolts_x_offset                           = 24;

// Y offsets for positioning bolts relative to the center

battery_holes_y_positions                        = [];

smd_battery_holder_bolts_x_offset                = 31.5;
smd_battery_holder_bolts_y_offset                = 21;

// ─────────────────────────────────────────────────────────────────────────────
// 16850 battery dimensions
// ─────────────────────────────────────────────────────────────────────────────
battery_dia                                      = 18;
battery_height                                   = 65.0;
battery_positive_pole_height                     = 1.5;
battery_positive_pole_dia                        = 5.63;

// ─────────────────────────────────────────────────────────────────────────────
// Battery holder dimensions
// ─────────────────────────────────────────────────────────────────────────────
battery_holder_thickness                         = 1.82;
battery_holder_batteries_count                   = 2;

smd_battery_holder_length                        = 77.32;
smd_battery_holder_height                        = 14.92;
smd_battery_holder_bottom_thickness              = 1.2;
smd_battery_holder_front_rear_thickness          = 3.6;
smd_battery_holder_inner_thickness               = 0.9;
smd_battery_holder_side_thickness                = 1.8;

smd_battery_holder_bolt_dia                      = m3_hole_dia;
smd_battery_holder_bolt_recess_size              = [9, 5, 2];
smd_battery_holder_bolt_spacing                  = [0, 56.0];
smd_battery_holder_batteries_count               = 2;
smd_battery_holder_inner_cutout_size             = [9.0, 66.6];
smd_battery_holder_inner_side_h                  = 10;

smd_battery_holder_chassis_specs                 = [[[[smd_battery_holder_bolt_spacing[0],
                                                       smd_battery_holder_bolt_spacing[1],],
                                                      smd_battery_holder_bolt_dia,
                                                      [smd_battery_holder_length / 2,
                                                       smd_battery_holder_bolts_x_offset + 2,
                                                       smd_battery_holder_bolts_y_offset],]],
                                                    [[[smd_battery_holder_bolt_spacing[0],
                                                       smd_battery_holder_bolt_spacing[1],],
                                                      smd_battery_holder_bolt_dia,
                                                      [smd_battery_holder_length / 2,
                                                       -smd_battery_holder_bolts_x_offset,
                                                       smd_battery_holder_bolts_y_offset],]]];

// ─────────────────────────────────────────────────────────────────────────────
// Camera's placeholder dimensions
// ─────────────────────────────────────────────────────────────────────────────
camera_w                                         = 25;
camera_h                                         = 24;
camera_thickness                                 = 1.05;
camera_lens_items                                = [[8.05, 8.05, 1.0, matte_black, "cube"],
                                                    [11.05, 11.05, 1.5, matte_black, "cube"],
                                                    [11.05, 11.05, 2.9, metallic_silver_7, "cube"],
                                                    [11.05, 11.05, 0.5, metallic_silver_8, "octagon"],
                                                    [7.15, 0, 3.03, matte_black,
                                                     "circle", 30],
                                                    [3.03, 0, 0.1, cobalt_blue_metallic,
                                                     "circle", 15]];

camera_lens_connectors                           = [[6.0, 3.2, 1.5, matte_black, "cube"],
                                                    [6.0, 0.5, 1.5, "darkgoldenrod", "cube"],
                                                    [8.0, 4.0, 1.5, onyx, "cube", -1]];

camera_lens_distance_from_top                    = 9;
camera_bolt_hole_dia                             = 2.0;
camera_offset_rad                                = 2.0;
camera_holes_size                                = [21, 12.5];
camera_holes_distance_from_top                   = 1;

camera_module_ffc_zif_len                        = 21;
camera_module_ffc_zif_inner_len                  = 19.7;
camera_module_ffc_zif_thickness                  = 2.2;
camera_module_ffc_inner_thickness                = 1.8;
camera_module_ffc_zif_base_h                     = 1.2;
camera_module_ffc_zif_h                          = 3.2;
camera_module_socket_base_h                      = 3.3;
camera_module_socket_upper_h                     = 1.4;
camera_module_socket_thickness                   = 2.7;
camera_module_socket_y_offset                    = 1;

/* [Chassis dimensions] */
// width of the chassis body
/* [Chassis dimensions] */

// Length of the upper chassis (holds the head with cameras and steering system)
chassis_upper_len                                = 105;  // [120.0:300.0]

// Length of the chassis neck (connects the wide base to the narrower upper section)
chassis_transition_len                           = 25;  // [1.0:100.0]

// Length of the main body (houses motors, batteries, and electronics)
chassis_body_len                                 = 156; // [120.0:300.0]

// Width of the upper chassis (holds the head with cameras and steering system)
chassis_upper_w                                  = 27;  // [20.0:200.0]

// Width of the chassis neck (connects the wide base to the narrower upper section)
chassis_transition_w                             = 68;  // [27.0:250.0]

// Width of the main body (houses motors, batteries, and electronics)
chassis_body_w                                   = 125; // [100.0:300.0]

// Thickness of the chassis
chassis_thickness                                = 4.0; // [2.0:10.0]

// Amount by which to offset the chassis
chassis_offset_rad                               = 3;   // [0.0:5]

/* [Hidden] */
chassis_len                                      = sum([chassis_upper_len,
                                                        chassis_transition_len,
                                                        chassis_body_len]);
chassis_body_half_w                              = chassis_body_w / 2;
chassis_transition_half_w                        = chassis_transition_w / 2;
chassis_upper_half_w                             = chassis_upper_w / 2;

chassis_connector_w                              = chassis_body_w - 10;
chassis_use_connector                            = false;
chassis_connector_len                            = 6;
chassis_connector_height                         = 2.2;
chassis_connector_w_clearance                    = 0.5;
chassis_connector_len_clearance                  = 0.4;

chassis_connector_dia                            = m3_hole_dia;

chassis_connector_edge_distance                  = 1.5;
chassis_connector_bolt_positions                 = [50, 25, 0];

chassis_lower_cutout_pts                         = [[0, 0],
                                                    [26, 0],
                                                    [38.25, 5],
                                                    [44.25, 5],
                                                    [chassis_body_half_w - 10, 0],
                                                    [chassis_body_half_w, 5],
                                                    [chassis_body_half_w, 6]];

chassis_upper_pts                                = [[0, 0],
                                                    [chassis_transition_half_w, 0],
                                                    [chassis_upper_half_w, chassis_upper_len],
                                                    [0, chassis_upper_len]];

chassis_transition_pts                           = [[0, 0],
                                                    [chassis_body_half_w, 0],
                                                    [chassis_transition_half_w, chassis_transition_len],
                                                    [0, chassis_transition_len]];

chassis_counterbore_h                            = 2.2; // The amount by which to offset the chassis

// ─────────────────────────────────────────────────────────────────────────────
// Chassis shape
// ─────────────────────────────────────────────────────────────────────────────

// The half of the width is used because the polygon will be mirrored.
chassis_shape_base_width                         = chassis_body_w / 2;

chassis_shape_rear_panel_base_w                  = 26.0;

chassis_trapezoid_hole_width                     = 7.5;
chassis_trapezoid_hole_len                       = 11.0;

// distance from the side of the chassis
chassis_trapezoid_hole_x_distance                = 2;

chassis_trapezoid_border_height                  = 1;

chassis_side_hole_border_w                       = 0.8;
chassis_side_hole_border_h                       = 0.8;

// diameter of the pan servo mounting hole at the front of the chassis
chassis_pan_servo_slot_dia                       = 6.5;

// The depth of the cross-shaped recess in the chassis for mounting the steering
// servo and its horn (either a vertical one or also cross-shaped).
chassis_pan_servo_slot_recess                    = constraint(2.0, 0, chassis_thickness - 1);

chassis_pan_servo_top_ribbon_cuttout_len         = min(18, chassis_upper_w * 0.8);
chassis_pan_servo_top_ribbon_cuttout_h           = 2;

upper_chassis_holes_border_w                     = chassis_side_hole_border_w;
chassis_upper_front_padding_y                    = 2;

chassis_head_zone_y_offset                       = 0; // position of the head on Y axle

chassis_top_most_holes_side_y_offset             = -1.5;
chassis_top_most_holes_side_w                    = 10.0;
chassis_top_most_holes_side_len                  = 5;
chassis_top_most_holes_gap                       = 2.5;
chassis_top_most_holes_margin                    = 1;
chassis_top_most_holes_rows                      = 2;

chassis_pan_servo_recesess_y_len                 = 14;
chassis_pan_servo_recesess_x_len                 = 16;
chassis_pan_servo_recesess_thickness             = 5;
// diameter of the screw holes along pan servo slot
chassis_pan_servo_screw_d                        = 1.5;
// the distance between screw holes along pan servo slot
chassis_pan_servo_screws_gap                     = 0.5;
chassis_pan_servo_rib_slots_rows                 = 3;
chassis_pan_servo_rib_slots_gap                  = 3;
chassis_pan_servo_rib_slots_len                  = 20;
chassis_pan_servo_rib_slots_thickness            = 3;
chassis_pan_servo_rib_slots_distance_from_recess = 1;
chassis_pan_servo_side_trapezoid_rows            = 2;
chassis_pan_servo_side_trapezoid_gap             = 2;

chassis_upper_side_hole_len                      = chassis_transition_len / 3;
chassis_upper_side_hole_w                        = chassis_trapezoid_hole_width;

chassis_upper_side_hole_rows                     = 2;
chasssis_upper_side_hole_gap                     = 3;
chassis_upper_side_hole_margin                   = 2;
chassis_upper_side_hole_start                    = 14;

chassis_upper_rect_holes_specs                   = [[[[32, 5, 1.0], [0, -8, 7]],  // camera ribbon holes
                                                     [[32, 5, 1.0], [0, -8, 8]],
                                                     [[32, 5, 1.0], [0, -8, 9]]]];

// ─────────────────────────────────────────────────────────────────────────────
// Front panel dimensions
// ─────────────────────────────────────────────────────────────────────────────
// This panel is vertical and includes mounting holes for the ultrasonic sensors.
// ─────────────────────────────────────────────────────────────────────────────

front_panel_width                                = 66;   // panel width
front_panel_height                               = 22.5;   // panel height
front_panel_thickness                            = 2.5;   // panel thickness
// A slight tilt of the panel with the ultrasonic sensor to prevent the sensor's
// "eyes" from dipping down into the floor.
front_panel_rotation_angle                       = 5;

front_panel_rear_panel_thickness                 = 1.5;
front_panel_connector_bolt_dia                   = m25_hole_dia;

front_panel_connector_bolt_bore_dia              = front_panel_connector_bolt_dia * 2.5;
front_panel_connector_bolt_bore_h                = min(1.5,
                                                       front_panel_thickness * 0.7);

front_panel_connector_len                        = 15;

front_panel_connector_width                      = constraint(chassis_upper_w - 2, 10, 30);
front_panel_connector_bolts_padding_y            = 1;

front_panel_connector_bolt_spacing               = [constraint(10, front_panel_connector_bolt_bore_dia * 2 + 3,
                                                               front_panel_connector_width), 0];

front_panel_connector_bolt_offsets               = [[4, 3], [-4, 3]];
front_panel_bolt_dia                             = m25_hole_dia;

// diameter of each mounting hole ("eye") for the ultrasonic sensors
front_panel_ultrasonic_sensor_dia                = 16.5;

// distance between the two ultrasonic sensor mounting holes
front_panel_ultrasonic_sensors_offset            = 10.10;

// horizontal offset between the ultrasonic sensor mounting holes
front_panel_bolts_x_offset                       = 27;

front_panel_connector_offset_rad                 = 3;
front_panel_ultrasonic_y_offset                  = 0;
front_panel_bolts_y_offst                        = 0;
front_panel_offset_rad                           = front_panel_height * 0.18;

// the diameter of the holes for four solder blobs on the back rear mount
front_panel_solder_blob_dia                      = 4.0;

// An additional cutout at the front-panel connector. Specify a two-value array
// [x, y] for a rectangular cutout of dimensions x by y; it may be used as a
// pass-through hole for an FFC cable. It is disabled by default because it
// makes the front panel more fragile.
front_panel_connector_rect_cutout_size           = [0, 0];

// the height of the deepening slot for ultrasonic
front_panel_ultrasonic_cutout_depth              = 0.8;

front_panel_rear_panel_ring_width                = 2;

// ─────────────────────────────────────────────────────────────────────────────
// Head
// ─────────────────────────────────────────────────────────────────────────────

head_camera_bolt_dia                             = m2_hole_dia;

head_camera_lens_width                           = 14;
head_camera_lens_height                          = 23;

// Dimensions of the hole for the Camera Module (lens opening).
head_camera_module_3_size                        = [head_camera_lens_width,
                                                    head_camera_lens_height];

// Dimensions for the bolt hole area of the Camera Module.
// These form a rectangle around the camera hole, with a bolt hole
// centered at each corner to secure the camera module.
head_camera_module_3_bolt_holes_size             = [head_camera_lens_width +
                                                    head_camera_bolt_dia + 4.2,
                                                    12.73];

// Vertical offset to move the bolt hole grid below the top edge
// of the camera lens hole.
head_camera_bolt_y_offset_from_camera_hole       = 2.0;

// List of camera mounting configurations.
// Each item is an array of:
// [ [lens_hole_width, lens_hole_height],
//   vertical_offset_for_bolt_holes_relative_to_camera_hole,
//   [bolt_hole_region_width, bolt_hole_region_height],
//   optional_color_for_assembly_view
//  ]
//
// To configure a single camera, remove one of the internal elements.
head_cameras                                     = [[head_camera_module_3_size,
                                                     1,
                                                     head_camera_module_3_bolt_holes_size,
                                                     green_2],
                                                    [head_camera_module_3_size,
                                                     head_camera_bolt_y_offset_from_camera_hole,
                                                     head_camera_module_3_bolt_holes_size,
                                                     noir_1]];

// Vertical distance between camera modules (center-to-center spacing).
// If more than one camera is present, a fixed spacing of 2 mm is used.
// If only one camera is mounted, use half of its height for centering.
head_cameras_y_distance                          = len(head_cameras) > 1
                                                ? 2.0
                                                : (head_cameras[0][0][1] / 2);

// Width of the front face plate where the camera modules are mounted.
head_plate_width                                 = 38;

// Height of the front face plate, automatically calculated based on
// the total height of all camera lens holes plus their vertical spacing.
// Ensures a minimum height of 40 mm.
head_plate_height                                = max(40,
                                                       sum([for (j = [0:len(head_cameras)-1])
                                                               head_cameras[j][0][1]])
                                                       + head_cameras_y_distance *
                                                       len(head_cameras) - 1);

// Thickness (depth) of all the main head plates, including front,
// top, connector, and side plates.
head_plate_thickness                             = 2;

// Diameter of the central hole in the side panel for mounting the servo motor.
head_servo_mount_dia                             = 6.5;

// Diameter of the screws used to mount the servo motor.
// The screws are placed radially around the main servo mounting hole.
head_servo_horn_screw_dia                        = 1.5;

// Height of the side panel of the head, matching the height of the front plate.
head_side_panel_height                           = head_plate_height;

// Width of the side panel, based on a scaling factor relative to front plate width
// to ensure appropriate coverage for the mounting surface.
head_side_panel_width                            = head_plate_width * 1.2;

// Don't try to find a lot of sense in the calculations of the side panel polygon, this is an aesthetic choice.
head_side_panel_top                              = -head_side_panel_height * (4 / 15);
head_side_panel_curve_start                      = head_side_panel_width * (1 / 2.1);
head_side_panel_notch_y                          = -head_side_panel_height * (7 / 14.2);
head_side_panel_bottom                           = head_side_panel_height * (1 / 4.9);
head_side_panel_curve_end                        = head_side_panel_height * (3 / 4.0);

head_side_panel_extra_slot_width                 = head_side_panel_width * 0.8;
head_side_panel_extra_slot_height                = 2;
head_side_panel_extra_slot_ypos                  = [-9, 0.2];

head_upper_plate_width                           = head_plate_width * 0.9;
head_upper_plate_height                          = 30;

head_top_slot_size                               = [head_upper_plate_width * 0.8, 2];

head_lower_connector_width                       = head_upper_plate_width * 0.6;
head_upper_connector_width                       = head_upper_plate_width * 0.7;

head_extra_side_slots_x_positions                = [head_side_panel_width * 0.25,
                                                    head_side_panel_width * 0.5,
                                                    head_side_panel_width * 0.75];
head_upper_connector_len                         = head_plate_thickness;
head_upper_connector_height                      = 4;

head_lower_connector_height                      = 2;

head_extra_holes_offset                          = 4;

head_hole_row_offsets                            = [head_extra_holes_offset * 3];

head_extra_slots_dia                             = 3;

// positions of the additional holes at the top plate

head_top_holes_x_positions                       = [-8, 0, 8];

head_top_slots_y_distance                        = 6;
head_top_plate_extra_slots_dia                   = 4;

// ─────────────────────────────────────────────────────────────────────────────
// Head neck bracket
// ─────────────────────────────────────────────────────────────────────────────
// Conceptually, this L-bracket combines:
// - A pan servo on the horizontal base that rotates the entire structure horizontally.
// - A tilt servo on the vertical plate that allows the attached head to tilt vertically.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// HEAD NECK PANEL (Horizontal Bracket Base for Pan Servo)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Width (X-dimension) of the rectangular cutout slot for the pan servo.
 * Typically matches or slightly exceeds the physical servo width.
 */
head_neck_pan_servo_slot_width                   = 23.6;

/**
 * Height (Y-dimension) of the rectangular pan servo slot.
 * Matches the thickness (depth) of the servo body horizontally.
 */
head_neck_pan_servo_slot_height                  = 12;

/**
 * Diameter of the bolt holes used to fasten the pan servo to the neck bracket.
 * Two holes are centered on the width and offset laterally.
 */
head_neck_pan_servo_bolt_dia                     = 2;

/**
 * Offset distance from the servo slot width to the bolt hole center.
 * Applies symmetrically on both sides of the slot.
 */
head_neck_pan_servo_bolts_offset                 = 1;

/**
 * Thickness of the horizontal base panel of the bracket,
 * which holds the pan servo.
 */
head_neck_pan_servo_slot_thickness               = 2.5;

/**
 * Extra width to add around the main bracket body to accommodate
 * alignment, mechanical clearance, or additional structural space.
 */
head_neck_pan_servo_extra_w                      = 4;

head_neck_pan_servo_assembly_reversed            = false;

// ─────────────────────────────────────────────────────────────────────────────
// IR LED Case parameters
// ─────────────────────────────────────────────────────────────────────────────

// Outer diameter used for the case cutout for the LED (case-side value).
// Note: this is the hole size intended for the LED in the case (may include any planned clearance).
ir_case_led_dia                                  = 19.1;

// Overall vertical size of the case part
ir_case_height                                   = 28;

// Overall horizontal size of the case part (X dimension).
ir_case_width                                    = 29;

// Base plate thickness of the case (main wall thickness).
ir_case_thickness                                = 2;

// Additional boss thickness around the LED pocket on top of ir_case_thickness.
// Used to raise the LED boss above the base plate.
ir_case_led_boss_thickness                       = 1;

// Light detector (small photodiode/receiver) diameter.
ir_light_detector_dia                            = 6.4;

// Vertical distance from the top edge where the LED + detector holes are positioned.
ir_case_holes_distance_from_top                  = 2;

// Y offset of the light detector relative to the LED center (negative moves it up).
// Positive = move detector down, Negative = move detector up (depends on coordinate system).
ir_light_offset_from_led_y                       = -1.4;

// X offset of the light detector relative to the LED center (positive -> to the right).
ir_light_offset_from_led_x                       = 0.1;

// Which side(s) the (optional) light detector hole is created on.
// Allowed values: "left" | "right" | "both"
ir_light_detector_position                       = "right"; // left | right | both

// Which side(s) the L-bracket is added on the case.
// Allowed values: "left" | "right" | "both"
ir_case_bracket_position                         = "left";  // left | right | both

// Small carriage height above the stacked case thicknesses (clearance for rail carriage).
ir_case_carriage_h                               = 1;

// Length of the carriage feature (along rail direction).
ir_case_carriage_len                             = 4;

// Wall thickness of the carriage walls.
ir_case_carriage_wall_thickness                  = 2;

// Fillet/rounding radius used for the carriage / rail corners.
// Typical small value (0..1).
ir_case_carriage_offset_rad                      = 0.8;

// Rail (slot) inner width (inside the carriage).
ir_case_rail_w                                   = 5;

// Rail (slot) inner height (thickness of the rail profile).
ir_case_rail_h                                   = 1.5;

// Height of the rail protruding above the carriage
ir_case_rail_protrusion_h                        = 1.0;

// Angle of the rail protruding above the carriage
ir_case_rail_protrusion_angle                    = 3;

// Angle of the rail protruding above the carriage
ir_case_rail_protrusion_offset_rad               = 0.2;

// Rail incline angle (degrees) used for trapezoid/angled rail profile.
ir_case_rail_angle                               = 10;

// Rail corner rounding radius.
ir_case_rail_offset_rad                          = 0.0;

// Diameter for the holes in the rail meant for M2 bolts.
ir_case_rail_bolt_dia                            = m2_hole_dia;

// Additional clearance for the rail (gap to allow slider movement).
ir_case_rail_clearance                           = 0.3;

// L-bracket width (horizontal flange) that attaches to the case.
ir_case_l_bracket_w                              = 8;

// L-bracket height (vertical flange).
ir_case_l_bracket_h                              = 20;

// L-bracket leg length (depth of bracket from case wall).
ir_case_l_bracket_len                            = 5;

// Bolt hole diameter used across the case / bracket (M2 holes).
ir_case_bolt_dia                                 = m2_hole_dia;

// X offsets for additional pan holes along the bolt row (relative offsets).
// Array of offsets in mm; used to create multiple holes along the bolt line.
ir_case_bolt_pan_holes_x_offsets                 = [0, 5];

// Actual LED physical diameter (measured component). Note: very close to ir_case_led_dia.
// Keep consistent: ir_led_dia is the real LED, ir_case_led_dia is the case cutout dimension.
ir_led_dia                                       = 19.0;

// PCB board length (long dimension of the LED board).
ir_led_board_len                                 = 27.94;

// PCB board width (short dimension of the LED board).
ir_led_board_w                                   = 19.82;

// Depth of the PCB cutout/relief in the board model (used when modeling board shape).
ir_led_board_cutout_depth                        = 3.4;

// Height of the LED cylinder part (component height).
ir_led_height                                    = 15.05;

// PCB thickness (board thickness).
ir_led_thickness                                 = 0.95;

// Height of the separate light detector cylinder (component height).
ir_led_light_detector_h                          = 8.26;

// Light detector smaller diameter (tapered detector model - one end radius).
ir_led_light_detector_dia_1                      = 5.3;

// Light detector larger diameter (tapered detector model - other end radius).
ir_led_light_detector_dia_2                      = 5.9;

// Bolt diameter used on the LED board mounting (M2).
ir_led_bolt_dia                                  = m2_hole_dia;

// Y offset of the LED center relative to the board origin in the board model.
ir_led_y_offset                                  = 2;

// Offset of the detector from the LED along the board normal direction (signed).
ir_led_light_detector_offset_from_led            = -2;

// Lateral offset of the detector relative to the LED on the board (X axis).
ir_led_light_detector_offset_x                   = 1;

// Coordinates used to position the case relative to the head side panel.
// These precomputed values sum stacked thicknesses so the case clears the side panel.
// ir_case_head_side_panel_x_2 is further from the panel than x_1.
ir_case_head_side_panel_x_2                      = + ir_case_thickness
                                                + ir_case_led_boss_thickness
                                                + ir_led_thickness
                                                + ir_led_light_detector_h / 2;
ir_case_head_side_panel_x_1                      = + ir_led_light_detector_h / 2
                                                + ir_led_height;

// Y coordinate for the first column of bolt positions (centered on the LED height).
ir_case_head_side_panel_y_1                      = -ir_led_height / 2;

// Y coordinate for the second column of bolt positions (bottom of the case).
ir_case_head_side_panel_y_2                      = -ir_case_height / 2;

// Array of four [x,y] positions used to lay out the four bolt mounting holes
// that attach the case to the head side panel. Each element is [x, y].
ir_case_head_bolts_side_panel_positions          = [[ir_case_head_side_panel_x_1,
                                                     ir_case_head_side_panel_y_1],
                                                    [ir_case_head_side_panel_x_2,
                                                     ir_case_head_side_panel_y_1],
                                                    [ir_case_head_side_panel_x_2,
                                                     ir_case_head_side_panel_y_2],
                                                    [ir_case_head_side_panel_x_1,
                                                     ir_case_head_side_panel_y_2]];

// ─────────────────────────────────────────────────────────────────────────────
// LiPo Battery Pack dimensions (4S2P configuration)
// ─────────────────────────────────────────────────────────────────────────────

lipo_pack_length                                 = 138.4; // Length of the battery pack
lipo_pack_width                                  = 47;   // Width of the battery pack
lipo_pack_height                                 = 48.4;  // Height of the battery pack

// ─────────────────────────────────────────────────────────────────────────────
// PAN SERVO CONFIGURATION (Dimensions & Visual Representation)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Physical size of the pan servo in [length (X), width (Y), height (Z)].
 * Measured as the actuator body without hat or gearbox.
 */
pan_servo_size                                   = [23.48, 11.7, 20.3];

/**
 * Distance between the slot edge and bolt center for fastening.
 * Used during visualization and mounting slot generation.
 */
pan_servo_bolts_offset                           = 1;

/**
 * Width of the "hat" (top flange) on the servo.
 * This includes mounting holes and is typically wider than the body.
 */
pan_servo_hat_w                                  = 32.11;

/**
 * Height (Y) dimension of the servo's "hat" section.
 * Equal to servo width unless asymmetrically hatched.
 */
pan_servo_hat_h                                  = pan_servo_size[1];

/**
 * Vertical thickness of the servo hat, i.e., how thick the extension flange is.
 */
pan_servo_hat_thickness                          = 1.7;

/**
 * Distance from the top of the servo body to the bottom of the hat.
 * Accounts for mechanical separation between body and hat.
 */
pan_bolts_hat_z_offset                           = 4;

/**
 * Servo label text for visualization purposes.
 * Each row is formatted as: [text_content, font_size, font_name]
 */
pan_servo_text                                   = [["EMAX", 4, "Liberation Sans:style=Bold Italic"],
                                                    ["ES08MA II ANALOG SERVO", 1.2, "Ubuntu:style=Bold"]];

/**
 * Default size to use for servo label text when specific size is not defined.
 * Units: font points
 */
pan_servo_text_size                              = 3;

/**
 * Height of the gearbox block directly above the servo body.
 * The base volume that holds gears before the gear stack begins.
 */
pan_servo_gearbox_h                              = 4;

/**
 * A list describing a stack of circular gear disks on the servo.
 * Each gear is defined as: [height, diameter, color, (optional) resolution].
 */
pan_servo_gearbox_size                           = [[0.4, 6.09, matte_black],
                                                    [0.5, 4.35, dark_gold_2, 8],
                                                    [0.8, 2, dark_gold_2],
                                                    [2.45, 4, dark_gold_2, 10],
                                                    [0.05, 2.6, licorice, 8]];

/**
 * Diameter of the first (largest) gear or lid on the gear stack.
 * Used to compute alignment and transitions.
 */
pan_servo_gearbox_d1                             = 11.51;

/**
 * Diameter of the secondary gear/layer in the stack.
 * Typically used for angled profiles and hull blending.
 */
pan_servo_gearbox_d2                             = 6.56;

/**
 * Horizontal offset on the X-axis to place the second gear (d2)
 * shifted relative to the first gear (d1), for hull or profile shaping.
 */
pan_servo_gearbox_x_offset                       = 3;

/**
 * Mode used to generate the transition junction between d1 and d2 gearbox layers.
 * - `"hull"`: meshes them with a smooth profile.
 * - `"union"`: shows them as stacked cylinders.
 */
pan_servo_gearbox_mode                           = "hull";

/**
 * Color value used to render the body of the pan servo.
 */
pan_servo_color                                  = jet_black;

/**
 * Length of the chamfered or cutout region at the bottom of the servo body.
 * Used for display detail in component preview.
 */
pan_servo_cutted_len                             = 3;

// ─────────────────────────────────────────────────────────────────────────────
// HEAD NECK PANEL (Vertical Plate for Tilt Servo Mounting)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Width (X-axis) of the tilt servo mounting slot.
 * Should closely match the physical width of the servo body.
 */
head_neck_tilt_servo_slot_width                  = 23.6;

/**
 * Height (Y-axis) of the tilt servo slot in the vertical bracket.
 * Should correspond to the depth of the servo side profile.
 */
head_neck_tilt_servo_slot_height                 = 12;

/**
 * Diameter of the holes used for fastening the servo to the bracket.
 * Applies to both pan and tilt servos.
 */
head_neck_tilt_servo_bolt_dia                    = 2;

/**
 * Lateral horizontal offset from the slot centerline to each bolt hole center.
 */
head_neck_tilt_servo_bolts_offset                = 1;

/**
 * Thickness of the vertical support plate in which the tilt servo is mounted.
 * Same as the vertical thickness of the L-bracket.
 */
head_neck_tilt_servo_slot_thickness              = 2.5;

/**
 * Additional width added beyond the tilt servo slot to ensure clearance and rigidity.
 * Allow placement of head/servo structures with sufficient tolerance.
 */
head_neck_tilt_servo_extra_w                     = 4;

/**
 * Additional lower structural height added **below** tilt servo slot.
 * Provides more support at the base and positions the servo higher.
 */
head_neck_tilt_servo_extra_lower_h               = 5;

/**
 * Additional height added **above** the tilt servo placement.
 * Allows for mounting clearance or bolt pass-through from above.
 */
head_neck_tilt_servo_extra_top_h                 = 3;

// ─────────────────────────────────────────────────────────────────────────────
// TILT SERVO CONFIGURATION (Dimensions & Visual Representation)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Physical dimensions of the tilt servo: [Length, Width, Height].
 * Measurement excludes mounting hat and gear housing.
 */
tilt_servo_size                                  = [23.48, 11.7, 20.3];

/**
 * Bolt offset distance from the slot to centers of mounting holes.
 * Used during servo slot modeling and visualization.
 */
tilt_servo_bolts_offset                          = 1;

/**
 * Width of the mounting flange ("hat") for the tilt servo.
 * Usually wider than the central body to allow secure fastening.
 */
tilt_servo_hat_w                                 = 32.11;

/**
 * Height of the servo hat (Y axis).
 * Should match the width of the servo body.
 */
tilt_servo_hat_h                                 = tilt_servo_size[1];

/**
 * Thickness of the tilt servo's mounting flange ("hat").
 * Used to offset and extrude bolt holders in 3D view.
 */
tilt_servo_hat_thickness                         = 1.6;

/**
 * Distance from the top of the servo body to bolt-holding surface (flange).
 * Used to vertically position the hat relative to the main body.
 */
tilt_bolts_hat_z_offset                          = 4;

/**
 * Horizontal offset between the two gearbox shaft diameters
 * (used when blending large/small gear diameters visually).
 */
tilt_servo_gearbox_x_offset                      = 3;

/**
 * How to visually join `gearbox_d1` and `gearbox_d2`. Accepted values:
 * - `"hull"`: Smooth shell connection.
 * - `"union"`: Joined but visually distinct cylinders.
 */
tilt_servo_gearbox_mode                          = "hull";

/**
 * Labeling text for the tilt servo used in rendered previews.
 * Format: [["Text Line", font size, font name], ...]
 */
tilt_servo_text                                  = [["EMAX", 4, "Liberation Sans:style=Bold Italic"],
                                                    ["ES08MA II ANALOG SERVO", 1.2, "Ubuntu:style=Bold"]];

/**
 * Default text size for servo labels if none is explicitly specified.
 */
tilt_servo_text_size                             = 3;

/**
 * Height of the gearbox housing above the main servo body.
 * Does not include stacked gears.
 */
tilt_servo_gearbox_h                             = 4;

/**
 * Array representing a visual stack of gear disks or wheels.
 * Each item: [height, diameter, color, (optional) faceting resolution].
 */
tilt_servo_gearbox_size                          = [[0.4, 6.09, matte_black],
                                                    [0.5, 4.35, dark_gold_2, 8],
                                                    [0.8, 2, dark_gold_2],
                                                    [2.45, 4, dark_gold_2, 10],
                                                    [0.05, 2.6, licorice, 8]];

/**
 * Diameter of the primary (largest) top gear in the tilt servo’s gearbox.
 */
tilt_servo_gearbox_d1                            = 11.51;

/**
 * Diameter of secondary/inner gear used for visuals or profile blending.
 */
tilt_servo_gearbox_d2                            = 6.56;

/**
 * Rendering color for the tilt servo body.
 */
tilt_servo_color                                 = jet_black;

/**
 * Length of the angled cut (chamfer) at the servo body base.
 * Used in visual model to distinguish component edges.
 */
tilt_servo_cutted_len                            = 3;

// ─────────────────────────────────────────────────────────────────────────────
// Motor type
// ─────────────────────────────────────────────────────────────────────────────
// Type of the DC motor to use. Either "n20" or "standard". "n20" refers to
// motors like the GA12-N20 with a 3mm shaft, whereas "standard" refers to
// popular, inexpensive, unnamed yellow motors with a 5mm shaft. This setting
// affects the shape and type of the motor bracket, the diameter of the rear
// wheel shafts, and the vertical length of the steering knuckle shafts
motor_type                                       = "n20"; // [n20, standard]

// ─────────────────────────────────────────────────────────────────────────────
// Steering Knuckle
// ─────────────────────────────────────────────────────────────────────────────

// The height of the steering knuckle
knuckle_height                                   = 14.0;

// Diameter of the steering knuckle
knuckle_dia                                      = 14.0;

// The outside diameter of the 685-Z bearing (5x11x5) that is inserted into the
// knuckle
knuckle_bearing_outer_dia                        = 11.0;

// The inside diameter (plus tolerance) of the 685-Z bearing (5x11x5).
// They are placed on the each side of the steering panel
knuckle_bearing_inner_dia                        = 5.20;

// The height of the 685-Z bearing placeholder used in the knuckle assembly
knuckle_bearing_height                           = 5;

// The height of the flange of the 685-Z bearing placeholder
knuckle_bearing_flanged_height                   = 0.5;

// The width of the 685-Z bearing placeholder used in the knuckle assembly
knuckle_bearing_flanged_width                    = 0.5;

// Do not edit, used for Ackermann geometry calculations
knuckle_border_w                                 = (knuckle_dia - knuckle_bearing_outer_dia) / 2;

// The diameter of the knuckle’s wheel shaft for the 608ZZ bearing
knuckle_shaft_dia                                = 8;

// The diameter of the knuckle's connector into which the shaft is inserted. It
// should be larger than the shaft itself.
knuckle_shaft_connector_dia                      = knuckle_shaft_dia * 1.4;

// The diameter of the fastening bolts on the knuckle connector for the wheel
// shaft.
knuckle_shaft_bolt_dia                           = m25_hole_dia;

// The distance from the top of the shaft to the bolt holes
knuckle_shaft_bolts_offset                       = 1;

// distance between bolt holes on the shaft
knuckle_shaft_bolts_distance                     = 2;

// The length of the vertical part of the (curved) axle shaft that connects the
// steering knuckle to the wheel hub
knuckle_shaft_vertical_len                       = knuckle_height +
                                                (motor_type == "n20"
                                                 ? 21.5
                                                 : 26.5);

// The additional length of the connector for the shaft in the knuckle and the
// corresponding curved axle shaft
knuckle_shaft_connector_extra_len                = 2;

knuckle_shaft_connector_extra_arm_len            = 1;

// The additional length of the for the shaft itself
knuckle_shaft_extra_len                          = assembly_shaft_use_front_steering
                                                &&
                                                assembly_use_front_steering
                                                ? 5
                                                : 0;

// The length of the lower horizontal part of the (curved) axle shaft that is
// inserted into the wheel hub
knuckle_shaft_lower_horiz_len                    = 27;

// The height of the upper pins on each side of the frame onto which the
// steering knuckle bearings are mounted
knuckle_pin_bearing_height                       = 8.0;

// The height of the chamfer at the top of the bearing pin
knuckle_pin_chamfer_height                       = 2.5;

// The height of the lower pins on each side of the frame that have bearing pins
// at the top
knuckle_pin_lower_height                         = 5.6;

// The height of the wider lower part of the pin that prevents contact between
// the bearing and the frame
knuckle_pin_stopper_height                       = 1;

// The length of the rotated shaft that connects the knuckle with the bracket
// steering_knuckle_bracket_connector_len          = 12.2;

// The height (thickness) of the knuckle connector with the 685-Z bearing that
// is connected to the rack link
knuckle_rack_link_arm_height                     = 6;

knuckle_tie_rod_shaft_arm_len                    = 9.4;

// ─────────────────────────────────────────────────────────────────────────────
// N20 motor dimensions
// ─────────────────────────────────────────────────────────────────────────────
n20_reductor_dia                                 = 14;
n20_reductor_height                              = 9;
n20_shaft_height                                 = 9;
n20_shaft_dia                                    = 3;
n20_shaft_cutout_w                               = 2;
n20_can_height                                   = 15;
n20_can_dia                                      = 12;
n20_can_cutout_w                                 = 7;

n20_end_cap_h                                    = 0.8;
n20_end_circle_h                                 = 0.5;
n20_end_cap_circle_dia                           = 5;
n20_end_cap_circle_hole_dia                      = 3;

// ─────────────────────────────────────────────────────────────────────────────
// N20 motor bracket dimensions
// ─────────────────────────────────────────────────────────────────────────────
n20_motor_bracket_tolerance                      = 0.2;
n20_motor_bracket_thickness                      = 3;
n20_motor_bolts_panel_offset                     = 11.3;
n20_motor_bolts_panel_length                     = 4;
n20_motor_bolt_dia                               = m25_hole_dia;
n20_motor_bolt_bore_dia                          = n20_motor_bolt_dia * 2;
n20_motor_bolt_bore_h                            = chassis_counterbore_h;

n20_motor_chassis_y_distance                     = 0;
n20_motor_chassis_x_distance                     = -9;

n20_motor_bolts_panel_len                        = n20_can_dia
                                                + n20_motor_bracket_thickness
                                                * 2
                                                + n20_motor_bolt_dia
                                                * 2
                                                + n20_motor_bolts_panel_length
                                                * 2;

chassis_single_holes_specs                       = [[[8, 0, -5, 0]],
                                                    [[8, 0, 5, 0]],
                                                    [[6, 0,
                                                      chassis_body_w / 2 - n20_motor_bolts_panel_offset
                                                      - n20_can_height, -40]],
                                                    [[6, 30.2,
                                                      chassis_body_w / 2 - n20_motor_bolts_panel_offset
                                                      - n20_can_height, -30]],
                                                    [[6.0, 30.2,
                                                      -chassis_body_w / 2 + n20_motor_bolts_panel_offset
                                                      + n20_can_height, -40]],
                                                    [[6.0, 30.2,
                                                      -chassis_body_w / 2 + n20_motor_bolts_panel_offset
                                                      + n20_can_height, -30]]];

chassis_rect_holes_specs                         = [[[[10, 20, 4.0], [10, 0, 40]], // third in the center
                                                     [[10, 20, 4.0], [10, 0, 38]], // second in the center
                                                     [[10, 20, 4.0], [10, 0, 35]]], // first in the center
                   // rectangulars on the both sides
                                                    [[[10, 15, 4.0], [10,
                                                                      chassis_body_w / 2 - 6.5,
                                                                      40]],
                                                     [[10, 15, 4.0], [10,
                                                                      chassis_body_w / 2 - 6.5,
                                                                      40]]],
                                                    [[[10, 15, 4.0], [10,
                                                                      -chassis_body_w / 2 + 6.5,
                                                                      40],],
                                                     [[10, 15, 4.0], [10,
                                                                      -chassis_body_w / 2 + 6.5,
                                                                      40]]]];

chassis_panel_stack_slot_specs                   = [[[[15, 30, 6.0], [14, 35, 0]],  // side hole near fuse stack
                                                     [[32, 15, 3.0], [0, 47.2, 0]]], // hole under left smd battery
                                                    [[[25, 14, 3.0], [10, -4, 0]], // upper hole under fuse stack
                                                     [[25, 14, 3.0], [10, -4, 0]], // lower hole under fuse stack
                                                     [[35, 14, 3.0], [10, -22, 0]]], // hole under right smd battery
                                                   ];
// ─────────────────────────────────────────────────────────────────────────────
// Rear panel: A vertical rear plate with dimensions including two mounting
// holes for switch buttons.
// ─────────────────────────────────────────────────────────────────────────────
rear_panel_size                                  = [52, 25, 8];
rear_panel_switch_slot_dia                       = 13;
rear_panel_switch_slot_cbore_dia                 = 18;
rear_panel_switch_slot_cbore_h                   = 2;

rear_panel_holes_x_offsets                       = [-16, 16];
rear_panel_bolt_holes_x_offsets                  = [-16, 16];
rear_panel_bolt_hole_dia                         = m25_hole_dia;
rear_panel_bolt_cbore_hole_dia                   = 5.0;
rear_panel_bolt_cbore_h                          = 2.0;
rear_panel_mount_thickness                       = 2.5;
rear_panel_thickness                             = 3;

rear_panel_bolt_offset                           = 3;

// ─────────────────────────────────────────────────────────────────────────────
// Raspberry Pi dimensions (defaults are for Raspberry PI 5)
// ─────────────────────────────────────────────────────────────────────────────
// Y offset for the Raspberry Pi 5 related slots and holes is measured from the end of the chassis.
rpi_chassis_y_position                           = 0;
rpi_chassis_x_position                           = -32.5;

// The X and Y dimensions of the bolt positions for the Raspberry Pi 5 slot.
// This forms a square with a bolt hole centered on each corner.
rpi_bolt_spacing                                 = [50, 58];

// The diameter of the bolt holes for the Raspberry Pi 5 slot.
rpi_bolt_hole_dia                                = m2_hole_dia;
rpi_bolt_cbore_dia                               = m2_round_head_dia + 0.1;

rpi_bolts_offset                                 = m25_hole_dia + 0.4;
rpi_pin_headers_cols                             = 20;
rpi_pin_headers_rows                             = 2;

rpi_len                                          = 85;
rpi_width                                        = 56;
rpi_thickness                                    = 1.9;

// The amount by which to offset the Raspberry Pi
rpi_offset_rad                                   = 2.4;

// The height of the pin
rpi_pin_height                                   = 8.54;

// The width of the single pin black header
rpi_pin_header_width                             = 2.54;

// The height of the pin black headers
rpi_pin_header_height                            = 2.54;

// Whether to show the Raspberry Pi with more realistic details, which may slow
// down the render
rpi_model_detailed                               = false;

rpi_model_text                                   = "Raspberry Pi [5]";
rpi_text_font                                    = "Ubuntu:style=Bold";

// Raspberry Pi parts dimensions (x, y, z)

rpi_ram_size                                     = [10.2, 15, 1]; // Size of the SRAM
rpi_processor_size                               = [15, 15, 0.5]; // BCM2712 processor

// USB 2.0 and USB 3.0 jacks
rpi_usb_size                                     = [13.25, 17.60, 15.04];

// Ethernet jack
rpi_ethernet_jack_size                           = [16.15, 21.34, 13.40];

// PCI Express interface
rpi_pci_size                                     = [12.85, 2, 3];

// 2 x 4-lane MIPI DSI/CSI connectors
rpi_csi_size                                     = [13.0, 2, 2.5];

// USB-c power jack
rpi_usb_c_jack_size                              = [8.2, 7.8, 3];

// 2 x micro-HDMI
rpi_micro_hdmi_jack_size                         = [8.2, 6.5, 3];

// UART connector
rpi_uart_connector_size                          = [2.5, 4.0, 5];

// RTC battery connector
rpi_rtc_connector_size                           = [2.5, 3.4, 5];

// Dual-band 902.11ac Wireless + Bluetooth 5
rpi_wifi_bt_size                                 = [14, 11, 1.5];

// RP1 I/O controller
rpi_io_size                                      = [14, 10, 1.5];

// The size of the On-off button
rpi_on_off_button_size                           = [3.85, 1.8, 2];
// The diameter of the On-off button
rpi_on_off_button_dia                            = 1.5;

//The height of the standoffs for Raspberry Pi
rpi_standoff_height                              = 6;
rpi_csi_position_x                               = rpi_bolt_spacing[0] - rpi_csi_size[0] / 2 - 2;
rpi_csi_position_y                               = rpi_bolt_spacing[1] - m25_hole_dia - 1;

// ─────────────────────────────────────────────────────────────────────────────
// AI HAT+
// ─────────────────────────────────────────────────────────────────────────────

ai_hat_size                                      = [56.7, 65, 1.5];
ai_hat_corner_rad                                = 2.4;
ai_hat_bolt_dia                                  = m25_hole_dia;

ai_hat_mounting_hole_pad_spec                    = [[m25_hole_dia + 2.5, yellow_3]];
ai_hat_csi_slot_size                             = [rpi_csi_size[0] + 4, ai_hat_size[1]
                                                    - rpi_csi_position_y];

ai_hat_processor_size                            = [17, 17, 1];
ai_hat_processor_text                            = "HAILO";
ai_hat_csi_cutout_corner_r                       = 1.5;
ai_hat_front_cutout_size                         = [20, 5];
ai_hat_header_height                             = 10.16;
ai_hat_pin_height                                = 10.57;

// ─────────────────────────────────────────────────────────────────────────────
// Servo Driver HAT
// ─────────────────────────────────────────────────────────────────────────────

servo_driver_hat_size                            = [30.26, 65.25, 1.65];
servo_driver_corner_rad                          = 2;
servo_driver_hat_bolt_spacing                    = [25, 58];

servo_driver_hat_bolt_dia                        = m25_hole_dia;
servo_driver_hat_standoff_color                  = "white";
servo_driver_hat_mounting_hole_pad_spec          = [[m25_hole_dia + 2.5, "white"]];

servo_driver_hat_header_height                   = 9;
servo_driver_hat_pin_height                      = 9.5;
servo_driver_hat_screw_terminal_thickness        = 5.8;
servo_driver_hat_screw_terminal_base_h           = 6.8;              // base height (Z)
servo_driver_hat_screw_terminal_top_l            = 4.50;              // top trapezoid top side length
servo_driver_hat_screw_terminal_top_h            = 3.2;               // top trapezoid height
servo_driver_hat_screw_terminal_contacts_n       = 2;            // number of contact boxes
servo_driver_hat_screw_terminal_contact_w        = 3.5;           // contact box width (X)
servo_driver_hat_screw_terminal_contact_h        = 4.47;          // contact box height (Z)
servo_driver_hat_screw_terminal_pitch            = 5.0;              // center-to-center spacing (X)

servo_driver_hat_side_pins_headers_count         = 4;
servo_driver_hat_side_pins_headers_margin        = 2;
servo_driver_hat_side_header_height              = 1.5;
servo_driver_hat_side_pin_cols                   = 4;
servo_driver_hat_side_pin_rows                   = 3;
servo_driver_hat_side_pin_height                 = 15.7;

servo_driver_hat_chip_len                        = 9;
servo_driver_hat_chip_w                          = 5;
servo_driver_hat_chip_total_w                    = 8;
servo_driver_hat_chip_j_lead_n                   = 14;
servo_driver_hat_chip_j_lead_thickness           = 0.4;
servo_driver_hat_chip_h                          = 1.65;

servo_driver_hat_chip_x_distance                 = 18;

servo_driver_hat_chip_i2c_x_distance             = 5;
servo_driver_hat_chip_i2c_y_distance             = 15;

servo_driver_hat_i2c_addr_size                   = [3.0, 1.3, 0.4];
servo_driver_hat_i2c_addr_gap                    = 0.3;
servo_driver_hat_i2c_addr_text_size              = 0.6;
servo_driver_hat_i2c_addr_text_gap               = 0.6;

servo_driver_hat_i2c_addr_text_label             = "I2C Addresses";
servo_driver_hat_i2c_addr_text_label_size        = 0.9;

servo_driver_hat_chip_2_len                      = 5;
servo_driver_hat_chip_2_w                        = 4;
servo_driver_hat_chip_2_total_w                  = 8;
servo_driver_hat_chip_2_j_lead_n                 = 4;
servo_driver_hat_chip_2_j_lead_thickness         = 0.4;
servo_driver_hat_chip_2_h                        = 1.65;
servo_driver_hat_chip_2_y_distance               = 10;
servo_driver_hat_chip_2_x_distance               = 46;

// ─────────────────────────────────────────────────────────────────────────────
// Motor Driver HAT
// ─────────────────────────────────────────────────────────────────────────────

motor_driver_hat_size                            = [56.7, 65, 1.9];
motor_driver_hat_corner_rad                      = 2.4;
motor_driver_hat_bolt_dia                        = m25_hole_dia;
motor_driver_hat_standoff_color                  = "white";
motor_driver_hat_mounting_hole_pad_spec          = [[m25_hole_dia + 2.5, "white"]];

motor_driver_hat_header_height                   = 13.15;
motor_driver_hat_pin_height                      = 8.5;

motor_driver_hat_screw_terminal_distance         = 2.5;
motor_driver_hat_screw_terminal_thickness        = 5.8;
motor_driver_hat_screw_terminal_base_h           = 6.8;              // base height (Z)
motor_driver_hat_screw_terminal_top_l            = 4.50;              // top trapezoid top side length
motor_driver_hat_screw_terminal_top_h            = 3.2;               // top trapezoid height
motor_driver_hat_screw_terminal_contacts_n       = 6;            // number of contact boxes
motor_driver_hat_screw_terminal_contact_w        = 3.5;           // contact box width (X)
motor_driver_hat_screw_terminal_contact_h        = 4.47;          // contact box height (Z)
motor_driver_hat_screw_terminal_pitch            = 5.0;              // center-to-center spacing (X)

motor_driver_hat_chip_len                        = 15;
motor_driver_hat_chip_w                          = 10;

motor_driver_hat_chip_j_lead_n                   = 11;
motor_driver_hat_chip_j_lead_thickness           = 0.4;
motor_driver_hat_chip_total_w                    = 17;
motor_driver_hat_chip_h                          = 1.65;
motor_driver_hat_chip_distance_between           = 4;
motor_driver_hat_chip_y_distance                 = 18;

motor_driver_hat_voltage_chip_len                = 15;
motor_driver_hat_voltage_chip_w                  = 7;

motor_driver_hat_voltage_chip_j_lead_n           = 11;
motor_driver_hat_voltage_chip_j_lead_thickness   = 0.4;
motor_driver_hat_voltage_chip_total_w            = 17;
motor_driver_hat_voltage_chip_h                  = 1.65;
motor_driver_hat_voltage_chip_x_distance         = 4;
motor_driver_hat_voltage_chip_y_distance         = 4;

motor_driver_hat_upper_header_height             = 9;
motor_driver_hat_upper_pin_height                = 5;

motor_driver_hat_capacitor_d                     = 10;
motor_driver_hat_capacitor_h                     = 2.58;

motor_driver_hat_capacitor_cyl_h                 = 7.5;
motor_driver_hat_capacitor_x_offset=0;
motor_driver_hat_capacitor_y_offset=3;

motor_driver_hat_extra_capacitors                = [[5.5, 2.58, 5.5, 0, 5],
                                                    [5.5, 2.58, 5.5, -10, 5],
                                                    [5.5, 2.58, 5.5, 24, 10]];

// ─────────────────────────────────────────────────────────────────────────────
// GPIO Expansion Board
// ─────────────────────────────────────────────────────────────────────────────
gpio_expansion_bolt_spacing_2                    = [38, 58];
gpio_expansion_size                              = [55.0, 65.25, 1.65];

gpio_expansion_bolt_dia                          = m25_hole_dia;
gpio_expansion_standoff_color                    = "white";
gpio_expansion_corner_rad                        = 2;
gpio_expansion_mounting_hole_pad_spec            = [[m25_hole_dia + 2.5, dark_gold_1]];

gpio_expansion_header_height                     = 8;
gpio_expansion_pin_height                        = 3.5;

gpio_expansion_header_up_height                  = 2;
gpio_expansion_pin_up_height                     = 7;

gpio_expansion_inner_header_cols                 = 8;
gpio_expansion_inner_header_rows                 = 2;
gpio_expansion_inner_header_gap                  = 8;

gpio_expansion_inner_header_pin_height           = 6;
gpio_expansion_inner_headers_count               = 3;

gpio_expansion_screw_terminal_thickness          = 12.0;
gpio_expansion_screw_terminal_base_h             = 7.4;
gpio_expansion_screw_terminal_top_l              = 6.50;

gpio_expansion_screw_terminal_top_h              = 6.2;
gpio_expansion_screw_terminal_contacts_n         = 8;
gpio_expansion_screw_terminal_contact_w          = 2.0;
gpio_expansion_screw_terminal_contact_h          = 0;
gpio_expansion_screw_terminal_pitch              = 3.2;
gpio_expansion_screw_terminal_x_offset           = 2.0;

// ─────────────────────────────────────────────────────────────────────────────
// Voltmeter placeholder
// ─────────────────────────────────────────────────────────────────────────────
voltmeter_board_len                              = 22.65;
voltmeter_board_w                                = 14.45;
voltmeter_board_h                                = 0.9;

voltmeter_display_len                            = 22.65;
voltmeter_display_w                              = 14.45;
voltmeter_display_h                              = 6.16;

voltmeter_bolt_spacing                           = [0, 27.70];
voltmeter_bolt_dia                               = m3_hole_dia;
voltmeter_standoff_body_d                        = 4.58;
voltmeter_standoff_thread_h                      = 5;

voltmeter_pin_h                                  = 3.44;
voltmeter_pins_len                               = 10.65;

voltmeter_pin_thickness                          = 0.63;
voltmeter_pins_count                             = 5;

voltemeter_text_spec                             = ["8.8.8.",
                                                    6.15,
                                                    "DSEG14 Classic:style=Italic",
                                                    1.0,
                                                    metallic_silver_1,
                                                    [0, 0.6]];

voltmeter_display_indicators_len                 = 3;
voltmeter_wiring_distance                        = 3;
voltmeter_wiring_gap                             = 1;
voltmeter_wiring_d                               = 1.5;

voltmeter_chassis_specs                          = [];

// ─────────────────────────────────────────────────────────────────────────────
// XT90 connector placeholder
// ─────────────────────────────────────────────────────────────────────────────

xt_90_size                                       = [10.30, 22.20];
xt_90_position                                   = [3, 1];

xt_90_bolt_spacing                               = [0, 32.20];
xt_90_bolt_dia                                   = m3_hole_dia;

// ─────────────────────────────────────────────────────────────────────────────
// XT90E-M connector placeholder
// ─────────────────────────────────────────────────────────────────────────────
xt90e_size                                       = [xt_90_size[0], xt_90_size[1], 15.1];
xt90e_mounting_panel_size                        = [17.4, 42, 3];
xt90e_shell_h                                    = 15.1;
xt90e_mount_spacing                              = 32.4;
xt90e_mount_dia                                  = m3_hole_dia;
xt90e_mount_cbore_dia                            = m3_countersunk_head_dia;
xt90e_mount_cbore_h                              = m3_countersunk_head_h;

xt90e_pin_spacing                                = 10.16;
xt90e_pin_dia                                    = 5.2;
xt90e_contact_dia                                = 5.7;
xt90e_contact_h                                  = 5.7;
xt90e_contact_thickness                          = 0.8;
xt90e_contact_wall_h                             = 3;
xt90e_contact_base_h                             = 2;

xt90e_pin_length                                 = 13.5;

xt90e_pin_thickness                              = 1;

xt90e_shell_color                                = matte_black;
xt90e_pin_color                                  = dark_gold_2;

// ─────────────────────────────────────────────────────────────────────────────
// Power module case dimensions
// ─────────────────────────────────────────────────────────────────────────────

// External width of the power module case (X dimension).
// This is the full outside width including side walls and rails.
power_case_width                                 = 52.4;

// External length of the power module case (Y dimension).
// This is the full outside length of the battery case including front/back walls.
power_case_length                                = 146;

// External height of the base case body (Z dimension) measured to the top face
// of the main case (does not include the dovetail rails mounted above).
power_case_height                                = 55;

power_case_round_rad                             = 1; // Corner radius for rounded exterior geometry.

// ─────────────────────────────────────────────────────────────────────────────
// INA 260
// ─────────────────────────────────────────────────────────────────────────────

ina260_bolt_spacing                              = [17.78, 0];
ina260_bolt_dia                                  = m25_hole_dia;
ina260_size                                      = [22.9, 23.1, 1.65];

// ─────────────────────────────────────────────────────────────────────────────
// Side wall ventilation slot parameters
// ─────────────────────────────────────────────────────────────────────────────

// depth of each slot (extent into the model in Z when slots are created).
power_case_side_slot_h                           = 10;
// Vent/slot parameters (for the case top/side ventilation slots).
// slot width (slot_w) is the narrow dimension of each rectangular vent slot.
power_case_side_slot_w                           = 2.8;

// distance between adjacent slot centers (slot gap) measured in the same axis as slot width spacing.
power_case_side_slot_gap                         = 5.6;

power_case_side_slot_padding_z                   = 7.0;
power_case_side_slot_padding_x                   = 30.0;

power_case_side_slot_gap_z                       = 4.6;

// Height of the front and back (end) walls of the case (Z dimension).
// These end walls are shorter than the side walls to allow the battery XT90/ balance
// leads and connector to exit from the top. Used to position slot cutouts and the
// top pocket height relative to the inner battery compartment.
power_case_front_back_wall_h                     = 34;

// Thickness of the front and back (end) walls
power_case_front_wall_thickness                  = (power_case_length - (lipo_pack_length + 0.4)) / 2;

// ─────────────────────────────────────────────────────────────────────────────
// Slots in front and rear panels of the Power case
// ─────────────────────────────────────────────────────────────────────────────

// depth of each slot (extent into the model in Z when slots are created).
power_case_front_slot_h                          = 10;

// Vent/slot parameters (for the case side ventilation slots).
// slot width (slot_w) is the narrow dimension of each rectangular vent slot.
power_case_front_slot_w                          = 2.8;

// distance between adjacent slot centers (slot gap) measured in the same axis as slot width spacing.
power_case_front_slot_gap                        = 3.6;

power_case_front_slot_padding_z                  = 4.0;
power_case_front_slot_padding_x                  = 5.0;

power_case_front_slot_gap_z                      = 3.9;

// ─────────────────────────────────────────────────────────────────────────────
// Power module case bottom wall and mounting bolts
// ─────────────────────────────────────────────────────────────────────────────

// Thickness of the bottom wall (floor) of the case.
// This affects internal clearance and bolt/counterbore depths.
power_case_bottom_thickness                      = 2.0;

// The X and Y spacing for the 4 corner mounting bolt positions.
// Provided as [X_spacing, Y_spacing]. These define the square/rectangle on which
// the four mounting holes are placed; used by four_corner_children/four_corner_holes.

power_case_bottom_bolt_spacing                   = [40, 88];
// Bolt/cutout sizes for mounting the power module to the chassis.
// The bolt hole diameter for through holes in the bottom/back wall.
power_case_bottom_bolt_dia                       = m3_hole_dia;

// Counterbore diameter for the bolt head recess on the bottom/back wall.
// This is the larger diameter of the counterbore so the bolt head can sit flush.
power_case_bottom_cbore_dia                      = 6.0;

power_case_bottom_cbore_h                        = 1.0;

power_case_chassis_x_offset                      = 0;
power_case_chassis_y_offset                      = 0;

power_case_bolt_spacing_offset_x                 = 0;
power_case_bolt_spacing_offset_y                 = 18;

power_case_standoff_h                            = 10;
power_case_standoff_thread_h                     = 5;

// ─────────────────────────────────────────────────────────────────────────────
// Power module case dovetail rail parameters
// ─────────────────────────────────────────────────────────────────────────────

// Dovetail rail geometry parameters (for mounting a secondary module on top).
// Angle (deg) of the dovetail sides relative to vertical (controls trapezoid slope).
power_case_rail_angle                            = 20;

// Fillet radius applied to dovetail profile (0 = sharp corners).
power_case_rail_rad                              = 0.0;

// Vertical thickness of the rail profile (height of the dovetail section).
power_case_rail_height                           = 4;

// Diameter of bolt holes that run through the rail for mounting hardware.
power_case_rail_bolt_dia                         = m25_hole_dia + 0.1;

// Distance from the centerline of the rail to the bolt groove (used to place clearance slots).
power_case_rail_bolt_groove_distance             = 6.5;

// Internal side wall thickness computed from overall width and the bolt pattern.
// This determines the width of the side wall between the central battery pocket and outer shell.
// Changing the bolt pose values will change this computed thickness.
power_case_side_wall_thickness                   = 2.3;

power_lid_extra_side_thickness                   = 2;

// Groove dimensions along the rail used to accept the mating slider/plate.
power_case_groove_w                              = power_case_side_wall_thickness - 0.8;

power_case_groove_thickness                      = 1.5; // Thickness (depth) of the groove feature.

power_case_groove_edge_distance                  = 2; // Distance from the rail edge to the start of the groove cut.

// Rabbet (rabet) / lip geometry used for mating the lid or aligning another part.
// rabet_h is the height (Z) of the lip, rabet_w is its width (X), and rabet_thickness is the board/thickness it sits on.
power_case_rabet_h                               = 1;
power_case_rabet_w                               = 1.4;
power_case_rabet_thickness                       = 2.8;

// The tolerance to add to the hole for the rail
power_case_rail_tolerance                        = 0.4;

power_case_rail_relief_depth                     = 0.12; // 0.12…0.15

power_lid_height                                 = 24.5;
power_lid_width                                  = power_case_width
                                                + power_case_side_wall_thickness
                                                + power_case_rail_tolerance / 2;

power_lid_thickness                              = 2;

power_voltmeter_specs                            = [[[voltmeter_bolt_spacing,
                                                      voltmeter_bolt_dia,
                                                      [voltmeter_board_w,
                                                       voltmeter_board_len,
                                                       voltmeter_board_h,],
                                                      [voltmeter_display_w,
                                                       voltmeter_display_len,
                                                       voltmeter_display_h,
                                                       1,
                                                       voltmeter_display_indicators_len],
                                                      [voltmeter_pins_count,
                                                       voltmeter_pin_h,
                                                       voltmeter_pin_thickness,
                                                       voltmeter_pins_len],
                                                      [voltmeter_wiring_d,
                                                       [[-5, -5, -2],
                                                        [-15, -10, -1],
                                                        [10, -15, -2],
                                                        [20, 0, 0]],
                                                       voltmeter_wiring_gap,
                                                       voltmeter_wiring_distance],
                                                      [voltmeter_standoff_body_d],
                                                      ["16.4", 6.15,
                                                       "DSEG14 Classic:style=Italic",
                                                       1.2,
                                                       red_1,
                                                       [0, 0.6]]],
                                                     [-25, -12, 3, -90, true]],
                                                    [[voltmeter_bolt_spacing,
                                                      voltmeter_bolt_dia,
                                                      [voltmeter_board_w,
                                                       voltmeter_board_len,
                                                       voltmeter_board_h,],
                                                      [voltmeter_display_w,
                                                       voltmeter_display_len,
                                                       voltmeter_display_h,
                                                       1,
                                                       voltmeter_display_indicators_len],
                                                      [voltmeter_pins_count,
                                                       voltmeter_pin_h,
                                                       voltmeter_pin_thickness,
                                                       voltmeter_pins_len],
                                                      [voltmeter_wiring_d,
                                                       [[0, -5, -2],
                                                        [-22, 15, -1],
                                                        [-22, 15, -20],
                                                        [-65, 15, -20],
                                                        [-60, 25, -25]],
                                                       voltmeter_wiring_gap,
                                                       voltmeter_wiring_distance],
                                                      [voltmeter_standoff_body_d],
                                                      ["8.02", 6.15,
                                                       "DSEG14 Classic:style=Italic",
                                                       1.2,
                                                       red_1,
                                                       [0, 0.6]]],
                                                     [-38,
                                                      107,
                                                      0,
                                                      0,
                                                      true]],
                                                    [[voltmeter_bolt_spacing,
                                                      voltmeter_bolt_dia,
                                                      [voltmeter_board_w,
                                                       voltmeter_board_len,
                                                       voltmeter_board_h,],
                                                      [voltmeter_display_w,
                                                       voltmeter_display_len,
                                                       voltmeter_display_h,
                                                       1,
                                                       voltmeter_display_indicators_len],
                                                      [voltmeter_pins_count,
                                                       voltmeter_pin_h,
                                                       voltmeter_pin_thickness,
                                                       voltmeter_pins_len],
                                                      [voltmeter_wiring_d,
                                                       [[0, 5, -2],
                                                        [-22, 10, -1],
                                                        [-32, 10, -49],
                                                        [-70, -20, -49],
                                                        [-70, 0, -45]],
                                                       voltmeter_wiring_gap,
                                                       voltmeter_wiring_distance],
                                                      [voltmeter_standoff_body_d],
                                                      ["8.10", 6.15,
                                                       "DSEG14 Classic:style=Italic",
                                                       1.2,
                                                       red_1,
                                                       [0, 0.6]]],
                                                     [-38,
                                                      70,
                                                      0,
                                                      0,
                                                      true]],];

power_lid_breadboard_bolt_spacing                = [16.0, 76.0];
// [16.0, 76.0];
power_lid_breadboard_bolt_dia                    = m2_hole_dia;

// [[[x, y], diameter, [gap_for_next_item, x_offset, y_offset], [bore_dia, bore_h, auto_scale_step, reverse]?, [debug?, text] ]],
power_lid_rect_bolt_holes                        = [[[[15.2, 35.55],
                                                      m2_hole_dia,
                                                      [10, -11.9, 14.55],
                                                      [6 , 1.0, 0.1, false],
                                                      [false,
                                                       "DC",
                                                       1.5,
                                                       "red",
                                                       [0, 0, 90],
                                                       [-2, 0, 0],
                                                       undef,
                                                       undef,
                                                       "center",
                                                       "baseline"],
                                                      ["pan",
                                                       4,
                                                       2,
                                                       2]]],
                                                    [[[power_lid_breadboard_bolt_spacing[0],
                                                       power_lid_breadboard_bolt_spacing[1]],
                                                      power_lid_breadboard_bolt_dia,
                                                      [0, 15, 18],
                                                      [],
                                                      [false,
                                                       "Breadboard",
                                                       1.5,
                                                       "red",
                                                       [0, 0, 90],
                                                       [-2, 0, 0],
                                                       undef,
                                                       undef,
                                                       "center",
                                                       "baseline"]]],
                                                    [[[ina260_bolt_spacing[0],
                                                       ina260_bolt_spacing[1]],
                                                      ina260_bolt_dia,
                                                      [10,
                                                       17,
                                                       38],
                                                      [],
                                                      [false,
                                                       "INA260",
                                                       2,
                                                       "red",
                                                       [0, 0, 90],
                                                       [-2, 0, 0],
                                                       undef,
                                                       undef,
                                                       "center",
                                                       "baseline"]]]];
// [...[x, y, radius, y_gap, x_offset, y_offset, [counterbore_x, counterbore_y, counterbore_z], higlight?]]
power_lid_single_holes_specs                     = [[[8, 15.2, -0, 25]]];

power_lid_side_wall_1_circle_holes               = [[[8, 15.2, -2, 5], [8, 15.2, -2, 5]]];
power_lid_side_wall_2_circle_holes               = [[[8, 22.2, -2, 5], [8, 15.2, -2, 5]]];

// [...[[x, y, radius], [y_gap, x_offset, y_offset], [counterbore_x, counterbore_y, counterbore_z], higlight?]]
power_lid_cube_holes                             = [[[[atm_fuse_holder_2_mounting_hole_h + 2,
                                                       atm_fuse_holder_2_mounting_hole_l + 0.8,
                                                       atm_fuse_holder_2_mounting_hole_r + 1],
                                                      [0,
                                                       12.5,
                                                       70],]],
                                                    [[[atm_fuse_holder_2_mounting_hole_h + 2,
                                                       atm_fuse_holder_2_mounting_hole_l + 0.8,
                                                       atm_fuse_holder_2_mounting_hole_r + 1],
                                                      [0,
                                                       -3.5,
                                                       70],]],
                                                    [[[9.5, 30.4, 2.0], [0, -16.7, -10]],
                                                     [[9.5, 8.4, 2.0], [26, -16.7, 18]],
                                                     [[6, 20, 1.0], [26, -19.0, 9]],]];

// [[slot_h, slot_l, slot_r, hole_depth, slot_tolerance_r?],
//  [y_gap, x, y, z?],
//  [counterbore_x, counterbore_y, counterbore_thickness],
//  [fuse_placeholder_body_top_l,
//   fuse_placeholder_body_bottom_l,
//   fuse_placeholder_body_w,
//   fuse_placeholder_body_h,
//   matte_black_2],
//  [fuse_placeholder_lid_top_l,
//   fuse_placeholder_lid_bottom_l,
//   fuse_placeholder_lid_w,
//   fuse_placeholder_lid_h,
//   fuse_placeholder_lid_color]]
power_lid_side_wall_1_atm_fuse_specs             = [[[[atm_fuse_holder_2_mounting_hole_h + 2.2,
                                                       atm_fuse_holder_2_mounting_hole_l + 0.6,
                                                       atm_fuse_holder_2_mounting_hole_r,
                                                       1,
                                                       atm_fuse_holder_2_mounting_hole_depth],
                                                      [0,
                                                       0,
                                                       75,
                                                       0],
                                                      [atm_fuse_holder_2_mounting_hole_h * 1.7,
                                                       atm_fuse_holder_2_lid_bottom_l + 7,
                                                       (power_case_side_wall_thickness
                                                        + power_lid_extra_side_thickness
                                                        + power_case_rail_tolerance) * 0.66,
                                                       true],
                                                      [atm_fuse_holder_2_body_top_l,
                                                       atm_fuse_holder_2_body_bottom_l,
                                                       atm_fuse_holder_2_body_thickness,
                                                       atm_fuse_holder_2_body_h,
                                                       matte_black_2,
                                                       true],
                                                      [atm_fuse_holder_2_lid_top_l,
                                                       atm_fuse_holder_2_lid_bottom_l,
                                                       atm_fuse_holder_2_lid_thickness,
                                                       atm_fuse_holder_2_lid_h,
                                                       matte_black_2,
                                                       false],
                                                      [atm_fuse_holder_2_body_rib_l,
                                                       atm_fuse_holder_2_body_rib_h,
                                                       atm_fuse_holder_2_body_rib_n,
                                                       atm_fuse_holder_2_body_rib_distance,
                                                       atm_fuse_holder_2_body_rib_thickness],
                                                      [atm_fuse_holder_2_lid_rib_l,
                                                       atm_fuse_holder_2_lid_rib_h,
                                                       atm_fuse_holder_2_lid_rib_n,
                                                       atm_fuse_holder_2_lid_rib_distance,
                                                       atm_fuse_holder_2_lid_rib_thickness],
                                                      [atm_fuse_holder_body_wiring_d, [[15, 0, 0],
                                                                                       [0, 0, 0]]]],]];

power_lid_side_wall_2_atm_fuse_specs             = [[[[atm_fuse_holder_2_mounting_hole_h + 2.2,
                                                       atm_fuse_holder_2_mounting_hole_l + 0.6,
                                                       atm_fuse_holder_2_mounting_hole_r,
                                                       1,
                                                       atm_fuse_holder_2_mounting_hole_depth],
                                                      [0,
                                                       0,
                                                       85,
                                                       3],
                                                      [atm_fuse_holder_2_mounting_hole_h * 1.7,
                                                       atm_fuse_holder_2_lid_bottom_l + 7,
                                                       (power_case_side_wall_thickness
                                                        +  power_lid_extra_side_thickness
                                                        + power_case_rail_tolerance) * 0.66,
                                                       true],
                                                      [atm_fuse_holder_2_body_top_l,
                                                       atm_fuse_holder_2_body_bottom_l,
                                                       atm_fuse_holder_2_body_thickness,
                                                       atm_fuse_holder_2_body_h,
                                                       matte_black_2,
                                                       true],
                                                      [atm_fuse_holder_2_lid_top_l,
                                                       atm_fuse_holder_2_lid_bottom_l,
                                                       atm_fuse_holder_2_lid_thickness,
                                                       atm_fuse_holder_2_lid_h,
                                                       matte_black_2,
                                                       true],
                                                      [atm_fuse_holder_2_body_rib_l,
                                                       atm_fuse_holder_2_body_rib_h,
                                                       atm_fuse_holder_2_body_rib_n,
                                                       atm_fuse_holder_2_body_rib_distance,
                                                       atm_fuse_holder_2_body_rib_thickness],
                                                      [atm_fuse_holder_2_lid_rib_l,
                                                       atm_fuse_holder_2_lid_rib_h,
                                                       atm_fuse_holder_2_lid_rib_n,
                                                       atm_fuse_holder_2_lid_rib_distance,
                                                       atm_fuse_holder_2_lid_rib_thickness],
                                                      [atm_fuse_holder_body_wiring_d, [[15, 0, 0],
                                                                                       [0, 0, 0]]]],]];

power_lid_toggle_switch_size                     = [38.6, 18.2];
power_lid_toggle_switch_dia                      = 13;
power_lid_toggle_switch_cbore_dia                = 18;

power_lid_toggle_switch_distance_from_bottom     = -1.5;
power_lid_toggle_switch_distance_from_y          = 3;
power_lid_toggle_switch_wall_thickness           = 0;

// ─────────────────────────────────────────────────────────────────────────────
// Switch button placeholder
// ─────────────────────────────────────────────────────────────────────────────

toggle_switch_size                               = [29.4, 15.5, 18];
toggle_switch_metallic_head_h                    = 2;
toggle_switch_thread_d                           = 11.8;
toggle_switch_thread_h                           = 11.2;
toggle_switch_thread_upper_h                     = 8;
toggle_switch_thread_border_w                    = 2;
toggle_switch_nut_out_h                          = toggle_switch_thread_h - toggle_switch_thread_upper_h;
toggle_switch_nut_d                              = 17.5;
toggle_switch_lever_dia_1                        = 3.6;
toggle_switch_lever_dia_2                        = 5.7;
toggle_switch_lever_h                            = 23.0;
toggle_switch_slot_d_tolerance                   = 1.2;
toggle_switch_slot_counterbore_tolerance         = 0.5;

toggle_switch_terminal_size                      = [1.2, 6.0, 9.7];

// ─────────────────────────────────────────────────────────────────────────────
// Control panel with toggle switches near Raspberry PI
// ─────────────────────────────────────────────────────────────────────────────
control_panel_default_toggle_switch_spec         = ["size",
                                                    toggle_switch_size,
                                                    "thread",
                                                    [toggle_switch_thread_d,
                                                     toggle_switch_thread_h,
                                                     toggle_switch_thread_border_w,
                                                     toggle_switch_slot_d_tolerance],
                                                    "nut",
                                                    [toggle_switch_nut_d,
                                                     toggle_switch_nut_out_h,
                                                     toggle_switch_slot_counterbore_tolerance],
                                                    "terminal",
                                                    toggle_switch_terminal_size,
                                                    "lever",
                                                    [toggle_switch_lever_dia_1,
                                                     toggle_switch_lever_dia_2,
                                                     toggle_switch_lever_h],
                                                    "head",
                                                    [toggle_switch_metallic_head_h]];

control_panel_switch_button_specs                = [control_panel_default_toggle_switch_spec,
                                                    control_panel_default_toggle_switch_spec,
                                                    control_panel_default_toggle_switch_spec];

control_panel_thickness                          = toggle_switch_nut_out_h + 2;

// ─────────────────────────────────────────────────────────────────────────────
// Standard (see motor_type) motor brackets dimension
// ─────────────────────────────────────────────────────────────────────────────
standard_motor_bracket_bolt_spacing              = [-0, 0];
standard_motor_bracket_chassis_bolt_hole         = m2_hole_dia;
standard_motor_bracket_motor_bolt_hole           = m3_hole_dia;
standard_motor_bracket_y_offset                  = 0; // distance from the end of the chassis
standard_motor_bracket_width                     = 10;
standard_motor_bracket_thickness                 = 3;
standard_motor_bracket_height                    = 29;

// ─────────────────────────────────────────────────────────────────────────────
// Standard (see motor_type) motor dimensions

// ─────────────────────────────────────────────────────────────────────────────
standard_motor_shaft_color                       = light_grey;

standard_motor_can_color                         = "silver";
standard_motor_endcap_color                      = black_1;

standard_motor_gearbox_body_main_len             = 37;
standard_motor_gearbox_height                    = 22.6;
standard_motor_gearbox_color                     = yellow_1;
standard_motor_gearbox_side_height               = 19.5;
standard_motor_body_neck_len                     = 11.4;
standard_motor_can_len                           = 9.6;
standard_motor_endcap_len                        = 8.5;
standard_motor_shaft_len                         = 35;
standard_motor_shaft_rad                         = 2.8;
standard_motor_shaft_offset                      = 12;

standard_gearbox_neck_rad                        = standard_motor_gearbox_height / 2;
standard_motor_can_rad                           = standard_gearbox_neck_rad  * 0.9;
standard_endcap_rad                              = standard_gearbox_neck_rad  * 0.86;

// ─────────────────────────────────────────────────────────────────────────────
// Step down voltage converter
// ─────────────────────────────────────────────────────────────────────────────
step_down_voltage_regulator_len                  = 40.7;
step_down_voltage_regulator_w                    = 20.4;
step_down_voltage_regulator_thickness            = 1.8;
step_down_voltage_regulator_standoff_h           = 2;

step_down_voltage_bolt_hole_dia                  = 2.1;
step_down_voltage_bolt_x_distance                = 1.5;
step_down_voltage_bolt_y_distance                = 2.54;
step_down_voltage_screw_terminal_holes           = [35.5, 5];

// ─────────────────────────────────────────────────────────────────────────────
// Servo horn
// ─────────────────────────────────────────────────────────────────────────────

// Each arm has the shape of a trapezoid.
// These trapezoids form either a cross (4 arms) or a single bar (2 arms).
// This is the starting width of the arm trapezoid, measured from the center.
servo_horn_starting_arm_w                        = 5.25;
// This is the ending width of the arm trapezoid.
servo_horn_ending_arm_w                          = 4.03;
// A ring is placed at the center where the arms meet. This is the ring's outer diameter.
servo_horn_center_ring_outer_dia                 = 5.90;
// This is the ring's inner diameter.
servo_horn_center_ring_inner_dia                 = 3.87;

// This is the total height of the ring and the horn itself.
servo_horn_ring_height                           = 4.54;

// This is the thickness of each arm.
servo_horn_arm_thickness                         = 1.5;

// This is the Z offset (height) of the arms from the bottom of the ring.
servo_horn_arm_z_offset                          = 2.5;

// This is the through-hole diameter at the center for the servo motor.
servo_horn_center_hole_dia                       = 1.87;

// This is the total length of the horn (two arms + center ring).
servo_horn_len                                   = 24;

// The diameter of fastening screw holes
servo_horn_screw_d                               = 0.8;
// This is the distance between screw holes.
servo_horn_screws_distance                       = 2.84;
// This is the number of screw holes on each arm.
servo_horn_holes_n                               = 2;

// ─────────────────────────────────────────────────────────────────────────────
// Steering servo
// ─────────────────────────────────────────────────────────────────────────────
// Dimensions for the slot that accommodates the steering servo motor.
// Tested with the EMAX ES08MA II servo (23 x 11.5 x 24 mm).
//
// The popular SG90 servo measures approximately 23mm x 12.2mm x 29mm, so you
// may want to adjust steering_servo_slot_width and steering_servo_slot_height
// as needed.

steering_servo_slot_width                        = 12;
steering_servo_slot_height                       = 23.6;
steering_servo_size                              = [23.48, 11.7, 20.3];

// offset between the servo slot and the fastening bolts
steering_servo_bolts_offset                      = 1;

steering_servo_hat_w                             = 33;
steering_servo_hat_h                             = steering_servo_size[1];
steering_servo_hat_thickness                     = 1.6;
steering_bolts_hat_z_offset                      = 4;
steering_servo_gearbox_x_offset                  = 3;
steering_servo_gearbox_mode                      = "hull";
steering_servo_text                              = [["EMAX",
                                                     4,
                                                     "Liberation Sans:style=Bold Italic"],
                                                    ["ES08MA II ANALOG SERVO",
                                                     1.2,
                                                     "Ubuntu:style=Bold"]];
steering_servo_text_size                         = 3;
steering_servo_gearbox_h                         = 4;
steering_servo_gearbox_size                      = [[0.4, 6.09, matte_black],
                                                    [0.5, 4.35, dark_gold_2, 8],
                                                    [0.8, 2, dark_gold_2],
                                                    [2.45, 4, dark_gold_2, 10],
                                                    [0.05, 2.6, licorice, 8]];
steering_servo_gearbox_d1                        = 8;

steering_servo_gearbox_d2                        = 6;
steering_servo_color                             = jet_black;
steering_servo_cutted_len                        = 3;

// ─────────────────────────────────────────────────────────────────────────────
// Steering panel
// ─────────────────────────────────────────────────────────────────────────────

// The length of the panel that holds the rack and the pins for the steering
// knuckles at each side
steering_panel_length                            = 134;

// The width of the panel that holds the rack and the pins for the steering
// knuckles at each side
steering_rack_support_width                      = 8;

// The diameter of the fastening bolts for the servo
steering_servo_bolt_dia                          = 2;

// The thickness of the panel that holds the rack and the pins for the steering
// knuckles at each side
steering_rack_support_thickness                  = 5;

// The thickness of the vertical panel with the servo slot
steering_vertical_panel_thickness                = 3;

// Position of the steering panel relative to the chassis center. This panel
// houses the rack and pinion assembly implementing Ackermann steering geometry
// for the wheels.

steering_panel_distance_from_top                 = 70; // position from the start of the chassis
steering_panel_hinge_length                      = 10;
steering_panel_hinge_w                           = 8;
steering_panel_hinge_x_offset                    = 1;
steering_panel_hinge_corner_rad                  = 0.5;
steering_panel_hinge_bolt_dia                    = m25_hole_dia;
steering_panel_hinge_bore_dia                    = steering_panel_hinge_bolt_dia * 2;
steering_panel_hinge_chassis_bore_dia            = steering_panel_hinge_bolt_dia * 2.2;
steering_panel_hinge_bore_h                      = chassis_counterbore_h;

steering_panel_hinge_bolt_distance               = 1;
steering_panel_hinge_bolt_x_distance             = 1;

// ─────────────────────────────────────────────────────────────────────────────
// Rack and Pinion
// ─────────────────────────────────────────────────────────────────────────────

// Length of the toothed section of the steering rack (excluding side connectors)
steering_rack_teethed_length                     = 45.5;

// The width of the steering rack
steering_rack_width                              = 6;

steering_rack_z_distance_from_panel              = 1;

// The height of the steering rack, excluding the height of the teeth
steering_rack_base_height                        = 7.4;

// The height of the cylindrical pedestals on each side of the rack onto which
// the bearing shaft that connects with the bracket’s bearing is placed
steering_rack_pin_base_height                    = 5;

// The diameter of the steering pinion
steering_pinion_d                                = 28.8;

// The diameter of the hole for the servo at the center of the pinion
steering_pinion_center_hole_dia                  = 6.5;

// Thickness of the pinion
steering_pinion_thickness                        = 2;

// The diamater of the screw holes for the servo arm around the steering_pinion_center_hole_dia
steering_pinion_screw_dia                        = 1.5;

// Number of teeth on the pinion
steering_pinion_teeth_count                      = 24;

steering_pinion_bolts_spacing                    = 0.5;

steering_pinion_bolts_servo_distance             = 0.8;
steering_pinion_clearance                        = 0.1;
steering_pinion_backlash                         = 0.05;

// The number of degrees of the straightness of the tooth
steering_pinion_pressure_angle                   = 20;

// The height of the wider part of the shaft on the L-bracket connector and the
// rack connector. In the first case, this prevents friction between the knuckle
// and the bracket, and in the second case, between the bracket and the rack.
steering_rack_link_bearing_stopper_height        = 1;

// The height of the shaft on the L-bracket connector that is inserted into the
// 685-Z bearing on the knuckle
steering_rack_link_bearing_pin_height            = 5;

// The height of the cylindrical pedestal on which the bearing shaft is placed
// on the bracket
steering_rack_link_bearing_bearing_pin_base_h    = 5;

// The outside diameter of the flanged bearing 693 ZZ / 2Z (3x8x4) that is
// inserted into the bearing connector
steering_rack_link_bearing_outer_d               = 10.0;

// The outside diameter of the flanged bearing 693 ZZ / 2Z (3x8x4) that is
// inserted into the bearing connector
steering_rack_link_bearing_d                     = 8.0;

// The inside diameter (plus tolerance) of the flanged 693 2Z bearing (3x8x4)
steering_rack_link_bearing_shaft_d               = 3.05;

// The height of the bearing placeholder in the bracket assembly
steering_rack_link_bearing_height                = 4;

// The height of the flanges of the bearing placeholder in the bracket assembly
steering_rack_link_bearing_flanged_height        = 0.5;

// The width of the flanges of the bearing placeholder in the bracket assembly
steering_breacket_bearing_flanged_width          = 0.5;

// The width of the L-bracket connector
steering_rack_link_linkage_width                 = 5;

// The thickness of the L-bracket connector
steering_rack_link_linkage_thickness             = steering_rack_link_bearing_bearing_pin_base_h;

// The length of the rail in the center of the steering panel that holds the rack
steering_panel_rail_len                          = steering_panel_length
                                                - knuckle_dia * 2;

steering_panel_rail_rad                          = 0.5;

// The height of the rails at the center of the steering panel that holds the rack
steering_panel_rail_height                       = min(4,
                                                       steering_rack_base_height - 1);

// The tolerance to add to the hole for the rail
steering_rack_rail_tolerance                     = 0.7;

// The thickness of the rail in the center of the steering panel that holds the rack
steering_panel_rail_thickness                    = 2.8;

// The angle of the rail's dovetail rib in the center of the steering panel that holds the rack
steering_panel_rail_angle                        = 30;

steering_rail_edge_land                          = 0.45;

steering_rail_relief_depth                       = 0.12; // 0.12…0.15

steering_rack_anti_tilt_key_thickness            = 0.8;
steering_rack_anti_tilt_rack_x_offset            = -0.3;
steering_rack_anti_tilt_key_height               = steering_rack_z_distance_from_panel + 0.1;

steering_kingpin_post_bolt_dia                   = m25_hole_dia;
steering_kingpin_post_border_w                   = 2;

steering_servo_bolt_distance_from_top            = 1;
steering_servo_mount_width                       = 23.5;
steering_servo_mount_height                      = 39.5;
steering_servo_mount_length                      = 5.5;
steering_servo_mount_connector_length            = 2.5;
steering_servo_mount_connector_thickness         = steering_rack_support_thickness  * 0.65;
steering_servo_mount_connector_bolt_dia          = m3_hole_dia;
steering_servo_mount_connector_bolt_x            = 3;

// Knuckle center along X. Do not edit, used for Ackermann geometry calculations
steering_x_left_knuckle                          = -steering_panel_length / 2
                                                + knuckle_dia / 2;

// Diameter and width of the tie rod
tie_rod_outer_dia                                = 14.0;

// The outside diameter of the 685-Z bearing (5x11x5) that is inserted into the
// tie rod
tie_rod_bearing_outer_dia                        = 11.0;

// The inside diameter (plus tolerance) of the 685-Z bearing (5x11x5).
// They are placed on the each side of the steering panel
tie_rod_bearing_inner_dia                        = 5.20;

// The height of the 685-Z bearing placeholder used in the tie rod assembly
tie_rod_bearing_height                           = 5;

// The height of the flange of the 685-Z bearing placeholder
tie_rod_bearing_flanged_height                   = 0.5;

// The width of the 685-Z bearing placeholder used in the tie rod assembly
tie_rod_bearing_flanged_width                    = 0.5;

// The thickness of the tie rod
tie_rod_thickness                                = tie_rod_bearing_height + 0.5;

tie_rod_bearing_x_offset                         = 2;

tie_rod_shaft_dia                                = 8.0;

tie_rod_shaft_knuckle_arm_dia                    = tie_rod_shaft_dia * 1.4;
tie_rod_shaft_bolt_dia                           = m2_hole_dia;
tie_rod_shaft_bolt_offset                        = 1;
tie_rod_shaft_bolt_distance                      = 2.0;
tie_rod_shaft_len                                = knuckle_shaft_vertical_len + 6;

tie_rod_shaft_knuckle_arm_height                 = 9;
tie_rod_shaft_bearing_pin_height                 = 8;
tie_rod_shaft_bearing_pin_chamfer_height         = 1.5;

// ─────────────────────────────────────────────────────────────────────────────
// Ultrasonic placeholder
// ─────────────────────────────────────────────────────────────────────────────

ultrasonic_w                                     = 45.42;
ultrasonic_h                                     = 20.5;
ultrasonic_thickness                             = 1.25;
ultrasonic_offset_rad                            = 0.5;

ultrasonic_text_size                             = 1.5;

ultrasonic_transducer_dia                        = 15.88;
ultrasonic_transducer_inner_dia                  = 12.75;
ultrasonic_transducer_h                          = 12.25;

// distance from the side of the panel
ultrasonic_transducer_x_offset                   = 1.5;

ultrasonic_pins_jack_w                           = 11.20;
ultrasonic_pins_jack_h                           = 2.50;
ultrasonic_pins_jack_thickness                   = 2.0;
ultrasonic_pins_jack_y_offset                    = 1;

ultrasonic_pins_count                            = 4;
ultrasonic_pin_len_a                             = 7.84;
ultrasonic_pin_len_b                             = 5.84;
ultrasonic_pin_protrusion_h                      = 2;

ultrasonic_pin_thickness                         = 0.5;

ultrasonic_oscillator_h                          = 3.5;
ultrasonic_oscillator_w                          = 9.86;
ultrasonic_oscillator_thickness                  = 3.33;
ultrasonic_oscillator_y_offset                   = 0.8;
ultrasonic_oscillator_solder_x                   = 2;

ultrasonic_bolt_dia                              = 2.0;
ultrasonic_bolt_spacing                          = [42.0, 17.50];

ultrasonic_smd_len                               = 8;
ultrasonic_smd_h                                 = 1.65;
ultrasonic_smd_led_thickness                     = 0.4;
ultrasonic_smd_led_count                         = 7;
ultrasonic_smd_w                                 = 7.55;
ultrasonic_smd_chip_w                            = 4.0;
ultrasonic_smd_x_offst                           = 1.0;
ultrasonic_solder_blob_d                         = 2.07;
ultrasonic_solder_blobs_positions                = [26, 10];

// ─────────────────────────────────────────────────────────────────────────────
// Parameters for wheels, common for front and rear
// ─────────────────────────────────────────────────────────────────────────────
wheel_dia                                        = 42;
wheel_w                                          = 20.0;
wheel_thickness                                  = 2.0;
wheel_rim_h                                      = 1.2;
wheel_rim_w                                      = 1;
wheel_rim_bend                                   = 0.8;

// ─────────────────────────────────────────────────────────────────────────────
// Front wheels
// ─────────────────────────────────────────────────────────────────────────────
wheel_hub_outer_d                                = wheel_dia - wheel_thickness * 2;
wheel_hub_outer_ring_d                           = wheel_hub_outer_d;
wheel_hub_d                                      = 22;
wheel_hub_h                                      = 7.2;
wheel_hub_inner_rim_h                            = 1.4;
wheel_hub_inner_rim_w                            = 1.2;
wheel_hub_bolt_dia                               = m25_hole_dia;
wheel_bolts_n                                    = 6;
wheel_bolt_boss_w                                = 1;
wheel_bolt_boss_h                                = 2;

// ─────────────────────────────────────────────────────────────────────────────
// Rear wheels
// ─────────────────────────────────────────────────────────────────────────────

// Height of the shaft protruding above the wheel
wheel_rear_shaft_protrusion_height               = 10.8;

// Number of rear wheel spokes.
wheel_rear_spokes_count                          = 5;

// Width of rear wheel spokes.
wheel_rear_wheel_spoke_w                         = 18.8;

// The outer diameter of the rear wheel’s shaft. The hole for the motor’s shaft
// is located within this shaft.
wheel_rear_shaft_outer_dia                       = 9.8;

// The inner diameter of the hole for the motor’s shaft in the rear wheel’s
// shaft.
wheel_rear_shaft_inner_dia                       = motor_type == "n20" ? 3.1 : 5.2;

// Number of flat sections on the motor shaft.
// Common values:
//   - 0: round shaft (e.g., basic toy motors)
//   - 1: single flat (e.g., an N20 motor)
//   - 2: dual flats (e.g., yellow plastic gear motors)
wheel_rear_shaft_flat_count                      = motor_type == "n20" ? 1 : 2;

// Length of each flat section on the shaft in millimeters. Measured along the
// shaft’s axis. This value affects the depth of the hub keying feature.
wheel_rear_shaft_flat_len                        = motor_type == "n20" ? 2 : 5;

// The height of the rear wheel’s shaft.
wheel_rear_motor_shaft_height                    = 10;

// ─────────────────────────────────────────────────────────────────────────────
// Tires
// ─────────────────────────────────────────────────────────────────────────────

// A small radial offset applied during the subtraction operation to slightly
// enlarge the cut-out, providing extra clearance between the tire and adjacent
// wheel elements.
wheel_tire_offset                                = 0.5;

// The gap value used in the offset operation to round the corners of the tire
// cross-section.
wheel_tire_fillet_gap                            = 0.5;

// The added thickness to the wheel's inner radius for computing the overall
// cross-sectional depth of the tire.
wheel_tire_thickness                             = 9.0;

// The effective width of the tire
wheel_tire_width                                 = wheel_w - wheel_rim_w;

// The polygon facet count used with circle-based operations
wheel_tire_fn                                    = 360;

wheel_tire_num_grooves                           = 34;
wheel_tire_groove_thickness                      = 0.4;
wheel_tire_groove_depth                          = 3.4;

// ─────────────────────────────────────────────────────────────────────────────
// Ackermann geometry
// ─────────────────────────────────────────────────────────────────────────────

// center of the left wheel
wheel_center_offset                              = wheel_w / 2 +
                                                (wheel_rear_shaft_protrusion_height
                                                 - (knuckle_shaft_dia / 2));

// distance between centers of the front wheels
wheels_track_width                               = steering_panel_length
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
steering_rack_link_bearing_border_w              = (steering_rack_link_bearing_outer_d
                                                    - steering_rack_link_bearing_d)
                                                / 2;

// X-coordinate of the steering-rack bearing connector center
steering_rack_connector_x_pos                    = -steering_rack_teethed_length
                                                / 2
                                                - steering_rack_link_bearing_outer_d
                                                / 2
                                                + steering_rack_link_bearing_border_w;

// X-axis distance between the kingpin post and the steering-rack bearing connector center
steering_distance_between_kingpin_and_rack       = abs(steering_x_left_knuckle)
                                                - abs(steering_rack_connector_x_pos);

// The length of the L-bracket part that is connected to the rack
steering_rack_link_rack_side_h_length            = knuckle_shaft_connector_extra_len
                                                + knuckle_shaft_connector_dia
                                                + knuckle_shaft_connector_extra_arm_len
                                                + steering_rack_link_bearing_outer_d / 2
                                                + steering_rack_link_bearing_border_w;

// The length of the L-shaped rack link that is connected to the knuckle
steering_rack_link_rack_side_w_length            = steering_distance_between_kingpin_and_rack
                                                - steering_rack_link_bearing_d
                                                - steering_rack_link_bearing_border_w;

// wheelbase, calculated from the center of the rear axle
steering_wheelbase_effective                     = abs(chassis_len
                                                       - steering_panel_distance_from_top
                                                       - n20_motor_bolts_panel_len / 2
                                                       - n20_motor_chassis_y_distance);

// The angle of the tie-rod arms that forms the Ackermann trapezoid
steering_angle_deg                               = atan(abs(steering_x_left_knuckle / steering_wheelbase_effective));

// "Technical" angle of the tie-rod arms required due to the knuckle's implementation details
steering_alpha_deg                               = steering_angle_deg + 90;

// Length of the tie rod
// Distance between the bearing centers on the tie rod (Ackermann top width)
tie_rod_bearing_center_distance                  = calc_isosceles_trapezoid_top_width(steering_panel_length - knuckle_dia,
                                                                                      steering_arm_full_len,
                                                                                      steering_angle_deg);

// Overall tie rod length including bearing landings and offsets
tie_rod_len                                      = tie_rod_bearing_center_distance
                                                + tie_rod_bearing_outer_dia
                                                + tie_rod_bearing_x_offset * 2;
// Local Variables:
// c-label-minimum-indentation: 48
// End:
