use <util.scad>
// This module defines a robot parameters

m1_hole_dia                            = 1.2; // M1 screw hole diameter
m2_hole_dia                            = 2.4; // M2 screw hole diameter
m25_hole_dia                           = 2.6; // M2.5 screw hole diameter
m3_hole_dia                            = 3.2; // M3 screw hole diameter
r4120_dia                              = 4.6; // diameter in millimeters
r3065_dia                              = 3.5;

// Chassis dimensions:
chassis_width                          = 120;  // width of the chassis
chassis_len                            = 254;  // length of the chassis
chassis_thickness                      = 4.0;    // chassis thickness
chassis_offset_rad                     = 1; // The amount by which to offset the chassis

// Type of the DC motor to use. Either "n20" or "standard". "n20" refers to
// motors like the GA12-N20 with a 3mm shaft, whereas "standard" refers to
// popular, inexpensive, unnamed yellow motors with a 5mm shaft. This setting
// affects the shape and type of the motor bracket and the diameter of the rear
// wheel shafts.
motor_type                             = "n20";

motor_bracket_screws                   = [-7.5, 10.5];
motor_bracket_offest                   = 25;

// Front panel dimensions:
// This panel is vertical and includes mounting holes for the ultrasonic sensors.
front_panel_chassis_y_offset           = 5;
front_panel_width                      = 66;   // panel width
front_panel_height                     = 28;   // panel height
front_panel_thickness                  = 2;   // panel thickness
front_panel_rear_panel_thickness       = 1.5;
front_panel_connector_screw_dia        = m25_hole_dia;
front_panel_connector_len              = 15;
front_panel_connector_width            = chassis_width / 4;
front_panel_connector_screw_offsets    = [[4, 3], [0, 3], [-4, 3]];

// diameter of each mounting hole ("eye") for the ultrasonic sensors
front_panel_ultrasonic_sensor_dia      = 17;

// distance between the two ultrasonic sensor mounting holes
front_panel_ultrasonic_sensors_offset  = 9;

// horizontal offset between the ultrasonic sensor mounting holes
front_panel_screws_x_offset            = 27;

// diameter of the pan servo mounting hole at the front of the chassis
pan_servo_slot_dia                     = 6.5;

// Position of the steering panel relative to the chassis center. This panel
// houses the rack and pinion assembly implementing Ackerman steering geometry
// for the wheels.
steering_servo_chassis_y_offset        = 65;

// Vertical offset, measured from the steering panel's position, for the pan
// servo cut-out. The pan servo is mounted on a bottom horizontal panel (with a
// gear hole interfacing with the chassis) that is part of the robot’s head
// (which also carries the cameras). Its placement is determined by adding this
// offset to steering_servo_chassis_y_offset.
pan_servo_y_offset_from_steering_panel = 47;

// rear motor panel for the "standard" yellow motor (see motor_type)
motor_mount_panel_width                = 10;
motor_mount_panel_thickness            = 3;
motor_mount_panel_height               = 26;
motor_bracket_panel_height             = 29;

// Y offset for the Raspberry Pi 5 slot measured from the chassis center
raspberry_pi_offset                    = 2.7;

// The X and Y dimensions of the screw positions for the Raspberry Pi 5 slot.
// This forms a square with a screw hole centered on each corner.
raspberry_pi5_screws_size              = [50, 58];

// The diameter of the screw holes for the Raspberry Pi 5 slot.
raspberry_pi5_screws_hole_size         = m2_hole_dia;

// Y offset for the UPS HAT slot, measured from the Raspberry Pi
// (raspberry_pi_offset) position to the end of the chassis
ups_hat_offset                         = 40;

// The X and Y dimensions of the screw positions for the UPS HAT slot.
// This forms a square with a screw hole centered on each corner.
ups_hat_screws_size                    = [86, 46];

steering_servo_panel_screws_offsets    = [5.5, 12.0];
steering_servo_panel_screws_dia        = m2_hole_dia;
steering_servo_extra_width             = 4;

// The diameter of the three extra holes on the left and right sides of the
// chassis
extra_cutouts_dia                      = 8;

