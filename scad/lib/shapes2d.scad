/**
 * Module: Utility modules that simplify common 2D geometric constructions.
 *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
 */

use <functions.scad>
use <transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  calc_corner_rad
  ─────────────────────────────────────────────────────────────────────────────

  Compute the clamped corner radius for a rectangular profile.

  **Parameters:**
  - `size`: Profile dimensions `[width, length]` on X/Y.
  - `r`: Absolute radius or percentage string such as `"10%"`, relative to
    the smaller profile dimension. `undef` uses `r_factor`.
  - `r_factor`: Fraction of the smaller dimension (default `0.3`).

  **Returns:**
  The resolved radius, capped at half of each profile dimension.

  **Examples:**
  ```scad
  calc_corner_rad([40, 20], "10%"); // -> 2
  calc_corner_rad([40, 20], 30);    // -> 10
  ```
 */
function calc_corner_rad(size, r, r_factor=0.3) =
  let (w = size[0],
       h = size[1],
       r = maybe_percent_string_to_num(r, min(w, h)),
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
  - `r`: Absolute corner radius or percentage of the smaller X/Y dimension.
    When `undef`, the radius comes from `r_factor`.
  - `center`: Default X/Y placement when `anchor` is omitted or its X/Y
    components are `undef`. If `true`, center on those axes; otherwise extend
    positively from the origin (default `false`).
  - `fn`: Fragment count for circular corners.
  - `r_factor`: Fraction of the smaller dimension used when `r` is `undef`.
  - `side`: Rounded side selection. Supported values are `"all"`, `"top"`,
    `"left"`, `"right"`, `"bottom"`, `"top_left"`, `"top_right"`,
    `"bottom_left"`, or `"bottom_right"`. Corner names round only that corner.
  - `anchor`: Per-axis placement as `[x, y, z]`. Each component is `1` to
    extend positively, `0` to center, or `-1` to extend negatively. Defaults
    to `[1, 1, 1]`, or `[0, 0, 1]` when `center=true`. Individual `undef`
    components use the same defaults. The reference size is
    `[size[0], size[1], 0]`, so Z anchoring leaves the shape at `z=0`.

  **Examples:**
  ```scad
  rounded_rect([40, 20], r=3, center=true, fn=48);
  rounded_rect([100, 10], r_factor=0.25, side="top");
  rounded_rect([40, 20], r=3, anchor=[-1, 0, 1]);
  ```
 */
module rounded_rect(size, r=undef, center=false, fn, r_factor=0.3, side, anchor) {
  w = size[0];
  h = size[1];
  rad = calc_corner_rad(size=size, r=r, r_factor=r_factor);
  anchor = [with_default(anchor[0], center ? 0 : 1),
            with_default(anchor[1], center ? 0 : 1),
            with_default(anchor[2], 1)];

  with_anchor(anchor=anchor, size=[w, h, 0]) {
    if (rad == 0) {
      square(size);
    } else if (is_string(side) && side != "all") {
      rounded_rect_two(size=size,
                       r=r,
                       segments=is_undef(fn) ? 10 : fn,
                       r_factor=r_factor,
                       side=side,
                       fn=fn);
    } else {
      hull() {
        translate([rad, rad]) {
          circle(rad, $fn=fn);
        }
        translate([w - rad, rad]) {
          circle(rad, $fn=fn);
        }
        translate([rad, h - rad]) {
          circle(rad, $fn=fn);
        }
        translate([w - rad, h - rad]) {
          circle(rad, $fn=fn);
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rounded_rect_two
  ─────────────────────────────────────────────────────────────────────────────

  Create a rectangle with one corner or two adjacent corners rounded using a
  custom polygon.

  **Parameters:**
  - `size`: Rectangle size as `[width, height]`.
  - `r`: Absolute corner radius or percentage of the smaller X/Y dimension.
    When `undef`, the radius comes from `r_factor`.
  - `center`: Default X/Y placement when `anchor` is omitted or its X/Y
    components are `undef`. If `true`, center on those axes; otherwise extend
    positively from the origin (default `false`).
  - `segments`: Number of points used for each rounded corner arc.
  - `r_factor`: Fraction of the smaller dimension used when `r` is `undef`.
  - `fn`: Optional polygon fragment hint.
  - `side`: Which edge pair receives the rounded corners: `"top"`, `"left"`,
    `"right"`, or `"bottom"`. A single corner can be selected with `"top_left"`,
    `"top_right"`, `"bottom_left"`, or `"bottom_right"`.
  - `anchor`: Per-axis placement as `[x, y, z]`. Each component is `1` to
    extend positively, `0` to center, or `-1` to extend negatively. Defaults
    to `[1, 1, 1]`, or `[0, 0, 1]` when `center=true`. Individual `undef`
    components use the same defaults. The reference size is
    `[size[0], size[1], 0]`, so Z anchoring leaves the shape at `z=0`.

  **Examples:**
  ```scad
  rounded_rect_two([50, 20], r=4, center=true, segments=12, side="top");
  rounded_rect_two([80, 40], r_factor=0.25, side="left");
  rounded_rect_two([50, 20], r=4, side="top_left", anchor=[0, -1, 1]);
  ```
 */
module rounded_rect_two(size,
                        r=undef,
                        center=false,
                        segments=10,
                        r_factor=0.5,
                        fn,
                        side="top",
                        anchor) {

  w = size[0];
  h = size[1];
  rad = calc_corner_rad(size=size, r=r, r_factor=r_factor);

  anchor = [with_default(anchor[0], center ? 0 : 1),
            with_default(anchor[1], center ? 0 : 1),
            with_default(anchor[2], 1)];

  round_tl = side == "top" || side == "left" || side == "top_left";
  round_tr = side == "top" || side == "right" || side == "top_right";
  round_br = side == "bottom" || side == "right" || side == "bottom_right";
  round_bl = side == "bottom" || side == "left" || side == "bottom_left";

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

  with_anchor(anchor=anchor, size=[w, h, 0]) {
    polygon(points = pts, $fn=fn);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  chamfered_square
  ─────────────────────────────────────────────────────────────────────────────

  Create a square with clipped 45-degree corners.

  **Parameters:**
  - `size`: Square width and length.
  - `chamfer`: Distance trimmed along each edge, as a number or percentage of
    `size`. `undef` defaults to `size / 4`; values above `size / 2` are capped.
  - `anchor`: Reference-box placement `[x, y, z]` (default `[0, 0, 1]`).
    Each component is `1` for positive placement, `0` for centering, or `-1`
    for negative placement. The reference size is `[size, size, 0]`, so Z
    anchoring leaves the profile at `z=0`.

  **Examples:**
  ```scad
  chamfered_square(20, chamfer="10%", anchor=[1, 1, 1]);
  ```
 */
module chamfered_square(size, chamfer, anchor=[0, 0, 1]) {
  chamfer = maybe_percent_string_to_num(with_default(chamfer, size / 4), size);
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
  with_anchor(anchor=anchor, size=[size, size, 0], centered=true) {
    polygon(points=pts);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  chamfered_rect
  ─────────────────────────────────────────────────────────────────────────────

  Create a rectangle with clipped corners.

  **Parameters:**
  - `size`: Rectangle dimensions `[width, length]` on X/Y.
  - `chamfer`: Distance trimmed along each edge, as a number or percentage of
    the smaller dimension. `undef` preserves the default `size[1] / 4`.
    The X and Y trims are independently capped at half of their dimensions.
  - `anchor`: Reference-box placement `[x, y, z]` (default `[0, 0, 1]`).
    Each component is `1` for positive placement, `0` for centering, or `-1`
    for negative placement. The reference height is zero; Z has no effect.

  **Examples:**
  ```scad
  chamfered_rect([40, 20], chamfer="10%", anchor=[-1, 0, 1]);
  ```
 */
module chamfered_rect(size, chamfer, anchor=[0, 0, 1]) {
  x = size[0];
  y = size[1];
  chamfer = maybe_percent_string_to_num(with_default(chamfer, y / 4), min(x, y));
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
  with_anchor(anchor=anchor, size=[x, y, 0], centered=true) {
    polygon(points=pts);
  }
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

  Create a rectangular frame with optional rounded corners.

  **Parameters:**
  - `size`: Reference footprint `[width, length]` on X/Y.
  - `border_w`: Difference between outer and inner dimensions (default `0.5`).
    Accepts a number or percentage of the smaller reference dimension. The
    wall on each side is `border_w / 2` along the straight edges.
  - `inner`: If `true` (default), `size` is the outer footprint. If `false`,
    `size` is the opening and the outer dimensions grow by `border_w`.
  - `r`: Common corner radius for both outlines, as a number or percentage of
    the smaller reference dimension (default `0`). Each outline clamps it to
    fit. `undef` derives a separate radius for each outline from `r_factor`.
  - `anchor`: Placement of the reference footprint (default `[1, 1, 1]`).
    Components `1`, `0`, and `-1` select positive, centered, and negative
    placement. Reference height is zero, so Z anchoring has no effect.
  - `fn`: Fragment count for rounded corners.
  - `r_factor`: Radius fraction used when `r=undef` (default `0.3`).
  - `round_side`: Rounded side or corner selection passed to `rounded_rect()`.

  **Behavior:**
  With `inner=false`, the frame extends `border_w / 2` beyond each edge of
  its anchored reference footprint. Anchoring does not change the opening.

  **Examples:**
  ```scad
  rect_border([40, 20], border_w="10%", r="5%", anchor=[0, 0, 1]);
  ```
 */
module rect_border(size,
                   border_w=0.5,
                   inner=true,
                   r=0,
                   anchor=[1, 1, 1],
                   fn,
                   r_factor=0.3,
                   round_side) {
  border_w = maybe_percent_string_to_num(border_w, min(size[0], size[1]));
  r = maybe_percent_string_to_num(r, min(size[0], size[1]));
  container_size = inner ? size : [size[0] + border_w, size[1] + border_w];
  with_anchor(anchor=anchor, size=[size[0], size[1], 0], centered=true) {

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
