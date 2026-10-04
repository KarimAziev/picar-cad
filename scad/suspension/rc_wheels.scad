/**
  * Module: Touring wheel placement at front knuckles and rear preview datums.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../rc_params.scad>

use <../lib/plist.scad>
use <../placeholders/rc_touring_wheel.scad>
use <front_linkage.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_knuckle_wheel
  ─────────────────────────────────────────────────────────────────────────────
  Attach a wheel to the native knuckle's outer bearing face (Z=0, outboard -Z).
  **Parameters:** `show_tire`: Show the tire around the rim.
  **Behavior:** The hex adapter and stepped stub are visual placeholders. Their
  dimensions and wheel backspacing remain packaging assumptions.
 */
module rc_knuckle_wheel(show_tire=true) {
  p = rc_touring_wheel_spec(rc_wheel_plist);
  face = rc_wheel_bearing_gap + rc_wheel_hex_h;
  rotate([180, 0, 0]) {
    color("#739cb9") {
      translate([0, 0, rc_wheel_bearing_gap]) {
        cylinder(d=plist_get("hex_af", p) / cos(30), h=rc_wheel_hex_h, $fn=6);
      }
    }
    color("#b9bec4") {
      cylinder(d=knuckle_outer_bearing_bore_d,
               h=rc_wheel_bearing_gap,
               $fn=32);
      cylinder(d=4, h=face + 6.5, $fn=32);
    }
    translate([0, 0, face - plist_get("mount_z", p)]) {
      rc_touring_wheel(pl=rc_wheel_plist, show_tire=show_tire);
    }
    color("#6b7078") {
      translate([0, 0, face + 4]) {
        difference() {
          cylinder(d=7 / cos(30), h=2.5, $fn=6);
          cylinder(d=4.2, h=2.5, $fn=32);
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_front_wheel_reference_center
  ─────────────────────────────────────────────────────────────────────────────
  Return the right tire center in the front suspension's solved reference pose.
  **Returns:** [x, y, z], relative to the chassis top. Used only as a rear layout
  reference; actual front wheels inherit the knuckle's complete transform.
 */
function rc_front_wheel_reference_center() =
  let (pose = front_linkage_pose(),
       d = plist_get("datums", pose),
       wheel = rc_touring_wheel_spec(rc_wheel_plist),
       offset = rc_wheel_bearing_gap + rc_wheel_hex_h
                - plist_get("mount_z", wheel) + plist_get("width", wheel) / 2)
  plist_get("lower_ball", pose)
  + plist_get("rotation", pose)
  * (plist_get("hub", d) - plist_get("socket", d) + [offset, 0, 0]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_rear_wheels_preview
  ─────────────────────────────────────────────────────────────────────────────
  Show two upright rear wheels in the rear chassis's unanchored native frame.
  **Parameters:**
  - `layout`: rear_chassis_layout() result, owning the suspension mounting rows.
  - `show_tire`: Show rubber tires.
  **Behavior:** Rear suspension and hubs have not been modeled. Axle Y is the
  midpoint of the two bulkhead mounting groups plus an explicit preview offset.
  Track and height default to the solved front reference, with optional overrides.
  These are packaging placeholders, not a completed rear mechanical assembly.
 */
module rc_rear_wheels_preview(layout, show_tire=true) {
  reference = rc_front_wheel_reference_center();
  track = is_undef(rc_rear_wheel_preview_track)
    ? 2 * reference[0] : rc_rear_wheel_preview_track;
  z = is_undef(rc_rear_wheel_preview_axis_z)
    ? reference[2] : rc_rear_wheel_preview_axis_z;
  y = (plist_get("bulkhead_1_y", layout) + plist_get("bulkhead_2_y", layout)) / 2
      + rc_rear_wheel_preview_y_offset;
  w = rc_touring_wheel_size(rc_wheel_plist)[2];
  for (side = [-1, 1]) {
    translate([side * track / 2, y, chassis_thickness + z]) {
      rotate([0, side * 90, 0]) {
        translate([0, 0, -w / 2]) {
          rc_touring_wheel(pl=rc_wheel_plist, show_tire=show_tire);
        }
      }
    }
  }
}
