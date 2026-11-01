/**
  * Module: Eye-mounted on-road shock absorber.
  *
  * The cylinder, piston rod, eye bores and helical spring expose hardware
  * clearance and mounting alignment over the configured shock travel.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

use <../lib/transforms.scad>
use <hsp_rear_drivetrain.scad>
use <spring.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_shock_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the shock envelope `[width, length, height]` along positive Z.
  **Parameters:**
  - `pl`: Shock dimensions and travel settings: `rear_shock_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  - `eye_distance`: Required distance between the mounting-eye centers.
 */
function hsp_shock_size(pl, eye_distance) =
  let (d = max(_hsp_value(pl, "spring_d"), _hsp_value(pl, "eye_d"),
               _hsp_value(pl, "body_d")),
       w = max(d, _hsp_value(pl, "eye_w")))
  [d, w, eye_distance + _hsp_value(pl, "eye_d")];

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_shock_eye_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return the two shock eye centers in unanchored coordinates.
  **Parameters:**
  - `pl`: Shock dimensions and travel settings: `rear_shock_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  - `eye_distance`: Required distance between mounting-eye centers.
  **Returns:** Two vec3 positions ordered along positive Z.
 */
function hsp_shock_eye_positions(pl, eye_distance) =
  let (size = hsp_shock_size(pl, eye_distance),
       z = _hsp_value(pl, "eye_d") / 2)
  [[size[0] / 2, size[1] / 2, z],
   [size[0] / 2, size[1] / 2, z + eye_distance]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_shock_absorber
  ─────────────────────────────────────────────────────────────────────────────
  Model a shock at an explicit eye-center distance, with transverse Y eye bores.
  **Parameters:**
  - `pl`: Shock dimensions and travel settings: `rear_shock_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  - `eye_distance`: Required eye-center distance within the configured travel.
  - `anchor`: Reference-box anchor, using the complete outside envelope.
  - `slot_mode`: Emit eye bores along Y at the same mounting centers.
  - `show_spring`: Display the helical spring; seats and piston remain visible.
  **Behavior:** The bottom eye's piston rod extends toward the top-eye cylinder.
  Slot-mode bore depth equals the configured eye width; consumers may extend
  the cutter along Y when cutting wider mounting tabs.

  **Examples:**
  Save this example at the repository root.
  ```scad
  include <scad/suspension/rear_axle/hardware_params.scad>
  use <scad/lib/plist.scad>
  use <scad/placeholders/hsp_shock_absorber.scad>
  hsp_shock_absorber(pl=rear_shock_spec,
                     eye_distance=plist_get("eye_distance", rear_shock_spec),
                     anchor=[1, 1, 1], slot_mode=false, show_spring=true);
  ```
 */
