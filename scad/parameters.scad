/**
 * Module: Parameters
 * This file defines most of the robot parameters
 * All dimensions are in millimeters (mm)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <colors.scad>
use <util.scad>

assembly_steering_system_reversed           = true;
assembly_knuckle_shaft_reversed             = true;

m1_hole_dia                                 = 1.2; // M1 screw hole diameter
m2_hole_dia                                 = 2.4; // M2 screw hole diameter
m25_hole_dia                                = 2.6; // M2.5 screw hole diameter
m3_hole_dia                                 = 3.2; // M3 screw hole diameter

// ─────────────────────────────────────────────────────────────────────────────
// Battery holder at the top of the chassis behind Raspberry Pi
// (defaults dimensions are for Uninterruptible Power Supply Module 3S
// https://www.waveshare.com/ups-module-3s.html)
// ─────────────────────────────────────────────────────────────────────────────
battery_ups_size                            = [93, 60, 1.82];
battery_ups_holder_size                     = [77.8, 60, 22.0];
battery_ups_holder_thickness                = 1.86;

// Y offset for the UPS HAT slot, measured from the end of the chassis
battery_ups_offset                          = 2;

// The X and Y dimensions of the screw positions for the UPS HAT slot.
// This forms a square with a screw hole centered on each corner.
battery_ups_module_screws_size              = [86, 46];

// ─────────────────────────────────────────────────────────────────────────────
// Battery holders under the case
// ─────────────────────────────────────────────────────────────────────────────

// Starting Y-offset for extra battery screws
battery_screws_y_start                      = -30;

// Ending Y-offset for extra battery screws
battery_screws_y_offset_end                 = 0;

// Step/increment along the Y-axis for extra battery screws
battery_screws_y_offset_step                = 10;

// Dimensions for the screw hole pattern (width, height)
battery_holder_screw_holes_size             = [20, 10]; // [width, height] of the screw pattern

// Diameter of the screw holes
battery_holder_screw_hole_dia               = m25_hole_dia;

// Number of fragments for rendering circle (defines resolution)
battery_screws_fn_val                       = 360;

// X-offset for positioning screws relative to the center
battery_screws_x_offset                     = 24;

// Y offsets for positioning screws relative to the center
baterry_holes_y_positions                   = [for (i =
                                                      [battery_screws_y_start
                                                       : battery_screws_y_offset_step
                                                       : battery_screws_y_offset_end]) i];

// ─────────────────────────────────────────────────────────────────────────────
// 16850 battery dimensions
// ─────────────────────────────────────────────────────────────────────────────
battery_dia                                 = 18;
battery_height                              = 65.0;
battery_positive_pole_height                = 1.5;
battery_positive_pole_dia                   = 5.63;

// ─────────────────────────────────────────────────────────────────────────────
// Battery holder dimensions
// ─────────────────────────────────────────────────────────────────────────────
battery_holder_thickness                    = 1.82;
battery_holder_batteries_count              = 2;

// ─────────────────────────────────────────────────────────────────────────────
// Camera's placeholder dimensions
// ─────────────────────────────────────────────────────────────────────────────
camera_w                                    = 25;
camera_h                                    = 24;
camera_thickness                            = 1.05;
camera_lens_items                           = [[8.05, 8.05, 1.0, matte_black, "cube"],
                                               [11.05, 11.05, 1.5, matte_black, "cube"],
                                               [11.05, 11.05, 3.4, metalic_silver_2, "cube"],
                                               [7.15, 0, 3.03, matte_black,
                                                "circle", 30],
                                               [3.03, 0, 0.1, cobalt_blue_metalic,
                                                "circle", 15]];

camera_lens_connectors                      = [[6.0, 3.2, 1.5, matte_black, "cube"],
                                               [6.0, 0.5, 1.5, "darkgoldenrod", "cube"],
                                               [8.0, 4.0, 1.5, onyx, "cube", -1]];

camera_lens_distance_from_top               = 9;
camera_screw_hole_dia                       = 2.0;
camera_offset_rad                           = 1.0;
camera_holes_size                           = [21, 12.5];
camera_holes_distance_from_top              = 1;

// ─────────────────────────────────────────────────────────────────────────────
// Chassis dimensions
// ─────────────────────────────────────────────────────────────────────────────

chassis_width                               = 120;  // width of the chassis
chassis_len                                 = 254;  // length of the chassis
chassis_thickness                           = 4.0;    // chassis thickness
chassis_offset_rad                          = 3; // The amount by which to offset the chassis

// ─────────────────────────────────────────────────────────────────────────────
// Chassis Center Wiring Cutouts (near the Raspberry Pi/UPS HAT area)
// ─────────────────────────────────────────────────────────────────────────────

chassis_center_cutout_dia                   = 8.5;             // Diameter of each round cutout circle
chassis_center_cutout_spacing               = 4;               // Vertical spacing between cutouts
chassis_center_cutout_fn                    = 20;              // Circle detail level

chassis_center_trapezoid_1                  = [1 / 8.5, 1 / 8.5, 7]; // [bottom_frac_w, top_frac_w, height]
chassis_center_trapezoid_2                  = [0.2, 0.2, 5.4]; // [bottom_frac_w, top_frac_w, height]
chassis_center_cutout_repeat_offsets        = [0];         // How often to repeat stacked trapezoids
chassis_center_dotted_y_offsets             = [-10 / 235, 0, -20 / 235];  // Relative Y-positions for dotted cutoff line

// Extra vertical margin applied to avoid overlaps between wiring holes and other components
chassis_center_wiring_cutout_y_margin       = 8;

// ─────────────────────────────────────────────────────────────────────────────
// Chassis Head Wiring Pass-Through Holes (front section, near pan/tilt servo)
// ─────────────────────────────────────────────────────────────────────────────

chassis_head_wiring_hole_size               = [6, 3];      // [width, height] of rectangular wiring holes
chassis_head_wiring_hole_spacing            = 6;           // Vertical spacing between holes
chassis_head_profile_height                 = 4;           // Height of each rectangular hole
chassis_head_side_taper_height              = 9;           // Height of trapezoidal tapered cutouts
chassis_head_cutout_relative_width          = 0.4;         // Relative width of center cutout (fraction of width)
chassis_head_final_spacing                  = 3;           // Space between dual-stacked cutouts
chassis_head_min_cutout_w                   = 20;          // Minimal allowed width for center cutout
chassis_head_center_hole_radius             = 0.2;         // Rounded corner radius for center hole

// ─────────────────────────────────────────────────────────────────────────────
// Chassis shape
// ─────────────────────────────────────────────────────────────────────────────

chassis_base_rear_cutout_depth              = + 5;

chassis_shape_init_pos_x                    = 0;
chassis_shape_init_pos_y                    = - chassis_len / 2;

// The half of the width is used because the polygon will be mirrored.
chassis_shape_base_width                    = chassis_width / 2;
chassis_shape_target                        = ceil(0.2 * abs(chassis_shape_init_pos_y));
chassis_shape_rear_panel_base_w             = 26.0;

chassis_shape_rear_cutout_x_offset          = 6;  // Horizontal offset for the rear cutout
chassis_shape_rear_cutout_y_offset          = 5;  // Vertical offset for the rear cutout

chassis_rear_join_x                         = (-chassis_shape_base_width - chassis_shape_rear_panel_base_w) / 2;

chassis_trapezoid_hole_width                = 4.5;
chassis_trapezoid_hole_len                  = 9.5;

chassis_trapezoid_shape_pts                 = [[-chassis_shape_base_width * 0.6,
                                                chassis_shape_init_pos_y + chassis_len / 1.68],
                                               [-chassis_shape_base_width * 0.24,
                                                chassis_len / 2],
                                               [0, chassis_len / 2]];

chassis_shape_points                        = concat([[chassis_shape_init_pos_x,
                                                       chassis_shape_init_pos_y],
                                                      [-chassis_shape_rear_panel_base_w,
                                                       chassis_shape_init_pos_y],
                                                      [chassis_rear_join_x + chassis_shape_rear_cutout_x_offset,
                                                       chassis_shape_init_pos_y + chassis_base_rear_cutout_depth],
                                                      [chassis_rear_join_x,
                                                       chassis_shape_init_pos_y
                                                       + chassis_shape_rear_cutout_y_offset],
                                                      [-chassis_shape_base_width
                                                       + chassis_shape_rear_cutout_x_offset,
                                                       chassis_shape_init_pos_y],
                                                      [-chassis_shape_base_width,
                                                       chassis_shape_init_pos_y
                                                       + chassis_shape_rear_cutout_y_offset],
                                                      [-chassis_shape_base_width,
                                                       chassis_shape_init_pos_y + chassis_shape_target],
                                                      [-chassis_shape_base_width + 2,
                                                       (chassis_shape_init_pos_y + chassis_len / 2)
                                                       + 0.02 * chassis_len]],
                                                     chassis_trapezoid_shape_pts);

// diameter of the pan servo mounting hole at the front of the chassis
chassis_pan_servo_slot_dia                  = 6.5;

// Vertical offset, measured from the steering panel's position, for the pan
// servo cut-out. The pan servo is mounted on a bottom horizontal panel (with a
// gear hole interfacing with the chassis) that is part of the robot’s head
// (which also carries the cameras). Its placement is determined by adding this
// offset to steering_panel_y_pos_from_center.
chassis_pan_servo_y_distance_from_steering  = 45;

// ─────────────────────────────────────────────────────────────────────────────
// Front panel dimensions
// ─────────────────────────────────────────────────────────────────────────────
// This panel is vertical and includes mounting holes for the ultrasonic sensors.
// ─────────────────────────────────────────────────────────────────────────────
front_panel_chassis_y_offset                = 5;
front_panel_width                           = 66;   // panel width
front_panel_height                          = 22.5;   // panel height
front_panel_thickness                       = 2.5;   // panel thickness
front_panel_rear_panel_thickness            = 1.5;
front_panel_connector_screw_dia             = m25_hole_dia;
front_panel_connector_len                   = 15;
front_panel_connector_width                 = chassis_width / 4;
front_panel_connector_screw_offsets         = [[4, 3], [-4, 3]];
front_panel_screw_dia                       = m25_hole_dia;

// diameter of each mounting hole ("eye") for the ultrasonic sensors
front_panel_ultrasonic_sensor_dia           = 16.5;

// distance between the two ultrasonic sensor mounting holes
front_panel_ultrasonic_sensors_offset       = 10.0;

// horizontal offset between the ultrasonic sensor mounting holes
front_panel_screws_x_offset                 = 27;

front_panel_connector_offset_rad            = 3;
front_panel_ultrasonic_y_offset             = 0;
front_panel_screws_y_offst                  = 0;
front_panel_offset_rad                      = front_panel_height * 0.18;

front_panel_connector_rect_cutout_size      = [20, 3];

// the diameter of the holes for four solder blobs on the back rear mount
front_panel_solder_blob_dia                 = 4.0;

// the height of the deepening slot for ultrasonic
front_panel_ultrasonic_cutout_depth         = 0.8;

front_panel_rear_panel_ring_width           = 2;

// ─────────────────────────────────────────────────────────────────────────────
// Head
// ─────────────────────────────────────────────────────────────────────────────

head_camera_screw_dia                       = m2_hole_dia;

head_camera_lens_width                      = 14;
head_camera_lens_height                     = 23;

// Dimensions of the hole for the Camera Module (lens opening).
head_camera_module_3_size                   = [head_camera_lens_width,
                                               head_camera_lens_height];

// Dimensions for the screw hole area of the Camera Module.
// These form a rectangle around the camera hole, with a screw hole
// centered at each corner to secure the camera module.
head_camera_module_3_screw_holes_size       = [head_camera_lens_width +
                                               head_camera_screw_dia + 4.2,
                                               12.73];

// Vertical offset to move the screw hole grid below the top edge
// of the camera lens hole.
head_camera_screw_y_offset_from_camera_hole = 2.0;

// List of camera mounting configurations.
// Each item is an array of:
// [ [lens_hole_width, lens_hole_height],
//   vertical_offset_for_screw_holes_relative_to_camera_hole,
//   [screw_hole_region_width, screw_hole_region_height] ]
//
// To configure a single camera, remove one of the internal elements.
head_cameras                                = [[head_camera_module_3_size,
                                                head_camera_screw_y_offset_from_camera_hole,
                                                head_camera_module_3_screw_holes_size],
                                               [head_camera_module_3_size,
                                                head_camera_screw_y_offset_from_camera_hole,
                                                head_camera_module_3_screw_holes_size]];

// Vertical distance between camera modules (center-to-center spacing).
// If more than one camera is present, a fixed spacing of 2 mm is used.
// If only one camera is mounted, use half of its height for centering.
head_cameras_y_distance                     = len(head_cameras) > 1
  ? 2
  : (head_cameras[0][0][1] / 2);

// Width of the front face plate (in mm) where the camera modules are mounted.
head_plate_width                            = 38;

// Height of the front face plate (in mm), automatically calculated based on
// the total height of all camera lens holes plus their vertical spacing.
// Ensures a minimum height of 40 mm.
head_plate_height                           = max(40,
                                                  sum([for (j = [0 : len(head_cameras)-1])
                                                          head_cameras[j][0][1]])
                                                  + head_cameras_y_distance * len(head_cameras) - 1);

// Thickness (depth) of all the main head plates (in mm), including front,
// top, connector, and side plates.
head_plate_thickness                        = 2;

// Diameter (in mm) of the central hole in the side panel for mounting the servo motor.
head_servo_mount_dia                        = 6.5;

// Diameter (in mm) of the screws used to mount the servo motor.
// The screws are placed radially around the main servo mounting hole.
head_servo_screw_dia                        = 1.5;

// Height (in mm) of the side panel of the head, matching the height of the front plate.
head_side_panel_height                      = head_plate_height;

// Width (in mm) of the side panel, based on a scaling factor relative to front plate width
// to ensure appropriate coverage for the mounting surface.
head_side_panel_width                       = head_plate_width * 1.2;

// Don't try to find a lot of sense in the calculations of the side panel polygon, this is an aesthetic choice.
head_side_panel_top                         = -head_side_panel_height * (4 / 15);
head_side_panel_curve_start                 = head_side_panel_width * (1 / 2.1);
head_side_panel_notch_y                     = -head_side_panel_height * (7 / 14.2);
head_side_panel_bottom                      = head_side_panel_height * (1 / 4.9);
head_side_panel_curve_end                   = head_side_panel_height * (3 / 4.0);

head_side_panel_extra_slot_width            = head_side_panel_width * 0.8;
head_side_panel_extra_slot_height           = 2;
head_side_panel_extra_slot_ypos             = [-9, 0.2];

head_upper_plate_width                      = head_plate_width * 0.9;
head_upper_plate_height                     = 30;

head_top_slot_size                          = [head_upper_plate_width * 0.8, 2];

head_lower_connector_width                  = head_upper_plate_width * 0.6;
head_upper_connector_width                  = head_upper_plate_width * 0.7;

head_extra_side_slots_x_positions           = [head_side_panel_width * 0.25,
                                               head_side_panel_width * 0.5,
                                               head_side_panel_width * 0.75];
head_upper_connector_len                    = head_plate_thickness;
head_upper_connector_height                 = 4;

head_lower_connector_height                 = 2;

head_extra_holes_offset                     = 4;

head_hole_row_offsets                       = [head_extra_holes_offset * 3];

head_extra_slots_dia                        = 3;

// positions of the additional holes at the top plate

head_top_holes_x_positions                  = [-8, 0, 8];

head_top_slots_y_distance                   = 6;
head_top_plate_extra_slots_dia              = 4;

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
 * Units: mm
 */
