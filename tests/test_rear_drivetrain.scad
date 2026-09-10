include <../scad/suspension/rear_chassis/computed_params.scad>
use <../scad/lib/plist.scad>
use <../scad/placeholders/rc_gearmotor.scad>
use <../scad/placeholders/rc_driveshaft.scad>

motor_size = rc_gearmotor_size();
assert(motor_size == [41.97, 55.62, 31.34]);
assert(plist_get("can_d", rc_gearmotor_plist) == 24.31);
assert(plist_get("gearbox_l", rc_gearmotor_plist) == 17.68);
assert(plist_get("tube_d", rc_driveshaft_plist) == 8);
assert(plist_get("bore_d", rc_driveshaft_plist) == 4);
assert(plist_get("yoke_l", rc_driveshaft_plist) + rc_driveshaft_hub_l()
       == plist_get("socket_l", rc_driveshaft_plist));
assert(rc_gearmotor_axis_x(output=false) - rc_gearmotor_axis_x()
       > (plist_get("can_d", rc_gearmotor_plist)
          + plist_get("bearing_d", rc_gearmotor_plist)) / 2);

module check_layout(motor_spec=rc_gearmotor_plist, shaft_spec=rc_driveshaft_plist) {
  layout = rear_chassis_layout(motor_spec, shaft_spec);
  start = plist_get("shaft_start", layout);
  end = plist_get("shaft_end", layout);
  assert(abs(end[2] - front_chassis_thickness - rear_chassis_diff_input_h) < 0.00001);
  suspension = rear_suspension_layout();
  assert(abs(plist_get("suspension_y", layout) - plist_get("maintenance_y", suspension)
             - plist_get("dogbone_tip", layout)[1]) < 0.00001);
  assert(plist_get("rail_end_y", layout) > plist_get("suspension_front_y", layout));
  pos = plist_get("motor_pos", layout);
  tip = rc_gearmotor_shaft_tip(motor_spec);
  body = rc_gearmotor_size(motor_spec);
  clocked_tip = [tip[2] - body[2] / 2, tip[1], body[0] / 2 - tip[0]] + pos;
  hub_reach = plist_get("socket_l", shaft_spec);
  engagement = rc_driveshaft_hub_l(shaft_spec) / 2;
  assert(abs(norm(end - start) - plist_get("pivot_l", shaft_spec)) < 0.00001);
  assert(start[0] == clocked_tip[0] && start[2] == clocked_tip[2]);
  assert(abs(start[1] + hub_reach - engagement - clocked_tip[1]) < 0.00001);
  assert(rc_driveshaft_joint_angle(end - start, [0, -1, 0])
         < plist_get("max_angle", shaft_spec));
  assert(plist_get("ladder_w", layout) - rear_chassis_rail_w * 2
         >= rear_chassis_diff_size[0] + rear_chassis_clearance * 2);
  for (y = plist_get("bolt_ys", layout)) {
    assert(y + rear_chassis_mount_bolt_d / 2 < plist_get("straight_y", layout));
    assert(y - rear_chassis_mount_bolt_d / 2 > plist_get("rear_y", layout));
  }
  assert(end[2] - plist_get("joint_d", shaft_spec) / 2 > front_chassis_thickness);
  assert(-plist_get("shoulder_y", layout) - joint_l
         >= (front_chassis_joint_pin_l - joint_l) / 2 + rear_chassis_mount_land);
}

check_layout();
check_layout(plist_put("body_l", 65, rc_gearmotor_plist));
check_layout(shaft_spec=plist_put("pivot_l", 70, rc_driveshaft_plist));
check_layout(shaft_spec=plist_put("socket_l", 15, rc_driveshaft_plist));
assert(rc_driveshaft_joint_angle([0, -1, 0], [0, 1, 0]) == 0);
assert(abs(rc_driveshaft_joint_angle([0, -1, -1], [0, -1, 0]) - 45) < 0.00001);
echo("PASS: rear drivetrain envelopes, shaft engagement and shared mount datums");