// Rear panel: A vertical rear plate with dimensions including two 13-mm
// mounting holes for switch buttons.
rear_panel_size                        = [52, 25, 10];
rear_panel_switch_slot_dia             = 13;

rear_panel_holes_x_offsets             = [-16, 16];
rear_panel_screw_holes_x_offsets       = [-16, 0, 16];
rear_panel_screw_hole_dia              = m25_hole_dia;
rear_panel_thickness                   = 2;
rear_panel_screw_offset                = 3;

/**
 * Battery holder screws along each side of the chassis
 */

// Vertical offsets for extra battery holder screws along the Y-axis

// Starting Y-offset for extra battery screws
extra_battery_screws_y_offset_start    = -30;

// Ending Y-offset for extra battery screws
extra_battery_screws_y_offset_end      = 0;

// Step/increment along the Y-axis for extra battery screws
extra_battery_screws_y_offset_step     = 10;

// Dimensions for the screw hole pattern (width, height)
extra_battery_screws_y_size            = [20, 10]; // [width, height] of the screw pattern

// Horizontal offset for the screws on the sides (distance from center)

// X-offset for positioning screws relative to the center
extra_battery_screws_x_offset          = 24;

// Screw hole parameters for extra battery holders

// Diameter of the screw holes (uses global m2_hole_dia)
extra_battery_screws_dia               = m2_hole_dia;

// Number of fragments for rendering circle (defines resolution)
extra_battery_screws_fn_val            = 360;

// Battery holder screws placed at the center of the chassis

// Vertical offsets for center battery screws along the Y-axis
battery_screws_center_y_offset_start   = -100;  // Starting Y-offset for center battery screws
battery_screws_center_y_offset_end     = 100;   // Ending Y-offset for center battery screws
battery_screws_center_y_step           = 20;    // Step/increment along the Y-axis for center battery screws

// Dimensions for the screw hole pattern at the center; note that the X-size is 0 to indicate a central alignment
battery_screws_center_size             = [0, 20];  // [width, height] of the center screw pattern

// Screw hole parameters for center battery holders
battery_screws_center_dia              = m2_hole_dia;  // Diameter of the screw holes (uses same m2_hole_dia)
battery_screws_center_fn_val           = 360;  // Number of fragments for rendering circle (defines resolution)

// head
head_plate_width                       = 38;
head_plate_height                      = 50;
head_plate_thickness                   = 2;

head_side_panel_height                 = head_plate_height;
head_side_panel_width                  = head_plate_width * 1.2;

// the diameter of the side hole for mounting servo
head_servo_mount_dia                   = 6.5;

// the diameter of the screws for servo. They are placed around the side hole for mounting servo
head_servo_screw_dia                   = 1.5;

head_upper_plate_width                 = head_plate_width * 0.9;
head_upper_plate_height                = head_plate_height / 2;

// head camera
head_camera_lens_width                 = 14;
head_camera_lens_height                = 23;
camera_screw_offset_x                  = 10.3;
camera_screw_offset_y                  = -4.2;
camera_screw_offset_y_top              = 8.54;
camera_screw_dia                       = m2_hole_dia;

cam_pan_servo_slot_width               = 23.6;
cam_pan_servo_slot_height              = 12;
cam_pan_servo_height                   = 20;
cam_pan_servo_screw_dia                = 2;
cam_pan_servo_screws_offset            = 1;
cam_pan_servo_slot_thickness           = 2.5;

cam_tilt_servo_slot_width              = 23.6;
cam_tilt_servo_slot_height             = 12;
cam_tilt_servo_screw_dia               = 2;
cam_tilt_servo_screws_offset           = 1;
cam_tilt_servo_slot_thickness          = 2.5;
cam_tilt_servo_height                  = 20;
cam_tilt_servo_extra_w                 = 4;
cam_tilt_servo_extra_h                 = 2;

pan_servo_extra_h                      = 14;
pan_servo_extra_w                      = 4;

/**
 * Steering system
 */
