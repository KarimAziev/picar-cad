/**
 * Module: Simple robot wheel parameters
 *
 * Legacy wheel dimensions and layout defaults in millimeters.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>

// ─────────────────────────────────────────────────────────────────────────────
// Parameters for wheels, common for front and rear
// ─────────────────────────────────────────────────────────────────────────────

wheel_dia                                            = 42;
wheel_w                                              = 22.0;
wheel_thickness                                      = 2.0;
wheel_rim_h                                          = 1.2;
wheel_rim_w                                          = 1;
wheel_rim_bend                                       = 0.8;

// ─────────────────────────────────────────────────────────────────────────────
// Front wheels
// ─────────────────────────────────────────────────────────────────────────────

wheel_bearing_bore_d                                 = 8;
wheel_bearing_shoulder_d                             = 12.15;
wheel_bearing_outer_recess_d                         = 19.2;
wheel_bearing_w                                      = 7;
wheel_bearing_outer_d                                = 22;

wheel_hub_outer_d                                    = wheel_dia - (wheel_thickness * 2) - 2;

wheel_hub_bolt_offset                                = 0.7;

wheel_hub_h_tolerance                                = 0.2;
wheel_hub_inner_rim_h                                = 1.4;
wheel_hub_inner_rim_w                                = 1.2;

wheel_hub_n                                          = 2;
wheel_bolts_n                                        = 6;

wheel_bolt_boss_h                                    = 2;

wheel_hub_bolt_d                                     = m3_hole_dia;

wheel_hub_wheel_bolt_bore_d                          = m3_socket_head_dia + 0.4;
wheel_hub_wheel_bolt_bore_h                          = m3_socket_head_h + 0.4;
wheel_hub_wheel_spacer_h                             = 1.4 + wheel_hub_wheel_bolt_bore_h;

wheel_hub_bolt_boss_d                                = wheel_hub_bolt_d + 2;

knuckle_h                                            = (wheel_hub_inner_rim_h + (wheel_hub_h_tolerance + wheel_bearing_w));
knuckle_base_h                                       = knuckle_h - 2;

knuckle_narrow_d                                     = wheel_bearing_shoulder_d;
knuckle_base_d                                       = knuckle_narrow_d + 2;
knuckle_max_d                                        = knuckle_base_d + 4;

// ─────────────────────────────────────────────────────────────────────────────
// Rear wheels
// ─────────────────────────────────────────────────────────────────────────────

// Height of the shaft protruding above the wheel
wheel_rear_shaft_protrusion_height                   = 10.8;

// Number of rear wheel spokes.
wheel_rear_spokes_count                              = 5;

// Width of rear wheel spokes.
wheel_rear_wheel_spoke_w                             = 18.8;

// The outer diameter of the rear wheel’s shaft. The hole for the motor’s shaft
// is located within this shaft.
wheel_rear_shaft_outer_dia                           = 9.8;

// The inner diameter of the hole for the motor’s shaft in the rear wheel’s
// shaft.
wheel_rear_shaft_inner_dia                           = motor_type == "n20" ? 3.1 : 5.2;

// Number of flat sections on the motor shaft.
// Common values:
//   - 0: round shaft (e.g., basic toy motors)
//   - 1: single flat (e.g., an N20 motor)
//   - 2: dual flats (e.g., yellow plastic gear motors)
wheel_rear_shaft_flat_count                          = motor_type == "n20" ? 1 : 2;

// Length of each flat section on the shaft in millimeters. Measured along the
// shaft’s axis. This value affects the depth of the hub keying feature.
wheel_rear_shaft_flat_len                            = motor_type == "n20" ? 2 : 5;

// The height of the rear wheel’s shaft.
wheel_rear_motor_shaft_height                        = 10;

// ─────────────────────────────────────────────────────────────────────────────
// Tires
// ─────────────────────────────────────────────────────────────────────────────

// A small radial offset applied during the subtraction operation to slightly
// enlarge the cut-out, providing extra clearance between the tire and adjacent
// wheel elements.
wheel_tire_offset                                    = 0.5;

// The gap value used in the offset operation to round the corners of the tire
// cross-section.
wheel_tire_fillet_gap                                = 0.5;

// The added thickness to the wheel's inner radius for computing the overall
// cross-sectional depth of the tire.
wheel_tire_thickness                                 = 9.0;

// The effective width of the tire
wheel_tire_width                                     = wheel_w - wheel_rim_w;

// The polygon facet count used with circle-based operations
wheel_tire_fn                                        = 360;

wheel_tire_num_grooves                               = 34;
wheel_tire_groove_thickness                          = 0.4;
wheel_tire_groove_depth                              = 3.4;
