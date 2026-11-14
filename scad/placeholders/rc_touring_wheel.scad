
/**
  * Module: Generic 1:10 touring wheel and simple grooved road tire.
  *
  * The 65 x 26 mm envelope and 12 mm hex describe common commercial wheels.
  * Spokes, hub depth and tire section are illustrative, not a printable design
  * or a measured replica of a particular product. Local +Z points outboard.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../parameters.scad>

use <../lib/plist.scad>
use <../lib/transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_touring_wheel_spec
  ─────────────────────────────────────────────────────────────────────────────
  Resolve and validate the visual wheel's hardware dimensions.
  **Parameters:**
  - `pl`: Specification: tire_d, width, tire_bevel, rim_d, hex_af, hex_depth,
    axle_d, mount_z. `tire_bevel` is the radial and axial sidewall chamfer.
  **Returns:** A plist. mount_z is the hex contact plane measured from the
  inboard tire face; it is explicit backspacing, not a vendor offset number.
 */
function rc_touring_wheel_spec(pl=rc_touring_wheel_plist) =
  assert(plist_is(pl) && len(pl) > 0, "Supply a hardware specification")
  let (p = pl,
       d = plist_get("tire_d", p),
       w = plist_get("width", p),
       rim = plist_get("rim_d", p),
       mount = plist_get("mount_z", p),
       hex = plist_get("hex_af", p),
       depth = plist_get("hex_depth", p),
       bevel = plist_get("tire_bevel", p))
  assert(d > rim + 4 && rim > hex * 2 && w > 12)
  assert(hex > plist_get("axle_d", p) && depth > 0)
  assert(mount > depth && mount + 6 < w)
  assert(bevel >= 0 && bevel < w / 2 && bevel < (d - rim) / 2)
  p;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_touring_tire_profile
  ─────────────────────────────────────────────────────────────────────────────
  Return the tire's meridian profile before the tread grooves are cut.
  **Parameters:**
  - `pl`: Wheel dimensions accepted by `rc_touring_wheel_spec()`.
  **Returns:** Polygon vertices `[radius, axial_z]` in millimeters. Axial zero
  is the inboard tire face; the profile is symmetric about half its width.
 */
function rc_touring_tire_profile(pl=rc_touring_wheel_plist) =
  let (p = rc_touring_wheel_spec(pl),
       radius = plist_get("tire_d", p) / 2,
       rim_radius = plist_get("rim_d", p) / 2,
       width = plist_get("width", p),
       bevel = plist_get("tire_bevel", p))
  [[rim_radius, 0], [radius - bevel, 0], [radius, bevel],
   [radius, width - bevel], [radius - bevel, width], [rim_radius, width]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_touring_wheel_size
  ─────────────────────────────────────────────────────────────────────────────
  Return [diameter, diameter, width] for the complete tire envelope.
  **Parameters:** `pl`: Wheel specification.
 */
function rc_touring_wheel_size(pl=rc_touring_wheel_plist) =
  let (p = rc_touring_wheel_spec(pl), d = plist_get("tire_d", p))
  [d, d, plist_get("width", p)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_touring_wheel
  ─────────────────────────────────────────────────────────────────────────────
  Render a six-spoke rim with an optional tire, or its cylindrical envelope.
  **Parameters:**
  - `pl`: Wheel specification accepted by rc_touring_wheel_spec().
  - `anchor`: Tire-envelope anchor; default [0, 0, 1] keeps its axis on X=Y=0.
  - `show_tire`: Show the black tire with three shallow circumferential grooves.
  - `slot_mode`: Emit the complete tire envelope for packaging checks.
  - `clearance`: Radial and axial envelope allowance in slot mode.
  **Behavior:** Z=0 is the inboard tire face, +Z is outboard. Anchors retain the
  same full-tire reference box when the tire is hidden.
 */
module rc_touring_wheel(pl=rc_touring_wheel_plist,
                        anchor=[0, 0, 1],
                        show_tire=true,
                        slot_mode=false,
                        clearance=0) {
  p = rc_touring_wheel_spec(pl);
  size = rc_touring_wheel_size(pl);
  d = size[0];
  w = size[2];
  rim = plist_get("rim_d", p);
  hex = plist_get("hex_af", p);
  mount = plist_get("mount_z", p);
  depth = plist_get("hex_depth", p);
  axle = plist_get("axle_d", p);
  hub_r = hex / sqrt(3) + 1.3;
  fn = $preview ? 72 : 144;
  assert(clearance >= 0);

  with_anchor(size=size, anchor=anchor, centered=true) {
    if (slot_mode) {
      translate([0, 0, -clearance]) {
        cylinder(d=d + 2 * clearance, h=w + 2 * clearance, $fn=fn);
      }
    } else {
      color("#bbc3ce") {
        difference() {
          union() {
            difference() {
              translate([0, 0, 0.8]) {
                cylinder(d=rim, h=w - 1.6, $fn=fn);
              }
              cylinder(d=rim - 3, h=w + 1, $fn=fn);
            }
            translate([0, 0, mount - depth]) {
              cylinder(r=hub_r, h=depth + 4, $fn=fn);
            }
            for (a = [0:60:300]) {
              rotate([0, 0, a]) {
                hull() {
                  translate([hub_r - 1, 0, mount + 1]) {
                    cylinder(d=4.5, h=3, $fn=20);
                  }
                  translate([rim / 2 - 2.5, 2, w - 4.5]) {
                    cylinder(d=4.5, h=3, $fn=20);
                  }
                }
              }
            }
          }
          translate([0, 0, -0.01]) {
            cylinder(d=axle, h=w + 0.02, $fn=fn);
            cylinder(d=hex / cos(30), h=mount + 0.01, $fn=6);
          }
        }
      }
      if (show_tire) {
        color("#24272b") {
          difference() {
            rotate_extrude($fn=fn) {
              polygon(rc_touring_tire_profile(p));
            }
            for (z = [w * 0.3, w * 0.5, w * 0.7]) {
              translate([0, 0, z - 0.4]) {
                difference() {
                  cylinder(d=d + 1, h=0.8, $fn=fn);
                  cylinder(d=d - 1.6, h=0.8, $fn=fn);
                }
              }
            }
          }
        }
      }
    }
  }
}

rc_touring_wheel();
