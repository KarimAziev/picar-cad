/**
  * Module: Front chassis dimensions with a shared vehicle body width.
  */
include <layout_params.scad>

use <../../lib/plist.scad>
use <../rear_chassis/computed_params.scad>

front_chassis_rear_frame_w     = plist_get("join_w", rear_chassis_layout());

chassis_joint_wide_w           = front_chassis_rear_frame_w;
chassis_joint_wide_rail_w      = chassis_joint_wide_w
                                  - (front_chassis_joint_bolt_d
                                  + front_chassis_joint_bolt_pad) * 2;
chassis_joint_wide_bolt_edge_x = chassis_joint_wide_w / 2
                                  - front_chassis_joint_bolt_pad
                                  - front_chassis_joint_bolt_d / 2;
chassis_joint_wide_bolt_step   = chassis_joint_wide_bolt_edge_x * 2
                                  / (suspension_chassis_joint_wide_bolt_cols - 1);
chassis_joint_wide_bolt_xs     = [for (i = [0 : suspension_chassis_joint_wide_bolt_cols - 1])
                                  -chassis_joint_wide_bolt_edge_x
                                  + i * chassis_joint_wide_bolt_step];
chassis_joint_wide_pin_spacing = chassis_joint_wide_rail_w / 2;

rpi_y_end                      = front_rpi_bounds[0][1];
front_chassis_y_joint_2_end    = min(servo_end_y, rpi_y_end) - joint_l;
