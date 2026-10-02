/**
  * Module: Removable gearbox mounting bosses and their base sockets.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../rc_params.scad>

use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <util.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  gearbox_boss
  ─────────────────────────────────────────────────────────────────────────────

  Render one removable support or its locating socket.

  **Parameters:**
  - `type`: `"front"` or `"rear"`, selecting the measured gearbox ear height.
  - `slot_mode`: Emit the locating pocket instead of the bored support.
  - `plist`: Motor hardware used when `params` is omitted.
  - `params`: Resolved bracket dimensions; overrides `plist` and all sizing.
  - `anchor`: Anchor of the solid boss envelope; `[0, 0, 1]` puts it on the
    print bed. `undef` retains the seating datum at Z=0, with the pocket
    engagement extending down to Z=-`boss_pocket_depth`.
  - `color`: Printed support color.

  A relief follows the gearbox bearing housing with 0.1 mm radial clearance.
  Slot mode uses the solid's anchor reference and extends 0.1 mm above the
  seating plane. A zero boss wall in `params` disables both modes.
 */
module gearbox_boss(type="front",
                    slot_mode=false,
                    plist=motor_plist,
                    params=undef,
                    anchor=undef,
                    color=cobalt_blue_metallic) {
  assert(type == "front" || type == "rear", "Boss type must be front or rear");
  p = is_undef(params) ? gearmotor_bracket_compute_params(plist) : params;
  od = plist_get("boss_od", p);
  d = plist_get("mount_bolt_d", p);
  depth = plist_get("boss_pocket_depth", p);
  h = plist_get(type, plist_get("boss_heights", p));
  shift = is_undef(anchor) ? [0, 0, 0]
    : to_anchor(normalize_anchor(anchor), [od, od, h], centered=true) + [0, 0, depth];
  if (od > d) {
    translate(shift) {
      if (slot_mode) {
        translate([0, 0, -depth]) {
          cylinder(d=plist_get("boss_pocket_od", p),
                   h=depth + 0.1,
                   $fn=$preview ? 48 : 300);
        }
      } else {
        difference() {
          translate([0, 0, -depth]) {
            ring(d=d,
                 od=od,
                 h=h,
                 color=color,
                 whole_color=false,
                 fn=$preview ? 48 : 300);
          }
          // Clear the front bearing housing where it overhangs the support.
          g = plist_get("gearbox_params", p);
          xy = plist_get("gearbox_hole_positions", p)[type == "rear" ? 0 : 1];
          translate([-xy[0],
                     -xy[1] - 0.1,
                     plist_get("outer_shaft_y_center", p)]) {
            rotate([-90, 0, 0]) {
              cylinder(d=plist_get("gearbox_shaft_boss_d", g) + 0.2,
                       h=plist_get("bearing_boss_h", g) + 0.2,
                       $fn=$preview ? 48 : 300);
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  gearbox_bosses
  ─────────────────────────────────────────────────────────────────────────────

  Place both supports in the bracket's native shaft-centered coordinates.

  **Parameters:**
  - `plist`: Motor hardware used when `params` is omitted.
  - `slot_mode`: Emit both locating pockets instead of supports.
  - `params`: Resolved bracket dimensions, including hole centers and base height.
  - `color`: Support color.
 */
module gearbox_bosses(plist=motor_plist,
                      slot_mode=false,
                      params=undef,
                      color=cobalt_blue_metallic) {
  p = is_undef(params) ? gearmotor_bracket_compute_params(plist) : params;
  holes = plist_get("gearbox_hole_positions", p);
  for (i = [0:1]) {
    translate(concat(holes[i], [plist_get("bracket_thickness", p)])) {
      gearbox_boss(type=i == 0 ? "rear" : "front",
                   params=p,
                   slot_mode=slot_mode,
                   color=color);
    }
  }
}

gearbox_bosses();
