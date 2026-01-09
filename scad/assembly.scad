
/**
 * Module: Assembly view.
 *
 * The module shows the complete 3D assembled model.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <colors.scad>
include <parameters.scad>

use <components/chassis/chassis.scad>

/* [Colors] */
panel_color                       = "white";
pinion_color                      = "white";
power_case_color                  = panel_color;

/* [Power Case] */
show_socket_case                  = true;
// Insert the socket jack for the XT90E-M male connector and fasten it with bolts.
show_socket                       = true;
// Seat the XT90E-M male connector into the fuse holders.
// Connect the XT90E-M male connector to the fuse holders.
show_socket_case_fuses            = true;

// Slide the socket case lid into place.
show_socket_case_lid              = true;

// Now mount the power case onto the socket-case lid.
show_power_case                   = true;
// Insert the bolts.
show_power_case_bottom_bolts      = true;
// Show the required bolt length and diameter.
show_power_case_bottom_bolts_info = true;
// Tighten the bolts.
power_case_bottom_bolts_down      = true;

// From the bottom, fasten the bolts to the standoffs.
show_power_case_show_standoffs    = true;
// Attach your Turnigy Rapid (or other LiPo) pack.
show_lipo_pack                    = true;

// Uncheck the previous variables to see only the power-lid assembly.
show_power_case_lid               = true;
// Connect your step-down voltage regulator.
show_power_lid_dc_regulator       = true;
// Connect the step-down voltage regulator to the fuse holders.
show_power_lid_atm_fuse_holders   = true;
// Connect your voltmeters.
show_power_lid_voltmeter          = true;
// Connect your perfboard, if any.
show_power_lid_perf_board         = true;

// Fasten everything with bolts.
show_lid_bolts                    = true;

// Connect your custom slots, if any.
// Show if defined in power_lid_left_slots or power_lid_right_slots.
show_power_lid_ato_fuse           = true;
// Show XT90E if defined in power_lid_left_slots or power_lid_right_slots.
show_power_lid_case_xt90e         = true;
// Toggle any extra lid slot fillers defined in power_lid_left_slots or power_lid_right_slots.

/* [Head] */
// Preview the entire head stack at once.
show_head_assembly                = true;
// Drop the tilt servo into the neck tilt bracket.
show_tilt_servo                   = true;
// Install the pan servo into the neck base.
show_pan_servo                    = true;
// Attach the head shell on top of the tilt bracket.
show_head                         = true;
// Insert the camera boards into their holders.
show_camera                       = true;
// Fasten the IR LED case onto the head.
show_ir_case                      = true;
// Seat the IR LED board inside its case.
show_ir_led                       = true;

pan_servo_rotation                = 0; // [-179:179]
tilt_servo_rotation               = 0; // [-90:90]

/* [Chassis] */
// Add the upper chassis plate.
show_upper_chassis_body           = true;
// Show the main chassis body.
show_chassis_body                 = true;

/* [Batteries] */
// Place battery holders into the chassis.
show_battery_holders              = true;
// Bolt the battery holders from the top.
show_battery_holders_bolts        = true;
// Capture nuts underneath the holders.
show_battery_holders_nuts         = true;
// Load the cells into the holders.
show_batteries                    = true;

/* [Motors] */
// Mount the motor brackets to the chassis sides.
show_motor_brackets               = true;
// Slide the motors into the brackets.
show_motor                        = true;

/* [Buttons and Fuses Stack] */
// Attach the fuse panel to the rear stack.
show_fuse_panel                   = true;
// Insert fuses into the panel.
show_fuses                        = true;
// Mount the buttons panel.
show_buttons_panel                = true;
// Install buttons into their panel cutouts.
show_buttons                      = true;

/* [Steering Panel] */
// Fix the steering panel to the chassis.
show_steering_panel               = true;

// Drop the rack into its guide.
show_rack                         = true;
// Bolt the kingpin posts to the steering panel.
show_kingpin_posts                = true;
show_kingpin_bolt                 = true;

show_bolts_info                   = false;

fasten_kingpin_bolt               = true;

// Install the steering servo mount.
show_servo_mount_panel            = true;

show_panel_bolt                   = true;
fasten_panel_bolt                 = true;
// Mount the steering servo on its panel.
show_servo                        = true;
// Press the pinion onto the servo spline.
show_pinion                       = true;
// Attach the knuckles to the kingpin posts.
show_knuckles                     = true;
// Keep bearings visible for clearance checks.
show_knuckle_bolts                = true;

show_bearing                      = true;
// Add the tie-rod brackets to the knuckles.
show_brackets                     = true;
// Link the knuckles with the tie rod.
show_tie_rod                      = true;

