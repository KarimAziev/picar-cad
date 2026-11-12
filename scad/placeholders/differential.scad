/**
  * Module: Measured differential with crown, capsule case and slotted cups.
  *
  * The output axle is Z. The crown is on the minimum-Z side of the case.
  * Bounds are positive XYZ; crown teeth are represented by their outer envelope.
  * Bearings and dogbone engagement depths belong to the installation settings.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  differential_spec
  ─────────────────────────────────────────────────────────────────────────────
  Return caliper dimensions and explicit display/clearance settings.
  **Returns:** Complete plist. `case_size` is the capsule's XYZ box, excluding
  the crown. Cup bores pass through the full cup length. `support_l` and
  `support_d` describe the journals between case/crown and cups, not bearings.
 */
function differential_spec() =
  let (cup_d = 9.17, cup_wall = 1.63, cup_l = 10)
  ["gear_d", 38,
   "gear_h", 4,
   "case_size", [25, 20, 12.6],
   "case_radius_factor", 0.5,
   "support_l", 4.25,
   "support_d", cup_d,
   "cup_d", cup_d,
   "cup_l", cup_l,
   "cup_bore_d", cup_d - 2 * cup_wall,
   "cup_bore_depth", cup_l,
   "cup_slot_w", 2.25,
   "cup_slot_depth", 8.3,
   "radial_clearance", 0.3,
   "axial_clearance", 0.2,
   "csg_epsilon", 0.02,
   "fn", 64,
   "gear_color", "#8b5a2b",
   "body_color", "#277d9e",
   "cup_color", "silver"];

function _differential_value(pl, key) =
  assert(plist_is(pl), "Differential requires a property list")
  assert(plist_has(key, pl), str("Missing differential setting: ", key))
  plist_get(key, pl);

/**
  ─────────────────────────────────────────────────────────────────────────────
  differential_case_span
  ─────────────────────────────────────────────────────────────────────────────
  Return the axial crown-plus-case span, excluding journals and cups.
  **Parameters:**
  - `pl`: Measured dimensions and display settings returned by
    `differential_spec()` in `scad/placeholders/differential.scad`.
 */
function differential_case_span(pl) =
  _differential_value(pl, "gear_h") + _differential_value(pl, "case_size")[2];

/**
  ─────────────────────────────────────────────────────────────────────────────
  differential_case_swept_d
  ─────────────────────────────────────────────────────────────────────────────
  Return the case's rotating outside diameter about its output axle.
  **Parameters:**
  - `pl`: Measured dimensions and display settings returned by
    `differential_spec()` in `scad/placeholders/differential.scad`.
 */
function differential_case_swept_d(pl) =
  let (size = _differential_value(pl, "case_size"),
       r = min(size[0], size[1]) * _differential_value(pl, "case_radius_factor"))
  2 * (norm([size[0] / 2 - r, size[1] / 2 - r]) + r);

/**
  ─────────────────────────────────────────────────────────────────────────────
  differential_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the positive XYZ reference box, with axle along Z.
  **Parameters:**
  - `pl`: Measured dimensions and display settings returned by
    `differential_spec()` in `scad/placeholders/differential.scad`.
 */
function differential_size(pl) =
  let (case_size = _differential_value(pl, "case_size"),
       d = max(_differential_value(pl, "gear_d"), case_size[0], case_size[1],
               _differential_value(pl, "support_d"),
               _differential_value(pl, "cup_d")))
  [d, d, differential_case_span(pl)
         + 2 * (_differential_value(pl, "support_l")
                + _differential_value(pl, "cup_l"))];

/**
  ─────────────────────────────────────────────────────────────────────────────
  differential
  ─────────────────────────────────────────────────────────────────────────────
  Model the measured metal differential or its rotating clearance envelope.
  **Parameters:**
  - `pl`: Measured dimensions and display settings returned by
    `differential_spec()` in `scad/placeholders/differential.scad`.
  - `anchor`: Reference-box anchor; `[1, 1, 1]` preserves positive bounds.
  - `slot_mode`: Emit swept cylindrical volumes with configured radial and
    axial clearances. Bearings are supplied by the installation, separately.
  **Behavior:** Cups open at opposite Z ends. Their slots run along Y, with
  width along X. The case is a rounded rectangle in XY, extruded along Z.

  **Examples:**
  Save this example at the repository root.
  ```scad
  use <scad/placeholders/differential.scad>
  differential(pl=differential_spec(), anchor=[1, 1, 1], slot_mode=false);
  ```
 */
