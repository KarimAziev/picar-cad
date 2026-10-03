/**
 * Module: Pad hole
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>

use <../lib/functions.scad>
use <../lib/shapes2d.scad>
use <../lib/transforms.scad>

function pad_hole_total_od(specs, bolt_d) =
  len(specs) > 0
  ? specs[len(specs) - 1][0]
  : bolt_d;

/** Module: Pad hole

    Create a multi-step circular pad around a bolt hole, defined by a set of
    diameter “bands”. Each band is rendered as a concentric ring and extruded
    to the requested thickness.

    Parameters:
    - `bolt_d`: Diameter of the central bolt hole (the innermost diameter).
    - `thickness` : Height of the pad in Z.
    - `specs` (list of 2-item lists): `[[dia1, color1], [dia2, color2], ...]`. Order does not matter.
    - `fn`: Circle resolution used for the generated rings.
    - `anchor`: Placement on the final X/Y/Z axes (default `[0, 0, 1]`).
    Each component is `1` to extend positively from the origin, `0` to
    center, or `-1` to extend negatively. Explicit `undef`, or an `undef`
    component, uses the corresponding default from `[1, 1, 1]`.
    - `orientation`: Logical width/length/height on X/Y/Z, respectively
       (default `"wlh"`; `undef` also uses `"wlh"`). Both width and length
       are the larger resolved end diameter. The direction from `d1` to `d2` is:
       - `"wlh"` or `"lwh"`: positive Z.
       - `"whl"`: negative Y; `"lhw"`: positive Y.
       - `"hlw"`: negative X; `"hwl"`: positive X.

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
                tolerance=0.1,
                fn=20,
                orientation="wlh",
                anchor=[0, 0, 1]) {
  sorted_specs = sort_by_idx(elems=specs, idx=0, asc=true);
  total_d = pad_hole_total_od(sorted_specs, bolt_d);

  with_orientation(from="wlh",
                   to=orientation,
                   anchor=anchor,
                   size=[total_d, total_d, thickness]) {
    union() {
      for (i = [0 : len(sorted_specs) - 1]) {
        let (spec = specs[i],
             prev_spec_dia = i > 0 ? specs[i - 1][0] : bolt_d,
             dia = spec[0],
             colr = spec[1],
             w = (dia - prev_spec_dia) / 2) {
          color(colr, alpha=1) {
            translate([0, 0, -tolerance / 2]) {
              linear_extrude(height=thickness + tolerance,
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
}

pad_hole(bolt_d=1.0,
         specs=[[3.4, "blue"], [4.0, "white"], [5.0, "red"]],
         thickness=2);