head_neck_pan_servo_slot_width              = 23.6;

/**
 * Height (Y-dimension) of the rectangular pan servo slot.
 * Matches the thickness (depth) of the servo body horizontally.
 * Units: mm
 */
head_neck_pan_servo_slot_height             = 12;

/**
 * Diameter of the screw holes used to fasten the pan servo to the neck bracket.
 * Two holes are centered on the width and offset laterally.
 * Units: mm
 */
head_neck_pan_servo_screw_dia               = 2;

/**
 * Offset distance from the servo slot width to the screw hole center.
 * Applies symmetrically on both sides of the slot.
 * Units: mm
 */
head_neck_pan_servo_screws_offset           = 1;

/**
 * Thickness of the horizontal base panel of the bracket,
 * which holds the pan servo.
 * Units: mm
 */
head_neck_pan_servo_slot_thickness          = 2.5;

/**
 * Extra width to add around the main bracket body to accommodate
 * alignment, mechanical clearance, or additional structural space.
 * Units: mm
 */
head_neck_pan_servo_extra_w                 = 4;

head_neck_pan_servo_assembly_reversed       = false;

// ─────────────────────────────────────────────────────────────────────────────
// IR LED Case parameters
// ─────────────────────────────────────────────────────────────────────────────

// Outer diameter used for the case cutout for the LED (case-side value).
// Note: this is the hole size intended for the LED in the case (may include any planned clearance).
ir_case_led_dia                             = 19.1;

