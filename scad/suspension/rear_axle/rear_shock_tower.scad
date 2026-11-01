/**
  * Module: Rear shock tower with adjustable damper and camber-link attachments.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../../lib/plist.scad>
use <../../lib/transforms.scad>
use <../../lib/shapes2d.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_shock_tower_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the flat tower reference box, including damper bosses.
  **Parameters:**
  - `pl`: Tower dimensions and mounting settings: `rear_tower_spec` from
    `scad/suspension/rear_axle/structure_params.scad`.
 */
function rear_shock_tower_size(pl) =
  [plist_get("w", pl), plist_get("h", pl),
   plist_get("thickness", pl) + plist_get("shock_boss_h", pl)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_shock_tower_mounts
  ─────────────────────────────────────────────────────────────────────────────
  Return four mounting-hole centers in flat tower XY coordinates.
  **Parameters:**
  - `pl`: Tower dimensions and mounting settings: `rear_tower_spec` from
    `scad/suspension/rear_axle/structure_params.scad`.
 */
function rear_shock_tower_mounts(pl) =
  let (s = plist_get("mount_bolt_spacing", pl))
  [for (x = [-1, 1], y = [0, 1])
    [plist_get("w", pl) / 2 + x * s[0] / 2,
     plist_get("mount_z", pl) + y * s[1], 0]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_shock_tower_shocks
  ─────────────────────────────────────────────────────────────────────────────
  Return the left and right selected damper-boss face centers.
  **Parameters:**
  - `pl`: Tower dimensions and mounting settings: `rear_tower_spec` from
    `scad/suspension/rear_axle/structure_params.scad`.
  - `hole`: Zero-based adjustment-hole index.
 */
function rear_shock_tower_shocks(pl, hole) =
  let (xs = plist_get("shock_hole_x", pl),
       zs = plist_get("shock_hole_z", pl))
  assert(hole >= 0 && hole < len(xs) && hole == floor(hole))
  [for (side = [-1, 1])
    [plist_get("w", pl) / 2 + side * xs[hole], zs[hole],
     rear_shock_tower_size(pl)[2]]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_shock_tower
  ─────────────────────────────────────────────────────────────────────────────
  Build a flat printable tower in XY; assembly rotates its height into +Z.
  **Parameters:**
  - `pl`: Tower dimensions and mounting settings: `rear_tower_spec` from
    `scad/suspension/rear_axle/structure_params.scad`.
  - `anchor`: Reference-box anchor including the damper bosses.
  - `slot_mode`: Emit all fastener bores using the same reference box.

  **Examples:**
  Save this example at the repository root.
  ```scad
  include <scad/suspension/rear_axle/structure_params.scad>
  use <scad/suspension/rear_axle/rear_shock_tower.scad>
  rear_shock_tower(pl=rear_tower_spec, anchor=[1, 1, 1], slot_mode=false);
  ```
 */
module rear_shock_tower(pl, anchor=[1, 1, 1], slot_mode=false) {
  size = rear_shock_tower_size(pl);
  w = size[0];
  h = size[1];
  t = plist_get("thickness", pl);
  e = plist_get("csg_epsilon", pl);
  pad = plist_get("mount_pad", pl);
  mount_w = plist_get("mount_bolt_spacing", pl)[0] + pad * 2;
  shoulder_z = plist_get("mount_z", pl)
               + plist_get("mount_bolt_spacing", pl)[1] + pad;
  xs = plist_get("shock_hole_x", pl);
  zs = plist_get("shock_hole_z", pl);
  $fn = plist_get("fn", pl);
  assert(w > mount_w && h > shoulder_z && len(xs) == len(zs));
  assert(t > 0 && plist_get("rib_w", pl) > 0);
  module bores() {
    for (p = rear_shock_tower_mounts(pl)) {
      translate(p - [0, 0, e]) {
        cylinder(d=plist_get("mount_bolt_d", pl), h=size[2] + 2 * e);
      }
    }
    for (i = [0:len(xs) - 1], p = rear_shock_tower_shocks(pl, i)) {
      translate([p[0], p[1], -e]) {
        cylinder(d=plist_get("shock_bolt_d", pl), h=size[2] + 2 * e);
      }
    }
    for (side = [-1, 1]) {
      translate([w / 2 + side * plist_get("link_x", pl),
                 plist_get("link_z", pl), -e]) {
        cylinder(d=plist_get("link_bolt_d", pl), h=size[2] + 2 * e);
      }
    }
  }
  with_anchor(anchor, size) {
    if (slot_mode) {
      bores();
    } else {
      color(plist_get("color", pl)) {
        difference() {
          union() {
            linear_extrude(height=t) {
              offset(r=plist_get("corner_r", pl)) {
                offset(delta=-plist_get("corner_r", pl)) {
                  polygon([[w / 2 - mount_w / 2, 0],
                           [w / 2 + mount_w / 2, 0],
                           [w / 2 + plist_get("link_x", pl) + pad, 0],
                           [w, h - plist_get("shock_boss_d", pl)],
                           [w, h], [0, h],
                           [0, h - plist_get("shock_boss_d", pl)],
                           [w / 2 - plist_get("link_x", pl) - pad, 0]]);
                }
              }
            }
            for (i = [0:len(xs) - 1], p = rear_shock_tower_shocks(pl, i)) {
              translate([p[0], p[1], t - e]) {
                cylinder(d=plist_get("shock_boss_d", pl),
                         h=plist_get("shock_boss_h", pl) + e);
              }
            }
          }
          bores();
          for (side = [-1, 1]) {
            window_w = (plist_get("window_w", pl) - plist_get("rib_w", pl)) / 2;
            translate([w / 2 + side * (window_w + plist_get("rib_w", pl)) / 2,
                       plist_get("window_z", pl), -e]) {
              linear_extrude(height=t + 2 * e) {
                rounded_rect([window_w, plist_get("window_h", pl)],
                             r=plist_get("corner_r", pl), center=true);
              }
            }
          }
        }
      }
    }
  }
}
