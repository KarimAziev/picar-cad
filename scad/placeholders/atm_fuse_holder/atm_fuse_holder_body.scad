/**
 * Module: Mini ATM Blade Fuse Holder body
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../parameters.scad>
include <../../colors.scad>

use <../../lib/wire.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/trapezoids.scad>
use <../../lib/transforms.scad>
use <../../lib/plist.scad>
use <../../lib/holes.scad>
use <../../lib/stairs.scad>
use <../../lib/slots.scad>
use <atm_fuse_holder_cap.scad>
use <atm_fuse_holder_cap_collar.scad>

module atm_fuse_holder_body(size=[atm_fuse_holder_body_bottom_l,
                                  atm_fuse_holder_body_thickness,
                                  atm_fuse_holder_body_h,
                                  atm_fuse_holder_body_top_l],
                            round_side="top",
                            color=matte_black_2,
                            wiring=["d", atm_fuse_holder_body_wiring_d,
                                    "socket_type", "cylinder",
                                    "socket_type_len", 4,
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
                            atm_fuse_holder_body_rib_thickness);

  thickness = size[1];
  h = size[2];
  w = size[0] - rib_thickness * 2;

  rib_h = plist_get("h", rib, atm_fuse_holder_body_rib_h);
  rib_l = plist_get("l", rib, atm_fuse_holder_body_rib_l);
  rib_n = plist_get("n", rib, atm_fuse_holder_body_rib_n);
  rib_distance = plist_get("distance_from_top", rib, 0);

  wiring_d = plist_get("d", wiring, atm_fuse_holder_body_wiring_d);
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
                                                     [atm_fuse_holder_mounting_hole_l,
                                                      atm_fuse_holder_mounting_hole_h,
                                                      atm_fuse_holder_mounting_hole_depth]),
                                      r=plist_get("r", cap_collar_plist, atm_fuse_holder_mounting_hole_r),
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
