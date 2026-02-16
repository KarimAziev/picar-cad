/**
 * Module: A dummy mockup of the DSSERVO DS3218MG.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>
include <../steering_params.scad>

use <../lib/debug.scad>
use <bolt.scad>
use <servo.scad>
use <servo_arm.scad>
use <tie_rod_end.scad>
use <tie_rod_shaft.scad>

function dsservo_full_height() =
  servo_full_height(dsservo_size[2],
                    dsservo_gearbox_h,
                    dsservo_gearbox_size);

function dsservo_height_after_hat() =
  servo_height_after_hat(h=dsservo_size[2],
                         z_offst=steering_bolts_hat_z_offset,
                         hat_thickness=dsservo_hat_thickness);

function dsservo_height_before_hat() =
  servo_height_before_hat(h=dsservo_size[2],
                          z_offst=steering_bolts_hat_z_offset,
                          hat_thickness=dsservo_hat_thickness);

function dsservo_gear_height() =
  servo_gear_total_height(dsservo_gearbox_size);

module servo_tie_rod_end(direction="bottom") {
  tie_rod_end(eye_od=steering_servo_tie_rod_eye_od,
              eye_h=steering_servo_tie_rod_eye_h,
              shank_od=steering_servo_tie_rod_shank_od,
              shank_bolt_d=steering_servo_tie_rod_shank_bolt_d,
              shank_len=steering_servo_tie_rod_shank_len,
              neck_len=steering_servo_tie_rod_neck_len,
              bushing_od=steering_servo_tie_rod_bushing_od,
              bushing_d=steering_servo_tie_rod_bushing_d,
              bushing_h=steering_servo_tie_rod_bushing_h,
              bushing_flat_d=steering_servo_tie_rod_bushing_flat_d,
              neck_h=steering_servo_tie_rod_neck_h,
              bushing_color=steering_servo_tie_rod_bushing_color,
              show_eye_bolt=false,
              eye_bolt_through_h=1,
              eye_bolt_h=20,
              center_z=true,
              direction=direction,
              color=steering_servo_tie_rod_color);
}

module servo_tie_rod() {
  nut_h = find_nut_prop(prop="height",
                        inner_d=steering_servo_tie_rod_shank_bolt_d,
                        lock=false);
  translate([0, -steering_servo_tie_rod_eye_od / 2, 0]) {
    servo_tie_rod_end();
  }

  translate([0, -steering_servo_tie_rod_eye_od, 0]) {
    translate([0,
               -steering_servo_tie_rod_shank_len
               + steering_servo_tie_rod_thread_len
               - nut_h,
               0]) {

      translate([0,
                 -steering_servo_tie_rod_eye_od / 2
                 - steering_servo_tie_rod_shank_len
                 - steering_servo_tie_rod_body_len
                 - steering_servo_tie_rod_thread_len * 2
                 + steering_servo_tie_rod_thread_len - nut_h,
                 0]) {
        rotate([0, 90, 0]) {
          servo_tie_rod_end(direction="top");
        }
      }

      rotate([90, 0, 0]) {
        tie_rod_shaft(body_len=steering_servo_tie_rod_body_len,
                      body_d=steering_servo_tie_rod_body_d,
                      body_end_len=steering_servo_tie_rod_body_end_len,
                      thread_len=steering_servo_tie_rod_thread_len,
                      thread_d=steering_servo_tie_rod_thread_d,
                      fn=steering_servo_tie_rod_fn,
                      color=steering_servo_tie_rod_color);
      }
    }
  }
}

module dsservo(center=false,
               servo_color=dsservo_color,
               alpha=1,
               show_servo_horn=true,
               show_servo_horn_screws,
               show_servo_horn_bolt,
               servo_horn_single,
               show_tie_rod=true,
               servo_horn_screw_side) {
  servo(size=[dsservo_size[0],
              dsservo_size[1],
              dsservo_size[2]],
        bolts_dia=dsservo_bolt_dia,
        bolt_spacing=dsservo_bolt_spacing,
        servo_hat_w=dsservo_hat_w,
        center=center,
        servo_hat_h=dsservo_hat_h,
        servo_hat_thickness=dsservo_hat_thickness,
        center_hat_z=false,
        bolts_offset=dsservo_bolts_offset,
        bolts_hat_z_offset=dsservo_hat_z_offset,
        servo_color=servo_color,
        alpha=alpha,
        gearbox_box_color=servo_color,
        servo_text=dsservo_text,
        text_size=dsservo_text_size,
        tolerance=0.3,
        cut_len=dsservo_cut_len,
        gearbox_h=dsservo_gearbox_h,
        gearbox_d1=dsservo_gearbox_d1,
        servo_horn_rotation=$t * ($t > 0.5 ? -90 : 45),
        gearbox_d2=dsservo_gearbox_d2,
        gearbox_x_offset=dsservo_gearbox_x_offset,
        show_servo_horn=false,
        gearbox_mode=dsservo_gearbox_mode,
        gearbox_gear_size=dsservo_gearbox_size,
        show_servo_horn_screws=show_servo_horn_screws,
        cut_len_top_len=dsservo_cut_len_top,
        cut_len_top_depth=dsservo_cut_top_depth,
        show_servo_horn_bolt=show_servo_horn_bolt,
        servo_horn_single=servo_horn_single,
        servo_horn_screw_side=servo_horn_screw_side) {
    if (show_servo_horn) {
      rotate([0, 0, 180]) {
        servo_arm(arm_d=steering_servo_arm_d,
                  arm_len=steering_servo_arm_len,
                  arm_base_h=steering_servo_arm_base_h,
                  arm_bolt_boss_h=steering_servo_arm_bolt_boss_h,
                  arm_bolt_boss_w=steering_servo_arm_bolt_boss_w,
                  arm_bolt_boss_spacing=steering_servo_arm_bolt_boss_spacing,
                  arm_bolt_boss_padding=steering_servo_arm_bolt_boss_padding,
                  arm_thickness=steering_servo_arm_thickness,
                  arm_w=steering_servo_arm_w,
                  bolt_d=steering_servo_arm_bolt_d,
                  boss_inner_padding=steering_servo_arm_bolt_boss_inner_padding,
                  arm_center_bolt_d=steering_servo_arm_center_bolt_d,
                  arm_center_bolt_bore_d=steering_servo_arm_center_bolt_bore_d,
                  arm_center_bolt_bore_h=steering_servo_arm_center_bolt_bore_h);
      }
      if (show_tie_rod) {
        translate([-steering_servo_tie_rod_eye_od / 2 ,
                   -steering_servo_arm_d / 2
                   - steering_servo_arm_len
                   + steering_servo_tie_rod_eye_od / 2,
                   - steering_servo_arm_bolt_boss_h / 2]) {
          rotate([0, 0, 90]) {
            servo_tie_rod();
          }
        }
      }
    }
  }
}

dsservo(center=true);

// servo_tie_rod();