// Overall vertical size of the case part (Y dimension in your layouts).
ir_case_height                              = 28;

// Overall horizontal size of the case part (X dimension).
ir_case_width                               = 29;

// Base plate thickness of the case (main wall thickness).
ir_case_thickness                           = 2;

// Additional boss thickness around the LED pocket on top of ir_case_thickness.
// Used to raise the LED boss above the base plate.
ir_case_led_boss_thickness                  = 1;

// Light detector (small photodiode/receiver) diameter.
ir_light_detector_dia                       = 6.4;

// Vertical distance from the top edge where the LED + detector holes are positioned.
ir_case_holes_distance_from_top             = 2;

// Y offset of the light detector relative to the LED center (negative moves it up).
// Positive = move detector down, Negative = move detector up (depends on coordinate system).
ir_light_offset_from_led_y                  = -1.4;

// X offset of the light detector relative to the LED center (positive -> to the right).
ir_light_offset_from_led_x                  = 0.1;

// Which side(s) the (optional) light detector hole is created on.
// Allowed values: "left" | "right" | "both"
ir_light_detector_position                  = "right"; // left | right | both

// Which side(s) the L-bracket is added on the case.
// Allowed values: "left" | "right" | "both"
ir_case_bracket_position                    = "left";  // left | right | both

// Small carriage height above the stacked case thicknesses (clearance for rail carriage).
ir_case_carriage_h                          = 1;

// Length of the carriage feature (along rail direction).
ir_case_carriage_len                        = 4;

// Wall thickness of the carriage walls.
ir_case_carriage_wall_thickness             = 2;

// Fillet/rounding radius used for the carriage / rail corners.
// Typical small value (0..1).
ir_case_carriage_offset_rad                 = 0.8;

// Rail (slot) inner width (inside the carriage).
ir_case_rail_w                              = 5;

// Rail (slot) inner height (thickness of the rail profile).
ir_case_rail_h                              = 1.5;

// Height of the rail protruding above the carriage
ir_case_rail_protrusion_h                   = 1.0;

// Angle of the rail protruding above the carriage
ir_case_rail_protrusion_angle               = 3;

// Angle of the rail protruding above the carriage
ir_case_rail_protrusion_offset_rad          = 0.2;

// Rail incline angle (degrees) used for trapezoid/angled rail profile.
ir_case_rail_angle                          = 10;

// Rail corner rounding radius.
ir_case_rail_offset_rad                     = 0.0;

// Diameter for the holes in the rail meant for M2 screws.
// Value is taken from common m2_hole_dia parameter (see parameters.scad).
ir_case_rail_hole_dia                       = m2_hole_dia;

// Additional clearance for the rail (gap to allow slider movement).
ir_case_rail_clearance                      = 0.3;

// L-bracket width (horizontal flange) that attaches to the case.
ir_case_l_bracket_w                         = 8;

// L-bracket height (vertical flange).
ir_case_l_bracket_h                         = 20;

// L-bracket leg length (depth of bracket from case wall).
ir_case_l_bracket_len                       = 5;

// Screw hole diameter used across the case / bracket (M2 holes).
ir_case_screw_dia                           = m2_hole_dia;

// X offsets for additional pan holes along the screw row (relative offsets).
// Array of offsets in mm; used to create multiple holes along the screw line.
ir_case_screw_pan_holes_x_offsets           = [0, 5];

// Actual LED physical diameter (measured component). Note: very close to ir_case_led_dia.
// Keep consistent: ir_led_dia is the real LED, ir_case_led_dia is the case cutout dimension.
ir_led_dia                                  = 19.0;

