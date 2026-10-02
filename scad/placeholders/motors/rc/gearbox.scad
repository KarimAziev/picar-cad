/**
  * Module: Gearbox for a brushed RC motor in the style of MN78/MN82 gearboxes
  *
  * This gearbox is quite complex and has an asymmetric shape.
  * Because of this, it does not provide anchoring: it is positioned vertically
  * (as when the motor is placed vertically, like an unrotated `cylinder()`),
  * and on the X axis it is always centered on the motor drive shaft position.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../../bolt_parameters.scad>
include <../../../colors.scad>
include <../../../rc_params.scad>

use <../../../lib/debug.scad>
use <../../../lib/functions.scad>
use <../../../lib/plist.scad>
use <../../../lib/polygon_util.scad>
use <../../../lib/shapes2d.scad>
use <../../../lib/shapes3d.scad>
use <../../../lib/slots.scad>
use <../../../lib/transforms.scad>
use <../../../lib/trapezoids.scad>
use <../../bolt.scad>
use <../../suspension_arm_pin.scad>
use <motor_drive_shaft.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  gearbox_compute_params
  ─────────────────────────────────────────────────────────────────────────────

  Resolve gearbox dimensions, mounting interfaces and body extents.

  **Parameters:**
  - `plist`: Complete motor plist containing `gearbox`, `body`, `drive_shaft`
    and the optional shaft sleeve settings, as accepted by `gearbox`.

  **Returns:**
  A plist of resolved hardware dimensions and derived geometry. Input defaults
  are shared with `gearbox`; bracket padding and clearances are not included.
  - `mount_hole_positions`: `[rear, front]` hole-axis origins as `[x, 0, z]`
    in the unrotated gearbox frame. Hole axes run along Y. After the
    `gearmotor` rotation `[90, 0, 0]`, their bracket-plane coordinates are
    `[x, -z]`, before applying any bracket anchor translation.
  - `rear_mount_ear_y_min`, `rear_mount_ear_y_max`,
    `front_mount_ear_y_min`, `front_mount_ear_y_max`: mounting ear faces in
    the native Y direction. In `gearmotor`, these become heights above the
    parent surface; add `parent_thickness` for absolute assembly heights.
  - `gearbox_shaft_boss_d`: bearing boss outside diameter, including its wall.
  - `motor_od_xyz`, ear and gear positions, `pts`, `body_bbox`, and `bbox`
    retain the unrotated gearbox frame used by `gearbox`.
 */