// Dimensions for the slot that accommodates the steering servo motor.
// Tested with the EMAX ES08MA II servo (23 x 11.5 x 24 mm).
// The popular SG90 servo measures approximately 23mm x 12.2mm x 29mm, so you may
// want to adjust steering_servo_slot_width and steering_servo_slot_height as needed.
steering_servo_slot_width              = 23.6;
steering_servo_slot_height             = 12;

// The diameter of the fastening screws for the servo
steering_servo_screw_dia               = 2;

// offset between the servo slot and the fastening screws
steering_servo_screws_offset           = 1;

// The width of the wider part of the steering servo usually contains screw holes.
steering_servo_hat_w                   = 33;

// The thickness of the vertical panel with the servo slot
steering_servo_panel_thickness         = 2;

// The length of the panel that holds the rack and the pins for the steering
// knuckles at each side
rack_mount_panel_len                   = 134;

// The width of the panel that holds the rack and the pins for the steering
// knuckles at each side
rack_mount_panel_width                 = 15.5;

// The width of the panel that holds the rack and the pins for the steering
// knuckles at each side
rack_mount_rack_panel_width            = 8;

// The thickness of the panel that holds the rack and the pins for the steering
// knuckles at each side
rack_mount_panel_thickness             = 4;

// The height of the pinion and rack teeth
tooth_h                                = 4;

// The diameter of the pinion
pinion_d                               = 25;

// The diameter of the steering pinion
steering_pinion_d                      = 28.8;

// The diameter of the hole for the servo at the center of the pinion
pinion_servo_dia                       = 6.5;

// Thickness of the pinion
pinion_thickness                       = 2;

// The diamater of the screw holes for the servo arm around the pinion_servo_dia
pinion_screw_dia                       = 1.5;

// The diamater of the screw holes for the servo arm around the pinion_servo_dia
steering_pinion_teeth_count            = 18;

steering_pinion_screws_spacing         = 0.5;

steering_pinion_screws_servo_distance  = 0.8;
steering_pinion_clearance              = 0.0;
steering_pinion_backlash               = 0;

// The number of degrees of the straightness of the tooth
steering_pinion_pressure_angle         = 28;

// The height of the steering knuckle
knuckle_height                         = 14.0;

// Diameter of the steering knuckle
knuckle_dia                            = 14.0;

// The outside diameter of the 685-Z bearing (5x11x5) that is inserted into the
// knuckle
knuckle_bearing_outer_dia              = 11.0;

// The inside diameter (plus tolerance) of the 685-Z bearing (5x11x5)
knuckle_bearing_inner_dia              = 5.2;

// The height of the 685-Z bearing placeholder used in the knuckle assembly
knuckle_bearing_height                 = 5;

// The height of the flange of the 685-Z bearing placeholder
knuckle_bearing_flanged_height         = 0.5;

// The width of the 685-Z bearing placeholder used in the knuckle assembly
knuckle_bearing_flanged_width          = 0.5;

// The diameter of the knuckle’s wheel shaft for the 608ZZ bearing
knuckle_shaft_dia                      = 8;

// The diameter of the knuckle's connector into which the shaft is inserted. It
// should be larger than the shaft itself.
knuckle_shaft_connector_dia            = knuckle_shaft_dia * 1.4;

// The diameter of the fastening screws on the knuckle connector for the wheel
// shaft.
knuckle_shaft_screws_dia               = m25_hole_dia;

// The distance from the top of the shaft to the screw holes
knuckle_shaft_screws_offset            = 1;
knuckle_shaft_screws_distance          = 2;

// The length of the vertical part of the (curved) axle shaft that connects the
// steering knuckle to the wheel hub
knuckle_shaft_vertical_len             = 20 + knuckle_height;

// The additional length of the connector for the shaft in the knuckle and the
// corresponding curved axle shaft
knuckle_shaft_connector_extra_len      = 0;

// The length of the lower horizontal part of the (curved) axle shaft that is
// inserted into the wheel hub
knuckle_shaft_lower_horiz_len          = 27;