// PCB board length (long dimension of the LED board).
ir_led_board_len                            = 27.94;

// PCB board width (short dimension of the LED board).
ir_led_board_w                              = 19.82;

// Depth of the PCB cutout/relief in the board model (used when modeling board shape).
ir_led_board_cutout_depth                   = 3.4;

// Height of the LED cylinder part (component height).
ir_led_height                               = 15.05;

// PCB thickness (board thickness).
ir_led_thickness                            = 0.95;

// Height of the separate light detector cylinder (component height).
ir_led_light_detector_h                     = 8.26;

// Light detector smaller diameter (tapered detector model - one end radius).
ir_led_light_detector_dia_1                 = 5.3;

// Light detector larger diameter (tapered detector model - other end radius).
ir_led_light_detector_dia_2                 = 5.9;

// Screw diameter used on the LED board mounting (M2).
ir_led_screws_dia                           = m2_hole_dia;

// Y offset of the LED center relative to the board origin in the board model.
ir_led_y_offset                             = 2;

// Offset of the detector from the LED along the board normal direction (signed).
ir_led_light_detector_offset_from_led       = -2;

// Lateral offset of the detector relative to the LED on the board (X axis).
ir_led_light_detector_offset_x              = 1;

// Coordinates used to position the case relative to the head side panel.
// These precomputed values sum stacked thicknesses so the case clears the side panel.
// ir_case_head_side_panel_x_2 is further from the panel than x_1.
ir_case_head_side_panel_x_2                 = + ir_case_thickness
  + ir_case_led_boss_thickness
  + ir_led_thickness
  + ir_led_light_detector_h / 2;
ir_case_head_side_panel_x_1                 = + ir_led_light_detector_h / 2
  + ir_led_height;

// Y coordinate for the first column of screw positions (centered on the LED height).
ir_case_head_side_panel_y_1                 = -ir_led_height / 2;

// Y coordinate for the second column of screw positions (bottom of the case).
ir_case_head_side_panel_y_2                 = -ir_case_height / 2;

// Array of four [x,y] positions used to lay out the four screw mounting holes
// that attach the case to the head side panel. Each element is [x, y].
ir_case_head_screws_side_panel_positions    = [[ir_case_head_side_panel_x_1,
                                                ir_case_head_side_panel_y_1],
                                               [ir_case_head_side_panel_x_2,
                                                ir_case_head_side_panel_y_1],
                                               [ir_case_head_side_panel_x_2,
                                                ir_case_head_side_panel_y_2],
                                               [ir_case_head_side_panel_x_1,
                                                ir_case_head_side_panel_y_2]];

// ─────────────────────────────────────────────────────────────────────────────
// PAN SERVO CONFIGURATION (Dimensions & Visual Representation)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Physical size of the pan servo in [length (X), width (Y), height (Z)].
 * Measured as the actuator body without hat or gearbox.
 * Units: mm
 */
pan_servo_size                              = [23.48, 11.7, 20.3];

/**
 * Distance between the slot edge and screw center for fastening.
 * Used during visualization and mounting slot generation.
 * Units: mm
 */
pan_servo_screws_offset                     = 1;

/**
 * Width of the "hat" (top flange) on the servo.
 * This includes mounting holes and is typically wider than the body.
 * Units: mm
 */
pan_servo_hat_w                             = 32.11;

/**
 * Height (Y) dimension of the servo's "hat" section.
 * Equal to servo width unless asymmetrically hatched.
 * Units: mm
 */
pan_servo_hat_h                             = pan_servo_size[1];

/**
 * Vertical thickness of the servo hat, i.e., how thick the extension flange is.
 * Units: mm
 */
pan_servo_hat_thickness                     = 1.7;

/**
 * Distance from the top of the servo body to the bottom of the hat.
 * Accounts for mechanical separation between body and hat.
 * Units: mm
 */
pan_screws_hat_z_offset                     = 4;

/**
 * Servo label text for visualization purposes.
 * Each row is formatted as: [text_content, font_size, font_name]
 */
pan_servo_text                              = [["EMAX", 4, "Liberation Sans:style=Bold Italic"],
                                               ["ES08MA II ANALOG SERVO", 1.2, "Ubuntu:style=Bold"]];

/**
 * Default size to use for servo label text when specific size is not defined.
 * Units: font points
 */
pan_servo_text_size                         = 3;

/**
 * Height of the gearbox block directly above the servo body.
 * The base volume that holds gears before the gear stack begins.
 * Units: mm
 */
pan_servo_gearbox_h                         = 4;

/**
 * A list describing a stack of circular gear disks on the servo.
 * Each gear is defined as: [height, diameter, color, (optional) resolution].
 */
pan_servo_gearbox_size                      = [[0.4, 6.09, matte_black],
                                               [0.5, 4.35, dark_gold_2, 8],
                                               [0.8, 2, dark_gold_2],
                                               [2.45, 4, dark_gold_2, 10],
                                               [0.05, 2.6, licorice, 8]];

/**
 * Diameter of the first (largest) gear or lid on the gear stack.
 * Used to compute alignment and transitions.
 * Units: mm
 */
pan_servo_gearbox_d1                        = 11.51;

/**
 * Diameter of the secondary gear/layer in the stack.
 * Typically used for angled profiles and hull blending.
 * Units: mm
 */
pan_servo_gearbox_d2                        = 6.56;

/**
 * Horizontal offset on the X-axis to place the second gear (d2)
 * shifted relative to the first gear (d1), for hull or profile shaping.
 * Units: mm
 */
pan_servo_gearbox_x_offset                  = 3;

/**
 * Mode used to generate the transition junction between d1 and d2 gearbox layers.
 * - `"hull"`: meshes them with a smooth profile.
 * - `"union"`: shows them as stacked cylinders.
 */
pan_servo_gearbox_mode                      = "hull";

/**
 * Color value used to render the body of the pan servo.
 */
pan_servo_color                             = jet_black;

/**
 * Length of the chamfered or cutout region at the bottom of the servo body.
 * Used for display detail in component preview.
 * Units: mm
 */
pan_servo_cutted_len                        = 3;

// ─────────────────────────────────────────────────────────────────────────────
// HEAD NECK PANEL (Vertical Plate for Tilt Servo Mounting)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Width (X-axis) of the tilt servo mounting slot.
 * Should closely match the physical width of the servo body.
 * Units: mm
 */
head_neck_tilt_servo_slot_width             = 23.6;

/**
 * Height (Y-axis) of the tilt servo slot in the vertical bracket.
 * Should correspond to the depth of the servo side profile.
 * Units: mm
 */
head_neck_tilt_servo_slot_height            = 12;

/**
 * Diameter of the holes used for fastening the servo to the bracket.
 * Applies to both pan and tilt servos.
 * Units: mm
 */
head_neck_tilt_servo_screw_dia              = 2;

/**
 * Lateral horizontal offset from the slot centerline to each screw hole center.
 * Units: mm
 */
head_neck_tilt_servo_screws_offset          = 1;

