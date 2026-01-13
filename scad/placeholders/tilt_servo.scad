/**
 * Module: A dummy mockup of the tilt servo.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <servo.scad>

function tilt_servo_full_height() =
  servo_full_height(tilt_servo_size[2],
                    tilt_servo_gearbox_h,
                    tilt_servo_gearbox_size);

function tilt_servo_height_after_hat() =
  servo_height_after_hat(h=tilt_servo_size[2],
                         z_offst=tilt_bolts_hat_z_offset,
                         hat_thickness=tilt_servo_hat_thickness);

function tilt_servo_height_before_hat() =
  servo_height_before_hat(h=tilt_servo_size[2],
                          z_offst=tilt_bolts_hat_z_offset,
                          hat_thickness=tilt_servo_hat_thickness);

function tilt_servo_gear_height() =
  servo_gear_total_height(tilt_servo_gearbox_size);

module tilt_servo(center=false,
                  servo_color=tilt_servo_color,
                  alpha=1,
                  show_servo_horn=false,
                  show_servo_horn_screws,
                  show_servo_horn_bolt,
                  servo_horn_single,
                  servo_horn_screw_side,
                  rotation_angle) {
  servo(size=[tilt_servo_size[0],
              tilt_servo_size[1],
              tilt_servo_size[2]],
        bolts_dia=head_neck_tilt_servo_bolt_dia,
        servo_hat_w=tilt_servo_hat_w,
        center=center,
        servo_hat_h=tilt_servo_hat_h,
        servo_hat_thickness=tilt_servo_hat_thickness,
        bolts_offset=tilt_servo_bolts_offset,
        bolts_hat_z_offset=tilt_bolts_hat_z_offset,
        servo_color=servo_color,
        gearbox_box_color=servo_color,
        alpha=alpha,
        servo_text=tilt_servo_text,
        text_size=tilt_servo_text_size,
        tolerance=0.3,
        show_servo_horn=show_servo_horn,
        cut_len=tilt_servo_cut_len,
        gearbox_h=tilt_servo_gearbox_h,
        gearbox_d1=tilt_servo_gearbox_d1,
        gearbox_d2=tilt_servo_gearbox_d2,
        gearbox_x_offset=tilt_servo_gearbox_x_offset,
        gearbox_mode=tilt_servo_gearbox_mode,
        servo_horn_rotation=is_undef(rotation_angle) ?
        (($t * ($t > 0.5 ? -90 : 45)) + 45) :
        rotation_angle,
        show_servo_horn_screws=show_servo_horn_screws,
        show_servo_horn_bolt=show_servo_horn_bolt,
        servo_horn_single=servo_horn_single,
        servo_horn_screw_side=servo_horn_screw_side,
        gearbox_gear_size=tilt_servo_gearbox_size) {
    children();
  }
}

tilt_servo(center=true);
