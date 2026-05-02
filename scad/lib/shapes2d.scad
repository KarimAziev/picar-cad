/**
 * Module: Utility modules that simplify common 2D geometric constructions.
 *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
 */

/**
  ─────────────────────────────────────────────────────────────────────────────
  calc_corner_rad
  ─────────────────────────────────────────────────────────────────────────────

  Compute the effective corner radius for rounded rectangle helpers.

  **Parameters:**
  - `size`: Rectangle size as `[width, height]`.
  - `r`: Explicit corner radius. When `undef`, `r_factor` is used instead.
  - `r_factor`: Fraction of the smaller rectangle dimension used when `r` is
    not provided.

  **Returns:**
  A radius clamped to half of the rectangle width and height.
 */
function calc_corner_rad(size, r, r_factor=0.3) =
  let (w = size[0],
       h = size[1],
       rad = min(is_undef(r) ? (min(h, w)) * r_factor : r, w / 2, h / 2))
  rad;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rounded_rect
  ─────────────────────────────────────────────────────────────────────────────

  Create a rounded rectangle using either four hulled circles or the selective
  rounding helper when only some sides should be rounded.

  **Parameters:**
  - `size`: Rectangle size as `[width, height]`.
  - `r`: Explicit corner radius. When `undef`, the radius comes from
    `r_factor`.
  - `center`: If `true`, center the rectangle on the origin.
  - `fn`: Fragment count for circular corners.
  - `r_factor`: Fraction of the smaller dimension used when `r` is `undef`.
  - `side`: Rounded side selection. Supported values are `"all"`, `"top"`,
    `"left"`, `"right"`, or `"bottom"`.

  **Examples:**
  ```scad
  rounded_rect([40, 20], r=3, center=true, fn=48);
  rounded_rect([100, 10], r_factor=0.25, side="top");
  ```
 */
module rounded_rect(size, r=undef, center=false, fn, r_factor=0.3, side) {
  w = size[0];
  h = size[1];
  rad = calc_corner_rad(size=size, r=r, r_factor=r_factor);