/**
 * Thickness of the vertical support plate in which the tilt servo is mounted.
 * Same as the vertical thickness of the L-bracket.
 * Units: mm
 */
head_neck_tilt_servo_slot_thickness         = 2.5;

/**
 * Additional width added beyond the tilt servo slot to ensure clearance and rigidity.
 * Allow placement of head/servo structures with sufficient tolerance.
 * Units: mm
 */
head_neck_tilt_servo_extra_w                = 4;

/**
 * Additional lower structural height added **below** tilt servo slot.
 * Provides more support at the base and positions the servo higher.
 * Units: mm
 */
head_neck_tilt_servo_extra_lower_h          = 5;

/**
 * Additional height added **above** the tilt servo placement.
 * Allows for mounting clearance or screw pass-through from above.
 * Units: mm
 */
head_neck_tilt_servo_extra_top_h            = 3;

// ─────────────────────────────────────────────────────────────────────────────
// TILT SERVO CONFIGURATION (Dimensions & Visual Representation)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Physical dimensions of the tilt servo: [Length, Width, Height].
 * Measurement excludes mounting hat and gear housing.
 * Units: mm
 */
tilt_servo_size                             = [23.48, 11.7, 20.3];

/**
 * Screw offset distance from the slot to centers of mounting holes.
 * Used during servo slot modeling and visualization.
 * Units: mm
 */
tilt_servo_screws_offset                    = 1;

/**
 * Width of the mounting flange ("hat") for the tilt servo.
 * Usually wider than the central body to allow secure fastening.
 * Units: mm
 */
tilt_servo_hat_w                            = 32.11;

/**
 * Height of the servo hat (Y axis).
 * Should match the width of the servo body.
 * Units: mm
 */
tilt_servo_hat_h                            = tilt_servo_size[1];

/**
 * Thickness of the tilt servo's mounting flange ("hat").
 * Used to offset and extrude screw holders in 3D view.
 * Units: mm
 */
tilt_servo_hat_thickness                    = 1.6;

/**
 * Distance from the top of the servo body to screw-holding surface (flange).
 * Used to vertically position the hat relative to the main body.
 * Units: mm
 */
tilt_screws_hat_z_offset                    = 4;

/**
 * Horizontal offset between the two gearbox shaft diameters
 * (used when blending large/small gear diameters visually).
 * Units: mm
 */
tilt_servo_gearbox_x_offset                 = 3;

/**
 * How to visually join `gearbox_d1` and `gearbox_d2`. Accepted values:
 * - `"hull"`: Smooth shell connection.
 * - `"union"`: Joined but visually distinct cylinders.
 */
tilt_servo_gearbox_mode                     = "hull";

/**
 * Labeling text for the tilt servo used in rendered previews.
 * Format: [["Text Line", font size, font name], ...]
 */
tilt_servo_text                             = [["EMAX", 4, "Liberation Sans:style=Bold Italic"],
                                               ["ES08MA II ANALOG SERVO", 1.2, "Ubuntu:style=Bold"]];

/**
 * Default text size for servo labels if none is explicitly specified.
 */
tilt_servo_text_size                        = 3;

/**
 * Height of the gearbox housing above the main servo body.
 * Does not include stacked gears.
 * Units: mm
 */
tilt_servo_gearbox_h                        = 4;

/**
 * Array representing a visual stack of gear disks or wheels.
 * Each item: [height, diameter, color, (optional) faceting resolution].
 */
tilt_servo_gearbox_size                     = [[0.4, 6.09, matte_black],
                                               [0.5, 4.35, dark_gold_2, 8],
                                               [0.8, 2, dark_gold_2],
                                               [2.45, 4, dark_gold_2, 10],
                                               [0.05, 2.6, licorice, 8]];

/**
 * Diameter of the primary (largest) top gear in the tilt servo’s gearbox.
 * Units: mm
 */
tilt_servo_gearbox_d1                       = 11.51;

/**
 * Diameter of secondary/inner gear used for visuals or profile blending.
 * Units: mm
 */
tilt_servo_gearbox_d2                       = 6.56;

/**
 * Rendering color for the tilt servo body.
 */
tilt_servo_color                            = jet_black;

/**
 * Length of the angled cut (chamfer) at the servo body base.
 * Used in visual model to distinguish component edges.
 * Units: mm
 */
tilt_servo_cutted_len                       = 3;

// ─────────────────────────────────────────────────────────────────────────────
// Motor type
// ─────────────────────────────────────────────────────────────────────────────
// Type of the DC motor to use. Either "n20" or "standard". "n20" refers to
// motors like the GA12-N20 with a 3mm shaft, whereas "standard" refers to
// popular, inexpensive, unnamed yellow motors with a 5mm shaft. This setting
// affects the shape and type of the motor bracket, the diameter of the rear
// wheel shafts, and the vertical length of the steering knuckle shafts
motor_type                                  = "n20";

// ─────────────────────────────────────────────────────────────────────────────
// Steering Knuckle
// ─────────────────────────────────────────────────────────────────────────────

// The height of the steering knuckle
knuckle_height                              = 14.0;

// Diameter of the steering knuckle
knuckle_dia                                 = 14.0;

// The outside diameter of the 685-Z bearing (5x11x5) that is inserted into the
// knuckle
knuckle_bearing_outer_dia                   = 11.0;

// The inside diameter (plus tolerance) of the 685-Z bearing (5x11x5).
// They are placed on the each side of the steering panel
knuckle_bearing_inner_dia                   = 5.16;

// The height of the 685-Z bearing placeholder used in the knuckle assembly
knuckle_bearing_height                      = 5;

// The height of the flange of the 685-Z bearing placeholder
knuckle_bearing_flanged_height              = 0.5;

// The width of the 685-Z bearing placeholder used in the knuckle assembly
knuckle_bearing_flanged_width               = 0.5;

// The diameter of the knuckle’s wheel shaft for the 608ZZ bearing
knuckle_shaft_dia                           = 8;

// The diameter of the knuckle's connector into which the shaft is inserted. It
// should be larger than the shaft itself.
knuckle_shaft_connector_dia                 = knuckle_shaft_dia * 1.4;

// The diameter of the fastening screws on the knuckle connector for the wheel
// shaft.
knuckle_shaft_screws_dia                    = m25_hole_dia;

// The distance from the top of the shaft to the screw holes
knuckle_shaft_screws_offset                 = 1;
knuckle_shaft_screws_distance               = 2;

// The length of the vertical part of the (curved) axle shaft that connects the
// steering knuckle to the wheel hub
knuckle_shaft_vertical_len                  = knuckle_height + (motor_type == "n20" ? 21.5 : 26.5);

// The additional length of the connector for the shaft in the knuckle and the
// corresponding curved axle shaft
knuckle_shaft_connector_extra_len           = 2;

// The additional length of the for the shaft itself
knuckle_shaft_extra_len                     = assembly_knuckle_shaft_reversed && assembly_steering_system_reversed ? 20 : 0;