// The height of the upper pins on each side of the frame onto which the
// steering knuckle bearings are mounted
knuckle_pin_bearing_height             = 8.0;

// The height of the chamfer at the top of the bearing pin
knuckle_pin_chamfer_height             = 2.5;

// The height of the lower pins on each side of the frame that have bearing pins
// at the top
knuckle_pin_lower_height               = 2;

// The height of the wider lower part of the pin that prevents contact between
// the bearing and the frame
knuckle_pin_stopper_height             = 1;

// The length of the rotated shaft that connects the knuckle with the bracket
// knuckle_bracket_connector_len          = 12.2;

// The height (thickness) of the knuckle connector with the 685-Z bearing that
// is connected to the bracket
knuckle_bracket_connector_height       = 7;

// The height of the wider part of the shaft on the L-bracket connector and the
// rack connector. In the first case, this prevents friction between the knuckle
// and the bracket, and in the second case, between the bracket and the rack.
bracket_bearing_stopper_height         = 1;

// The height of the shaft on the L-bracket connector that is inserted into the
// 685-Z bearing on the knuckle
bracket_bearing_pin_height             = 6;

// The height of the cylindrical pedestal on which the bearing shaft is placed
// on the bracket
bracket_bearing_pin_base_height        = 4;

// The outside diameter of the flanged bearing 693 ZZ / 2Z (3x8x4) that is
// inserted into the bearing connector
bracket_bearing_outer_d                = 10.0;

// The outside diameter of the flanged bearing 693 ZZ / 2Z (3x8x4) that is
// inserted into the bearing connector
bracket_bearing_d                      = 8.0;

// The inside diameter (plus tolerance) of the flanged 693 2Z bearing (3x8x4)
bracket_bearing_shaft_d                = 3.1;

// The height of the bearing placeholder in the bracket assembly
bracket_bearing_height                 = 4;

// The height of the flanges of the bearing placeholder in the bracket assembly
bracket_bearing_flanged_height         = 0.5;

// The width of the flanges of the bearing placeholder in the bracket assembly
bracket_bearing_flanged_width          = 0.5;

// The length of the L-bracket part that is connected to the rack
bracket_rack_side_h_length             = 11.30;

// The length of the L-bracket part that is connected to the knuckle connector
// bracket_rack_side_w_length             = 12.5;

rack_len                               = 59.0;    // The length of the steering rack
rack_width                             = 6;     // The width of the steering rack

// The height of the steering rack, excluding the height of the teeth
rack_base_h                            = 5.8;

// The height of the cylindrical pedestals on each side of the rack onto which
// the bearing shaft that connects with the bracket’s bearing is placed
rack_pin_base_height                   = 5;

// The amount by which to offset the rack teeth
rack_rad                               = 1.0;

// The width of the L-bracket connector
steering_bracket_linkage_width         = 5;

// The thickness of the L-bracket connector
steering_bracket_linkage_thickness     = 4;

// Parameters for wheel dimensions and screw properties.
wheel_hub_outer_d                      = 48.2;
wheel_hub_d                            = 22;
wheel_hub_h                            = 7.4;
wheel_hub_inner_rim_h                  = 1.4;
wheel_hub_inner_rim_w                  = 1.2;
wheel_hub_screws                       = m3_hole_dia;
wheel_screws_n                         = 6;
wheel_screw_boss_w                     = 1;
wheel_screw_boss_h                     = 2;

wheel_dia                              = 52;
wheel_w                                = 21.6;
wheel_thickness                        = 1.0;
wheel_rim_h                            = 1.2;
wheel_rim_w                            = 1;
wheel_rim_bend                         = 0.8;
wheel_shaft_offset                     = 10.8;

// Number of rear wheel spokes.
rear_wheel_spokes_count                = 5;

// Width of rear wheel spokes.
rear_wheel_spoke_w                     = 22.8;

// The outer diameter of the rear wheel’s shaft. The hole for the motor’s shaft
// is located within this shaft.
rear_wheel_shaft_outer_dia             = 6.4;

