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
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>

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
  front_chassis_head_ribbon_slot_ys
  ─────────────────────────────────────────────────────────────────────────────
  Locate every slot in the head-side ribbon threading bank, nearest first.
  **Parameters:**
  - `rows`: Number of separate ribbon openings; at least three for threading.
  - `slot_l`: Slot dimension along the chassis Y axis.
  - `gap`: Solid strip width between adjacent openings.
  **Returns:** Y centers relative to the pan axis, behind the head base.
 */
function front_chassis_head_ribbon_slot_ys(rows=front_chassis_head_ribbon_slot_rows,
                                           slot_l=front_chassis_head_ribbon_slot_l,
                                           gap=front_chassis_head_ribbon_slot_gap) =
  assert(rows >= 3 && rows == floor(rows),
         "Ribbon threading requires at least three slots")
  assert(slot_l > 0 && gap > 0)
  let (first_y = -front_chassis_head_mount_size()[1] / 2
       - front_chassis_head_wire_land - slot_l / 2)
  [for (row = [0:rows - 1]) first_y - row * (slot_l + gap)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_rear_reach
  ─────────────────────────────────────────────────────────────────────────────

  Bound the ribbon bank and its rear material land from the pan axis.

  **Returns:**
  - Positive distance to the rear edge of the ribbon bank's supporting land.
 */
function front_chassis_head_rear_reach() =
  let (ys = front_chassis_head_ribbon_slot_ys())
  -ys[len(ys) - 1] + front_chassis_head_ribbon_slot_l / 2
  + front_chassis_head_wire_land;

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_ribbon_slots
  ─────────────────────────────────────────────────────────────────────────────
  Cut the separate head-side slots used to thread and retain the camera ribbon.
  **Parameters:**
  - `thickness`: Frame thickness crossed by every slot.
  - `anchor`: Anchor on the head mounting-pad envelope, matching the horn slots.
  **Notes:** Defaults preserve the old chassis's three 20 × 3 mm openings and
  two 3 mm strips. These are functional ribbon-routing features, not vents.
 */
module front_chassis_head_ribbon_slots(thickness=front_chassis_thickness,
                                       anchor=[0, 0, 1]) {
  size = front_chassis_head_mount_size();
  eps = front_chassis_joint_boolean_overlap;
  with_anchor(anchor, [size[0], size[1], thickness], centered=true) {
    for (y = front_chassis_head_ribbon_slot_ys()) {
      translate([0, y, -eps]) {
        rect_slot(size=[front_chassis_head_ribbon_slot_w, front_chassis_head_ribbon_slot_l],
                  h=thickness + eps * 2,
                  autoscale_step=0,
                  center=true,
                  r=0);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_slots
  ─────────────────────────────────────────────────────────────────────────────

  Build the head mounting cuts and the three-slot ribbon threading bank.

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

  cols_params = calc_cols_params(gap=chassis_pan_servo_screws_gap,
                                 cols=x_screw_cols,
                                 w=chassis_pan_servo_screw_d);
  rows_params = calc_cols_params(gap=chassis_pan_servo_screws_gap,
                                 cols=y_screw_rows,
                                 w=chassis_pan_servo_screw_d);

  total_x = cols_params[1];
  total_y = rows_params[1];

  recess_w = total_x * 2 + slot_r * 2 + chassis_pan_servo_screw_d
    + chassis_pan_servo_screws_gap;
  recess_l = total_y * 2 + slot_r * 2 + chassis_pan_servo_screw_d
    + chassis_pan_servo_screws_gap;

  with_anchor(anchor=anchor,
              size=[size[0], size[1], thickness],
              centered=true) {
    union() {
      translate([0, 0, thickness - recess_h]) {
        linear_extrude(height=recess_h + eps, center=false) {
          mirror_copy([0, 1, 0]) {
            translate([-chassis_pan_servo_recesess_thickness / 2, 0, 0]) {
              trapezoid_rounded_top(b=chassis_pan_servo_slot_dia,
                                    t=chassis_pan_servo_recesess_thickness,
                                    h=recess_w / 2,
                                    center=false,
                                    r_factor=0.5);
            }
          }
          rotate([0, 0, 90]) {
            mirror_copy([0, 1, 0]) {
              translate([-chassis_pan_servo_recesess_thickness / 2, 0, 0]) {
                trapezoid_rounded_top(b=chassis_pan_servo_slot_dia,
                                      t=chassis_pan_servo_recesess_thickness,
                                      h=recess_l / 2,
                                      center=false,
                                      r_factor=0.5);
              }
            }
          }
        }
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

      // The ribbon weaves through separate slots; do not merge their solid strips.
      front_chassis_head_ribbon_slots(thickness=thickness);
    }
  }
}

front_chassis_head_slots();