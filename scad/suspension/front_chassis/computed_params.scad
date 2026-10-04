/**
  * Module: Front chassis dimensions with a shared vehicle body width.
  */
include <layout_params.scad>

use <../../lib/plist.scad>
use <../rear_chassis/computed_params.scad>
use <front_chassis_joint.scad>

front_chassis_rear_frame_w     = plist_get("join_w", rear_chassis_layout());

chassis_joint_wide_w           = front_chassis_rear_frame_w;
chassis_joint_wide_rail_w      = front_chassis_body_joint_rail_w(chassis_joint_wide_w);
chassis_joint_wide_bolt_xs     = front_chassis_body_joint_bolt_xs(chassis_joint_wide_w);
chassis_joint_wide_pin_spacing = front_chassis_body_joint_pin_spacing(chassis_joint_wide_w);

rpi_y_end                      = front_rpi_bounds[0][1];
front_chassis_y_joint_2_end    = min(servo_end_y, rpi_y_end) - joint_l;
