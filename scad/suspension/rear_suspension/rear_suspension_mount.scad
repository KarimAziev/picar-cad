/**
  * Module: Rear-suspension mounting plate with a chassis joint
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../rc_params.scad>
include <../rear_chassis/computed_params.scad>
include <../rear_chassis/rear_chassis_params.scad>

use <../../lib/debug.scad>
use <../../lib/plist.scad>
use <../../lib/polygon_util.scad>
use <../../lib/transforms.scad>
use <../rear_chassis/rear_chassis_slots.scad>
use <rear_suspension_joint.scad>
use <rear_suspension_slots.scad>
use <util.scad>

module rear_suspension_mount_outline(layout=rear_chassis_layout()) {
  mirror_copy([1, 0, 0]) {
    polygon(rear_suspension_outline(layout));
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_mount
  ─────────────────────────────────────────────────────────────────────────────
  Build the lowered rear suspension footprint and reinforced chassis socket.
  **Parameters:**
  - `layout`: Shared rear chassis layout in native holder-row coordinates.
  - `debug`: Display outline labels.
  - `debug_font`: Font for outline labels.
  - `debug_color`: Outline label color.
  - `color`: Mount body color.
  - `joint_color`: Socket color.
  - `slot_mode`: Emit the recess, mounting holes and joint cutters.
  **Behavior:** The suspension footprint sits at `suspension_chassis_mount_h`;
  the flared joint region retains the full chassis thickness.
 */
module rear_suspension_mount(layout=rear_chassis_layout(),
                             debug=false,
                             debug_font="Gill Sans:style=Bold",
                             debug_color=green_2,
                             color=white_smoke_1,
                             joint_color=light_grey,
                             slot_mode=false) {
  assert(suspension_chassis_mount_recess >= 0
         && suspension_chassis_mount_h - rear_suspension_chassis_bolt_bore_h >= 1.5,
         "Rear suspension mounts need 1.5 mm above the screw-head seats");
  pts = rear_suspension_outline(layout);
  min_y = polygon_min_y(pts);

  module _slots() {
    if (suspension_chassis_mount_recess > 0) {
      translate([-plist_get("join_w", layout),
                 rear_suspension_mount_recess_end_y(layout),
                 suspension_chassis_mount_h]) {
        cube([plist_get("join_w", layout) * 2,
              plist_get("max_y", layout)
              - rear_suspension_mount_recess_end_y(layout) + 1,
              suspension_chassis_mount_recess + 0.02]);
      }
    }
    rear_suspension_mount_slots(layout=layout);
    rear_chassis_slots(layout=layout);

    translate([0, min_y, 0]) {
      rear_suspension_chassis_joint(anchor=[0, -1, 1],
                                    layout=layout,
                                    mode="female",
                                    slot_mode=true);
    }
  }

  if (slot_mode) {
    _slots();
  } else {
    color(color, alpha=1) {
      difference() {
        union() {
          linear_extrude(height=chassis_thickness) {
            rear_suspension_mount_outline(layout);
          }
          translate([0, min_y, 0]) {
            rear_suspension_chassis_joint(anchor=[0, -1, 1],
                                          layout=layout,
                                          mode="female",
                                          color=joint_color);
          }
        }

        _slots();
      }
    }
  }
  if (debug && !slot_mode) {
    translate([0,
               0,
               chassis_thickness + front_chassis_joint_boolean_overlap]) {
      mirror_copy([1, 0, 0]) {
        debug_polygon_text(pts,
                           circle_color="red",
                           font=debug_font,
                           color=debug_color);
      }
    }
  }
}
rear_suspension_mount(debug=true);
