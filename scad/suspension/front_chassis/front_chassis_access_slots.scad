/**
  * Module: Head-side cable and upper ribbon access openings.
  * Adapts the legacy side trapezoids and ribbon passage to the new outline.
  */

include <computed_params.scad>

use <../../lib/transforms.scad>
use <front_chassis_head_slots.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_front_ribbon_y
  ─────────────────────────────────────────────────────────────────────────────

  Locate the front ribbon passage just beyond the head mounting footprint.

  **Returns:** Y center relative to the pan axis, with a full material land
  between the mounting footprint and the passage's rear edge.
 */
function front_chassis_head_front_ribbon_y() =
  front_chassis_head_mount_size()[1] / 2 + front_chassis_head_wire_land
    + front_chassis_head_pan_servo_top_ribbon_cutout_h / 2;

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_front_ribbon_slot
  ─────────────────────────────────────────────────────────────────────────────

  Cut the trapezoidal ribbon passage ahead of the head mounting footprint.

  **Parameters:**
  - `thickness`: Frame thickness crossed by the passage.
  - `anchor`: Anchor on the head mounting-pad envelope, matching the horn slots.
 */
module front_chassis_head_front_ribbon_slot(thickness=chassis_thickness,
                                           anchor=[0, 0, 1]) {
  head = front_chassis_head_mount_size();
  eps = front_chassis_joint_boolean_overlap;
  w = front_chassis_head_pan_servo_top_ribbon_cutout_len;
  l = front_chassis_head_pan_servo_top_ribbon_cutout_h;
  with_anchor(anchor, [head[0], head[1], thickness], centered=true) {
    translate([0, front_chassis_head_front_ribbon_y(), -eps]) {
      linear_extrude(height=thickness + eps * 2) {
        polygon([[-w / 2, -l / 2], [w / 2, -l / 2],
                 [w / 2 - l, l / 2], [-w / 2 + l, l / 2]]);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_access_slots
  ─────────────────────────────────────────────────────────────────────────────
  Cut the head-side trapezoids and the front ribbon passage.
  **Parameters:**
  - `head_y`: Head pan-axis Y coordinate in the same frame.
 */
module front_chassis_access_slots(head_y) {
  land = front_chassis_head_wire_land;
  w = front_chassis_head_side_slot_w;
  l = front_chassis_head_side_slot_l;
  rows = front_chassis_head_side_slot_rows;
  eps = front_chassis_joint_boolean_overlap;
  head = front_chassis_head_mount_size();
  assert(rows * l + (rows - 1) * land <= head[1]);
  translate([0, 0, -eps]) {
    for (side = [-1, 1], row = [0:rows - 1]) {
      // A tapered inner edge leaves the full head base and its mounting land.
      translate([side * (head[0] / 2 + land),
                 head_y + (row - (rows - 1) / 2) * (l + land), 0]) {
        scale([side, 1, 1]) {
          linear_extrude(height=chassis_thickness + eps * 2) {
            polygon([[0, -l / 2], [w, -l / 2], [w, l / 2], [w / 2, l / 2]]);
          }
        }
      }
    }
  }
  translate([0, head_y, 0]) {
    front_chassis_head_front_ribbon_slot();
  }
}
