/**
 * Module: Mini ATM Blade Fuse Holder body
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

use <../wire.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/trapezoids.scad>
use <../lib/transforms.scad>
use <../lib/plist.scad>
use <../lib/holes.scad>
use <../lib/stairs.scad>

function atm_fuse_holder_full_thickness(body_thickness, rib_thickness) =
  body_thickness + rib_thickness * 2;

function atm_fuse_holder_full_len(plist) =
  body_thickness + rib_thickness * 2;

module atm_fuse_holder_body_cap_collar(size=[atm_fuse_holder_2_mounting_hole_l,
                                             atm_fuse_holder_2_mounting_hole_h,
                                             atm_fuse_holder_2_mounting_hole_depth],
                                       r=atm_fuse_holder_2_mounting_hole_r,
                                       fuse_holes_spacing=[8, 4],
                                       fuse_hole_size=[6.0, 1.82],
                                       fuse_holes_pad_x=4,
                                       fuse_holes_pad_y=0,
                                       rib_thickness=1,
                                       rib_h=0.8,
                                       colr=matte_black,
                                       rib_colr=matte_black_2,
                                       rib_positions=[0.5]) {
  x = size[0];
  y = size[1];
  z = size[2];
  corner_rad = r;
  rib_x = x + rib_thickness * 2;
  rib_y = y + rib_thickness * 2;

  module rib() {
    linear_extrude(height=rib_h, center=false) {
      rounded_rect([rib_x, rib_y],
                   r=corner_rad,
                   center=true);
    }
  }

  difference() {
    union() {
      difference() {
        color(colr, alpha=1) {
          linear_extrude(height=z, center=false) {
            rounded_rect([x,
                          y],
                         r=corner_rad,
                         center=true);
          }
        }
        rect_slot(h=min(2, z * 0.5),
                  reverse=true,
                  size=[fuse_holes_spacing[0]
                        + fuse_hole_size[0]
                        + fuse_holes_pad_x,
                        fuse_holes_spacing[1] + fuse_hole_size[1]
                        + fuse_holes_pad_y],
                  center=true);
      }

      color(rib_colr, alpha=1) {
        for (factor = rib_positions) {
          let (pos = (z * factor) - rib_h / 2) {
            translate([0, 0, pos]) {
              rib();
            }
          }
        }
      }
    }
    four_corner_children(size=fuse_holes_spacing, center=true) {
      upper = ($x_i == 0 && $y_i == 0);
      lower = ($x_i == 1 && $y_i == 1);
      if (upper || lower) {
        translate([0,
                   upper ? fuse_holes_spacing[1] / 2 - fuse_hole_size[1] / 2:
                   -fuse_holes_spacing[1] / 2 + fuse_hole_size[1] / 2,
                   0]) {
          rect_slot(h=z,
                    reverse=true,
                    size=fuse_hole_size,
                    center=true);
        }
      }
    }
  }
}

module atm_fuse_holder_body(size=[atm_fuse_holder_2_body_bottom_l,
                                  atm_fuse_holder_2_body_thickness,
                                  atm_fuse_holder_2_body_h,
                                  atm_fuse_holder_2_body_top_l],
                            round_side="top",
                            color=matte_black_2,
                            wiring=["d", atm_fuse_holder_2_body_wiring_d,
                                    "socket_type", "cylinder",
                                    "socket_type_len", 5,
                                    "color", red_1,
                                    "cutted_len", 3,
                                    "left_pts", [[25, 0, 0]],
                                    "right_pts", [[-25, 0, 0]]],
                            corner_rad,
                            rib,
                            cap_collar) {

  wiring = with_default(wiring, []);
  rib = with_default(rib, []);
  cap_collar_plist = with_default(cap_collar, []);

  rib_colr = plist_get("color", rib, matte_black);
  rib_thickness = plist_get("thickness",
                            rib,
                            atm_fuse_holder_2_body_rib_thickness);

  thickness = size[1];
  h = size[2];
  w = size[0] - rib_thickness * 2;

  rib_h = plist_get("h", rib, atm_fuse_holder_2_body_rib_h);
  rib_l = plist_get("l", rib, atm_fuse_holder_2_body_rib_l);
  rib_n = plist_get("n", rib, atm_fuse_holder_2_body_rib_n);
  rib_distance = plist_get("distance_from_top", rib, 0);

  wiring_d = plist_get("d", wiring, atm_fuse_holder_2_body_wiring_d);
  wiring_base_type = plist_get("socket_type", wiring, "sphere");
  wiring_left_pts = plist_get("left_pts",
                              wiring,
                              [[25, 0, 0]]);
  wiring_right_pts = plist_get("right_pts",
                               wiring,
                               [[-25, 0, 0]]);

  wiring_cutted_len = plist_get("cutted_len",
                                wiring,
                                3);

  wiring_base_type_len = plist_get("socket_type_len", wiring, 4);
  wiring_color = plist_get("color", wiring, red_1);
  wiring_base_d = plist_get("base_d", wiring, min(thickness, h) * 0.8);

  union() {
    color(color, alpha=1) {
      trapezoid_vertical(size=[w, thickness, h, size[3]],
                         r=corner_rad,
                         round_side=round_side);
    }

    color(rib_colr, alpha=1) {
      mirror_copy([0, 1, 0]) {
        let (max_rib_dist = h - rib_h) {
          translate([0,
                     thickness / 2,
                     h - rib_h / 2 - min(max_rib_dist, rib_distance)]) {
            rotate([0, 90, 90]) {
              stairs_solid(total_size=[rib_h,
                                       rib_l,
                                       rib_thickness],
                           step_count=rib_n);
            }
          }
        }
      }
    }

    translate([0, 0, h]) {
      atm_fuse_holder_body_cap_collar(size=plist_get("size",
                                                     cap_collar_plist,
                                                     [atm_fuse_holder_2_mounting_hole_l,
                                                      atm_fuse_holder_2_mounting_hole_h,
                                                      atm_fuse_holder_2_mounting_hole_depth]),
                                      r=plist_get("r", cap_collar_plist, atm_fuse_holder_2_mounting_hole_r),
                                      fuse_holes_spacing=plist_get("fuse_holes_spacing", cap_collar_plist, [8, 4]),
                                      fuse_hole_size=plist_get("fuse_hole_size", cap_collar_plist, [6.0, 1.82]),
                                      fuse_holes_pad_x=plist_get("fuse_holes_pad_x", cap_collar_plist, 4),
                                      fuse_holes_pad_y=plist_get("fuse_holes_pad_y", cap_collar_plist, 0),
                                      rib_thickness=plist_get("rib_thickness", cap_collar_plist, 1),
                                      rib_h=plist_get("rib_h", cap_collar_plist, 0.8),
                                      colr=plist_get("colr", cap_collar_plist, matte_black),
                                      rib_colr=plist_get("rib_colr", cap_collar_plist, matte_black_2),
                                      rib_positions=plist_get("rib_positions", cap_collar_plist, [0.5]));
    }
    color(color, alpha=1) {
      mirror_copy([1, 0, 0]) {
        translate([w / 2, 0, h / 2]) {
          rotate([0, 90, 0]) {
            cylinder(d=wiring_base_d, h=wiring_base_type_len);
          }
          if (wiring_base_type == "sphere") {
            translate([wiring_base_type_len, 0, 0]) {
              sphere(r=wiring_base_d / 2, $fn=20);
            }
          }
        }
      }
    }

    if (!is_undef(wiring_left_pts) && len(wiring_left_pts) > 0) {
      translate([w / 2, 0, h / 2]) {
        wire_path(points=concat([[-w / 2, 0, 0]], wiring_left_pts),
                  d=wiring_d,
                  colr=wiring_color,
                  cut_len=wiring_cutted_len);
      }
    }
    if (!is_undef(wiring_right_pts) && len(wiring_right_pts) > 0) {
      translate([-w / 2, 0, h / 2]) {
        rotate([0, 0, 180]) {
          wire_path(points=concat([[-w / 2, 0, 0]], wiring_right_pts),
                    d=wiring_d,

                    colr=wiring_color,
                    cut_len=wiring_cutted_len);
        }
      }
    }
  }
}

module atm_fuse_holder_cap(size=[atm_fuse_holder_2_lid_top_l,
                                 atm_fuse_holder_2_lid_thickness,
                                 atm_fuse_holder_2_lid_h,
                                 atm_fuse_holder_2_lid_bottom_l,],
                           rib,
                           round_side="top",
                           corner_rad=2,
                           cap_collar_size=[atm_fuse_holder_2_mounting_hole_l,
                                            atm_fuse_holder_2_mounting_hole_h,
                                            atm_fuse_holder_2_mounting_hole_depth],
                           corner_rad,
                           color) {
  rib = with_default(rib, []);

  rib_colr = plist_get("color", rib, matte_black);
  rib_thickness = plist_get("thickness",
                            rib,
                            atm_fuse_holder_2_lid_rib_thickness);

  thickness = size[1];
  w = size[0] - rib_thickness * 2;
  h = size[2];

  rib_h = plist_get("h", rib, atm_fuse_holder_2_lid_rib_h);
  rib_l = plist_get("l", rib, atm_fuse_holder_2_lid_rib_l);
  rib_n = plist_get("n", rib, atm_fuse_holder_2_lid_rib_n);
  rib_distance = plist_get("distance_from_top", rib, 0);

  difference() {
    union() {
      color(color, alpha=1) {
        trapezoid_vertical(size=[w, thickness, h, size[3]],
                           r=corner_rad,
                           round_side=round_side);
      }

      difference() {
        color(rib_colr, alpha=1) {
          mirror_copy([0, 1, 0]) {
            let (max_rib_dist = h - rib_h) {
              translate([0,
                         thickness / 2,
                         h - rib_h / 2 - min(max_rib_dist, rib_distance)]) {
                rotate([0, 90, 90]) {
                  stairs_solid(total_size=[rib_h,
                                           rib_l,
                                           rib_thickness],
                               step_count=rib_n);
                }
              }
            }
          }
        }
      }
    }
    let (cutout_h = cap_collar_size[2]) {
      translate([0, 0, -0.2]) {
        rect_slot(h=cap_collar_size[2],
                  r=corner_rad,
                  reverse=true,
                  size=cap_collar_size,
                  center=true);
      }
    }
  }
}

module atm_fuse_holder_from_spec(plist) {
  plist = with_default(plist, []);
  body_plist = plist_get("body", plist, []);
  size = plist_get("size",
                   body_plist,
                   [atm_fuse_holder_2_body_bottom_l,
                    atm_fuse_holder_2_body_thickness,
                    atm_fuse_holder_2_body_h,
                    atm_fuse_holder_2_body_top_l]);
  color = plist_get("color", plist, matte_black_2);
  show_cap = plist_get("show_cap",
                       plist,
                       true);
  show_body = plist_get("show_body",
                        plist,
                        true);
  wiring = plist_get("wiring",
                     plist,
                     ["d", atm_fuse_holder_2_body_wiring_d,
                      "socket_type", "cylinder",
                      "socket_type_len", 5,
                      "color", red_1,
                      "cutted_len", 3,
                      "left_pts", [[25, 0, 0]],
                      "right_pts", [[-25, 0, 0]]]);
  body_corner_rad = plist_get("corner_rad", body_plist, 2);
  body_round_side = plist_get("round_side", body_plist, "bottom");

  rib = plist_get("rib",
                  body_plist,
                  ["h", atm_fuse_holder_2_body_rib_h,
                   "l", atm_fuse_holder_2_body_rib_l,
                   "n", atm_fuse_holder_2_body_rib_n,
                   "thickness", atm_fuse_holder_2_body_rib_thickness,
                   "distance_from_top", 0]);
  cap_collar = plist_get("cap_collar",
                         plist,
                         ["size", [atm_fuse_holder_2_mounting_hole_l,
                                   atm_fuse_holder_2_mounting_hole_h,
                                   atm_fuse_holder_2_mounting_hole_depth],
                          "r", atm_fuse_holder_2_mounting_hole_r,
                          "fuse_holes_spacing", [8, 4],
                          "fuse_hole_size", [6.0, 1.82],
                          "fuse_holes_pad_x", 4,
                          "fuse_holes_pad_y", 0,
                          "rib_thickness", 1,
                          "rib_h", 0.8,
                          "colr", matte_black,
                          "rib_colr", matte_black_2,
                          "rib_positions", [0.5]]);
  cap_plist = plist_get("cap",
                        plist,
                        ["size", [atm_fuse_holder_2_lid_top_l,
                                  atm_fuse_holder_2_lid_thickness,
                                  atm_fuse_holder_2_lid_h,
                                  atm_fuse_holder_2_lid_bottom_l,],
                         "corner_rad", 2,
                         "round_side", "top",
                         "color", matte_black_2,
                         "rib", ["h", atm_fuse_holder_2_lid_rib_h,
                                 "l", atm_fuse_holder_2_lid_rib_l,
                                 "n", atm_fuse_holder_2_lid_rib_n,
                                 "thickness", atm_fuse_holder_2_lid_rib_thickness,
                                 "distance_from_top", atm_fuse_holder_2_lid_rib_distance]]);

  union() {
    if (show_body) {
      atm_fuse_holder_body(size=size,
                           round_side=body_round_side,
                           color=color,
                           wiring=wiring,
                           corner_rad=body_corner_rad,
                           rib=rib,
                           cap_collar=cap_collar);
    }

    if (show_cap) {
      translate([0, 0, size[2]]) {
        atm_fuse_holder_cap(size=plist_get("size", cap_plist, [atm_fuse_holder_2_lid_bottom_l,
                                                               atm_fuse_holder_2_lid_thickness,
                                                               atm_fuse_holder_2_lid_h,
                                                               atm_fuse_holder_2_lid_top_l]),
                            cap_collar_size=plist_get("size", cap_collar, [atm_fuse_holder_2_mounting_hole_l,
                                                                           atm_fuse_holder_2_mounting_hole_h,
                                                                           atm_fuse_holder_2_mounting_hole_depth]),
                            corner_rad=plist_get("corner_rad", cap_plist, 0),
                            color=color,

                            rib=plist_get("rib",
                                          cap_plist,
                                          ["h", atm_fuse_holder_2_lid_rib_h,
                                           "l", atm_fuse_holder_2_lid_rib_l,
                                           "n", atm_fuse_holder_2_lid_rib_n,
                                           "thickness", atm_fuse_holder_2_lid_rib_thickness,
                                           "distance_from_top", atm_fuse_holder_2_lid_rib_distance]));
      }
    }
  }
}

atm_fuse_holder_from_spec(atm_fuse_default_plist);
