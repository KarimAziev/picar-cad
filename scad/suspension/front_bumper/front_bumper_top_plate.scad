/**
  * Module: Triangulated front bumper top plate with compression posts.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../parameters.scad>
include <../../rc_params.scad>

use <../../lib/plist.scad>
use <../../lib/transforms.scad>
use <../../placeholders/bolt.scad>
use <common.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_bumper_top_plate
  ─────────────────────────────────────────────────────────────────────────────
  Build the rigid top retainer and its three integral compression posts.
  **Parameters:**
  - `pl`: Dimension overrides; see `front_bumper_params`.
  - `anchor`: Reference-box anchor, including the posts beneath the plate.
  - `slot_mode`: Emit the three bolt passages through the full reference height.
  - `slot_h`: Cutter height from z=0; undef uses the reference height.
  - `show_bolts`: Show mounting screws and underside nuts in solid mode.
  - `color`: Retainer color; undef inherits the caller's color.
  **Behavior:** Canonical bounds start at zero, with +Y forward. Posts stand
  on z=0; the plate underside is at `foam_h`. Print with the plate's top face
  on the bed, using `top_plate_printable.scad`.
 */
module front_bumper_top_plate(pl=front_bumper_plist,
                              anchor=[1, 1, 1],
                              slot_mode=false,
                              slot_h=undef,
                              show_bolts=false,
                              color=undef) {
  p = front_bumper_params(pl);
  size = front_bumper_size(p, "plate");
  mounts = front_bumper_mount_positions(p, "plate");
  post_d = plist_get("post_d", p);
  pad_d = post_d + 4;
  rib = plist_get("rib_w", p);
  foam_h = plist_get("foam_h", p);
  plate_h = plist_get("plate_h", p);
  bolt_l = plist_get("bolt_l", p);
  cut_h = is_undef(slot_h) ? size[2] : slot_h;
  bow = _front_bumper_bow(size[0], size[1], rib / 2, size[1] * 0.46);
  left = bow[0];
  front = bow[len(bow) / 2];
  right = bow[len(bow) - 1];
  rear = [mounts[1][0], mounts[1][1]];
  assert(cut_h > 0, "Slot height must be positive");

  module holes() {
    for (pos = mounts) {
      translate(pos - [0, 0, 0.01]) {
        cylinder(d=front_bumper_bolt_d, h=cut_h + 0.02, $fn=64);
      }
    }
  }

  with_anchor(size=size, anchor=anchor) {
    if (slot_mode) {
      holes();
    } else {
      maybe_color(color) {
        difference() {
          union() {
            translate([0, 0, foam_h]) {
              linear_extrude(height=plate_h) {
                _front_bumper_rail(bow, rib);
                _front_bumper_rail([left, [mounts[0][0], mounts[0][1]], rear,
                                    [mounts[2][0], mounts[2][1]], right],
                                   rib);
                for (pos = mounts) {
                  _front_bumper_rail([[pos[0], pos[1]], front], rib);
                  translate([pos[0], pos[1]]) {
                    circle(d=pad_d, $fn=64);
                  }
                }
              }
            }
            for (pos = mounts) {
              translate(pos) {
                cylinder(d=post_d, h=foam_h + 0.01, $fn=64);
              }
            }
          }
          holes();
        }
      }
      if (show_bolts) {
        for (pos = mounts) {
          translate(pos + [0, 0, size[2] - bolt_l]) {
            bolt(d=front_bumper_bolt_d,
                 h=bolt_l,
                 threaded=false,
                 head_type="socket",
                 bolt_color=[0.7, 0.72, 0.75],
                 head_color=[0.7, 0.72, 0.75],
                 show_nut=true,
                 nut_head_distance=size[2] + chassis_thickness,
                 $fn=48);
          }
        }
      }
    }
  }
}

front_bumper_top_plate();
