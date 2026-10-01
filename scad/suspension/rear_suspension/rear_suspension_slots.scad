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

module rear_suspension_mount_slots(layout=rear_chassis_layout()) {
  for (row = [[0, [rear_suspension_holder_bolt_spacing_x, 0]],
              [plist_get("bulkhead_1_y", layout), rear_bulkhead_bolt_spacing_1],
              [plist_get("bulkhead_2_y", layout), rear_bulkhead_bolt_spacing_2]]) {
    translate([0, row[0], 0]) {
      four_corner_children(size=row[1]) {
        rear_suspension_counterbore();
      }
    }
  }

  translate([0, plist_get("rect_y", layout), 0]) {
    rear_suspension_arm_pad_rect_slot();
  }
}

rear_suspension_mount_slots();