function gearbox_compute_params(plist) =
  let (pinion_gear_h=plist_get("pinion_gear_h", plist),
       drive_seeve=plist_get("drive_seeve", plist, []),
       drive_seeve_od=plist_get("od", drive_seeve),
       drive_seeve_h=plist_get("h", drive_seeve),
       drive_seeve_dist=plist_get("outer_dist", drive_seeve),
       drive_seeve_shaft=plist_get("drive_seeve_shaft", plist, []),
       drive_seeve_shaft_od=plist_get("od", drive_seeve_shaft),
       drive_seeve_shaft_l=plist_get("l", drive_seeve_shaft),
       drive_seeve_inner_l=plist_get("inner_depth", drive_seeve_shaft),
       drive_seeve_pad_l=plist_get("pad_l", drive_seeve_shaft),
       gearbox_plist=plist_get("gearbox", plist),
       color=plist_get("color", gearbox_plist, metallic_silver_3),
       thickness=plist_get("thickness", gearbox_plist, 18),
       corner_r=plist_get("corner_r", gearbox_plist, 6),
       bottom_straight_w=plist_get("bottom_straight_w", gearbox_plist, 15.34),
       motor_pad=plist_get("motor_pad", gearbox_plist, 1.2),
       bearing_boss_wall=plist_get("bearing_boss_wall", gearbox_plist, 1.05),
       bearing_boss_h=plist_get("bearing_boss_h", gearbox_plist, 2.5),
       motor_shaft_y=plist_get("motor_shaft_y", gearbox_plist, 18.8),
       motor_outer_shaft_x_pad=plist_get("motor_outer_shaft_x_pad",
                                         gearbox_plist,
                                         11.65),
       outer_shaft_y_center=plist_get("outer_shaft_y_center",
                                      gearbox_plist,
                                      10.65),
       mount_ear_x_spacing=plist_get("mount_ear_x_spacing", gearbox_plist),
       mount_ear_y_spacing=plist_get("mount_ear_y_spacing", gearbox_plist),
       mount_bolt_d=plist_get("mount_bolt_d", gearbox_plist, m3_hole_dia),
       mount_cbore_d=plist_get("mount_cbore_d",
                               gearbox_plist,
                               m3_hole_dia * 2 + 0.2),
       mount_cbore_h=plist_get("mount_cbore_h", gearbox_plist, 3),
       motor_outer_shaft_x_spacing=plist_get("motor_x_shift", gearbox_plist, 16.0),
       side_ears=plist_get("side_ears", gearbox_plist),
       drive_shaft=plist_get("drive_shaft", plist),
       mount_ears=plist_get("mount_ears", gearbox_plist),
       upper_gear=plist_get("upper_gear", gearbox_plist),
       side_ears_poses=plist_get("poses", side_ears),
       side_ear_thickness=plist_get("thickness", side_ears, 8),
       side_ear_bolt_d=plist_get("bolt_d", side_ears, m2_hole_dia),
       side_ear_d=plist_get("d", side_ears, 5),
       outer_shaft_d=plist_get("d", drive_shaft, 3.95),
       outer_shaft_pad_l=plist_get("pad_l", drive_shaft),
       outer_shaft_l=plist_get("l", drive_shaft),
       outer_shaft_rear_len=plist_get("rear_l", drive_shaft),
       outer_shaft_hole_d=plist_get("hole_d", drive_shaft),
       outer_shaft_hole_edge_dist=plist_get("hole_edge_dist", drive_shaft),
       outer_shaft_bearing=plist_get("bearing", drive_shaft),
       bearing_od=plist_get("od", outer_shaft_bearing, 7),
       bearing_w=plist_get("w", outer_shaft_bearing, 2),
       mount_ear_x_dist=plist_get("mount_ear_x_dist", gearbox_plist),
       mount_ear_boss_d=plist_get("boss_d", mount_ears, 8.6),
       mount_ear_l=plist_get("ear_l", mount_ears, 6.7),
       mount_ear_thickness=plist_get("ear_thickness", mount_ears, 3.24),
       mount_ear_rear_boss_h=plist_get("rear_boss_h", mount_ears, 1.0),
       mount_ear_front_boss_h=plist_get("front_boss_h", mount_ears, 0.0),
       rear_mount_ear_y_center=plist_get("rear_mount_ear_y_center",
                                         gearbox_plist,
                                         outer_shaft_y_center),
       front_mount_ear_y_center=plist_get("front_mount_ear_y_center",
                                          gearbox_plist,
                                          rear_mount_ear_y_center),
       upper_gear_x=plist_get("x", upper_gear, 1.46),
       upper_gear_y=plist_get("y", upper_gear, 22.09),
       upper_gear_d=plist_get("d", upper_gear, 18.4),
       mount_ear_y_shift=plist_get("mount_ear_y_shift", gearbox_plist, 0),
       motor_body=plist_get("body", plist),
       motor_d=plist_get("d", motor_body, 24.3),
// computing
       mount_bolt_spacing=[mount_ear_x_spacing, mount_ear_y_spacing],
       gearbox_shaft_boss_d=bearing_od + bearing_boss_wall * 2,
       motor_od=motor_d + motor_pad * 2,
       pts=[[0, outer_shaft_y_center],
            [0, 0],
            [-bottom_straight_w, 0],
            [-motor_outer_shaft_x_spacing - motor_od / 2, motor_shaft_y],
            [upper_gear_x, upper_gear_y]],
       motor_od_xy_hinted=[-motor_outer_shaft_x_spacing, motor_shaft_y,
                           "Motor Od",
                           ["rotation", [0, 0, 180],
                            "halign", "left",
                            "circle_r", motor_od / 2,
                            "circle_alpha", 0.3]],
       motor_d_xy_hinted=[-motor_outer_shaft_x_spacing, motor_shaft_y,
                          "Motor",
                          ["rotation", [0, 0, 90],
                           "halign", "left",
                           "circle_r", motor_d / 2,
                           "circle_color", "gold",
                           "circle_alpha", 0.3]],
       motor_od_xyz=concat(take(motor_od_xy_hinted, 2), [0]),
       drive_shaft_xy_hinted=[0, outer_shaft_y_center,
                              "Drive shaft bearing",
                              ["rotation", [0, 0, 0],
                               "halign", "left",
                               "circle_r", gearbox_shaft_boss_d / 2,
                               "circle_alpha", 0.5,
                               "circle_color", "red"]],
       drive_shaft_xyz=concat(take(drive_shaft_xy_hinted, 2), [0]),
       upper_gear_xy_hinted=[upper_gear_x, upper_gear_y,
                             "Upper gear",
                             ["circle_r", upper_gear_d / 2,
                              "circle_alpha", 0.5,
                              "circle_color", cobalt_blue_dark_1,
                              "rotation", [0, 0, 0],
                              "halign", "center"]],
       upper_gear_xyz=concat(take(upper_gear_xy_hinted, 2), [0]),
       top_mount_ear_x=-mount_bolt_spacing[0]
       + mount_bolt_d / 2
       + outer_shaft_d / 2
       + mount_ear_x_dist,
       top_mount_ear_xy=[top_mount_ear_x,
                         rear_mount_ear_y_center,
                         "Top mount ear xyz",
                         ["rotation", [0, 0, 90],
                          "halign", "right",
                          "circle_r", mount_ear_boss_d / 2]],
       top_mount_ear_xyz=concat(take(top_mount_ear_xy, 2), [thickness]),
       lower_mount_ear_x=top_mount_ear_x + mount_ear_x_spacing,
       lower_mount_ear_xy_hinted=[lower_mount_ear_x, front_mount_ear_y_center],
       lower_mount_ear_xyz=concat(take(lower_mount_ear_xy_hinted, 2), [0]),
       mount_hole_front_z=-mount_bolt_d / 2 - mount_ear_y_shift,
       mount_hole_positions=[[top_mount_ear_x, 0,
                              mount_hole_front_z + mount_ear_y_spacing],
                             [lower_mount_ear_x, 0, mount_hole_front_z]],
       rear_mount_ear_y_min=rear_mount_ear_y_center - mount_ear_thickness / 2,
       rear_mount_ear_y_max=rear_mount_ear_y_center + mount_ear_thickness / 2,
       front_mount_ear_y_min=front_mount_ear_y_center - mount_ear_thickness / 2,
       front_mount_ear_y_max=front_mount_ear_y_center + mount_ear_thickness / 2,
       outer_shaft_max_d=max(outer_shaft_d,
                             gearbox_shaft_boss_d,
                             motor_outer_shaft_x_pad
                             + gearbox_shaft_boss_d),
       drive_shaft_box_full_l=drive_shaft_xy_hinted[1] + outer_shaft_max_d / 2,
       upper_gearbox_full_l=upper_gear_y + upper_gear_d / 2,
       right_l=max(upper_gearbox_full_l, drive_shaft_box_full_l),
       motor_od_full_l=max(motor_od_xyz[1] + motor_od / 2 - motor_pad,
                           right_l),
       side_ears_max_y=max([for (v = side_ears_poses) v[1]]) + side_ear_d / 2,
       side_ears_max_x=max([for (v = side_ears_poses) v[0]]) + side_ear_d / 2,
       side_ears_min_x=min([for (v = side_ears_poses) v[0]]) - side_ear_d / 2,
       left_l=motor_od_full_l,
       pts_min_x=min([for (v = pts) v[0]]),
       upper_gear_x_end=upper_gear_xyz[0] + upper_gear_d / 2,
       drive_shaft_x_end=motor_od_xyz[0] + outer_shaft_max_d / 2,
       bbox_min_x=min(side_ears_min_x, pts_min_x),
       max_body_x=max(drive_shaft_x_end, upper_gear_x_end),
       bbox_max_x=max(side_ears_max_x, max_body_x),
       body_w=abs(pts_min_x) + max_body_x,
       bbox_w=abs(pts_min_x) + bbox_max_x,
       max_body_l=max(right_l, left_l),
       max_bbox_l=max(max_body_l, side_ears_max_y),
       body_bbox=[body_w, max_body_l, thickness],
       bbox=[bbox_w, max_bbox_l, thickness])
       ["pinion_gear_h", pinion_gear_h,
        "drive_seeve_od", drive_seeve_od,
        "drive_seeve_h", drive_seeve_h,
        "drive_seeve_dist", drive_seeve_dist,
        "drive_seeve_shaft_od", drive_seeve_shaft_od,
        "drive_seeve_shaft_l", drive_seeve_shaft_l,
        "drive_seeve_inner_l", drive_seeve_inner_l,
        "drive_seeve_pad_l", drive_seeve_pad_l,
        "color", color,
        "thickness", thickness,
        "corner_r", corner_r,
        "motor_pad", motor_pad,
        "bearing_boss_h", bearing_boss_h,
        "motor_shaft_y", motor_shaft_y,
        "outer_shaft_y_center", outer_shaft_y_center,
        "mount_ear_y_spacing", mount_ear_y_spacing,
        "mount_bolt_d", mount_bolt_d,
        "mount_cbore_d", mount_cbore_d,
        "mount_cbore_h", mount_cbore_h,
        "motor_outer_shaft_x_spacing", motor_outer_shaft_x_spacing,
        "side_ears_poses", side_ears_poses,
        "side_ear_thickness", side_ear_thickness,
        "side_ear_bolt_d", side_ear_bolt_d,
        "side_ear_d", side_ear_d,
        "outer_shaft_d", outer_shaft_d,
        "outer_shaft_pad_l", outer_shaft_pad_l,
        "outer_shaft_l", outer_shaft_l,
        "outer_shaft_rear_len", outer_shaft_rear_len,
        "outer_shaft_hole_edge_dist", outer_shaft_hole_edge_dist,
        "outer_shaft_hole_d", outer_shaft_hole_d,
        "bearing_od", bearing_od,
        "bearing_w", bearing_w,
        "mount_ear_x_dist", mount_ear_x_dist,
        "mount_ear_boss_d", mount_ear_boss_d,
        "mount_ear_l", mount_ear_l,
        "mount_ear_thickness", mount_ear_thickness,
        "mount_ear_rear_boss_h", mount_ear_rear_boss_h,
        "mount_ear_front_boss_h", mount_ear_front_boss_h,
        "rear_mount_ear_y_center", rear_mount_ear_y_center,
        "front_mount_ear_y_center", front_mount_ear_y_center,
        "upper_gear_d", upper_gear_d,
        "mount_ear_y_shift", mount_ear_y_shift,
        "bottom_straight_w", bottom_straight_w,
        "motor_d", motor_d,
        "mount_hole_positions", mount_hole_positions,
        "rear_mount_ear_y_min", rear_mount_ear_y_min,
        "rear_mount_ear_y_max", rear_mount_ear_y_max,
        "front_mount_ear_y_min", front_mount_ear_y_min,
        "front_mount_ear_y_max", front_mount_ear_y_max,
        "mount_bolt_spacing", mount_bolt_spacing,
        "gearbox_shaft_boss_d" , gearbox_shaft_boss_d,
        "motor_od" , motor_od,
        "pts" , pts,
        "motor_od_xy_hinted" , motor_od_xy_hinted,
        "motor_d_xy_hinted" , motor_d_xy_hinted,
        "motor_od_xyz" , motor_od_xyz,
        "drive_shaft_xy_hinted" , drive_shaft_xy_hinted,
        "drive_shaft_xyz" , drive_shaft_xyz,
        "upper_gear_xy_hinted" , upper_gear_xy_hinted,
        "upper_gear_xyz" , upper_gear_xyz,
        "top_mount_ear_x" , top_mount_ear_x,
        "top_mount_ear_xy" , top_mount_ear_xy,
        "top_mount_ear_xyz" , top_mount_ear_xyz,
        "lower_mount_ear_x" , lower_mount_ear_x,
        "lower_mount_ear_xy_hinted" , lower_mount_ear_xy_hinted,
        "lower_mount_ear_xyz" , lower_mount_ear_xyz,
        "outer_shaft_max_d" , outer_shaft_max_d,
        "drive_shaft_box_full_l" , drive_shaft_box_full_l,
        "upper_gearbox_full_l" , upper_gearbox_full_l,
        "right_l" , right_l,
        "motor_od_full_l" , motor_od_full_l,
        "side_ears_max_y" , side_ears_max_y,
        "side_ears_max_x" , side_ears_max_x,
        "side_ears_min_x" , side_ears_min_x,
        "left_l" , left_l,
        "pts_min_x" , pts_min_x,
        "upper_gear_x_end" , upper_gear_x_end,
        "drive_shaft_x_end" , drive_shaft_x_end,
        "bbox_min_x" , bbox_min_x,
        "max_body_x" , max_body_x,
        "bbox_max_x" , bbox_max_x,
        "body_w" , body_w,
        "bbox_w" , bbox_w,
        "max_body_l" , max_body_l,
        "max_bbox_l" , max_bbox_l,
        "body_bbox" , body_bbox,
        "bbox" , bbox];

