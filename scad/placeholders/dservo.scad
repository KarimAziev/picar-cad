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
use <../lib/functions.scad>
use <../suspension/bellcrank/bellcrank_drive.scad>
use <bolt.scad>
use <servo.scad>
use <servo_arm.scad>
use <tie_rod.scad>
use <tie_rod_end.scad>
use <tie_rod_shaft.scad>

function dsservo_full_height() =
  servo_full_height(dsservo_size[2],
                    dsservo_gearbox_h,
                    dsservo_gearbox_size);

function dservo_tie_rod_a_max_h() =
  tie_rod_max_h(eye_od=servo_tie_rod_a_eye_od,
                eye_h=servo_tie_rod_a_eye_h,
                bushing_od=servo_tie_rod_a_bushing_od,
                bushing_d=servo_tie_rod_a_bushing_d,
                bushing_h=servo_tie_rod_a_bushing_h,
                shank_od=servo_tie_rod_a_shank_od);

function dservo_tie_rod_b_max_h() =
  tie_rod_max_h(eye_od=servo_tie_rod_b_eye_od,
                eye_h=servo_tie_rod_b_eye_h,
                bushing_od=servo_tie_rod_b_bushing_od,
                bushing_d=servo_tie_rod_b_bushing_d,
                bushing_h=servo_tie_rod_b_bushing_h,
                shank_od=servo_tie_rod_b_shank_od);

function dsservo_height_after_hat() =
  dsservo_size[2] - dsservo_hat_z_offset;

function dsservo_height_max_bracket_l() =
  dsservo_size[2] - dsservo_hat_z_offset
  - dsservo_socket_z_offset
  - dsservo_socket_size[2];

function dsservo_height_before_hat() =
  servo_height_before_hat(h=dsservo_size[2],
                          z_offst=steering_bolts_hat_z_offset,
                          hat_thickness=dsservo_hat_thickness);

function dsservo_gear_height() =
  servo_gear_total_height(dsservo_gearbox_size);

function full_dservo_tie_rod_len() =
  let (nut_h = find_nut_prop(prop="height",
                             inner_d=servo_tie_rod_a_shank_bolt_d,
                             lock=false),
       shaft_len = steering_servo_tie_rod_body_len,
       tie_rod_len = servo_tie_rod_a_shank_len + servo_tie_rod_a_eye_od
       + nut_h)
  shaft_len + tie_rod_len * 2;

function dservo_tie_rod_bbox_for_len(length) =
  let (w=servo_tie_rod_a_eye_od,
       dims = [w, length, w],
       ang  = [steering_servo_tie_rod_angle, 0, 0],
       bb = rotated_bbox(size=dims, a=ang))
  bb;

function dservo_tie_rod_bbox() =
  dservo_tie_rod_bbox_for_len(full_dservo_tie_rod_len());

function dservo_tie_rod_bb() =
  dservo_tie_rod_bbox_for_len(servo_tie_rod_a_shank_len +
                              servo_tie_rod_a_eye_od);

module servo_tie_rod(bushing_rotation,
                     tie_rod_b_bushing_rotation=[0, 0, 0],
                     y_angle=0) {
  tie_rod(center_anchor="a",
          direction="bottom",
          center_z=true,
          shaft_body_len=steering_servo_tie_rod_body_len,
          shaft_body_d=steering_servo_tie_rod_body_d,
          shaft_body_end_len=steering_servo_tie_rod_body_end_len,
          shaft_thread_len=steering_servo_tie_rod_thread_len,
          shaft_thread_d=steering_servo_tie_rod_thread_d,
          shaft_fn=steering_servo_tie_rod_fn,
          shaft_color=steering_servo_tie_rod_color,
          show_shaft_nuts=true,

          tie_rod_a_eye_od=servo_tie_rod_a_eye_od,
          tie_rod_a_eye_h=servo_tie_rod_a_eye_h,
          tie_rod_a_shank_od=servo_tie_rod_a_shank_od,
          tie_rod_a_shank_bolt_d=servo_tie_rod_a_shank_bolt_d,
          tie_rod_a_neck_len=servo_tie_rod_a_neck_len,
          tie_rod_a_shank_len=servo_tie_rod_a_shank_len,
          tie_rod_a_bushing_od=servo_tie_rod_a_bushing_od,
          tie_rod_a_bushing_d=servo_tie_rod_a_bushing_d,
          tie_rod_a_bushing_h=servo_tie_rod_a_bushing_h,
          tie_rod_a_bushing_flat_d=servo_tie_rod_a_bushing_flat_d,
          tie_rod_a_bushing_cap_h=servo_tie_rod_a_bushing_cap_h,
          tie_rod_a_bushing_cap_d=servo_tie_rod_a_bushing_cap_d,
          tie_rod_a_neck_h=servo_tie_rod_a_neck_h,
          tie_rod_a_eye_bolt_color=servo_tie_rod_a_eye_bolt_color,
          tie_rod_a_bushing_color=servo_tie_rod_a_bushing_color,
          tie_rod_a_eye_bolt_h=servo_tie_rod_a_eye_bolt_h,
          tie_rod_a_eye_bolt_head_d=servo_tie_rod_a_eye_bolt_head_d,
          tie_rod_a_show_eye_bolt=true,
          tie_rod_a_show_eye_bolt_nut=true,
          tie_rod_a_eye_bolt_through_h=steering_servo_arm_bolt_boss_h,

          tie_rod_a_y_angle=y_angle,

          tie_rod_a_reverse_bolt=servo_tie_rod_a_reverse_bolt,
          tie_rod_a_bushing_rotation=bushing_rotation,
          tie_rod_a_screw_out_depth=servo_tie_rod_a_screw_out_depth,
          tie_rod_a_color=servo_tie_rod_a_color,

          tie_rod_b_eye_od=servo_tie_rod_b_eye_od,
          tie_rod_b_eye_h=servo_tie_rod_b_eye_h,
          tie_rod_b_shank_od=servo_tie_rod_b_shank_od,
          tie_rod_b_shank_bolt_d=servo_tie_rod_b_shank_bolt_d,
          tie_rod_b_neck_len=servo_tie_rod_b_neck_len,
          tie_rod_b_shank_len=servo_tie_rod_b_shank_len,
          tie_rod_b_bushing_od=servo_tie_rod_b_bushing_od,
          tie_rod_b_bushing_d=servo_tie_rod_b_bushing_d,
          tie_rod_b_bushing_h=servo_tie_rod_b_bushing_h,
          tie_rod_b_bushing_flat_d=servo_tie_rod_b_bushing_flat_d,
          tie_rod_b_bushing_cap_h=servo_tie_rod_b_bushing_cap_h,
          tie_rod_b_bushing_cap_d=servo_tie_rod_b_bushing_cap_d,
          tie_rod_b_neck_h=servo_tie_rod_b_neck_h,
          tie_rod_b_eye_bolt_color=servo_tie_rod_b_eye_bolt_color,
          tie_rod_b_bushing_color=servo_tie_rod_b_bushing_color,
          tie_rod_b_eye_bolt_head_d=servo_tie_rod_b_eye_bolt_head_d,
          tie_rod_b_show_eye_bolt=servo_tie_rod_b_show_eye_bolt,
          tie_rod_b_reverse_bolt=servo_tie_rod_b_reverse_bolt,
          tie_rod_b_bushing_rotation=tie_rod_b_bushing_rotation,
          tie_rod_b_y_angle=90,
          tie_rod_b_screw_out_depth=servo_tie_rod_b_screw_out_depth,
          tie_rod_b_color=servo_tie_rod_b_color);
}

