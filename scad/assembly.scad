
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

panel_color              = "white";

/* [Head] */
show_head_assembly       = false;
show_head                = false;
show_pan_servo           = false;
show_tilt_servo          = false;
show_ir_case             = false;
show_camera              = false;
show_ir_led              = false;
head_color               = panel_color;
head_panel_color         = matte_black;
pan_servo_rotation       = 0; // [-179:179]
tilt_servo_rotation      = 0; // [-90:90]

/* [Front Panel] */
show_front_panel         = false;
show_ultrasonic          = false;
show_front_rear_panel    = false;

/* [Steering Panel] */
show_steering_panel      = false;
show_bearing             = false;
show_servo_mount_panel   = false;
show_brackets            = false;
show_rack                = false;
show_kingpin_posts       = false;
show_pinion              = false;
show_tie_rod             = false;
show_servo               = false;
show_knuckles            = false;
pinion_color             = matte_black;
show_front_wheels        = false;

/* [Buttons Fusers Stack] */
show_buttons_panel       = false;
show_fuse_panel          = false;
show_buttons             = false;
show_fusers              = false;

/* [Motors] */
show_motor               = false;
show_motor_brackets      = false;
show_rear_wheels         = false;

/* [Rear Panel] */
show_rear_panel_buttons  = false;
show_rear_panel          = false;

/* [Power Case] */
show_power_case          = false;
show_power_case_lid      = false;
show_lipo_pack           = false;
power_case_color         = "grey";

/* [Batteries] */
show_smd_battery_holders = false;
show_battery_holders     = false;
show_batteries           = false;

show_ups_hat             = false;

/* [Raspberry PI] */
show_rpi                 = false;

/* [Debug] */
show_ackermann_triangle  = false;
show_distance            = false;

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
        show_smd_battery_holders=show_smd_battery_holders,
        show_ups_hat=show_ups_hat,
        show_power_case=show_power_case,
        show_power_case_lid=show_power_case_lid,
        show_lipo_pack=show_lipo_pack,
        show_batteries=show_batteries,
        show_rpi=show_rpi);