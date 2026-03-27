/**
  * Module: Placeholder (non-printable) for the steering tie rod end
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/placement.scad>
use <../../lib/plist.scad>
use <../../lib/shapes2d.scad>
use <../../lib/transforms.scad>
use <../../placeholders/bolt.scad>
use <../../placeholders/tie_rod_end.scad>
use <../../placeholders/tie_rod_shaft.scad>
use <knuckle_steering_arm.scad>

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
                             show_eye_bolt=true,
                             tilt_angle=knuckle_tie_tilt_angle,
                             eye_bolt_h,
                             eye_bolt_through_h,
                             show_eye_bolt_nut=false,
                             eye_bolt_head_type="pan",
                             center_y=true,
                             center_x_by_eye=false) {
  eye_bolt_h_1 = with_default(eye_bolt_h, knuckle_arm_thickness + bushing_h);

  max_h = max(bushing_h, eye_h, knuckle_tie_rod_link_od);

  module _tie_rod_end(y_angle, x_angle, bushing_rotation, eye_bolt_h) {
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
                y_angle=y_angle,
                bushing_rotation=bushing_rotation,
                x_angle=x_angle,
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
                 bushing_rotation=[0, tilt_angle, 0]);
    translate([shank_len + eye_od / 2,
               0,
               0]) {
      translate([- knuckle_tie_rod_link_thread_len,
                 0,
                 max_h / 2]) {
        rotate([0, 90, 0]) {
          tie_rod_shaft(body_len=knuckle_tie_rod_link_len,
                        body_d=knuckle_tie_rod_link_od,
                        body_end_len=knuckle_tie_rod_link_end_len,
                        show_nuts=true,
                        thread_len=knuckle_tie_rod_link_thread_len,
                        thread_d=knuckle_tie_rod_link_thread_d,
                        color=knuckle_tie_rod_link_color);
        }
      }

      translate([+ shank_len + eye_od / 2 + knuckle_tie_rod_link_len,
                 0,
                 0]) {
        mirror([1, 0, 0]) {
          _tie_rod_end(bushing_rotation=[0, -tilt_angle, 0]);
        }
      }
    }
  }

  maybe_translate([0, center_y ? 0 : eye_od / 2 , 0]) {
    if (center_x_by_eye) {
      _main();
    } else {
      translate([eye_od / 2, 0, 0]) {
        _main();
      }
    }
  }
}

module steering_link(knuckle_arm_len=knuckle_arm_base_len,
                     knuckle_outer_d=knuckle_arm_ring_outer_d,
                     knuckle_ear_len=knuckle_arm_ear_len,
                     w_narrow=knuckle_arm_narrow_w,
                     knuckle_angle=knuckle_arm_angle,
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
                     show_eye_bolt=true,
                     tilt_angle=knuckle_tie_tilt_angle,
                     eye_bolt_h,
                     eye_bolt_through_h,
                     show_eye_bolt_nut=false,
                     eye_bolt_head_type="pan",
                     tie_rod_reverse=true) {
  x2 = knuckle_arm_len * sin(knuckle_angle);
  y2 = knuckle_arm_len * cos(knuckle_angle);
  ear_base_len = knuckle_ear_len - bolt_d - bolt_edge_offset;
  max_h = max(bushing_h, eye_od, knuckle_tie_rod_link_od);
  z = tie_rod_reverse ? -thickness / 2 - max_h : 0;

  rotate([0, 0, tilt_angle]) {
    translate([x2 + w_narrow / 2,
               z,
               knuckle_outer_d / 2 + eye_od / 2 + ear_base_len + y2]) {
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
                                tilt_angle=tilt_angle,
                                eye_bolt_h=eye_bolt_h,
                                eye_bolt_through_h=eye_bolt_through_h,
                                show_eye_bolt_nut=show_eye_bolt_nut,
                                eye_bolt_head_type=eye_bolt_head_type,
                                center_x_by_eye=true);
        }
      }
    }
  }
}

steering_tie_rod_link();
