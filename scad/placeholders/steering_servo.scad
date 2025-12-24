/**
 * Module: A dummy mockup of the steering servo.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

use <servo.scad>

function steering_servo_full_height() =
  servo_full_height(steering_servo_size[2],
                    steering_servo_gearbox_h,
                    steering_servo_gearbox_size);

function steering_servo_height_after_hat() =
  servo_height_after_hat(h=steering_servo_size[2],
                         z_offst=steering_bolts_hat_z_offset,
                         hat_thickness=steering_servo_hat_thickness);

function steering_servo_height_before_hat() =
  servo_height_before_hat(h=steering_servo_size[2],
                          z_offst=steering_bolts_hat_z_offset,
                          hat_thickness=steering_servo_hat_thickness);

function steering_servo_gear_height() =
  servo_gear_total_height(steering_servo_gearbox_size);

module steering_servo(center=false, servo_color=steering_servo_color, alpha=1) {
  servo(size=[steering_servo_size[0],
              steering_servo_size[1],
              steering_servo_size[2]],
        bolts_dia=steering_servo_bolt_dia,
        servo_hat_w=steering_servo_hat_w,
        center=center,
        servo_hat_h=steering_servo_hat_h,
        servo_hat_thickness=steering_servo_hat_thickness,
        bolts_offset=steering_servo_bolts_offset,
        bolts_hat_z_offset=steering_bolts_hat_z_offset,
        servo_color=servo_color,
        alpha=alpha,
        gearbox_box_color=servo_color,
        servo_text=steering_servo_text,
        text_size=steering_servo_text_size,
        tolerance=0.3,
        cutted_len=steering_servo_cutted_len,
        gearbox_h=steering_servo_gearbox_h,
        gearbox_d1=steering_servo_gearbox_d1,
        servo_horn_rotation=$t * ($t > 0.5 ? -90 : 45),
        gearbox_d2=steering_servo_gearbox_d2,
        gearbox_x_offset=steering_servo_gearbox_x_offset,
        gearbox_mode=steering_servo_gearbox_mode,
        gearbox_gear_size=steering_servo_gearbox_size) {
    children();
  }
}

steering_servo(center=true);
