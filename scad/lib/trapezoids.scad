/**
  * Module: Trapezoid helpers.
  *
  * This file provides 2D and extruded trapezoid profiles with optional corner
  * rounding for slider rails and other tapered geometry.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

use <transforms.scad>

/**
   ─────────────────────────────────────────────────────────────────────────────
   trapezoid
   ─────────────────────────────────────────────────────────────────────────────

   Create a plain isosceles trapezoid polygon.

   **Parameters:**
   - `b`: Bottom width.
   - `t`: Top width.
   - `h`: Trapezoid height.
   - `center`: If `true`, center the polygon on the origin.

   **Example**:
   ```scad
   trapezoid(b=30, t=20, h=20, center=true);
   trapezoid(b=20, t=30, h=20, center=true);
   ```
*/
module trapezoid(b=20, t=10, h=15, center=false) {
  m = (b - t) / 2;

  pts = [[0, 0],
         [b, 0],
         [b - m, h],
         [m, h]];

  polygon(points = center ?
          [for (p = pts) [p[0] - b/2, p[1] - h/2]] :
          pts);
}

/**
   ─────────────────────────────────────────────────────────────────────────────
   trapezoid_rounded
   ─────────────────────────────────────────────────────────────────────────────

   Create an isosceles trapezoid with all corners rounded.

   **Parameters:**
   - `b`: Bottom width.
   - `t`: Top width.
   - `h`: Trapezoid height.
   - `r`: Explicit corner radius. When `undef`, `r_factor` is used.
   - `center`: If `true`, center the polygon on the origin.
   - `r_factor`: Fraction of the smallest dimension used when `r` is `undef`.
 */
module trapezoid_rounded(b=20, t=10, h=15, r=undef, center=false, r_factor=0.1) {
  rad = is_undef(r) ? min(b, t, h) * r_factor : r;
  offset(r=rad, chamfer=false) {
    offset(r=-rad, chamfer=false) {
      trapezoid(b=b, t=t, h=h, center=center);
    }
  }
}

/**
   ─────────────────────────────────────────────────────────────────────────────
   trapezoid_rounded_bottom
   ─────────────────────────────────────────────────────────────────────────────

   Create a trapezoid whose bottom two corners are rounded.

   **Parameters:**
   - `b`: Bottom width.
   - `t`: Top width.
   - `h`: Trapezoid height.
   - `r`: Explicit corner radius. When `undef`, `r_factor` is used.
   - `r_factor`: Fraction of the smallest dimension used when `r` is `undef`.
   - `center`: If `true`, center the polygon on the origin.
   - `$fn`: Number of segments used for each bottom fillet.
 */
module trapezoid_rounded_bottom(b=20,
                                t=10,
                                h=15,
                                r=undef,
                                r_factor=0.1,
                                center=false,
                                $fn=20) {
  rad = (is_undef(r) ? min(b, t, h) * r_factor : r);
  m = (b - t) / 2;
  n = $fn;

  left_fillet = [for (i = [0 : n])
      let (theta = 180 + i * (90 / n))
        [rad + rad * cos(theta), rad + rad * sin(theta)]];

  right_fillet = [for (i = [1 : n])
      let (theta = -90 + i * (90 / n))
        [(b - rad) + rad * cos(theta), rad + rad * sin(theta)]];

  pts = concat(left_fillet,
               [[b - rad, 0]],
               right_fillet,
               [[b, rad], [b - m, h]],
               [[m, h]],
               [[0, rad]]);

  polygon(points = center ? [for (p = pts) [p[0] - b/2, p[1] - h/2]] : pts);
}

/**
   ─────────────────────────────────────────────────────────────────────────────
   trapezoid_rounded_top
   ─────────────────────────────────────────────────────────────────────────────

   Create a trapezoid whose top two corners are rounded.

   **Parameters:**
   - `b`: Bottom width.
   - `t`: Top width.
   - `h`: Trapezoid height.
   - `r`: Explicit corner radius. When `undef`, `r_factor` is used.
   - `r_factor`: Fraction of the smallest dimension used when `r` is `undef`.
   - `center`: If `true`, center the polygon on the origin.
   - `$fn`: Number of segments used for each top fillet.
 */
module trapezoid_rounded_top(b=20,
                             t=10,
                             h=15,
                             r=undef,
                             r_factor=0.1,
                             center=false,
                             $fn=20) {
  translate([0, center ? 0 : h, 0]) {
    scale([1, -1]) {
      trapezoid_rounded_bottom(b=t,
                               t=b,
                               h=h,
                               r=r,
                               r_factor=r_factor,
                               center=center,
                               $fn=$fn);
    }
  }
}
/**
   ─────────────────────────────────────────────────────────────────────────────
   trapezoid_vertical
   ─────────────────────────────────────────────────────────────────────────────

   Extrude a trapezoid along Y so the taper is visible in the X/Z plane.

   **Parameters:**
   - `size`: Trapezoid prism dimensions as `[bottom_x, length_y, height_z, top_x]`.
     If `top_x` is omitted, the top width matches `bottom_x`.
   - `r`: Explicit corner radius.
   - `r_factor`: Fraction of the smallest trapezoid dimension used when `r` is
     `undef`.
   - `round_side`: Which side to round: `"all"`, `"top"`, or `"bottom"`.
   - `center`: If `true`, center the extrusion around X and Y.


   **Example**:
   ```scad
   trapezoid_vertical(round_side="bottom", center=true, size=[18, 10, 15, 14])

   ```
*/
module trapezoid_vertical(size=[20, 10, 15, 12],
                          r,
                          r_factor=0.1,
                          round_side="all", // "all" | "top" | "bottom"
                          center=true) {
  b = size[0];
  l = size[1];
  h = size[2];
  t = is_undef(size[3]) ? b : size[3];

  translate([center ? -b / 2 : t > b ? (t - b) / 2 : 0, center ? l / 2 : l, 0]) {
    if (round_side == "top") {
      translate([b / 2, 0, h / 2]) {
        rotate([90, 0, 0]) {
          linear_extrude(height=l, center=false) {
            trapezoid_rounded_top(t=t,
                                  b=b,
                                  h=h,
                                  r=r,
                                  r_factor=r_factor,
                                  center=true);
          }
        }
      }
    } else {
      rotate([90, 0, 0]) {
        linear_extrude(height=l, center=false) {
          if (is_undef(round_side) || round_side == "all") {
            trapezoid_rounded(t=t, b=b, h=h, r=r, r_factor=r_factor);
          }  else if (round_side == "bottom") {
            trapezoid_rounded_bottom(t=t,
                                     b=b,
                                     h=h,
                                     r=r,
                                     r_factor=r_factor);
          }
        }
      }
    }
  }
}
