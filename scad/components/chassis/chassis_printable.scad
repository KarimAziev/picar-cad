/**
 * A robot chassis (printable)
 *
 * It can be printed either split into a body and an upper part and then fastened with a connector, or as a single part.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../parameters.scad>
include <../../colors.scad>
use <chassis_body.scad>
use <upper_chassis.scad>

panel_color   = "white";
use_connector = chassis_use_connector;

module chassis_printable(panel_color=panel_color,
                         chassis_use_connector=use_connector) {
  union() {
    translate([0, (chassis_use_connector ? chassis_connector_len + 4 : 0), 0]) {
      chassis_upper(panel_color=panel_color,
                    show_front_panel=false,
                    show_ultrasonic=false,
                    show_front_rear_panel=false,
                    show_head_assembly=false,
                    show_head=false,
                    show_pan_servo=false,
                    show_tilt_servo=false,
                    show_ir_case=false,
                    show_camera=false,
                    show_ir_led=false,
                    show_steering_panel=false,
                    show_wheels=false,
                    show_bearing=false,
                    show_servo_mount_panel=false,
                    show_brackets=false,
                    show_rack=false,
                    show_kingpin_posts=false,
                    show_pinion=false,
                    show_tie_rod=false,
                    show_servo=false,
                    show_knuckles=false,
                    tilt_servo_rotation=false,
                    show_distance=false);
    }
    chassis_body(motor_type=motor_type,
                 show_motor=false,
                 show_wheels=false,
                 show_motor_brackets=false,
                 show_rear_panel=false,
                 show_buttons_panel=false,
                 show_fuse_panel=false,
                 show_buttons=false,
                 show_fusers=false,
                 show_rear_panel_buttons=false,
                 show_battery_holders=false,
                 show_ups_hat=false,
                 show_power_case=false,
                 show_power_case_lid=false,
                 show_lipo_pack=false,
                 show_batteries=false,
                 show_rpi=false);
  }
}

chassis_printable();