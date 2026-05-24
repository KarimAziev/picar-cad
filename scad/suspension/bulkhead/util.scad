/**
  * Module: Common bulkhead helpers
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../steering_params.scad>

use <../wishbone_arms/util.scad>

function front_bulkhead_pad_distance_to_hinge(barrel_y_offset=front_bulkhead_barrel_y_offset,
                                              hinge_clearance=front_bulkhead_barrel_hinge_clearance,
                                              outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                              inner_spacing=front_bulkhead_mount_bolt_spacing_2,
                                              bulkhead_mount_bolt_d=front_bulkhead_mount_bolt_d,
                                              bulkhead_len=front_bulkhead_len,
                                              arm_pad_thickness=front_suspension_arm_pad_thickness) =
  let (barrel_size=front_lower_arm_mount_cutout_size(),
       barrel_len=barrel_size[1] - hinge_clearance,
       bolt_spacing_max_y=max(outer_spacing[1],
                              inner_spacing[1]),
       full_bolt_spacing_y=bolt_spacing_max_y + bulkhead_mount_bolt_d,
       y2=bulkhead_len
       - full_bolt_spacing_y
       - barrel_y_offset
       - barrel_len / 2
       + full_bolt_spacing_y / 2)
  y2 + arm_pad_thickness * 2;

function shock_tower_mount_size_x(bolt_d=front_shock_tower_bolt_d,
                                  pad_x=front_bulkhead_shock_tower_mount_pad_x,
                                  bolt_spacing=front_shock_tower_bolt_spacing) =
  bolt_spacing[0] + bolt_d + pad_x * 2;

function shock_tower_mount_size_y(bolt_d=front_shock_tower_bolt_d,
                                  pad_y=front_shock_tower_damper_holes_pad_y,
                                  bolt_spacing=front_shock_tower_bolt_spacing) =
  bolt_spacing[1] + bolt_d + pad_y * 2;

function front_bulkhead_bbox_size(bulkhead_w=front_bulkhead_w,
                                  bulkhead_l=front_bulkhead_len,
                                  support_extra_len=front_bulkhead_support_extra_len,
                                  extra_rear_len=front_bulkhead_extra_len,
                                  outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                  inner_spacing=front_bulkhead_mount_bolt_spacing_2,
                                  shock_tower_bolt_spacing=front_shock_tower_bolt_spacing,
                                  hinge_pad_x=front_bulkhead_mount_hinge_pad_x,
                                  shock_tower_mount_offset=front_bulkhead_shock_tower_mount_offset,
                                  bolt_d=front_bulkhead_mount_bolt_d,
                                  upper_holder_barrel_h=front_upper_suspension_holder_pin_barrel_h,
                                  upper_holder_thickness=front_upper_suspension_holder_thickness,
                                  arm_pad_thickness=front_suspension_arm_pad_thickness,
                                  arm_pad_holder_thickness=front_bulkhead_suspension_pad_thickness,
                                  shock_tower_pad_y=front_shock_tower_damper_holes_pad_y,
                                  shock_tower_pad_x=front_bulkhead_shock_tower_mount_pad_x,
                                  shock_tower_bolt_d=front_shock_tower_bolt_d,
                                  tower_pin_hole_y_offset=front_shock_tower_pin_y_offset,
                                  pin_d=front_upper_arm_hinge_barrel_hole_d,
                                  pad_y_top=front_bulkhead_shock_tower_mount_pad_y_top) =
  let (upper_holder_mount_thickness = upper_holder_barrel_h - upper_holder_thickness,
       rear_l = extra_rear_len + upper_holder_mount_thickness,
       shock_tower_x = shock_tower_mount_size_x(bolt_d=shock_tower_bolt_d,
                                                pad_x=shock_tower_pad_x,
                                                bolt_spacing=shock_tower_bolt_spacing),
       shock_tower_y = shock_tower_mount_size_y(bolt_d=shock_tower_bolt_d,
                                                pad_y=shock_tower_pad_y,
                                                bolt_spacing=shock_tower_bolt_spacing),
       hinge_len = max(outer_spacing[0], inner_spacing[0]) + hinge_pad_x * 2 + bolt_d,

       x = max(bulkhead_w, hinge_len, shock_tower_x),
       y = bulkhead_l + rear_l + support_extra_len + arm_pad_holder_thickness + arm_pad_thickness,
       z = shock_tower_mount_offset + shock_tower_y + pad_y_top)
  [x, y, z];

function front_bulkhead_upper_suspension_holder_z_pos(tower_pin_hole_y_offset=front_shock_tower_pin_y_offset,
                                                      shock_tower_mount_offset=front_bulkhead_shock_tower_mount_offset,
                                                      upper_holder_bore_y_offset=front_upper_suspension_holder_bolt_y_offset,
                                                      pin_d=front_upper_arm_hinge_barrel_hole_d,
                                                      upper_holder_bore_d=front_upper_suspension_holder_bolt_bore_d,
                                                      upper_holder_bolt_d=front_upper_suspension_holder_bolt_d) =
  let (bore_d = max(upper_holder_bore_d, upper_holder_bolt_d),
       bore_r =  bore_d / 2,
       common_pin_y = tower_pin_hole_y_offset + pin_d / 2,
       z_end = shock_tower_mount_offset
       + common_pin_y
       - upper_holder_bore_y_offset,
       z_center = z_end - bore_r,
       z_start = z_center - bore_r)
  [z_start, z_center, z_end];

// ─────────────────────────────────────────────────────────────────────────────
// Front shock tower shape functions
// ─────────────────────────────────────────────────────────────────────────────

function lower_damper_hole_y_pos(tilt_angle,
                                 damper_holes_n,
                                 total_h,
                                 damper_bolt_d,
                                 gap,
                                 pad_x,
                                 pad_y) =
  let (bb=bbox_holder_hull_samepads(tilt_angle=tilt_angle,
                                    damper_holes_n=damper_holes_n,
                                    bolt_d=damper_bolt_d,
                                    gap=gap,
                                    pad_x=pad_x,
                                    pad_y=pad_y),
       size=size2d_from_bbox(bb),
       size_y=size[1],
       lower_damper_hole_y=total_h + damper_bolt_d / 2 - size_y)
  lower_damper_hole_y;

function front_shock_damper_holes_poses(tilt_angle=front_shock_tower_damper_holes_angle,
                                        damper_holes_n=front_shock_tower_damper_holes_amount,
                                        bolt_d=front_shock_tower_shock_damper_bolt_d,
                                        gap=front_shock_tower_damper_holes_gap) =
  let (angle_cos=cos(tilt_angle),
       angle_sin=sin(tilt_angle),
       step=bolt_d + gap)
  [for (i = [0 : damper_holes_n - 1])
      let (base_offst = i * step,
           x = base_offst * angle_cos,
           y = base_offst * angle_sin)
        [x, y]];

function bbox_holder_hull_samepads(tilt_angle,
                                   damper_holes_n,
                                   bolt_d,
                                   gap,
                                   pad_x,
                                   pad_y) =
  let (ps = front_shock_damper_holes_poses(tilt_angle=tilt_angle,
                                           damper_holes_n=damper_holes_n,
                                           bolt_d=bolt_d, gap=gap),
       rx = bolt_d / 2 + pad_x,
       ry = bolt_d / 2 + pad_y,
       x  = map_idx(ps, 0),
       y  = map_idx(ps, 1))
  [[min(x) - rx, min(y) - ry],
   [max(x) + rx, max(y) + ry]];

function bbox2d_of_circles(ps, r) =
  let (x = map_idx(ps, 0),
       y = map_idx(ps, 1),
       minx = min(x),
       maxx = max(x),
       miny = min(y),
       maxy = max(y))
  [[minx - r, miny - r], [maxx + r, maxy + r]];

function size2d_from_bbox(b) = [b[1][0] - b[0][0],
                                b[1][1] - b[0][1]];

function front_shock_damper_holes_size2d(tilt_angle,
                                         damper_holes_n,
                                         bolt_d,
                                         gap) =
  let (ps = front_shock_damper_holes_poses(tilt_angle, damper_holes_n, bolt_d, gap),
       r  = bolt_d / 2,
       bb = bbox2d_of_circles(ps, r))
  size2d_from_bbox(bb);