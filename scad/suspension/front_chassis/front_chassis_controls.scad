/**
  * Module: Controls and fuse stack beside the steering servo.
  * Component and mounting slots share the same front-frame datum.
  */
include <computed_params.scad>

use <../../panel_stack/panel_stack.scad>
use <../../placeholders/rpi_5.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_controls_pos
  ─────────────────────────────────────────────────────────────────────────────
  Place the unrotated panel against the right edge, ahead of the rear joint.
  **Returns:** Panel center `[x, y, z]` on the frame's top face.
 */
function front_chassis_controls_pos() =
  let (size = panel_stack_size(),
       land = middle_chassis_mount_land,
       rear_y = -bellcrank_y_distance_from_bulkhead + bellcrank_zone_y_len,
       front_y = -bellcrank_y_distance_from_bulkhead + bellcrank_y_dist)
  assert(size[1] + land * 2 <= front_y - rear_y,
         "Controls do not fit between the steering mechanism and rear joint")
  [servo_slot_min_w - land - size[0] / 2,
   rear_y + land + size[1] / 2, front_chassis_thickness];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_controls
  ─────────────────────────────────────────────────────────────────────────────
  Render the relocated controls or cut their four mounting passages.
  **Parameters:**
  - `slot_mode`: Emit mounting cutters through the front frame.
 */
module front_chassis_controls(slot_mode=false) {
  pos = front_chassis_controls_pos();
  translate([pos[0], pos[1], slot_mode ? 0 : pos[2]]) {
    panel_stack(anchor=[0, 0, 1],
                orientation="wlh",
                show_buttons=true,
                show_standoff=true,
                slot_mode=slot_mode,
                slot_thickness=front_chassis_thickness);
  }
}

module front_chassis_rpi(slot_mode=false) {
  y_start = -bellcrank_y_distance_from_bulkhead + bellcrank_y_dist;
  translate([front_rpi_x_offset, y_start + front_rpi_y_offset, 0]) {
    rpi_5(anchor=[1, -1, 1], slot_mode=slot_mode);
  }
}

front_chassis_controls();
