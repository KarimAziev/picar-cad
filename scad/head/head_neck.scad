/**
 * Module: head_neck - Dual Servo Neck Bracket for Robot Head
 *
 * Defines a modular neck bracket assembly that enables Pan and Tilt movement
 * for a robot’s head using two servo motors (a pan servo and a tilt servo).
 *
 * The bracket is compatible with the robot head designed for dual Raspberry Pi Camera
 * Module 2 units and allows integration of the robot head via the tilt servo mount.
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
 * - Designed with wiring clearance and geometric offsets for hat components and screws.
 *
 * Parameters:
 * -----------
 * @param show_tilt_servo   Boolean - Whether to render the tilt servo model in 3D.
 * @param show_head         Boolean - Whether to render the robot head on the neck mount.
 * @param show_pan_servo    Boolean - Whether to render the pan servo model in 3D.
 * @param bracket_color     Color value - Color used for rendering the neck bracket.
 * @param head_color        Color value - Color used for rendering the robot head.
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <head_mount.scad>
use <../util.scad>
use <../l_bracket.scad>
use <../placeholders/servo.scad>
use <../placeholders/pan_servo.scad>
use <../placeholders/tilt_servo.scad>

function head_neck_full_w(base_width=max(head_neck_pan_servo_slot_width,
                                         head_neck_tilt_servo_slot_width),
                          screws_dia=max(head_neck_pan_servo_screw_dia,
                                         head_neck_tilt_servo_screw_dia),
                          screws_offset=max(head_neck_pan_servo_screws_offset,
                                            head_neck_tilt_servo_screws_offset),
                          extra_w=max(head_neck_pan_servo_extra_w,
                                      head_neck_tilt_servo_extra_w)) =
  base_width + (screws_offset * 2 + screws_dia * 2) + extra_w;

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

module head_neck(show_tilt_servo=false,
                 show_head=false,
                 show_pan_servo=false,
                 bracket_color=cobalt_blue_metalic,
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
                  screws_dia=head_neck_pan_servo_screw_dia,
                  screws_offset=head_neck_pan_servo_screws_offset);
    translate([pan_servo_size[0] / 2,
               -pan_servo_size[1] / 2 ,
               pan_servo_h
               + head_neck_pan_servo_slot_thickness / 2
               - pan_screws_hat_z_offset
               + pan_servo_hat_thickness / 2]) {
      if (show_pan_servo) {
        rotate([0, 180, 0]) {
          pan_servo();
        }
      }
    }

    translate([0, tilt_servo_y, 0]) {
      servo_slot_2d(size=[head_neck_tilt_servo_slot_width,
                          head_neck_tilt_servo_slot_height],
                    screws_dia=head_neck_tilt_servo_screw_dia,
                    screws_offset=head_neck_tilt_servo_screws_offset,
                    center=true);
    }

    translate([0,
               tilt_servo_y,
               -tilt_servo_size[2]
               - head_neck_tilt_servo_slot_thickness
               + tilt_screws_hat_z_offset
               + tilt_servo_hat_thickness / 2]) {

      if (show_tilt_servo || show_head) {
        tilt_servo(center=true, alpha=show_tilt_servo ? 1 : 0) {
          if (show_head) {
            head_centers = side_panel_servo_center();

            translate([-head_centers[0],
                       -head_centers[1] / 2,
                       -head_plate_width / 2]) {
              rotate([0, 90, 0]) {
                color(head_color) {
                  head_mount();
                }
              }
            }
          }
        }
      }
    }
  }
}

head_neck(show_tilt_servo=false,
          show_head=false,
          show_pan_servo=false);