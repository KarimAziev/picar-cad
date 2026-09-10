/**
  * Module: Front-chassis head mount and slots.
  *
  * Defines the pan-axis mounting pad envelope and the matching servo-horn
  * recess used to attach the rotating head neck to the front frame.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../parameters.scad>
include <../../steering_params.scad>

use <../../head/head_neck.scad>
use <../../lib/functions.scad>
use <../../lib/placement.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_mount_size
  ─────────────────────────────────────────────────────────────────────────────

  Return the mounting-pad envelope derived from the complete head-neck base.

  **Returns:**
  - Mount size as [w, l, h].
 */
function front_chassis_head_mount_size() =
  [max(head_neck_full_pan_panel_h() + head_neck_tilt_servo_slot_thickness,
       front_chassis_head_ribbon_slot_w)
     + front_chassis_head_wire_land * 2,
   head_neck_full_w() + front_chassis_head_mount_padding * 2,
   front_chassis_thickness];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_front_reach
  ─────────────────────────────────────────────────────────────────────────────

  Bound the neutral head's forward projection for bumper service clearance.

  Includes the side-panel depth and a camera envelope measured from the pan
  axis through both servo shaft displacements. This is a packaging envelope,
  not a limit on the head's pan or tilt motion.
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
  front_chassis_head_wire_y
  ─────────────────────────────────────────────────────────────────────────────

  Return cable-slot row centers behind the pan-axis mounting footprint.

  **Returns:**
  - `[ribbon_y, servo_y]`, relative to the pan axis.
 */
function front_chassis_head_wire_y() =
  let (ribbon_y = -front_chassis_head_mount_size()[1] / 2
         - front_chassis_head_wire_land - front_chassis_head_ribbon_slot_l / 2)
  [ribbon_y,
   ribbon_y - front_chassis_head_ribbon_slot_l / 2
     - front_chassis_head_wire_land - front_chassis_head_servo_slot_l / 2];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_slots
  ─────────────────────────────────────────────────────────────────────────────

  Build the anchored through-hole, horn recess, and selectable horn screw rows.

  **Parameters:**
  - thickness: Frame thickness crossed by through-holes.
  - recess_h: Depth of the horn-arm recess from the top face.
  - anchor: Anchor vector for the mount-pad envelope.
 */
module front_chassis_head_slots(thickness=front_chassis_thickness,
                                recess_h=chassis_pan_servo_slot_recess,
                                anchor=[0, 0, 1]) {
  size = front_chassis_head_mount_size();
  eps = front_chassis_joint_boolean_overlap;
  screw_step = chassis_pan_servo_screw_d
    + chassis_pan_servo_screws_gap;
  slot_r = chassis_pan_servo_slot_dia / 2;
  x_screw_cols = round((chassis_pan_servo_recesess_x_len / 2) / screw_step);
  y_screw_rows = round((chassis_pan_servo_recesess_y_len / 2) / screw_step);

  with_anchor(anchor=anchor,
              size=[size[0], size[1], thickness],
              centered=true) {
    union() {
      translate([0, 0, thickness - recess_h]) {
        cuboid([chassis_pan_servo_recesess_x_len,
                chassis_pan_servo_recesess_thickness,
                recess_h + eps],
               anchor=[0, 0, 1],
               r=chassis_pan_servo_recesess_thickness / 2);
        cuboid([chassis_pan_servo_recesess_thickness,
                chassis_pan_servo_recesess_y_len,
                recess_h + eps],
               anchor=[0, 0, 1],
               r=chassis_pan_servo_recesess_thickness / 2);
      }

      translate([0, 0, -eps]) {
        cylinder(d=chassis_pan_servo_slot_dia,
                 h=thickness + eps * 2,
                 $fn=$preview ? 40 : 120);
      }

      mirror_copy([1, 0, 0]) {
        translate([slot_r + chassis_pan_servo_screws_gap, 0, -eps]) {
          columns_children(gap=chassis_pan_servo_screws_gap,
                           cols=x_screw_cols,
                           w=chassis_pan_servo_screw_d) {
            cylinder(d=chassis_pan_servo_screw_d,
                     h=thickness + eps * 2,
                     $fn=$preview ? 24 : 80);
          }
        }
      }

      mirror_copy([0, 1, 0]) {
        translate([0, slot_r + chassis_pan_servo_screws_gap, -eps]) {
          rows_children(gap=chassis_pan_servo_screws_gap,
                        rows=y_screw_rows,
                        w=chassis_pan_servo_screw_d) {
            cylinder(d=chassis_pan_servo_screw_d,
                     h=thickness + eps * 2,
                     $fn=$preview ? 24 : 80);
          }
        }
      }

      // Wide camera ribbon opening and two connector-sized servo passages.
      translate([0, front_chassis_head_wire_y()[0], -eps]) {
        cuboid([front_chassis_head_ribbon_slot_w,
                front_chassis_head_ribbon_slot_l, thickness + eps * 2],
               r=front_chassis_head_ribbon_slot_l / 2);
      }
      for (side = [-1, 1]) {
        translate([side * (front_chassis_head_servo_slot_w
                          + front_chassis_head_wire_land) / 2,
                   front_chassis_head_wire_y()[1], -eps]) {
          cuboid([front_chassis_head_servo_slot_w,
                  front_chassis_head_servo_slot_l, thickness + eps * 2],
                 r=front_chassis_head_servo_slot_l / 2);
        }
      }
    }
  }
}
