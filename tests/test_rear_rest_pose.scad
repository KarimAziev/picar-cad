/**
  * Module: Upright rear suspension rest-pose assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/rc_params.scad>
include <../scad/suspension/rear_axle/arm_hub_params.scad>
include <../scad/suspension/rear_axle/hardware_params.scad>
include <../scad/suspension/rear_axle/structure_params.scad>

use <../scad/lib/plist.scad>
use <../scad/placeholders/hsp_rear_drivetrain.scad>
use <../scad/suspension/rc_wheels.scad>
use <../scad/suspension/rear_axle/rear_axle_assembly.scad>
use <../scad/suspension/rear_axle/rear_bulkhead.scad>
use <../scad/suspension/rear_axle/rear_camber_link.scad>
use <../scad/suspension/rear_axle/rear_hub.scad>
use <../scad/suspension/rear_axle/rear_lower_arm.scad>
use <../scad/suspension/rear_suspension_assembly.scad>

epsilon  = 0.000001;
target_z = rc_rear_level_wheel_center_z();
assert(plist_get("wheel_center_z", rear_axle_settings) == target_z);
assert(plist_get("hub_camber_angle", rear_axle_settings) == 0);

for (height_offset = [-3, 0, 3]) {
  settings = plist_put("wheel_center_z",
                       target_z + height_offset,
                       rear_axle_settings);
  pose = rear_axle_rest_pose(settings,
                             rear_housing_spec,
                             rear_lower_arm_spec,
                             rear_hub_spec);
  inner = rear_lower_arm_inner_pivot(rear_lower_arm_spec);
  outer = rear_lower_arm_outer_pivot(rear_lower_arm_spec);
  hinge = rear_bulkhead_hinge_axis(rear_housing_spec, rear_lower_arm_spec);
  ball = rear_axle_arm_point(outer,
                             settings,
                             rear_housing_spec,
                             rear_lower_arm_spec,
                             rear_hub_spec);
  assert(norm(rear_axle_arm_point(inner, settings, rear_housing_spec,
                                  rear_lower_arm_spec, rear_hub_spec) - hinge)
         < epsilon,
         "The inner hinge must stay fixed through pose changes");
  assert(abs(norm(ball - hinge) - norm(outer - inner)) < epsilon,
         "The lower arm must remain rigid");
  hub_origin = rear_axle_hub_origin(rear_housing_spec,
                                    rear_lower_arm_spec,
                                    rear_hub_spec,
                                    settings);
  arm_balls = rear_lower_arm_ball_positions(rear_lower_arm_spec);
  hub_balls = rear_hub_ball_positions(rear_hub_spec);
  for (i = [0, 1]) {
    placed_ball = rear_axle_arm_point(arm_balls[i],
                                      settings,
                                      rear_housing_spec,
                                      rear_lower_arm_spec,
                                      rear_hub_spec);
    assert(norm(placed_ball - hub_origin - hub_balls[i]) < epsilon,
           "Both lower ball centers must close on their hub sockets");
  }
  wheel_origin = rear_suspension_wheel_origin(rear_housing_spec,
                                              rear_lower_arm_spec,
                                              rear_hub_spec,
                                              rear_wheel_axle_spec,
                                              rc_wheel_plist,
                                              settings);
  assert(abs(wheel_origin[2] - target_z - height_offset) < epsilon,
         "Upright wheel center must meet the requested ride-height datum");
  shaft_origin = rear_axle_wheel_shaft_origin(rear_housing_spec,
                                              rear_lower_arm_spec,
                                              rear_hub_spec,
                                              rear_wheel_axle_spec,
                                              settings);
  inner_bearing = hsp_rear_wheel_axle_bearing_positions(rear_wheel_axle_spec)[0];
  bearing_start = inner_bearing[2] - plist_get("bearing_h",
                                               rear_wheel_axle_spec) / 2;
  axle = rear_hub_axle(rear_hub_spec);
  assert(norm(shaft_origin + [bearing_start, 0, 0]
              - hub_origin - [0, axle[1], axle[2]]) < epsilon,
         "Wheel shaft and hub bearing seats must share the posed datum");
  shock_local = rear_lower_arm_shock_positions(rear_lower_arm_spec)[0];
  shock_placed = rear_axle_arm_point(shock_local,
                                     settings,
                                     rear_housing_spec,
                                     rear_lower_arm_spec,
                                     rear_hub_spec);
  assert(abs(norm(shock_placed - ball) - norm(shock_local - outer)) < epsilon,
         "Shock attachment must follow the rigid lower arm");
}

link_points = rear_axle_camber_link_centers(rear_axle_settings,
                                            rear_housing_spec,
                                            rear_lower_arm_spec,
                                            rear_hub_spec,
                                            rear_differential_spec,
                                            rear_tower_spec);
link_fit = rear_camber_link_fit(link_points[0],
                                link_points[1],
                                plist_get("camber_link", rear_axle_settings));
assert(abs(plist_get("length_error", link_fit)) < 0.05,
       "Nominal camber-arm reach must close the fixed-length link within 0.05 mm");
echo("Rear upright rest-pose checks passed");
