/**
  * Module: Rear-suspension mounting plate with a flat chassis joining edge.
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../steering_params.scad>
include <computed_params.scad>
include <rear_suspension_params.scad>

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/shapes2d.scad>
use <../../lib/transforms.scad>
use <../front_chassis/front_chassis_joint.scad>
use <rear_suspension_slots.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_outline
  ─────────────────────────────────────────────────────────────────────────────
  Emit the native 2D plate outline for standalone or shared frame extrusion.
  **Parameters:**
  - `layout`: Resolved rear layout.
  **Notes:** Only the free boundary is rounded; the joining edge stays square.
 */
module rear_suspension_outline(layout=rear_suspension_layout()) {
  r = rear_suspension_chassis_corner_r;
  mirror_copy([1, 0, 0]) {
    offset_vertices_2d(r=r) {
      polygon(rear_suspension_outline_points(layout));
    }
    translate([plist_get("join_w", layout) / 2 - r,
               plist_get("min_y", layout)]) {
      square([r, r]);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_suspension_chassis
  ─────────────────────────────────────────────────────────────────────────────
  Build the measured mounting plate, independently of the ladder frame.
  **Parameters:**
  - `debug`: Display outline vertices above the part.
  - `debug_font`: Font for vertex labels.
  - `debug_color`: Color for vertex labels.
  - `color`: Body color; `undef` inherits the caller's color.
  - `slot_mode`: Emit only the shared mounting cutters.
  - `anchor`: Envelope anchor; `undef` retains the original holder row at Y=0.
  - `layout`: Resolved rear layout shared with components and cutters.
 */
module rear_suspension_chassis(debug=false,
                               debug_font="Gill Sans:style=Bold",
                               debug_color=green_2,
                               color=white_smoke_1,
                               slot_mode=false,
                               anchor=undef,
                               layout=rear_suspension_layout()) {
  size = plist_get("size", layout);
  center_y = (plist_get("min_y", layout) + plist_get("max_y", layout)) / 2;
  with_anchor(is_undef(anchor) ? [0, 0, 1] : anchor, size, centered=true) {
    translate([0, is_undef(anchor) ? 0 : -center_y, 0]) {
      if (slot_mode) {
        rear_suspension_slots(layout=layout);
      } else {
        maybe_color(color) {
          difference() {
            linear_extrude(height=front_chassis_thickness) {
              rear_suspension_outline(layout);
            }
            rear_suspension_slots(layout=layout);
          }
        }
      }
      if (debug && !slot_mode) {
        translate([0,
                   0,
                   front_chassis_thickness + front_chassis_joint_boolean_overlap]) {
          mirror_copy([1, 0, 0]) {
            debug_polygon_text(rear_suspension_outline_points(layout),
                               circle_color="red",
                               font_size=constraint(size[0] * 0.08, 1, 5),
                               font=debug_font,
                               color=debug_color);
          }
        }
      }
    }
  }
}

rear_suspension_chassis(debug=true);
