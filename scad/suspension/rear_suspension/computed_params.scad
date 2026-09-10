/**
  * Module: Measured rear-suspension interface datums.
  * Native coordinates put the last holder row at Y=0; the input is toward -Y.
  */
include <../../steering_params.scad>
include <rear_suspension_params.scad>
use <../../lib/plist.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_layout
  ─────────────────────────────────────────────────────────────────────────────
  Convert measured edge gaps into shared hole centers and outline dimensions.
  **Returns:** Property list in native holder-row coordinates, with Z=0 below
  the plate. `min_y` is the flat joining edge; `maintenance_y` locates the input.
 */
function rear_suspension_layout() =
  let (d = rear_suspension_chassis_bolt_bore_d,
       r = d / 2,
       pad = rear_suspension_chassis_bolt_pad,
       spacing_1 = rear_bulkhead_bolt_spacing_1,
       spacing_2 = rear_bulkhead_bolt_spacing_2,
       bh_1 = -d - rear_bulkhead_bolt_spacing_1_holder_dist,
       bh_2 = bh_1 - spacing_1[1] / 2 - d
              - rear_bulkhead_bolt_spacing_1_2_edge_dist - spacing_2[1] / 2,
       rect_y = bh_2 - spacing_2[1] / 2 - r
                - rear_suspension_arm_pad_bulkhead_slot_dist
                - rear_suspension_arm_pad_rect_slot_size[1] / 2,
       maintenance_y = rect_y - rear_suspension_arm_pad_rect_slot_size[1] / 2
                       - rear_chassis_maintenance_hole_arm_pad_dist
                       - rear_chassis_maintenance_hole_d / 2,
       min_y = maintenance_y - rear_chassis_maintenance_hole_d / 2 - pad,
       max_y = r + pad,
       half_w = max(spacing_1[0], spacing_2[0]) / 2 + r + pad,
       ear_x = half_w + r,
       ear_start_y = -r - pad,
       ear_end_y = bh_1 + spacing_1[1] / 2 + r + pad)
  assert(ear_start_y > ear_end_y, "Holder-to-bulkhead gap cannot contain the ear")
  ["bulkhead_1_y", bh_1, "bulkhead_2_y", bh_2,
   "rect_y", rect_y, "maintenance_y", maintenance_y,
   "min_y", min_y, "max_y", max_y,
   "join_w", half_w * 2,
   "ear_x", ear_x, "ear_start_y", ear_start_y, "ear_end_y", ear_end_y,
   "size", [ear_x * 2, max_y - min_y, front_chassis_thickness]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_outline_points
  ─────────────────────────────────────────────────────────────────────────────
  Derive the right half-outline from the bolt lands and measured row spacing.
  **Returns:** Nonduplicated polygon points; mirror across X for the full plate.
 */
function rear_suspension_outline_points() =
  let (layout = rear_suspension_layout(),
       r = rear_suspension_chassis_bolt_bore_d / 2,
       pad = rear_suspension_chassis_bolt_pad,
       corner_r = rear_suspension_chassis_corner_r,
       holder_x = rear_suspension_holder_bolt_spacing_x / 2 + r,
       half_w = plist_get("join_w", layout) / 2,
       max_y = plist_get("max_y", layout),
       min_y = plist_get("min_y", layout))
  [[-corner_r, max_y], [holder_x, max_y], [holder_x + r + pad, 0],
   [half_w - pad, -r],
   [plist_get("ear_x", layout), plist_get("ear_start_y", layout)],
   [plist_get("ear_x", layout), plist_get("ear_end_y", layout)],
   [half_w, plist_get("bulkhead_1_y", layout)
             + rear_bulkhead_bolt_spacing_1[1] / 2 + r],
   [half_w, min_y], [-corner_r, min_y]];
