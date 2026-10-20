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
use <../../placeholders/nut.scad>
use <common.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_bumper_top_plate
  ─────────────────────────────────────────────────────────────────────────────
  Build the rigid top retainer and its three integral compression posts.
  **Parameters:**
  - `pl`: Dimension overrides; see `front_bumper_params`.
  - `anchor`: Reference-box anchor, including the posts beneath the plate.
  - `slot_mode`: Emit bolt passages and applicable top-entry nut pockets.
  - `slot_h`: Through-passage height from z=0; undef uses the reference height.
    Nut pockets retain their reference-height placement.
  - `show_bolts`: Show mounting screws and nuts in solid mode.
  - `color`: Retainer color; undef inherits the caller's color.
  - `reverse_bolts`: True provides nut pockets and places heads in the underside
    chassis recesses. False provides a flat top for heads, with nuts below the chassis.
    The default follows `front_bumper_reverse_bolts` in `rc_params.scad`.
  **Behavior:** Canonical bounds start at zero, with +Y forward. Posts stand
  on z=0; the plate underside is at `foam_h`. Print with the plate's top face
  on the bed, using `top_plate_printable.scad`.
 */
module front_bumper_top_plate(pl=front_bumper_plist,
                              anchor=[1, 1, 1],
                              slot_mode=false,
                              slot_h=undef,
                              show_bolts=false,
                              color=undef,
                              reverse_bolts=front_bumper_reverse_bolts) {
  p = front_bumper_params(pl);
  size = front_bumper_size(p, "plate");
  mounts = front_bumper_mount_positions(p, "plate");
  post_d = plist_get("post_d", p);
  pad_d = post_d + 4;
  rib = plist_get("rib_w", p);
  foam_h = plist_get("foam_h", p);
  plate_h = plist_get("plate_h", p);
  bolt_l = plist_get("bolt_l", p);
  hardware = front_bumper_bolt_params(p, reverse_bolts);
  nut_h = find_nut_prop("height", front_bumper_bolt_d);
  pocket_h = nut_h + plist_get("nut_depth", p);
  pocket_d = (find_nut_prop("outer_dia", front_bumper_bolt_d)
              + plist_get("nut_clearance", p)) / cos(30);
  cut_h = is_undef(slot_h) ? size[2] : slot_h;
  bow = _front_bumper_bow(size[0], size[1], rib / 2, size[1] * 0.46);
  left = bow[0];
  front = bow[len(bow) / 2];
  right = bow[len(bow) - 1];
  rear = [mounts[1][0], mounts[1][1]];
  assert(cut_h > 0, "Slot height must be positive");
  assert(plist_get("grip", hardware) > 0, "Bolt grip must be positive");

  module holes() {
    for (pos = mounts) {
      translate(pos - [0, 0, 0.01]) {
        cylinder(d=front_bumper_bolt_d, h=cut_h + 0.02, $fn=64);
      }
      if (reverse_bolts) {
        translate(pos + [0, 0, size[2] - pocket_h]) {
          cylinder(d=pocket_d, h=pocket_h + 0.01, $fn=6);
        }
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
          translate(pos + [0, 0, plist_get("head_z", hardware)]) {
            rotate([reverse_bolts ? 180 : 0, 0, 0]) {
              translate([0, 0, -bolt_l]) {
                bolt(d=front_bumper_bolt_d,
                     h=bolt_l,
                     threaded=false,
                     head_type=front_bumper_use_countersunk ? "countersunk" : "socket",
                     bolt_color=[0.7, 0.72, 0.75],
                     head_color=[0.7, 0.72, 0.75],
                     show_nut=false,
                     $fn=48);
              }
            }
          }
          translate(pos + [0, 0, plist_get("nut_z", hardware)
                                 - (reverse_bolts ? 0 : nut_h)]) {
            nut(d=snap_bolt_d(front_bumper_bolt_d),
                outer_d=find_nut_prop("outer_dia", front_bumper_bolt_d) / cos(30),
                h=nut_h,
                show_text=false);
          }
        }
      }
    }
  }
}

front_bumper_top_plate();
