/**
 * Module: head_neck - Dual Servo Neck Bracket for Robot Head
 *
 * Defines a modular neck bracket assembly that enables Pan and Tilt movement
 * for a robot’s head using two servo motors (a pan servo and a tilt servo).
 *
 * The bracket is compatible with the robot head designed for dual Raspberry Pi Camera
 * Module 3 units and allows integration of the robot head via the tilt servo mount.
 *
 * Conceptually, this bracket combines:
 * - A pan servo on the horizontal base that rotates the entire structure horizontally.
 * - A tilt servo on the vertical plate that allows the attached head to tilt vertically.
 * - Optional mounts for visualizing servo and head placement in the 3D model.
 *
 * Structure:
 * ----------
 * This assembly is implemented using an L-shaped bracket (from `l_bracket.scad`)
 * as the foundational geometry, with servo slot cutouts and optionally mounted servo models.
 * The robot head (from `head_mount.scad`) can also be visualized to confirm fitment.
 *
 * Features:
 * ---------
 * - Automatically sizes the bracket to fit both pan and tilt servo components.
 * - Allows toggling visualization of tilt servo, pan servo, and head.
 * - Designed with wiring clearance and geometric offsets for hat components and bolts.
 *
 * Parameters:
 * -----------
 * @param show_tilt_servo   Boolean - Whether to render the tilt servo model in 3D.
 * @param show_head         Boolean - Whether to render the robot head on the neck mount.
 * @param show_pan_servo    Boolean - Whether to render the pan servo model in 3D.
 * @param bracket_color     Color value - Color used for rendering the neck bracket.
 * @param head_color        Color value - Color used for rendering the robot head.
 * @param show_ir_case      Boolean - Whether to render the case for IR LED
 * @param show_ir_led       Boolean - Whether to render the IR LED if show_ir_case is also enabled.
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/l_bracket.scad>
use <../placeholders/pan_servo.scad>
use <../placeholders/servo.scad>
use <../placeholders/tilt_servo.scad>
use <head_mount.scad>

pan_servo_rotation  = 0; // [-179:179]
tilt_servo_rotation = 0; // [-90:90]

function head_neck_full_w(base_width=max(head_neck_pan_servo_slot_width,
                                         head_neck_tilt_servo_slot_width),
                          bolts_dia=max(head_neck_pan_servo_bolt_dia,
                                        head_neck_tilt_servo_bolt_dia),
                          bolts_offset=max(head_neck_pan_servo_bolts_offset,
                                           head_neck_tilt_servo_bolts_offset),
                          extra_w=max(head_neck_pan_servo_extra_w,
                                      head_neck_tilt_servo_extra_w)) =
  base_width + (bolts_offset * 2 + bolts_dia * 2) + extra_w;

function head_neck_full_pan_panel_h() =
  let (nominal_h = head_neck_pan_servo_slot_height
       + head_neck_tilt_servo_slot_thickness / 2,
       diff = (head_plate_width / 2 + head_plate_thickness) - nominal_h)
  nominal_h + diff + head_plate_thickness * 2;

function head_neck_full_tilt_panel_h() =
  head_neck_tilt_servo_slot_height
  + head_neck_pan_servo_slot_thickness
  + pan_servo_height_after_hat()
  + head_neck_tilt_servo_extra_lower_h
  + head_neck_tilt_servo_extra_top_h;

module head_neck_base(show_tilt_servo=false,
                      show_head=false,
                      show_camera=true,
                      show_pan_servo=false,
                      show_ir_case=false,
                      show_ir_led=true,
                      show_servo_horn=true,
                      tilt_servo_rotation=tilt_servo_rotation,
                      pan_servo_rotation=pan_servo_rotation,
                      bracket_color=matte_black,
                      head_color="white") {
  pan_servo_h = pan_servo_size[2];
  full_pan_h = head_neck_full_pan_panel_h();
  full_tilt_h = head_neck_full_tilt_panel_h();
  full_w = head_neck_full_w();
  pan_rad = min(min(full_w, full_pan_h) * 0.2, 3);
  tilt_rad = min(min(full_w, full_tilt_h) * 0.2, 3);

  half_of_tilt_h = full_tilt_h / 2;

  tilt_servo_y = half_of_tilt_h
    - head_neck_tilt_servo_slot_height / 2
    - head_neck_tilt_servo_extra_top_h;

  l_bracket(size=[full_w,
                  full_pan_h,
                  full_tilt_h],
            bracket_color=bracket_color,
            vertical_thickness=head_neck_tilt_servo_slot_thickness,
            thickness=head_neck_pan_servo_slot_thickness,
            children_modes=[["difference", "horizontal"],
                            ["union", "horizontal"],
                            ["difference", "vertical"],
                            ["union", "vertical"]],
                            center=false,
            y_r=pan_rad,
            z_r=tilt_rad) {
    servo_slot_2d(size=[head_neck_pan_servo_slot_width,
                        head_neck_pan_servo_slot_height],
                  bolts_dia=head_neck_pan_servo_bolt_dia,
                  bolts_offset=head_neck_pan_servo_bolts_offset);
    reverse_rotation = head_neck_pan_servo_assembly_reversed ? 180 : 0;
    rotate([reverse_rotation,
            reverse_rotation, 0]) {
      translate([pan_servo_size[0] / 2,
                 -pan_servo_size[1] / 2 ,
                 pan_servo_h
                 + head_neck_pan_servo_slot_thickness / 2
                 - pan_bolts_hat_z_offset
                 + pan_servo_hat_thickness / 2]) {
        if (show_pan_servo) {
          rotate([0, 0, 0]) {
            rotate([0, 180, 0]) {
              pan_servo(show_servo_horn=show_servo_horn,
                        servo_horn_rotation=pan_servo_rotation);
            }
          }
        }
      }
    }

    translate([0, tilt_servo_y, 0]) {
      servo_slot_2d(size=[head_neck_tilt_servo_slot_width,
                          head_neck_tilt_servo_slot_height],
                    bolts_dia=head_neck_tilt_servo_bolt_dia,
                    bolts_offset=head_neck_tilt_servo_bolts_offset,
                    center=true);
    }

    translate([0,
               tilt_servo_y,
               -tilt_servo_size[2]
               - head_neck_tilt_servo_slot_thickness
               + tilt_bolts_hat_z_offset
               + tilt_servo_hat_thickness / 2]) {

      if (show_tilt_servo || show_head) {

        tilt_servo(center=true,
                   show_servo_horn=false,
                   alpha=show_tilt_servo ? 1 : 0) {
          if (show_head) {
            head_centers = side_panel_servo_center();

            rotate([0, 0, tilt_servo_rotation]) {
              translate([-head_centers[0],
                         -head_centers[1] / 2,
                         -head_plate_width / 2]) {
                rotate([0, 90, 0]) {
                  head_mount(head_color=head_color,
                             show_ir_case=show_ir_case,
                             show_servo_horn=show_servo_horn,
                             show_camera=show_camera,
                             show_ir_led=show_ir_led);
                }
              }
            }
          }
        }
      }
    }
  }
}

module head_neck(center_pan_servo_slot=false,
                 show_tilt_servo=true,
                 show_head=true,
                 show_camera=true,
                 show_pan_servo=true,
                 show_ir_case=false,
                 show_ir_led=true,
                 show_servo_horn=true,
                 bracket_color=matte_black,
                 tilt_servo_rotation=tilt_servo_rotation,
                 pan_servo_rotation=pan_servo_rotation,
                 head_color="white") {

  module head_neck_mod() {
    head_neck_base(show_tilt_servo=show_tilt_servo,
                   show_head=show_head,
                   show_camera=show_camera,
                   show_pan_servo=show_pan_servo,
                   show_ir_case=show_ir_case,
                   show_ir_led=show_ir_led,
                   show_servo_horn=show_servo_horn,
                   bracket_color=bracket_color,
                   head_color=head_color,
                   pan_servo_rotation=pan_servo_rotation,
                   tilt_servo_rotation=tilt_servo_rotation);
  }

  if (!center_pan_servo_slot) {
    head_neck_mod();
  } else {
    head_x = -head_neck_full_pan_panel_h() / 2
      - head_neck_tilt_servo_slot_thickness / 2;

    head_full_w = head_neck_full_w();
    slot_w = (head_full_w - pan_servo_size[0]) / 2;

    extra_head_y = head_neck_pan_servo_assembly_reversed
      ? -pan_servo_gearbox_d1 - pan_servo_gearbox_d2
      : -pan_servo_gearbox_d1 / 2;

    head_y =
      + head_full_w - slot_w + extra_head_y;

    gear_h = pan_servo_gear_height();
    h_before_hat = pan_servo_height_before_hat();
    head_z = pan_servo_gearbox_h + (h_before_hat - head_neck_pan_servo_slot_thickness)
      + gear_h + (servo_horn_ring_height - servo_horn_arm_z_offset);

    rotate([0, 0, pan_servo_rotation]) {
      translate([head_x,
                 head_y,
                 head_z]) {
        rotate([0, 0, -90]) {
          head_neck_mod();
        }
      }
    }
  }
}

head_neck(center_pan_servo_slot=true,
          show_tilt_servo=true,
          show_head=true,
          show_camera=true,
          show_pan_servo=true,
          show_ir_case=false,
          show_ir_led=true,
          bracket_color="white");
