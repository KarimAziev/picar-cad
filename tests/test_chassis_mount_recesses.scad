/**
  * Module: Chassis mounting-plane and fixed vehicle datum assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/suspension/rear_chassis/computed_params.scad>
use <../scad/suspension/front_chassis/head_frame/head_joint.scad>

layout = rear_chassis_layout();
joint_y = rear_suspension_joint_y_bounds(layout);
assert(suspension_chassis_mount_recess == 2);
assert(suspension_chassis_mount_h == 4);
assert(gearbox_bracket_thickness == 6.5);
assert(suspension_chassis_mount_h - front_bulkhead_mount_bolt_bore_h >= 1.5);
assert(suspension_chassis_mount_h - front_chassis_bellcrank_bolt_bore_h >= 1.5);
assert(suspension_chassis_mount_h - steering_servo_mount_bolt_bore_h >= 1.5);
assert(suspension_chassis_mount_h - rear_suspension_chassis_bolt_bore_h >= 1.5);
// Independent native-coordinate references protect the chassis length and wheelbase.
assert(abs(plist_get("min_y", layout) + 147.74) < 0.000001);
assert(abs(plist_get("max_y", layout) - 5.75) < 0.000001);
assert(abs(plist_get("maintenance_y", layout) + 60.69) < 0.000001);
assert(norm(plist_get("motor_pos", layout) - [0, -106.89, 0]) < 0.000001);
assert(joint_y[0] - plist_get("motor_bounds", layout)[1][1] >= 3);
assert(rear_suspension_mount_recess_end_y(layout)
       - ((joint_y[0] + joint_y[1]) / 2 + rear_suspension_joint_pin_l / 2)
       >= 1);
assert(plist_get("pin_start_y", front_chassis_head_joint_params())
       - front_chassis_mount_end_y >= front_chassis_head_wire_land);
echo("PASS: 2 mm mounting recess, screw floors, fixed chassis/motor datums and joint keepouts");