module dsservo(center=false,
               servo_color=dsservo_color,
               alpha=1,
               show_servo_horn=true,
               show_servo_horn_screws,
               show_servo_horn_bolt,
               servo_horn_single,
               show_tie_rod=true,
               bellcrank_lever_z_end,
               servo_horn_screw_side) {
  bellcrank_lever_z_end = is_undef(bellcrank_lever_z_end)
    ? bellcrank_servo_lever_z_coords()[1]
    : bellcrank_lever_z_end;

  dims = tie_rod_full_len(shaft_body_len=steering_servo_tie_rod_body_len,
                          shaft_thread_len=steering_servo_tie_rod_thread_len,
                          shaft_thread_d=steering_servo_tie_rod_thread_d,
                          show_shaft_nuts=true,
                          tie_rod_a_screw_out_depth=servo_tie_rod_a_screw_out_depth,
                          tie_rod_a_eye_od=servo_tie_rod_a_eye_od,
                          tie_rod_a_shank_len=servo_tie_rod_a_shank_len,
                          tie_rod_b_shank_len=servo_tie_rod_b_shank_len,
                          tie_rod_b_eye_od=servo_tie_rod_b_eye_od,
                          tie_rod_b_screw_out_depth=servo_tie_rod_b_screw_out_depth,
                          limit_max_depth=true);

  full_l = dims[0];

  y_tie_rod = + steering_servo_arm_d / 2
    + steering_servo_arm_len
    - steering_servo_arm_bolt_boss_padding
    - steering_servo_arm_bolt_d
    + (steering_servo_arm_bolt_d - servo_tie_rod_a_bushing_d);

  y_rod_zh = y_tie_rod + dsservo_size[1] / 2 - min(servo_tie_rod_b_shank_od,
                                                   servo_tie_rod_a_shank_od,
                                                   steering_servo_tie_rod_body_d) / 2;

  bellcrank_lever_z = y_rod_zh - bellcrank_lever_z_end;
  angle = -y_angle_from_zshift(bellcrank_lever_z, full_l);

  rotate([0, 0, 180]) {
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
          servo_horn_screw_side=servo_horn_screw_side,
          text_plist=dsservo_text_plist,
          socket_side=dsservo_socket_side,
          socket_size=dsservo_socket_size,
          socket_z_offset=dsservo_socket_z_offset,
          wiring_path=[[-100, 0, dsservo_socket_z_offset]]) {

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
                    arm_center_bolt_bore_h=steering_servo_arm_center_bolt_bore_h,
                    reverse=true);

          if (show_tie_rod) {
            max_tie_rod_a_h = dservo_tie_rod_a_max_h();
            mirror([1, 0, 0]) {
              translate([-steering_servo_arm_w / 2 + servo_tie_rod_a_eye_od / 2,
                         y_tie_rod,
                         -max_tie_rod_a_h / 2]) {

                rotate([0, 0, 90 + angle]) {
                  servo_tie_rod(tie_rod_b_bushing_rotation=[angle, 0, 0]);
                }
              }
            }
          }
        }
      }
    }
  }
}
dsservo();
