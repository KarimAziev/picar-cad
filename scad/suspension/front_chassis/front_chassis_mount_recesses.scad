/**
  * Module: Lowered suspension and steering mounting surfaces.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <layout_params.scad>

use <../../lib/shapes2d.scad>
use <../bellcrank_steering_slots.scad>
use <../steering_servo_bracket/steering_servo_bracket_assembly.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_mount_recesses
  ─────────────────────────────────────────────────────────────────────────────
  Cut the common suspension, bellcrank, servo and encoder mounting plane.
  **Behavior:** Coordinates match the assembled front chassis. The compact
  joint's central pin spine remains full thickness. Servo pockets follow the
  lower hardware envelope, including both brackets and the encoder foot.
 */
module front_chassis_mount_recesses() {
  depth = suspension_chassis_mount_recess;
  gap = suspension_chassis_mount_clearance;
  cutter_half_w = front_chassis_required_width() / 2 + gap;
  pin_wall = 1.25;
  spine_w = front_chassis_joint_pin_spacing
            + front_chassis_joint_pin_d + 2 * pin_wall;
  spine_start_y = y_front_chassis_rear_frame_joint_1_start - joint_l - spine_w;
  pin_end_y = y_front_chassis_rear_frame_joint_1_start - joint_l / 2
              + front_chassis_joint_pin_l / 2 + front_chassis_joint_pin_end_clearance;
  // Keep the full spine width over the blind pin ends before the round tip.
  spine_end_y = pin_end_y + pin_wall + spine_w / 2;
  // Local servo X spans the case, mounting brackets and encoder support.
  servo_clip_half_w = servo_chassis_reach + dsservo_size[2]
                      + steering_servo_bracket_thickness;
  assert(depth >= 0 && suspension_chassis_mount_h
         - max(front_bulkhead_mount_bolt_bore_h,
               front_chassis_bellcrank_bolt_bore_h,
               steering_servo_mount_bolt_bore_h) >= 1.5,
         "Mount recesses need 1.5 mm above their screw-head seats");
  if (depth > 0) {
    translate([0, 0, suspension_chassis_mount_h]) {
      linear_extrude(height=depth + 0.02) {
        difference() {
          translate([-cutter_half_w,
                     -bellcrank_y_distance_from_bulkhead
                     - bellcrank_mount_r - gap]) {
            square([2 * cutter_half_w, front_chassis_mount_end_y
                         + bellcrank_y_distance_from_bulkhead
                         + bellcrank_mount_r + gap]);
          }
          translate([-spine_w / 2, spine_start_y]) {
            rounded_rect([spine_w, spine_end_y - spine_start_y],
                         center=false,
                         r_factor=0.5);
          }
        }
        translate([0, -bellcrank_y_distance_from_bulkhead]) {
          bellcrank_steering_with_servo_position() {
            offset(delta=gap) {
              projection() {
                intersection() {
                  steering_servo_bracket_assembly(show_servo_bolt=false,
                                                  show_chassis_bolt=false,
                                                  show_chassis_bolt_nut=false,
                                                  show_servo_bolt_nut=false);
                  translate([-servo_clip_half_w,
                             -dsservo_flange_w - 0.5, -0.01]) {
                    cube([2 * servo_clip_half_w, dsservo_flange_w + 1,
                          depth + gap + 0.01]);
                  }
                }
              }
            }
          }
        }
      }
    }
    // The servo case rim extends below the bracket mounting feet.
    translate([0,
               -bellcrank_y_distance_from_bulkhead,
               suspension_chassis_mount_h - 0.25]) {
      bellcrank_steering_with_servo_position() {
        linear_extrude(height=depth + 0.27) {
          offset(delta=gap + 0.01) {
            projection() {
              intersection() {
                steering_servo_bracket_assembly(show_servo_bolt=false,
                                                show_chassis_bolt=false,
                                                show_chassis_bolt_nut=false,
                                                show_servo_bolt_nut=false);
                translate([-servo_clip_half_w,
                           -dsservo_flange_w - 0.5, -0.25]) {
                  cube([2 * servo_clip_half_w, dsservo_flange_w + 1, 0.249]);
                }
              }
            }
          }
        }
      }
    }
  }
}

front_chassis_mount_recesses();
