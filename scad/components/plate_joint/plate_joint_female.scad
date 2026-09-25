/**
  * Module: Resolved female plate socket.
  *
  * Standalone plate joint; dimensions are in millimeters.
  */

use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <plate_joint_geometry.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint_female
  ─────────────────────────────────────────────────────────────────────────────

  Build a matching female socket, or its cutters.

  **Parameters:**
  - `params`: Validated property list from `plate_joint_parameters()`; shared by both halves.
  - `color`: Optional display color.
  - `root_side`: Parent edge: 1 at Y=0 or -1 at Y=-l; only this edge gets boolean overlap.
  - `slot_mode`: Emit only socket and hole cutters for subtraction from a parent plate.
  - `anchor`: Nominal plate-envelope anchor, independent of clearance and overlap.
  - `flip`: Mirror in Z within the nominal plate envelope; preserve the anchor.
 */
module plate_joint_female(params,
                          color,
                          root_side=-1,
                          slot_mode=false,
                          anchor=[0, -1, 1],
                          flip=false) {
  p = params;
  l = plist_get("l", p);
  eps = plist_get("boolean_overlap", p);
  assert(root_side == -1 || root_side == 1, "root_side must be -1 or 1");
  module _slots() {
    _plate_joint_profile(p,
                         l=l,
                         extra_l=eps * 4,
                         clearance=plist_get("clearance", p));
    _plate_joint_holes(p, reverse=true);
  }
  _plate_joint_anchor(p, anchor, flip=flip) {
    if (slot_mode) {
      _slots();
    } else {
      render() {
        maybe_color(color) {
          difference() {
            translate([0, -l / 2 + root_side * eps / 2, 0]) {
              cuboid([plist_get("w", p), l + eps, plist_get("plate_h", p)],
                     anchor=[0, 0, 1]);
            }
            _slots();
          }
        }
      }
    }
  }
}
