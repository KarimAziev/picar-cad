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
use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  wago_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the measured body envelope, excluding the approximate lever detail.
  **Parameters:**
  - `n`: Positive integer number of conductors.
  - `conductor_size`: Measured conductor pitch, body length and body height.
  - `total_w`: Measured total width; undef uses the sum of conductor widths.
 */
function wago_size(n=wago_n,
                   conductor_size=wago_conductor_size,
                   total_w=wago_total_w) =
  assert(is_num(n) && n >= 1 && n == floor(n),
         "Wago n must be a positive integer")
  assert(is_list(conductor_size) && len(conductor_size) == 3
         && min(conductor_size) > 0,
         "Wago conductor_size must contain three positive dimensions")
  let (w = is_undef(total_w) ? n * conductor_size[0] : total_w)
  assert(is_num(w) && w >= n * conductor_size[0],
         "Wago total_w is smaller than its conductors")
  [w, conductor_size[1], conductor_size[2]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  wago_wire_ports
  ─────────────────────────────────────────────────────────────────────────────
  Return conductor entry centers in the centered XY, bottom-Z hardware frame.
  **Parameters:**
  - `pl`: Hardware plist accepted by wago_from_plist. Entries face local -Y.
  **Returns:** XYZ points ordered from -X to +X.
 */
function wago_wire_ports(pl=[]) =
  let (n = plist_get("n", pl, wago_n),
       s = plist_get("conductor_size", pl, wago_conductor_size),
       hole = plist_get("hole_size_xz", pl, wago_hole_size_xz),
       t = plist_get("thickness", pl, wago_thickness))
  [for (i = [0:n - 1]) [(i - (n - 1) / 2) * s[0], -s[1] / 2, t + hole[1] / 2]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  wago_from_plist
  ─────────────────────────────────────────────────────────────────────────────
  Render a connector from measured dimensions and optional visual detail.
  **Parameters:**
  - `pl`: Keys n, conductor_size, total_w, hole_size_xz, lid_l, lid_t, thickness.
    Omitted total_w uses the shared measured default; explicit undef uses n*pitch.
  - `orientation`: Axis permutation accepted by with_orientation.
  - `anchor`: Anchor on the body envelope; lever detail is approximate.
 */
module wago_from_plist(pl=[], orientation="wlh", anchor=[1, 1, 1]) {
  size = wago_size(plist_get("n", pl, wago_n),
                   plist_get("conductor_size", pl, wago_conductor_size),
                   plist_get("total_w", pl, wago_total_w));
  wago(n=plist_get("n", pl, wago_n),
       wago_conductor_size=plist_get("conductor_size", pl, wago_conductor_size),
       wago_hole_size_xz=plist_get("hole_size_xz", pl, wago_hole_size_xz),
       wago_lid_l=plist_get("lid_l", pl, wago_lid_l),
       wago_lid_t=plist_get("lid_t", pl, wago_lid_t),
       wago_thickness=plist_get("thickness", pl, wago_thickness),
       total_w=size[0],
       orientation=orientation,
       anchor=anchor);
}

module wago_conductor(lid_color=orange_1,
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

module wago(n=5,
            wago_conductor_size=wago_conductor_size,
            wago_hole_size_xz=wago_hole_size_xz,
            wago_lid_l=wago_lid_l,
            wago_lid_t=wago_lid_t,
            wago_thickness=wago_thickness,
            total_w,
            orientation="wlh",
            anchor=[0, 0, 1]) {
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

  with_orientation(from="wlh",
                   to=orientation,
                   anchor=anchor,
                   size=[with_default(total_w, computed_total), l, h]) {
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
}

wago(n=wago_n, total_w=36.5);