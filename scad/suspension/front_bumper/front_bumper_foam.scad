/**
  * Module: Swept TPU 95A front bumper body.
  *
  * The closed outer envelope accepts slicer-controlled infill. Three vertical
  * passages receive the top plate's compression posts.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>

use <../../lib/plist.scad>
use <../../lib/transforms.scad>
use <common.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_bumper_foam
  ─────────────────────────────────────────────────────────────────────────────
  Build the rounded impact body for printing in TPU 95A.
  **Parameters:**
  - `pl`: Dimension overrides; see `front_bumper_params`.
  - `anchor`: Reference-box anchor; +Y faces forward and z=0 is the print bed.
  - `slot_mode`: Emit the three compression-post passages.
  - `slot_h`: Cutter height from z=0; undef uses the body height.
  **Behavior:** The mesh is a closed solid envelope. Compliance depends on
  filament, wall count and infill; the CAD envelope does not specify stiffness.
 */
module front_bumper_foam(pl=front_bumper_plist,
                         anchor=[1, 1, 1],
                         slot_mode=false,
                         slot_h=undef) {
  p = front_bumper_params(pl);
  size = front_bumper_size(p, "foam");
  mounts = front_bumper_mount_positions(p, "foam");
  post_d = plist_get("post_d", p);
  passage_d = post_d + plist_get("post_clearance", p);
  r = 3;
  bow = _front_bumper_bow(size[0], size[1], r, size[1] * 0.55);
  rear = [[size[0] - r, bow[0][1]],
          [size[0] * 0.75, 8],
          [mounts[2][0], r],
          [size[0] / 2, 7],
          [mounts[0][0], r],
          [size[0] * 0.25, 8],
          [r, bow[0][1]]];
  cut_h = is_undef(slot_h) ? size[2] : slot_h;
  assert(cut_h > 0, "Slot height must be positive");

  module holes() {
    for (pos = mounts) {
      translate(pos - [0, 0, 0.01]) {
        cylinder(d=passage_d, h=cut_h + 0.02, $fn=64);
      }
    }
  }

  with_anchor(size=size, anchor=anchor) {
    if (slot_mode) {
      holes();
    } else {
      difference() {
        linear_extrude(height=size[2], convexity=6) {
          offset(r=r, $fn=48) {
            polygon(concat(bow, rear));
          }
        }
        holes();
      }
    }
  }
}

front_bumper_foam();
