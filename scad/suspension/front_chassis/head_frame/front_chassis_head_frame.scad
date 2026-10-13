/**
  * Module: Removable head mount of the front chassis.
  *
  * The removable head carries the pan-axis and bumper mounts.
  * The bulkhead and bellcrank section carries the matching head socket and
  * the rear joint for the steering-servo frame.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../../colors.scad>
include <../../../parameters.scad>
include <../../../rc_params.scad>
include <../computed_params.scad>

use <../../../lib/plist.scad>
use <../../../lib/transforms.scad>
use <../front_chassis_access_slots.scad>
use <../front_frame_util.scad>
use <head_joint.scad>
use <head_slots.scad>

show_head_frame_access_slots = true;

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_frame
  ─────────────────────────────────────────────────────────────────────────────
  Build the removable head mounting and bumper plate.
  **Parameters:**
  - `debug`: Show outline labels within this part.
  - `show_access_slots`: Include the side and front cable openings.
  - `color`: Body color; undef inherits the caller's color.
  - `split`: Provide the detachable head joint; false makes a continuous boundary.
  **Behavior:** Native coordinates align with the bulkhead frame. The detachable
  joint has a central tab and two longitudinal side-rail pins with 3.1 mm
  sag-compensated passages.
 */
module front_chassis_head_frame(debug=false,
                                show_access_slots=show_head_frame_access_slots,
                                color=white_smoke_1,
                                split=split_head_chassis) {
  p = front_chassis_head_joint_params();
  bounds = front_chassis_front_frame_bounds();
  eps = front_chassis_joint_boolean_overlap;
  // Outline labels extend beyond the solid's bounding box.
  clip_pad = debug ? norm(bounds[1] - bounds[0]) : eps;
  split_y = plist_get("root_y", p) + (split ? eps / 2 : -eps);
  maybe_color(color) {
    difference() {
      union() {
        intersection() {
          front_chassis_front_frame_unsplit(debug=debug,
                                            show_access_slots=show_access_slots,
                                            color=undef);
          union() {
            // Stay off the outline vertex plane to avoid zero-thickness slivers.
            // The tongue's root overlap still reaches this head body.
            translate([bounds[0][0] - clip_pad, split_y, -clip_pad]) {
              cube([bounds[1][0] - bounds[0][0] + 2 * clip_pad,
                    bounds[1][1] - split_y + clip_pad,
                    chassis_thickness + 2 * clip_pad]);
            }
            if (split) {
              translate([-plist_get("tab_w", p) / 2,
                         plist_get("tab_end_y", p),
                         -clip_pad]) {
                cube([plist_get("tab_w", p),
                      plist_get("root_y", p) - plist_get("tab_end_y", p) + eps,
                      chassis_thickness + 2 * clip_pad]);
              }
            }
          }
        }
        if (split) {
          front_chassis_head_joint(mode="male");
        }
      }
      if (split) {
        front_chassis_head_joint(mode="male", slot_mode=true);
      }
      translate([0, front_chassis_head_center_y(), 0]) {
        front_chassis_head_slots();
      }
      if (show_access_slots) {
        front_chassis_access_slots(front_chassis_head_center_y());
      }
    }
  }
}

front_chassis_head_frame();
