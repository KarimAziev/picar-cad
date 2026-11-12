/**
  * Module: Helpers for bulkhead slos
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../rc_params.scad>

use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../wishbone_arms/util.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_bulkhead_chassis_mount_origin_y
  ─────────────────────────────────────────────────────────────────────────────
  Locate the mounting pattern in native front-chassis coordinates.
  **Parameters:**
  - `barrel_y_offset`: Hinge barrel setback from the bulkhead's front edge.
  - `hinge_clearance`: Clearance removed from the arm's barrel length.
  **Returns:** Y translation shared by mounting cutters and clearance checks.
 */
function front_bulkhead_chassis_mount_origin_y(barrel_y_offset=front_bulkhead_barrel_y_offset,
                                               hinge_clearance=front_bulkhead_barrel_hinge_clearance) =
  let (barrel_len = front_lower_arm_mount_cutout_size()[1] - hinge_clearance,
       bolt_spacing_max_y = max(front_bulkhead_mount_bolt_spacing_1[1],
                                front_bulkhead_mount_bolt_spacing_2[1]),
       full_bolt_spacing_y = bolt_spacing_max_y + front_bulkhead_mount_bolt_d)
  front_bulkhead_len - full_bolt_spacing_y / 2 - barrel_y_offset - barrel_len / 2;

module front_bulkhead_housing_slots_non_center_y(barrel_y_offset=front_bulkhead_barrel_y_offset,
                                                 hinge_clearance=front_bulkhead_barrel_hinge_clearance) {
  translate([0,
             front_bulkhead_chassis_mount_origin_y(barrel_y_offset, hinge_clearance),
             0]) {
    front_bulkhead_chassis_mount_slots(center_y=false);
  }
}

module front_bulkhead_chassis_mount_slots(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                          inner_spacing=front_bulkhead_mount_bolt_spacing_2,
                                          d=front_bulkhead_mount_bolt_d,
                                          h=front_bulkhead_housing_h,
                                          padding=front_bulkhead_mount_bolt_padding,
                                          center_x=true,
                                          center_y=true) {

  front_bulkhead_chassis_with_slots_positions(outer_spacing=outer_spacing,
                                              inner_spacing=inner_spacing,
                                              d=d,
                                              padding=padding,
                                              center_x=center_x,
                                              center_y=center_y) {

    counterbore(d=d,
                h=h,
                sink=true,
                reverse=true,
                bore_d=($outer || $y_i == 1) ? front_bulkhead_mount_bolt_bore_d : 0,
                bore_h=front_bulkhead_mount_bolt_bore_h);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_bulkhead_chassis_mount_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return eight XYZ centers, outer group followed by inner group, in X/Y order.
  **Parameters:**
  - `outer_spacing`, `inner_spacing`: Hole-center spacings from `scad/rc_params.scad`.
  - `d`: Through-hole diameter; defines the uncentered pattern's edge margin.
  - `padding`: Edge gap between the upper outer and inner rows.
  - `center_x`, `center_y`: Center the reference outer pattern on each axis.
 */
function front_bulkhead_chassis_mount_positions(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                                inner_spacing=front_bulkhead_mount_bolt_spacing_2,
                                                d=front_bulkhead_mount_bolt_d,
                                                padding=front_bulkhead_mount_bolt_padding,
                                                center_x=true,
                                                center_y=true) =
  let (origin = [center_x ? -outer_spacing[0] / 2 - d / 2 : 0,
                 center_y ? -outer_spacing[1] / 2 - d / 2 : 0, 0],
       inner_y = outer_spacing[1] - inner_spacing[1] - d - padding)
  [for (group = [0, 1], x = [0, 1], y = [0, 1])
    let (spacing = group == 0 ? outer_spacing : inner_spacing)
    origin + [d / 2 + x * spacing[0],
              d / 2 + y * spacing[1] + (group == 0 ? 0 : inner_y), 0]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_bulkhead_housing_mount_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return mounting centers in the lower housing frame, centered on X/Y at Z=0.
  **Parameters:**
  - `barrel_y_offset`, `hinge_clearance`: Hinge placement values from `scad/rc_params.scad`.
  **Returns:** Eight XYZ points shared by the housing and its chassis plate.
 */
function front_bulkhead_housing_mount_positions(barrel_y_offset=front_bulkhead_barrel_y_offset,
                                                hinge_clearance=front_bulkhead_barrel_hinge_clearance) =
  [for (p = front_bulkhead_chassis_mount_positions(center_y=false))
    p + [0, front_bulkhead_chassis_mount_origin_y(barrel_y_offset,
                                                  hinge_clearance)
            - front_bulkhead_len / 2, 0]];

module front_bulkhead_chassis_with_slots_positions(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                                   inner_spacing=front_bulkhead_mount_bolt_spacing_2,
                                                   d=front_bulkhead_mount_bolt_d,
                                                   padding=front_bulkhead_mount_bolt_padding,
                                                   center_x=true,
                                                   center_y=true) {
  points = front_bulkhead_chassis_mount_positions(outer_spacing,
                                                  inner_spacing,
                                                  d,
                                                  padding,
                                                  center_x,
                                                  center_y);
  for (i = [0 : len(points) - 1]) {
    $outer = i < 4;
    $x_i = floor((i % 4) / 2);
    $y_i = i % 2;
    $key = str($x_i, "-", $y_i);
    spacing = $outer ? outer_spacing : inner_spacing;
    $full_x = spacing[0] + d;
    $full_y = spacing[1] + d;
    $full_size = [$full_x, $full_y];
    translate(points[i]) {
      children();
    }
  }
}

front_bulkhead_housing_slots_non_center_y();
