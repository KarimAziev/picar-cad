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
use <../../../lib/slots.scad>
use <../../../lib/transforms.scad>
use <../../../lib/trapezoids.scad>

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
  max(head_side_panel_width,
      head_side_panel_width / 2 + camera_thickness
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
  assert(front_chassis_head_transition_l > 0, "Head transition must be positive")
  front_chassis_head_mount_size()[1] / 2 + front_chassis_head_transition_l;

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
  screw_step = front_chassis_head_pan_servo_screw_d
               + front_chassis_head_pan_servo_screws_gap;
  slot_r = front_chassis_head_pan_servo_slot_dia / 2;
  x_screw_cols = round((front_chassis_head_pan_servo_recess_x_len / 2) / screw_step);
  y_screw_rows = round((front_chassis_head_pan_servo_recess_y_len / 2) / screw_step);

  cols_params = calc_cols_params(gap=front_chassis_head_pan_servo_screws_gap,
                                 cols=x_screw_cols,
                                 w=front_chassis_head_pan_servo_screw_d);
  rows_params = calc_cols_params(gap=front_chassis_head_pan_servo_screws_gap,
                                 cols=y_screw_rows,
                                 w=front_chassis_head_pan_servo_screw_d);

  total_x = cols_params[1];
  total_y = rows_params[1];

  recess_w = total_x * 2 + slot_r * 2 + front_chassis_head_pan_servo_screw_d
             + front_chassis_head_pan_servo_screws_gap;
  recess_l = total_y * 2 + slot_r * 2 + front_chassis_head_pan_servo_screw_d
             + front_chassis_head_pan_servo_screws_gap;

  with_anchor(anchor=anchor,
              size=[size[0], size[1], thickness],
              centered=true) {
    union() {
      translate([0, 0, thickness - recess_h]) {
        linear_extrude(height=recess_h + eps, center=false) {
          mirror_copy([0, 1, 0]) {
            translate([-front_chassis_head_pan_servo_recess_thickness / 2,
                       0,
                       0]) {
              trapezoid_rounded_top(b=front_chassis_head_pan_servo_slot_dia,
                                    t=front_chassis_head_pan_servo_recess_thickness,
                                    h=recess_w / 2,
                                    center=false,
                                    r_factor=0.5);
            }
          }
          rotate([0, 0, 90]) {
            mirror_copy([0, 1, 0]) {
              translate([-front_chassis_head_pan_servo_recess_thickness / 2,
                         0,
                         0]) {
                trapezoid_rounded_top(b=front_chassis_head_pan_servo_slot_dia,
                                      t=front_chassis_head_pan_servo_recess_thickness,
                                      h=recess_l / 2,
                                      center=false,
                                      r_factor=0.5);
              }
            }
          }
        }
      }

      translate([0, 0, -eps]) {
        cylinder(d=front_chassis_head_pan_servo_slot_dia,
                 h=thickness + eps * 2,
                 $fn=$preview ? 40 : 120);
      }

      mirror_copy([1, 0, 0]) {
        translate([slot_r + front_chassis_head_pan_servo_screws_gap, 0, -eps]) {
          columns_children(gap=front_chassis_head_pan_servo_screws_gap,
                           cols=x_screw_cols,
                           w=front_chassis_head_pan_servo_screw_d) {
            cylinder(d=front_chassis_head_pan_servo_screw_d,
                     h=thickness + eps * 2,
                     $fn=$preview ? 24 : 80);
          }
        }
      }

      mirror_copy([0, 1, 0]) {
        translate([0, slot_r + front_chassis_head_pan_servo_screws_gap, -eps]) {
          rows_children(gap=front_chassis_head_pan_servo_screws_gap,
                        rows=y_screw_rows,
                        w=front_chassis_head_pan_servo_screw_d) {
            cylinder(d=front_chassis_head_pan_servo_screw_d,
                     h=thickness + eps * 2,
                     $fn=$preview ? 24 : 80);
          }
        }
      }
    }
  }
}

front_chassis_head_slots();