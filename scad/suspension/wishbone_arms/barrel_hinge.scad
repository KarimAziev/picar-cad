/**
 * Module: Barrel hinge
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <../../lib/shapes2d.scad>

/**
 ─────────────────────────────────────────────────────────────────────────────
 barrel_hinge
 ─────────────────────────────────────────────────────────────────────────────

 **Example**:
 ```scad
 barrel_hinge(size=[10, 8, 5], d=3, distance=2);

 ```
*/
module barrel_hinge(size, distance, d) {
  length = size[0];
  h = size[1];
  thickness = size[2];
  hole_r = d / 2;
  translate([0, h, 0]) {
    rotate([90, 0, 0]) {
      linear_extrude(height=h, center=false) {
        difference() {
          rounded_rect([length, thickness],
                       center=false,
                       r_factor=0.5,
                       side="left",
                       fn=$preview ? 20 : 100);
          translate([hole_r + distance,
                     thickness / 2,
                     0]) {
            circle(r=hole_r, $fn=$preview ? 20 : 360);
          }
        }
      }
    }
  }
}

barrel_hinge(size=[10, 8, 5], d=3, distance=2);
