/**
 * Module: Parameters
 * This file defines most of the robot parameters
 * All dimensions are in millimeters (mm)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <bolt_parameters.scad>
include <colors.scad>

use <lib/functions.scad>
use <lib/plist.scad>

// Shared chassis defaults for suspension, panel mounts and hardware.
chassis_thickness                                    = 6.0; // [2.0:10.0]
chassis_counterbore_h                                = 2.2; // The depth of counterbores on the chassis

// ─────────────────────────────────────────────────────────────────────────────
// ATC ATO Blade Fuse Holder
// ─────────────────────────────────────────────────────────────────────────────

atc_ato_blade_fuse_holder_top_cover_h                = 35.3;
atc_ato_blade_fuse_holder_top_cover_w                = 27.10;
atc_ato_blade_fuse_holder_top_cover_thickness        = 13.9;
atc_ato_blade_fuse_holder_top_rad                    = 5;

atc_ato_blade_fuse_holder_top_joint_h                = 7.8;
atc_ato_blade_fuse_holder_top_joint_thickness        = 1.5;

atc_ato_blade_mounting_wall_h                        = 17.45;
atc_ato_blade_mounting_wall_w                        = 25.0;
atc_ato_blade_mounting_wall_thickness                = 3.30;

atc_ato_blade_fuse_holder_bottom_cover_h             = 12.22;
atc_ato_blade_fuse_holder_bottom_cover_w             = 24;
atc_ato_blade_fuse_holder_bottom_cover_thickness     = 14.56;
atc_ato_blade_fuse_holder_bottom_rad                 = 5;

// ─────────────────────────────────────────────────────────────────────────────
// Inline ATM fuse holder
// ─────────────────────────────────────────────────────────────────────────────

atm_fuse_holder_body_wiring_d                        = 3.8;
atm_fuse_holder_body_bottom_l                        = 28.50;
atm_fuse_holder_body_top_l                           = 28.9;
atm_fuse_holder_body_h                               = 15.070;
atm_fuse_holder_body_thickness                       = 12.20;

atm_fuse_holder_cap_thickness                        = 11.60;
atm_fuse_holder_cap_top_l                            = 24.60;
atm_fuse_holder_cap_bottom_l                         = 23.07;
atm_fuse_holder_cap_h                                = 21.64;

atm_fuse_holder_body_rib_thickness                   = 1.0;
atm_fuse_holder_body_rib_h                           = 10.00;
atm_fuse_holder_body_rib_l                           = 19.03;
// number of the ribs
atm_fuse_holder_body_rib_n                           = 5;

atm_fuse_holder_cap_rib_thickness                    = 1.0;
atm_fuse_holder_cap_rib_h                            = 14.30;

atm_fuse_holder_cap_rib_l                            = 13.3;
// number of the ribs
atm_fuse_holder_cap_rib_n                            = 7;
atm_fuse_holder_cap_rib_distance                     = 7.22;

atm_fuse_holder_mounting_hole_l                      = 22.0;
atm_fuse_holder_mounting_hole_h                      = 8.0;
atm_fuse_holder_mounting_hole_depth                  = 5.2;
atm_fuse_holder_mounting_hole_r                      = 5.0;

atm_fuse_holder_cap_hole_size                        = [atm_fuse_holder_mounting_hole_l * 0.8,
                                                        atm_fuse_holder_mounting_hole_h,
                                                        atm_fuse_holder_cap_h * 0.8];

// ─────────────────────────────────────────────────────────────────────────────
// Fuse holder
// ─────────────────────────────────────────────────────────────────────────────
fuse_panel_thickness                                 = 3;

atm_fuse_default_plist                               = ["placeholder", "atm_fuse_holder",
                                                        "type", "rect",
                                                        "slot_size", [atm_fuse_holder_mounting_hole_l + 1,
                                                                      atm_fuse_holder_mounting_hole_h + 2],
                                                        "corner_rad", atm_fuse_holder_mounting_hole_r,
                                                        "placeholder_size", [max(atm_fuse_holder_body_top_l,
                                                                                 atm_fuse_holder_body_bottom_l)
                                                                             + 12,
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
                                                                         "thickness", atm_fuse_holder_body_rib_thickness,
                                                                         "distance_from_top", 0]],
                                                        "wiring", ["d", atm_fuse_holder_body_wiring_d,
                                                                   "socket_type", "cylinder",
                                                                   "socket_type_len", 5,
                                                                   "color", red_1,
                                                                   "cut_len", 3,
                                                                   "left_pts", [[25, 0, 0]],
                                                                   "right_pts", [[25, 0, 0]]],
                                                        "color", matte_black_2,
                                                        "show_cap", true,
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
                                                                        "thickness", atm_fuse_holder_cap_rib_thickness,
                                                                        "distance_from_top", atm_fuse_holder_cap_rib_distance]]];

as5048A_encoder_plist                                = ["size", [14.75, 17.1, 1.74],
                                                        "bolt_d", m2_hole_dia,
                                                        "bolt_spacing", [11.44, 0],
                                                        "lock_nut", true,
                                                        "bolt_head_type", "pan",
                                                        "chamfer_size", 3,
                                                        "corner_r", 1,
                                                        "color", graphite_grey_1,
                                                        // Connectors occupy the face opposite the sensor IC.
                                                        "show_jst_shr", true,
                                                        "show_pins", true,
                                                        "connector_clearance", 0.2,
                                                        "jst_shr", ["contacts", 6,
                                                                    "pitch", 1,
                                                                    "size", [9.7, 4.83, 3.4]],
                                                        "pins", ["h", 4.56,
                                                                 "body_h", 2.5,
                                                                 "pin_w", 0.64,
                                                                 "tail_l", 6],
                                                        "sensor_ic", ["placeholder_size", [5.19,
                                                                                           7.5],
                                                                      "chip_size", [5.19, 4.26, 0.84],
                                                                      "text_rows", ["AS5048A",
                                                                                    "2524MAZ",
                                                                                    "AMU1"],
                                                                      "text_props", ["size", 0.8,
                                                                                     "gap", 0.4,
                                                                                     "color", "grey",
                                                                                     "spacing", 0.9,
                                                                                     "valign", "center",
                                                                                     "halign", "center"],
                                                                      "j_lead", [["count", 7,
                                                                                  "thickness", 0.3,
                                                                                  "sides", ["top", "bottom"]]],
                                                                      "rotation", [0, 0, 180]],
                                                        // optional interface contact pads, mainly SPI + power
                                                        "interface_pads", ["cols", 8,
                                                                           "gap", 0.5,
                                                                           "w", 0.7,
                                                                           "l", 3.6,
                                                                           "side", "top", // top | bottom | left | right
                                                                           "padding", 0.3,
                                                                           "color", metallic_silver_1,
                                                                           "text_props", ["size", 0.4,
                                                                                          "gap", 0.2,
                                                                                          "rotation", [0, 0, 90],
                                                                                          "valign", "center",
                                                                                          "spacing", 0.85],
                                                                           "texts", [["bottom", ["text", "GND",
                                                                                                 "color", "black",
                                                                                                 "rotation", [0, 0, 0],
                                                                                                 "spacing", 0.9,
                                                                                                 "gap", 0.5,]],
                                                                                     ["bottom", ["text", "CSN",
                                                                                                 "color", "orange",
                                                                                                 "spacing", 1]],
                                                                                     ["bottom", ["text", "CLK",
                                                                                                 "color", "yellow",
                                                                                                 "spacing", 0.9,
                                                                                                 "rotation", [0, 0, 0]]],
                                                                                     ["bottom", ["text", "MOSI",
                                                                                                 "color", "green",
                                                                                                 "rotation", [0, 0, 0]]],
                                                                                     ["bottom", ["text", "MISO",
                                                                                                 "color", cobalt_blue_metallic,
                                                                                                 "rotation", [0, 0, 0],]],
                                                                                     ["bottom", ["text", "5V",
                                                                                                 "color", "red",
                                                                                                 "rotation", [0, 0, 0],
                                                                                                 "size", 0.5]],
                                                                                     ["bottom", ["text", "GND",
                                                                                                 "color", "black",
                                                                                                 "spacing", 0.9,
                                                                                                 "size", 0.5]],
                                                                                     ["bottom", ["text", "GND",
                                                                                                 "color", "black",
                                                                                                 "spacing", 0.9,
                                                                                                 "size", 0.5]],]],
                                                        // optional large solder pads for wires - GND, power, PWM
                                                        "wire_pads", ["cols", 3,
                                                                      "gap", 0.8,
                                                                      "w", 1.9,
                                                                      "l", 2.71,
                                                                      "color", metallic_silver_1,
                                                                      "r_factor", 0.5,
                                                                      "fn", 24,
                                                                      "side", "bottom", // top | bottom | left | right
                                                                      "padding", 0.7,
                                                                      "text_props", ["size", 0.8,
                                                                                     "gap", 0.2,
                                                                                     "height", 0.11,
                                                                                     "valign", "center"],
                                                                      "texts", [["top", ["text", "GND",
                                                                                         "color", "black"]],
                                                                                ["top", ["text", "V5",
                                                                                         "color", "red",]],
                                                                                ["top", ["text", "PWM",
                                                                                         "color", "yellow",]]]],
                                                        "ceramic_capacitors", ["props", ["placeholder_size", [1.82, 0.9, 0.76]],
                                                                               "cols", 2,
                                                                               "gap", 6.7,
                                                                               "side", "bottom",
                                                                               "padding", 4.6,
                                                                               "texts", [["before", ["text", "C2",
                                                                                                     "size", 0.9,
                                                                                                     "color", metallic_silver_5,
                                                                                                     "gap", 0.3]],
                                                                                         ["after", ["text", "C1",
                                                                                                    "size", 0.9,
                                                                                                    "color", metallic_silver_5,
                                                                                                    "gap", 0.3]]]]];

panel_stack_bolt_dia                                 = m3_hole_dia;
panel_stack_bolt_cbore_dia                           = panel_stack_bolt_dia * 2;
panel_stack_corner_radius_factor                     = 0.05;
panel_stack_bolt_padding                             = 2;
panel_stack_padding_x                                = 2;
panel_stack_padding_y                                = 1;

fuse_panel_plist_specs                               = concat(repeat(plist_merge(atm_fuse_default_plist,
                                                                                 ["gap_after", 2,
                                                                                  "cap_to_bottom", true,
                                                                                  "wiring", plist_put("cut_len", 0,
                                                                                                      plist_get("wiring", atm_fuse_default_plist))]),
                                                                     3));

panel_stack_orientation                              = "wlh"; // wlh | lwh

control_panel_row_gap                                = 0.8;

// Each element is a list of: [diameter, body diameter, thread height, [body heights], number of vertices, color]
standoff_specs                                       = [["thread_d", 3,
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
// whether to make holes for UPS on the chassis
battery_ups_holes_enabled                            = false;
battery_ups_size                                     = [93, 60, 1.82];
battery_ups_holder_size                              = [77.8, 60, 22.0];
battery_ups_holder_thickness                         = 1.86;

// Y offset for the UPS HAT slot, measured from the end of the chassis
battery_ups_offset                                   = 0;

// The Y and X dimensions of the bolt positions for the UPS HAT slot.
// This forms a square with a bolt hole centered on each corner.
battery_ups_module_bolt_spacing                      = [86, 46];

// the diameter for fastening bolts
battery_ups_bolt_dia                                 = m3_hole_dia;

// ─────────────────────────────────────────────────────────────────────────────
// 18650 battery dimensions
// ─────────────────────────────────────────────────────────────────────────────

battery_18650_dia                                    = 18;
battery_18650_h                                      = 65.0;

// ─────────────────────────────────────────────────────────────────────────────
// 21700 battery dimensions
// ─────────────────────────────────────────────────────────────────────────────

battery_21700_dia                                    = 21;
battery_21700_h                                      = 70.0;

// ─────────────────────────────────────────────────────────────────────────────
// Default battery dimensions
// ─────────────────────────────────────────────────────────────────────────────

// The default battery diameter to use in battery holders.
battery_dia                                          = battery_18650_dia;
// The default battery height to use in battery holders.
battery_length                                       = battery_18650_h;

// Positive terminal (top) height.
battery_positive_pole_height                         = 1.0;

// Positive terminal (top) diameter.
battery_positive_pole_dia                            = 5.63;

// ─────────────────────────────────────────────────────────────────────────────
// Default battery holder parameters
// ─────────────────────────────────────────────────────────────────────────────

// Two side-wall styles: skeleton or enclosed.
battery_holder_side_wall_type                        = "skeleton"; // [enclosed: Enclosed, skeleton: Skeleton (open frame)]

// Default number of battery cells to use.
battery_holder_cell_count                            = 2;

// Height of the holder walls between cells.
battery_holder_divider_wall_h                        = 10;

// Diameter of the mounting bolt.
battery_holder_bolt_dia                              = m3_hole_dia;

// Terminal type: circular contact with a helical spring (positive polarity) or
// rectangular external tabs.
battery_holder_terminal_type                         = "solder_tab"; // [coil_spring: Circular contact with a helical spring, solder_tab: Rectangular external connection-style tabs]

/* [Parameters of the slot for squared external connection-style tabs (solder_tab)] */
// The additional length to add to the cutout for the external terminal contact.
battery_holder_tab_slot_extra_len                    = 5;
// The additional width to add to the cutout for the terminal contact.
battery_holder_tab_slot_extra_w                      = 4;

