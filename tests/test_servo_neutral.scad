/**
  * Module: Servo neutral trim and chassis mounting datum assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/suspension/front_chassis/layout_params.scad>

use <../scad/lib/functions.scad>
use <../scad/lib/plist.scad>
use <../scad/placeholders/dservo.scad>
use <../scad/suspension/chassis_dimensions.scad>
use <../scad/suspension/computed.scad>
use <../scad/suspension/rear_chassis/computed_params.scad>
use <../scad/suspension/steering_characterization/datums.scad>

module near(a, b, tolerance=1e-8) {
  error = is_list(a) ? norm(a - b) : abs(a - b);
  assert(error < tolerance, str(a, " != ", b));
}

near(dsservo_gearbox_d1, 18.55);
near(bellcrank_params, [-9.85, -20.289391240237933, -74.78939124023793]);
near(joint_l, 14.039391240237933);
near(servo_end_y, -102.28939124023793);
near(y_front_chassis_rear_frame_main_start, -47.78939124023793);
near(steering_servo_bellcrank_y(center=true),
     bellcrank_params[1] + dsservo_size[0] / 2);

layout = rear_chassis_layout(min_width=suspension_chassis_width());
dimensions = chassis_dimensions(layout=layout);
near(plist_get("chassis_length", dimensions), 398.921, 0.001);
near(plist_get("wheelbase", dimensions), 263.966, 0.001);
near(plist_get("chassis_width", dimensions), 152.26);

origin = steering_servo_tie_rod_origin();
rod_l = steering_servo_tie_rod_length();
near(rod_l, 59.18);
for (lever_z = [28, 30.2, 34]) {
  upright = steering_servo_neutral_pose(lever_z, offset=0);
  near(upright[0], 0);
  near(upright[2], origin);
  for (offset = [-0.9, 0, 0.9, 2]) {
    pose = steering_servo_neutral_pose(lever_z, offset=offset);
    near(norm(pose[3] - pose[2]), rod_l);
    near(pose[2], rotate_euler_xyz(origin, [0, 0, pose[0]]));
    near(pose[3],
         pose[2] + rotate_euler_xyz([-rod_l, 0, 0],
                                    [0, 0, pose[1]]));
    near(pose[3] - upright[3], [offset, 0, 0]);
  }
}

pose = steering_servo_neutral_pose();
near(pose[0], -2.121086, 0.000001);
near(pose[1], 1.301616, 0.000001);
audit = steering_audit_datums();
near(plist_get("servo_rod_b", audit), [-46.85, 0.05, 32.965879265091864]);
near(plist_get("servo_axis", audit), [-50.35, -58.26439124023793, 10]);
echo("PASS: neutral servo trim, rigid rod closure and fixed chassis datums");
