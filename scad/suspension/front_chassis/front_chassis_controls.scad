/**
  * Module: Controls, fuse stack and Raspberry Pi placement beside the steering servo.
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
   rear_y + land + size[1] / 2, chassis_thickness];

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
                slot_thickness=chassis_thickness);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_rpi
  ─────────────────────────────────────────────────────────────────────────────
  Place the RPi or its mounting cutters using the front-frame configuration.
  **Parameters:**
  - `slot_mode`: Cut mounting holes and camera-ribbon passages through the frame.

  `front_rpi_orientation` selects the flat layout; `front_rpi_rotate_z_180` turns
  the board 180 degrees in its plane. Both keep the configured minimum X and
  maximum Y of its reference box fixed. Chassis width follows the mounting
  footprint; connector overhang does not require supporting plate material.
 */
module front_chassis_rpi(slot_mode=false) {
  bounds = front_chassis_rpi_bounds();
  translate([bounds[0][0], bounds[1][1], 0]) {
    rpi_5(anchor=[1, -1, 1],
          orientation=front_rpi_orientation,
          rotate_z_180=front_rpi_rotate_z_180,
          slot_thickness=chassis_thickness,
          bolt_visible_h=chassis_thickness - chassis_counterbore_h,
          show_standoffs=true,
          slot_mode=slot_mode);
  }
}

front_chassis_rpi();
