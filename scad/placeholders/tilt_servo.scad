/**
 * Module: A dummy mockup of the tilt servo.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <servo.scad>

function tilt_servo_full_height() =
  servo_full_height(tilt_servo_size[2],
                    tilt_servo_gearbox_h,
                    tilt_servo_gearbox_size);

function tilt_servo_height_after_hat() =
  servo_height_after_hat(h=tilt_servo_size[2],
                         z_offst=tilt_screws_hat_z_offset,
                         hat_thickness=tilt_servo_hat_thickness);

function tilt_servo_height_before_hat() =
  servo_height_before_hat(h=tilt_servo_size[2],
                          z_offst=tilt_screws_hat_z_offset,
                          hat_thickness=tilt_servo_hat_thickness);

function tilt_servo_gear_height() =
  servo_gear_total_height(tilt_servo_gearbox_size);

module tilt_servo(center=false, servo_color=tilt_servo_color, alpha=1) {
  servo(size=[tilt_servo_size[0],
              tilt_servo_size[1],
              tilt_servo_size[2]],
        screws_dia=head_neck_tilt_servo_screw_dia,
        servo_hat_w=tilt_servo_hat_w,
        center=center,
        servo_hat_h=tilt_servo_hat_h,
        servo_hat_thickness=tilt_servo_hat_thickness,
        screws_offset=tilt_servo_screws_offset,
        screws_hat_z_offset=tilt_screws_hat_z_offset,
        servo_color=servo_color,
        gearbox_box_color=servo_color,
        alpha=alpha,
        servo_text=tilt_servo_text,
        text_depth=0.5,
        text_size=tilt_servo_text_size,
        tolerance=0.3,
        cutted_len=tilt_servo_cutted_len,
        gearbox_h=tilt_servo_gearbox_h,
        gearbox_d1=tilt_servo_gearbox_d1,
        gearbox_d2=tilt_servo_gearbox_d2,
        gearbox_x_offset=tilt_servo_gearbox_x_offset,
        gearbox_mode=tilt_servo_gearbox_mode,
        gearbox_gear_size=tilt_servo_gearbox_size) {
    children();
  }
}

tilt_servo(center=true);
