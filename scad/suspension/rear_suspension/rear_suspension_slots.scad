/**
  * Module: Measured rear-suspension mounting and maintenance cutters.
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <computed_params.scad>
use <../../lib/plist.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_counterbore
  ─────────────────────────────────────────────────────────────────────────────
  Cut one suspension bolt passage with its original underside head recess.
 */
module rear_suspension_counterbore() {
  counterbore(d=rear_suspension_chassis_bolt_d,
              h=front_chassis_thickness,
              bore_h=rear_suspension_chassis_bolt_bore_h,
              bore_d=rear_suspension_chassis_bolt_bore_d,
              sink=rear_suspension_chassis_sink,
              reverse=true);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_slots
  ─────────────────────────────────────────────────────────────────────────────
  Emit the measured bolt pattern, arm-pad slot and maintenance hole.
  **Parameters:**
  - `anchor`: Envelope anchor, or `undef` to retain native holder-row coordinates.
  **Notes:** Body and cutters use the same envelope. Mounting recesses face -Z.
 */
module rear_suspension_slots(anchor=undef) {
  layout = rear_suspension_layout();
  size = plist_get("size", layout);
  center_y = (plist_get("min_y", layout) + plist_get("max_y", layout)) / 2;
  with_anchor(is_undef(anchor) ? [0, 0, 1] : anchor, size, centered=true)
    translate([0, is_undef(anchor) ? 0 : -center_y, 0]) {
      for (row = [[0, [rear_suspension_holder_bolt_spacing_x, 0]],
                  [plist_get("bulkhead_1_y", layout), rear_bulkhead_bolt_spacing_1],
                  [plist_get("bulkhead_2_y", layout), rear_bulkhead_bolt_spacing_2]])
        translate([0, row[0], 0]) four_corner_children(size=row[1])
          rear_suspension_counterbore();
      translate([0, plist_get("rect_y", layout), 0])
        rect_slot(h=front_chassis_thickness,
                   size=rear_suspension_arm_pad_rect_slot_size,
                   r=rear_suspension_arm_pad_rect_corner_r, center=true);
      translate([0, plist_get("maintenance_y", layout), 0])
        counterbore(h=front_chassis_thickness, d=rear_chassis_maintenance_hole_d);
    }
}

rear_suspension_slots();
