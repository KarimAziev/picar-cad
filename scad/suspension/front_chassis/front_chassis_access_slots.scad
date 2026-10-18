/**
  * Module: Chassis camera ribbon and head-side cable openings.
  */

include <computed_params.scad>

use <../../lib/transforms.scad>
use <head_frame/head_slots.scad>

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
  front_chassis_camera_ribbon_slot
  ─────────────────────────────────────────────────────────────────────────────
  Cut a trapezoidal camera ribbon passage with the shared head-zone dimensions.
  **Parameters:**
  - `thickness`: Frame thickness crossed by the passage, starting at Z=0.
  - `anchor`: Anchor on the `[width, length, thickness]` reference box.
  **Behavior:** The wider edge faces -Y. The cutter overlaps both frame faces.
 */
module front_chassis_camera_ribbon_slot(thickness=chassis_thickness,
                                        anchor=[1, 1, 1]) {
  eps = front_chassis_joint_boolean_overlap;
  w = front_chassis_head_pan_servo_top_ribbon_cutout_len;
  l = front_chassis_head_pan_servo_top_ribbon_cutout_h;
  assert(w > 2 * l && l > 0 && thickness > 0,
         "Camera ribbon passage needs positive dimensions and width > 2 * length");
  with_anchor(anchor, [w, l, thickness], centered=true) {
    translate([0, 0, -eps]) {
      linear_extrude(height=thickness + eps * 2) {
        polygon([[-w / 2, -l / 2], [w / 2, -l / 2],
                 [w / 2 - l, l / 2], [-w / 2 + l, l / 2]]);
      }
    }
  }
}

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
  with_anchor(anchor, [head[0], head[1], thickness], centered=true) {
    translate([0, front_chassis_head_front_ribbon_y(), 0]) {
      front_chassis_camera_ribbon_slot(thickness=thickness, anchor=[0, 0, 1]);
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
                 head_y + (row - (rows - 1) / 2) * (l + land),
                 0]) {
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
