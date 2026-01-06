
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

panel_color                     = "white";

/* [Head] */
show_head_assembly              = true;
show_head                       = true;
show_pan_servo                  = true;
show_tilt_servo                 = true;
show_ir_case                    = true;
show_camera                     = true;
show_ir_led                     = true;
head_color                      = panel_color;
head_panel_color                = matte_black;
pan_servo_rotation              = 0; // [-179:179]
tilt_servo_rotation             = 0; // [-90:90]

/* [Front Panel] */
show_front_panel                = true;
show_ultrasonic                 = true;
show_front_rear_panel           = true;

/* [Steering Panel] */
show_steering_panel             = true;
show_bearing                    = true;
show_servo_mount_panel          = true;
show_brackets                   = true;
show_rack                       = true;
show_kingpin_posts              = true;
show_pinion                     = true;
show_tie_rod                    = true;
show_servo                      = true;
show_knuckles                   = true;
pinion_color                    = matte_black;
show_front_wheels               = true;

/* [Buttons Fusers Stack] */
show_buttons_panel              = true;
show_fuse_panel                 = true;
show_buttons                    = true;
show_fusers                     = true;

/* [Motors] */
show_motor                      = true;
show_motor_brackets             = true;
show_rear_wheels                = true;

/* [Rear Panel] */
show_rear_panel_buttons         = false;
show_rear_panel                 = false;

/* [Power Case] */
show_power_case                 = true;
show_lipo_pack                  = true;
power_case_color                = panel_color;

show_power_case_lid             = true;
show_power_lid_dc_regulator     = true;
show_power_lid_voltmeter        = true;
show_power_lid_atm_fuse_holders = true;
show_power_lid_ato_fuse         = true;
show_power_lid_perf_board       = true;
show_power_lid_case_xt90e       = true;

show_socket_case                = true;
show_socket                     = true;
show_socket_case_lid            = true;
show_socket_case_fusers         = true;

/* [Batteries] */
show_battery_holders            = true;

show_ups_hat                    = false;

/* [Raspberry PI] */
show_rpi                        = true;
show_ai_hat                     = true;
show_motor_driver_hat           = true;
show_servo_driver_hat           = true;
show_gpio_expansion_board       = true;

/* [Debug] */
show_ackermann_triangle         = false;
show_distance                   = false;

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
        show_socket_case_fusers=show_socket_case_fusers);