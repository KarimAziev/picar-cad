/**
  * Module: Rear axle mounting and fit contracts.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/suspension/rear_axle/structure_params.scad>
include <../scad/suspension/rear_axle/hardware_params.scad>
include <../scad/suspension/rear_axle/arm_hub_params.scad>
use <../scad/lib/plist.scad>
use <../scad/suspension/bulkhead/front_bulkhead_chassis.scad>
use <../scad/suspension/rear_chassis/computed_params.scad>
use <../scad/suspension/rear_axle/rear_bulkhead.scad>
use <../scad/suspension/rear_axle/rear_axle_assembly.scad>
use <../scad/suspension/rear_axle/rear_lower_arm.scad>
use <../scad/suspension/rear_axle/rear_hub.scad>
use <../scad/placeholders/hsp_rear_drivetrain.scad>

layout = rear_chassis_layout();
mounts = rear_bulkhead_mount_positions(layout, rear_bulkhead_bolt_spacing_x,
                                       rear_bulkhead_bolt_spacing_2[1]);
front_mounts = front_bulkhead_housing_mount_positions();
assert(len(mounts) == 8);
for (i = [0 : len(mounts) - 1]) {
  assert(norm(mounts[i] - front_mounts[i]) < 0.000001,
         "Rear housing must preserve every shared front mounting center");
  assert(mounts[i][2] == 0);
}

retained = rear_bulkhead_fastener_positions(rear_housing_spec, mounts);
assert(len(retained) == 4, "Four outer-pattern bolts retain both housing parts");
for (i = [0 : len(retained) - 2], j = [i + 1 : len(retained) - 1]) {
  assert(norm(retained[i] - retained[j])
         > plist_get("mount_nut_af", rear_housing_spec) / cos(30),
         "Captive nuts must have disjoint installation envelopes");
}

for (arm = [rear_lower_arm_spec,
            plist_put("h", plist_get("h", rear_lower_arm_spec) + 2,
                      rear_lower_arm_spec)]) {
  pos = rear_axle_arm_origin(rear_housing_spec, arm);
  hinge = rear_bulkhead_hinge_axis(rear_housing_spec, arm);
  assert(norm(pos + rear_lower_arm_inner_pivot(arm) - hinge) < 0.000001,
         "The zero-angle arm datum must preserve the shared housing hinge");
  assert(abs(hinge[2] - front_bulkhead_housing_h / 2) < 0.000001,
         "Rear hinge height must follow the front housing envelope");
  hub_pos = rear_axle_hub_origin(rear_housing_spec, arm, rear_hub_spec);
  lower_ball = rear_axle_arm_point(rear_lower_arm_outer_pivot(arm),
                                   rear_axle_settings, rear_housing_spec,
                                   arm, rear_hub_spec);
  assert(norm(lower_ball - hub_pos - rear_hub_pivot(rear_hub_spec)) < 0.000001,
         "Hub ball centers must follow the articulated arm studs");
}
fit = rear_axle_fit(rear_housing_spec, rear_lower_arm_spec, rear_hub_spec,
                    rear_differential_spec, rear_wheel_axle_spec, rear_dogbone_spec);
assert(plist_get("stock_dogbone_l", fit) == 61.2 - 5.8);
assert(plist_get("dogbone_length_error", fit) > 7,
       "Unmeasured hub offsets must expose the measured dogbone placement mismatch");
assert(abs(plist_get("required_dogbone_l", fit)
           + plist_get("dogbone_length_error", fit) - (61.2 - 5.8)) < 0.000001);

sleeve_start_y = rear_bulkhead_pinion_origin(rear_housing_spec,
                                            rear_differential_spec,
                                            rear_pinion_spec)[1]
                  + hsp_rear_pinion_shaft_end(rear_pinion_spec)[2]
                  - plist_get("pinion_engagement", rear_motor_sleeve_spec);
assert(sleeve_start_y - rear_bulkhead_pinion_neck_end(rear_housing_spec,
                                                      rear_pinion_spec)
       >= plist_get("coupling_axial_gap", rear_axle_settings));
assert(plist_get("motor_bore_d", rear_motor_sleeve_spec) == 4
       && plist_get("pinion_bore_d", rear_motor_sleeve_spec) == 5);
echo("PASS rear axle mounting frame, shared pivots, honest shaft fit and sleeve clearance");