// The length of the lower horizontal part of the (curved) axle shaft that is
// inserted into the wheel hub
knuckle_shaft_lower_horiz_len               = 27;

// The height of the upper pins on each side of the frame onto which the
// steering knuckle bearings are mounted
knuckle_pin_bearing_height                  = 8.0;

// The height of the chamfer at the top of the bearing pin
knuckle_pin_chamfer_height                  = 2.5;

// The height of the lower pins on each side of the frame that have bearing pins
// at the top
knuckle_pin_lower_height                    = 5.6;

// The height of the wider lower part of the pin that prevents contact between
// the bearing and the frame
knuckle_pin_stopper_height                  = 1;

// The length of the rotated shaft that connects the knuckle with the bracket
// steering_knuckle_bracket_connector_len          = 12.2;

// The height (thickness) of the knuckle connector with the 685-Z bearing that
// is connected to the bracket
knuckle_bracket_connector_height            = 7;

// ─────────────────────────────────────────────────────────────────────────────
// N20 motor dimensions
// ─────────────────────────────────────────────────────────────────────────────
n20_reductor_dia                            = 14;
n20_reductor_height                         = 9;
n20_shaft_height                            = 9;
n20_shaft_dia                               = 3;
n20_shaft_cutout_w                          = 2;
n20_can_height                              = 15;
n20_can_dia                                 = 12;
n20_can_cutout_w                            = 7;

n20_end_cap_h                               = 0.8;
n20_end_circle_h                            = 0.5;
n20_end_cap_circle_dia                      = 5;
n20_end_cap_circle_hole_dia                 = 3;

// ─────────────────────────────────────────────────────────────────────────────
// N20 motor bracket dimensions
// ─────────────────────────────────────────────────────────────────────────────
n20_motor_bracket_tolerance                 = 0.3;
n20_motor_bracket_thickness                 = 3;
n20_motor_screws_panel_offset               = 11.3;
n20_motor_screws_panel_length               = 4;
n20_motor_screws_dia                        = m25_hole_dia;

n20_motor_chassis_y_distance                = 15;
n20_motor_chassis_x_distance                = -9;

n20_motor_screws_panel_len                  = n20_can_dia + n20_motor_bracket_thickness * 2 +
  n20_motor_screws_dia * 2 + n20_motor_screws_panel_length * 2;
// ─────────────────────────────────────────────────────────────────────────────
// Rear panel: A vertical rear plate with dimensions including two mounting
// holes for switch buttons.
// ─────────────────────────────────────────────────────────────────────────────
rear_panel_size                             = [52, 25, 10];
rear_panel_switch_slot_dia                  = 13;

rear_panel_holes_x_offsets                  = [-16, 16];
rear_panel_screw_holes_x_offsets            = [-16, 0, 16];
rear_panel_screw_hole_dia                   = m25_hole_dia;
rear_panel_thickness                        = 2;
rear_panel_screw_offset                     = 3;

// ─────────────────────────────────────────────────────────────────────────────
// Raspberry Pi dimensions (defaults are for Raspberry PI 5)
// ─────────────────────────────────────────────────────────────────────────────
// Y offset for the Raspberry Pi 5 related slots and holes is measured from the end of the chassis.
rpi_chassis_y_position                      = battery_ups_module_screws_size[0] + 15;

// The X and Y dimensions of the screw positions for the Raspberry Pi 5 slot.
// This forms a square with a screw hole centered on each corner.
rpi_screws_size                             = [50, 58];

// The diameter of the screw holes for the Raspberry Pi 5 slot.
rpi_screw_hole_dia                          = m2_hole_dia;

rpi_len                                     = 85;
rpi_width                                   = 56;
rpi_thickness                               = 1.9;

// The amount by which to offset the Raspberry Pi
rpi_offset_rad                              = 2.4;

// The height of the pin
rpi_pin_height                              = 8.54;

// The width of the single pin black header
rpi_pin_header_width                        = 2.54;

// The height of the pin black headers
rpi_pin_header_height                       = 2.54;

// Whether to show the Raspberry Pi with more realistic details, which may slow
// down the render
rpi_model_detailed                          = false;

rpi_model_text                              = "Raspberry Pi [5]";
rpi_text_font                               = "Ubuntu:style=Bold";

// Raspberry Pi parts dimensions (x, y, z)

rpi_ram_size                                = [10.2, 15, 1]; // Size of the SRAM
rpi_processor_size                          = [15, 15, 0.5]; // BCM2712 processor

// USB 2.0 and USB 3.0 jacks
rpi_usb_size                                = [13.25, 17.60, 15.04];

// Ethernet jack
rpi_ethernet_jack_size                      = [16.15, 21.34, 13.40];

// PCI Express interface
rpi_pci_size                                = [12.85, 2, 3];

// 2 x 4-lane MIPI DSI/CSI connectors
rpi_csi_size                                = [13.0, 2, 2.5];

// USB-c power jack
rpi_usb_c_jack_size                         = [8.2, 7.8, 3];

// 2 x micro-HDMI
rpi_micro_hdmi_jack_size                    = [8.2, 6.5, 3];

// UART connector
rpi_uart_connector_size                     = [2.5, 4.0, 5];

// RTC battery connector
rpi_rtc_connector_size                      = [2.5, 3.4, 5];

// Dual-band 902.11ac Wireless + Bluetooth 5
rpi_wifi_bt_size                            = [14, 11, 1.5];

// RP1 I/O controller
rpi_io_size                                 = [14, 10, 1.5];

// The size of the On-off button
rpi_on_off_button_size                      = [3.85, 1.8, 2];
// The diameter of the On-off button
rpi_on_off_button_dia                       = 1.5;

//The height of the standoffs for Raspberry Pi
rpi_standoff_height                         = 10;

// ─────────────────────────────────────────────────────────────────────────────
// Standard (see motor_type) motor brackets dimension
// ─────────────────────────────────────────────────────────────────────────────
standard_motor_bracket_screws_size          = [-7.5, 10.5];
standard_motor_bracket_chassis_screw_hole   = m2_hole_dia;
standard_motor_bracket_motor_screw_hole     = m3_hole_dia;
standard_motor_bracket_y_offset             = 25;
standard_motor_bracket_width                = 10;
standard_motor_bracket_thickness            = 3;
standard_motor_bracket_height               = 29;

// ─────────────────────────────────────────────────────────────────────────────
// Standard (see motor_type) motor dimensions
// ─────────────────────────────────────────────────────────────────────────────
standard_motor_shaft_color                  = light_grey;

standard_motor_can_color                    = "silver";
standard_motor_endcap_color                 = black_1;

standard_motor_gearbox_body_main_len        = 37;
standard_motor_gearbox_height               = 22.6;
standard_motor_gearbox_color                = yellow_1;
standard_motor_gearbox_side_height          = 19.5;
standard_motor_body_neck_len                = 11.4;
standard_motor_can_len                      = 9.6;
standard_motor_endcap_len                   = 8.5;
standard_motor_shaft_len                    = 35;
standard_motor_shaft_rad                    = 2.8;
standard_motor_shaft_offset                 = 12;

