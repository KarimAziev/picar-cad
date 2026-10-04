/**
 * Module: Simple robot chassis parameters
 *
 * Legacy chassis dimensions and layout defaults in millimeters.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>


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
chassis_thickness                                = 6.0; // [2.0:10.0]

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

chassis_counterbore_h                            = 2.2; // The depth of counterbores on the chassis

// ─────────────────────────────────────────────────────────────────────────────
// Chassis shape
// ─────────────────────────────────────────────────────────────────────────────

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
chassis_pan_servo_slot_recess                    = constraint(2.0,
                                                                  0,
                                                                  chassis_thickness - 1);

chassis_pan_servo_top_ribbon_cuttout_len         = min(18,
                                                           chassis_upper_w * 0.8);
chassis_pan_servo_top_ribbon_cuttout_h           = 2;

chassis_upper_holes_border_w                     = chassis_side_hole_border_w;
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

chassis_upper_front_pan_slot_depth               = chassis_thickness / 2;

chassis_body_battery_holders_specs               = ["type", "grid",
                                                    "size", [chassis_body_w, chassis_body_len],
                                                    "rows", maybe_add_battery_holders_rows_h([["cells",
                                                                                           [["w", 0.5,
                                                                                             "align_y", 0,
                                                                                             "align_x", 0,
                                                                                             "placeholder", ["y_offset", -7.5,
                                                                                                             "x_offset", 1.5,
                                                                                                             "placeholder_type", "battery_holder",
                                                                                                             "battery_len", battery_length,
                                                                                                             "battery_dia", battery_dia,
                                                                                                             "mount_type", battery_holder_mount_type,
                                                                                                             "reverse", true,
                                                                                                             "terminal_type", battery_holder_terminal_type,
                                                                                                             "side_wall_cutout_type", battery_holder_side_wall_type]],
                                                                                            ["w", 0.5,
                                                                                             "align_y", 0,
                                                                                             "align_x", 0,
                                                                                             "placeholder", ["placeholder_type", "battery_holder",
                                                                                                             "y_offset", -7.5,
                                                                                                             "x_offset", 4.0,
                                                                                                             "reverse", true,
                                                                                                             "battery_len", battery_length,
                                                                                                             "battery_dia", battery_dia,
                                                                                                             "mount_type", battery_holder_mount_type,
                                                                                                             "terminal_type", battery_holder_terminal_type,
                                                                                                             "side_wall_cutout_type", battery_holder_side_wall_type]]]]])];

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

front_panel_connector_width                      = constraint(chassis_upper_w - 2,
                                                                  10,
                                                                  30);
front_panel_connector_bolts_padding_y            = 1;

front_panel_connector_bolt_spacing               = [constraint(10,
                                                                   front_panel_connector_bolt_bore_dia * 2 + 3,
                                                                   front_panel_connector_width), 0];

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
                                                        // side holes
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
                                                         // [[32, 15, 3.0], [0, 47.2, 0]]
                                                    ], // hole under left smd battery
                                                        [[[25, 14, 3.0], [10, -4, 0]], // upper hole under fuse stack
                                                         [[25, 14, 3.0], [10, -4, 0]], // lower hole under fuse stack
                                                         // [[35, 14, 3.0], [10, -22, 0]]
                                                        ], // hole under right smd battery
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
chassis_panel_stack_x_offset                     = 0;
chassis_panel_stack_y_offset                     = 1;
chassis_panel_stack_orientation                  = "horizontal"; // [horizontal, vertical] // -> deprecated
// Y offset for the Raspberry Pi 5 related slots and holes is measured from the end of the chassis.
rpi_chassis_y_position                           = 0;
rpi_chassis_x_position                           = -32.5;