// Diameter of the hole on the terminal contact (placeholder setting only).
battery_holder_tab_hole_d                            = 1;

battery_holder_mount_type                            = "intercell"; // [under_cell: Under each cell, intercell: Between the cells]

/* [Intercell battery holder parameters] */
// Bolt spacing is applied only when battery_holder_mount_type == "intercell",
// because in under-cell style holders the bolts are placed at the center of each cell.
battery_holder_bolt_spacing                          = [0, 56.0];
// Squared recess size around the mounting-bolt holes on the inner wall of the placeholder.
battery_holder_bolt_recess_size                      = [9, 5, 2];

/* [Common battery holder parameters] */
// Bottom thickness of the holder. Note: intercell mount type doesn't have a solid
// bottom, since it has cutouts between cells.
battery_holder_bottom_thickness                      = 1.2;
// Thickness of the front and rear walls.
battery_holder_front_rear_thickness                  = 3.6;
// Thickness of the inner walls.
battery_holder_inner_thickness                       = 0.9;
// Thickness of the side walls.
battery_holder_side_thickness                        = 1.8;

// ─────────────────────────────────────────────────────────────────────────────
// Camera's placeholder dimensions
// ─────────────────────────────────────────────────────────────────────────────
camera_w                                             = 25;
camera_h                                             = 24;
camera_thickness                                     = 1.05;
camera_lens_items                                    = [[8.05, 8.05, 1.0, matte_black, "cube"],
                                                        [11.05, 11.05, 1.5, matte_black, "cube"],
                                                        [11.05, 11.05, 2.9, metallic_silver_7, "cube"],
                                                        [11.05, 11.05, 0.5, metallic_silver_8, "octagon"],
                                                        [7.15, 0, 3.03, matte_black,
                                                         "circle", 30],
                                                        [3.03, 0, 0.1, cobalt_blue_metallic,
                                                         "circle", 15]];

camera_lens_connectors                               = [[6.0, 3.2, 1.5, matte_black, "cube"],
                                                        [6.0, 0.5, 1.5, "darkgoldenrod", "cube"],
                                                        [8.0, 4.0, 1.5, onyx, "cube", -1]];

camera_lens_distance_from_top                        = 9;
camera_bolt_hole_dia                                 = 2.0;
camera_offset_rad                                    = 2.0;
camera_holes_size                                    = [21, 12.5];
camera_holes_distance_from_top                       = 1;

camera_module_ffc_zif_len                            = 21;
camera_module_ffc_zif_inner_len                      = 19.7;
camera_module_ffc_zif_thickness                      = 2.2;
camera_module_ffc_inner_thickness                    = 1.8;
camera_module_ffc_zif_base_h                         = 1.2;
camera_module_ffc_zif_h                              = 3.2;
camera_module_socket_base_h                          = 3.3;
camera_module_socket_upper_h                         = 1.4;
camera_module_socket_thickness                       = 2.7;
camera_module_socket_y_offset                        = 1;

// ─────────────────────────────────────────────────────────────────────────────
// Head
// ─────────────────────────────────────────────────────────────────────────────

head_camera_bolt_dia                                 = m2_hole_dia;

head_camera_lens_width                               = 14;
head_camera_lens_height                              = 23;

// Dimensions of the hole for the Camera Module (lens opening).
head_camera_module_3_size                            = [head_camera_lens_width,
                                                        head_camera_lens_height];

// Dimensions for the bolt hole area of the Camera Module.
// These form a rectangle around the camera hole, with a bolt hole
// centered at each corner to secure the camera module.
head_camera_module_3_bolt_holes_size                 = [head_camera_lens_width +
                                                        head_camera_bolt_dia + 4.2,
                                                        12.73];

// Vertical offset to move the bolt hole grid below the top edge
// of the camera lens hole.
head_camera_bolt_y_offset_from_camera_hole           = 2.0;

