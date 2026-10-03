/**
  * Module: Motor drive shaft placeholder
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

use <../../../lib/functions.scad>
use <../../../lib/transforms.scad>
use <../../suspension_arm_pin.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  motor_drive_shaft
  ─────────────────────────────────────────────────────────────────────────────

  Model a shaft with keyed end flats and transverse retention holes.

  **Parameters:**
  - `d`, `l`: Full shaft diameter and length.
  - `pad_l`: End-flat length; both pads together must fit within `l`.
  - `pad_side`: `"all"`, `"bottom"`, or `"top"` selects flattened ends.
  - `pad_w`: Remaining Y thickness of the flat, default `d/2`.
  - `hole_d`: Cross-hole diameter; `undef` or zero omits holes.
  - `hole_edge_dist`: Shaft end to nearest hole edge, default 2 mm.
  - `pad_horizontal_one_side`: One +Y flat when true; opposing flats otherwise.
  - `hole_side`: `"all"`, `"bottom"`, or `"top"` selects cross-holes.
  - `anchor`: Anchor of the original cylindrical envelope. Default keeps
    the axis on X=Y=0, with the shaft extending from Z=0 to Z=`l`.

  Holes run through both sides along Y. Their centers are offset from each
  end by `hole_edge_dist + hole_d/2`.
  */
module motor_drive_shaft(d,
                         l,
                         pad_l,
                         pad_side="all",
                         pad_w,
                         hole_d,
                         hole_edge_dist,
                         pad_horizontal_one_side=true,
                         hole_side="all",
                         anchor=[0, 0, 1]) {

  hole_edge_dist = with_default(hole_edge_dist, 2);
  assert(d > 0 && l > 0 && pad_l >= 0 && 2 * pad_l <= l);
  assert(in_list(hole_side, ["all", "bottom", "top"]));
  assert(is_undef(hole_d) || hole_d == 0
         || (hole_d > 0 && hole_edge_dist >= 0
             && hole_edge_dist + hole_d <= pad_l),
         "Cross-hole and its end land must fit within the shaft flat");
  with_anchor(size=[d, d, l], anchor=anchor, centered=true) {
    difference() {
      suspension_arm_pin(d=d,
                         l=l,
                         pad_l=pad_l,
                         pad_w=is_undef(pad_w) ? d / 2 : pad_w,
                         pad_side=pad_side,
                         pad_horizontal_one_side=pad_horizontal_one_side,
                         fn=$preview ? 48 : 300,
                         show_e_clip=false);
      if (!is_undef(hole_d) && hole_d > 0) {
        for (bottom = [true, false]) {
          if (hole_side == "all" || hole_side == (bottom ? "bottom" : "top")) {
            z = hole_edge_dist + hole_d / 2;
            translate([0, 0, bottom ? z : l - z]) {
              rotate([90, 0, 0]) {
                cylinder(d=hole_d, h=d + 1, center=true, $fn=48);
              }
            }
          }
        }
      }
    }
  }
}

motor_drive_shaft(d=3.95,
                  l=61.42,
                  pad_l=6.8,
                  pad_w=3,
                  hole_d=3,
                  hole_edge_dist=2,
                  pad_horizontal_one_side=true,
                  hole_side="all");
