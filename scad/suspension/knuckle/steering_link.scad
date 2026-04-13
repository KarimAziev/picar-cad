/**
  * Module: Placeholder (non-printable) for the steering tie rod end
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/functions.scad>
use <../../lib/placement.scad>
use <../../lib/plist.scad>
use <../../lib/shapes2d.scad>
use <../../lib/transforms.scad>
use <../../placeholders/bolt.scad>
use <../../placeholders/tie_rod_end.scad>
use <../../placeholders/tie_rod_shaft.scad>
use <knuckle_steering_arm.scad>

function steering_link_full_len(eye_od=knuckle_tie_rod_eye_od,
                                shank_len=knuckle_tie_rod_shank_len,
                                center_link_len=knuckle_tie_rod_link_len) =
  let (tie_rod_len = eye_od + shank_len)
  center_link_len + tie_rod_len * 2;

module steering_tie_rod_link(eye_od=knuckle_tie_rod_eye_od,
                             eye_h=knuckle_tie_rod_eye_h,
                             shank_od=knuckle_tie_rod_shank_od,
                             shank_bolt_d=knuckle_tie_rod_shank_bolt_d,
                             neck_len=knuckle_tie_rod_neck_len,
                             shank_len=knuckle_tie_rod_shank_len,
                             bushing_od=knuckle_tie_rod_bushing_od,
                             bushing_d=knuckle_tie_rod_bushing_d,
                             bushing_h=knuckle_tie_rod_bushing_h,
                             bushing_flat_d=knuckle_tie_rod_bushing_flat_d,
                             bushing_cap_h=knuckle_tie_rod_bushing_cap_h,
                             bushing_cap_d=knuckle_tie_rod_bushing_cap_d,
                             bushing_color=knuckle_tie_rod_bushing_color,
                             eye_bolt_head_d=knuckle_tie_rod_bushing_bolt_head_d,
                             eye_bolt_color=knuckle_tie_rod_bushing_bolt_color,
                             angles,
                             tilt_shift,
                             show_eye_bolt=true,
                             knuckle_arm_t=knuckle_arm_thickness,
                             center_link_len=knuckle_tie_rod_link_len,
                             center_link_end_len=knuckle_tie_rod_link_end_len,
                             center_link_od=knuckle_tie_rod_link_od,
                             center_link_thread_l=knuckle_tie_rod_link_thread_l,
                             center_link_thread_d=knuckle_tie_rod_link_thread_d,
                             center_link_color=knuckle_tie_rod_link_color,
                             right_end_bushing_angles=[0, 0, 0],
                             left_end_bushing_angles=[0, 0, 0],
                             eye_bolt_h,
                             eye_bolt_through_h,
                             show_eye_bolt_nut=false,
                             eye_bolt_head_type="pan",
                             center_y=true,
                             center_x_by_eye=true) {
  full_len = steering_link_full_len(eye_od=eye_od,
                                    shank_len=shank_len,
                                    center_link_len=center_link_len);
  angles = with_default(angles, []);
  x_angle = with_default(angles[0], 0);
  y_angle = with_default(angles[1], with_default(tilt_shift, 0));
  z_angle = with_default(angles[2], 0);
  eye_bolt_h_1 = with_default(eye_bolt_h, knuckle_arm_t + bushing_h);
  max_d = max(center_link_od, eye_od);
  max_h = max(bushing_h, eye_h, center_link_od);
  bb = rotated_bbox(size=[full_len, max_d, max_h],
                    a=[x_angle, y_angle, z_angle]);
  bb2 = rotated_bbox(size=[eye_od, eye_od, eye_od],
                     a=[x_angle, y_angle, z_angle]);

  x_shift = bb[3];
  y_shift = bb[4];
  tilt_shift = bb[5];

  x_final = center_x_by_eye ? -bb2[0] / 2 : 0;

  module _tie_rod_end(bushing_rotation, eye_bolt_h) {
    tie_rod_end(eye_od=eye_od,
                eye_h=eye_h,
                shank_od=shank_od,
                shank_bolt_d=shank_bolt_d,
                neck_len=neck_len,
                shank_len=shank_len,
                bushing_od=bushing_od,
                bushing_d=bushing_d,
                bushing_h=bushing_h,
                bushing_flat_d=bushing_flat_d,
                direction="right",
                bushing_rotation=bushing_rotation,
                show_eye_bolt=show_eye_bolt,
                eye_bolt_h=eye_bolt_h,
                eye_bolt_color=eye_bolt_color,
                reverse_bolt=true,
                bushing_color=bushing_color,
                bushing_cap_d=bushing_cap_d,
                eye_bolt_head_d=eye_bolt_head_d,
                bushing_cap_h=bushing_cap_h,
                eye_bolt_through_h=with_default(eye_bolt_through_h, eye_bolt_h),
                show_eye_bolt_nut=show_eye_bolt_nut,
                eye_bolt_head_type=eye_bolt_head_type);
  }

  module _main() {
    _tie_rod_end(eye_bolt_h=eye_bolt_h_1,
                 bushing_rotation=[left_end_bushing_angles[0],
                                   left_end_bushing_angles[1] -y_angle,
                                   left_end_bushing_angles[2]]);
    translate([shank_len + eye_od / 2,
               0,
               0]) {
      translate([-center_link_thread_l,
                 0,
                 max_h / 2]) {
        rotate([0, 90, 0]) {
          tie_rod_shaft(body_len=center_link_len,
                        body_d=center_link_od,
                        body_end_len=center_link_end_len,
                        show_nuts=true,
                        thread_len=center_link_thread_l,
                        thread_d=center_link_thread_d,
                        color=center_link_color);
        }
      }

      translate([+ shank_len + eye_od / 2 + center_link_len,
                 0,
                 0]) {
        mirror([1, 0, 0]) {
          _tie_rod_end(bushing_rotation=[right_end_bushing_angles[0],
                                         right_end_bushing_angles[1] + y_angle,
                                         right_end_bushing_angles[2]]);
        }
      }
    }
  }
  maybe_translate([x_final, center_y ? -eye_od / 2 : 0, 0]) {
    maybe_translate([0, 0, 0]) {
      maybe_rotate([x_angle, y_angle, z_angle]) {
        translate([eye_od / 2, eye_od / 2, 0]) {
          _main();
        }
      }
    }
  }
}

module steering_link(knuckle_arm_len=knuckle_arm_base_len,
                     knuckle_outer_d=knuckle_arm_ring_outer_d,
                     knuckle_ear_len=knuckle_arm_ear_len,
                     w_narrow=knuckle_arm_narrow_w,
                     knuckle_arm_angle=knuckle_arm_angle,
                     bolt_d=knuckle_arm_bolt_d,
                     bolt_edge_offset=knuckle_arm_bolt_hole_offset,
                     thickness=knuckle_arm_thickness,
                     tie_rod_angle=knuckle_tie_rod_angle,
                     eye_od=knuckle_tie_rod_eye_od,
                     eye_h=knuckle_tie_rod_eye_h,
                     shank_od=knuckle_tie_rod_shank_od,
                     shank_bolt_d=knuckle_tie_rod_shank_bolt_d,
                     neck_len=knuckle_tie_rod_neck_len,
                     shank_len=knuckle_tie_rod_shank_len,
                     bushing_od=knuckle_tie_rod_bushing_od,
                     bushing_d=knuckle_tie_rod_bushing_d,
                     bushing_h=knuckle_tie_rod_bushing_h,
                     bushing_flat_d=knuckle_tie_rod_bushing_flat_d,
                     bushing_cap_h=knuckle_tie_rod_bushing_cap_h,
                     bushing_cap_d=knuckle_tie_rod_bushing_cap_d,
                     bushing_color=knuckle_tie_rod_bushing_color,
                     eye_bolt_head_d=knuckle_tie_rod_bushing_bolt_head_d,
                     eye_bolt_color=knuckle_tie_rod_bushing_bolt_color,
                     knuckle_arm_t=knuckle_arm_thickness,
                     center_link_len=knuckle_tie_rod_link_len,
                     center_link_end_len=knuckle_tie_rod_link_end_len,
                     center_link_od=knuckle_tie_rod_link_od,
                     center_link_thread_l=knuckle_tie_rod_link_thread_l,
                     center_link_thread_d=knuckle_tie_rod_link_thread_d,
                     center_link_color=knuckle_tie_rod_link_color,
                     show_eye_bolt=true,
                     angles=[0, 6, 0],
                     tilt_shift=knuckle_tie_tilt_shift,
                     right_end_bushing_angles=[0, 0, 0],
                     left_end_bushing_angles=[0, 0, 0],
                     eye_bolt_h,
                     eye_bolt_through_h,
                     show_eye_bolt_nut=false,
                     eye_bolt_head_type="pan",
                     tie_rod_reverse=true) {
  x2 = knuckle_arm_len * sin(knuckle_arm_angle);
  y2 = knuckle_arm_len * cos(knuckle_arm_angle);

  max_h = max(bushing_h, eye_od, knuckle_tie_rod_link_od);
  x = x2 + w_narrow / 2;
  y = tie_rod_reverse ? -thickness / 2 - max_h : 0;

  ear_base_len = knuckle_ear_len - bolt_d - bolt_edge_offset;

  z = thickness +
    knuckle_outer_d / 2 + y2
    + ear_base_len
    + bolt_d / 2
    - (bolt_d - snap_bolt_d(bolt_d));

  right_end_bushing_angles = [with_default(right_end_bushing_angles[0], 0),
                              with_default(right_end_bushing_angles[1], 0),
                              with_default(right_end_bushing_angles[2], 0)];

  left_end_bushing_angles = [with_default(left_end_bushing_angles[0], 0),
                             with_default(left_end_bushing_angles[1], 0),
                             with_default(left_end_bushing_angles[2], 0)];

  translate([x,
             y,
             z]) {

    rotate([-90, 0, 0]) {
      rotate([0, 0, -abs(tie_rod_angle)]) {
        steering_tie_rod_link(eye_od=eye_od,
                              eye_h=eye_h,
                              shank_od=shank_od,
                              shank_bolt_d=shank_bolt_d,
                              neck_len=neck_len,
                              shank_len=shank_len,
                              bushing_od=bushing_od,
                              bushing_d=bushing_d,
                              bushing_h=bushing_h,
                              bushing_flat_d=bushing_flat_d,
                              bushing_cap_h=bushing_cap_h,
                              bushing_cap_d=bushing_cap_d,
                              bushing_color=bushing_color,
                              eye_bolt_head_d=eye_bolt_head_d,
                              eye_bolt_color=eye_bolt_color,
                              show_eye_bolt=show_eye_bolt,
                              right_end_bushing_angles=right_end_bushing_angles,
                              left_end_bushing_angles=left_end_bushing_angles,
                              tilt_shift=tilt_shift,
                              angles=angles,
                              eye_bolt_h=eye_bolt_h,
                              eye_bolt_through_h=eye_bolt_through_h,
                              show_eye_bolt_nut=show_eye_bolt_nut,
                              eye_bolt_head_type=eye_bolt_head_type,
                              knuckle_arm_t=knuckle_arm_t,
                              center_link_len=center_link_len,
                              center_link_end_len=center_link_end_len,
                              center_link_od=center_link_od,
                              center_link_thread_l=center_link_thread_l,
                              center_link_thread_d=center_link_thread_d,
                              center_link_color=center_link_color,
                              center_y=true,
                              center_x_by_eye=true);
      }
    }
  }
}

steering_link(left_end_bushing_angles=[0, 0, 0], angles=[0, 10, 0]);
// steering_tie_rod_link(angles=[0, 30, 0]);
