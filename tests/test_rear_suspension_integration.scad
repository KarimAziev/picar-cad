/**
  * Module: Rear suspension chassis transforms and wheel seating contracts.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/rc_params.scad>
include <../scad/suspension/front_chassis/computed_params.scad>
include <../scad/suspension/rear_axle/arm_hub_params.scad>
include <../scad/suspension/rear_axle/hardware_params.scad>
include <../scad/suspension/rear_axle/structure_params.scad>

use <../scad/lib/plist.scad>
use <../scad/placeholders/hsp_rear_drivetrain.scad>
use <../scad/suspension/chassis_dimensions.scad>
use <../scad/suspension/rear_axle/rear_axle_assembly.scad>
use <../scad/suspension/rear_axle/rear_bulkhead.scad>
use <../scad/suspension/rear_chassis/computed_params.scad>
use <../scad/suspension/rear_suspension/rear_suspension_slots.scad>
use <../scad/suspension/rear_suspension_assembly.scad>

layout       = rear_chassis_layout();
epsilon      = 0.000001;
mounts       = rear_bulkhead_mount_positions(layout,
                                             rear_bulkhead_bolt_spacing_x,
                                             rear_bulkhead_bolt_spacing_2[1]);
plate_mounts = rear_suspension_bulkhead_mount_positions(layout);
assert(len(mounts) == 8 && len(plate_mounts) == len(mounts));
for (spacing = [0, 17]) {
  datum = rear_suspension_chassis_datum(layout,
                                        suspension_chassis_mount_h,
                                        spacing);
  for (i = [0 : len(mounts) - 1]) {
    p = mounts[i];
    native = datum + [-p[0], -p[1], p[2]];
    assert(norm(native - plate_mounts[i] - [0, spacing, suspension_chassis_mount_h])
           < epsilon,
           "Every housing mount must coincide with its native plate cutter");
  }
  assembled_y = front_chassis_y_joint_2_end + plist_get("min_y", layout) - datum[1];
  zero_y = front_chassis_y_joint_2_end + plist_get("min_y", layout)
           - plist_get("bulkhead_2_y", layout);
  assert(abs(assembled_y - (zero_y - spacing)) < epsilon,
         "Positive suspension separation moves the axle toward vehicle rear");
}
for (wheel = [rc_wheel_plist, plist_put("mount_z", 17, rc_wheel_plist)]) {
  origin = rear_suspension_wheel_origin(rear_housing_spec,
                                        rear_lower_arm_spec,
                                        rear_hub_spec,
                                        rear_wheel_axle_spec,
                                        wheel);
  shaft = rear_axle_wheel_shaft_origin(rear_housing_spec,
                                       rear_lower_arm_spec,
                                       rear_hub_spec,
                                       rear_wheel_axle_spec);
  assert(norm(origin + [plist_get("mount_z", wheel), 0, 0]
              - shaft - [hsp_rear_wheel_axle_mount_z(rear_wheel_axle_spec), 0, 0])
         < epsilon,
         "Wheel backspacing must preserve contact with the shaft hex");
  reference = rear_suspension_wheel_reference_center(layout,
                                                     suspension_chassis_mount_h,
                                                     rear_housing_spec,
                                                     rear_lower_arm_spec,
                                                     rear_hub_spec,
                                                     rear_wheel_axle_spec,
                                                     wheel);
  assert(reference[0] == origin[0] + plist_get("width", wheel) / 2);
  assert(reference[1] == plist_get("bulkhead_2_y", layout) - origin[1]);
  assert(reference[2] == suspension_chassis_mount_h + origin[2]);
  dimensions = chassis_dimensions(layout=layout, rear_reference=reference);
  assert(plist_get("rear_track", dimensions) == reference[0] * 2);
  assert(abs(plist_get("rear_front_ground_height_delta", dimensions)) < epsilon,
         "The upright rear tire must share the front tire ground tangent");
  assert(plist_get("rear_axle_y", dimensions)
         == front_chassis_y_joint_2_end + plist_get("min_y", layout) - reference[1]);
  assert(plist_get("chassis_length", dimensions)
         == plist_get("chassis_length", chassis_dimensions(layout=layout)),
         "Axle integration must preserve chassis length");
}
assert(plist_get("w", rear_lower_arm_spec) >= 48.6
       && plist_get("w", rear_lower_arm_spec) <= 49,
       "Nominal arm envelope must remain within the measured range");
echo("PASS rear mounting rows, rearward separation, wheel seating and dimension datums");
