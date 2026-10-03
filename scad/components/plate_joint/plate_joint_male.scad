/**
  * Module: Resolved male plate rail.
  *
  * Standalone plate joint; dimensions are in millimeters.
  */

use <../../lib/plist.scad>
use <../../lib/transforms.scad>
use <plate_joint_geometry.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint_male
  ─────────────────────────────────────────────────────────────────────────────

  Build a male rail with a free-tip setback.

  **Parameters:**
  - `params`: Validated property list from `plate_joint_parameters()`; shared by both halves.
  - `color`: Optional display color.
  - `root_side`: Parent edge: 1 at Y=0 or -1 at Y=-l; only this edge gets boolean overlap.
  - `anchor`: Nominal plate-envelope anchor, independent of clearance and overlap.
  - `flip`: Mirror in Z within the nominal plate envelope; preserve the anchor.
 */
module plate_joint_male(params,
                        color,
                        root_side=1,
                        anchor=[0, -1, 1],
                        flip=false) {
  p = params;
  l = plist_get("l", p);
  eps = plist_get("boolean_overlap", p);
  gap = plist_get("axial_clearance", p);
  assert(root_side == -1 || root_side == 1, "root_side must be -1 or 1");
  _plate_joint_anchor(p, anchor, flip=flip) {
    maybe_color(color) {
      render(convexity=10) {
        difference() {
          translate([0, root_side == 1 ? eps : -gap, 0]) {
            _plate_joint_profile(p, l=l + eps - gap);
          }
          _plate_joint_holes(p);
        }
      }
    }
  }
}