// The inner diameter of the hole for the motor’s shaft in the rear wheel’s
// shaft.
rear_wheel_shaft_inner_dia             = motor_type == "n20" ? 3.2 : 5.2;

// Number of flat sections on the motor shaft.
// Common values:
//   - 0: round shaft (e.g., basic toy motors)
//   - 1: single flat (e.g., an N20 motor)
//   - 2: dual flats (e.g., yellow plastic gear motors)
rear_wheel_shaft_flat_count            = motor_type == "n20" ? 1 : 2;

// Length of each flat section on the shaft in millimeters. Measured along the
// shaft’s axis. This value affects the depth of the hub keying feature.
rear_wheel_shaft_flat_len              = motor_type == "n20" ? 2 : 5;

// The height of the rear wheel’s shaft.
rear_wheel_motor_shaft_height          = 10;

// A small radial offset applied during the subtraction operation to slightly
// enlarge the cut-out, providing extra clearance between the tire and adjacent
// wheel elements.
tire_offset                            = 0.5;

// The gap value used in the offset operation to round the corners of the tire
// cross-section.
tire_fillet_gap                        = 0.5;

// The added thickness to the wheel's inner radius for computing the overall
// cross-sectional depth of the tire.
tire_thickness                         = 3.5;

// The effective width of the tire
tire_width                             = wheel_w - wheel_rim_w;

// The polygon facet count used with circle-based operations
tire_fn                                = 360;

n20_reductor_dia                       = 14;
n20_reductor_height                    = 9;
n20_shaft_height                       = 9;
n20_shaft_dia                          = 3;
n20_shaft_cutout_w                     = 2;
n20_can_height                         = 15;
n20_can_dia                            = 12;
n20_can_cutout_w                       = 7;

n20_end_cap_h                          = 0.8;
n20_end_circle_h                       = 0.5;
n20_end_cap_circle_dia                 = 5;
n20_end_cap_circle_hole_dia            = 3;

n20_motor_bracket_thickness            = 1;
n20_motor_screws_panel_offset          = 1;
n20_motor_screws_panel_length          = 4;
n20_motor_screws_dia                   = m25_hole_dia;

n20_motor_chassis_y_distance           = 15;
n20_motor_chassis_x_distance           = -9;

n20_motor_screws_panel_len             = n20_can_dia + n20_motor_bracket_thickness * 2 +
  n20_motor_screws_dia * 2 + n20_motor_screws_panel_length * 2;

// Ackerman geometry

// Knuckle center along X
x_left_knuckle                         = -rack_mount_panel_len / 2 + knuckle_dia / 2;

// Calculation of the Y-coordinate for the convergence point of the tie rod extensions (at the rear axle)
y_intersection                         = -chassis_len * 0.5 + n20_motor_screws_panel_len / 2
  + n20_motor_chassis_y_distance - steering_servo_chassis_y_offset;

bracket_bearing_border_w               = (bracket_bearing_outer_d - bracket_bearing_d) / 2;

// The angle of the shaft that connects the knuckle with the bracket
ackermann_angle_deg                    = round(atan(abs(x_left_knuckle) / abs(y_intersection)));
ackerman_alpha_deg                     = ackermann_angle_deg + 90;
// Rack connector center along X
rack_left_connector_x                  = -rack_len / 2 - bracket_bearing_outer_d / 2 + bracket_bearing_border_w;

distance_between_knuckle_and_rack      = abs(x_left_knuckle) - abs(rack_left_connector_x);

knuckle_bracket_connector_len          = (bracket_rack_side_h_length  / sin(180 - ackerman_alpha_deg)) - (bracket_bearing_outer_d + bracket_bearing_border_w) / 2;
bracket_bearing_ackerman_offst         = -bracket_bearing_outer_d +
  (calc_notch_width(bracket_bearing_outer_d, steering_bracket_linkage_width) / 2);

ackerman_dx                            = (bracket_rack_side_h_length / tan(ackerman_alpha_deg)) + bracket_bearing_ackerman_offst;

bracket_rack_side_w_length             = 11.4;

// bracket_rack_side_w_length             = 12.5;
