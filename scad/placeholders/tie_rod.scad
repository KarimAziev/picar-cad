/**
  * Module: Tie rod with shaft and two ends.
  *
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../colors.scad>
include <../steering_params.scad>

use <../lib/plist.scad>
use <../lib/text.scad>
use <bolt.scad>
use <tie_rod_end.scad>
use <tie_rod_shaft.scad>

function tie_rod_full_len(shaft_nut_h,
                          shaft_thread_d,
                          show_shaft_nuts,
                          shaft_thread_len,
                          shaft_body_len,
                          tie_rod_a_screw_out_depth,
                          tie_rod_a_eye_od,
                          tie_rod_a_shank_len,
                          tie_rod_b_shank_len,
                          tie_rod_b_eye_od,
                          tie_rod_b_screw_out_depth,
                          limit_max_depth) =
  let (nut_h=with_default(shaft_nut_h,
                          show_shaft_nuts
                          ? find_nut_prop(prop="height",
                                          inner_d=shaft_thread_d,
                                          lock=false)
                          : 0),
       max_screw_out_depth=shaft_thread_len - nut_h,
       tie_rod_a_screw_out_depth=with_default(tie_rod_a_screw_out_depth, 0),
       tie_rod_b_screw_out_depth=with_default(tie_rod_b_screw_out_depth, 0),
       tie_rod_a_raw_len=tie_rod_a_shank_len + tie_rod_a_eye_od,
       tie_rod_b_raw_len=tie_rod_b_shank_len + tie_rod_b_eye_od,
       tie_rod_a_depth=(limit_max_depth
                        ? min(max_screw_out_depth, tie_rod_a_screw_out_depth)
                        : tie_rod_a_screw_out_depth),
       tie_rod_b_depth=(limit_max_depth
                        ? min(max_screw_out_depth, tie_rod_b_screw_out_depth)
                        : tie_rod_b_screw_out_depth),
       tie_rod_a_len=tie_rod_a_raw_len
       + (limit_max_depth
          ? min(max_screw_out_depth, tie_rod_a_screw_out_depth)
          : tie_rod_a_screw_out_depth)
       ,
       tie_rod_b_len=tie_rod_b_raw_len
       + (limit_max_depth
          ? min(max_screw_out_depth, tie_rod_b_screw_out_depth)
          : tie_rod_b_screw_out_depth)
       ,
       full_len = shaft_body_len + nut_h * 2 + tie_rod_a_len + tie_rod_b_len)
       [full_len,
        tie_rod_a_len,
        tie_rod_b_len,
        tie_rod_a_depth,
        tie_rod_b_depth,
        max_screw_out_depth,
        tie_rod_a_raw_len,
        tie_rod_b_raw_len];

module tie_rod(show_tie_rod_a=true,
               show_tie_rod_b=true,
               center_anchor="a",
               direction="bottom",
               shaft_body_len,
               shaft_body_d,
               shaft_body_end_len,
               shaft_thread_len,
               shaft_thread_d,
               shaft_fn=6,
               shaft_nut_h,
               shaft_color=metallic_silver_1,
               show_shaft_nuts=true,
               tie_rod_a_eye_od,
               tie_rod_a_eye_h,
               tie_rod_a_bushing_od,
               tie_rod_a_bushing_d,
               tie_rod_a_bushing_h,
               tie_rod_a_bushing_flat_d,
               tie_rod_a_bushing_color=metallic_silver_9,
               tie_rod_a_bushing_cap_d,
               tie_rod_a_bushing_cap_h,
               tie_rod_a_color=cobalt_blue_metallic,
               tie_rod_a_shank_od,
               tie_rod_a_shank_len,
               tie_rod_a_shank_bolt_d,
               tie_rod_a_neck_len,
               tie_rod_a_neck_h,
               tie_rod_a_fn=80,
               tie_rod_a_show_eye_bolt,
               tie_rod_a_show_eye_bolt_nut,
               tie_rod_a_eye_bolt_h,
               tie_rod_a_eye_bolt_head_d,
               tie_rod_a_eye_bolt_through_h,
               tie_rod_a_eye_bolt_head_type="pan",
               tie_rod_a_eye_bolt_lock_nut,
               tie_rod_a_eye_bolt_color,
               tie_rod_a_eye_head_color,
               tie_rod_a_y_angle,
               tie_rod_a_reverse_bolt,
               tie_rod_a_bushing_rotation,
               tie_rod_a_screw_out_depth,
               tie_rod_b_eye_od,
               tie_rod_b_eye_h,
               tie_rod_b_bushing_od,
               tie_rod_b_bushing_d,
               tie_rod_b_bushing_h,
               tie_rod_b_bushing_flat_d,
               tie_rod_b_bushing_color=metallic_silver_9,
               tie_rod_b_bushing_cap_d,
               tie_rod_b_bushing_cap_h,
               tie_rod_b_color=cobalt_blue_metallic,
               tie_rod_b_shank_od,
               tie_rod_b_shank_len,
               tie_rod_b_shank_bolt_d,
               tie_rod_b_neck_len,
               tie_rod_b_neck_h,
               tie_rod_b_fn=80,
               tie_rod_b_show_eye_bolt,
               tie_rod_b_show_eye_bolt_nut,
               tie_rod_b_eye_bolt_h,
               tie_rod_b_eye_bolt_head_d,
               tie_rod_b_eye_bolt_through_h,
               tie_rod_b_eye_bolt_head_type="pan",
               tie_rod_b_eye_bolt_lock_nut,
               tie_rod_b_eye_bolt_color,
               tie_rod_b_eye_head_color,
               tie_rod_b_y_angle,
               tie_rod_b_reverse_bolt,
               tie_rod_b_bushing_rotation,
               tie_rod_b_screw_out_depth,
               limit_max_depth=false,
               show_full_len=true,
               center_z=true) {

  shaft_full_len = shaft_body_len + shaft_thread_len * 2;
  shaft_half_l = shaft_full_len / 2;

  nut_h = with_default(shaft_nut_h,
                       show_shaft_nuts
                       ? find_nut_prop(prop="height",
                                       inner_d=shaft_thread_d,
                                       lock=false)
                       : 0);

  max_screw_out_depth = shaft_thread_len - nut_h;

  tie_rod_a_screw_out_depth = with_default(tie_rod_a_screw_out_depth, 0);
  tie_rod_b_screw_out_depth = with_default(tie_rod_b_screw_out_depth, 0);

  len_params = tie_rod_full_len(shaft_nut_h=shaft_nut_h,
                                shaft_thread_d=shaft_thread_d,
                                show_shaft_nuts=show_shaft_nuts,
                                shaft_thread_len=shaft_thread_len,
                                shaft_body_len=shaft_body_len,
                                tie_rod_a_screw_out_depth=tie_rod_a_screw_out_depth,
                                tie_rod_a_eye_od=tie_rod_a_eye_od,
                                tie_rod_a_shank_len=tie_rod_a_shank_len,
                                tie_rod_b_shank_len=tie_rod_b_shank_len,
                                tie_rod_b_eye_od=tie_rod_b_eye_od,
                                tie_rod_b_screw_out_depth=tie_rod_b_screw_out_depth,
                                limit_max_depth=limit_max_depth);
  full_len = len_params[0];

  tie_rod_a_len = len_params[1];

  tie_rod_b_len = len_params[2];

  tie_rod_a_max_h = tie_rod_max_h(eye_od=tie_rod_a_eye_od,
                                  eye_h=tie_rod_a_eye_h,
                                  bushing_od=tie_rod_a_bushing_od,
                                  bushing_d=tie_rod_a_bushing_d,
                                  bushing_h=tie_rod_a_bushing_h,
                                  shank_od=tie_rod_a_shank_od);

  tie_rod_b_max_h = tie_rod_max_h(eye_od=tie_rod_b_eye_od,
                                  eye_h=tie_rod_b_eye_h,
                                  bushing_od=tie_rod_b_bushing_od,
                                  bushing_d=tie_rod_b_bushing_d,
                                  bushing_h=tie_rod_b_bushing_h,
                                  shank_od=tie_rod_b_shank_od);

  max_h = max(tie_rod_a_max_h, tie_rod_b_max_h, shaft_body_d);

  if (show_full_len) {
    echo(str("Tie rod full length: ", full_len, "mm", ". Shaft: ",
             shaft_body_len, "mm, a: ", tie_rod_a_len,
             "mm, b: ", tie_rod_b_len,
             ", nut len: ", nut_h, "mm"));
  }

  function _tie_rod_end_y(eye_od,
                          shank_len,
                          screw_out_depth) =
    eye_od / 2 + shank_len
    + shaft_half_l
    - shaft_thread_len
    + nut_h
    + (limit_max_depth
       ? min(max_screw_out_depth, screw_out_depth)
       : screw_out_depth);

  a_centered_y = _tie_rod_end_y(tie_rod_a_eye_od,
                                tie_rod_a_shank_len,
                                tie_rod_a_screw_out_depth);
  b_centered_y = _tie_rod_end_y(tie_rod_b_eye_od,
                                tie_rod_b_shank_len,
                                tie_rod_b_screw_out_depth);

  a_anchor = center_anchor == "a";

  y_shift = a_anchor ? -a_centered_y : b_centered_y;

  z_rotation_initial = a_anchor ? 0 : 180;

  directions = ["left", -90,
                "right", 90,
                "top", 180,
                "bottom", 0];

  z_rotation = plist_get(with_default(direction, "bottom"), directions, 0);
  z = center_z ? 0 : max_h / 2;

  rotate([0, 0, z_rotation_initial + z_rotation]) {
    translate([0, y_shift, z]) {
      union() {
        translate([0, shaft_half_l, 0]) {
          rotate([90, 0, 0]) {
            tie_rod_shaft(body_len=shaft_body_len,
                          body_d=shaft_body_d,
                          body_end_len=shaft_body_end_len,
                          thread_len=shaft_thread_len,
                          thread_d=shaft_thread_d,
                          fn=shaft_fn,
                          nut_h=shaft_nut_h,
                          color=shaft_color,
                          show_nuts=show_shaft_nuts,
                          show_len=show_full_len,
                          extra_text=str("Total: ", full_len, "mm"));
          }
        }
        if (show_tie_rod_a) {
          translate([0, a_centered_y, 0]) {
            tie_rod_end(eye_od=tie_rod_a_eye_od,
                        eye_h=tie_rod_a_eye_h,
                        bushing_od=tie_rod_a_bushing_od,
                        bushing_d=tie_rod_a_bushing_d,
                        bushing_h=tie_rod_a_bushing_h,
                        bushing_flat_d=tie_rod_a_bushing_flat_d,
                        bushing_color=tie_rod_a_bushing_color,
                        color=tie_rod_a_color,
                        shank_od=tie_rod_a_shank_od,
                        direction="bottom",
                        shank_len=tie_rod_a_shank_len,
                        shank_bolt_d=tie_rod_a_shank_bolt_d,
                        neck_len=tie_rod_a_neck_len,
                        neck_h=tie_rod_a_neck_h,
                        fn=tie_rod_a_fn,
                        show_eye_bolt=tie_rod_a_show_eye_bolt,
                        show_eye_bolt_nut=tie_rod_a_show_eye_bolt_nut,
                        eye_bolt_h=tie_rod_a_eye_bolt_h,
                        eye_bolt_head_d=tie_rod_a_eye_bolt_head_d,
                        eye_bolt_through_h=tie_rod_a_eye_bolt_through_h,
                        eye_bolt_head_type=tie_rod_a_eye_bolt_head_type,
                        eye_bolt_lock_nut=tie_rod_a_eye_bolt_lock_nut,
                        eye_bolt_color=tie_rod_a_eye_bolt_color,
                        eye_head_color=tie_rod_a_eye_head_color,
                        x_angle=0,
                        y_angle=tie_rod_a_y_angle,
                        bushing_cap_d=tie_rod_a_bushing_cap_d,
                        bushing_cap_h=tie_rod_a_bushing_cap_h,
                        reverse_bolt=tie_rod_a_reverse_bolt,
                        bushing_rotation=tie_rod_a_bushing_rotation,
                        center_z=true);
          }
        }
        if (show_tie_rod_b) {
          translate([0, -b_centered_y, 0]) {
            tie_rod_end(eye_od=tie_rod_b_eye_od,
                        eye_h=tie_rod_b_eye_h,
                        bushing_od=tie_rod_b_bushing_od,
                        bushing_d=tie_rod_b_bushing_d,
                        bushing_h=tie_rod_b_bushing_h,
                        bushing_flat_d=tie_rod_b_bushing_flat_d,
                        bushing_color=tie_rod_b_bushing_color,
                        color=tie_rod_b_color,
                        shank_od=tie_rod_b_shank_od,
                        direction="top",
                        shank_len=tie_rod_b_shank_len,
                        shank_bolt_d=tie_rod_b_shank_bolt_d,
                        neck_len=tie_rod_b_neck_len,
                        neck_h=tie_rod_b_neck_h,
                        fn=tie_rod_b_fn,
                        show_eye_bolt=tie_rod_b_show_eye_bolt,
                        show_eye_bolt_nut=tie_rod_b_show_eye_bolt_nut,
                        eye_bolt_h=tie_rod_b_eye_bolt_h,
                        eye_bolt_head_d=tie_rod_b_eye_bolt_head_d,
                        eye_bolt_through_h=tie_rod_b_eye_bolt_through_h,
                        eye_bolt_head_type=tie_rod_b_eye_bolt_head_type,
                        eye_bolt_lock_nut=tie_rod_b_eye_bolt_lock_nut,
                        eye_bolt_color=tie_rod_b_eye_bolt_color,
                        eye_head_color=tie_rod_b_eye_head_color,
                        x_angle=0,
                        y_angle=tie_rod_b_y_angle,
                        bushing_cap_d=tie_rod_b_bushing_cap_d,
                        bushing_cap_h=tie_rod_b_bushing_cap_h,
                        reverse_bolt=tie_rod_b_reverse_bolt,
                        bushing_rotation=tie_rod_b_bushing_rotation,
                        center_z=true);
          }
        }
      }
    }
  }
}

module servo_tie_rod(bushing_rotation,
                     tie_rod_b_bushing_rotation=[0, 0, 0],
                     tie_rod_b_eye_bolt_through_h=10,
                     y_angle=0) {
  tie_rod(center_anchor="a",
          direction="right",
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
          tie_rod_b_show_eye_bolt=true,
          tie_rod_b_reverse_bolt=servo_tie_rod_b_reverse_bolt,
          tie_rod_b_bushing_rotation=tie_rod_b_bushing_rotation,
          tie_rod_b_y_angle=90,
          tie_rod_b_eye_bolt_through_h=tie_rod_b_eye_bolt_through_h,
          tie_rod_b_screw_out_depth=servo_tie_rod_b_screw_out_depth,
          tie_rod_b_color=servo_tie_rod_b_color);
}

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

function rotated_bbox_minmax(minp, maxp, a=[0, 0, 0]) =
  rotated_points_bbox([[minp[0], minp[1], minp[2]],
                       [maxp[0], minp[1], minp[2]],
                       [minp[0], maxp[1], minp[2]],
                       [maxp[0], maxp[1], minp[2]],
                       [minp[0], minp[1], maxp[2]],
                       [maxp[0], minp[1], maxp[2]],
                       [minp[0], maxp[1], maxp[2]],
                       [maxp[0], maxp[1], maxp[2]]],
                      a);

function rotated_bbox_from_minmax(minp, maxp, a=[0, 0, 0]) =
  let (b = rotated_bbox_minmax(minp, maxp, a))
  [b[3]-b[0],  // size x
   b[4]-b[1],  // size y
   b[5]-b[2],  // size z
   -b[0],      // shift x
   -b[1],      // shift y
   -b[2]       // shift z
  ];

function bbox_corners(minp, maxp) =
  [[minp[0], minp[1], minp[2]],
   [maxp[0], minp[1], minp[2]],
   [minp[0], maxp[1], minp[2]],
   [maxp[0], maxp[1], minp[2]],
   [minp[0], minp[1], maxp[2]],
   [maxp[0], minp[1], maxp[2]],
   [minp[0], maxp[1], maxp[2]],
   [maxp[0], maxp[1], maxp[2]]];

function rotated_points_bbox(pts, a=[0, 0, 0]) =
  let (rpts = [for (p=pts) rotate_euler_xyz(p, a)],
       xs = [for (p=rpts) p[0]],
       ys = [for (p=rpts) p[1]],
       zs = [for (p=rpts) p[2]])
  [min(xs), min(ys), min(zs), max(xs), max(ys), max(zs)];

function bbox_from_boxes(boxes, a=[0, 0, 0]) =
  let (pts = [for (b = boxes)
           each bbox_corners(b[0], b[1])])
  rotated_points_bbox(pts, a);

function bbox_size_shift(minmax) =
  [minmax[3] - minmax[0],
   minmax[4] - minmax[1],
   minmax[5] - minmax[2],
   -minmax[0],
   -minmax[1],
   -minmax[2]];

function vsub(a, b) = [a[0]-b[0], a[1]-b[1], a[2]-b[2]];
function vadd(a, b) = [a[0] + b[0], a[1] + b[1], a[2] + b[2]];

function rotate_point_about(p, pivot=[0, 0, 0], a=[0, 0, 0]) =
  vadd(rotate_euler_xyz(vsub(p, pivot), a), pivot);

function rotated_points_bbox_about(pts, pivot=[0, 0, 0], a=[0, 0, 0]) =
  let (rpts = [for (p=pts) rotate_point_about(p, pivot, a)],
       xs = [for (p=rpts) p[0]],
       ys = [for (p=rpts) p[1]],
       zs = [for (p=rpts) p[2]])
  [min(xs), min(ys), min(zs), max(xs), max(ys), max(zs)];

function bbox_from_boxes_about(boxes, pivot=[0, 0, 0], a=[0, 0, 0]) =
  let (pts = [for (b=boxes) each bbox_corners(b[0], b[1])])
  rotated_points_bbox_about(pts, pivot, a);

function servo_tie_rod_bbox(angle=0) =
  let (dims = tie_rod_full_len(shaft_body_len=steering_servo_tie_rod_body_len,
                               shaft_thread_len=steering_servo_tie_rod_thread_len,
                               shaft_thread_d=steering_servo_tie_rod_thread_d,
                               show_shaft_nuts=true,
                               tie_rod_a_screw_out_depth=servo_tie_rod_a_screw_out_depth,
                               tie_rod_a_eye_od=servo_tie_rod_a_eye_od,
                               tie_rod_a_shank_len=servo_tie_rod_a_shank_len,
                               tie_rod_b_shank_len=servo_tie_rod_b_shank_len,
                               tie_rod_b_eye_od=servo_tie_rod_b_eye_od,
                               tie_rod_b_screw_out_depth=servo_tie_rod_b_screw_out_depth,
                               limit_max_depth=true),
       full_l = dims[0],
       eye_center_spacing = full_l
       - servo_tie_rod_a_eye_od/2
       - servo_tie_rod_b_eye_od/2,

       ha = dservo_tie_rod_a_max_h(),
       hb = dservo_tie_rod_b_max_h(),
       sd = steering_servo_tie_rod_body_d,

       boxes = [[[-servo_tie_rod_a_eye_od/2, -ha/2, -ha/2],
                 [servo_tie_rod_a_eye_od/2,  ha/2,  ha/2]],

                [[0, -sd/2, -sd/2],
                 [eye_center_spacing, sd/2, sd/2]],

                [[eye_center_spacing - servo_tie_rod_b_eye_od/2, -hb/2, -hb/2],
                 [eye_center_spacing + servo_tie_rod_b_eye_od/2,  hb/2,  hb/2]]],

       mm = bbox_from_boxes_about(boxes, [0, 0, 0], [0, 0, angle]))
  bbox_size_shift(mm);

function servo_tie_rod_b_center(angle=0) =
  let (dims = tie_rod_full_len(shaft_body_len=steering_servo_tie_rod_body_len,
                               shaft_thread_len=steering_servo_tie_rod_thread_len,
                               shaft_thread_d=steering_servo_tie_rod_thread_d,
                               show_shaft_nuts=true,
                               tie_rod_a_screw_out_depth=servo_tie_rod_a_screw_out_depth,
                               tie_rod_a_eye_od=servo_tie_rod_a_eye_od,
                               tie_rod_a_shank_len=servo_tie_rod_a_shank_len,
                               tie_rod_b_shank_len=servo_tie_rod_b_shank_len,
                               tie_rod_b_eye_od=servo_tie_rod_b_eye_od,
                               tie_rod_b_screw_out_depth=servo_tie_rod_b_screw_out_depth,
                               limit_max_depth=true),
       full_l = dims[0],
       s = full_l - servo_tie_rod_a_eye_od/2 - servo_tie_rod_b_eye_od/2)
  [s*cos(angle), s*sin(angle), 0];

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
angle = -30;
max_tie_rod_a_h = dservo_tie_rod_a_max_h();
max_tie_rod_b_h = dservo_tie_rod_b_max_h();
w = max(max_tie_rod_a_h, max_tie_rod_b_h, steering_servo_tie_rod_body_d);

// I need to have way to get distance from x0 and y0 (the center of anchored
// tie_rod_a_eye_od) to the center of tie_rod_b_eye_od
eye_center_spacing = full_l
  - servo_tie_rod_a_eye_od / 2
  - servo_tie_rod_b_eye_od / 2;

bb = servo_tie_rod_bbox(angle);

bb_center = servo_tie_rod_b_center();

echo("bb_center", bb_center);

translate([0, 0, 0]) {

  rotate([0, 0, angle]) {
    servo_tie_rod(tie_rod_b_bushing_rotation=[0, 0, 0]);
  }
}

// translate([0, (angle > 0 ? 0 : -bb[1]), 0]) {
//   translate([0, 0, 0]) {
//     #cube([bb_center[0], bb[1], bb[2]]);
//   }
// }
translate([0, 0, 10]) {

  color("red") {
    translate([eye_center_spacing*cos(angle),
               eye_center_spacing*sin(angle),
               0]) {
      sphere(d=1);
    }
  }
}