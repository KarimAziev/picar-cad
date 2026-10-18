/**
  * Module: Front bumper dimensions, profiles and mounting datums.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../parameters.scad>
include <../../rc_params.scad>

use <../../lib/plist.scad>
use <../front_chassis/front_frame_util.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_bumper_params
  ─────────────────────────────────────────────────────────────────────────────
  Resolve and validate the bumper's shared dimensions in millimeters.
  The complete configuration is `front_bumper_plist` in `rc_params.scad`.
  **Parameters:**
  - `pl`: Overrides for `foam_w`, `foam_l`, `foam_h`, `plate_w`, `plate_l`,
    `plate_h`, `rib_w`, `post_d`, `post_clearance`, and `bolt_l`.
    `post_clearance` is diametral clearance in the TPU passages.
  **Returns:** Resolved property list. Mounting centers and bolt diameter come
  from the head frame. The top plate includes three integral compression posts.
 */
function front_bumper_params(pl=front_bumper_plist) =
  let (p = plist_merge(front_bumper_plist, pl),
       fw = plist_get("foam_w", p),
       fl = plist_get("foam_l", p),
       fh = plist_get("foam_h", p),
       pw = plist_get("plate_w", p),
       len = plist_get("plate_l", p),
       ph = plist_get("plate_h", p),
       rib = plist_get("rib_w", p),
       post = plist_get("post_d", p),
       gap = plist_get("post_clearance", p),
       pad = post + 4)
  assert(fh > 0 && ph > 0 && rib > 0 && rib <= pad,
         "Bumper heights and ribs must be positive; rib_w must fit the pads")
  assert(post >= front_bumper_bolt_d + 3 && gap >= 0 && gap < 2,
         "Compression posts need 1.5 mm radial walls and 0..2 mm clearance")
  assert(pw > front_bumper_bolt_spacing_x + pad * 4,
         "Top plate needs room for the outer truss wings")
  assert(fw >= pw + 24 && fl >= len + 10,
         "TPU must project beyond the rigid top plate")
  assert(len > pad + front_bumper_center_bolt_y_offset + rib,
         "Top plate needs room ahead of the three mounting pads")
  assert(plist_get("bolt_l", p) >= fh + ph + chassis_thickness + 4,
         "Bolts must cross the stack and provide at least 4 mm below the frame")
  p;

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_bumper_size
  ─────────────────────────────────────────────────────────────────────────────
  Return a component's canonical reference box `[w, l, h]`.
  **Parameters:**
  - `pl`: Bumper dimension overrides; see `front_bumper_params`.
  - `part`: `"foam"`, `"plate"` (including posts), or `"assembly"`.
 */
function front_bumper_size(pl=front_bumper_plist, part="assembly") =
  let (p = front_bumper_params(pl),
       foam = [plist_get("foam_w", p), plist_get("foam_l", p),
               plist_get("foam_h", p)])
  assert(part == "foam" || part == "plate" || part == "assembly")
  part == "foam"
  ? foam
  : [part == "plate" ? plist_get("plate_w", p) : foam[0],
     part == "plate" ? plist_get("plate_l", p) : foam[1],
     foam[2] + plist_get("plate_h", p)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_bumper_mount_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return `[left, center, right]` bolt centers in a component's canonical box.
  **Parameters:**
  - `pl`: Bumper dimension overrides.
  - `part`: `"foam"`, `"plate"`, or `"assembly"` reference box.
  **Returns:** XYZ points at the bottom of the posts, with +Y facing forward.
 */
function front_bumper_mount_positions(pl=front_bumper_plist, part="assembly") =
  let (p = front_bumper_params(pl),
       size = front_bumper_size(p, part),
       mounts = front_chassis_bumper_mount_positions(),
       rear_y = mounts[0][1] - (plist_get("post_d", p) + 4) / 2)
  [for (pos = mounts) [pos[0] + size[0] / 2, pos[1] - rear_y, 0]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_bumper_position
  ─────────────────────────────────────────────────────────────────────────────
  Place a canonical bumper component on the head frame.
  **Parameters:**
  - `pl`: Bumper dimension overrides.
  - `part`: `"foam"`, `"plate"`, or `"assembly"` reference box.
  **Returns:** XYZ translation for the default `[1, 1, 1]` anchor.
 */
function front_bumper_position(pl=front_bumper_plist, part="assembly") =
  front_chassis_bumper_mount_positions()[0]
  - front_bumper_mount_positions(pl, part)[0];

// Rounded rail centers sampled symmetrically, including the center vertex.
function _front_bumper_bow(w, l, r, sweep, steps=48) =
  [for (i = [0:steps])
    let (t = 2 * i / steps - 1)
    [w / 2 + t * (w / 2 - r), l - r - sweep * t * t]];

module _front_bumper_rail(points, d) {
  for (i = [0:len(points) - 2]) {
    hull() {
      translate(points[i]) {
        circle(d=d, $fn=32);
      }
      translate(points[i + 1]) {
        circle(d=d, $fn=32);
      }
    }
  }
}
