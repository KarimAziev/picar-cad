/**
  * Module: Three camera-ribbon passages below the Raspberry Pi CSI connectors.
  * The surrounding solid land connects the openings to the mounting lattice.
  */
include <computed_params.scad>
use <../../lib/shapes3d.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_camera_slot_pos
  ─────────────────────────────────────────────────────────────────────────────
  Locate the first ribbon row behind the CSI sockets and their mounting bolts.
  **Returns:** First slot center `[x, y, z]` in middle-frame coordinates.
 */
function middle_chassis_camera_slot_pos() =
  [rpi_csi_position_x - rpi_width / 2,
   middle_chassis_component_front_y() - rpi_len
   + min(rpi_csi_position_y - middle_chassis_mount_land,
         rpi_bolts_offset + rpi_bolt_spacing[1] - rpi_bolt_cbore_dia / 2
           - middle_chassis_mount_land)
   - middle_chassis_camera_slot_l / 2, 0];

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_camera_slots
  ─────────────────────────────────────────────────────────────────────────────
  Build a connected service land or its three rectangular through-cutters.
  **Parameters:**
  - `slot_mode`: True emits openings; false emits the surrounding solid land.
 */
module middle_chassis_camera_slots(slot_mode=true) {
  pos = middle_chassis_camera_slot_pos();
  w = middle_chassis_camera_slot_w;
  l = middle_chassis_camera_slot_l;
  rows = middle_chassis_camera_slot_rows;
  land = middle_chassis_mount_land;
  pitch = l + land;
  eps = front_chassis_joint_boolean_overlap;
  if (slot_mode) {
    for (row = [0:rows - 1]) {
      translate(pos + [0, -row * pitch, -eps]) {
        cuboid([w, l, middle_chassis_thickness + eps * 2], r=middle_chassis_camera_slot_r);
      }
    }
  } else {
    translate(pos + [0, -(rows - 1) * pitch / 2, 0]) {
      cuboid([w + land * 2, rows * l + (rows + 1) * land, middle_chassis_thickness]);
    }
  }
}