  if (rad == 0) {
    square(size, center=center);
  } else if (is_string(side) && side != "all") {
    rounded_rect_two(size=size,
                     r=r,
                     segments=is_undef(fn) ? 10 : fn,
                     r_factor=r_factor,
                     side=side,
                     center=center,
                     fn=fn);
  }
  else {
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

/**
  ─────────────────────────────────────────────────────────────────────────────
  rounded_rect_two
  ─────────────────────────────────────────────────────────────────────────────

  Create a rectangle with only two adjacent rounded corners by building a
  custom polygon.

  **Parameters:**
  - `size`: Rectangle size as `[width, height]`.
  - `r`: Explicit corner radius. When `undef`, the radius comes from
    `r_factor`.
  - `center`: If `true`, center the polygon on the origin.
  - `segments`: Number of points used for each rounded corner arc.
  - `r_factor`: Fraction of the smaller dimension used when `r` is `undef`.
  - `fn`: Optional polygon fragment hint.
  - `side`: Which edge pair receives the rounded corners: `"top"`, `"left"`,
    `"right"`, or `"bottom"`.

  **Examples:**
  ```scad
  rounded_rect_two([50, 20], r=4, center=true, segments=12, side="top");
  rounded_rect_two([80, 40], r_factor=0.25, side="left");
  ```
 */
module rounded_rect_two(size,
                        r=undef,
                        center=false,
                        segments=10,
                        r_factor=0.5,
                        fn,
                        side = "top" // "top" | "left" | "right" | "bottom"
                       ) {

  w = size[0];
  h = size[1];
  rad = min(is_undef(r) ? (min(h, w)) * r_factor : r, w / 2, h / 2);

  offst = center ? [-w/2, -h/2] : [0, 0];

  round_tl = (side == "top")|| (side == "left");
  round_tr = (side == "top")|| (side == "right");
  round_br = (side == "bottom") || (side == "right");
  round_bl = (side == "bottom") || (side == "left");

  function arc(cx, cy, a0, a1) =
    [for (i = [1:segments])
        let (a = a0 + i * ((a1 - a0)/segments))
          [cx + rad*cos(a), cy + rad*sin(a)]];

  pts =
    concat(round_bl ? [[rad, 0]] : [[0, 0]],
           round_br ? [[w-rad, 0]] : [[w, 0]],
           round_br ? arc(w-rad, rad, -90, 0) : [],
           round_tr ? [[w, h-rad]] : [[w, h]],
           round_tr ? arc(w-rad, h-rad, 0, 90) : [],
           round_tl ? [[rad, h]] : [[0, h]],
           round_tl ? arc(rad, h-rad, 90, 180) : [],
           round_bl ? [[0, rad]] : [[0, 0]],
           round_bl ? arc(rad, rad, 180, 270) : []);

  translate(offst)
    polygon(points = pts, $fn=fn);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  chamfered_square
  ─────────────────────────────────────────────────────────────────────────────

  Create a centered square with clipped 45-degree corners.

  **Parameters:**
  - `size`: Square width and height.
  - `chamfer`: Chamfer length measured along each edge. When `undef`, defaults
    to `size / 4`.
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

/**
  ─────────────────────────────────────────────────────────────────────────────
  chamfered_rect
  ─────────────────────────────────────────────────────────────────────────────

  Create a centered rectangle with chamfered corners.

  **Parameters:**
  - `size`: Rectangle size as `[width, height]`.
  - `chamfer`: Chamfer length measured along each edge. When `undef`, defaults
    to `size[1] / 4`.
 */
module chamfered_rect(size, chamfer) {
  x = size[0];
  y = size[1];
  chamfer = is_undef(chamfer) ? y / 4 : chamfer;
  hy = y / 2;
  hx = x / 2;
  cy = chamfer > hy ? hy : chamfer;
  cx = chamfer > hx ? hx : chamfer;
  pts = [[hx - cx,  hy],
         [hx,      hy - cy],
         [hx,     -hy + cy],
         [hx - cx, -hy],
         [-hx + cx, -hy],
         [-hx,     -hy + cy],
         [-hx,      hy - cy],
         [-hx + cx,  hy]];
  polygon(points = pts);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  ring_2d_outer
  ─────────────────────────────────────────────────────────────────────────────

  Create a 2D ring where `r` represents the inner radius.

  **Parameters:**
  - `r`: Inner radius. When `undef`, the radius is derived from `d / 2`.
  - `w`: Ring wall thickness added outside the inner radius.
  - `d`: Diameter fallback used when `r` is `undef`.
  - `fn`: Fragment count for both circles.
 */
module ring_2d_outer(r, w, d, fn) {
  r = is_undef(r) ? d / 2 : r;
  difference() {
    circle(r=r + w, $fn=fn);
    circle(r=r, $fn=fn);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  ring_2d_inner
  ─────────────────────────────────────────────────────────────────────────────

  Create a 2D ring where `r` represents the outer radius.

  **Parameters:**
  - `r`: Outer radius. When `undef`, the radius is derived from `d / 2`.
  - `w`: Ring wall thickness removed from the inside.
  - `d`: Diameter fallback used when `r` is `undef`.
  - `fn`: Fragment count for both circles.
 */
module ring_2d_inner(r, w, d, fn) {
  r = is_undef(r) ? d / 2 : r;
  difference() {
    circle(r=r, $fn=fn);
    circle(r=r - w, $fn=fn);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  ring_2d
  ─────────────────────────────────────────────────────────────────────────────

  Dispatch to either `ring_2d_outer()` or `ring_2d_inner()`.

  **Parameters:**
  - `r`: Radius interpreted according to `outer`.
  - `w`: Ring wall thickness.
  - `d`: Diameter fallback used when `r` is `undef`.
  - `fn`: Fragment count for both circles.
  - `outer`: If `true`, treat `r` as the inner radius. Otherwise treat `r` as
    the outer radius.
 */
module ring_2d(r, w, d, fn, outer) {
  if (outer) {
    ring_2d_outer(r, w, d, fn);
  } else {
    ring_2d_inner(r, w, d, fn);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  star_2d
  ─────────────────────────────────────────────────────────────────────────────

  Create a 2D star polygon centered at the origin.

  **Parameters:**
  - `n`: Number of star points.
  - `r_outer`: Radius of the outer tips.
  - `r_inner`: Radius of the inner valleys.
 */
module star_2d(n=5, r_outer=20, r_inner=10) {
  pts = [for (i = [0 : 2 * n - 1])
      let (angle = 360 / (2*n) * i,
           r = (i % 2 == 0) ? r_outer : r_inner)
        [r * cos(angle), r * sin(angle)]];
  polygon(points = pts);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  ellipse
  ─────────────────────────────────────────────────────────────────────────────

  Create a 2D ellipse by scaling a unit circle.

  **Parameters:**
  - `rx`: X radius.
  - `ry`: Y radius.
  - `$fn`: Fragment count for the base circle.
  - `center`: If `true`, center the ellipse on the origin. Otherwise place the
    bounding box in the positive quadrant.
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

/**
  ─────────────────────────────────────────────────────────────────────────────
  capsule
  ─────────────────────────────────────────────────────────────────────────────

  Create a vertical 2D capsule shape with semicircular ends.

  **Parameters:**
  - `y`: Center-to-center spacing between the two end circles.
  - `d`: End-cap diameter.
  - `center`: If `true`, center the capsule on the origin.
  - `$fn`: Fragment count for the end circles.
 */
module capsule(y, d, center=true, $fn=64) {
  r = d / 2;
  origin_shift = center ? [0, -y / 2] : [r, r];
  translate(origin_shift) {
    hull() {
      circle(r=r, $fn=$fn);
      translate([0, y]) circle(r=r, $fn=$fn);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  capsule_x
  ─────────────────────────────────────────────────────────────────────────────

  Create a horizontal 2D capsule shape with semicircular ends.

  **Parameters:**
  - `x`: Center-to-center spacing between the two end circles.
  - `d`: End-cap diameter.
  - `center`: If `true`, center the capsule on the origin.
  - `$fn`: Fragment count for the end circles.
 */
module capsule_x(x, d, center=true, $fn=64) {
  r = d / 2;
  origin_shift = center ? [-x / 2, 0] : [r, r];
  translate(origin_shift) {
    hull() {
      circle(r=r, $fn=$fn);
      translate([x, 0]) circle(r=r, $fn=$fn);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rect_border
  ─────────────────────────────────────────────────────────────────────────────

  Create a 2D rectangular frame using rounded rectangles.

  **Parameters:**
  - `size`: Reference size as `[width, height]`.
  - `border_w`: Difference between the outer and inner rectangle sizes.
  - `inner`: If `true`, `size` is treated as the outer footprint. Otherwise the
    outer footprint is expanded by `border_w`.
  - `r`: Explicit corner radius.
  - `center`: If `true`, center the frame on the origin.
  - `fn`: Fragment count for rounded corners.
  - `r_factor`: Radius fallback factor used when `r` is `undef`.
  - `round_side`: Optional side selection forwarded to `rounded_rect()`.
 */
module rect_border(size,
                   border_w=0.5,
                   inner=true,
                   r=0,
                   center=false,
                   fn,
                   r_factor=0.3,
                   round_side) {
  container_size = inner ? size : [size[0] + border_w, size[1] + border_w];
  translate([center ? 0 : size[0] / 2, center ? 0 : size[1] / 2, 0]) {

    difference() {
      rounded_rect(size=container_size,
                   r=r,
                   center=true,
                   fn=fn,
                   r_factor=r_factor,
                   side=round_side);
      rounded_rect(size=[container_size[0] - border_w,
                         container_size[1] - border_w],
                   r=r,
                   center=true,
                   fn=fn,
                   r_factor=r_factor,
                   side=round_side);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  triangle_SAS
  ─────────────────────────────────────────────────────────────────────────────

  Create a triangle from two side lengths and the included angle.

  **Parameters:**
  - `a`: Length of the first side, laid out on the X axis.
  - `b`: Length of the second side.
  - `ang`: Included angle in degrees between sides `a` and `b`.
 */
module triangle_SAS(a, b, ang) {
  polygon(points=[[0, 0],
                  [a, 0],
                  [b*cos(ang), b*sin(ang)]]);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  teardrop_2d
  ─────────────────────────────────────────────────────────────────────────────

  Create a printable teardrop-like hole profile from a circle and a pointed
  roof.

  **Parameters:**
  - `d`: Base circle diameter.
  - `ang`: Apex angle used to compute the pointed roof height.
  - `fn`: Fragment count for the circular portion.
  - `both_sides`: If `true`, mirror the pointed section to both sides.
 */
module teardrop_2d(d, ang=45, fn=30, both_sides=false) {
  h = (d / 4) / tan(ang / 2);
  pts = [[-d / 2, 0],
         [d / 2, 0],
         [0,   h]];
  hull() {
    circle(d=d, $fn=fn);
    polygon(pts);
    if (both_sides) {
      rotate([0, 0, 180]) {
        polygon(pts);
      }
    }
  }
}
