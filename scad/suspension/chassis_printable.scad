/**
  * Module: Printable connected chassis groups.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../parameters.scad>
include <../rc_params.scad>
include <front_chassis/computed_params.scad>

use <../lib/plist.scad>
use <computed.scad>
use <front_chassis/head_frame/front_chassis_head_frame.scad>
use <front_chassis/rear_frame/front_chassis_rear_frame.scad>
use <front_chassis/suspension_frame/front_chassis_suspension_frame.scad>
use <rear_chassis/computed_params.scad>
use <rear_chassis/rear_chassis_frame.scad>
use <rear_suspension/rear_suspension_mount.scad>

// Select any section in the desired connected group, numbered front to rear.
chassis_print_section = 1; // [0:Head, 1:Front suspension, 2:Steering servo, 3:Rear deck, 4:Rear suspension]

/**
  ─────────────────────────────────────────────────────────────────────────────
  chassis_group_sections
  ─────────────────────────────────────────────────────────────────────────────
  Find the contiguous printable group containing a section.
  **Parameters:**
  - `section`: Section index, 0 through 4 from front to rear.
  - `splits`: Four booleans; true keeps the corresponding joint detachable.
  **Returns:** Inclusive [first, last] section indices.
 */
function chassis_group_sections(section, splits) =
  assert(section >= 0 && section <= 4 && floor(section) == section,
         "Chassis section must be an integer from 0 through 4")
  assert(len(splits) == 4 && len([for (s = splits) if (is_bool(s)) s]) == 4,
         "Chassis splits must contain four booleans")
  [max(concat([0], [for (i = [0:3]) if (i < section && splits[i]) i + 1])),
   min(concat([4], [for (i = [0:3]) if (i >= section && splits[i]) i]))];

/**
  ─────────────────────────────────────────────────────────────────────────────
  chassis_printable
  ─────────────────────────────────────────────────────────────────────────────
  Emit one connected chassis group with its flat underside at Z=0.
  **Parameters:**
  - `section`: Any section in the desired group, numbered 0 through 4.
  **Behavior:** Uses the four shared split controls in rc_params.scad. Coordinates
  retain the vehicle datums, with +Y toward the head. Hardware is excluded.
 */
module chassis_printable(section=chassis_print_section) {
  splits = [split_head_chassis, split_front_chassis,
            split_rear_chassis, split_rear_suspension];
  group = chassis_group_sections(section, splits);
  width = suspension_chassis_width();
  layout = rear_chassis_layout(min_width=width);
  union() {
    for (i = [group[0]:group[1]]) {
      if (i == 0) {
        front_chassis_head_frame(debug=false);
      } else if (i == 1) {
        front_chassis_suspension_frame(debug=false);
      } else if (i == 2) {
        front_chassis_rear_frame(debug=false, width=width);
      } else {
        translate([0, front_chassis_y_joint_2_end, 0]) {
          rotate([0, 0, 180]) {
            translate([0, -plist_get("min_y", layout), 0]) {
              if (i == 3) {
                rear_chassis_frame(layout=layout);
              } else {
                rear_suspension_mount(layout=layout);
              }
            }
          }
        }
      }
    }
  }
}

chassis_printable();