show_hinges_bolts                 = true;

fasten_hinges_bolts               = true;

/* [Raspberry PI] */
// Place the Raspberry Pi board on its standoffs.
show_rpi                          = true;
// Add the AI hat above the Pi.
show_ai_hat                       = true;
// Stack the motor driver hat.
show_motor_driver_hat             = true;
// Stack the servo driver hat.
show_servo_driver_hat             = true;
// Drop the GPIO expansion board into position.
show_gpio_expansion_board         = true;

/* [Front Panel] */
// Mount the front sensor panel.
show_front_panel                  = true;
// Insert the HC-SR04 ultrasonic module.
show_ultrasonic                   = true;
// Add the rear stiffener for the front panel.
show_front_rear_panel             = true;

/* [Rear panel] */
show_rear_panel                   = false;
show_rear_panel_buttons           = false;

/* [Wheels] */
// Install the front wheels onto the knuckles.
show_front_wheels                 = true;
// Push the rear wheels onto the motor shafts.
show_rear_wheels                  = true;

/* [UPS hat] */

show_ups_hat                      = false;

/* [Debug] */
show_ackermann_triangle           = false;
show_distance                     = false;

chassis(panel_color=panel_color,
        pinion_color=pinion_color,
        power_case_color=power_case_color,
        show_front_panel=show_front_panel,
        show_ultrasonic=show_ultrasonic,
        show_front_rear_panel=show_front_rear_panel,
        show_head_assembly=show_head_assembly,
        show_head=show_head,
        show_pan_servo=show_pan_servo,
        show_tilt_servo=show_tilt_servo,
        show_ir_case=show_ir_case,
        show_camera=show_camera,
        show_ir_led=show_ir_led,
        show_steering_panel=show_steering_panel,
        show_rear_wheels=show_rear_wheels,
        show_bearing=show_bearing,
        show_servo_mount_panel=show_servo_mount_panel,
        show_brackets=show_brackets,
        show_rack=show_rack,
        show_kingpin_posts=show_kingpin_posts,
        show_pinion=show_pinion,
        show_tie_rod=show_tie_rod,
        show_servo=show_servo,
        show_knuckles=show_knuckles,
        tilt_servo_rotation=tilt_servo_rotation,
        pan_servo_rotation=pan_servo_rotation,
        show_ackermann_triangle=show_ackermann_triangle,
        show_distance=show_distance,
        show_motor=show_motor,
        show_motor_brackets=show_motor_brackets,
        show_buttons_panel=show_buttons_panel,
        show_fuse_panel=show_fuse_panel,
        show_buttons=show_buttons,
        show_fuses=show_fuses,
        show_rear_panel_buttons=show_rear_panel_buttons,
        show_rear_panel=show_rear_panel,
        show_battery_holders=show_battery_holders,
        show_ups_hat=show_ups_hat,
        show_power_case=show_power_case,
        show_power_case_lid=show_power_case_lid,
        show_lipo_pack=show_lipo_pack,
        show_rpi=show_rpi,
        show_ai_hat=show_ai_hat,
        show_motor_driver_hat=show_motor_driver_hat,
        show_servo_driver_hat=show_servo_driver_hat,
        show_gpio_expansion_board=show_gpio_expansion_board,
        show_lid_dc_regulator=show_power_lid_dc_regulator,
        show_lid_voltmeter=show_power_lid_voltmeter,
        show_lid_atm_fuse_holders=show_power_lid_atm_fuse_holders,
        show_lid_ato_fuse=show_power_lid_ato_fuse,
        show_lid_perf_board=show_power_lid_perf_board,
        show_socket_case=show_socket_case,
        show_xt90e=show_power_lid_case_xt90e,
        show_socket=show_socket,
        show_socket_case_lid=show_socket_case_lid,
        show_socket_case_fuses=show_socket_case_fuses,
        show_chassis_body=show_chassis_body,
        show_front_wheels=show_front_wheels,
        show_upper_chassis=show_upper_chassis_body,
        show_knuckle_bolts=show_knuckle_bolts,
        show_bolts_info=show_bolts_info,
        override_battery_holders_plists=true,
        show_kingpin_bolt=show_kingpin_bolt,
        show_hinges_bolts=show_hinges_bolts,
        show_panel_bolt=show_panel_bolt,
        fasten_kingpin_bolt=fasten_kingpin_bolt,
        fasten_hinges_bolts=fasten_hinges_bolts,
        fasten_panel_bolt=fasten_panel_bolt,
        show_batteries=show_batteries);
