/**
  * Module: Placeholder for generic Lidar
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>

show_lidar_mount_holes = true;

/**
  ─────────────────────────────────────────────────────────────────────────────
  lidar_size
  ─────────────────────────────────────────────────────────────────────────────

  Return the nominal lidar envelope, excluding unmodeled wiring.

  **Parameters:**
  - `plist`: Lidar property list; defaults to RPLIDAR C1.

  **Returns:** `[w, l, h]` in mm, with the body bottom at Z=0.
 */
function lidar_size(plist=rplidar_c1_plist) =
  concat(plist_get("size", plist),
         [plist_get("base_h", plist) + plist_get("top_h", plist)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  lidar_min_mount_z
  ─────────────────────────────────────────────────────────────────────────────

  Calculate a mounting height that clears both the optical band and payload.

  **Parameters:**
  - `obstacle_z`: Highest obstruction, including the head's intended swept envelope.
  - `clearance`: Vertical margin beneath the optical band.
  - `payload_z`: Highest component directly beneath the lidar.
  - `service_clearance`: Space between that component and the lidar bottom.
  - `plist`: Lidar property list; `base_h` is the optical band's lower edge.

  **Returns:** Minimum lidar bottom Z in the caller's chassis coordinates.
  Inputs are geometric envelopes, not just current component visibility states.
 */
function lidar_min_mount_z(obstacle_z, clearance,
                           payload_z, service_clearance,
                           plist=rplidar_c1_plist) =
  assert(clearance >= 0 && service_clearance >= 0)
  max(obstacle_z + clearance - plist_get("base_h", plist),
      payload_z + service_clearance);

/**
  ─────────────────────────────────────────────────────────────────────────────
  lidar_mount_slots
  ─────────────────────────────────────────────────────────────────────────────

  Emit the shared four-hole mounting pattern, without a head recess.

  **Parameters:**
  - `plist`: Lidar property list.
  - `h`: Cutter depth; defaults to the lidar's blind thread depth.
  - `d`: Hole diameter; defaults to nominal thread diameter, not plate clearance.
  - `anchor`: Anchor on the lidar footprint and cutter height, with Z=0..h by default.

  **Notes:** A mounting plate must supply its own clearance diameter and depth.
  The C1 permits at most 4 mm screw insertion beyond the plate into the sensor.
 */
module lidar_mount_slots(plist=rplidar_c1_plist, h, d, anchor=[0, 0, 1]) {
  depth = is_undef(h) ? plist_get("bolt_depth", plist) : h;
  dia = is_undef(d) ? plist_get("bolt_d", plist) : d;
  with_anchor(anchor, concat(plist_get("size", plist), [depth]), centered=true) {
    four_corner_children(size=plist_get("bolt_spacing", plist), center=true) {
      counterbore(h=depth, d=dia, no_bore=true, center=true, autoscale_step=0);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  lidar
  ─────────────────────────────────────────────────────────────────────────────

  Build the generic lidar placeholder using the RPLIDAR C1 defaults.

  **Parameters:**
  - `plist`: Body, optical and underside mounting dimensions.
  - `anchor`: Anchor on the complete nominal body envelope.
  - `show_mount_holes`: Cut the blind underside threads as plain nominal holes.

  **Notes:** Threads, cable and connector are not detailed geometry. The upper
  cylinder diameter and corner rounding remain visual approximations.
 */
module lidar(plist=rplidar_c1_plist, anchor=[0, 0, 1],
              show_mount_holes=show_lidar_mount_holes) {
  corner_r = plist_get("corner_r", plist);

  base_h = plist_get("base_h", plist);
  top_h = plist_get("top_h", plist);

  top_round_d = plist_get("top_round_d", plist);

  bolt_depth = plist_get("bolt_depth", plist);
  ring_h = plist_get("lid_ring_h", plist, 0);
  ring_w = plist_get("lid_ring_w", plist, 0);

  total_h = base_h + top_h;
  size = lidar_size(plist);
  cube_size = concat(plist_get("size", plist), [base_h]);

  color = plist_get("color", plist, matte_black);
  assert(bolt_depth > 0 && bolt_depth < base_h);

  with_anchor(anchor=anchor, size=size, centered=true) {
    difference() {
      maybe_color(color) {
        cuboid(size=cube_size, anchor=[0, 0, 1], r=corner_r);
        translate([0, 0, base_h]) {
          cylinder(d=top_round_d, h=top_h, $fn=40);
        }
      }
      if (show_mount_holes) {
        // Extend through the exterior face without changing the blind-hole end.
        translate([0, 0, -lidar_boolean_overlap])
          lidar_mount_slots(plist=plist, h=bolt_depth + lidar_boolean_overlap);
      }
      // Engrave the cosmetic top ring instead of creating a floating solid.
      if (ring_h > 0 && ring_w > 0) {
        translate([0, 0, total_h - ring_h]) {
          let (d = top_round_d / 2) {
            ring(outer_d=d, d=d - ring_w * 2, h=ring_h * 2, $fn=40);
          }
        }
      }
    }
  }
}

lidar();