// List of camera mounting configurations.
// Each item is an array of:
// [ [lens_hole_width, lens_hole_height],
//   vertical_offset_for_bolt_holes_relative_to_camera_hole,
//   [bolt_hole_region_width, bolt_hole_region_height],
//   optional_color_for_assembly_view
//  ]
//
// To configure a single camera, remove one of the internal elements.
head_cameras                                         = [[head_camera_module_3_size,
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
head_cameras_y_distance                              = len(head_cameras) > 1
                                                        ? 2.0
                                                        : (head_cameras[0][0][1] / 2);

// Width of the front face plate where the camera modules are mounted.
head_plate_width                                     = 38;

// Height of the front face plate, automatically calculated based on
// the total height of all camera lens holes plus their vertical spacing.
// Ensures a minimum height of 40 mm.
head_plate_height                                    = max(40,
                                                           sum([for (j = [0:len(head_cameras)-1])
                                                             head_cameras[j][0][1]])
                                                           + head_cameras_y_distance *
                                                           len(head_cameras) - 1);

// Thickness (depth) of all the main head plates, including front,
// top, connector, and side plates.
head_plate_thickness                                 = 2;

// Diameter of the central hole in the side panel for mounting the servo motor.
head_servo_mount_dia                                 = 6.5;

// Diameter of the screws used to mount the servo motor.
// The screws are placed radially around the main servo mounting hole.
head_servo_horn_screw_dia                            = 1.5;

// Height of the side panel of the head, matching the height of the front plate.
head_side_panel_height                               = head_plate_height;

// Width of the side panel, based on a scaling factor relative to front plate width
// to ensure appropriate coverage for the mounting surface.
head_side_panel_width                                = head_plate_width * 1.2;

// Don't try to find a lot of sense in the calculations of the side panel polygon, this is an aesthetic choice.
head_side_panel_top                                  = -head_side_panel_height * (4 / 15);
head_side_panel_curve_start                          = head_side_panel_width * (1 / 2.1);
head_side_panel_notch_y                              = -head_side_panel_height * (7 / 14.2);
head_side_panel_bottom                               = head_side_panel_height * (1 / 4.9);
head_side_panel_curve_end                            = head_side_panel_height * (3 / 4.0);

head_side_panel_extra_slot_width                     = head_side_panel_width * 0.8;
head_side_panel_extra_slot_height                    = 2;
head_side_panel_extra_slot_ypos                      = [-9, 0.2];

head_upper_plate_width                               = head_plate_width * 0.9;
head_upper_plate_height                              = 30;

head_top_slot_size                                   = [head_upper_plate_width * 0.8, 2];

head_lower_connector_width                           = head_upper_plate_width * 0.6;
head_upper_connector_width                           = head_upper_plate_width * 0.7;

head_extra_side_slots_x_positions                    = [head_side_panel_width * 0.25,
                                                        head_side_panel_width * 0.5,
                                                        head_side_panel_width * 0.75];
head_upper_connector_len                             = head_plate_thickness;
head_upper_connector_height                          = 4;

head_lower_connector_height                          = 2;

head_extra_holes_offset                              = 4;

head_hole_row_offsets                                = [head_extra_holes_offset * 3];

head_extra_slots_dia                                 = 3;

// positions of the additional holes at the top plate

head_top_holes_x_positions                           = [-8, 0, 8];

head_top_slots_y_distance                            = 6;
head_top_plate_extra_slots_dia                       = 4;

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
head_neck_pan_servo_slot_width                       = 23.6;

/**
 * Height (Y-dimension) of the rectangular pan servo slot.
 * Matches the thickness (depth) of the servo body horizontally.
 */
head_neck_pan_servo_slot_height                      = 12;

/**
 * Diameter of the bolt holes used to fasten the pan servo to the neck bracket.
 * Two holes are centered on the width and offset laterally.
 */
head_neck_pan_servo_bolt_dia                         = 2;

/**
 * Offset distance from the servo slot width to the bolt hole center.
 * Applies symmetrically on both sides of the slot.
 */
head_neck_pan_servo_bolts_offset                     = 1;

/**
 * Thickness of the horizontal base panel of the bracket,
 * which holds the pan servo.
 */
head_neck_pan_servo_slot_thickness                   = 2.5;

/**
 * Extra width to add around the main bracket body to accommodate
 * alignment, mechanical clearance, or additional structural space.
 */
head_neck_pan_servo_extra_w                          = 4;

head_neck_pan_servo_assembly_reversed                = false;

// ─────────────────────────────────────────────────────────────────────────────
// IR LED Case parameters
// ─────────────────────────────────────────────────────────────────────────────

// Outer diameter used for the case cutout for the LED (case-side value).
// Note: this is the hole size intended for the LED in the case (may include any planned clearance).
ir_case_led_dia                                      = 19.1;

// Overall vertical size of the case part
ir_case_height                                       = 28;

// Overall horizontal size of the case part (X dimension).
ir_case_width                                        = 29;

// Base plate thickness of the case (main wall thickness).
ir_case_thickness                                    = 2;

// Additional boss thickness around the LED pocket on top of ir_case_thickness.
// Used to raise the LED boss above the base plate.
ir_case_led_boss_thickness                           = 1;

// Light detector (small photodiode/receiver) diameter.
ir_light_detector_dia                                = 6.4;

// Vertical distance from the top edge where the LED + detector holes are positioned.
ir_case_holes_distance_from_top                      = 2;

// Y offset of the light detector relative to the LED center (negative moves it up).
// Positive = move detector down, Negative = move detector up (depends on coordinate system).
ir_light_offset_from_led_y                           = -1.4;

// X offset of the light detector relative to the LED center (positive -> to the right).
ir_light_offset_from_led_x                           = 0.1;

// Which side(s) the (optional) light detector hole is created on.
// Allowed values: "left" | "right" | "both"
ir_light_detector_position                           = "right"; // left | right | both

// Which side(s) the L-bracket is added on the case.
// Allowed values: "left" | "right" | "both"
ir_case_bracket_position                             = "left";  // left | right | both

// Small carriage height above the stacked case thicknesses (clearance for rail carriage).
ir_case_carriage_h                                   = 1;

// Length of the carriage feature (along rail direction).
ir_case_carriage_len                                 = 4;

// Wall thickness of the carriage walls.
ir_case_carriage_wall_thickness                      = 2;

// Fillet/rounding radius used for the carriage / rail corners.
// Typical small value (0..1).
ir_case_carriage_offset_rad                          = 0.8;

// Rail (slot) inner width (inside the carriage).
ir_case_rail_w                                       = 5;

// Rail (slot) inner height (thickness of the rail profile).
ir_case_rail_h                                       = 1.5;

// Height of the rail protruding above the carriage
ir_case_rail_protrusion_h                            = 1.0;

// Angle of the rail protruding above the carriage
ir_case_rail_protrusion_angle                        = 3;

// Angle of the rail protruding above the carriage
ir_case_rail_protrusion_offset_rad                   = 0.2;

// Rail incline angle (degrees) used for trapezoid/angled rail profile.
ir_case_rail_angle                                   = 10;

// Rail corner rounding radius.
ir_case_rail_offset_rad                              = 0.0;

// Diameter for the holes in the rail meant for M2 bolts.
ir_case_rail_bolt_dia                                = m2_hole_dia;

// Additional clearance for the rail (gap to allow slider movement).
ir_case_rail_clearance                               = 0.3;

// L-bracket width (horizontal flange) that attaches to the case.
ir_case_l_bracket_w                                  = 8;

// L-bracket height (vertical flange).
ir_case_l_bracket_h                                  = 20;

// L-bracket leg length (depth of bracket from case wall).
ir_case_l_bracket_len                                = 5;

// Bolt hole diameter used across the case / bracket (M2 holes).
ir_case_bolt_dia                                     = m2_hole_dia;

// X offsets for additional pan holes along the bolt row (relative offsets).
// Array of offsets in mm; used to create multiple holes along the bolt line.
ir_case_bolt_pan_holes_x_offsets                     = [0, 5];

// Actual LED physical diameter (measured component). Note: very close to ir_case_led_dia.
// Keep consistent: ir_led_dia is the real LED, ir_case_led_dia is the case cutout dimension.
ir_led_dia                                           = 19.0;

// PCB board length (long dimension of the LED board).
ir_led_board_len                                     = 27.94;

// PCB board width (short dimension of the LED board).
ir_led_board_w                                       = 19.82;

// Depth of the PCB cutout/relief in the board model (used when modeling board shape).
ir_led_board_cutout_depth                            = 3.4;

// Height of the LED cylinder part (component height).
ir_led_height                                        = 15.05;

// PCB thickness (board thickness).
ir_led_thickness                                     = 0.95;

// Height of the separate light detector cylinder (component height).
ir_led_light_detector_h                              = 8.26;

// Light detector smaller diameter (tapered detector model - one end radius).
ir_led_light_detector_dia_1                          = 5.3;

// Light detector larger diameter (tapered detector model - other end radius).
ir_led_light_detector_dia_2                          = 5.9;

// Bolt diameter used on the LED board mounting (M2).
ir_led_bolt_dia                                      = m2_hole_dia;

// Y offset of the LED center relative to the board origin in the board model.
ir_led_y_offset                                      = 2;

// Offset of the detector from the LED along the board normal direction (signed).
ir_led_light_detector_offset_from_led                = -2;

// Lateral offset of the detector relative to the LED on the board (X axis).
ir_led_light_detector_offset_x                       = 1;

// Coordinates used to position the case relative to the head side panel.
// These precomputed values sum stacked thicknesses so the case clears the side panel.
// ir_case_head_side_panel_x_2 is further from the panel than x_1.
ir_case_head_side_panel_x_2                          = + ir_case_thickness
                                                        + ir_case_led_boss_thickness
                                                        + ir_led_thickness
                                                        + ir_led_light_detector_h / 2;
ir_case_head_side_panel_x_1                          = + ir_led_light_detector_h / 2
                                                        + ir_led_height;

// Y coordinate for the first column of bolt positions (centered on the LED height).
ir_case_head_side_panel_y_1                          = -ir_led_height / 2;

// Y coordinate for the second column of bolt positions (bottom of the case).
ir_case_head_side_panel_y_2                          = -ir_case_height / 2;

// Array of four [x,y] positions used to lay out the four bolt mounting holes
// that attach the case to the head side panel. Each element is [x, y].
ir_case_head_bolts_side_panel_positions              = [[ir_case_head_side_panel_x_1,
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

lipo_pack_length                                     = 155.0; // Length of the battery pack
lipo_pack_width                                      = 47.4;   // Width of the battery pack
lipo_pack_s3_height                                  = 21.8;  // Height of the S3 battery pack
lipo_pack_s2_height                                  = 14.6;  // Height of the S2 battery pack
lipo_pack_height                                     = lipo_pack_s3_height;  // Height of the battery pack

// ─────────────────────────────────────────────────────────────────────────────
// PAN SERVO CONFIGURATION (Dimensions & Visual Representation)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Physical size of the pan servo in [length (X), width (Y), height (Z)].
 * Measured as the actuator body without hat or gearbox.
 */
pan_servo_size                                       = [23.48, 11.7, 20.3];

/**
 * Distance between the slot edge and bolt center for fastening.
 * Used during visualization and mounting slot generation.
 */
pan_servo_bolts_offset                               = 1;

/**
 * Width of the "hat" (top flange) on the servo.
 * This includes mounting holes and is typically wider than the body.
 */
pan_servo_flange_w                                   = 32.11;

/**
 * Height (Y) dimension of the servo's "hat" section.
 * Equal to servo width unless asymmetrically hatched.
 */
pan_servo_flange_h                                   = pan_servo_size[1];

/**
 * Vertical thickness of the servo hat, i.e., how thick the extension flange is.
 */
pan_servo_flange_thickness                           = 1.7;

/**
 * Distance from the top of the servo body to the bottom of the hat.
 * Accounts for mechanical separation between body and hat.
 */
pan_servo_flange_z_offset                            = 4;

/**
 * Servo label text for visualization purposes.
 * Each row is formatted as plist.
 */
pan_servo_text                                       = [["EMAX", "size", 4,
                                                         "font", "Liberation Sans:style=Bold Italic",
                                                         "height", 0.1,
                                                         "color", "white",
                                                         "bg_color", matte_black_2,
                                                         "bg_pad_left", 3.6,
                                                         "bg_pad_right", 3.6,
                                                         "bg_pad_bottom", 0.5,
                                                         "bg_pad_top", 0.5,],
                                                        ["ES08MA II ANALOG SERVO",
                                                         "size", 1.2,
                                                         "gap_before", 1]];

pan_servo_text_plist                                 = ["background", ["color", yellow_2],
                                                        "color", "black"];

/**
 * Default size to use for servo label text when specific size is not defined.
 * Units: font points
 */
pan_servo_text_size                                  = 3;

/**
 * Height of the gearbox block directly above the servo body.
 * The base volume that holds gears before the gear stack begins.
 */
pan_servo_gearbox_h                                  = 4;

/**
 * A list describing a stack of circular gear disks on the servo.
 * Each gear is defined as: [height, diameter, color, (optional) resolution].
 */
pan_servo_gearbox_size                               = [[0.4, 6.09, matte_black],
                                                        [0.5, 4.35, dark_gold_2, 8],
                                                        [0.8, 2, dark_gold_2],
                                                        [2.45, 4, dark_gold_2, 10],
                                                        [0.05, 2.6, licorice, 8]];

/**
 * Diameter of the first (largest) gear or lid on the gear stack.
 * Used to compute alignment and transitions.
 */
pan_servo_gearbox_d1                                 = 11.51;

/**
 * Diameter of the secondary gear/layer in the stack.
 * Typically used for angled profiles and hull blending.
 */
pan_servo_gearbox_d2                                 = 6.56;

/**
 * Horizontal offset on the X-axis to place the second gear (d2)
 * shifted relative to the first gear (d1), for hull or profile shaping.
 */
pan_servo_gearbox_x_offset                           = 3;

/**
 * Mode used to generate the transition junction between d1 and d2 gearbox layers.
 * - `"hull"`: meshes them with a smooth profile.
 * - `"union"`: shows them as stacked cylinders.
 */
pan_servo_gearbox_mode                               = "hull";

/**
 * Color value used to render the body of the pan servo.
 */
pan_servo_color                                      = jet_black;

/**
 * Length of the chamfered or cutout region at the bottom of the servo body.
 * Used for display detail in component preview.
 */
pan_servo_cut_len                                    = 3;

// ─────────────────────────────────────────────────────────────────────────────
// HEAD NECK PANEL (Vertical Plate for Tilt Servo Mounting)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Width (X-axis) of the tilt servo mounting slot.
 * Should closely match the physical width of the servo body.
 */
head_neck_tilt_servo_slot_width                      = 23.6;

/**
 * Height (Y-axis) of the tilt servo slot in the vertical bracket.
 * Should correspond to the depth of the servo side profile.
 */
head_neck_tilt_servo_slot_height                     = 12;

/**
 * Diameter of the holes used for fastening the servo to the bracket.
 * Applies to both pan and tilt servos.
 */
head_neck_tilt_servo_bolt_dia                        = 2;

/**
 * Lateral horizontal offset from the slot centerline to each bolt hole center.
 */
head_neck_tilt_servo_bolts_offset                    = 1;

/**
 * Thickness of the vertical support plate in which the tilt servo is mounted.
 * Same as the vertical thickness of the L-bracket.
 */
head_neck_tilt_servo_slot_thickness                  = 2.5;

/**
 * Additional width added beyond the tilt servo slot to ensure clearance and rigidity.
 * Allow placement of head/servo structures with sufficient tolerance.
 */
head_neck_tilt_servo_extra_w                         = 4;

/**
 * Additional lower structural height added **below** tilt servo slot.
 * Provides more support at the base and positions the servo higher.
 */
head_neck_tilt_servo_extra_lower_h                   = 5;

/**
 * Additional height added **above** the tilt servo placement.
 * Allows for mounting clearance or bolt pass-through from above.
 */
head_neck_tilt_servo_extra_top_h                     = 3;

// ─────────────────────────────────────────────────────────────────────────────
// TILT SERVO CONFIGURATION (Dimensions & Visual Representation)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Physical dimensions of the tilt servo: [Length, Width, Height].
 * Measurement excludes mounting hat and gear housing.
 */
tilt_servo_size                                      = [23.48, 11.7, 20.3];

/**
 * Bolt offset distance from the slot to centers of mounting holes.
 * Used during servo slot modeling and visualization.
 */
tilt_servo_bolts_offset                              = 1;

/**
 * Width of the mounting flange ("hat") for the tilt servo.
 * Usually wider than the central body to allow secure fastening.
 */
tilt_servo_flange_w                                  = 32.11;

/**
 * Height of the servo hat (Y axis).
 * Should match the width of the servo body.
 */
tilt_servo_flange_h                                  = tilt_servo_size[1];

/**
 * Thickness of the tilt servo's mounting flange ("hat").
 * Used to offset and extrude bolt holders in 3D view.
 */
tilt_servo_flange_thickness                          = 1.6;

/**
 * Distance from the top of the servo body to bolt-holding surface (flange).
 * Used to vertically position the hat relative to the main body.
 */
tilt_servo_flange_z_offset                           = 4;

/**
 * Horizontal offset between the two gearbox shaft diameters
 * (used when blending large/small gear diameters visually).
 */
tilt_servo_gearbox_x_offset                          = 3;

/**
 * How to visually join `gearbox_d1` and `gearbox_d2`. Accepted values:
 * - `"hull"`: Smooth shell connection.
 * - `"union"`: Joined but visually distinct cylinders.
 */
tilt_servo_gearbox_mode                              = "hull";

/**
 * Labeling text for the tilt servo used in rendered previews.
 */
tilt_servo_text                                      = pan_servo_text;
tilt_servo_text_plist                                = pan_servo_text_plist;

/**
 * Default text size for servo labels if none is explicitly specified.
 */
tilt_servo_text_size                                 = 3;

/**
 * Height of the gearbox housing above the main servo body.
 * Does not include stacked gears.
 */
tilt_servo_gearbox_h                                 = 4;

/**
 * Array representing a visual stack of gear disks or wheels.
 * Each item: [height, diameter, color, (optional) faceting resolution].
 */
tilt_servo_gearbox_size                              = [[0.4, 6.09, matte_black],
                                                        [0.5, 4.35, dark_gold_2, 8],
                                                        [0.8, 2, dark_gold_2],
                                                        [2.45, 4, dark_gold_2, 10],
                                                        [0.05, 2.6, licorice, 8]];

/**
 * Diameter of the primary (largest) top gear in the tilt servo’s gearbox.
 */
tilt_servo_gearbox_d1                                = 11.51;

/**
 * Diameter of secondary/inner gear used for visuals or profile blending.
 */
tilt_servo_gearbox_d2                                = 6.56;

/**
 * Rendering color for the tilt servo body.
 */
tilt_servo_color                                     = jet_black;

/**
 * Length of the angled cut (chamfer) at the servo body base.
 * Used in visual model to distinguish component edges.
 */
tilt_servo_cut_len                                   = 3;

// ─────────────────────────────────────────────────────────────────────────────
// Motor type
// ─────────────────────────────────────────────────────────────────────────────
// Type of the DC motor to use. Either "n20" or "standard". "n20" refers to
// motors like the GA12-N20 with a 3mm shaft, whereas "standard" refers to
// popular, inexpensive, unnamed yellow motors with a 5mm shaft. This setting
// affects the shape and type of the motor bracket, the diameter of the rear
// wheel shafts, and the vertical length of the steering knuckle shafts
motor_type                                           = "n20"; // [n20, standard]

// ─────────────────────────────────────────────────────────────────────────────
// N20 motor dimensions
// ─────────────────────────────────────────────────────────────────────────────
n20_reductor_dia                                     = 14;
n20_reductor_height                                  = 9;
n20_shaft_height                                     = 9;
n20_shaft_dia                                        = 3;
n20_shaft_cutout_w                                   = 2;
n20_can_height                                       = 15;
n20_can_dia                                          = 12;
n20_can_cutout_w                                     = 7;

n20_end_cap_h                                        = 0.8;
n20_end_circle_h                                     = 0.5;
n20_end_cap_circle_dia                               = 5;
n20_end_cap_circle_hole_dia                          = 3;

// ─────────────────────────────────────────────────────────────────────────────
// N20 motor bracket dimensions
// ─────────────────────────────────────────────────────────────────────────────
n20_motor_bracket_tolerance                          = 0.2;
n20_motor_bracket_thickness                          = 3;
n20_motor_bolts_panel_offset                         = 11.3;
n20_motor_bolts_panel_length                         = 4;
n20_motor_bolt_dia                                   = m25_hole_dia;
n20_motor_bolt_bore_dia                              = n20_motor_bolt_dia * 2;
n20_motor_bolt_bore_h                                = chassis_counterbore_h;

n20_motor_chassis_y_distance                         = 0;
n20_motor_chassis_x_distance                         = -9;

n20_motor_bolts_panel_len                            = n20_can_dia
                                                        + n20_motor_bracket_thickness
                                                        * 2
                                                        + n20_motor_bolt_dia
                                                        * 2
                                                        + n20_motor_bolts_panel_length
                                                        * 2;

// ─────────────────────────────────────────────────────────────────────────────
// Raspberry Pi dimensions (defaults are for Raspberry PI 5)
// ─────────────────────────────────────────────────────────────────────────────

// The X and Y dimensions of the bolt positions for the Raspberry Pi 5 slot.
// This forms a square with a bolt hole centered on each corner.
rpi_bolt_spacing                                     = [50, 58];

// The diameter of the bolt holes for the Raspberry Pi 5 slot.
rpi_bolt_hole_dia                                    = m2_hole_dia;
rpi_bolt_cbore_dia                                   = m2_pan_counterbore_d;
rpi_chassis_cbore_h                                  = m2_pan_counterbore_h;
rpi_bolt_head_type                                   = "pan";
rpi_use_countersunk                                  = false;

rpi_bolts_offset                                     = m25_hole_dia + 0.4;
rpi_pin_headers_cols                                 = 20;
rpi_pin_headers_rows                                 = 2;

rpi_len                                              = 85;

rpi_width                                            = 56;
rpi_thickness                                        = 1.9;

rpi_usb_y_offset                                     = 3;

// The amount by which to offset the Raspberry Pi
rpi_offset_rad                                       = 2.4;

// The height of the pin
rpi_pin_height                                       = 8.54;

// The width of the single pin black header
rpi_pin_header_width                                 = 2.54;

// The height of the pin black headers
rpi_pin_header_height                                = 2.54;

// Whether to show the Raspberry Pi with more realistic details, which may slow
// down the render
rpi_model_detailed                                   = false;

rpi_model_text                                       = "Raspberry Pi [5]";
rpi_text_font                                        = "Ubuntu:style=Bold";

// Raspberry Pi parts dimensions (x, y, z)

rpi_ram_size                                         = [10.2, 15, 1]; // Size of the SRAM
rpi_processor_size                                   = [15, 15, 0.5]; // BCM2712 processor

// USB 2.0 and USB 3.0 jacks
rpi_usb_a_size                                       = [13.25, 17.60, 15.04];
rpi_usb_a_gap                                        = 5;
rpi_usb_a_edge_gap                                   = 2;
rpi_usb_a_n                                          = 2;

// Ethernet jack
rpi_ethernet_jack_size                               = [16.15, 21.34, 13.40];

// PCI Express interface
rpi_pci_size                                         = [2, 12.85, 3];

// 2 x 4-lane MIPI DSI/CSI connectors
rpi_csi_size                                         = [2, 16.0, 2.5];

rpi_pad_hole_specs                                   = [[4.5, yellow_3]];

// USB-c power jack
rpi_usb_c_jack_size                                  = [8.2, 7.8, 3];

// 2 x micro-HDMI
rpi_micro_hdmi_jack_size                             = [8.2, 6.5, 3];

// UART connector
rpi_uart_connector_size                              = [2.5, 4.0, 5];

// RTC battery connector
rpi_rtc_connector_size                               = [2.5, 3.4, 5];

// Dual-band 902.11ac Wireless + Bluetooth 5
rpi_wifi_bt_size                                     = [14, 11, 1.5];

// RP1 I/O controller
rpi_io_size                                          = [14, 10, 1.5];

// On-off button
rpi_on_off_button_plist                              = ["size", [3.85, 2, 1.8],
                                                        "button_d", 1.5,
                                                        "button_h", 0.8,
                                                        "offsets", [3.12, 0]];

rpi_camera_ribbon_slot_size                          = [rpi_csi_size[1], 1.6];
rpi_camera_ribbon_slot_gap                           = 1.4;
rpi_camera_ribbon_slot_rows                          = 3;

rpi_plugged_usb_a                                    = ["left", [1],
                                                        "right", []];

//The height of the standoffs for Raspberry Pi
rpi_standoff_height                                  = 6;

// CSI
rpi_csi_cameras_n                                    = 2; // number of camera CSI connectors on the Raspberry PI
rpi_csi_position_x                                   = rpi_bolt_spacing[0] - rpi_csi_size[1] / 2 - 2;
rpi_csi_position_y                                   = rpi_bolt_spacing[1] - m25_hole_dia;
rpi_csi_camera_gap                                   = 3.84;

// ─────────────────────────────────────────────────────────────────────────────
// AI HAT+
// ─────────────────────────────────────────────────────────────────────────────

ai_hat_size                                          = [56.7, 65, 1.5];
ai_hat_corner_rad                                    = 2.4;
ai_hat_bolt_dia                                      = m25_hole_dia;

ai_hat_mounting_hole_pad_spec                        = [[m25_hole_dia + 2.5, yellow_3]];
ai_hat_csi_slot_size                                 = [rpi_csi_size[1] + 4, ai_hat_size[1]
                                                                             - rpi_csi_position_y];

ai_hat_processor_size                                = [17, 17, 1];
ai_hat_processor_text                                = "HAILO";
ai_hat_csi_cutout_corner_r                           = 1.5;
ai_hat_front_cutout_size                             = [20, 5];
ai_hat_header_height                                 = 10.16;
ai_hat_pin_height                                    = 10.57;

// ─────────────────────────────────────────────────────────────────────────────
// Servo Driver HAT
// ─────────────────────────────────────────────────────────────────────────────

servo_driver_hat_size                                = [30.26, 65.25, 1.65];
servo_driver_corner_rad                              = 2;
servo_driver_hat_bolt_spacing                        = [25, 58];

servo_driver_hat_bolt_dia                            = m25_hole_dia;
servo_driver_hat_standoff_color                      = "white";
servo_driver_hat_mounting_hole_pad_spec              = [[m25_hole_dia + 2.5, "white"]];

servo_driver_hat_header_height                       = 9;
servo_driver_hat_pin_height                          = 9.5;
servo_driver_hat_screw_terminal_thickness            = 5.8;
servo_driver_hat_screw_terminal_base_h               = 6.8;              // base height (Z)
servo_driver_hat_screw_terminal_top_l                = 4.50;              // top trapezoid top side length
servo_driver_hat_screw_terminal_top_h                = 3.2;               // top trapezoid height
servo_driver_hat_screw_terminal_contacts_n           = 2;            // number of contact boxes
servo_driver_hat_screw_terminal_contact_w            = 3.5;           // contact box width (X)
servo_driver_hat_screw_terminal_contact_h            = 4.47;          // contact box height (Z)
servo_driver_hat_screw_terminal_pitch                = 5.0;              // center-to-center spacing (X)

servo_driver_hat_side_pins_headers_count             = 4;
servo_driver_hat_side_pins_headers_margin            = 2;
servo_driver_hat_side_header_height                  = 1.5;
servo_driver_hat_side_pin_cols                       = 4;
servo_driver_hat_side_pin_rows                       = 3;
servo_driver_hat_side_pin_height                     = 15.7;

servo_driver_hat_chip_len                            = 9;
servo_driver_hat_chip_w                              = 5;
servo_driver_hat_chip_total_w                        = 8;
servo_driver_hat_chip_j_lead_n                       = 14;
servo_driver_hat_chip_j_lead_thickness               = 0.4;
servo_driver_hat_chip_h                              = 1.65;

servo_driver_hat_chip_x_distance                     = 18;

servo_driver_hat_chip_i2c_x_distance                 = 5;
servo_driver_hat_chip_i2c_y_distance                 = 15;

servo_driver_hat_i2c_addr_size                       = [3.0, 1.3, 0.4];
servo_driver_hat_i2c_addr_gap                        = 0.3;
servo_driver_hat_i2c_addr_text_size                  = 0.6;
servo_driver_hat_i2c_addr_text_gap                   = 0.6;

servo_driver_hat_i2c_addr_text_label                 = "I2C Addresses";
servo_driver_hat_i2c_addr_text_label_size            = 0.9;

servo_driver_hat_chip_2_len                          = 5;
servo_driver_hat_chip_2_w                            = 4;
servo_driver_hat_chip_2_total_w                      = 8;
servo_driver_hat_chip_2_j_lead_n                     = 4;
servo_driver_hat_chip_2_j_lead_thickness             = 0.4;
servo_driver_hat_chip_2_h                            = 1.65;
servo_driver_hat_chip_2_x_distance                   = 46;

// ─────────────────────────────────────────────────────────────────────────────
// Motor Driver HAT
// ─────────────────────────────────────────────────────────────────────────────

motor_driver_hat_size                                = [56.7, 65, 1.9];
motor_driver_hat_corner_rad                          = 2.4;
motor_driver_hat_bolt_dia                            = m25_hole_dia;
motor_driver_hat_standoff_color                      = "white";
motor_driver_hat_mounting_hole_pad_spec              = [[m25_hole_dia + 2.5, "white"]];

motor_driver_hat_lower_header_height                 = 13.15;
motor_driver_hat_lower_header_pin_height             = 8;

motor_driver_hat_upper_header_height                 = 13;
motor_driver_hat_upper_pin_height                    = 8;

motor_driver_grid                                    = ["type", "grid",
                                                        "size", [motor_driver_hat_size[0] - 7, motor_driver_hat_size[1]],
                                                        "rows", [["h", 2.0,
                                                                  "cells", [["w", 1]]],
                                                                 ["h", 14.0,
                                                                  "cells", [["w", 20,
                                                                             "align_y", 1,
                                                                             "placeholder", ["type", "smd_chip",
                                                                                             "placeholder_size", [13, 15.6],
                                                                                             "corner_rad", 0.0,
                                                                                             "chip_size", [7.7, 15.6, 3.2],
                                                                                             "j_lead", [["count", 11,
                                                                                                         "thickness", 0.4,
                                                                                                         "sides", ["left", "right"]]]]],
                                                                            ["w", 0.25,
                                                                             "grid", ["type", "grid",
                                                                                      "rows", [["h", 11,
                                                                                                "cells", [["w", 0.5,
                                                                                                           "placeholder", ["type", "can_capacitor",
                                                                                                                           "d", 10.0,
                                                                                                                           "h", 10.6,
                                                                                                                           "base_h", 2.58,
                                                                                                                           "text_rows", ["470", "35V", "VRT"]]],
                                                                                                          ["w", 0.5]]],
                                                                                               ["h", 0.5,
                                                                                                "cells", [["w", 1.0,
                                                                                                           "spin", 0,
                                                                                                           "placeholder", ["type", "smd_resistor",
                                                                                                                           "placeholder_size", [6.8, 2.6, 2]]]]]]]],
                                                                            ["w", 0.25,
                                                                             "align_y", 1,
                                                                             "placeholder", ["type", "smd_chip",
                                                                                             "placeholder_size", [10, 12],
                                                                                             "corner_rad", 0.0,
                                                                                             "chip_size", [10, 8.8, 4.40],
                                                                                             "j_lead", [["count", 5,
                                                                                                         "thickness", 0.8,
                                                                                                         "sides", ["bottom"]]]]]]],
                                                                 ["h", 2.0,
                                                                  "cells", [["w", 1]]],
                                                                 ["h", 11.0,
                                                                  "cells", [["w", 7],
                                                                            ["w", 0.2,
                                                                             "spin", 90,
                                                                             "placeholder", ["type", "can_capacitor",
                                                                                             "d", 6.4,
                                                                                             "base_h", 2.58,
                                                                                             "h", 5.5,
                                                                                             "marking_color", matte_black,
                                                                                             "can_color", metallic_silver_1,
                                                                                             "text_rows", ["47", "HFT", "S92"],
                                                                                             "rotation", 0]],
                                                                            ["w", 0.2,
                                                                             "spin", -90,
                                                                             "placeholder", ["type", "can_capacitor",
                                                                                             "d", 6.4,
                                                                                             "base_h", 2.58,
                                                                                             "h", 5.5,
                                                                                             "marking_color", matte_black,
                                                                                             "can_color", metallic_silver_1,
                                                                                             "text_rows", ["47", "HFT", "S92"],
                                                                                             "rotation", 0]],
                                                                            ["w", 0.1,
                                                                             "align_x", -1,
                                                                             "spin", 90,
                                                                             "placeholder", ["type", "smd_resistor",
                                                                                             "placeholder_size", [6.8, 2.6, 2]]],
                                                                            ["w", 0.3,
                                                                             "grid", ["type", "grid",
                                                                                      "rows", [["h", 0.7,
                                                                                                "cells", [["w", 0.8,
                                                                                                           "placeholder", ["type", "unshielded_power_inductor",
                                                                                                                           "placeholder_size", [5.8, 5.8, 6],
                                                                                                                           "text", 330,]],
                                                                                                          ["w", 0.5,
                                                                                                           "placeholder", ["type", "can_capacitor",
                                                                                                                           "d", 6.4,
                                                                                                                           "base_h", 2.58,
                                                                                                                           "h", 5.5,
                                                                                                                           "text_rows", ["47", "HFT", "S92"],
                                                                                                                           "rotation", 0]]]],
                                                                                               ["h", 0.5,
                                                                                                "cells", [["w", 1.0]]]]]]]],
                                                                 ["h", 17.0,
                                                                  "cells", [["w", 0.4,
                                                                             "placeholder", ["type", "smd_chip",
                                                                                             "placeholder_size", [15.6, 17],
                                                                                             "corner_rad", 0.0,
                                                                                             "chip_size", [11.0, 15, 3.2],
                                                                                             "text_rows", ["MC33886VW"],
                                                                                             "text_props", ["size", 1.0,
                                                                                                            "gap", 3,
                                                                                                            "rotation", [0, 0, -90],
                                                                                                            "colr", "lightgrey",
                                                                                                            "spacing", 0.9,
                                                                                                            "height", 0.1,
                                                                                                            "valign", "center",
                                                                                                            "halign", "center"],
                                                                                             "j_lead", [["count", 11,
                                                                                                         "thickness", 0.4,
                                                                                                         "sides", ["left", "right"]]]]],
                                                                            ["w", 8],
                                                                            ["w", 0.4,
                                                                             "placeholder", ["type", "smd_chip",
                                                                                             "placeholder_size", [15.6, 17],
                                                                                             "corner_rad", 0.0,
                                                                                             "chip_size", [11.0, 15, 3.2],
                                                                                             "text_rows", ["MC33886VW"],
                                                                                             "text_props", ["size", 1.0,
                                                                                                            "gap", 3,
                                                                                                            "rotation", [0, 0, -90],
                                                                                                            "colr", "lightgrey",
                                                                                                            "spacing", 0.9,
                                                                                                            "height", 0.1,
                                                                                                            "valign", "center",
                                                                                                            "halign", "center"],
                                                                                             "j_lead", [["count", 11,
                                                                                                         "thickness", 0.4,
                                                                                                         "sides", ["left", "right"]]]]],
                                                                            ["w", 0.07,
                                                                             "align_x", -1,
                                                                             "spin", -90,
                                                                             "placeholder", ["type", "text",
                                                                                             "color", "white",
                                                                                             "size", 1.5,
                                                                                             "text", "RPI Motor Driver Board",
                                                                                             "spacing", 1,
                                                                                             "halign", "left",
                                                                                             "valign", "baseline",]]]],
                                                                 ["h", 2,
                                                                  "cells", [["w", 1]]],
                                                                 ["h", 2.7,
                                                                  "debug", false,
                                                                  "cells", [["w", 0.05],
                                                                            ["w", 0.17,
                                                                             "debug", false,
                                                                             "placeholder", ["type", "schottky_diode",
                                                                                             "placeholder_size", [6.8, 2.6, 2]]],
                                                                            ["w", 0.17,
                                                                             "placeholder", ["type", "schottky_diode",
                                                                                             "placeholder_size", [6.8, 2.6, 2]]],
                                                                            ["w", 0.17],
                                                                            ["w", 0.17,
                                                                             "placeholder", ["type", "schottky_diode",
                                                                                             "placeholder_size", [6.8, 2.6, 2]]],
                                                                            ["w", 0.17,
                                                                             "placeholder", ["type", "schottky_diode",
                                                                                             "placeholder_size", [6.8, 2.6, 2]]]]],
                                                                 ["h", 2,
                                                                  "cells", [["w", 1]]],
                                                                 ["h", 2.7,
                                                                  "cells", [["w", 0.05],
                                                                            ["w", 0.17,
                                                                             "placeholder", ["type", "schottky_diode",
                                                                                             "placeholder_size", [6.8, 2.6, 2]]],
                                                                            ["w", 0.17,
                                                                             "placeholder", ["type", "schottky_diode",
                                                                                             "placeholder_size", [6.8, 2.6, 2]]],
                                                                            ["w", 0.17,
                                                                             "placeholder", ["type", "schottky_diode",
                                                                                             "placeholder_size", [6.8, 2.6, 2]]],
                                                                            ["w", 0.17,
                                                                             "placeholder", ["type", "schottky_diode",
                                                                                             "placeholder_size", [6.8, 2.6, 2]]],
                                                                            ["w", 0.17,
                                                                             "placeholder", ["type", "schottky_diode",
                                                                                             "placeholder_size", [6.8, 2.6, 2]]]]],
                                                                 ["h", 10.0,
                                                                  "cells", [["w", 0.1],
                                                                            ["w", 0.8,
                                                                             "spin", 180,
                                                                             "placeholder", ["type", "screw_terminal",
                                                                                             "base_h", 6.8,
                                                                                             "thickness", 5.8,
                                                                                             "top_l", 4.50,
                                                                                             "top_h", 3.2,
                                                                                             "contacts_n", 6,
                                                                                             "contact_w", 3.5,
                                                                                             "contact_h", 4.47,
                                                                                             "pitch", 5.0,
                                                                                             "colr", medium_blue_2,
                                                                                             "pin_thickness", 0.4,
                                                                                             "pin_h", 3.9,
                                                                                             "wall_thickness", 0.6,
                                                                                             "isosceles_trapezoid", false,]],
                                                                            ["w", 0.15]]]]];

// ─────────────────────────────────────────────────────────────────────────────
// GPIO Expansion Board
// ─────────────────────────────────────────────────────────────────────────────
gpio_expansion_bolt_spacing_2                        = [38, 58];
gpio_expansion_size                                  = [55.0, 65.25, 1.65];

gpio_expansion_bolt_dia                              = m25_hole_dia;
gpio_expansion_standoff_color                        = "white";
gpio_expansion_corner_rad                            = 2;
gpio_expansion_mounting_hole_pad_spec                = [[m25_hole_dia + 2.5, dark_gold_1]];

gpio_expansion_header_height                         = 8;
gpio_expansion_pin_height                            = 3.5;

gpio_expansion_header_up_height                      = 2;
gpio_expansion_pin_up_height                         = 7;

gpio_expansion_inner_header_cols                     = 8;
gpio_expansion_inner_header_rows                     = 2;
gpio_expansion_inner_header_gap                      = 8;

gpio_expansion_inner_header_pin_height               = 6;
gpio_expansion_inner_headers_count                   = 3;

gpio_expansion_screw_terminal_thickness              = 12.0;
gpio_expansion_screw_terminal_base_h                 = 7.4;
gpio_expansion_screw_terminal_top_l                  = 6.50;

gpio_expansion_screw_terminal_top_h                  = 6.2;
gpio_expansion_screw_terminal_contacts_n             = 8;
gpio_expansion_screw_terminal_contact_w              = 2.0;
gpio_expansion_screw_terminal_contact_h              = 0;
gpio_expansion_screw_terminal_pitch                  = 3.2;
gpio_expansion_screw_terminal_x_offset               = 2.0;

// ─────────────────────────────────────────────────────────────────────────────
// Voltmeter placeholder
// ─────────────────────────────────────────────────────────────────────────────
voltmeter_board_len                                  = 22.65;
voltmeter_board_w                                    = 14.45;
voltmeter_board_h                                    = 0.9;

voltmeter_display_len                                = 22.65;
voltmeter_display_w                                  = 14.45;
voltmeter_display_h                                  = 6.16;

voltmeter_bolt_spacing                               = [0, 27.70];
voltmeter_bolt_dia                                   = m3_hole_dia;

voltmeter_pin_h                                      = 3.44;
voltmeter_pins_len                                   = 10.65;

voltmeter_pin_thickness                              = 0.63;
voltmeter_pins_count                                 = 5;

voltmeter_wiring_distance                            = 3;
voltmeter_wiring_gap                                 = 1;
voltmeter_wiring_d                                   = 1.5;

voltmeter_default_pins_spec                          = ["size", [voltmeter_pin_thickness,
                                                                 voltmeter_pin_h],
                                                        "count", voltmeter_pins_count,
                                                        "total_len", voltmeter_pins_len];

voltmeter_default_spec                               = ["display", ["size", [voltmeter_display_w,
                                                                             voltmeter_display_len,
                                                                             voltmeter_display_h],
                                                                    "upper_thickness", 1,
                                                                    "upper_color", matte_black,
                                                                    "bottom_color", "white"],
                                                        "hide_board", false,
                                                        "hide_display", false,
                                                        "text", "8.8.8",
                                                        "text_props", ["font", "DSEG14 Classic:style=Italic",
                                                                       "size", 6],
                                                        "slot_size", [0, 27.70],
                                                        "d", m3_hole_dia,
                                                        "pins", ["size", [voltmeter_pin_thickness,
                                                                          voltmeter_pin_h],
                                                                 "count", voltmeter_pins_count,
                                                                 "total_len", voltmeter_pins_len],
                                                        "wiring", ["d", voltmeter_wiring_d,
                                                                   "distance", voltmeter_wiring_distance,
                                                                   "path", [[-5, -5, -2],
                                                                            [-15, -10, -1],
                                                                            [10, -15, -2],
                                                                            [20, 0, 0]]],
                                                        "placeholder_size", [voltmeter_board_w,
                                                                             voltmeter_board_len,
                                                                             voltmeter_board_h]];

// ─────────────────────────────────────────────────────────────────────────────
// XT60 connector placeholder
// ─────────────────────────────────────────────────────────────────────────────

xt_60_size                                           = [11.6, 18.0];

xt_60_bolt_spacing                                   = [0, 25.4];

// ─────────────────────────────────────────────────────────────────────────────
// XT60BE-M connector placeholder
// ─────────────────────────────────────────────────────────────────────────────
xt60be_size                                          = [xt_60_size[0], xt_60_size[1], 15.1];
xt60be_mounting_panel_size                           = [15.65, 33.2, 2.5];
xt60be_mount_spacing                                 = 25.4;
xt60be_mount_dia                                     = m3_hole_dia;
xt60be_mount_cbore_dia                               = m3_countersunk_head_dia;
xt60be_mount_cbore_h                                 = m3_countersunk_head_h;

xt60be_pin_spacing                                   = 7.6;
xt60be_pin_dia                                       = 3.7;
xt60be_contact_dia                                   = 4.2;
xt60be_contact_h                                     = 4.2;
xt60be_contact_thickness                             = 0.8;
xt60be_contact_wall_h                                = 2;
xt60be_contact_base_h                                = 1;

xt60be_pin_length                                    = 6.0;

xt60be_pin_thickness                                 = 1;

xt60be_shell_color                                   = matte_black;
xt60be_pin_color                                     = dark_gold_2;

// ─────────────────────────────────────────────────────────────────────────────
// XT90 connector placeholder
// ─────────────────────────────────────────────────────────────────────────────

xt_90_size                                           = [10.30, 22.20];

xt_90_bolt_spacing                                   = [0, 32.20];

// ─────────────────────────────────────────────────────────────────────────────
// XT90E-M connector placeholder
// ─────────────────────────────────────────────────────────────────────────────
xt90e_size                                           = [xt_90_size[0], xt_90_size[1], 15.1];
xt90e_mounting_panel_size                            = [17.4, 42, 3];
xt90e_mount_spacing                                  = 32.4;
xt90e_mount_dia                                      = m3_hole_dia;
xt90e_mount_cbore_dia                                = m3_countersunk_head_dia;
xt90e_mount_cbore_h                                  = m3_countersunk_head_h;

xt90e_pin_spacing                                    = 10.16;
xt90e_pin_dia                                        = 5.2;
xt90e_contact_dia                                    = 5.7;
xt90e_contact_h                                      = 5.7;
xt90e_contact_thickness                              = 0.8;
xt90e_contact_wall_h                                 = 3;
xt90e_contact_base_h                                 = 2;

xt90e_pin_length                                     = 13.5;

xt90e_pin_thickness                                  = 1;

xt90e_shell_color                                    = matte_black;
xt90e_pin_color                                      = dark_gold_2;

// ─────────────────────────────────────────────────────────────────────────────
// INA 260
// ─────────────────────────────────────────────────────────────────────────────

ina260_bolt_spacing                                  = [17.78, 0];
ina260_bolt_dia                                      = m25_hole_dia;
ina260_size                                          = [22.9, 23.1, 1.65];

// ─────────────────────────────────────────────────────────────────────────────
// Switch button placeholder
// ─────────────────────────────────────────────────────────────────────────────

toggle_switch_size                                   = [29.4, 15.5, 18];
toggle_switch_metallic_head_h                        = 2;
toggle_switch_thread_d                               = 11.8;
toggle_switch_thread_h                               = 11.2;
toggle_switch_thread_upper_h                         = 8;
toggle_switch_thread_border_w                        = 2;
toggle_switch_nut_out_h                              = toggle_switch_thread_h - toggle_switch_thread_upper_h;
toggle_switch_nut_d                                  = 17.5;
toggle_switch_lever_dia_1                            = 3.6;
toggle_switch_lever_dia_2                            = 5.7;
toggle_switch_lever_h                                = 23.0;
toggle_switch_slot_d_tolerance                       = 1.2;
toggle_switch_slot_counterbore_tolerance             = 0.5;

toggle_switch_terminal_size                          = [1.2, 6.0, 9.7];

// ─────────────────────────────────────────────────────────────────────────────
// Control panel with toggle switches near Raspberry PI
// ─────────────────────────────────────────────────────────────────────────────
control_panel_default_toggle_switch_spec             = ["size", toggle_switch_size,
                                                        "thread", [toggle_switch_thread_d,
                                                                   toggle_switch_thread_h,
                                                                   toggle_switch_thread_border_w,
                                                                   toggle_switch_slot_d_tolerance],
                                                        "nut", [toggle_switch_nut_d,
                                                                toggle_switch_nut_out_h,
                                                                toggle_switch_slot_counterbore_tolerance],
                                                        "terminal", toggle_switch_terminal_size,
                                                        "lever", [toggle_switch_lever_dia_1,
                                                                  toggle_switch_lever_dia_2,
                                                                  toggle_switch_lever_h],
                                                        "head", [toggle_switch_metallic_head_h]];

// One master switch for the shared battery supply.
control_panel_switch_button_specs                    = [control_panel_default_toggle_switch_spec];

control_panel_thickness                              = toggle_switch_nut_out_h + 2;

// ─────────────────────────────────────────────────────────────────────────────
// Standard (see motor_type) motor brackets dimension
// ─────────────────────────────────────────────────────────────────────────────
standard_motor_bracket_bolt_spacing                  = [-0, 0];
standard_motor_bracket_chassis_bolt_hole             = m2_hole_dia;
standard_motor_bracket_motor_bolt_hole               = m3_hole_dia;
standard_motor_bracket_y_offset                      = 0; // distance from the end of the chassis
standard_motor_bracket_width                         = 10;
standard_motor_bracket_thickness                     = 3;
standard_motor_bracket_height                        = 29;

// ─────────────────────────────────────────────────────────────────────────────
// Standard (see motor_type) motor dimensions

// ─────────────────────────────────────────────────────────────────────────────
standard_motor_shaft_color                           = light_grey;

standard_motor_can_color                             = "silver";
standard_motor_endcap_color                          = black_1;

standard_motor_gearbox_body_main_len                 = 37;
standard_motor_gearbox_height                        = 22.6;
standard_motor_gearbox_color                         = yellow_1;
standard_motor_gearbox_side_height                   = 19.5;
standard_motor_body_neck_len                         = 11.4;
standard_motor_can_len                               = 9.6;
standard_motor_endcap_len                            = 8.5;
standard_motor_shaft_len                             = 35;
standard_motor_shaft_rad                             = 2.8;
standard_motor_shaft_offset                          = 12;

standard_gearbox_neck_rad                            = standard_motor_gearbox_height / 2;
standard_motor_can_rad                               = standard_gearbox_neck_rad  * 0.9;
standard_endcap_rad                                  = standard_gearbox_neck_rad  * 0.86;

// ─────────────────────────────────────────────────────────────────────────────
// Step down voltage converter
// ─────────────────────────────────────────────────────────────────────────────
step_down_voltage_regulator_len                      = 40.7;
step_down_voltage_regulator_w                        = 20.4;
step_down_voltage_regulator_thickness                = 1.8;
step_down_voltage_regulator_standoff_h               = 2;

step_down_voltage_bolt_hole_dia                      = 2.1;

step_down_voltage_screw_terminal_holes               = [35.5, 5];

step_down_voltage_power_inductor_size                = [7.15, 7.4, 3.7, 0.8];
step_down_voltage_smd_chip_w                         = 5;
step_down_voltage_smd_chip_l                         = 3;
step_down_voltage_smd_chip_h                         = 1.55;
step_down_voltage_smd_chip_j_lead_l                  = 1;
step_down_voltage_power_regulator_y_distance         = 1.7;
step_down_voltage_screw_terminal_thickness           = 5.8;
step_down_voltage_screw_terminal_base_h              = 6.8;              // base height (Z)

step_down_voltage_screw_terminal_top_l               = 4.50;              // top trapezoid top side length
step_down_voltage_screw_terminal_top_h               = 3.2;               // top trapezoid height
step_down_voltage_screw_terminal_contacts_n          = 2;            // number of contact boxes
step_down_voltage_screw_terminal_contact_w           = 3.5;           // contact box width (X)
step_down_voltage_screw_terminal_contact_h           = 4.47;          // contact box height (Z)
step_down_voltage_screw_terminal_pitch               = 4.5;              // center-to-center spacing (X)
step_down_voltage_screw_terminal_colr                = medium_blue_2;
step_down_voltage_screw_terminal_pin_thickness       = 0.4;       // lower thin pin cross/width
step_down_voltage_screw_terminal_pin_h               = 3.9;               // lower thin pin height
step_down_voltage_screw_terminal_wall_thickness      = 0.6;  // wall offset from base top
step_down_voltage_screw_terminal_isosceles_trapezoid = true;

// ─────────────────────────────────────────────────────────────────────────────
// Servo horn
// ─────────────────────────────────────────────────────────────────────────────

// Each arm has the shape of a trapezoid.
// These trapezoids form either a cross (4 arms) or a single bar (2 arms).
// This is the starting width of the arm trapezoid, measured from the center.
servo_horn_starting_arm_w                            = 5.25;
// This is the ending width of the arm trapezoid.
servo_horn_ending_arm_w                              = 4.03;
// A ring is placed at the center where the arms meet. This is the ring's outer diameter.
servo_horn_center_ring_outer_dia                     = 5.90;
// This is the ring's inner diameter.
servo_horn_center_ring_inner_dia                     = 3.87;

// This is the total height of the ring and the horn itself.
servo_horn_ring_height                               = 4.54;

// This is the thickness of each arm.
servo_horn_arm_thickness                             = 1.5;

// This is the Z offset (height) of the arms from the bottom of the ring.
servo_horn_arm_z_offset                              = 2.5;

// This is the through-hole diameter at the center for the servo motor.
servo_horn_center_hole_dia                           = 2.0;

// This is the total length of the horn (two arms + center ring).
servo_horn_len                                       = 24;

// The diameter of fastening screw holes
servo_horn_screw_d                                   = 0.8;
// This is the distance between screw holes.
servo_horn_screws_distance                           = 2.84;
// This is the number of screw holes on each arm.
servo_horn_holes_n                                   = 2;

// A bare PCB needs only size and bolt_spacing. Rows, cols and bus_pad_cols
// are calculated from the available pad area when omitted (see perfboard_props).
// Mount consumers receive their hardware and clearance defaults through this plist.
perfboard_default_plist                              = ["size", [20, 80, 1.6],
                                                        "bolt_spacing", [16, 76],
                                                        // "rows", 28,        // optional calculated-count override
                                                        // "cols", 6,         // optional calculated-count override
                                                        // "bus_pad_cols", 4, // optional calculated-count override
                                                        "bolt_d", m2_hole_dia - 0.1,
                                                        "corner_r", 1,
                                                        "pad_d", 1.9,
                                                        "perf_grid_d", 1,
                                                        "spacing", 0.54,
                                                        "bus_pad_rx", 1.9,
                                                        "bus_pad_ry", 1,
                                                        "bus_pad_offset", 0.8,
                                                        "bus_pad_spacing", 0.8,
                                                        "board_color", "green",
                                                        "pin_color", "silver",
                                                        "bus_pad_color", "silver",
                                                        "standoff_h", 2,
                                                        "wire_d", 0,
                                                        "component_h", 0,
                                                        "slot_bore_d", m2_round_head_dia + 0.1,
                                                        "slot_bore_sink", false,
                                                        "slot_bore_h", 2];

// ─────────────────────────────────────────────────────────────────────────────
// Ultrasonic placeholder
// ─────────────────────────────────────────────────────────────────────────────

ultrasonic_w                                         = 45.42;
ultrasonic_h                                         = 20.5;
ultrasonic_thickness                                 = 1.25;
ultrasonic_offset_rad                                = 0.5;

ultrasonic_text_size                                 = 1.5;

ultrasonic_transducer_dia                            = 15.88;
ultrasonic_transducer_inner_dia                      = 12.75;
ultrasonic_transducer_h                              = 12.25;

// distance from the side of the panel
ultrasonic_transducer_x_offset                       = 1.5;

ultrasonic_pins_jack_w                               = 11.20;
ultrasonic_pins_jack_h                               = 2.50;
ultrasonic_pins_jack_thickness                       = 2.0;
ultrasonic_pins_jack_y_offset                        = 1;

ultrasonic_pins_count                                = 4;
ultrasonic_pin_len_a                                 = 7.84;
ultrasonic_pin_len_b                                 = 5.84;
ultrasonic_pin_protrusion_h                          = 2;

ultrasonic_pin_thickness                             = 0.5;

ultrasonic_oscillator_h                              = 3.5;
ultrasonic_oscillator_w                              = 9.86;
ultrasonic_oscillator_thickness                      = 3.33;
ultrasonic_oscillator_y_offset                       = 0.8;
ultrasonic_oscillator_solder_x                       = 2;

ultrasonic_bolt_dia                                  = 2.0;
ultrasonic_bolt_spacing                              = [42.0, 17.50];

ultrasonic_smd_len                                   = 8;
ultrasonic_smd_h                                     = 1.65;
ultrasonic_smd_led_thickness                         = 0.4;
ultrasonic_smd_led_count                             = 7;
ultrasonic_smd_w                                     = 7.55;
ultrasonic_smd_chip_w                                = 4.0;
ultrasonic_smd_x_offst                               = 1.0;
ultrasonic_solder_blob_d                             = 2.07;
ultrasonic_solder_blobs_positions                    = [26, 10];

// RPLIDAR C1: SLAMTEC C1M1-R2 datasheet, mechanical drawing, page 18.
// https://wiki.slamtec.com/download/attachments/83066883/SLAMTEC_rplidar_datasheet_C1_v1.0_en.pdf
// The four M2.5 mounting threads enter from the underside. Maximum screw
// insertion is 4 mm, NOT the total screw length including the mounting plate.
lidar_boolean_overlap                                = 0.01;
rplidar_c1_plist = ["size", [55.6, 55.6],
                    "corner_r", 4, // Approximate housing detail.
                    "color", matte_black,
                    "base_h", 23.1,
                    "top_h", 18.2,
                    "laser_transceiver_h", 29.8,
                    "top_round_d", 43.0, // Approximation; drawing does not dimension this diameter.
                    "bolt_d", 2.5,
                    "bolt_depth", 4,
                    "bolt_spacing", [43.0, 43.0],
                    "bolt_head_type", undef, // Blind threaded holes, not countersinks.
                    "lid_ring_h", 0.2, // Cosmetic details, not measured features.
                    "lid_ring_w", 1,
                    "texts", ["front",
                              [["text", "RPLIDAR",
                                "translation", [-10, 0, 0],
                                "bg_pad_bottom", 2,
                                "bg_pad_top", 2,
                                "bg_pad_left", 3,
                                "bg_pad_right", 3,
                                "bg_r_factor", 0.5,
                                "bg_color", black_1,
                                "color", onyx]]],
                    // Metadata only: cable/connector dimensions are not modeled.
                    // "bottom" is the -Y edge in plan view, not a Z-facing exit.
                    "cable_exit", ["side", "rear", // left | right | front | rear
                                   "position", "bottom", // top | bottom | center
                                   "side_offset", 0,
                                   "z_offset", 2,
                                   "color", matte_black,
                                   "socket_d", 9.13,
                                   "socket_l", 7,
                                   "cable_d", 4.8,
                                   "cable_l", 300,
                                   "bend_exclusion_l", 12]];

rc_driveshaft_plist = [// Selected assembly pivot spacing, not a hardware measurement.
                       "pivot_l", 60,
                       // Annotated measurements: full length and reach from the pivot.
                       "socket_l", 14.6,
                       "socket_pivot_l", 12.6,
                       "hub_l", 7.33,
                       "tube_l", 30.8,
                       "tube_pivot_l", 35.6,
                       "tube_total_l", 38,
                       "rod_yoke_l", 10.6,
                       "rod_yoke_pivot_l", 7.8,
                       "rod_max_exposed_l", 24.4,
                       // Hidden rod is provisionally as long as the tube bore.
                       "rod_l", undef,
                       "tube_d", 8,
                       "rod_d", 4,
                       "joint_d", 8,
                       "bore_d", 4,
                       "bore_clearance", 0.05,
                       "pin_d", 2,
                       // Exposed length is measured; insertion, ball and pin sizes are provisional.
                       "dogbone_outer_l", 12.5,
                       "dogbone_insert_l", 4,
                       "dogbone_ball_d", 5,
                       "dogbone_pin_d", 2,
                       "dogbone_pin_l", 8,
                       "max_angle", 30];

usb_a_plist = ["plug_shell", ["size", [12.0, 12.52, 4.4],
                              "color", metallic_silver_3],
               "plug_body", ["size", [15.46, 15.35, 8.08],
                             "color", matte_black],
               "strain_relief", ["size", [5.9, 7, 5.8]],];

usb_a_socket_plist = ["size", [rpi_usb_a_size[0], rpi_usb_a_size[1], rpi_usb_a_size[2] / 2],
                      "color", metallic_yellow_silver,
                      "offsets", [0, 0, 1]];

usb_c_plist = ["plug_shell", ["size", [8.2, 7.4, 2.4],
                              "color", metallic_silver_3],
               "plug_body", ["size", [11.23, 14.9, 7.7],
                             "color", matte_black],
               "strain_relief", ["size", [5.9, 7, 5.8]]];

wago_conductor_size = [6.9, 20.2, 9.8];
wago_hole_size_xz   = [6.1, 5.15];
wago_lid_l          = 16.0;
wago_lid_t          = 1.3;
wago_thickness      = 0.7;

wago_n              = 5;
wago_total_w        = 36.0;

// Rear deck electronics. Sides use chassis coordinates: left=-X, right=+X.
// See docs/rear-equipment.md for placement, clearance and custom hardware.
// Keep the converter input corridor free for the ring terminal and service hole.
rear_equipment_mixed = [["kind", "step_down",
                         "zone", "auto",
                         "rotation", -90]];

rear_equipment_meters = [["kind", "voltmeter",
                          "zone", "auto",
                          "rotation", 90,
                          "count", 2],
                         ["kind", "step_down",
                          "zone", "left",
                          "rotation", 0]];
// Choose [], rear_equipment_mixed, rear_equipment_meters, or a custom list.
rear_equipment_specs = rear_equipment_mixed;
rear_equipment_edge_margin = 3;
rear_equipment_gap = 3;

// Local Variables:
// c-label-minimum-indentation: 53
// End:
