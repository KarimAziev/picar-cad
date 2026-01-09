/**
 * Module: Taper-capable helical spring
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>


// linear interpolation helper
function lerp(a, b, t) = a + (b - a) * t;

/**
   Taper-capable helical spring

   If d1/d2 are provided, mean coil diameter varies linearly from d1 (bottom) to d2 (top).
   Otherwise uses constant d.

   **Example**:
   ```scad
   spring(d1=14, d2=9, wire=1.2, turns=8, pitch=3.2, ends="plain");
   spring(d1=14, d2=9, wire=1.2, turns=8, pitch=3.2, ends="ground", end_turns=1);

   ```
*/
module spring(d=20,              // constant mean diameter if d1/d2 not set
              d1=undef,          // bottom mean diameter (taper)
              d2=undef,          // top mean diameter (taper)
              color=metallic_silver_5,
              wire=2,
              turns=10,
              pitch=5,
              ends="plain",
              end_turns=1,
              coil_fn=48,
              wire_fn=24) {
  use_taper = !(is_undef(d1) || is_undef(d2));
  D0 = use_taper ? d1 : d;
  D1 = use_taper ? d2 : d;

  assert(D0 > wire && D1 > wire,
         "mean diameter(s) must be greater than wire");
  assert(turns > 0);
  assert(pitch > 0);
  assert(end_turns >= 0);

  r = wire/2;
  L = turns*pitch;

  steps = max(8, ceil(turns*coil_fn));
  total_angle = 360*turns;
  da = total_angle/steps;
  dz = L/steps;

  function R_at_z(z) = (lerp(D0, D1, (L==0?0:z/L)))/2;

  module helix_segment(a0, z0, a1, z1, R0, R1) {
    hull() {
      translate([R0*cos(a0), R0*sin(a0), z0]) {
        rotate([0, 90, a0]) cylinder(h=0.01, r=r, $fn=wire_fn);
      }

      translate([R1*cos(a1), R1*sin(a1), z1]) {
        rotate([0, 90, a1]) {
          cylinder(h=0.01, r=r, $fn=wire_fn);
        }
      }
    }
  }

  module helix() {
    union() {
      for (i=[0:steps-1]) {
        let (a0 = i * da,
             a1 = (i + 1) * da,
             zA = i * dz,
             zB = (i + 1)*dz,
             R0 = R_at_z(zA),
             R1 = R_at_z(zB)) {
          helix_segment(a0, zA, a1, zB, R0, R1);
        }
      }
    }
  }

  module ground_ends() {
    g = min(end_turns * pitch, L / 2);

    difference() {
      helix();

      translate([0, 0, -1000]) {
        cube([4 * max(D0, D1), 4 * max(D0, D1), 1000 - r], center=false);
      }

      translate([-2 * max(D0, D1), -2 * max(D0, D1), L + r]) {
        cube([4 * max(D0, D1), 4 * max(D0, D1), 1000], center=false);
      }

      if (g > 0) {
        translate([-2 * max(D0, D1), -2 * max(D0, D1), -1]) {
          cube([4 * max(D0, D1), 4 * max(D0, D1), g], center=false);
        }

        translate([-2 * max(D0, D1), -2 * max(D0, D1), L-g]) {
          cube([4 * max(D0, D1), 4 * max(D0, D1), g + 1], center=false);
        }
      }
    }
  }

  color(color, alpha=1) {
    if (ends=="ground") {
      ground_ends();
    }
    else {
      helix();
    }
  }
}

spring(d1=20, d2=12, wire=2, turns=10, pitch=5, ends="plain");

// translate([35, 0, 0]) {
//   spring(d1=20,
//          d2=12,
//          wire=2,
//          turns=10,
//          pitch=5,
//          ends="ground",
//          end_turns=1);
// }