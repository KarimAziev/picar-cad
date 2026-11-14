/**
  * Module: Front-chassis head mount and slots.
  *
  * Defines the pan-axis mounting pad envelope and the matching servo-horn
  * recess used to attach the rotating head neck to the front frame.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../../parameters.scad>
include <../../../rc_params.scad>

use <../../../head/head_neck.scad>
use <../../../lib/functions.scad>
use <../../../lib/placement.scad>
use <../../../lib/shapes3d.scad>
use <../../../lib/transforms.scad>
use <../../../placeholders/servo_horn.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_mount_size
  ─────────────────────────────────────────────────────────────────────────────

  Return the mounting-pad envelope derived from the complete head-neck base.

  **Returns:**
  - Mount size as [w, l, h].
 */
function front_chassis_head_mount_size() =
  [head_neck_full_pan_panel_h() + head_neck_tilt_servo_slot_thickness
   + front_chassis_head_wire_land * 2,
   head_neck_full_w() + front_chassis_head_mount_padding * 2,
   chassis_thickness];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_front_reach
  ─────────────────────────────────────────────────────────────────────────────

  Bound the neutral head's forward projection for packaging inspection.

  Includes the side-panel depth and a camera envelope measured from the pan
  axis through both servo shaft displacements. This is a packaging envelope,
  not a limit on the head's pan or tilt motion or a minimum deck length.
 */
function front_chassis_head_front_reach() =
  max(head_side_panel_depth,
      head_side_panel_depth / 2 + camera_thickness
      + sum([for (item = camera_lens_items) item[2]])
      + abs(pan_servo_size[0] - pan_servo_gearbox_d1) / 2
      + abs(tilt_servo_size[0] - tilt_servo_gearbox_d1) / 2,
      front_chassis_head_mount_size()[1] / 2);

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_rear_reach
  ─────────────────────────────────────────────────────────────────────────────

  Bound the mounting footprint and solid rear transition from the pan axis.

  **Returns:** Positive distance to the rear edge of the head transition.
 */
function front_chassis_head_rear_reach() =
  assert(front_chassis_head_transition_l > 0,
         "Head transition must be positive")
  front_chassis_head_mount_size()[1] / 2 + front_chassis_head_transition_l;

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_servo_cable_slot
  ─────────────────────────────────────────────────────────────────────────────
  Cut a rounded servo-cable opening using the shared head cable settings.
  **Parameters:**
  - `thickness`: Plate thickness crossed by the opening, starting at Z=0.
  - `anchor`: Anchor on the opening's `[width, length, thickness]` envelope.
  **Behavior:** The cutter overlaps both plate faces by the chassis Boolean margin.
 */
module front_chassis_servo_cable_slot(thickness=chassis_thickness,
                                      anchor=[1, 1, 1]) {
  eps = front_chassis_joint_boolean_overlap;
  size = concat(head_servo_cable_slot_size, [thickness]);
  with_anchor(size=size, anchor=anchor) {
    translate([0, 0, -eps]) {
      cuboid([size[0], size[1], thickness + eps * 2],
             r=head_servo_cable_corner_r,
             anchor=[1, 1, 1]);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_slots
  ─────────────────────────────────────────────────────────────────────────────

  Build the pan-axis mounting holes and servo-horn recess.

  **Parameters:**
  - thickness: Frame thickness crossed by through-holes.
  - recess_h: Depth of the horn-arm recess from the top face.
  - anchor: Anchor vector for the mount-pad envelope.
 */
module front_chassis_head_slots(thickness=chassis_thickness,
                                recess_h=front_chassis_head_pan_servo_slot_recess,
                                anchor=[0, 0, 1]) {
  size = front_chassis_head_mount_size();
  eps = front_chassis_joint_boolean_overlap;
  pan_servo_slot_r = front_chassis_head_pan_servo_slot_dia / 2;

  with_anchor(anchor=anchor,
              size=[size[0], size[1], thickness],
              centered=true) {
    union() {
      translate([0, 0, thickness - recess_h]) {
        linear_extrude(height=recess_h + eps, center=false) {
          servo_horn_profile_from_plist(pl=pan_servo_horn_slot_plist,
                                        mode="shape",
                                        clearance=pan_servo_horn_recess_clearance);
        }
      }

      mirror_copy([1, 0, 0]) {
        translate([pan_servo_slot_r + head_servo_cable_slot_offsets[0],
                   -pan_servo_slot_r - head_servo_cable_slot_offsets[1],
                   0]) {
          front_chassis_servo_cable_slot(thickness=thickness,
                                         anchor=[1, -1, 1]);
        }
      }

      translate([0, 0, -eps]) {
        cylinder(d=front_chassis_head_pan_servo_slot_dia,
                 h=thickness + eps * 2,
                 $fn=$preview ? 40 : 120);
      }

      translate([0, 0, -eps]) {
        linear_extrude(height=thickness + eps * 2) {
          servo_horn_profile_from_plist(pl=pan_servo_horn_slot_plist,
                                        mode="holes",
                                        screw_clearance=pan_servo_horn_screw_clearance);
        }
      }
    }
  }
}

front_chassis_head_slots();
