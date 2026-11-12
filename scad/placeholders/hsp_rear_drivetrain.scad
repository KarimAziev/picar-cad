/**
  * Module: HSP rear differential, pinion, dogbone and reducing sleeve.
  *
  * Hardware envelopes provide shared bearing and shaft datums for housing
  * construction. Gear blanks represent clearance envelopes, without teeth.
  * The metal drivetrain parts are visualization and fit-check placeholders.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

use <../lib/plist.scad>
use <../lib/transforms.scad>
use <differential.scad>

function _hsp_value(pl, key) =
  assert(plist_is(pl), "Hardware dimensions must be a property list")
  assert(plist_has(key, pl), str("Missing hardware setting: ", key))
  plist_get(key, pl);

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_differential_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the complete differential envelope `[width, length, height]`.
  **Parameters:**
  - `pl`: Hardware settings: `rear_differential_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  **Behavior:** The axle runs along X; all geometry occupies positive bounds.
 */
function hsp_rear_differential_size(pl) =
  let (size = differential_size(pl),
       bearing_d = _hsp_value(pl, "bearing_d"))
  [size[2], max(size[0], bearing_d), max(size[1], bearing_d)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_differential_axis
  ─────────────────────────────────────────────────────────────────────────────
  Return the axle midpoint `[x, y, z]` in unanchored differential coordinates.
  **Parameters:**
  - `pl`: Hardware settings: `rear_differential_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
 */
function hsp_rear_differential_axis(pl) =
  hsp_rear_differential_size(pl) / 2;

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_differential_bearing_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return the two support-bearing centers, ordered along positive X.
  **Parameters:**
  - `pl`: Hardware settings: `rear_differential_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  **Returns:** Two vec3 positions in unanchored differential coordinates.
 */
function hsp_rear_differential_bearing_positions(pl) =
  let (size = hsp_rear_differential_size(pl),
       support_l = _hsp_value(pl, "support_l"),
       bearing_h = _hsp_value(pl, "bearing_h"),
       gap = _hsp_value(pl, "bearing_shoulder_gap"),
       x = _hsp_value(pl, "cup_l") + support_l - gap - bearing_h / 2)
  assert(gap >= 0 && bearing_h + gap <= support_l,
         "Differential bearing must lie on the support journal")
  [[x, size[1] / 2, size[2] / 2],
   [size[0] - x, size[1] / 2, size[2] / 2]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_differential_output_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return the nominal dogbone ball centers inside the two drive cups.
  **Parameters:**
  - `pl`: Hardware settings: `rear_differential_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  **Returns:** Two vec3 positions, ordered along positive X, before anchoring.
 */
function hsp_rear_differential_output_positions(pl) =
  let (size = hsp_rear_differential_size(pl),
       depth = _hsp_value(pl, "cup_ball_depth"))
  assert(depth > 0 && depth < _hsp_value(pl, "cup_l"))
  [[depth, size[1] / 2, size[2] / 2],
   [size[0] - depth, size[1] / 2, size[2] / 2]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_differential_gear_position
  ─────────────────────────────────────────────────────────────────────────────
  Return the crown-gear envelope center in unanchored coordinates.
  **Parameters:**
  - `pl`: Hardware settings: `rear_differential_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
 */
function hsp_rear_differential_gear_position(pl) =
  let (size = hsp_rear_differential_size(pl))
  [_hsp_value(pl, "cup_l") + _hsp_value(pl, "support_l")
   + _hsp_value(pl, "gear_h") / 2, size[1] / 2, size[2] / 2];

module _hsp_bearing(d, id, h, epsilon) {
  assert(d > id && id > 0 && h > 0);
  difference() {
    cylinder(d=d, h=h, center=true);
    cylinder(d=id, h=h + 2 * epsilon, center=true);
  }
}

module _hsp_drive_cup(pl) {
  d = _hsp_value(pl, "cup_d");
  l = _hsp_value(pl, "cup_l");
  bore_d = _hsp_value(pl, "cup_bore_d");
  slot_w = _hsp_value(pl, "cup_slot_w");
  depth = _hsp_value(pl, "cup_slot_depth");
  epsilon = _hsp_value(pl, "csg_epsilon");
  assert(d > bore_d && bore_d > 0 && slot_w > 0);
  assert(depth > _hsp_value(pl, "cup_ball_depth") && depth < l);
  difference() {
    cylinder(d=d, h=l);
    translate([0, 0, l - depth]) {
      cylinder(d=bore_d, h=depth + epsilon);
      translate([-d / 2 - epsilon, -slot_w / 2, 0]) {
        cube([d + 2 * epsilon, slot_w, depth + epsilon]);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_differential
  ─────────────────────────────────────────────────────────────────────────────
  Model the differential case, crown envelope, slotted cups and support bearings.
  **Parameters:**
  - `pl`: Hardware settings: `rear_differential_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  - `anchor`: Reference-box anchor; `[1, 1, 1]` preserves positive bounds.
  - `slot_mode`: Emit clearance envelopes, including the bearing seats.
  - `show_bearings`: Display support bearings in solid mode.
  **Behavior:** Shaft axis is X; the crown is on the negative-X body end.
  Slot mode preserves solid-mode datums and applies configured clearances.

  **Examples:**
  Save this example at the repository root.
  ```scad
  include <scad/suspension/rear_axle/hardware_params.scad>
  use <scad/placeholders/hsp_rear_drivetrain.scad>
  hsp_rear_differential(pl=rear_differential_spec, anchor=[1, 1, 1],
                        slot_mode=false, show_bearings=true);
  ```
 */
module hsp_rear_differential(pl,
                             anchor=[1, 1, 1],
                             slot_mode=false,
                             show_bearings=true) {
  size = hsp_rear_differential_size(pl);
  native_size = differential_size(pl);
  bearings = hsp_rear_differential_bearing_positions(pl);
  bearing_d = _hsp_value(pl, "bearing_d");
  bearing_id = _hsp_value(pl, "bearing_id");
  bearing_h = _hsp_value(pl, "bearing_h");
  radial = _hsp_value(pl, "radial_clearance");
  axial = _hsp_value(pl, "axial_clearance");
  epsilon = _hsp_value(pl, "csg_epsilon");
  $fn = _hsp_value(pl, "fn");
  with_anchor(size=size, anchor=anchor) {
    // Native Z becomes axle X; cup slots open along vehicle Z for the pins.
    translate([0,
               (size[1] - native_size[0]) / 2,
               (size[2] - native_size[1]) / 2]) {
      multmatrix([[0, 0, 1, 0], [1, 0, 0, 0],
                  [0, 1, 0, 0], [0, 0, 0, 1]]) {
        differential(pl=pl, anchor=[1, 1, 1], slot_mode=slot_mode);
      }
    }
    if (slot_mode || show_bearings) {
      color(_hsp_value(pl, "bearing_color")) {
        for (p = bearings) {
          translate(p) {
            rotate([0, 90, 0]) {
              if (slot_mode) {
                cylinder(d=bearing_d + 2 * radial,
                         h=bearing_h + 2 * axial,
                         center=true);
              } else {
                _hsp_bearing(bearing_d, bearing_id, bearing_h, epsilon);
              }
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_pinion_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the pinion assembly envelope `[width, length, height]` along +Z.
  **Parameters:**
  - `pl`: Hardware settings: `rear_pinion_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
 */
function hsp_rear_pinion_size(pl) =
  let (d = max(_hsp_value(pl, "gear_d"), _hsp_value(pl, "bearing_d")))
  [d, d, _hsp_value(pl, "shaft_l")];

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_pinion_bearing_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return pinion bearing centers in unanchored coordinates.
  **Parameters:**
  - `pl`: Hardware settings: `rear_pinion_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  **Returns:** Vec3 centers, ordered by the configured bearing-center list.
 */
function hsp_rear_pinion_bearing_positions(pl) =
  let (size = hsp_rear_pinion_size(pl))
  [for (z = _hsp_value(pl, "bearing_centers_z"))
    [size[0] / 2, size[1] / 2, z]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_pinion_gear_position
  ─────────────────────────────────────────────────────────────────────────────
  Return the gear envelope midpoint in unanchored pinion coordinates.
  **Parameters:**
  - `pl`: Hardware settings: `rear_pinion_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
 */
function hsp_rear_pinion_gear_position(pl) =
  let (size = hsp_rear_pinion_size(pl))
  [size[0] / 2, size[1] / 2, _hsp_value(pl, "gear_h") / 2];

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_pinion_shaft_end
  ─────────────────────────────────────────────────────────────────────────────
  Return the motor-side shaft end in unanchored pinion coordinates.
  **Parameters:**
  - `pl`: Hardware settings: `rear_pinion_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
 */
function hsp_rear_pinion_shaft_end(pl) =
  let (size = hsp_rear_pinion_size(pl))
  [size[0] / 2, size[1] / 2, size[2]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_pinion
  ─────────────────────────────────────────────────────────────────────────────
  Model the pinion envelope and 5 mm shaft with its support bearings.
  **Parameters:**
  - `pl`: Hardware settings: `rear_pinion_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  - `anchor`: Reference-box anchor.
  - `slot_mode`: Emit gear, shaft and bearing clearance envelopes.
  - `show_bearings`: Display support bearings in solid mode.
  **Behavior:** The gear starts at Z=0; the motor-side shaft extends along +Z.
  The tapered gear blank is a packaging envelope, without a meshing tooth model.

  **Examples:**
  Save this example at the repository root.
  ```scad
  include <scad/suspension/rear_axle/hardware_params.scad>
  use <scad/placeholders/hsp_rear_drivetrain.scad>
  hsp_rear_pinion(pl=rear_pinion_spec, anchor=[1, 1, 1],
                  slot_mode=false, show_bearings=true);
  ```
 */
module hsp_rear_pinion(pl,
                       anchor=[1, 1, 1],
                       slot_mode=false,
                       show_bearings=true) {
  size = hsp_rear_pinion_size(pl);
  gear_d = _hsp_value(pl, "gear_d");
  tip_d = _hsp_value(pl, "gear_tip_d");
  gear_h = _hsp_value(pl, "gear_h");
  shaft_d = _hsp_value(pl, "shaft_d");
  bearing_d = _hsp_value(pl, "bearing_d");
  bearing_id = _hsp_value(pl, "bearing_id");
  bearing_h = _hsp_value(pl, "bearing_h");
  bearing_positions = hsp_rear_pinion_bearing_positions(pl);
  radial = _hsp_value(pl, "radial_clearance");
  axial = _hsp_value(pl, "axial_clearance");
  epsilon = _hsp_value(pl, "csg_epsilon");
  assert(gear_d >= tip_d && tip_d > shaft_d && shaft_d > 0);
  assert(gear_h > 0 && size[2] > gear_h && bearing_id == shaft_d);
  assert(len(bearing_positions) == 2);
  assert(bearing_positions[0][2] - bearing_h / 2 >= gear_h);
  assert(bearing_positions[1][2] - bearing_positions[0][2] >= bearing_h);
  assert(bearing_positions[1][2] + bearing_h / 2 < size[2]);
  assert(radial >= 0 && axial >= 0 && epsilon > 0);
  $fn = _hsp_value(pl, "fn");
  with_anchor(size=size, anchor=anchor) {
    translate([size[0] / 2, size[1] / 2, 0]) {
      if (slot_mode) {
        translate([0, 0, -axial]) {
          cylinder(d=gear_d + 2 * radial, h=gear_h + 2 * axial);
          cylinder(d=shaft_d + 2 * radial, h=size[2] + 2 * axial);
        }
      } else {
        color(_hsp_value(pl, "gear_color")) {
          cylinder(d1=tip_d, d2=gear_d, h=gear_h);
        }
        color(_hsp_value(pl, "shaft_color")) {
          cylinder(d=shaft_d, h=size[2]);
        }
      }
    }
    for (p = bearing_positions) {
      translate(p) {
        if (slot_mode) {
          cylinder(d=bearing_d + 2 * radial,
                   h=bearing_h + 2 * axial,
                   center=true);
        } else if (show_bearings) {
          color(_hsp_value(pl, "bearing_color")) {
            _hsp_bearing(bearing_d, bearing_id, bearing_h, epsilon);
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_motor_sleeve_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the metal reducing sleeve envelope `[diameter, diameter, length]`.
  **Parameters:**
  - `pl`: Hardware settings: `rear_motor_sleeve_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
 */
function hsp_motor_sleeve_size(pl) =
  [_hsp_value(pl, "d"), _hsp_value(pl, "d"),
   _hsp_value(pl, "motor_engagement") + _hsp_value(pl, "pinion_engagement")
   + _hsp_value(pl, "shaft_end_gap")];

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_motor_sleeve
  ─────────────────────────────────────────────────────────────────────────────
  Model a metal reducing sleeve with stepped shaft bores and radial screw holes.
  **Parameters:**
  - `pl`: Hardware settings: `rear_motor_sleeve_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  - `anchor`: Reference-box anchor.
  - `slot_mode`: Emit the external sleeve clearance envelope.
  **Behavior:** Motor bore opens at Z=0; pinion bore opens at positive Z.
  Both engagement lengths exclude the central shaft-end gap. Screw holes are
  centered over each engagement, at the configured angular positions.

  **Examples:**
  Save this example at the repository root.
  ```scad
  include <scad/suspension/rear_axle/hardware_params.scad>
  use <scad/placeholders/hsp_rear_drivetrain.scad>
  hsp_motor_sleeve(pl=rear_motor_sleeve_spec, anchor=[1, 1, 1],
                   slot_mode=false);
  ```
 */
module hsp_motor_sleeve(pl,
                        anchor=[1, 1, 1],
                        slot_mode=false) {
  size = hsp_motor_sleeve_size(pl);
  motor_d = _hsp_value(pl, "motor_bore_d");
  pinion_d = _hsp_value(pl, "pinion_bore_d");
  motor_l = _hsp_value(pl, "motor_engagement");
  pinion_l = _hsp_value(pl, "pinion_engagement");
  gap = _hsp_value(pl, "shaft_end_gap");
  grub_d = _hsp_value(pl, "grub_d");
  angles = _hsp_value(pl, "grub_angles");
  radial = _hsp_value(pl, "radial_clearance");
  axial = _hsp_value(pl, "axial_clearance");
  epsilon = _hsp_value(pl, "csg_epsilon");
  assert(size[0] > max(motor_d, pinion_d) && min(motor_d, pinion_d) > 0);
  assert(motor_l > grub_d && pinion_l > grub_d && grub_d > 0 && gap >= 0);
  assert(len(angles) > 0 && radial >= 0 && axial >= 0 && epsilon > 0);
  $fn = _hsp_value(pl, "fn");
  with_anchor(size=size, anchor=anchor) {
    translate([size[0] / 2, size[1] / 2, 0]) {
      if (slot_mode) {
        translate([0, 0, -axial]) {
          cylinder(d=size[0] + 2 * radial, h=size[2] + 2 * axial);
        }
      } else {
        color(_hsp_value(pl, "color")) {
          difference() {
            cylinder(d=size[0], h=size[2]);
            translate([0, 0, -epsilon]) {
              cylinder(d=motor_d, h=motor_l + gap + 2 * epsilon);
            }
            translate([0, 0, motor_l]) {
              cylinder(d=pinion_d, h=pinion_l + gap + epsilon);
            }
            for (z = [motor_l / 2, size[2] - pinion_l / 2]) {
              for (angle = angles) {
                translate([0, 0, z]) {
                  rotate([0, 90, angle]) {
                    cylinder(d=grub_d, h=size[0] / 2 + epsilon);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_wheel_dogbone
  ─────────────────────────────────────────────────────────────────────────────
  Model a complete wheel dogbone with two balls and transverse drive pins.
  **Parameters:**
  - `pl`: Hardware settings: `rear_dogbone_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  - `anchor`: Anchor relative to the joint-center reference box.
  **Behavior:** The default `[0, 0, 1]` places ball centers at `[0, 0, 0]`
  and `[0, 0, pin_center_l]`. Balls extend beyond both Z ends of this reference
  box. Drive pins run along X; the reference box spans `pin_l` on X and
  `ball_d` on Y. This joint-center datum supports suspension articulation.

  **Examples:**
  Save this example at the repository root.
  ```scad
  include <scad/suspension/rear_axle/hardware_params.scad>
  use <scad/placeholders/hsp_rear_drivetrain.scad>
  hsp_wheel_dogbone(pl=rear_dogbone_spec, anchor=[0, 0, 1]);
  ```
 */
module hsp_wheel_dogbone(pl, anchor=[0, 0, 1]) {
  l = _hsp_value(pl, "pin_center_l");
  ball_d = _hsp_value(pl, "ball_d");
  shank_d = _hsp_value(pl, "shank_d");
  pin_d = _hsp_value(pl, "pin_d");
  pin_l = _hsp_value(pl, "pin_l");
  assert(l > ball_d && ball_d > shank_d && shank_d > 0);
  assert(pin_l >= ball_d && pin_d > 0 && pin_d < ball_d);
  $fn = _hsp_value(pl, "fn");
  with_anchor(size=[pin_l, ball_d, l], anchor=anchor, centered=true) {
    color(_hsp_value(pl, "color")) {
      cylinder(d=shank_d, h=l);
      for (z = [0, l]) {
        translate([0, 0, z]) {
          sphere(d=ball_d);
          rotate([0, 90, 0]) {
            cylinder(d=pin_d, h=pin_l, center=true);
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_wheel_axle_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the wheel axle envelope including support bearings and hex adapter.
  **Parameters:**
  - `pl`: Hardware settings: `rear_wheel_axle_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  **Returns:** `[width, length, height]`, with the shaft along positive Z.
 */
function hsp_rear_wheel_axle_size(pl) =
  let (d = max(_hsp_value(pl, "inner_bearing_d"),
               _hsp_value(pl, "outer_bearing_d"),
               _hsp_value(pl, "cup_flange_d"),
               _hsp_value(pl, "hex_af") / cos(30)))
  [d, d, _hsp_value(pl, "total_l")];

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_wheel_axle_ball_position
  ─────────────────────────────────────────────────────────────────────────────
  Return the wheel dogbone ball center inside its cup before anchoring.
  **Parameters:**
  - `pl`: Hardware settings: `rear_wheel_axle_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
 */
function hsp_rear_wheel_axle_ball_position(pl) =
  let (size = hsp_rear_wheel_axle_size(pl))
  [size[0] / 2, size[1] / 2, _hsp_value(pl, "cup_ball_depth")];

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_wheel_axle_bearing_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return inner and outer wheel bearing centers before anchoring.
  **Parameters:**
  - `pl`: Hardware settings: `rear_wheel_axle_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  **Returns:** Two vec3 positions in order from the dogbone cup toward the wheel.
 */
function hsp_rear_wheel_axle_bearing_positions(pl) =
  let (size = hsp_rear_wheel_axle_size(pl),
       half_h = _hsp_value(pl, "bearing_h") / 2)
  [for (start = [_hsp_value(pl, "inner_bearing_start"),
                 _hsp_value(pl, "outer_bearing_start")])
    [size[0] / 2, size[1] / 2, start + half_h]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_wheel_axle_mount_z
  ─────────────────────────────────────────────────────────────────────────────
  Return the outboard hex face along the wheel shaft's local +Z axis.
  **Parameters:**
  - `pl`: Hardware settings: `rear_wheel_axle_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  **Returns:** Wheel contact datum measured from the cup mouth, in millimeters.
 */
function hsp_rear_wheel_axle_mount_z(pl) =
  _hsp_value(pl, "outer_bearing_start") + _hsp_value(pl, "bearing_h")
  + _hsp_value(pl, "hex_l");

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_rear_wheel_axle
  ─────────────────────────────────────────────────────────────────────────────
  Model a wheel drive cup, axle, cross pin, hex adapter and support bearings.
  **Parameters:**
  - `pl`: Hardware settings: `rear_wheel_axle_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  - `anchor`: Reference-box anchor including bearing and hex envelopes.
  - `slot_mode`: Emit shaft, cup and bearing clearance envelopes.
  - `show_bearings`: Display inner and outer bearing hardware.
  - `show_hex`: Display the wheel hex and its drive pin.
  **Behavior:** The cup opens at Z=0, and the wheel thread extends along +Z.
  The 10 mm inner bearing seats over the cup barrel; the 5 mm outer bearing
  seats on the shaft. The thread is represented by its major-diameter envelope.

  **Examples:**
  Save this example at the repository root.
  ```scad
  include <scad/suspension/rear_axle/hardware_params.scad>
  use <scad/placeholders/hsp_rear_drivetrain.scad>
  hsp_rear_wheel_axle(pl=rear_wheel_axle_spec, anchor=[1, 1, 1],
                      slot_mode=false, show_bearings=true, show_hex=true);
  ```
 */
module hsp_rear_wheel_axle(pl,
                           anchor=[1, 1, 1],
                           slot_mode=false,
                           show_bearings=true,
                           show_hex=true) {
  size = hsp_rear_wheel_axle_size(pl);
  cup_l = _hsp_value(pl, "cup_l");
  cup_d = _hsp_value(pl, "cup_d");
  flange_d = _hsp_value(pl, "cup_flange_d");
  flange_h = _hsp_value(pl, "cup_flange_h");
  shaft_d = _hsp_value(pl, "shaft_d");
  thread_d = _hsp_value(pl, "thread_d");
  thread_l = _hsp_value(pl, "thread_l");
  bearing_h = _hsp_value(pl, "bearing_h");
  bearings = hsp_rear_wheel_axle_bearing_positions(pl);
  bearing_ds = [_hsp_value(pl, "inner_bearing_d"),
                _hsp_value(pl, "outer_bearing_d")];
  bearing_ids = [_hsp_value(pl, "inner_bearing_id"),
                 _hsp_value(pl, "outer_bearing_id")];
  pin_z = _hsp_value(pl, "pin_center_z");
  pin_d = _hsp_value(pl, "pin_d");
  pin_l = _hsp_value(pl, "pin_l");
  hex_af = _hsp_value(pl, "hex_af");
  hex_l = _hsp_value(pl, "hex_l");
  hex_z = hsp_rear_wheel_axle_mount_z(pl) - hex_l;
  radial = _hsp_value(pl, "radial_clearance");
  axial = _hsp_value(pl, "axial_clearance");
  epsilon = _hsp_value(pl, "csg_epsilon");
  assert(cup_d == bearing_ids[0] && shaft_d == bearing_ids[1]);
  assert(cup_l >= _hsp_value(pl, "inner_bearing_start") + bearing_h);
  assert(_hsp_value(pl, "outer_bearing_start") >= cup_l);
  assert(pin_z - pin_d / 2 >= hex_z && pin_z + pin_d / 2 < hex_z + hex_l);
  assert(size[2] - thread_l >= pin_z + pin_d / 2);
  assert(flange_d > cup_d && flange_h > 0 && flange_h < cup_l);
  assert(thread_d > 0 && thread_d <= shaft_d && size[2] > hex_z + hex_l);
  $fn = _hsp_value(pl, "fn");
  with_anchor(size=size, anchor=anchor) {
    translate([size[0] / 2, size[1] / 2, 0]) {
      if (slot_mode) {
        translate([0, 0, -axial]) {
          cylinder(d=cup_d + 2 * radial, h=cup_l + 2 * axial);
          cylinder(d=flange_d + 2 * radial, h=flange_h + 2 * axial);
          cylinder(d=shaft_d + 2 * radial, h=size[2] + 2 * axial);
        }
      } else {
        color(_hsp_value(pl, "body_color")) {
          difference() {
            union() {
              translate([0, 0, cup_l]) {
                rotate([180, 0, 0]) {
                  _hsp_drive_cup(pl);
                }
                cylinder(d=shaft_d, h=size[2] - thread_l - cup_l);
              }
              difference() {
                cylinder(d=flange_d, h=flange_h);
                translate([0, 0, -epsilon]) {
                  cylinder(d=_hsp_value(pl, "cup_bore_d"),
                           h=flange_h + 2 * epsilon);
                  translate([-flange_d / 2,
                             -_hsp_value(pl, "cup_slot_w") / 2,
                             0]) {
                    cube([flange_d, _hsp_value(pl, "cup_slot_w"),
                          flange_h + 2 * epsilon]);
                  }
                }
              }
              translate([0, 0, size[2] - thread_l]) {
                cylinder(d=thread_d, h=thread_l);
              }
            }
            translate([0, 0, pin_z]) {
              rotate([0, 90, 0]) {
                cylinder(d=pin_d, h=shaft_d + 2 * epsilon, center=true);
              }
            }
          }
        }
        if (show_hex) {
          color(_hsp_value(pl, "hex_color")) {
            difference() {
              translate([0, 0, hex_z]) {
                cylinder(d=hex_af / cos(30), h=hex_l, $fn=6);
              }
              translate([0, 0, hex_z - epsilon]) {
                cylinder(d=shaft_d, h=hex_l + 2 * epsilon);
              }
              translate([-hex_af / 2, -pin_d / 2, hex_z - epsilon]) {
                cube([hex_af, pin_d, pin_z - hex_z + pin_d / 2 + epsilon]);
              }
            }
          }
          color(_hsp_value(pl, "bearing_color")) {
            translate([0, 0, pin_z]) {
              rotate([0, 90, 0]) {
                cylinder(d=pin_d, h=pin_l, center=true);
              }
            }
          }
        }
      }
    }
    for (i = [0, 1]) {
      translate(bearings[i]) {
        if (slot_mode) {
          cylinder(d=bearing_ds[i] + 2 * radial,
                   h=bearing_h + 2 * axial,
                   center=true);
        } else if (show_bearings) {
          color(_hsp_value(pl, "bearing_color")) {
            _hsp_bearing(bearing_ds[i], bearing_ids[i], bearing_h, epsilon);
          }
        }
      }
    }
  }
}
