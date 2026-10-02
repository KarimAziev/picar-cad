/**
  * Module: Inspect rigid front suspension and wheel tie-rod closure.
  *
  * Positive arm angle lowers the wheels; the knuckles and rods follow their
  * actual joints. Angles are prescribed, not calculated from spring forces.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>
use <../../lib/plist.scad>
use <../front_linkage.scad>
use <../front_suspension_assembly.scad>
use <../bellcrank_steering_assembly.scad>

lower_arm_angle = 10; // [-15:1:25]
bellcrank_angle = 0; // [-15:1:15]
steering_hole = 0; // [0,1]
solve_linkage = true;
show_suspension = true;
show_joint_centers = false;

translate([0, bellcrank_y_distance_from_bulkhead, 0]) {
  front_suspension_assembly(solve_linkage=solve_linkage,
                            lower_arm_angle=lower_arm_angle,
                            bellcrank_angle=bellcrank_angle,
                            steering_hole=steering_hole,
                            show_front_bulkhead=show_suspension,
                            show_front_bulkhead_housing=show_suspension);
  if (solve_linkage) {
    for (side = [-1, 1]) {
      p = front_linkage_pose(lower_arm_angle, bellcrank_angle, side, steering_hole);
      echo(side=side, lower_arm_angle=lower_arm_angle,
           heading=plist_get("heading", p),
           rod_length=norm(plist_get("rod_b", p) - plist_get("rod_a", p)),
           lower_ball=plist_get("lower_ball", p));
      if (show_joint_centers) {
        scale([side, 1, 1]) {
          for (key = ["lower_ball", "upper_ball", "rod_a", "rod_b"]) {
            color("orange") {
              translate(plist_get(key, p)) {
                sphere(d=2, $fn=24);
              }
            }
          }
        }
      }
    }
  }
}
bellcrank_steering_assembly(steering_servo_angle=bellcrank_angle,
                           show_steering_servo=false,
                           show_steering_servo_brackets=false,
                           show_steering_servo_encoder=false,
                           show_steering_servo_encoder_bracket=false,
                           show_steering_servo_magnet=false);
