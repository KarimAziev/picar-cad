
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
pinion_color             = matte_black;
power_case_color         = "grey";
show_front_panel         = true;
show_ultrasonic          = true;
show_front_rear_panel    = true;
show_head_assembly       = true;
show_head                = true;
show_pan_servo           = true;
show_tilt_servo          = true;
show_ir_case             = true;
show_camera              = true;
show_ir_led              = true;
show_steering_panel      = true;
show_wheels              = true;
show_bearing             = true;
show_servo_mount_panel   = true;
show_brackets            = true;
show_rack                = true;
show_kingpin_posts       = true;
show_pinion              = true;
show_tie_rod             = true;
show_servo               = true;
show_knuckles            = true;
tilt_servo_rotation      = 0;
show_ackermann_triangle  = false;
show_distance            = false;
show_motor               = true;
show_motor_brackets      = true;
show_buttons_panel       = true;
show_fuse_panel          = true;
show_buttons             = true;
show_fusers              = true;
show_rear_panel_buttons  = false;
show_rear_panel          = false;
show_battery_holders     = true;
show_smd_battery_holders = true;
show_ups_hat             = false;
show_power_case          = true;
show_power_case_lid      = true;
show_lipo_pack           = true;
show_batteries           = true;
show_rpi                 = true;

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
        show_wheels=show_wheels,
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