/**
 * Module: Pad hole
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>

use <../lib/functions.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>

/** Module: Pad hole

    Create a multi-step circular pad around a bolt hole, defined by a set of
    diameter “bands”. Each band is rendered as a concentric ring and extruded
    to the requested thickness.

    Parameters:
    - `bolt_d`: Diameter of the central bolt hole (the innermost diameter).
    - `thickness` : Height of the pad in Z.
    - `specs` (list of 2-item lists): `[[dia1, color1], [dia2, color2], ...]`. Order does not matter.
    - `fn`: Circle resolution used for the generated rings.

    Notes:
    - Diameters should be strictly increasing relative to `bolt_d` to avoid
    zero/negative-width bands (i.e. each `dia` should be > previous diameter).

    Example:

    ```scad
    pad_hole(bolt_d=2.0, specs=[[3.4, "blue"], [4.0, "white"], [5.0, "red"]], thickness=2);
    ```
*/
module pad_hole(bolt_d,
                specs,
                thickness,
                fn=20) {
  sorted_specs = sort_by_idx(elems=specs, idx=0, asc=true);
  union() {
    for (i = [0 : len(sorted_specs) - 1]) {
      let (spec = specs[i],
           prev_spec_dia=i > 0 ? specs[i - 1][0] : bolt_d,
           dia = spec[0],
           colr = spec[1],
           w = (dia - prev_spec_dia) / 2) {
        color(colr, alpha=1) {
          translate([0, 0, -0.05]) {
            linear_extrude(height=thickness + 0.1,
                           center=false,
                           convexity=2) {
              ring_2d(w=w, r=dia / 2, fn=fn);
            }
          }
        }
      }
    }
  }
}

pad_hole(bolt_d=2.0,
         specs=[[3.4, "blue"], [4.0, "white"], [5.0, "red"]],
         thickness=2);