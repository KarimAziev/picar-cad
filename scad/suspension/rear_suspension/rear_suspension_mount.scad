/**
  * Module: Rear-suspension mounting plate with a chassis joint
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../steering_params.scad>
include <../rear_chassis/computed_params.scad>
include <../rear_chassis/rear_chassis_params.scad>

use <../../components/plate_joint/plate_joint.scad>
use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/polygon_util.scad>
use <../../lib/shapes2d.scad>
use <../../lib/transforms.scad>
use <../rear_chassis/rear_chassis_slots.scad>
use <rear_suspension_joint.scad>
use <rear_suspension_slots.scad>
use <util.scad>

module rear_suspension_mount_outline(layout=rear_chassis_layout()) {
  pts = rear_suspension_outline(layout);
  half_w = plist_get("suspension_w", layout) / 2;

  r = rear_suspension_chassis_corner_r;

  min_y = polygon_min_y(pts);

  union() {

    mirror_copy([1, 0, 0]) {
      offset_vertices_2d(r=r) {
        polygon(pts);
      }
      // remove roundness for joint
      translate([-half_w + r / 2, min_y + r / 2, 0]) {
        square([r, r], center=true);
      }
    }
  }
}

module rear_suspension_mount(layout=rear_chassis_layout(),
                             debug=false,
                             debug_font="Gill Sans:style=Bold",
                             debug_color=green_2,
                             color=white_smoke_1,
                             joint_color=light_grey,
                             slot_mode=false) {
  pts = rear_suspension_outline(layout);
  size = plist_get("size", layout);
  min_y = polygon_min_y(pts);

  if (slot_mode) {
    rear_chassis_slots(layout=layout);
  } else {
    difference() {
      union() {
        maybe_color(color) {
          linear_extrude(height=chassis_thickness) {
            rear_suspension_mount_outline(layout);
          }
        }
        translate([0, min_y, 0]) {
          rear_suspension_chassis_joint(anchor=[0, -1, 1],
                                        layout=layout,
                                        mode="female",
                                        color=joint_color);
        }
      }
      rear_suspension_mount_slots(layout=layout);

      translate([0, min_y, 0]) {
        rear_suspension_chassis_joint(anchor=[0, -1, 1],
                                      layout=layout,
                                      mode="female",
                                      slot_mode=true);
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
                           font_size=constraint(size[0] * 0.08, 1, 5),
                           font=debug_font,
                           color=debug_color);
      }
    }
  }
}
rear_suspension_mount();
