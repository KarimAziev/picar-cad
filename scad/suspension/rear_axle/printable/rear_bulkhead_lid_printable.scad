/**
  * Module: Rear differential housing lid on its print bed.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../arm_hub_params.scad>
include <../hardware_params.scad>
include <../structure_params.scad>

use <../../../lib/plist.scad>
use <../../rear_chassis/computed_params.scad>
use <../rear_bulkhead.scad>

mounts = rear_bulkhead_mount_positions(rear_chassis_layout(),
                                       rear_bulkhead_bolt_spacing_x,
                                       rear_bulkhead_bolt_spacing_2[1]);
translate([0, 0, -rear_bulkhead_split_z(rear_housing_spec)]) {
  rear_bulkhead(rear_housing_spec,
                rear_differential_spec,
                rear_pinion_spec,
                rear_lower_arm_spec,
                rear_tower_spec,
                mounts,
                part="lid",
                show_hardware=false);
}