module hsp_shock_absorber(pl,
                          eye_distance,
                          anchor=[1, 1, 1],
                          slot_mode=false,
                          show_spring=true) {
  size = hsp_shock_size(pl, eye_distance);
  eye_d = _hsp_value(pl, "eye_d");
  eye_w = _hsp_value(pl, "eye_w");
  eye_bore_d = _hsp_value(pl, "eye_bore_d");
  neck_l = _hsp_value(pl, "eye_neck_l");
  body_d = _hsp_value(pl, "body_d");
  body_l = _hsp_value(pl, "body_l");
  shaft_d = _hsp_value(pl, "shaft_d");
  spring_d = _hsp_value(pl, "spring_d");
  wire = _hsp_value(pl, "spring_wire");
  turns = _hsp_value(pl, "spring_turns");
  seat_h = _hsp_value(pl, "spring_seat_h");
  epsilon = _hsp_value(pl, "csg_epsilon");
  upper_seat_z = eye_distance - neck_l;
  spring_start = neck_l + seat_h + wire / 2;
  spring_end = upper_seat_z - seat_h - wire / 2;
  spring_l = spring_end - spring_start;
  assert(eye_distance >= _hsp_value(pl, "eye_distance_min")
         && eye_distance <= _hsp_value(pl, "eye_distance_max"),
         "Shock eye distance exceeds the configured stroke");
  assert(eye_d > eye_bore_d && eye_bore_d > 0 && eye_w > 0);
  assert(body_d > shaft_d && shaft_d > 0 && body_l > 0);
  assert(upper_seat_z - body_l >= neck_l);
  assert(spring_d - 2 * wire > body_d && spring_l > turns * wire);
  assert(neck_l > eye_d / 2 && seat_h > 0 && epsilon > 0);
  $fn = _hsp_value(pl, "fn");
  with_anchor(size=size, anchor=anchor) {
    translate([size[0] / 2, size[1] / 2, eye_d / 2]) {
      if (slot_mode) {
        for (z = [0, eye_distance]) {
          translate([0, 0, z]) {
            rotate([90, 0, 0]) {
              cylinder(d=eye_bore_d, h=eye_w + 2 * epsilon, center=true);
            }
          }
        }
      } else {
        difference() {
          union() {
            color(_hsp_value(pl, "eye_color")) {
              for (z = [0, eye_distance]) {
                translate([0, 0, z]) {
                  rotate([90, 0, 0]) {
                    cylinder(d=eye_d, h=eye_w, center=true);
                  }
                }
              }
              cylinder(d=eye_w, h=neck_l + seat_h);
              translate([0, 0, upper_seat_z]) {
                cylinder(d=eye_w, h=neck_l);
              }
              translate([0, 0, neck_l]) {
                cylinder(d=spring_d, h=seat_h);
              }
            }
            color(_hsp_value(pl, "body_color")) {
              translate([0, 0, upper_seat_z - body_l]) {
                cylinder(d=body_d, h=body_l);
              }
              translate([0, 0, upper_seat_z - seat_h]) {
                cylinder(d=spring_d, h=seat_h);
              }
            }
            color(_hsp_value(pl, "shaft_color")) {
              translate([0, 0, neck_l]) {
                cylinder(d=shaft_d, h=upper_seat_z - neck_l);
              }
            }
          }
          for (z = [0, eye_distance]) {
            translate([0, 0, z]) {
              rotate([90, 0, 0]) {
                cylinder(d=eye_bore_d,
                         h=max(eye_w, body_d) + 2 * epsilon,
                         center=true);
              }
            }
          }
        }
        if (show_spring) {
          translate([0, 0, spring_start]) {
            spring(d=spring_d - wire,
                   d1=undef,
                   d2=undef,
                   color=_hsp_value(pl, "spring_color"),
                   wire=wire,
                   turns=turns,
                   pitch=spring_l / turns,
                   ends="plain",
                   end_turns=0,
                   coil_fn=_hsp_value(pl, "spring_coil_fn"),
                   wire_fn=_hsp_value(pl, "spring_wire_fn"));
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  hsp_shock_between
  ─────────────────────────────────────────────────────────────────────────────
  Place shock eye centers on two assembly points.
  **Parameters:**
  - `start`: Piston-side eye center `[x, y, z]`.
  - `end`: Cylinder-side eye center `[x, y, z]`.
  - `pl`: Shock dimensions and travel settings: `rear_shock_spec` from
    `scad/suspension/rear_axle/hardware_params.scad`.
  - `show_spring`: Display the helical spring.
  **Behavior:** The center distance follows the supplied endpoints and must
  remain inside the configured travel. For endpoints in the XZ plane, the
  mounting-eye axes remain parallel to Y.
 */
module hsp_shock_between(start, end, pl, show_spring=true) {
  direction = end - start;
  eye_distance = norm(direction);
  assert(eye_distance > 0, "Shock endpoints must differ");
  first_eye = hsp_shock_eye_positions(pl, eye_distance)[0];
  translate(start) {
    rotate([0, acos(direction[2] / eye_distance),
            atan2(direction[1], direction[0])]) {
      translate(-first_eye) {
        hsp_shock_absorber(pl=pl,
                          eye_distance=eye_distance,
                          anchor=[1, 1, 1],
                          slot_mode=false,
                          show_spring=show_spring);
      }
    }
  }
}
