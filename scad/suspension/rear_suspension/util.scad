/**
  * Module: Utilities for rear suspension mount
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <rear_suspension_params.scad>

use <../../lib/plist.scad>
use <../rear_chassis/computed_params.scad>

function rear_suspension_outline(layout=rear_chassis_layout()) =
  let (r = rear_suspension_chassis_bolt_bore_d / 2,
       pad = rear_suspension_chassis_bolt_pad,
       corner_r = rear_suspension_chassis_corner_r,
       holder_x = rear_suspension_holder_bolt_spacing_x / 2 + r,
       half_w = plist_get("suspension_w", layout) / 2,
       max_y = plist_get("max_y", layout),
       transition_y_start = plist_get("transition_y_start", layout))
  [[-corner_r, max_y],
   [holder_x, max_y],
   [holder_x + r + pad, 0],
   [half_w - pad, -r],
   [plist_get("ear_x", layout), plist_get("ear_start_y", layout)],
   [plist_get("ear_x", layout), plist_get("ear_end_y", layout)],
   [half_w, plist_get("bulkhead_1_y", layout) + rear_bulkhead_bolt_spacing_1[1] / 2 + r],
   [half_w, transition_y_start],
   [-corner_r, transition_y_start]];