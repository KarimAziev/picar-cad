
// This module defines a robot parameters

m1_hole_dia                            = 1.2; // M1 screw hole diameter
m2_hole_dia                            = 2.4; // M2 screw hole diameter
m25_hole_dia                           = 2.8; // M2.5 screw hole diameter
m3_hole_dia                            = 3.2; // M3 screw hole diameter
r4120_dia                              = 4.6; // diameter in millimeters
r3065_dia                              = 3.5;

// Chassis dimensions:
chassis_width                          = 110;  // width of the chassis
chassis_len                            = 235;  // length of the chassis
chassis_thickness                      = 3;    // chassis thickness

// Front panel dimensions:
// This panel is vertical and includes mounting holes for the ultrasonic sensors.
front_panel_width                      = 66;   // panel width
front_panel_height                     = 28;   // panel height

front_panel_ultrasonic_sensor_dia      = 17;   // diameter of each mounting hole ("eye") for the ultrasonic sensors
front_panel_ultrasonic_sensors_offset  = 9;    // distance between the two ultrasonic sensor mounting holes

front_panel_screws_x_offset            = 27;   // horizontal offset between the ultrasonic sensor mounting holes

// Wheels:
wheels_distance                        = 124; // distance between front wheels
// Offset for the front wheels and the steering servo slot. Also affects the position of the pan servo slot.
wheels_offset_y                        = chassis_len * 0.3;

// Steering system:

// Dimensions for the slot that accommodates the steering servo motor.
// Tested with the EMAX ES08MA II servo (23 x 11.5 x 24 mm).
// The popular SG90 servo measures approximately 23mm x 12.2mm x 29mm, so you may
// want to adjust steering_servo_slot_width and steering_servo_slot_height as needed.
steering_servo_slot_width              = 23.6;
steering_servo_slot_height             = 12;

steering_servo_screw_dia               = 2;    // diameter of the fastening screws for the servo
steering_servo_screws_offset           = 1;  // offset between the servo slot and the fastening screws
steering_servo_hat_w                   = 33;

steering_link_width                    = 13;
steering_tie_rod_center_screw_d        = 1.5;
steering_tie_rod_width                 = 8;
steering_upper_chassis_link_thickness  = 2;

steering_linkage_connector_len         = 30;

steering_linkage_connector_height      = steering_tie_rod_width;
steering_linkage_connector_bracket_len = 22;
steering_long_linkage_len              = wheels_distance - steering_linkage_connector_bracket_len - 10;
steering_short_linkage_len             = steering_long_linkage_len * 0.8;

// Knuckle
front_wheel_knuckle_dia                = r4120_dia; // Diameter of screws for knuckle and front wheel
steering_knuckle_screws_dia            = r3065_dia; // Diameter of screws for knuckle and linkage
steering_knuckle_width                 = 22;  // Overall width of the knuckle.
steering_knuckle_lower_height          = 15;  // Height of the lower part of the knuckle.
steering_knuckle_upper_height          = 8;   // Height of the upper part of the knuckle.
steering_knuckle_side_width            = 13;  // Width of the side feature of the knuckle.
steering_knuckle_side_hole_offset      = 2;   // Offset for positioning side mounting holes.
steering_knuckle_thickness             = 2;   // Thickness of the knuckle walls.
steering_ackernmann_connector_angle    = 120;   // Angle of the linkage connectors for ackermann

pan_servo_slot_dia                     = 7;    // diameter of the pan servo mounting hole at the front of the chassis
pan_servo_wheels_y_offset              = 18;

// rear motor panel
motor_mount_panel_width                = 10;
motor_mount_panel_thickness            = 3;
motor_mount_panel_height               = 26;

raspberry_pi_offset                    = chassis_len * 0.06; // Y offset for the Raspberry Pi slot
raspberry_pi5_screws_size              = [50, 58, 10];

ups_hat_screws_size                    = [46, 86, 10];

// Additional cutouts:
extra_cutouts_dia                      = 8; // diameter of the three extra holes on the left and right sides of the chassis

// Rear panel:
// A vertical rear plate with dimensions including two 13-mm mounting holes for switch buttons.
rear_panel_size                        = [52, 25, 2];
rear_panel_switch_slot_dia             = 13;

// Battery holder screws along each side of the chassis

// Vertical offsets for extra battery holder screws along the Y-axis
extra_battery_screws_y_offset_start    = -30;  // Starting Y-offset for extra battery screws
extra_battery_screws_y_offset_end      = 0;    // Ending Y-offset for extra battery screws
extra_battery_screws_y_offset_step     = 10;    // Step/increment along the Y-axis for extra battery screws

// Dimensions for the screw hole pattern (width, height)
extra_battery_screws_y_size            = [20, 10]; // [width, height] of the screw pattern

