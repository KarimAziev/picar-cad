/**
  * Module: Rear suspension slots
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../parameters.scad>
include <rear_suspension_params.scad>

use <../../lib/plist.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../bulkhead/front_bulkhead_chassis.scad>
use <../rear_chassis/computed_params.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_counterbore
  ─────────────────────────────────────────────────────────────────────────────
  Cut one suspension bolt passage with its original underside head recess.
 */
module rear_suspension_counterbore() {
  counterbore(d=rear_suspension_chassis_bolt_d,
              h=chassis_thickness,
              bore_h=rear_suspension_chassis_bolt_bore_h,
              bore_d=rear_suspension_chassis_bolt_bore_d,
              sink=rear_suspension_chassis_sink,
              reverse=true);
}

module rear_suspension_arm_pad_rect_slot() {
  rect_slot(h=chassis_thickness,
            size=rear_suspension_arm_pad_rect_slot_size,
            r=rear_suspension_arm_pad_rect_corner_r,
            center=true);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_bulkhead_mount_positions
  ─────────────────────────────────────────────────────────────────────────────
  Locate the shared front-housing bolt pattern on the native rear chassis plate.
  **Parameters:** `layout`: `rear_chassis_layout()` in
  `../rear_chassis/computed_params.scad`, including the axle datum `bulkhead_2_y`.
  **Returns:** Eight XYZ bolt centers at Z=0. Vehicle X/Y reverse under the
  axle's 180-degree chassis placement; the existing plate envelope stays fixed.
 */
function rear_suspension_bulkhead_mount_positions(layout) =
  [for (p = front_bulkhead_housing_mount_positions())
    [-p[0], plist_get("bulkhead_2_y", layout) - p[1], 0]];

module rear_suspension_mount_slots(layout=rear_chassis_layout()) {
  four_corner_children(size=[rear_suspension_holder_bolt_spacing_x, 0]) {
    rear_suspension_counterbore();
  }
  for (p = rear_suspension_bulkhead_mount_positions(layout)) {
    translate(p) {
      rear_suspension_counterbore();
    }
  }

  translate([0, plist_get("rect_y", layout), 0]) {
    rear_suspension_arm_pad_rect_slot();
  }
}

rear_suspension_mount_slots();