module gearbox(plist,
               show_bearing=true,
               show_drive_shaft=true,
               show_mount_bolts=true,
               show_nuts=true,
               show_shaft_seeve=true,
               show_extra_drive_shaft=true,
               slot_mode=false,
               debug=false,
               parent_thickness=0) {
  params = gearbox_compute_params(plist);
  pinion_gear_h = plist_get("pinion_gear_h", params);
  drive_seeve_od = plist_get("drive_seeve_od", params);
  drive_seeve_h = plist_get("drive_seeve_h", params);
  drive_seeve_dist = plist_get("drive_seeve_dist", params);
  drive_seeve_shaft_od = plist_get("drive_seeve_shaft_od", params);
  drive_seeve_shaft_l = plist_get("drive_seeve_shaft_l", params);
  drive_seeve_inner_l = plist_get("drive_seeve_inner_l", params);
  drive_seeve_pad_l = plist_get("drive_seeve_pad_l", params);
  color = plist_get("color", params);
  thickness = plist_get("thickness", params);
  corner_r = plist_get("corner_r", params);
  motor_pad = plist_get("motor_pad", params);
  bearing_boss_h = plist_get("bearing_boss_h", params);
  motor_shaft_y = plist_get("motor_shaft_y", params);
  outer_shaft_y_center = plist_get("outer_shaft_y_center", params);
  mount_ear_y_spacing = plist_get("mount_ear_y_spacing", params);
  mount_bolt_d = plist_get("mount_bolt_d", params);
  mount_cbore_d = plist_get("mount_cbore_d", params);
  mount_cbore_h = plist_get("mount_cbore_h", params);
  motor_outer_shaft_x_spacing = plist_get("motor_outer_shaft_x_spacing",
                                          params);
  side_ears_poses = plist_get("side_ears_poses", params);
  side_ear_thickness = plist_get("side_ear_thickness", params);
  side_ear_bolt_d = plist_get("side_ear_bolt_d", params);
  side_ear_d = plist_get("side_ear_d", params);
  outer_shaft_d = plist_get("outer_shaft_d", params);
  outer_shaft_pad_l = plist_get("outer_shaft_pad_l", params);
  outer_shaft_l = plist_get("outer_shaft_l", params);
  outer_shaft_rear_len = plist_get("outer_shaft_rear_len", params);
  outer_shaft_hole_d = plist_get("outer_shaft_hole_d", params);
  outer_shaft_hole_edge_dist = plist_get("outer_shaft_hole_edge_dist", params);
  bearing_od = plist_get("bearing_od", params);
  bearing_w = plist_get("bearing_w", params);
  mount_ear_boss_d = plist_get("mount_ear_boss_d", params);
  mount_ear_l = plist_get("mount_ear_l", params);
  mount_ear_thickness = plist_get("mount_ear_thickness", params);
  mount_ear_rear_boss_h = plist_get("mount_ear_rear_boss_h", params);
  mount_ear_front_boss_h = plist_get("mount_ear_front_boss_h", params);
  upper_gear_d = plist_get("upper_gear_d", params);
  mount_ear_y_shift = plist_get("mount_ear_y_shift", params);

  gearbox_shaft_boss_d = plist_get("gearbox_shaft_boss_d", params);
  motor_od = plist_get("motor_od", params);
  pts = plist_get("pts", params);
  motor_od_xy_hinted = plist_get("motor_od_xy_hinted", params);
  motor_d_xy_hinted = plist_get("motor_d_xy_hinted", params);
  motor_od_xyz = plist_get("motor_od_xyz", params);
  drive_shaft_xy_hinted = plist_get("drive_shaft_xy_hinted", params);
  drive_shaft_xyz = plist_get("drive_shaft_xyz", params);
  upper_gear_xy_hinted = plist_get("upper_gear_xy_hinted", params);
  upper_gear_xyz = plist_get("upper_gear_xyz", params);

  top_mount_ear_xy = plist_get("top_mount_ear_xy", params);
  top_mount_ear_xyz = plist_get("top_mount_ear_xyz", params);
  lower_mount_ear_xyz = plist_get("lower_mount_ear_xyz", params);
  outer_shaft_max_d = plist_get("outer_shaft_max_d", params);
  right_l = plist_get("right_l", params);

  mount_hole_positions = plist_get("mount_hole_positions", params);
  rear_mount_ear_y_max = plist_get("rear_mount_ear_y_max", params);
  front_mount_ear_y_max = plist_get("front_mount_ear_y_max", params);

  // render

  module _cbore(h) {
    counterbore(d=mount_bolt_d,
                h=h,
                bore_d=mount_cbore_d,
                bore_h=mount_cbore_h,
                reverse=false,
                sink=true);
  }

  module _with_mount_hole(index) {
    translate(mount_hole_positions[index]) {
      rotate([90, 0, 0]) {
        children();
      }
    }
  }

  module _mount_holes() {
    for (index = [0:1]) {
      _with_mount_hole(index) {
        let (depth = index == 0 ? rear_mount_ear_y_max : front_mount_ear_y_max,
             total_dep = depth + parent_thickness) {
          translate([0, 0, -depth]) {
            _cbore(h=total_dep);
          }
        }
      }
    }
  }

  module _mount_bolts() {
    for (index = [0:1]) {
      _with_mount_hole(index) {
        let (depth = index == 0 ? rear_mount_ear_y_max : front_mount_ear_y_max,
             total_dep = depth + parent_thickness) {
          translate([0, 0, -depth - mount_cbore_h - 0.1]) {
            bolt(d=mount_bolt_d,
                 show_nut=show_nuts,
                 nut_head_distance=total_dep - mount_cbore_h,
                 h=total_dep);
          }
        }
      }
    }
  }

  module _circles() {
    translate([0, 0, 0]) {
      let (y1 = motor_od / 2 - motor_pad,
           y2 = right_l) {
        difference() {
          translate(motor_od_xyz) {
            circle(d=motor_od);
          }
          translate([motor_od_xyz[0], 0, 0]) {
            translate([-motor_od / 2, max(y2, y1), 0]) {
              square([motor_od, motor_od], center=false);
            }
          }
        }
      }
    }
    translate(drive_shaft_xyz) {
      circle(d=outer_shaft_max_d);
    }
    translate(upper_gear_xyz) {
      circle(d=upper_gear_d, $fn=20);
    }
  }

  if (slot_mode) {
    _mount_holes();
  } else {
    difference() {
      maybe_color(color=color) {
        difference() {
          translate([0, 0, thickness / 2]) {
            union() {
              linear_extrude(height=thickness, center=true) {
                hull() {
                  _circles();

                  offset_vertices_2d(r=corner_r) {
                    polygon(pts);
                  }
                }
              }
              linear_extrude(height=side_ear_thickness, center=true) {
                _gearbox_side_ears(ears=side_ears_poses,
                                   bolt_d=side_ear_bolt_d,
                                   ear_d=side_ear_d);
              }
            }
          }
          translate([0, outer_shaft_y_center, 0]) {
            counterbore(d=outer_shaft_d, h=thickness, $fn=20);
          }
          translate([0, 0, -0.1]) {
            linear_extrude(height=thickness + 0.1, center=false) {
              _gearbox_side_ears(ears=side_ears_poses,
                                 bolt_d=side_ear_bolt_d,
                                 ear_d=side_ear_d,
                                 slot_mode=true);
            }
          }

          translate([-motor_outer_shaft_x_spacing, motor_shaft_y, -0.1]) {
            cylinder(d=motor_od + 0.4, h=pinion_gear_h + 0.1);
          }
        }
        // drive shaft bearing holder
        translate([0, outer_shaft_y_center, -bearing_boss_h]) {
          ring(od=gearbox_shaft_boss_d,
               d=bearing_od,
               h=thickness + bearing_boss_h * 2);
        }

        // upmost mount ear
        translate(top_mount_ear_xyz) {
          cylinder(d=mount_ear_boss_d,
                   h=mount_ear_rear_boss_h);
          cuboid(size=[mount_ear_boss_d,
                       mount_ear_thickness,
                       (mount_ear_y_spacing - thickness)
                       - mount_ear_y_shift + mount_ear_l]);
        }

        // lower mount ear
        translate(lower_mount_ear_xyz) {
          cylinder(d=mount_ear_boss_d,
                   h=mount_ear_front_boss_h);
          cuboid(size=[mount_ear_boss_d,
                       mount_ear_thickness,
                       mount_bolt_d + mount_ear_y_shift
                       + mount_ear_l],
                 anchor=[0, 0, -1]);
        }
      }
      _mount_holes();
    }
    if (show_bearing) {
      color(metallic_silver_4, alpha=1) {
        translate([0, outer_shaft_y_center, thickness]) {
          ring(od=bearing_od,
               d=outer_shaft_d,
               h=bearing_w);
        }
      }
    }

    if (show_mount_bolts) {
      _mount_bolts();
    }

    if (show_drive_shaft && outer_shaft_l) {
      translate([0,
                 outer_shaft_y_center,
                 -outer_shaft_l
                 + thickness
                 + outer_shaft_rear_len]) {
        motor_drive_shaft(d=outer_shaft_d,
                          l=outer_shaft_l,
                          hole_d=outer_shaft_hole_d,
                          hole_edge_dist=outer_shaft_hole_edge_dist,
                          pad_l=outer_shaft_pad_l,
                          pad_w=plist_get("flat_d", plist_get("drive_shaft", plist), outer_shaft_d / 2),
                          pad_horizontal_one_side=!plist_get("flat_both_sides", plist_get("drive_shaft", plist), false));
      }
    }

    let (dist = with_default(drive_seeve_dist, 0),
         seeve_dist = thickness + bearing_boss_h + dist,
         shaft_seeve_depth = with_default(drive_seeve_inner_l,
                                          drive_seeve_pad_l)) {

      translate([0, outer_shaft_y_center, seeve_dist]) {
        if (show_shaft_seeve && drive_seeve_od && drive_seeve_h) {
          color(metallic_silver_3, alpha=0.7) {
            cylinder(d=drive_seeve_od, h=drive_seeve_h);
          }
        }
        if (show_extra_drive_shaft && drive_seeve_h
            && drive_seeve_shaft_od && drive_seeve_shaft_l) {
          translate([0, 0, drive_seeve_h - shaft_seeve_depth]) {

            color(jet_black, alpha=1) {
              motor_drive_shaft(d=drive_seeve_shaft_od,
                                l=drive_seeve_shaft_l,
                                pad_l=drive_seeve_pad_l);
            }
          }
        }
      }
    }
  }

  if (debug) {
    translate([0, 0, thickness + 30 + 0.1]) {
      debug_polygon_text(points=pts);
      let (extra_pts = [motor_od_xy_hinted,
                        motor_d_xy_hinted,
                        upper_gear_xy_hinted,
                        drive_shaft_xy_hinted,
                        top_mount_ear_xy]) {
        debug_polygon_text(points=extra_pts, color=cobalt_blue_metallic);
      }
    }
  }
}

module _with_side_ear_poses(ears=[]) {
  if (ears && len(ears) > 0) {
    ears = sort_clockwise(ears);
    for (ear = ears) {
      let (x = ear[0],
           y = ear[1]) {
        translate([x, y, 0]) {
          children();
        }
      }
    }
  }
}

module _gearbox_side_ears(slot_mode=false,
                          ears=[],
                          bolt_d,
                          ear_d) {
  if (ears && len(ears) > 0) {
    if (slot_mode) {
      _with_side_ear_poses(ears) {
        circle(d=bolt_d, $fn=20);
      }
    } else {
      hull() {
        _with_side_ear_poses(ears) {
          circle(d=ear_d, $fn=20);
        }
      }
    }
  }
}

gearbox(plist=motor_plist,
        debug=false,
        show_mount_bolts=true,
        parent_thickness=6,
        show_drive_shaft=true,
        show_shaft_seeve=true,
        show_extra_drive_shaft=false);
