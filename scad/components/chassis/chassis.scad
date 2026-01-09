/**
 * A robot chassis
 *
 * This module defines a robot chassis designed for a four-wheeled vehicle.
 * The front wheels are controlled by servo steering while the rear wheels are powered by two separate motors.
 * It can be printed either with a connector or without, as one body.
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../parameters.scad>

use <../../steering_system/ackermann_geometry_triangle.scad>
use <chassis_body.scad>
use <upper_chassis.scad>

pan_servo_rotation                = 0; // [-179:179]
tilt_servo_rotation               = 0; // [-90:90]

panel_color                       = "white";
pinion_color                      = matte_black;
power_case_color                  = panel_color;
show_front_panel                  = true;
show_ultrasonic                   = true;
show_front_rear_panel             = true;
show_head_assembly                = true;
show_head                         = true;
show_pan_servo                    = true;
show_tilt_servo                   = true;
show_ir_case                      = true;
show_camera                       = true;
show_ir_led                       = true;
show_steering_panel               = true;
show_rear_wheels                  = true;
show_front_wheels                 = true;
show_bearing                      = true;
show_servo_mount_panel            = true;
show_brackets                     = true;
show_rack                         = true;
show_kingpin_posts                = true;
show_pinion                       = true;
show_tie_rod                      = true;
show_servo                        = true;
show_knuckles                     = true;
show_ackermann_triangle           = false;
show_distance                     = false;
show_motor                        = true;
show_motor_brackets               = true;
show_buttons_panel                = true;
show_fuse_panel                   = true;
show_buttons                      = true;
show_fuses                        = true;
show_rear_panel_buttons           = false;
show_rear_panel                   = false;
show_battery_holders              = true;
override_battery_holders_plists   = false;
show_ups_hat                      = false;
show_power_case                   = true;
show_lipo_pack                    = true;
show_power_case_lid               = true;
show_lid_dc_regulator             = true;
show_lid_ato_fuse                 = true;
show_lid_voltmeter                = true;
show_lid_atm_fuse_holders         = true;
show_lid_perf_board               = true;
show_socket_case                  = true;
show_socket                       = true;
show_socket_case_lid              = true;
show_socket_case_fuses            = true;
show_xt90e                        = true;
show_rpi                          = true;
show_ai_hat                       = true;
show_motor_driver_hat             = true;
show_servo_driver_hat             = true;
show_gpio_expansion_board         = true;
show_power_case_bottom_bolts      = false;

show_knuckle_bolts                = false;

show_bolts_info                   = false;
show_kingpin_bolt                 = false;
show_hinges_bolts                 = false;
show_panel_bolt                   = false;

fasten_kingpin_bolt               = false;
fasten_hinges_bolts               = false;
fasten_panel_bolt                 = false;

show_power_case_bottom_bolts_info = false;

power_case_bottom_bolts_down      = true;
show_power_case_show_standoffs    = true;

module chassis(tilt_servo_rotation=tilt_servo_rotation,
               pan_servo_rotation=pan_servo_rotation,
               panel_color=panel_color,
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
               show_front_wheels=show_front_wheels,
               show_bearing=show_bearing,
               show_servo_mount_panel=show_servo_mount_panel,
               show_brackets=show_brackets,
               show_rack=show_rack,
               show_kingpin_posts=show_kingpin_posts,
               show_pinion=show_pinion,
               show_tie_rod=show_tie_rod,
               show_servo=show_servo,
               show_knuckles=show_knuckles,
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
               show_lipo_pack=show_lipo_pack,
               show_power_case_lid=show_power_case_lid,
               show_lid_dc_regulator=show_lid_dc_regulator,
               show_lid_ato_fuse=show_lid_ato_fuse,
               show_lid_voltmeter=show_lid_voltmeter,
               show_lid_atm_fuse_holders=show_lid_atm_fuse_holders,
               show_lid_perf_board=show_lid_perf_board,
               show_socket_case=show_socket_case,
               show_socket=show_socket,
               show_socket_case_lid=show_socket_case_lid,
               show_socket_case_fuses=show_socket_case_fuses,
               show_xt90e=show_xt90e,
               show_rpi=show_rpi,
               show_ai_hat=show_ai_hat,
               show_motor_driver_hat=show_motor_driver_hat,
               show_servo_driver_hat=show_servo_driver_hat,
               show_gpio_expansion_board=show_gpio_expansion_board,
               override_battery_holders_plists,
               show_batteries,
               show_battery_holders_bolts,
               show_battery_holders_nuts,
               show_socket_case_lid=show_socket_case_lid,
               show_power_case=show_power_case,
               show_power_case_bottom_bolts=show_power_case_bottom_bolts,
               show_power_case_bottom_bolts_info=show_power_case_bottom_bolts_info,
               power_case_bottom_bolts_down=power_case_bottom_bolts_down,
               show_power_case_show_standoffs=show_power_case_show_standoffs,
               show_knuckle_bolts=show_knuckle_bolts,
               show_bolts_info=show_bolts_info,
               show_kingpin_bolt=show_kingpin_bolt,
               show_hinges_bolts=show_hinges_bolts,
               show_panel_bolt=show_panel_bolt,
               fasten_kingpin_bolt=fasten_kingpin_bolt,
               fasten_hinges_bolts=fasten_hinges_bolts,
               fasten_panel_bolt=fasten_panel_bolt,
               show_upper_chassis=true,
               show_chassis_body=true) {

  union() {
    chassis_upper(panel_color=panel_color,
                  show_front_panel=show_front_panel,
                  show_ultrasonic=show_ultrasonic,
                  show_front_rear_panel=show_front_rear_panel,
                  show_head_assembly=show_head_assembly
                  || show_head || show_pan_servo || show_camera || show_ir_led,
                  show_head=show_head,
                  show_pan_servo=show_pan_servo,
                  show_tilt_servo=show_tilt_servo,
                  show_ir_case=show_ir_case,
                  show_camera=show_camera,
                  show_ir_led=show_ir_led,
                  show_steering_panel=show_steering_panel,
                  pinion_color=pinion_color,
                  show_wheels=show_front_wheels,
                  show_bearing=show_bearing,
                  show_servo_mount_panel=show_servo_mount_panel,
                  show_brackets=show_brackets,
                  show_rack=show_rack,
                  show_kingpin_posts=show_kingpin_posts,
                  show_pinion=show_pinion,
                  show_tie_rod=show_tie_rod,
                  show_servo=show_servo,
                  show_knuckles=show_knuckles,
                  pan_servo_rotation=pan_servo_rotation,
                  tilt_servo_rotation=tilt_servo_rotation,
                  show_distance=show_distance,
                  show_upper_chassis=show_upper_chassis,
                  show_knuckle_bolts=show_knuckle_bolts,
                  show_bolts_info=show_bolts_info,
                  show_kingpin_bolt=show_kingpin_bolt,
                  show_hinges_bolts=show_hinges_bolts,
                  show_panel_bolt=show_panel_bolt,
                  fasten_kingpin_bolt=fasten_kingpin_bolt,
                  fasten_hinges_bolts=fasten_hinges_bolts,
                  fasten_panel_bolt=fasten_panel_bolt);

    chassis_body(motor_type=motor_type,
                 show_motor=show_motor,
                 show_xt90e=show_xt90e,
                 show_wheels=show_rear_wheels,
                 show_motor_brackets=show_motor_brackets,
                 show_rear_panel=show_rear_panel,
                 show_buttons_panel=show_buttons_panel,
                 show_fuse_panel=show_fuse_panel,
                 show_buttons=show_buttons,
                 show_fuses=show_fuses,
                 show_rear_panel_buttons=show_rear_panel_buttons,
                 show_battery_holders=show_battery_holders,
                 show_ups_hat=show_ups_hat,
                 show_power_case=show_power_case,
                 show_power_case_lid=show_power_case_lid,
                 show_lipo_pack=show_lipo_pack,
                 power_case_color=power_case_color,
                 show_socket_case_lid=show_socket_case_lid,
                 show_socket_case_atm_fuse_holders=show_socket_case_fuses,
                 show_socket=show_socket,
                 show_rpi=show_rpi,
                 show_socket_case=show_socket_case,
                 show_ai_hat=show_ai_hat,
                 show_motor_driver_hat=show_motor_driver_hat,
                 show_servo_driver_hat=show_servo_driver_hat,
                 show_gpio_expansion_board=show_gpio_expansion_board,
                 show_lid_dc_regulator=show_lid_dc_regulator,
                 show_lid_ato_fuse=show_lid_ato_fuse,
                 show_lid_voltmeter=show_lid_voltmeter,
                 show_lid_atm_fuse_holders=show_lid_atm_fuse_holders,
                 show_lid_perf_board=show_lid_perf_board,
                 override_battery_holders_plists=override_battery_holders_plists,
                 show_batteries=show_batteries,
                 show_battery_holders_bolts=show_battery_holders_bolts,
                 show_battery_holders_nuts=show_battery_holders_nuts,
                 show_power_case_bottom_bolts=show_power_case_bottom_bolts,
                 show_power_case_bottom_bolts_info=show_power_case_bottom_bolts_info,
                 power_case_bottom_bolts_down=power_case_bottom_bolts_down,
                 show_power_case_show_standoffs=show_power_case_show_standoffs,
                 show_chassis_body=show_chassis_body);
  }
  if (show_ackermann_triangle) {
    translate([0,
               chassis_transition_len
               + chassis_upper_len
               - steering_panel_distance_from_top
               - steering_rack_support_width / 2,
               0]) {
      ackermann_geometry_triangle();
    }
  }
}

chassis();
