
// This module defines a robot parameters

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
steering_knuckle_screws_dia           = 3.5; // diameter of R3065 Rivet
steering_tie_rod_center_screw_d       = 1.5;
steering_tie_rod_width                = 6;
steering_upper_chassis_link_thickness = 2;

pan_servo_slot_dia                    = 7;    // diameter of the pan servo mounting hole at the front of the chassis

// rear motor panel
motor_mount_panel_width               = 10;
motor_mount_panel_thickness           = 3;
motor_mount_panel_height              = 26;

raspberry_pi_offset                   = chassis_len * 0.06; // Y offset for the Raspberry Pi slot
raspberry_pi5_screws_size             = [50, 58, 10];

battery_holders_screws_size           = [20, 70, 10];
extra_battery_holders_screws_size     = [0, 20, 10];
ups_hat_screws_size                   = [46, 86, 10];

// Additional cutouts:
extra_cutouts_dia                     = 8; // diameter of the three extra holes on the left and right sides of the chassis

// Rear panel:
// A vertical rear plate with dimensions including two 13-mm mounting holes for switch buttons.
rear_panel_size                       = [52, 25, 2];
rear_panel_switch_slot_dia            = 13;
