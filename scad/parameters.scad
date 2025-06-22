
// This module defines a robot parameters

m1_hole_dia                           = 1.2; // M1 screw hole diameter
m2_hole_dia                           = 2.4; // M2 screw hole diameter
m25_hole_dia                          = 2.8; // M2.5 screw hole diameter
m3_hole_dia                           = 3.2; // M3 screw hole diameter

// Chassis dimensions:
chassis_width                         = 110;  // width of the chassis
chassis_len                           = 235;  // length of the chassis
chassis_thickness                     = 3;    // chassis thickness

// Front panel dimensions:
// This panel is vertical and includes mounting holes for the ultrasonic sensors.
front_panel_width                     = 66;   // panel width
front_panel_height                    = 28;   // panel height

front_panel_ultrasonic_sensor_dia     = 17;   // diameter of each mounting hole ("eye") for the ultrasonic sensors
front_panel_ultrasonic_sensors_offset = 9;    // distance between the two ultrasonic sensor mounting holes

front_panel_screws_x_offset           = 27;   // horizontal offset between the ultrasonic sensor mounting holes

// Wheels:
wheels_distance                       = 124; // distance between front wheels
// Offset for the front wheels and the steering servo slot. Also affects the position of the pan servo slot.
wheels_offset_y                       = chassis_len * 0.3;

// Steering system:

// Dimensions for the slot that accommodates the steering servo motor.
// Tested with the EMAX ES08MA II servo (23 x 11.5 x 24 mm).
// The popular SG90 servo measures approximately 23mm x 12.2mm x 29mm, so you may
// want to adjust steering_servo_slot_width and steering_servo_slot_height as needed.
steering_servo_slot_width             = 24;
steering_servo_slot_height            = 12;

steering_servo_screw_dia              = 2;    // diameter of the fastening screws for the servo
steering_servo_screws_offset          = 1.4;  // offset between the servo slot and the fastening screws

steering_link_width                   = 13;
steering_tie_rod_center_screw_d       = 1.5;
steering_tie_rod_width                = 6;
steering_upper_chassis_link_thickness = 2;

// Knuckle
steering_knuckle_screws_dia           = 3.5; // Diameter of the R3065 Rivet used for mounting.
steering_knuckle_width                = 20;  // Overall width of the knuckle.
steering_knuckle_lower_height         = 15;  // Height of the lower part of the knuckle.
steering_knuckle_upper_height         = 8;   // Height of the upper part of the knuckle.
steering_knuckle_side_width           = 13;  // Width of the side feature of the knuckle.
steering_knuckle_side_hole_offset     = 2;   // Offset for positioning side mounting holes.
steering_knuckle_thickness            = 1;   // Thickness of the knuckle walls.

pan_servo_slot_dia                    = 7;    // diameter of the pan servo mounting hole at the front of the chassis

// rear motor panel
motor_mount_panel_width               = 10;
motor_mount_panel_thickness           = 3;
motor_mount_panel_height              = 26;

raspberry_pi_offset                   = chassis_len * 0.06; // Y offset for the Raspberry Pi slot
raspberry_pi5_screws_size             = [50, 58, 10];

ups_hat_screws_size                   = [46, 86, 10];

// Additional cutouts:
extra_cutouts_dia                     = 8; // diameter of the three extra holes on the left and right sides of the chassis

// Rear panel:
// A vertical rear plate with dimensions including two 13-mm mounting holes for switch buttons.
rear_panel_size                       = [52, 25, 2];
rear_panel_switch_slot_dia            = 13;

// Battery holder screws along each side of the chassis

// Vertical offsets for extra battery holder screws along the Y-axis
extra_battery_screws_y_offset_start   = -102;  // Starting Y-offset for extra battery screws
extra_battery_screws_y_offset_end     = 40;    // Ending Y-offset for extra battery screws
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

// head camera
head_camera_lens_width                = 14;
head_camera_lens_height               = 23;