module differential(pl, anchor=[1, 1, 1], slot_mode=false) {
  size = differential_size(pl);
  case_size = _differential_value(pl, "case_size");
  gear_d = _differential_value(pl, "gear_d");
  gear_h = _differential_value(pl, "gear_h");
  support_l = _differential_value(pl, "support_l");
  support_d = _differential_value(pl, "support_d");
  cup_l = _differential_value(pl, "cup_l");
  cup_d = _differential_value(pl, "cup_d");
  bore_d = _differential_value(pl, "cup_bore_d");
  bore_depth = _differential_value(pl, "cup_bore_depth");
  slot_w = _differential_value(pl, "cup_slot_w");
  slot_depth = _differential_value(pl, "cup_slot_depth");
  radius_factor = _differential_value(pl, "case_radius_factor");
  radial = _differential_value(pl, "radial_clearance");
  axial = _differential_value(pl, "axial_clearance");
  epsilon = _differential_value(pl, "csg_epsilon");
  fn = _differential_value(pl, "fn");
  body_color = _differential_value(pl, "body_color");
  gear_color = _differential_value(pl, "gear_color");
  cup_color = _differential_value(pl, "cup_color");
  crown_z = cup_l + support_l;
  span = differential_case_span(pl);
  assert(min(case_size) > 0 && gear_d > 0 && gear_h > 0);
  assert(cup_d > bore_d && bore_d > 0 && cup_l > 0);
  assert(slot_depth > 0 && slot_depth <= cup_l && slot_w > 0);
  assert(bore_depth >= slot_depth && bore_depth <= cup_l);
  assert(support_d > 0 && support_l > 0);
  assert(radius_factor >= 0 && radius_factor <= 0.5);
  assert(radial >= 0 && axial >= 0 && epsilon > 0 && fn >= 3);
  $fn = fn;

  module cup() {
    color(cup_color) {
      difference() {
        cylinder(d=cup_d, h=cup_l);
        translate([0, 0, cup_l - bore_depth - epsilon]) {
          cylinder(d=bore_d, h=bore_depth + 2 * epsilon);
        }
        translate([-slot_w / 2, -cup_d / 2 - epsilon, cup_l - slot_depth]) {
          cube([slot_w, cup_d + 2 * epsilon, slot_depth + epsilon]);
        }
      }
    }
  }

  with_anchor(size=size, anchor=anchor) {
    translate([size[0] / 2, size[1] / 2, 0]) {
      if (slot_mode) {
        translate([0, 0, -axial]) {
          cylinder(d=max(cup_d, support_d) + 2 * radial,
                   h=size[2] + 2 * axial);
        }
        translate([0, 0, crown_z - axial]) {
          cylinder(d=gear_d + 2 * radial, h=gear_h + 2 * axial);
        }
        translate([0, 0, crown_z + gear_h - axial]) {
          cylinder(d=differential_case_swept_d(pl) + 2 * radial,
                   h=case_size[2] + 2 * axial);
        }
      } else {
        color(gear_color) {
          translate([0, 0, crown_z]) {
            cylinder(d=gear_d, h=gear_h);
          }
          translate([0, 0, cup_l]) {
            cylinder(d=support_d, h=support_l);
          }
        }
        color(body_color) {
          translate([0, 0, crown_z + gear_h]) {
            cuboid(size=case_size,
                   anchor=[0, 0, 1],
                   center=false,
                   r_factor=radius_factor,
                   use_minkowski=false,
                   fn=fn,
                   axis="z");
          }
          translate([0, 0, crown_z + span]) {
            cylinder(d=support_d, h=support_l);
          }
        }
        translate([0, 0, cup_l]) {
          rotate([180, 0, 0]) {
            cup();
          }
        }
        translate([0, 0, size[2] - cup_l]) {
          cup();
        }
      }
    }
  }
}
