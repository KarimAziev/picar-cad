/**
 * Module: Utility modules that simplify common 2D geometric constructions.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

/*
  Create a 2D rounded rectangle by hull-ing four circles placed at the
  rectangle's corners.

  **Parameters**
  - `size`:     [width, height]  (2-element vector). Width = `size[0]`, height = `size[1]`.
  - `r`:        corner radius. If undef, a radius is computed as `min(width, height) * r_factor`.
  - `r_factor`: fraction of the smaller dimension to use for radius when r is undef (default `0.3`).
  - `center`:   if `true`, the rectangle is centered at the origin. If `false`, the lower-left corner is at the origin.
  - `fn`:       resolution (`$fn`) passed to the circle() calls; controls the smoothness of the rounded corners.

  **Examples**
  ```scad
  rounded_rect([40, 20], r=3, center=true, fn=48);
  ```
  ```scad
  rounded_rect([100, 10], r=undef, r_factor=0.25, center=false, fn=36);
  ```
*/
module rounded_rect(size, r=undef, center=false, fn, r_factor=0.3) {
  w = size[0];
  h = size[1];
  rad = is_undef(r) ? (min(h, w)) * r_factor : r;
  if (rad == 0) {
    square(size, center=center);
  } else {
    offst = center ? [-w/2, -h/2] : [0, 0];

    hull() {
      translate([rad, rad] + offst) {
        circle(rad, $fn=fn);
      }
      translate([w - rad, rad] + offst) {
        circle(rad, $fn=fn);
      }
      translate([rad, h - rad] + offst) {
        circle(rad, $fn=fn);
      }
      translate([w - rad, h - rad] + offst)
        circle(rad, $fn=fn);
    }
  }
}

/*

  Create a 2D rounded rectangle by building a polygon composed of straight
  edges and approximated quarter-circle arcs (point lists).

  Parameters
  - `size`:     [width, height] (2-element vector).
  - `r`:        corner radius. If `undef`, defaults to `min(width, height) / 2`.
  (Setting it to half the smaller dimension produces end-caps
  similar to a capsule when one dimension is much larger.)
  - `center`:   if `true`, the rectangle is centered at the origin. If `false`,
  the lower-left corner is at the origin.
  - `segments`: number of subdivisions used to approximate each quarter-circle
  arc. Increasing this improves smoothness at the cost of more points.

  - Ensure `r` is `<= min(width, height)/2` for expected results (the code does
  not enforce a clamp).

  Examples
  ```scad
  rounded_rect_two([50, 20], r=4, center=true, segments=12);
  ```
  ```
  rounded_rect_two([80, 40], r=undef, center=false, segments=24);
  ```
*/
module rounded_rect_two(size, r=undef, center=false, segments=10) {
  w = size[0];
  h = size[1];
  rad = is_undef(r) ? (min(h, w)) / 2 : r;
  offst = center ? [-w/2, -h/2] : [0, 0];

  pts_bottom = [[0, 0], [w, 0]];
  pts_right = [[w, 0], [w, h - rad]];
  arc_top_right = [for (i = [1 : segments])
      let (a = i * (90 / segments))
        [(w - rad) + rad * cos(a), (h - rad) + rad * sin(a)]];
  pts_top_edge = [[w - rad, h], [rad, h]];

  arc_top_left = [for (i = [1 : segments])
      let (a = 90 + i * (90 / segments))
        [rad + rad * cos(a), (h - rad) + rad * sin(a)]];

  pts_left = [[0, h - rad], [0, 0]];

  pts = concat(pts_bottom,
               pts_right,
               arc_top_right,
               pts_top_edge,
               arc_top_left,
               pts_left);

  translate(offst) {
    polygon(points = pts);
  }
}

/*
  Produces an 8-vertex chamfered square (a common octagon shape).

  **Parameters**:
  - `size`: full width/height of the square (centered at origin)
  - `chamfer`: length of the chamfer measured along each edge from the corner.
  If omitted, defaults to `size / 4`. The chamfer is clamped to a maximum of size/2 (so it
  never exceeds half the side length).

  **Example**
  40x40 square with 6 mm chamfers
  ```scad
  chamfered_square(40, 6);
  ```
*/
module chamfered_square(size, chamfer) {
  chamfer = is_undef(chamfer) ? size / 4 : chamfer;
  h = size / 2;
  c = chamfer > h ? h : chamfer;
  pts = [[h - c,  h],
         [h,      h - c],
         [h,     -h + c],
         [h - c, -h],
         [-h + c, -h],
         [-h,     -h + c],
         [-h,      h - c],
         [-h + c,  h]];
  polygon(points = pts);
}

