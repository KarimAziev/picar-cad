/**
 * Module: Sidewall for battery holder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../parameters.scad>
use <../../lib/transforms.scad>
use <../../lib/debug.scad>
use <../../lib/functions.scad>

side_wall_type = "skeleton"; // [skeleton, enclosed]
side_wall_len  = 65.0;
side_wall_h    = 18;

function side_wall_get_depth_factors(side_wall_type) =
  let (is_skeleton = side_wall_type == "skeleton",
       center_cutout_depth_factor = is_skeleton
       ? 0.45
       : 0.25,
       edge_depth_cutout_factor = is_skeleton
       ? 0.4
       : 0.2)

  [edge_depth_cutout_factor, center_cutout_depth_factor]
  ;

function side_wall_get_cutout_depths(battery_dia,
                                     type) =
  let (factors = side_wall_get_depth_factors(type),
       edge_depth_cutout_factor = factors[0],
       center_cutout_depth_factor = factors[1],
       center_cutout_depth = center_cutout_depth_factor * battery_dia,
       edge_cutout_depth = edge_depth_cutout_factor * battery_dia)

  [edge_cutout_depth, center_cutout_depth];

module battery_holder_side_wall_2d(length=side_wall_len,
                                   h=side_wall_h,
                                   center_cutout_depth=4,
                                   center_cutout_upper_len,
                                   center_cutout_lower_len,
                                   edge_cutout_start=1.8,
                                   edge_cutout_end,
                                   edge_cutout_depth=4,
                                   edge_cutout_len,
                                   max_cutout_depth,
                                   fillet_r=1) {

  half_of_len = length / 2;

  center_cutout_h = with_default(max_cutout_depth, h - center_cutout_depth);

  edge_cutout_h = h - edge_cutout_depth;

  center_upper_len = with_default(center_cutout_upper_len, 0.3 * length);
  center_lower_len = with_default(center_cutout_lower_len, center_upper_len);

  edge_cutout_len = with_default(edge_cutout_len, 0.09 * length);
  edge_cutout_end = with_default(edge_cutout_end, edge_cutout_start);

  pts_start = [[0, half_of_len],
               [0, 0],
               [-h, 0]];

  edge_cutout_pts = edge_cutout_len > 0 ?
    [[-h, edge_cutout_start],  // 3
     [-edge_cutout_h, edge_cutout_end],
     [-edge_cutout_h, edge_cutout_len],
     [-h, edge_cutout_len]]
    : [];

  pts = concat(pts_start,
           // 3
               edge_cutout_pts,
               [[-h, half_of_len - center_upper_len / 2],
                [-center_cutout_h, half_of_len - center_lower_len / 2],
                [-center_cutout_h, half_of_len]]);

  fillet(r=fillet_r) {
    polygon(points=pts);
    translate([0, half_of_len * 2, 0]) {
      rotate([180, 0, 0]) {
        polygon(points=pts);
      }
    }
  }
}

module battery_holder_side_wall(type=side_wall_type,
                                front_rear_thickness,
                                battery_len=side_wall_len,
                                battery_dia=side_wall_h,
                                side_wall_thickness=2) {

  is_skeleton = type == "skeleton";
  depths = side_wall_get_cutout_depths(battery_dia=battery_dia,
                                       type=side_wall_type);

  center_cutout_upper_len_factor = is_skeleton ? 0.4 : 0.35;
  center_cutout_lower_len_factor = is_skeleton
    ? center_cutout_upper_len_factor
    : 0.3;

  edge_cutout_start = is_skeleton
    ? front_rear_thickness
    : front_rear_thickness + 0.4;
  edge_cutout_len_factor = is_skeleton ? 0.12 : 0.09;
  edge_cutout_len = edge_cutout_len_factor * battery_len;

  fillet_r = is_skeleton ? 0 : 1;

  edge_cutout_depth = depths[0];
  center_cutout_depth = depths[1];
  center_cutout_upper_len = center_cutout_upper_len_factor * battery_len;
  center_cutout_lower_len = center_cutout_lower_len_factor * battery_len;

  rotate([0, 90, 0]) {
    linear_extrude(height=side_wall_thickness, center=true) {
      battery_holder_side_wall_2d(length=battery_len + front_rear_thickness * 2,
                                  h=battery_dia,
                                  fillet_r=fillet_r,
                                  center_cutout_lower_len=center_cutout_lower_len,
                                  center_cutout_upper_len=center_cutout_upper_len,
                                  center_cutout_depth=center_cutout_depth,
                                  edge_cutout_depth=edge_cutout_depth,
                                  edge_cutout_start=edge_cutout_start,
                                  edge_cutout_len=edge_cutout_len);
    }
  }
}

battery_holder_side_wall(front_rear_thickness=smd_battery_holder_front_rear_thickness);