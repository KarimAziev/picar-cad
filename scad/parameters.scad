
// This module defines a robot parameters

m1_hole_dia                           = 1.2; // M1 screw hole diameter
m2_hole_dia                           = 2.4; // M2 screw hole diameter
m25_hole_dia                          = 2.6; // M2.5 screw hole diameter
m3_hole_dia                           = 3.2; // M3 screw hole diameter
r4120_dia                             = 4.6; // diameter in millimeters
r3065_dia                             = 3.5;

// Chassis dimensions:
chassis_width                         = 110;  // width of the chassis
chassis_len                           = 250;  // length of the chassis
chassis_thickness                     = 3;    // chassis thickness
chassis_offset_rad                    = 1;

motor_bracket_screws                  = [-7.5, 10.5];
motor_bracket_offest                  = 25;

// Front panel dimensions:
// This panel is vertical and includes mounting holes for the ultrasonic sensors.
front_panel_width                     = 66;   // panel width
front_panel_height                    = 28;   // panel height

front_panel_ultrasonic_sensor_dia     = 17;   // diameter of each mounting hole ("eye") for the ultrasonic sensors
front_panel_ultrasonic_sensors_offset = 9;    // distance between the two ultrasonic sensor mounting holes

front_panel_screws_x_offset           = 27;   // horizontal offset between the ultrasonic sensor mounting holes

// Wheels:
wheels_distance                       = 124; // distance between front wheels

pan_servo_slot_dia                    = 6.5;    // diameter of the pan servo mounting hole at the front of the chassis
pan_servo_wheels_y_offset             = 50;

// rear motor panel
motor_mount_panel_width               = 10;
motor_mount_panel_thickness           = 3;
motor_mount_panel_height              = 26;
motor_bracket_panel_height            = 29;

raspberry_pi_offset                   = 2.7; // Y offset for the Raspberry Pi slot 14.7
raspberry_pi5_screws_size             = [50, 58];

ups_hat_offset                        = 40; // Y offset for the UPS HAT from Raspberry Pi
ups_hat_screws_size                   = [86, 46];

steering_servo_panel_screws_offsets   = [5.5, 12.0];
steering_servo_panel_screws_dia       = m2_hole_dia;
steering_servo_extra_width            = 4;

// Additional cutouts:
extra_cutouts_dia                     = 8; // diameter of the three extra holes on the left and right sides of the chassis

// Rear panel:
// A vertical rear plate with dimensions including two 13-mm mounting holes for switch buttons.
rear_panel_size                       = [52, 25, 2];
rear_panel_switch_slot_dia            = 13;

// Battery holder screws along each side of the chassis

// Vertical offsets for extra battery holder screws along the Y-axis
extra_battery_screws_y_offset_start   = -30;  // Starting Y-offset for extra battery screws
extra_battery_screws_y_offset_end     = 0;    // Ending Y-offset for extra battery screws
extra_battery_screws_y_offset_step    = 10;    // Step/increment along the Y-axis for extra battery screws

// Dimensions for the screw hole pattern (width, height)
extra_battery_screws_y_size           = [20, 10]; // [width, height] of the screw pattern

// Horizontal offset for the screws on the sides (distance from center)
extra_battery_screws_x_offset         = 24;    // X-offset for positioning screws relative to the center

// Screw hole parameters for extra battery holders
extra_battery_screws_dia              = m2_hole_dia;  // Diameter of the screw holes (uses global m2_hole_dia)
extra_battery_screws_fn_val           = 360;  // Number of fragments for rendering circle (defines resolution)

// Battery holder screws placed at the center of the chassis

// Vertical offsets for center battery screws along the Y-axis
battery_screws_center_y_offset_start  = -100;  // Starting Y-offset for center battery screws
battery_screws_center_y_offset_end    = 100;   // Ending Y-offset for center battery screws
battery_screws_center_y_step          = 20;    // Step/increment along the Y-axis for center battery screws

// Dimensions for the screw hole pattern at the center; note that the X-size is 0 to indicate a central alignment
battery_screws_center_size            = [0, 20];  // [width, height] of the center screw pattern

// Screw hole parameters for center battery holders
battery_screws_center_dia             = m2_hole_dia;  // Diameter of the screw holes (uses same m2_hole_dia)
battery_screws_center_fn_val          = 360;  // Number of fragments for rendering circle (defines resolution)

// head
head_plate_width                      = 38;
head_plate_height                     = 50;
head_plate_thickness                  = 2;

head_side_panel_height                = head_plate_height;
head_side_panel_width                 = head_plate_width * 1.2;
// the diameter of the side hole for mounting servo
head_servo_mount_dia                  = 6.5;
// the diameter of the screws for servo. They are placed around the side hole for mounting servo
head_servo_screw_dia                  = 1.5;

head_upper_plate_width                = head_plate_width * 0.9;
head_upper_plate_height               = head_plate_height / 2;

// head camera
head_camera_lens_width                = 14;
head_camera_lens_height               = 23;
camera_screw_offset_x                 = 10.3;
camera_screw_offset_y                 = -4.2;
camera_screw_offset_y_top             = 8.54;
camera_screw_dia                      = m2_hole_dia;

cam_pan_servo_slot_width              = 23.6;
cam_pan_servo_slot_height             = 12;
cam_pan_servo_height                  = 20;
cam_pan_servo_screw_dia               = 2;
cam_pan_servo_screws_offset           = 1;
cam_pan_servo_slot_thickness          = 2;

