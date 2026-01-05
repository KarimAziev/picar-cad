/**
 * Module: The ATM fuse holder cap
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../parameters.scad>
include <../../colors.scad>

use <../../lib/trapezoids.scad>
use <../../lib/transforms.scad>
use <../../lib/plist.scad>
use <../../lib/stairs.scad>
use <../../lib/slots.scad>

module atm_fuse_holder_cap(size=[atm_fuse_holder_cap_top_l,
                                 atm_fuse_holder_cap_thickness,
                                 atm_fuse_holder_cap_h,
                                 atm_fuse_holder_cap_bottom_l],
                           rib,
                           round_side="top",
                           corner_rad=2,
                           hole_size,
                           color=matte_black_2) {

  rib = with_default(rib, []);

  rib_colr = plist_get("color", rib, matte_black);
  rib_thickness = plist_get("thickness",
                            rib,
                            atm_fuse_holder_cap_rib_thickness);

  hole_size = with_default(atm_fuse_holder_cap_hole_size, []);

  thickness = size[1];
  w = size[0] - rib_thickness * 2;
  h = size[2];

  rib_h = plist_get("h", rib, atm_fuse_holder_cap_rib_h);
  rib_l = plist_get("l", rib, atm_fuse_holder_cap_rib_l);
  rib_n = plist_get("n", rib, atm_fuse_holder_cap_rib_n);

  rib_distance = plist_get("distance_from_top", rib, 0);

  difference() {
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
    }
    translate([0, 0, -0.2]) {
      rect_slot(h=h * 0.9,
                r=corner_rad,
                reverse=true,
                size=hole_size,
                center=true);
    }
  }
}

module atm_fuse_holder_cap_from_plist(plist) {
  plist = with_default(plist, []);
  size = plist_get("size",
                   plist,
                   [atm_fuse_holder_cap_top_l,
                    atm_fuse_holder_cap_thickness,
                    atm_fuse_holder_cap_h,
                    atm_fuse_holder_cap_bottom_l]);
  rib = plist_get("rib",
                  plist,
                  ["h", atm_fuse_holder_cap_rib_h,
                   "l", atm_fuse_holder_cap_rib_l,
                   "n", atm_fuse_holder_cap_rib_n,
                   "thickness", atm_fuse_holder_cap_rib_thickness,
                   "distance_from_top", atm_fuse_holder_cap_rib_distance]);
  round_side = plist_get("round_side", plist, "top");
  corner_rad = plist_get("corner_rad", plist, 2);
  cap_hole_size = plist_get("hole_size", plist);
  color = plist_get("color", plist, matte_black_2);

  atm_fuse_holder_cap(size=size,
                      rib=rib,
                      round_side=round_side,
                      corner_rad=corner_rad,
                      hole_size=cap_hole_size,
                      color=color);
}

atm_fuse_holder_cap_from_plist(["size", [atm_fuse_holder_cap_top_l,
                                         atm_fuse_holder_cap_thickness,
                                         atm_fuse_holder_cap_h,
                                         atm_fuse_holder_cap_bottom_l,],
                                "corner_rad", 2,
                                "round_side", "top",
                                "hole_size", atm_fuse_holder_cap_hole_size,
                                "color", matte_black_2,
                                "rib", ["h", atm_fuse_holder_cap_rib_h,
                                        "l", atm_fuse_holder_cap_rib_l,
                                        "n", atm_fuse_holder_cap_rib_n,
                                        "thickness", atm_fuse_holder_cap_rib_thickness,
                                        "distance_from_top", atm_fuse_holder_cap_rib_distance]]);