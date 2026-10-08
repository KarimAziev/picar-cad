/**
  * Module: Utilities for rear suspension mount
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../rc_params.scad>
include <../rear_chassis/rear_chassis_params.scad>
include <rear_suspension_params.scad>

use <../../lib/plist.scad>
use <../rear_chassis/computed_params.scad>

function rear_suspension_outline(layout=rear_chassis_layout()) =
  let (r = rear_suspension_chassis_bolt_bore_d / 2,
       pad = rear_suspension_chassis_bolt_pad,
       holder_x = rear_suspension_holder_bolt_spacing_x / 2 + r,
       half_w = plist_get("suspension_w", layout) / 2,
       max_y = plist_get("max_y", layout),
       maintenance_y = plist_get("maintenance_y", layout),
       joint_y = rear_suspension_joint_y_bounds(layout),
       recess_end_y = rear_suspension_mount_recess_end_y(layout),
       joint_w = rear_suspension_joint_width(layout),
       joint_w_hf = joint_w / 2,
       x_max = joint_w_hf - front_chassis_joint_boolean_overlap,
       y_joint_end = joint_y[1],
       arm_cutout_y = maintenance_y + rear_chassis_maintenance_hole_d * 0.5
                      + rear_suspension_chassis_maintenance_pad,
       arm_cutout_x = ((x_max - half_w) * 0.7))
  [[0, max_y],
   [holder_x, max_y],
   [holder_x + r + pad, 0],
   [half_w - pad, -r],
   [plist_get("ear_x", layout), plist_get("ear_start_y", layout)],
   [plist_get("ear_x", layout), plist_get("ear_end_y", layout)],
   [half_w, plist_get("bulkhead_1_y", layout) + rear_bulkhead_bolt_spacing_1[1] / 2 + r],
   // Keep the recess step inside a straight edge, away from the taper vertex.
   [half_w, recess_end_y + front_chassis_joint_boolean_overlap],
   [arm_cutout_x, arm_cutout_y],
   [x_max, rear_suspension_mount_shoulder_y(layout)],
   [x_max, y_joint_end],
   [0, y_joint_end]];