standard_gearbox_neck_rad                   = standard_motor_gearbox_height / 2;
standard_motor_can_rad                      = standard_gearbox_neck_rad  * 0.9;
standard_endcap_rad                         = standard_gearbox_neck_rad  * 0.86;

// ─────────────────────────────────────────────────────────────────────────────
// Steering servo
// ─────────────────────────────────────────────────────────────────────────────
// Dimensions for the slot that accommodates the steering servo motor.
// Tested with the EMAX ES08MA II servo (23 x 11.5 x 24 mm).
//
// The popular SG90 servo measures approximately 23mm x 12.2mm x 29mm, so you
// may want to adjust steering_servo_slot_width and steering_servo_slot_height
// as needed.
steering_servo_extra_width                  = 4;
steering_servo_extra_h                      = 0;
steering_servo_slot_width                   = 23.6;
steering_servo_slot_height                  = 12;
steering_servo_size                         = [23.48, 11.7, 20.3];

// offset between the servo slot and the fastening screws
steering_servo_screws_offset                = 1;

steering_servo_hat_w                        = 33;
steering_servo_hat_h                        = steering_servo_size[1];
steering_servo_hat_thickness                = 1.6;
steering_screws_hat_z_offset                = 4;
steering_servo_gearbox_x_offset             = 3;
steering_servo_gearbox_mode                 = "hull";
steering_servo_text                         = [["EMAX",
                                                4,
                                                "Liberation Sans:style=Bold Italic"],
                                               ["ES08MA II ANALOG SERVO",
                                                1.2,
                                                "Ubuntu:style=Bold"]];
steering_servo_text_size                    = 3;
steering_servo_gearbox_h                    = 4;
steering_servo_gearbox_size                 = [[0.4, 6.09, matte_black],
                                               [0.5, 4.35, dark_gold_2, 8],
                                               [0.8, 2, dark_gold_2],
                                               [2.45, 4, dark_gold_2, 10],
                                               [0.05, 2.6, licorice, 8]];
steering_servo_gearbox_d1                   = 8;
steering_servo_gearbox_d2                   = 6;
steering_servo_color                        = jet_black;
steering_servo_cutted_len                   = 3;

// ─────────────────────────────────────────────────────────────────────────────
// Steering panel
// ─────────────────────────────────────────────────────────────────────────────

steering_panel_center_screws_offsets        = [5.5, 12.0];
steering_panel_center_screw_dia             = m2_hole_dia;

// The length of the two rails in the center of the steering panel that holds
// the rack
steering_panel_rail_len                     = 10;

// The height of the two rails in the center of the steering panel that holds
// the rack
steering_panel_rail_height                  = 8;

// The thickness of the two rails in the center of the steering panel that holds
// the rack
steering_panel_rail_thickness               = 1.5;

// The length of the panel that holds the rack and the pins for the steering
// knuckles at each side
steering_panel_length                       = 134;

// The width of the center panel with steering servo
steering_center_panel_width                 = 15.5;

// The width of the panel that holds the rack and the pins for the steering
// knuckles at each side
steering_rack_support_width                 = 8;

// The diameter of the fastening screws for the servo
steering_servo_screw_dia                    = 2;

// The thickness of the panel that holds the rack and the pins for the steering
// knuckles at each side
steering_rack_support_thickness             = 5;

// The thickness of the vertical panel with the servo slot
steering_vertical_panel_thickness           = 3;

// Position of the steering panel relative to the chassis center. This panel
// houses the rack and pinion assembly implementing Ackerman steering geometry
// for the wheels.
steering_panel_y_pos_from_center            = 65;
steering_panel_hinge_length                 = 10;
steering_panel_hinge_screw_dia              = m25_hole_dia;
steering_panel_hinge_rad                    = min(steering_rack_support_width, steering_panel_hinge_length) * 0.5;
steering_panel_hinge_screw_distance         = 2;

// ─────────────────────────────────────────────────────────────────────────────
// Rack and Pinion
// ─────────────────────────────────────────────────────────────────────────────

// Length of the toothed section of the steering rack (excluding side connectors)
steering_rack_teethed_length                = 59.0;

// The width of the steering rack
steering_rack_width                         = 6;

// The height of the steering rack, excluding the height of the teeth
steering_rack_base_height                   = 9.0;

// The height of the cylindrical pedestals on each side of the rack onto which
// the bearing shaft that connects with the bracket’s bearing is placed
steering_rack_pin_base_height               = 5;

// The diameter of the steering pinion
steering_pinion_d                           = 28.8;

// The diameter of the hole for the servo at the center of the pinion
steering_pinion_center_hole_dia             = 6.5;

// Thickness of the pinion
steering_pinion_thickness                   = 2;

// The diamater of the screw holes for the servo arm around the steering_pinion_center_hole_dia
steering_pinion_screw_dia                   = 1.5;

// Number of teeth on the pinion
steering_pinion_teeth_count                 = 24;

steering_pinion_screws_spacing              = 0.5;

steering_pinion_screws_servo_distance       = 0.8;
steering_pinion_clearance                   = 0.1;
steering_pinion_backlash                    = 0.05;

// The number of degrees of the straightness of the tooth
steering_pinion_pressure_angle              = 20;

// The height of the wider part of the shaft on the L-bracket connector and the
// rack connector. In the first case, this prevents friction between the knuckle
// and the bracket, and in the second case, between the bracket and the rack.
steering_bracket_bearing_stopper_height     = 1;

// The height of the shaft on the L-bracket connector that is inserted into the
// 685-Z bearing on the knuckle
steering_bracket_bearing_pin_height         = 6;

// The height of the cylindrical pedestal on which the bearing shaft is placed
// on the bracket
steering_bracket_bearing_bearing_pin_base_h = 4;

// The outside diameter of the flanged bearing 693 ZZ / 2Z (3x8x4) that is
// inserted into the bearing connector
steering_bracket_bearing_outer_d            = 10.0;

// The outside diameter of the flanged bearing 693 ZZ / 2Z (3x8x4) that is
// inserted into the bearing connector
steering_bracket_bearing_d                  = 8.0;

// The inside diameter (plus tolerance) of the flanged 693 2Z bearing (3x8x4)
steering_bracket_bearing_shaft_d            = 3.05;

// The height of the bearing placeholder in the bracket assembly
steering_bracket_bearing_height             = 4;

// The height of the flanges of the bearing placeholder in the bracket assembly
steering_bracket_bearing_flanged_height     = 0.5;

// The width of the flanges of the bearing placeholder in the bracket assembly
steering_breacket_bearing_flanged_width     = 0.5;

// The length of the L-bracket part that is connected to the rack
steering_bracket_rack_side_h_length         = 11.30;

// The length of the L-bracket part that is connected to the knuckle connector
steering_bracket_rack_side_w_length         = 11.4;