// Horizontal offset for the screws on the sides (distance from center)
extra_battery_screws_x_offset          = 24;    // X-offset for positioning screws relative to the center

// Screw hole parameters for extra battery holders
extra_battery_screws_dia               = m2_hole_dia;  // Diameter of the screw holes (uses global m2_hole_dia)
extra_battery_screws_fn_val            = 360;  // Number of fragments for rendering circle (defines resolution)

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
head_servo_mount_dia                   = 7;
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
cam_pan_servo_slot_thickness           = 2;

cam_tilt_servo_slot_width              = 23.6;
cam_tilt_servo_slot_height             = 12;
cam_tilt_servo_screw_dia               = 2;
cam_tilt_servo_screws_offset           = 1;
cam_tilt_servo_slot_thickness          = 2;
cam_tilt_servo_height                  = 20;
cam_tilt_servo_extra_w                 = 4;
cam_tilt_servo_extra_h                 = 2;

pan_servo_extra_h                      = 14;
pan_servo_extra_w                      = 4;

// Parameters for hub dimensions and screw properties.
wheel_hub_d                            = 22;
wheel_hub_h                            = 7.4;
wheel_hub_inner_rim_h                  = 1.4;
wheel_hub_inner_rim_w                  = 1.2;
wheel_hub_screws                       = m3_hole_dia;
wheel_screws_n                         = 6;
wheel_hub_outer_d                      = 48.2;
wheel_screw_boss_w                     = 1;
wheel_screw_boss_h                     = 2;

wheel_dia                              = 50;
wheel_w                                = 22;
wheel_thickness                        = 1.0;
wheel_rim_h                            = 1.8;
wheel_rim_w                            = 1;
wheel_rim_bend                         = 0.8;
wheel_shaft_offset                     = 0;
wheel_spokes                           = 5;

wheel_spoke_w                          = 22.8;
wheel_shaft_d                          = 6.4;
wheel_tolerance                        = 0.3;

rack_len                               = 60;
rack_pan_full_len                      = 120;

tooth_h                                = 4;
tooth_pitch                            = 3;
pinion_d                               = 25;
pinion_servo_dia                       = 6.5;
pinion_thickness                       = 2;
pinion_screw_dia                       = 1.5;
pinion_center_hole_dia                 = 6.5;
pinion_z_offst                         = 4;

upper_knuckle_h                        = 9;
lower_knuckle_h                        = 5;
upper_knuckle_d                        = 14;
lower_knuckle_d                        = 8;

knuckle_ring_inner_w                   = 1;

knuckle_connector_angle                = 110;
rack_width                             = 6;
rack_base_h                            = 3;
rack_rad                               = 0.5;
rack_rail_width                        = 14;

rack_side_connector_thickness          = 3;

rack_side_connector_screws_dia         = m2_hole_dia;
raw_connector_len                      = rack_side_connector_screws_dia * 2 + rack_side_connector_thickness;

rack_side_connector_size               = [rack_width, rack_base_h, raw_connector_len];
rack_knuckle_connector_dia             = 6;

shaft_height                           = 50;
shaft_dia                              = 8;

distance_between_rack_and_knuckle      = (((rack_pan_full_len / 2) - upper_knuckle_d) * 2 - (rack_len + raw_connector_len * 2));
bracket_screws_dia                     = m2_hole_dia;
bracket_thickness                      = 3;

bracket_rack_side_length               = 17; // The bracket's part that is connected to the rack
// bracket_knuckle_side_len               = 11;  // The bracket's part that is connected to the knuckle's shaft connector
knuckle_shaft_len                      = 6; // the length of the knuckle's shaft connector
bracket_cut_offset                     = (bracket_rack_side_length / tan(knuckle_connector_angle));
bracket_knuckle_side_len               = distance_between_rack_and_knuckle + bracket_cut_offset + rack_side_connector_screws_dia / 2 + 0.5;

bracket_size                           = [4, bracket_rack_side_length, bracket_knuckle_side_len];

steering_servo_panel_thickness         = 2;

// translate([-50, 10, 20]) {
//   color("red") {
//     l = ((rack_pan_full_len / 2) - upper_knuckle_d) * 2;
//     rack_l = (rack_len + rack_side_connector_size[2] * 2);
//     dist = (((rack_pan_full_len / 2) - upper_knuckle_d) * 2 - (rack_len + rack_side_connector_size[2] * 2));
//     square(size = [5, knuckle_shaft_len - shaft_dia / 2], center = true);
//   }
// }
// echo("bracket_knuckle_side_len", bracket_knuckle_side_len, "distance_between_rack_and_knuckle", distance_between_rack_and_knuckle, bracket_cut_offset, "tan", tan(knuckle_connector_angle));