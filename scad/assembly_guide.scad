/**
 * Module: Assembly guide. Toggle the variables one by one to see the assembly steps
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <colors.scad>
include <parameters.scad>

use <components/chassis/chassis.scad>

/* [Power Case] */
show_socket_case                  = true;
// Insert the socket jack for the XT90E-M male connector and fasten it with bolts.
show_socket                       = false;
// Connect the XT90E-M male connector to the fuse holders.
show_socket_case_fusers           = false;

// Slide the socket case lid into place.
show_socket_case_lid              = false;

// Now mount the power case onto the socket-case lid.
show_power_case                   = false;
// Insert the bolts.
show_power_case_bottom_bolts      = false;
// Show the required bolt length and diameter.
show_power_case_bottom_bolts_info = false;
// Tighten the bolts.
power_case_bottom_bolts_down      = false;

// From the bottom, fasten the bolts to the standoffs.
show_power_case_show_standoffs    = false;
// Attach your Turnigy Rapid (or other LiPo) pack.
show_lipo_pack                    = false;

// Uncheck the previous variables to see only the power-lid assembly.
show_power_case_lid               = false;
// Connect your step-down voltage regulator.
show_power_lid_dc_regulator       = false;
// Connect the step-down voltage regulator to the fuse holders.
show_power_lid_atm_fuse_holders   = false;
// Connect your voltmeters.
show_power_lid_voltmeter          = false;
// Connect your perfboard, if any.
show_power_lid_perf_board         = false;

// Fasten everything with bolts.
show_lid_bolts                    = false;

// Connect your custom slots, if any.
// Show if defined in power_lid_left_slots or power_lid_right_slots.
show_power_lid_ato_fuse           = false;
// Show XT90E if defined in power_lid_left_slots or power_lid_right_slots.
show_power_lid_case_xt90e         = false;
// Show if defined in power_lid_left_slots or power_lid_right_slots.

/* [Head] */
show_head_assembly                = false;
show_tilt_servo                   = false;
show_pan_servo                    = false;
show_head                         = false;
show_camera                       = false;
show_ir_case                      = false;
show_ir_led                       = false;

pan_servo_rotation                = 0; // [-179:179]
tilt_servo_rotation               = 0; // [-90:90]

/* [Chassis] */
show_upper_chassis_body           = false;
show_chassis_body                 = false;

/* [Batteries] */
show_battery_holders              = false;
show_battery_holders_bolts        = false;
show_battery_holders_nuts         = false;
show_batteries                    = false;

/* [Motors] */
show_motor_brackets               = false;
show_motor                        = false;

/* [Buttons Fusers Stack] */
show_fuse_panel                   = false;
show_fusers                       = false;
show_buttons_panel                = false;
show_buttons                      = false;

/* [Steering Panel] */
show_steering_panel               = false;
show_rack                         = false;
show_kingpin_posts                = false;
show_servo_mount_panel            = false;
show_servo                        = false;
show_pinion                       = false;
show_knuckles                     = false;
show_bearing                      = true;
show_brackets                     = false;
show_tie_rod                      = false;

/* [Raspberry PI] */
show_rpi                          = false;
show_ai_hat                       = false;
show_motor_driver_hat             = false;
show_servo_driver_hat             = false;
show_gpio_expansion_board         = false;

/* [Front Panel] */
show_front_panel                  = false;
show_ultrasonic                   = false;
show_front_rear_panel             = false;

/* [Wheels] */
show_front_wheels                 = false;
show_rear_wheels                  = false;

/* [Colors] */
panel_color                       = "white";
pinion_color                      = "white";
power_case_color                  = panel_color;

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
        show_fusers=show_fusers,
        show_rear_panel_buttons=false,
        show_rear_panel=false,
        show_battery_holders=show_battery_holders,
        show_ups_hat=false,
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
        show_socket_case_fusers=show_socket_case_fusers,
        show_battery_holders_bolts=show_battery_holders_bolts,
        show_battery_holders_nuts=show_battery_holders_nuts,
        show_batteries=show_batteries,
        show_power_case=show_power_case,
        show_power_case_bottom_bolts=show_power_case_bottom_bolts,
        show_power_case_bottom_bolts_info=show_power_case_bottom_bolts_info,
        power_case_bottom_bolts_down=power_case_bottom_bolts_down,
        show_power_case_show_standoffs=show_power_case_show_standoffs,
        override_battery_holders_plists=true,
        show_chassis_body=show_chassis_body,
        show_front_wheels=show_front_wheels,
        show_upper_chassis=show_upper_chassis_body);