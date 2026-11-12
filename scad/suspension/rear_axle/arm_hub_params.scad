/**
  * Module: Rear arm and hub dimensional presets.
  *
  * HSP 02149 photo dimensions establish the arm's plan envelope and fork gaps.
  * Thickness, bore fits, hinge offsets, rib layout and shock attachments are
  * design estimates requiring measurement against the installed hardware.
  * Source: https://www.monkeyhobby.com/hsp-rc-car-parts-02149-rear-lower-suspension-arm/
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../rc_params.scad>


// Caliper envelope: 48.6–49 mm; nominal length follows the 02149 drawing.
rear_arm_photo_length             = 49;
rear_arm_photo_inner_span         = 40;
rear_arm_photo_inner_gap          = 25;
// The 21 mm annotation is interpreted as lower ball-stud center spacing.
// The 29.5 mm annotation is interpreted as the full outer-end envelope.
rear_arm_photo_outer_bolt_spacing = 21;
rear_arm_photo_outer_gap          = 11;
rear_arm_photo_shoulder_span      = 29.5;

// Carrier measurements. Overall width and height are approximate envelopes;
// the lower ball spacing is derived from the width and socket boss diameter.
rear_hub_measured_carrier_d       = 18.3;
rear_hub_measured_socket_d        = 12;
rear_hub_measured_width           = 33.4;
rear_hub_measured_height          = 50.4;
rear_hub_measured_axle_pivot_h    = 10;
rear_hub_measured_link_axle_range = [28, 29];
rear_hub_nominal_link_axle_h      = (rear_hub_measured_link_axle_range[0]
                                     + rear_hub_measured_link_axle_range[1]) / 2;
rear_hub_lower_ball_spacing       = rear_hub_measured_width
                                     - rear_hub_measured_socket_d;
rear_hub_link_pivot_h             = rear_hub_measured_axle_pivot_h
                                     + rear_hub_nominal_link_axle_h;
rear_hub_link_boss_d              = 2 * (rear_hub_measured_height
                                         - rear_hub_measured_socket_d / 2
                                         - rear_hub_link_pivot_h);

rear_lower_arm_spec               = ["w", rear_arm_photo_length,
                                     "inner_span", rear_arm_photo_inner_span,
                                     "inner_gap", rear_arm_photo_inner_gap,
                                     "outer_span", rear_arm_photo_shoulder_span,
                                     "outer_bolt_spacing", rear_hub_lower_ball_spacing,
                                     "outer_gap", rear_arm_photo_outer_gap,
                                     "shoulder_span", rear_arm_photo_shoulder_span,
                                     "h", front_lower_arm_thickness,
                                     "hinge_d", front_lower_arm_thickness,
                                     "inner_fork_depth", 11,
                                     "outer_fork_depth", 10,
                                     "shoulder_x", 32,
                                     "rib_w", 3,
                                     "window_corner_r", 0.8,
                                     "shock_boss_d", front_lower_arm_thickness,
                                     "shock_bolt_d", 3,
                                     "shock_x", 32,
                                     "ball_d", 8.8,
                                     "ball_shank_d", 4.8,
                                     "ball_shank_l", 17.8,
                                     "ball_unthreaded_l", 5,
                                     "ball_projection", 8.5,
                                     "ball_pilot_d", 4.2,
                                     "ball_pilot_depth", 14,
                                     "ball_hex_d", 3.3,
                                     "ball_hex_depth", 2.6,
                                     "pin_d", 3,
                                     "pin_d_clearance", 0.2,
                                     "pin_end_overhang", 2,
                                     "pin_groove_d", 2.4,
                                     "pin_groove_w", 0.5,
                                     "pin_groove_offset", 0.7,
                                     "clip_thickness", 0.4,
                                     "cut_eps", 0.02,
                                     "fn", 64,
                                     "body_color", "SteelBlue",
                                     "pin_color", "Silver"];

// The paired lower ball sockets and unequal bearing pair follow the 02166
// layout. The carrier barrel and lower socket outer diameters are measured.
// Axle-to-ball height is 10 mm; link-eye height above the axle is 28–29 mm.
// Axial socket position, socket length and plug engagement are design estimates.

rear_hub_spec                     = ["inner_bearing_od", 15,
                                     "inner_bearing_id", 10,
                                     "inner_bearing_w", 4,
                                     "outer_bearing_od", 10,
                                     "outer_bearing_id", 5,
                                     "outer_bearing_w", 4,
                                     "bearing_separation", 2,
                                     "socket_l", 16,
                                     "bearing_d_clearance", 0.1,
                                     "inner_shoulder_d", 12,
                                     "outer_shoulder_d", 8,
                                     "bearing_housing_d", rear_hub_measured_carrier_d,
                                     "socket_d", rear_hub_measured_socket_d,
                                     "ball_d", 8.8,
                                     "ball_clearance", 0.15,
                                     "ball_x", 5,
                                     "ball_spacing", rear_hub_lower_ball_spacing,
                                     "ball_mouth_d", 6.8,
                                     "socket_plug_d", 10,
                                     "socket_plug_l", 5.2,
                                     "socket_plug_hex_d", 4.8,
                                     "socket_hex_clearance", 0.2,
                                     "socket_plug_tip_h", 1.5,
                                     "socket_plug_tip_fraction", 0.75,
                                     "socket_thread_pitch", 1.5,
                                     "socket_thread_angle", 30,
                                     "socket_thread_tolerance", 0.25,
                                     "socket_thread_tooth_h", 1.5,
                                     "bushing_d", 9.6,
                                     "bushing_l", 2.5,
                                     "bushing_hole_d", 4,
                                     "axle_pivot_height", rear_hub_measured_axle_pivot_h,
                                     "link_pivot_height", rear_hub_link_pivot_h,
                                     "link_inboard_offset", 2,
                                     "link_boss_d", rear_hub_link_boss_d,
                                     "link_l", 6,
                                     "link_bolt_d", 3,
                                     "link_d_clearance", 0.2,
                                     "web_l", 5,
                                     "web_w", 5,
                                     "rib_w", 3,
                                     "cut_eps", 0.02,
                                     "fn", 64,
                                     "print_part_gap", 8,
                                     "body_color", "SteelBlue",
                                     "bearing_color", "Silver",
                                     "bushing_color", "DimGray"];
