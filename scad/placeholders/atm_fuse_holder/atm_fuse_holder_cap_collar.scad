/**
 * Module: Cap collar for mini ATM Blade Fuse Holder's body
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../parameters.scad>
include <../../colors.scad>

use <../../lib/wire.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../../lib/plist.scad>
use <../../lib/holes.scad>
use <../../lib/stairs.scad>
use <../../lib/slots.scad>
use <atm_fuse_holder_cap.scad>

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
