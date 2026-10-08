/**
  * Module: Rear-suspension mounting plate with a flat chassis joining edge.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../rc_params.scad>
include <computed_params.scad>
include <rear_chassis_params.scad>

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/transforms.scad>
use <../front_chassis/front_chassis_joint.scad>
use <../rear_suspension/rear_suspension_joint.scad>
use <../rear_suspension/rear_suspension_mount.scad>
use <rear_chassis_slots.scad>

rear_suspension_joint_spacing = 0; // [0:1:100]

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis_outline
  ─────────────────────────────────────────────────────────────────────────────
  Emit the native 2D plate outline for standalone or shared frame extrusion.
  **Parameters:**
  - `layout`: Resolved rear layout.
  **Notes:** Only the free boundary is rounded; the joining edge stays square.
 */
module rear_chassis_outline(layout=rear_chassis_layout()) {
  join_y = rear_suspension_joint_y_bounds(layout);
  join_w = rear_suspension_joint_width(layout);
  corner_r = rear_chassis_corner_r;
  join_y0 = join_y[0];
  join_y1 = join_y[1];
  join_yl = abs(join_y0) - abs(join_y1);

  difference() {
    mirror_copy([1, 0, 0]) {
      offset_vertices_2d(r=corner_r) {
        polygon(rear_chassis_outline_points(layout));
      }
    }
    translate([-join_w / 2, join_y0, 0]) {
      square([join_w, join_yl], center=false);
    }
  }
  // Keep the complete attachment edge square, including the mirrored center.
  translate([-plist_get("join_w", layout) / 2, plist_get("min_y", layout)]) {
    square([plist_get("join_w", layout), corner_r]);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis_frame
  ─────────────────────────────────────────────────────────────────────────────
  Build the measured mounting plate, independently of the ladder frame.
  **Parameters:**
  - `debug`: Display outline vertices above the part.
  - `debug_font`: Font for vertex labels.
  - `debug_color`: Color for vertex labels.
  - `color`: Body color; `undef` inherits the caller's color.
  - `slot_mode`: Emit only the shared mounting cutters.
  - `anchor`: Original plate-envelope anchor; `undef` retains the holder row at Y=0.
  - `rear_suspension_mount_slide_l`: Suspension mount separation along native +Y.
  - `layout`: Resolved rear layout shared with components and cutters.
  - `show_rear_suspension_mount`: Display the separate suspension mount.
  - `front_joint`: Include the tongue for direct connection to the front frame.
  **Behavior:** The front joining edge remains at `min_y`. Its male tongue
  projects toward -Y into the front frame's existing socket; the anchor envelope
  excludes that projection and the assembled chassis length stays unchanged.
 */
module rear_chassis_frame(debug=false,
                          debug_font="Gill Sans:style=Bold",
                          debug_color=green_2,
                          color=white_smoke_1,
                          slot_mode=false,
                          anchor=undef,
                          rear_suspension_joint_spacing=rear_suspension_joint_spacing,
                          layout=rear_chassis_layout(),
                          show_rear_suspension_mount=false,
                          front_joint=true) {
  pts = rear_chassis_outline_points(layout);
  size = plist_get("size", layout);
  joint_y = rear_suspension_joint_y_bounds(layout);
  join_w = plist_get("join_w", layout);
  min_y = plist_get("min_y", layout);
  center_y = (plist_get("min_y", layout) + plist_get("max_y", layout)) / 2;

  with_anchor(is_undef(anchor) ? [0, 0, 1] : anchor, size, centered=true) {
    translate([0, is_undef(anchor) ? 0 : -center_y, 0]) {
      if (slot_mode) {
        rear_chassis_slots(layout=layout);
        if (front_joint) {
          translate([0, min_y, 0]) {
            front_chassis_body_joint(mode="male", w=join_w, slot_mode=true);
          }
        }
      } else {
        maybe_color(color) {
          difference() {
            union() {
              if (front_joint) {
                translate([0, min_y, 0]) {
                  front_chassis_body_joint(mode="male", w=join_w);
                }
              }

              linear_extrude(height=chassis_thickness, convexity=3) {
                rear_chassis_outline(layout);
              }
              translate([0, joint_y[1], 0]) {
                rear_suspension_chassis_joint(anchor=[0, -1, 1],
                                              layout=layout,
                                              mode="male");
              }
            }

            translate([0, joint_y[1], 0]) {
              rear_suspension_chassis_joint(anchor=[0, -1, 1],
                                            layout=layout,
                                            mode="male",
                                            slot_mode=true);
            }

            rear_chassis_slots(layout=layout);
            if (front_joint) {
              translate([0, min_y, 0]) {
                front_chassis_body_joint(mode="male", w=join_w, slot_mode=true);
              }
            }
          }
        }
      }

      if (show_rear_suspension_mount) {
        translate([0, rear_suspension_joint_spacing, 0]) {
          rear_suspension_mount(layout=layout);
        }
      }
      if (debug && !slot_mode) {
        translate([0,
                   0,
                   chassis_thickness + front_chassis_joint_boolean_overlap]) {
          mirror_copy([1, 0, 0]) {
            debug_polygon_text(pts,
                               circle_color="red",
                               font_size=constraint(size[0] * 0.07, 1, 5),
                               font=debug_font,
                               color=debug_color);
          }
        }
      }
    }
  }
}

rear_chassis_frame(debug=true, show_rear_suspension_mount=false);
