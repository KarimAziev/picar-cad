/**
  * Module: WAGO 221 placeholder
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/functions.scad>
use <../../lib/placement.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>

module wago_conductor(lid_color="#F07F24",
                      wago_conductor_size=wago_conductor_size,
                      wago_hole_size_xz=wago_hole_size_xz,
                      wago_lid_l=wago_lid_l,
                      wago_lid_t=wago_lid_t,
                      wago_thickness=wago_thickness,
                      orientation="wlh",
                      anchor=[0, 0, 1]) {
  w = wago_conductor_size[0];
  l = wago_conductor_size[1];
  h = wago_conductor_size[2];

  lid_w = w;
  lid_corner_r = lid_w / 2;
  lid_l = lid_corner_r + wago_lid_l;
  hole_l = l * 0.7;

  with_orientation(from="wlh",
                   to=orientation,
                   anchor=anchor,
                   size=wago_conductor_size) {
    difference() {
      union() {
        color(metallic_silver_1, alpha=0.3) {
          cuboid(size=wago_conductor_size);
        }
        translate([0, lid_l / 2 - l / 2 - lid_corner_r, h + 0.1]) {
          color(lid_color, alpha=1) {
            difference() {
              hull() {
                cuboid(size=[lid_w + 0.1, lid_l, wago_lid_t],
                       side="bottom",
                       r=lid_corner_r,
                       anchor=[0, 0, -1]);
                translate([0,
                           lid_l / 2,
                           0]) {
                  cuboid(size=[lid_w,
                               0.2,
                               h - wago_thickness],
                         side="bottom",
                         anchor=[0, 0, -1]);
                  translate([0,
                             0,
                             0]) {
                    cuboid(size=[lid_w,
                                 lid_l * 0.3,
                                 h - wago_thickness],
                           side="bottom",
                           anchor=[0, -1, -1]);
                  }
                }
              }

              translate([0, lid_l / 2 - (lid_l * 0.3) / 2 + 0.1, 0.5]) {
                cuboid(size=[w - wago_thickness * 4,
                             lid_l * 0.3 + 0.1,
                             h],
                       r="50%",
                       side="bottom",
                       anchor=[0, 0, -1]);
              }
            };
          }
        }
      }
      translate([0, -(l - hole_l) / 2 - 0.1, wago_thickness]) {
        cuboid(size=[wago_hole_size_xz[0],
                     hole_l,
                     wago_hole_size_xz[1]]);
      }
    }
  }
}

module wago(wago_conductor_size=wago_conductor_size,
            wago_hole_size_xz=wago_hole_size_xz,
            wago_lid_l=wago_lid_l,
            wago_lid_t=wago_lid_t,
            wago_thickness=wago_thickness,
            total_w,
            n=5) {
  w = wago_conductor_size[0];
  l = wago_conductor_size[1];
  h = wago_conductor_size[2];

  cols_params = calc_cols_params(cols=n, w=w, gap=0);
  computed_total = cols_params[1];

  module _wago_conductor() {
    wago_conductor(wago_conductor_size=wago_conductor_size,
                   wago_hole_size_xz=wago_hole_size_xz,
                   wago_lid_l=wago_lid_l,
                   wago_lid_t=wago_lid_t,
                   wago_thickness=wago_thickness);
  }

  if (!is_undef(total_w)) {
    side_thicknesss = is_undef(total_w) ? 0 : ((total_w - computed_total) / 2);

    mirror_copy([1, 0, 0]) {
      translate([computed_total / 2, 0, 0]) {
        color(metallic_silver_1, alpha=0.5) {
          cuboid(size=[side_thicknesss, l, h], anchor=[1, 0, 1]);
        }
      }
    }
  }

  columns_children(gap=0,
                   cols=n,
                   w=wago_conductor_size[0],
                   center=true) {
    _wago_conductor();
  }
}

wago(n=wago_n, total_w=36.5);