// The width of the L-bracket connector
steering_bracket_linkage_width              = 5;

// The thickness of the L-bracket connector
steering_bracket_linkage_thickness          = 4;

// Ackerman geometry

// Knuckle center along X
steering_x_left_knuckle                     = -steering_panel_length / 2 + knuckle_dia / 2;

// Calculation of the Y-coordinate for the convergence point of the tie rod extensions (at the rear axle)
steering_ackermann_y_intersection           = -chassis_len * 0.5 + n20_motor_screws_panel_len / 2
  + n20_motor_chassis_y_distance - steering_panel_y_pos_from_center;

steering_bracket_bearing_border_w           = (steering_bracket_bearing_outer_d - steering_bracket_bearing_d) / 2;

// The angle of the shaft that connects the knuckle with the bracket
steering_angle_deg                          = round(atan(abs(steering_x_left_knuckle / steering_ackermann_y_intersection)));

steering_alpha_deg                          = steering_angle_deg + 90;

// Rack connector center along X
steering_rack_connector_x_pos               = -steering_rack_teethed_length / 2 - steering_bracket_bearing_outer_d / 2 + steering_bracket_bearing_border_w;

steering_distance_between_knuckle_and_rack  = abs(steering_x_left_knuckle) - abs(steering_rack_connector_x_pos);

steering_knuckle_bracket_connector_len      = (steering_bracket_rack_side_h_length  / sin(180 - steering_alpha_deg))
  - (steering_bracket_bearing_outer_d + steering_bracket_bearing_border_w) / 2;

// ─────────────────────────────────────────────────────────────────────────────
// Ultrasonic placeholder
// ─────────────────────────────────────────────────────────────────────────────

ultrasonic_w                                = 45.42;
ultrasonic_h                                = 20.5;
ultrasonic_thickness                        = 1.25;
ultrasonic_offset_rad                       = 0.5;

ultrasonic_text_size                        = 1.5;

ultrasonic_transducer_dia                   = 15.88;
ultrasonic_transducer_inner_dia             = 12.75;
ultrasonic_transducer_h                     = 12.25;

// distance from the side of the panel
ultrasonic_transducer_x_offset              = 1.5;

ultrasonic_pins_jack_w                      = 11.20;
ultrasonic_pins_jack_h                      = 2.50;
ultrasonic_pins_jack_thickness              = 2.0;
ultrasonic_pins_jack_y_offset               = 1;

ultrasonic_pins_count                       = 4;
ultrasonic_pin_len_a                        = 7.84;
ultrasonic_pin_len_b                        = 5.84;
ultrasonic_pin_protrusion_h                 = 2;

ultrasonic_pin_thickness                    = 0.5;

ultrasonic_oscillator_h                     = 3.5;
ultrasonic_oscillator_w                     = 9.86;
ultrasonic_oscillator_thickness             = 3.33;
ultrasonic_oscillator_y_offset              = 0.8;
ultrasonic_oscillator_solder_x              = 2;

ultrasonic_screw_dia                        = 2.0;
ultrasonic_screw_size                       = [42.0, 17.50];

ultrasonic_smd_len                          = 8;
ultrasonic_smd_h                            = 1.65;
ultrasonic_smd_led_thickness                = 0.4;
ultrasonic_smd_led_count                    = 7;
ultrasonic_smd_w                            = 7.55;
ultrasonic_smd_chip_w                       = 4.0;
ultrasonic_smd_x_offst                      = 1.0;
ultrasonic_solder_blob_d                    = 2.07;
ultrasonic_solder_blobs_positions           = [26, 10];

// ─────────────────────────────────────────────────────────────────────────────
// Parameters for wheels, common for front and rear
// ─────────────────────────────────────────────────────────────────────────────
wheel_dia                                   = 42;
wheel_w                                     = 18.0;
wheel_thickness                             = 2.0;
wheel_rim_h                                 = 1.2;
wheel_rim_w                                 = 1;
wheel_rim_bend                              = 0.8;

// ─────────────────────────────────────────────────────────────────────────────
// Front wheels
// ─────────────────────────────────────────────────────────────────────────────
wheel_hub_outer_d                           = wheel_dia - wheel_thickness * 2;
wheel_hub_outer_ring_d                      = wheel_hub_outer_d;
wheel_hub_d                                 = 22;
wheel_hub_h                                 = 7.2;
wheel_hub_inner_rim_h                       = 1.4;
wheel_hub_inner_rim_w                       = 1.2;
wheel_hub_screws                            = m25_hole_dia;
wheel_screws_n                              = 6;
wheel_screw_boss_w                          = 1;
wheel_screw_boss_h                          = 2;

// ─────────────────────────────────────────────────────────────────────────────
// Rear wheels
// ─────────────────────────────────────────────────────────────────────────────

// Height of the shaft protruding above the wheel
wheel_rear_shaft_protrusion_height          = 10.8;

// Number of rear wheel spokes.
wheel_rear_spokes_count                     = 5;

// Width of rear wheel spokes.
wheel_rear_wheel_spoke_w                    = 18.8;

// The outer diameter of the rear wheel’s shaft. The hole for the motor’s shaft
// is located within this shaft.
wheel_rear_shaft_outer_dia                  = 9.8;

// The inner diameter of the hole for the motor’s shaft in the rear wheel’s
// shaft.
wheel_rear_shaft_inner_dia                  = motor_type == "n20" ? 3.1 : 5.2;

// Number of flat sections on the motor shaft.
// Common values:
//   - 0: round shaft (e.g., basic toy motors)
//   - 1: single flat (e.g., an N20 motor)
//   - 2: dual flats (e.g., yellow plastic gear motors)
wheel_rear_shaft_flat_count                 = motor_type == "n20" ? 1 : 2;

// Length of each flat section on the shaft in millimeters. Measured along the
// shaft’s axis. This value affects the depth of the hub keying feature.
wheel_rear_shaft_flat_len                   = motor_type == "n20" ? 2 : 5;

// The height of the rear wheel’s shaft.
wheel_rear_motor_shaft_height               = 10;

// ─────────────────────────────────────────────────────────────────────────────
// Tires
// ─────────────────────────────────────────────────────────────────────────────

// A small radial offset applied during the subtraction operation to slightly
// enlarge the cut-out, providing extra clearance between the tire and adjacent
// wheel elements.
wheel_tire_offset                           = 0.5;

// The gap value used in the offset operation to round the corners of the tire
// cross-section.
wheel_tire_fillet_gap                       = 0.5;

// The added thickness to the wheel's inner radius for computing the overall
// cross-sectional depth of the tire.
wheel_tire_thickness                        = 9.0;

// The effective width of the tire
wheel_tire_width                            = wheel_w - wheel_rim_w;

// The polygon facet count used with circle-based operations
wheel_tire_fn                               = 360;

wheel_tire_num_grooves                      = 34;
wheel_tire_groove_thickness                 = 0.4;
wheel_tire_groove_depth                     = 3.4;