
/**
  * Module: Rear axle hardware dimensions.
  *
  * Dimensions are millimeters. Vendor dimensions and design assumptions are
  * distinguished below; assumption values require physical measurement for fit.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../placeholders/hsp_shock_params.scad>

use <../../lib/plist.scad>
use <../../placeholders/differential.scad>

// Caliper geometry is owned by the reusable differential placeholder.
// Bearing size, shoulder seating and dogbone ball depth are installation
// assumptions. The 10 mm bearing bore exceeds the measured 9.17 mm journal.
rear_differential_measurements = differential_spec();
rear_differential_spec         = plist_merge(rear_differential_measurements,
                                     ["bearing_d", 15,
                                      "bearing_id", 10,
                                      "bearing_h", 4,
                                      "bearing_shoulder_gap", 0,
                                      "cup_ball_depth", 3,
                                      "bearing_color", "silver"]);

// HSP pinion shaft is 5 mm; its bearings are HSP 02139 (5x10x4).
// OD14 and total31 appear in an aftermarket 02030 dimensioned listing;
// 28 mm variants also exist. Gear taper and bearing locations are estimates.
// https://www.ebay.com/itm/315748395020
rear_pinion_spec               = ["gear_d", 14,
                                  "gear_tip_d", 9,
                                  "gear_h", 7,
                                  "shaft_d", 5,
                                  "shaft_l", 31,
                                  "bearing_d", 10,
                                  "bearing_id", 5,
                                  "bearing_h", 4,
                                  "bearing_centers_z", [10, 18],
                                  "radial_clearance", 0.3,
                                  "axial_clearance", 0.2,
                                  "csg_epsilon", 0.02,
                                  "fn", 64,
                                  "gear_color", "dimgray",
                                  "shaft_color", "silver",
                                  "bearing_color", "silver"];

// Caliper measurements: overall 61.2, ball OD 5.8, shank OD 3.8, pins 9.82 x 2.
// The two ball centers are inset by one ball radius from each overall end.
rear_dogbone_overall_l         = 61.2;
rear_dogbone_ball_d            = 5.8;
rear_dogbone_spec              = ["pin_center_l", rear_dogbone_overall_l - rear_dogbone_ball_d,
                                  "ball_d", rear_dogbone_ball_d,
                                  "shank_d", 3.8,
                                  "pin_d", 2,
                                  "pin_l", 9.82,
                                  "fn", 48,
                                  "color", "silver"];

// HSP 02168 dimensioned product image specifies total31 and cross-hole edges
// at16 and19. Cup length10, shaft diameters,2 mm drive pin and bearing stack
// are packaging assumptions. The cross-hole midpoint is17.5 from cup opening.
// https://modelisme-rc.net/1298-large_default/axe-de-roue-wheel-axle-hsp-1-10-02168.jpg
rear_wheel_axle_spec           = ["total_l", 31,
                                  "cup_l", 10,
                                  "cup_d", 10,
                                  "cup_flange_d", 11,
                                  "cup_flange_h", 1,
                                  "cup_bore_d", 6,
                                  "cup_slot_w", 2,
                                  "cup_slot_depth", 7,
                                  "cup_ball_depth", 3,
                                  "shaft_d", 5,
                                  "thread_d", 4,
                                  "thread_l", 12,
                                  "inner_bearing_d", 15,
                                  "inner_bearing_id", 10,
                                  "outer_bearing_d", 10,
                                  "outer_bearing_id", 5,
                                  "bearing_h", 4,
                                  "inner_bearing_start", 6,
                                  "outer_bearing_start", 12,
                                  "pin_center_z", (16 + 19) / 2,
                                  "pin_d", 2,
                                  "pin_l", 10,
                                  "hex_af", 12,
                                  "hex_l", 5,
                                  "radial_clearance", 0.3,
                                  "axial_clearance", 0.2,
                                  "csg_epsilon", 0.02,
                                  "fn", 64,
                                  "body_color", "#30343b",
                                  "bearing_color", "silver",
                                  "hex_color", "#277d9e"];

// Metal reducing sleeve, specified by shaft diameters and engagement lengths.
// Overall OD, engagement, shaft-end gap and screw layout are design choices.
rear_motor_sleeve_spec         = ["d", 12,
                                  "motor_bore_d", 4,
                                  "pinion_bore_d", 5,
                                  "motor_engagement", 10,
                                  "pinion_engagement", 8,
                                  "shaft_end_gap", 1,
                                  "grub_d", 3,
                                  "grub_angles", [0, 90],
                                  "radial_clearance", 0.3,
                                  "axial_clearance", 0.2,
                                  "csg_epsilon", 0.02,
                                  "fn", 64,
                                  "color", "silver"];

rear_shock_spec = hsp_onroad_shock_spec;
