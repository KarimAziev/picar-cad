/**
  * Module: Front bumper dimensions, profiles and mounting datums.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../parameters.scad>
include <../../rc_params.scad>

use <../../lib/plist.scad>
use <../../placeholders/bolt.scad>
use <../front_chassis/front_frame_util.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_bumper_params
  ─────────────────────────────────────────────────────────────────────────────
  Resolve and validate the bumper's shared dimensions in millimeters.
  The complete configuration is `front_bumper_plist` in `rc_params.scad`.
  **Parameters:**
  - `pl`: Overrides for `foam_w`, `foam_l`, `foam_h`, `plate_w`, `plate_l`,
    `plate_h`, `rib_w`, `post_d`, `post_clearance`, `bolt_l`, `nut_depth`,
    `nut_clearance`, and `bolt_tip_clearance`.
    `post_clearance` is diametral clearance in the TPU passages.
    `nut_clearance` is diametral clearance across the nut flats.
    `nut_depth` is the extra depth beneath the top face beyond the nut height.
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
       pad = post + 4,
       nut_depth = plist_get("nut_depth", p),
       nut_clearance = plist_get("nut_clearance", p),
       tip_clearance = plist_get("bolt_tip_clearance", p),
       nut_h = find_nut_prop("height", front_bumper_bolt_d),
       pocket_h = nut_h + nut_depth,
       pocket_d = (find_nut_prop("outer_dia", front_bumper_bolt_d)
                   + nut_clearance) / cos(30))
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
  assert(nut_clearance >= 0 && tip_clearance > 0,
         "Nut clearance must be nonnegative and bolt-tip clearance positive")
  assert(nut_depth >= tip_clearance && ph - pocket_h >= 1.5,
         "Nut pockets must contain the nut and tip clearance with a 1.5 mm floor")
  assert(pad - pocket_d >= 3,
         "Nut pockets need at least 1.5 mm radial walls")
  assert(plist_get("bolt_l", p) > 0, "Bolt length must be positive")
  p;

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_bumper_bolt_params
  ─────────────────────────────────────────────────────────────────────────────
  Resolve and validate the mounting bolt stack in the retainer's coordinates.
  **Parameters:**
  - `pl`: Bumper dimension overrides.
  - `reverse_bolts`: True seats heads in the chassis recess and nuts in the
    retainer pockets. False seats heads on the flat retainer and nuts below
    the chassis.
  **Returns:** Plist with `head_z` (under-head seat), `nut_z` (nut bearing face),
  `grip` (distance between those faces), `tip_z`, `min_l` and `max_l`.
  `max_l` is undef for downward-pointing bolts.
  **Behavior:** Bolts must engage the full nut height. Upward-pointing tips
  must remain at least `bolt_tip_clearance` below the top face.
 */
function front_bumper_bolt_params(pl=front_bumper_plist,
                                  reverse_bolts=front_bumper_reverse_bolts) =
  let (p = front_bumper_params(pl),
       top_z = plist_get("foam_h", p) + plist_get("plate_h", p),
       recess_h = reverse_bolts && front_bumper_bolt_cbore_d > 0
                  && front_bumper_bolt_cbore_h > 0
                  ? front_bumper_bolt_cbore_h
                  : 0,
       head_z = reverse_bolts ? -chassis_thickness + recess_h : top_z,
       nut_z = reverse_bolts
               ? top_z - find_nut_prop("height", front_bumper_bolt_d)
                 - plist_get("nut_depth", p)
               : -chassis_thickness,
       grip = abs(nut_z - head_z),
       bolt_l = plist_get("bolt_l", p),
       min_l = grip + find_nut_prop("height", front_bumper_bolt_d),
       max_l = reverse_bolts
               ? top_z - head_z - plist_get("bolt_tip_clearance", p)
               : undef)
  assert(bolt_l >= min_l - 1e-8,
         str("Bumper bolt must fully engage the nut: bolt_l >= ", min_l))
  assert(!reverse_bolts || bolt_l <= max_l + 1e-8,
         str("Bumper bolt tip must stay below the top face: bolt_l <= ", max_l))
  ["head_z", head_z,
   "nut_z", nut_z,
   "grip", grip,
   "tip_z", head_z + (reverse_bolts ? bolt_l : -bolt_l),
   "min_l", min_l,
   "max_l", max_l];

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
