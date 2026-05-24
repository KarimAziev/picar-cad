/**
  * Module: Common helpers
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../steering_params.scad>


function front_lower_arm_ball_stud_y_pos() =
  let (cutout_depth = front_lower_arm_damper_boss_h
       + front_lower_arm_upper_boss_y_offset)
  front_lower_arm_h - cutout_depth - front_lower_arm_apex_width / 2;

function front_lower_arm_mount_cutout_size() =
  let (profile_x0 = front_lower_arm_hinge_barrel_hole_d / 2
       + front_lower_arm_hinge_barrel_hole_offset
       + front_lower_arm_hinge_barrel_hole_d,
       hinge_cutout_len = front_lower_arm_hinge_barrel_len - profile_x0,
       hinge_cutout_h = front_lower_arm_h - (front_lower_arm_upper_hinge_barrel_h
                                             + front_lower_arm_lower_hinge_barrel_h))
  [hinge_cutout_len, hinge_cutout_h];

function front_lower_arm_full_size(inlcude_ball_stud=true) =
  let (ball_stud_len = !inlcude_ball_stud
       ? 0
       : front_arm_ball_stud_ball_d
       + front_arm_ball_stud_len
       - front_lower_arm_ball_stud_hole_depth
       + front_lower_arm_ball_stud_insert_out_depth)
  [front_lower_arm_len + ball_stud_len, front_lower_arm_h, front_lower_arm_thickness];

function front_upper_arm_ball_stud_y_pos() =
  front_upper_arm_ball_stud_mount_extra_h
  + front_upper_arm_h
  - front_upper_arm_ball_stud_mount_size[1] / 2;

function front_upper_arm_full_size(inlcude_ball_stud=true) =
  let (ball_stud_len = !inlcude_ball_stud
       ? 0
       : front_arm_ball_stud_ball_d
       + front_arm_ball_stud_len
       - front_upper_arm_ball_stud_hole_depth
       + front_upper_arm_ball_stud_insert_out_depth)
  [front_upper_arm_len + ball_stud_len, front_upper_arm_h, front_upper_arm_thickness];

function front_bulkhead_base_size(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                  d=front_bulkhead_mount_bolt_d,
                                  padding_x=front_chassis_bulkhead_padding_x,
                                  padding_y=front_chassis_bulkhead_padding_y) =
  let (size_x=outer_spacing[0] + d + padding_x,
       size_y=outer_spacing[1] + d + padding_y)
  [size_x, size_y];