cam_tilt_servo_slot_width             = 23.6;
cam_tilt_servo_slot_height            = 12;
cam_tilt_servo_screw_dia              = 2;
cam_tilt_servo_screws_offset          = 1;
cam_tilt_servo_slot_thickness         = 2;
cam_tilt_servo_height                 = 20;
cam_tilt_servo_extra_w                = 4;
cam_tilt_servo_extra_h                = 2;

pan_servo_extra_h                     = 14;
pan_servo_extra_w                     = 4;

// Offset for the front wheels and the steering servo slot. Also affects the position of the pan servo slot.
steering_servo_chassis_offset         = 65;
// Dimensions for the slot that accommodates the steering servo motor.
// Tested with the EMAX ES08MA II servo (23 x 11.5 x 24 mm).
// The popular SG90 servo measures approximately 23mm x 12.2mm x 29mm, so you may
// want to adjust steering_servo_slot_width and steering_servo_slot_height as needed.
steering_servo_slot_width             = 23.6;
steering_servo_slot_height            = 12;

steering_servo_screw_dia              = 2;    // diameter of the fastening screws for the servo
steering_servo_screws_offset          = 1;  // offset between the servo slot and the fastening screws
steering_servo_hat_w                  = 33;

steering_servo_panel_thickness        = 2;

rack_mount_panel_len                  = 124;
rack_mount_panel_thickness            = 3;
rack_mount_panel_width                = 15.5;

tooth_h                               = 4;
tooth_pitch                           = 3;
pinion_d                              = 25;
pinion_servo_dia                      = 6.5;
pinion_thickness                      = 2;
pinion_screw_dia                      = 1.5;

// The height of the knuckle.
knuckle_height                        = 14.0;
knuckle_dia                           = 14.0; // Diameter of the steering knuckle
knuckle_bearing_outer_dia             = 11.0; // Outside diameter of the bearing 685-Z (5x11x5) which is inserted inside knuckle
knuckle_bearing_inner_dia             = 5.1;  // Inside diameter + tolerance of the bearing 685-Z (5x11x5)
knuckle_bearing_height                = 5;
knuckle_bearing_flanged_height        = 0.5;
knuckle_bearing_flanged_width         = 0.5;

// The diameter of the knuckle's wheel shaft for the 608ZZ bearing
knuckle_shaft_dia                     = 8;
knuckle_shaft_connector_dia           = knuckle_shaft_dia * 1.4;

knuckle_shaft_screws_dia              = m25_hole_dia;
knuckle_shaft_screws_offset           = 3; // distance from top of the shaft to the screws holes

knuckle_shaft_vertical_len            = 30;
knuckle_shaft_upper_horiz_len         = 0;
knuckle_shaft_lower_horiz_len         = 25;

// The height of the upper pins on each side of the frame onto which the bearings of the steering knuckles are mounted
knuckle_pin_bearing_height            = 8.0;
// The height of the chamfer at the top of the bearing pin
knuckle_pin_chamfer_height            = 2.5;
// The height of the lower pins on each side of the frame with bearing pins at the top
knuckle_pin_lower_height              = 6;
knuckle_pin_stopper_height            = 1;
// The angle of the shaft that connects the knuckle with the bracket
knuckle_bracket_connector_angle       = 120.0;
// The length of the rotated shaft that connects the knuckle with the bracket.
knuckle_bracket_connector_len         = 12.2;
// The height (thickness) of the knuckle L-bracket's connector
knuckle_bracket_connector_height      = 7;

bracket_bearing_shaft_h               = 7;
bracket_bearing_lower_h               = 4;

bracket_bearing_outer_d               = 10.0; // Outside diameter of the flanged bearing 693 ZZ / 2Z (3x8x4) which is inserted bearing connector
bracket_bearing_d                     = 8.0; // Outside diameter of the flanged bearing 693 ZZ / 2Z (3x8x4) which is inserted bearing connector
bracket_bearing_shaft_d               = 3.1; // Inside diameter + tolerance of flanged the bearing 693 2Z (3x8x4)
bracket_bearing_stopper_height        = 1;

bracket_bearing_height                = 4;
bracket_bearing_flanged_height        = 0.5;
bracket_bearing_flanged_width         = 0.5;

// The length of the L-bracket part that is connected to the rack
bracket_rack_side_h_length            = 10.30;
// The length of the L-bracket part that is connected to the knuckle
bracket_rack_side_w_length            = 9.5; // The L-bracket's part that is connected to the rack

rack_len                              = 49;
rack_width                            = 6;
rack_base_h                           = 3;
rack_rad                              = 0.5;

rack_bracket_width                    = 5;
rack_bracket_thickness                = 3;
rack_connector_lower_h                = 5;

// Parameters for wheel dimensions and screw properties.
wheel_hub_outer_d                     = 48.2;
wheel_hub_d                           = 22;
wheel_hub_h                           = 7.4;
wheel_hub_inner_rim_h                 = 1.4;
wheel_hub_inner_rim_w                 = 1.2;
wheel_hub_screws                      = m3_hole_dia;
wheel_screws_n                        = 6;
wheel_screw_boss_w                    = 1;
wheel_screw_boss_h                    = 2;

wheel_dia                             = 52;
wheel_w                               = 22;
wheel_thickness                       = 1.0;
wheel_rim_h                           = 1.8;
wheel_rim_w                           = 1;
wheel_rim_bend                        = 0.8;
wheel_shaft_offset                    = 0;
wheel_spokes                          = 5;

wheel_spoke_w                         = 22.8;
wheel_shaft_d                         = 6.4;
wheel_tolerance                       = 0.3;