/*

  Create an annulus (ring) where the provided radius is treated as the inner radius,
  and the outer radius is inner + wall thickness.

  **Parameters:**
  - `r`: inner radius. If omitted, `r` is computed as `d / 2` (see `d`).
  - `w`: wall thickness. Outer `radius = r + w`. Must be >= 0.
  - `d`: diameter used to derive `r` when `r` is not provided.
  - `fn`: passed to circle as `$fn` to control circle resolution.

  **Examples:**
  - inner radius 10, wall 3
  ```scad
  ring_2d_outer(10, 3);
  ```
  - or using diameter:
  ```scad
  ring_2d_outer(undef, 3, 20);
  ```
*/
module ring_2d_outer(r, w, d, fn) {
  r = is_undef(r) ? d / 2 : r;
  difference() {
    circle(r=r + w, $fn=fn);
    circle(r=r, $fn=fn);
  }
}

/*
  Create an annulus (ring) where the provided radius is treated as the outer radius,
  and the inner radius is outer - wall thickness.

  **Parameters:**
  - `r`: outer radius. If omitted, `r` is computed as d/2 (see `d`).
  - `w`: wall thickness. Inner `radius = r - w`. Must satisfy `r - w >= 0`.
  - `d`: diameter used to derive `r` when `r` is not provided.
  - `fn`: passed to circle as $fn to control circle resolution.

  **Notes:**
  - Ensure `r >= w` to avoid a negative inner radius.

  **Examples:**

  - outer radius 12, wall 3 (inner radius will be 9)

  ```scad
  ring_2d_inner(12, 3);

  - using diameter:
  ```
  ring_2d_inner(undef, 3, 24);
*/

module ring_2d_inner(r, w, d, fn) {
  r = is_undef(r) ? d / 2 : r;
  difference() {
    circle(r=r, $fn=fn);
    circle(r=r - w, $fn=fn);
  }
}

/*
  Dispatch wrapper that selects either ring_2d_outer or ring_2d_inner.

  **Parameters:**
  - `r`: outer radius. If omitted, `r` is computed as `d / 2` (see `d`).
  - `w`: wall thickness. Inner radius = `r - w`. Must satisfy `r - w >= 0`.
  - `d`: diameter used to derive `r` when `r` is not provided.
  - `fn`: passed to circle as `$fn` to control circle resolution.
  - `outer`: if true, treat r as the inner radius (use ring_2d_outer).
  if `false` (default behavior if omitted), treat `r` as the outer radius.

  **Examples:**
  ```scad
  outer flag true -> inner radius = 10, outer = 13
  ```
  ```scad
  ring_2d(10, 3, undef, 64, true);
  ```
  outer flag false -> outer radius = 10, inner = 7:
  ```scad
  ring_2d(10, 3, undef, 64, false);
  ```
*/
module ring_2d(r, w, d, fn, outer) {
  if (outer) {
    ring_2d_outer(r, w, d, fn);
  } else {
    ring_2d_inner(r, w, d, fn);
  }
}

/*
  Create a 2D star polygon centered at the origin.

  **Parameters:**
  - n: number of star points (spikes). Default: 5. Must be >= 2.
  - r_outer: radius of the outer points (spike tips). Default: 20.
  - r_inner: radius of the inner points (between tips). Default: 10.

  **Notes:**
  - For a visually correct star, set 0 <= r_inner <= r_outer. If r_inner == r_outer the
  shape degenerates to a regular 2n-gon.

  **Examples:**

  - standard 5-point star
  ```scad
  star_2d();
  ```
  - 8-point star, outer 30, inner 12
  ```scad
  star_2d(8, 30, 12);
  ```
*/
module star_2d(n=5, r_outer=20, r_inner=10) {
  pts = [for (i = [0 : 2 * n - 1])
      let (angle = 360 / (2*n) * i,
           r = (i % 2 == 0) ? r_outer : r_inner)
        [r * cos(angle), r * sin(angle)]];
  polygon(points = pts);
}

/*

  Draw a 2D ellipse by scaling a unit circle. Reusable module for creating
  ellipses with controllable radii, resolution and centering behavior.

  **Parameters:**
  - `rx`: horizontal radius (half-width). Default 10.
  - `ry`: vertical radius (half-height). Default 5.
  - `$fn`:   polygon resolution for the circle (higher -> smoother). Default 100.
  - `center`: If true, ellipse is centered at the origin.
  If false, the bounding box is placed from (0,0) to (2*rx, 2*ry).

  **Notes:**
  To specify full width/height instead of radii, call ellipse(width/2, height/2, ...).

  **Examples:**
  Centered ellipse with rx=20, ry=10:

  ```scad
  ellipse(20, 10, $fn=200, center=true);
  ```

  Ellipse placed in the first quadrant with bounding box 0..40 by 0..20:
  ```scad
  ellipse(20, 10, $fn=100, center=false);
  ```
*/

module ellipse(rx=10, ry=5, $fn=100, center=true) {

  if (center) {
    scale([rx, ry]) circle(r=1, $fn=$fn);
  }
  else {
    translate([rx, ry]) {
      scale([rx, ry]) {
        circle(r=1, $fn=$fn);
      }
    }
  }
}

module capsule(y=20, d=10, center=true, $fn=64) {
  r = d / 2;
  origin_shift = center ? [0, -y / 2] : [-r, r];
  translate(origin_shift) {
    hull() {
      circle(r=r, $fn=$fn);
      translate([0, y]) circle(r=r, $fn=$fn);
    }
  }
}
