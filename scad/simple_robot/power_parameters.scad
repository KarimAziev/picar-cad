/**
 * Module: Simple robot power parameters
 *
 * Legacy power dimensions and layout defaults in millimeters.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>

// ─────────────────────────────────────────────────────────────────────────────
// Power module case dimensions
// ─────────────────────────────────────────────────────────────────────────────

// External width of the power module case (X dimension).
// This is the full outside width including side walls and rails.
power_case_width                                     = lipo_pack_width + 5.4;

// External length of the power module case (Y dimension).
// This is the full outside length of the battery case including front/back walls.
power_case_length                                    = lipo_pack_length + 7.6;

// External height of the base case body (Z dimension) measured to the top face
// of the main case (does not include the dovetail rails mounted above).
power_case_height                                    = lipo_pack_height + 6.6;

power_case_round_rad                                 = 1; // Corner radius for rounded exterior geometry.
// ─────────────────────────────────────────────────────────────────────────────
// Side wall ventilation slot parameters
// ─────────────────────────────────────────────────────────────────────────────

// depth of each slot (extent into the model in Z when slots are created).
power_case_side_slot_h                               = 10;
// Vent/slot parameters (for the case top/side ventilation slots).
// slot width (slot_w) is the narrow dimension of each rectangular vent slot.
power_case_side_slot_w                               = 2.8;

// distance between adjacent slot centers (slot gap) measured in the same axis as slot width spacing.
power_case_side_slot_gap                             = 5.6;

power_case_side_slot_padding_z                       = 7.0;
power_case_side_slot_padding_x                       = 30.0;

power_case_side_slot_gap_z                           = 4.6;

// Height of the front and back (end) walls of the case (Z dimension).
// These end walls are shorter than the side walls to allow the battery XT90/ balance
// leads and connector to exit from the top. Used to position slot cutouts and the
// top pocket height relative to the inner battery compartment.
power_case_front_back_wall_h                         = 34;

// Thickness of the front and back (end) walls
power_case_front_wall_thickness                      = (power_case_length - (lipo_pack_length + 0.4)) / 2;

// ─────────────────────────────────────────────────────────────────────────────
// Slots in front and rear panels of the Power case
// ─────────────────────────────────────────────────────────────────────────────

// depth of each slot (extent into the model in Z when slots are created).
power_case_front_slot_h                              = 10;

// Vent/slot parameters (for the case side ventilation slots).
// slot width (slot_w) is the narrow dimension of each rectangular vent slot.
power_case_front_slot_w                              = 2.8;

// distance between adjacent slot centers (slot gap) measured in the same axis as slot width spacing.
power_case_front_slot_gap                            = 3.6;

power_case_front_slot_padding_z                      = 4.0;
power_case_front_slot_padding_x                      = 5.0;

power_case_front_slot_gap_z                          = 3.9;

// ─────────────────────────────────────────────────────────────────────────────
// Power module case bottom wall and mounting bolts
// ─────────────────────────────────────────────────────────────────────────────

// Thickness of the bottom wall (floor) of the case.
// This affects internal clearance and bolt/counterbore depths.
power_case_bottom_thickness                          = 2.0;

// The X and Y spacing for the 4 corner mounting bolt positions.
// Provided as [X_spacing, Y_spacing]. These define the square/rectangle on which
// the four mounting holes are placed; used by four_corner_children/four_corner_holes.

power_case_bottom_bolt_spacing                       = [40, 88];
// Bolt/cutout sizes for mounting the power module to the chassis.
// The bolt hole diameter for through holes in the bottom/back wall.
power_case_bottom_bolt_dia                           = m3_hole_dia;

power_case_bottom_bolt_head_type                     = "round";

// Counterbore diameter for the bolt head recess on the bottom/back wall.
// This is the larger diameter of the counterbore so the bolt head can sit flush.
power_case_bottom_cbore_dia                          = 6.0;

power_case_bottom_cbore_h                            = 1.0;

power_case_chassis_x_offset                          = 0;
power_case_chassis_y_offset                          = 0;

power_case_bolt_spacing_offset_x                     = 0;
power_case_bolt_spacing_offset_y                     = 18;

power_case_standoff_h                                = 10;
power_case_standoff_thread_h                         = 5;

// ─────────────────────────────────────────────────────────────────────────────
// Power socket case
// ─────────────────────────────────────────────────────────────────────────────

power_socket_bolt_lid_mounting_spacing               = [35, 90];

power_socket_case_front_thickness                    = 4;
power_socket_case_bottom_thickness                   = 2;
power_socket_case_side_thickness                     = 2.0;
power_socket_case_lid_thickness                      = 3.0;

power_socket_case_fn                                 = 100;
power_socket_case_corner_rad                         = 1;
power_socket_case_rim_h                              = 3;
power_socket_case_rim_w                              = 2;
power_socket_case_use_rim_sizing                     = true;
power_socket_case_use_inner_round                    = false;
power_socket_case_rim_front_w                        = 1;
power_socket_case_latch_h                            = 0.5;
power_socket_case_latch_l                            = 10;
power_socket_case_rail_thickness                     = 1;
power_socket_case_rail_tolerance                     = 0.4;
power_socket_case_hook_h                             = 0.42;
power_socket_case_hook_distance                      = 0.6;
power_socket_case_hook_l                             = 5;
power_socket_case_rail_top_thickness                 = 1;

power_socket_case_jack_plist                         = ["type", "custom",
                                                        "placeholder", "xt90e_m",
                                                        "placeholder_size", xt60be_mounting_panel_size,
                                                        "slot_size", xt_60_size,
                                                        "shell_size", xt60be_size,
                                                        "mounting_panel_size", xt60be_mounting_panel_size,
                                                        "bolt_spacing", xt_60_bolt_spacing,
                                                        "align", 1,
                                                        "gap_before", 5,
                                                        "mount_spacing", xt60be_mount_spacing,
                                                        "mount_dia", xt60be_mount_dia,
                                                        "mount_bore_dia", xt60be_mount_cbore_dia,
                                                        "mount_bore_h", xt60be_mount_cbore_h,
                                                        "r_factor", 0.3,
                                                        "shell_r_factor", 0.5,
                                                        "contact_d", xt60be_contact_dia,
                                                        "contact_h", xt60be_contact_h,
                                                        "contact_wall_h", xt60be_contact_wall_h,
                                                        "contact_base_h", xt60be_contact_base_h,
                                                        "contact_thickness", xt60be_contact_thickness,
                                                        "pin_color", xt60be_pin_color,
                                                        "pin_spacing", xt60be_pin_spacing,
                                                        "pin_dia", xt60be_pin_dia,
                                                        "pin_length", xt60be_pin_length,
                                                        "pin_thickness", xt60be_pin_thickness,
                                                        "shell_color", xt60be_shell_color,
                                                        "bolt_head_type", "pan",
                                                        "round_side", "bottom",
                                                        "gnd_wiring_color", matte_black,
                                                        "gnd_wiring", [[3, 0, 70],
                                                                       [0, 0, 138],
                                                                       [-40, 0, 138]],
                                                        "vcc_wiring", [[0, 0, 20],
                                                                       [0, -20, 70]],
                                                        "vcc_wiring_color", red_1];

power_socket_case_side_panel_slots                   = [["placeholder", "atm_fuse_holder",
                                                         "recess_reverse", false,
                                                         "type", "rect",
                                                         "x_offset", 30,
                                                         "y_offset", 2,
                                                         "rotation", 0,
                                                         "slot_size", [atm_fuse_holder_mounting_hole_l + 1,
                                                                       atm_fuse_holder_mounting_hole_h + 2],
                                                         "corner_rad", atm_fuse_holder_mounting_hole_r,
                                                         "placeholder_size", [max(atm_fuse_holder_body_top_l,
                                                                                  atm_fuse_holder_body_bottom_l)
                                                                              + 40,
                                                                              atm_fuse_holder_body_thickness],
                                                         "body", ["size", [atm_fuse_holder_body_bottom_l,
                                                                           atm_fuse_holder_body_thickness,
                                                                           atm_fuse_holder_body_h,
                                                                           atm_fuse_holder_body_top_l],
                                                                  "corner_rad", 2,
                                                                  "round_side", "bottom",
                                                                  "rib", ["h", atm_fuse_holder_body_rib_h,
                                                                          "l", atm_fuse_holder_body_rib_l,
                                                                          "n", atm_fuse_holder_body_rib_n,
                                                                          "front_thickness", atm_fuse_holder_body_rib_thickness,
                                                                          "distance_from_top", 0]],
                                                         "wiring", ["d", atm_fuse_holder_body_wiring_d,
                                                                    "socket_type", "cylinder",
                                                                    "socket_type_len", 5,
                                                                    "color", red_1,
                                                                    "cut_len", 3,
                                                                    "left_pts", [[20, 0, 0],
                                                                                 [-25, 0, -45]],
                                                                    "right_pts", [[10, 0, 0],
                                                                                  [25, 2, -6]]],
                                                         "color", matte_black_2,
                                                         "show_cap", false,
                                                         "show_body", true,
                                                         "cap_collar", ["size", [atm_fuse_holder_mounting_hole_l - 2,
                                                                                 atm_fuse_holder_mounting_hole_h,
                                                                                 atm_fuse_holder_mounting_hole_depth],
                                                                        "r", atm_fuse_holder_mounting_hole_r,
                                                                        "fuse_holes_spacing", [8, 4],
                                                                        "fuse_hole_size", [6.0, 1.82],
                                                                        "fuse_holes_pad_x", 4,
                                                                        "fuse_holes_pad_y", 0,
                                                                        "rib_thickness", 1,
                                                                        "rib_h", 0.8,
                                                                        "colr", matte_black,
                                                                        "rib_colr", matte_black_2,
                                                                        "rib_positions", [0.5]],
                                                         "cap", ["size", [atm_fuse_holder_cap_top_l,
                                                                          atm_fuse_holder_cap_thickness,
                                                                          atm_fuse_holder_cap_h,
                                                                          atm_fuse_holder_cap_bottom_l,],
                                                                 "corner_rad", 2,
                                                                 "round_side", "top",
                                                                 "color", matte_black_2,
                                                                 "rib", ["h", atm_fuse_holder_cap_rib_h,
                                                                         "l", atm_fuse_holder_cap_rib_l,
                                                                         "n", atm_fuse_holder_cap_rib_n,
                                                                         "front_thickness", atm_fuse_holder_cap_rib_thickness,
                                                                         "distance_from_top", atm_fuse_holder_cap_rib_distance]]]];

power_socket_case_mounting_panel_size                = plist_get("placeholder_size",
                                                                 power_socket_case_jack_plist,
                                                                 xt60be_mounting_panel_size);
power_socket_case_mounting_panel_h                   = power_socket_case_mounting_panel_size[0];
power_socket_case_size                               = [power_case_width,
                                                        power_case_length,
                                                        power_socket_case_mounting_panel_h
                                                        + power_socket_case_bottom_thickness
                                                        + power_socket_case_rim_h];

// ─────────────────────────────────────────────────────────────────────────────
// Power module case dovetail rail parameters
// ─────────────────────────────────────────────────────────────────────────────

// Dovetail rail geometry parameters (for mounting a secondary module on top).
// Angle (deg) of the dovetail sides relative to vertical (controls trapezoid slope).
power_case_rail_angle                                = 20;

// Fillet radius applied to dovetail profile (0 = sharp corners).
power_case_rail_rad                                  = 0.0;

// Vertical thickness of the rail profile (height of the dovetail section).
power_case_rail_height                               = 4;

// Diameter of bolt\ holes that run through the rail for mounting hardware.
power_case_rail_bolt_dia                             = m25_hole_dia + 0.1;

// Distance from the end of the rail and mounting holes
power_case_rail_hole_distance_from_edge              = 30.25;

// Internal side wall thickness computed from overall width and the bolt pattern.
// This determines the width of the side wall between the central battery pocket and outer shell.
// Changing the bolt pose values will change this computed thickness.
power_case_side_wall_thickness                       = 2.3;

power_lid_extra_side_thickness                       = 2;

// The tolerance to add to the hole for the rail
power_case_rail_tolerance                            = 0.4;

power_case_rail_relief_depth                         = 0.12; // 0.12…0.15

power_lid_height                                     = 16.5;
power_lid_width                                      = power_case_width + power_case_side_wall_thickness + power_case_rail_tolerance / 2;

power_lid_thickness                                  = 2;
