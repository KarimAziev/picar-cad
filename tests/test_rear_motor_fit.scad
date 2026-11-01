/**
  * Module: Rear motor coupling alignment contracts.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/rc_params.scad>
include <../scad/suspension/rear_axle/structure_params.scad>
include <../scad/suspension/rear_axle/hardware_params.scad>
use <../scad/lib/plist.scad>
use <../scad/suspension/rear_chassis/computed_params.scad>
use <../scad/suspension/rear_axle/motor_fit.scad>

layout = rear_chassis_layout();
tolerance = 0.000001;
joint_spacing = 0;
fit = rear_axle_motor_fit(layout, rear_housing_spec, rear_differential_spec,
                          rear_pinion_spec, rear_motor_sleeve_spec,
                          suspension_chassis_mount_h, joint_spacing);
assert(norm(plist_get("motor_tip", fit) - [0, -74.4, 23.15]) < tolerance);
assert(norm(plist_get("required_motor_tip", fit) - [0, -71.45, 26.6])
       < tolerance);
assert(norm(plist_get("sleeve_motor_mouth", fit) - [0, -81.45, 26.6])
       < tolerance);
assert(abs(plist_get("radial_offset", fit) - 3.45) < tolerance,
       "The configured motor and sleeve axes must expose their height mismatch");
assert(abs(plist_get("engagement_available", fit) - 7.05) < tolerance);
assert(abs(plist_get("engagement_deficit", fit) - 2.95) < tolerance,
       "Axial engagement shortage differs from an air gap at the sleeve mouth");
assert(plist_get("motor_shaft_d", fit) == 3.95
       && plist_get("sleeve_motor_bore_d", fit) == 4,
       "The sleeve mates with the geared output, not the internal motor shaft");

// A hypothetical motor placement verifies the datum and direction contracts.
aligned_layout = plist_put("motor_pos",
                            plist_get("motor_pos", layout)
                            + plist_get("tip_delta", fit), layout);
aligned = rear_axle_motor_fit(aligned_layout, rear_housing_spec,
                              rear_differential_spec, rear_pinion_spec,
                              rear_motor_sleeve_spec,
                              suspension_chassis_mount_h, joint_spacing);
assert(plist_get("radial_offset", aligned) < tolerance);
assert(plist_get("engagement_deficit", aligned) < tolerance);
assert(abs(plist_get("engagement_available", aligned)
           - plist_get("engagement_required", aligned)) < tolerance);

separation = 5;
separated = rear_axle_motor_fit(layout, rear_housing_spec,
                                rear_differential_spec, rear_pinion_spec,
                                rear_motor_sleeve_spec,
                                suspension_chassis_mount_h, separation);
assert(abs(plist_get("engagement_available", separated)
           - plist_get("engagement_available", fit) + separation) < tolerance);
assert(plist_get("motor_tip", separated) == plist_get("motor_tip", fit),
       "Suspension spacing must not move the motor");
assert(abs(plist_get("radial_offset", separated)
           - plist_get("radial_offset", fit)) < tolerance);
echo("PASS rear motor endpoint, radial alignment and sleeve engagement diagnostics");
