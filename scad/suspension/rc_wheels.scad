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
  **Parameters:** `wheel_pl`: Wheel dimensions; defaults to `rc_wheel_plist`.
  **Returns:** [x, y, z], relative to the chassis top. Used only as a rear layout
  reference; actual front wheels inherit the knuckle's complete transform.
 */
function rc_front_wheel_reference_center(wheel_pl=rc_wheel_plist) =
  let (pose = front_linkage_pose(),
       d = plist_get("datums", pose),
       wheel = rc_touring_wheel_spec(wheel_pl),
       offset = rc_wheel_bearing_gap + rc_wheel_hex_h
                - plist_get("mount_z", wheel) + plist_get("width", wheel) / 2)
  plist_get("lower_ball", pose)
  + plist_get("rotation", pose)
  * (plist_get("hub", d) - plist_get("socket", d) + [offset, 0, 0]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_tire_vertical_half_extent
  ─────────────────────────────────────────────────────────────────────────────
  Return the tire envelope's vertical reach from its center.
  **Parameters:**
  - `axle_direction`: Nonzero axle direction in the assembly coordinate frame.
    Its magnitude is ignored; assembly +Z is vertical.
  - `wheel_pl`: Wheel dimensions; defaults to `rc_wheel_plist`.
  **Returns:** Positive distance in millimeters to either vertical extreme of
  the symmetric beveled tire profile, including the effect of wheel inclination.
  **Behavior:** Uses the continuous meridian profile. Tread recesses and render
  facets do not define the nominal contact envelope; tire deformation is absent.
 */
function rc_tire_vertical_half_extent(axle_direction,
                                      wheel_pl=rc_wheel_plist) =
  assert(is_list(axle_direction) && len(axle_direction) == 3
         && norm(axle_direction) > 0,
         "A nonzero axle direction is required")
  let (wheel = rc_touring_wheel_spec(wheel_pl),
       axial_z = min(1, abs(axle_direction[2]) / norm(axle_direction)),
       radial_z = sqrt(1 - axial_z * axial_z),
       half_width = plist_get("width", wheel) / 2)
  max([for (point = rc_touring_tire_profile(wheel))
    point[0] * radial_z + abs(point[1] - half_width) * axial_z]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_front_wheel_ground_z
  ─────────────────────────────────────────────────────────────────────────────
  Return the front tire's nominal contact-plane height relative to chassis top.
  **Parameters:** `wheel_pl`: Wheel dimensions; defaults to `rc_wheel_plist`.
  **Returns:** Tire-center Z minus the vertical reach at the solved front pose.
 */
function rc_front_wheel_ground_z(wheel_pl=rc_wheel_plist) =
  let (pose = front_linkage_pose(),
       axle_direction = plist_get("rotation", pose) * [1, 0, 0])
  rc_front_wheel_reference_center(wheel_pl)[2]
  - rc_tire_vertical_half_extent(axle_direction, wheel_pl);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_rear_level_wheel_center_z
  ─────────────────────────────────────────────────────────────────────────────
  Return an upright rear tire-center height sharing the front contact plane.
  **Parameters:**
  - `wheel_pl`: Rear wheel dimensions; defaults to `rc_wheel_plist`.
  - `front_wheel_pl`: Front wheel dimensions; defaults to `rc_wheel_plist`.
  **Returns:** Height relative to chassis top, using nominal undeformed tires.
 */
function rc_rear_level_wheel_center_z(wheel_pl=rc_wheel_plist,
                                      front_wheel_pl=rc_wheel_plist) =
  rc_front_wheel_ground_z(front_wheel_pl)
  + rc_tire_vertical_half_extent([1, 0, 0], wheel_pl);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_rear_wheel_reference_center
  ─────────────────────────────────────────────────────────────────────────────
  Locate the right rear preview tire center in native rear-deck coordinates.
  **Parameters:** `layout`: Resolved rear chassis layout.
  **Returns:** [x, y, z], including the suspension mounting height.
 */
function rc_rear_wheel_reference_center(layout) =
  let (reference = rc_front_wheel_reference_center(),
       track = is_undef(rc_rear_wheel_preview_track)
               ? 2 * reference[0]
               : rc_rear_wheel_preview_track,
       z = is_undef(rc_rear_wheel_preview_axis_z)
           ? rc_rear_level_wheel_center_z()
           : rc_rear_wheel_preview_axis_z,
       y = (plist_get("bulkhead_1_y", layout) + plist_get("bulkhead_2_y", layout)) / 2
           + rc_rear_wheel_preview_y_offset)
  [track / 2, y, suspension_chassis_mount_h + z];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_rear_wheels_preview
  ─────────────────────────────────────────────────────────────────────────────
  Show two upright rear wheels in the rear chassis's unanchored native frame.
  **Parameters:**
  - `layout`: rear_chassis_layout() result, owning the suspension mounting rows.
  - `show_tire`: Show rubber tires.
  **Behavior:** Standalone packaging view. Axle Y is the midpoint of the two
  bulkhead mounting groups plus an explicit preview offset.
  Track follows the solved front reference; upright tire height shares its
  nominal contact plane. Both accept explicit preview overrides.
  These are packaging placeholders, not a completed rear mechanical assembly.
 */
module rc_rear_wheels_preview(layout, show_tire=true) {
  center = rc_rear_wheel_reference_center(layout);
  w = rc_touring_wheel_size(rc_wheel_plist)[2];
  for (side = [-1, 1]) {
    translate([side * center[0], center[1], center[2]]) {
      rotate([0, side * 90, 0]) {
        translate([0, 0, -w / 2]) {
          rc_touring_wheel(pl=rc_wheel_plist, show_tire=show_tire);
        }
      }
    }
  }
}
