/**
 * Module: A dummy mockup of the pan servo.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

use <servo.scad>

function pan_servo_full_height() =
  servo_full_height(pan_servo_size[2],
                    pan_servo_gearbox_h,
                    pan_servo_gearbox_size);

function pan_servo_height_after_hat() =
  servo_height_after_hat(h=pan_servo_size[2],
                         z_offst=pan_screws_hat_z_offset,
                         hat_thickness=pan_servo_hat_thickness);

function pan_servo_height_before_hat() =
  servo_height_before_hat(h=pan_servo_size[2],
                          z_offst=pan_screws_hat_z_offset,
                          hat_thickness=pan_servo_hat_thickness);

function pan_servo_gear_height() =
  servo_gear_total_height(pan_servo_gearbox_size);

function pan_servo_gear_x_center() =
  pan_servo_size[0] / 2 - pan_servo_gearbox_d1 / 2;

module pan_servo(center=false, servo_color=pan_servo_color, alpha=1) {
  servo(size=[pan_servo_size[0],
              pan_servo_size[1],
              pan_servo_size[2]],
        screws_dia=head_neck_tilt_servo_screw_dia,
        servo_hat_w=pan_servo_hat_w,
        center=center,
        servo_hat_h=pan_servo_hat_h,
        servo_hat_thickness=pan_servo_hat_thickness,
        screws_offset=pan_servo_screws_offset,
        screws_hat_z_offset=pan_screws_hat_z_offset,
        alpha=alpha,
        servo_color=servo_color,
        gearbox_box_color=pan_servo_color,
        servo_text=pan_servo_text,
        text_size=pan_servo_text_size,
        tolerance=0.3,
        cutted_len=pan_servo_cutted_len,
        gearbox_h=pan_servo_gearbox_h,
        gearbox_d1=pan_servo_gearbox_d1,
        gearbox_d2=pan_servo_gearbox_d2,
        gearbox_x_offset=pan_servo_gearbox_x_offset,
        gearbox_mode=pan_servo_gearbox_mode,
        servo_horn_rotation=0,
        gearbox_gear_size=pan_servo_gearbox_size) {
    children();
  }
}

pan_servo(center=false);

translate([pan_servo_gear_x_center(), 0, 0]) {

  cube([2, 2, 2], center=true);
}
