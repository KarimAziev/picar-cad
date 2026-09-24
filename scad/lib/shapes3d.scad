/**
 * Module: Utility modules that simplify common 3D geometric constructions.
 *
 * This file provides rounded, chamfered, ring, and tapered 3D primitives used
 * by higher-level parts.
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

use <functions.scad>
use <shapes2d.scad>
use <transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  cuboid
  ─────────────────────────────────────────────────────────────────────────────

  Creates a box or rounded box with per-axis anchoring relative to the origin.

  This module extends OpenSCAD's `cube()` placement behavior by allowing each
  axis to be anchored independently. It can also generate rounded edges, either
  as a fast rounded-rectangle extrusion or as a fully 3D-rounded shape using
  Minkowski expansion.

  **Parameters**

  `size`:
    Cuboid dimensions. May be either:
    - a single number `s`, expanded to `[s, s, s]`
    - a vector `[x, y, z]`

  `center`:
    Default X/Y placement mode when `anchor` is omitted or contains `undef`
    values for those axes.

    - `true` (default) centers the cuboid on X and Y
    - `false` places the cuboid in the positive X and Y directions, matching
      `cube(size)` when `anchor` is also omitted

    This parameter does not affect Z placement.

  `anchor`:
    Per-axis anchor relative to the origin as `[x, y, z]`.

    Allowed values for each axis:
    - `1`  → object starts at the origin and extends in the positive direction
    - `0`  → object is centered on that axis
    - `-1` → object ends at the origin and extends in the negative direction

    Defaults to `[0, 0, 1]` when `center=true`, or `[1, 1, 1]` when
    `center=false`.

    Examples:
    - `[1, 1, 1]`  → same placement as `cube(size)`
    - `[0, 0, 0]`  → same placement as `cube(size, center=true)`
    - `[0, 0, 1]`  → centered on X/Y, rests on the XY plane
    - `[-1, 0, 1]` → extends into negative X, centered on Y, extends upward on Z

    If an element is `undef`, that axis falls back to:
    - X: `0` when `center=true`, otherwise `1`
    - Y: `0` when `center=true`, otherwise `1`
    - Z: `1`

  `r`:
    Absolute rounding radius or percentage string such as `"10%"`.
    Percentages use the smallest X/Y dimension for the extruded version,
    or the smallest X/Y/Z dimension when `use_minkowski=true`.

    If `undef` or `0`, no rounding is applied unless `r_factor` produces one.

  `r_factor`:
    Relative rounding radius factor.

    When `r` is `undef`, the radius is computed from the smallest relevant
    dimension:
    - for the extruded version: `min(size[0], size[1]) * r_factor`
    - for the Minkowski version: `min(size[0], size[1], size[2]) * r_factor`

  `use_minkowski`:
    If `true`, creates a fully 3D-rounded cuboid by applying a Minkowski sum
    with a sphere.

    If `false` (default), creates a prism by extruding a 2D rounded rectangle.
    This is faster, but only rounds the vertical edges and the top/bottom
    perimeter, not all 3D corners equally.

  `side`:
    Passed through to `rounded_rect()` when `use_minkowski=false`.

    Limits rounding to selected sides. Expected values are:
    `"all"` (default behavior), `"top"`, `"left"`, `"right"`, `"bottom"`,
    `"top_left"`, `"top_right"`, `"bottom_left"`, or `"bottom_right"`.
    Corner names round only one corner of the XY profile; Z faces stay flat.

  `fn`:
    Segment count used for spheres/circles when generating rounded geometry.
    Higher values produce smoother curves at greater render cost.

  `color`:
    Optional color to use.

  **Behavior**

  - `center` only controls fallback placement for X and Y when `anchor` is
    omitted or partially `undef`.
  - If both `r` and `r_factor` are `undef` or `0`, a plain `cube()` is created.
  - If rounding is requested and `use_minkowski=true`, all 3D edges/corners are
    rounded.
  - Otherwise, a rounded 2D profile is extruded along Z.

  The effective radius is always clamped so it cannot exceed half of any
  relevant dimension.

  **Examples**
  ```scad
  // Default placement: centered on X/Y and extending upward in Z
  cuboid([10, 20, 30]);

  // Same as cube([10, 20, 30])
  cuboid([10, 20, 30], center=false);

  // Same as cube([10, 20, 30])
  cuboid([10, 20, 30], anchor=[1, 1, 1]);

  // Same as cube([10, 20, 30], center=true)
  cuboid([10, 20, 30], anchor=[0, 0, 0]);

  // Centered in X/Y, sits on the XY plane and extends upward in Z
  cuboid([10, 20, 30], anchor=[0, 0, 1]);

  // Extends into negative X, centered in Y, extends upward in Z
  cuboid([10, 20, 30], anchor=[-1, 0, 1]);

  // Fast rounded box using 2D extrusion
  cuboid([20, 30, 10], r=2);

  // Round one exposed XY corner while keeping three junctions square.
  cuboid([20, 30, 10], r=2, side="top_left");

  // Fully 3D-rounded box
  cuboid([20, 30, 10], r=2, use_minkowski=true, fn=48);
  ```
  */
module cuboid(size,
              center=true,
              anchor,
              r,
              r_factor,
              use_minkowski=false,
              side,
              fn=36,
              color) {
  assert(is_num(size) || is_list(size) && len([for (v = size)
                                                  if (is_num(v)) v]) == 3,
         "Size should be number or [number, number, number]");
  size = is_num(size) ? [size, size, size] : size;
  r = maybe_percent_string_to_num(r,
                                  use_minkowski ? min(size) : min(size[0], size[1]));

  anchor = [with_default(anchor[0], center ? 0 : 1),
            with_default(anchor[1], center ? 0 : 1),
            with_default(anchor[2], 1)];

  maybe_color(color) {
    with_anchor(anchor=anchor, size=size) {
      if ((is_undef(r) || r == 0) && (is_undef(r_factor) || r_factor == 0)) {
        cube(size);
      } else if (use_minkowski) {
        rad = min(is_undef(r) ? min(size[0], size[1], size[2]) * r_factor : r,
                  size[0] / 2,
                  size[1] / 2,
                  size[2] / 2);
        inner = [for (i=[0:2]) max(0.001, size[i] - rad * 2)];

        minkowski(convexity=5) {
          cube(inner);
          translate([rad, rad, rad]) {
            sphere(r=rad, $fn=fn);
          }
        }
      } else {
        linear_extrude(height=size[2], center=false) {
          rounded_rect([size[0], size[1]],
                       center=false,
                       side=side,
                       fn=fn,
                       r=r,
                       r_factor=r_factor);
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  cyl
  ─────────────────────────────────────────────────────────────────────────────

  Create a cylinder, cone, or frustum with orientation and per-axis anchoring.

  **Parameters:**
  - `h`: Axial height (default `0`). Supply a positive value for a solid.
  - `d`: Common diameter used for either omitted end diameter. If `undef`,
    falls back to `d1`, then `d2`. At least one diameter must be numeric.
  - `d1`: Diameter at the bottom before rotation (`z=0`). Overrides `d` for
    that end; defaults to the resolved `d`.
  - `d2`: Diameter at the top before rotation (`z=h`). Overrides `d` for
    that end; defaults to the resolved `d`. Set either end to `0` for a cone.
  - `$fn`: Circumference fragment count (default `20`). Use `0` to let
    OpenSCAD determine resolution from `$fa` and `$fs`.
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
  - `color`: Optional OpenSCAD color; `undef` inherits the enclosing color.

  **Behavior:**
  Anchoring uses the rotated reference box based on the larger end diameter
  and `h`, rather than either end face alone. The default anchor centers this
  box on X/Y and places its minimum Z at `0` in every orientation.

  A single supplied diameter produces a cylinder. Unequal end diameters
  produce a taper, so orientations with opposite axial directions also
  reverse which end is wider.

  **Examples:**
  ```scad
  // Vertical cylinder centered on X/Y, from z=0 to z=10.
  cyl(h=10, d=4);

  // Horizontal cylinder from x=0 to x=10, centered on Y/Z.
  cyl(h=10, d=4, orientation="hwl", anchor=[1, 0, 0]);

  // Frustum with its wide end at y=0 and narrow end at y=10.
  cyl(h=10, d1=8, d2=4, orientation="lhw", anchor=[0, 1, 0]);

  // Cone centered on all axes, with its tip toward positive Z.
  cyl(h=10, d1=8, d2=0, anchor=[0, 0, 0], $fn=48);
  ```
  */
module cyl(h=0, d, d1, d2, $fn=20, anchor=[0, 0, 1], orientation="wlh", color) {
  assert(is_num(h), "cyl: h (height) must be provided");
  assert(is_num(d) || is_num(d1) || is_num(d2),
         "cyl: d, d1 or d2 must be provided");

  d = with_default(with_default(d, d1), d2);
  d1 = with_default(d1, d);
  d2 = with_default(d2, d);

  max_d = max(d2, d1);

  maybe_color(color) {
    with_orientation(from="wlh",
                     to=orientation,
                     anchor=anchor,
                     size=[max_d, max_d, h]) {
      cylinder(d1=d1, d2=d2, h=h);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  cylinder_cut
  ─────────────────────────────────────────────────────────────────────────────

  Create a cylinder with two opposite flats cut into its sides.

  **Parameters:**
  - `h`: Cylinder height.
  - `r`: Cylinder radius.
  - `cut_w`: Distance between each flat cut and the outer diameter.
  - `center`: Center the original cylinder and cutter cubes (default `true`).
    Also selects the default final placement when `anchor` is omitted.
  - `fn`: Fragment count for the cylinder.
  - `anchor`: Placement on the final X/Y/Z axes, as in `cyl()`. Omitted or
    `undef` uses `[0, 0, 0]` when `center=true`, otherwise `[0, 0, 1]`.
    Individual `undef` components normalize to `1`.
  - `orientation`: Logical width/length/height on X/Y/Z, as in `cyl()`;
    default and `undef` use `"wlh"`. The reference footprint is the uncut
    circle's diameter on both axes; the flats rotate with the body.
  - `color`: Optional OpenSCAD color; `undef` inherits the enclosing color.
 */
module cylinder_cut(h=10, r=5, cut_w=1, center=true, fn,
                    anchor, orientation="wlh", color) {
  anchor = with_default(anchor, center ? [0, 0, 0] : [0, 0, 1]);
  maybe_color(color) {
    with_orientation(to=orientation, anchor=anchor, size=[r * 2, r * 2, h]) {
      translate([0, 0, center ? h / 2 : 0]) {
        difference() {
          cylinder(h=h, r=r, center=center, $fn=fn);

          d = r * 2;
          translate([d - cut_w * 0.5, 0, 0]) {
            cube([d, d, h + 1], center=center);
          }
          translate([-d + cut_w * 0.5, 0, 0]) {
            cube([d, d, h + 1], center=center);
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  star_3d
  ─────────────────────────────────────────────────────────────────────────────

  Extrude `star_2d()` into a 3D prism.

  **Parameters:**
  - `n`: Number of star points.
  - `r_outer`: Radius of the outer tips.
  - `r_inner`: Radius of the inner valleys.
  - `h`: Extrusion height.
  - `color`: Optional OpenSCAD color; `undef` inherits the enclosing color.
 */
module star_3d(n=5, r_outer=20, r_inner=10, h=2, color) {
  maybe_color(color) {
    linear_extrude(height=h, center=false) {
      star_2d(n=n, r_outer=r_outer, r_inner=r_inner);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  notched_circle
  ─────────────────────────────────────────────────────────────────────────────

  Extrude a circular profile with rectangular notches cut from the X and Y
  axes.

  **Parameters:**
  - `d`: Circle diameter.
  - `cutout_w`: Width of each square notch.
  - `h`: Extrusion height.
  - `x_cutouts_n`: Number of notch pairs along X. The current implementation
    supports up to two positions.
  - `y_cutouts_n`: Number of notch pairs along Y. The current implementation
    supports up to two positions.
  - `center`: Default placement when `anchor` is omitted. `true` centers all
    final axes; `false` (default) centers X/Y and rests the box on the XY plane.
  - `convexity`: Convexity hint for the extrusion.
  - `fn`: Fragment count for the base circle.
  - `anchor`: Placement on the final X/Y/Z axes, as in `cyl()`. Omitted or
    `undef` uses `[0, 0, 0]` when `center=true`, otherwise `[0, 0, 1]`.
    Individual `undef` components normalize to `1`.
  - `orientation`: Logical width/length/height on X/Y/Z, as in `cyl()`;
    default and `undef` use `"wlh"`. The reference footprint is the uncut
    circle's diameter on both axes; the notches rotate with the body.
  - `color`: Optional OpenSCAD color; `undef` inherits the enclosing color.
 */
module notched_circle(d,
                      cutout_w,
                      h,
                      x_cutouts_n=1,
                      y_cutouts_n=0,
                      center=false,
                      convexity=1,
                      fn=40,
                      anchor,
                      orientation="wlh",
                      color) {
  square_center_x = notched_circle_square_center_x(r=d / 2, cutout_w=cutout_w);
  anchor = with_default(anchor, center ? [0, 0, 0] : [0, 0, 1]);
  maybe_color(color) {
    with_orientation(to=orientation, anchor=anchor, size=[d, d, h]) {
      linear_extrude(height=h, center=false, convexity=convexity) {
        difference() {
          circle(r=d / 2, $fn=fn);
          if (x_cutouts_n > 0) {
            for (i = [1:x_cutouts_n]) {
              translate([i == 1 ? square_center_x : -square_center_x, 0]) {
                square([cutout_w, cutout_w], center=true);
              }
            }
          }
          if (y_cutouts_n > 0) {
            for (i = [1:y_cutouts_n]) {
              translate([0, i == 1 ? square_center_x : -square_center_x]) {
                square([cutout_w, cutout_w], center=true);
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
  rounded_rect_recess
  ─────────────────────────────────────────────────────────────────────────────

  Create a rounded rectangular cutter with an optional concentric recess.

  **Parameters:**
  - `size`: Main footprint `[width, length]` on X/Y.
  - `recess_size`: Recess footprint `[width, length]`. `undef`, or a zero
    component, omits the recess.
  - `r`: Common corner radius, as a number or percentage of the smaller main
    footprint dimension. Each layer clamps the radius to fit. `undef` uses
    the rounded-rectangle default radius factor independently for each layer.
  - `thickness`: Main cutter depth along Z.
  - `recess_thickness`: Recess depth; `undef` uses `max(1, thickness / 2.2)`.
  - `recess_reverse`: If `true`, align the recess with the top of the main
    cutter; otherwise align it with the bottom (default `false`).
  - `anchor`: Reference-box placement (default `[1, 1, 1]`). Components `1`,
    `0`, and `-1` select positive, centered, and negative placement. The box
    uses the larger footprint on each axis and the main `thickness` on Z.
  - `color`: Optional OpenSCAD color; `undef` inherits the enclosing color.

  **Behavior:**
  Both layers share the same X/Y center. A recess deeper than `thickness`
  extends beyond the anchored main depth; its depth is not clamped.

  **Examples:**
  ```scad
  rounded_rect_recess([20, 12], recess_size=[24, 16], r="10%",
                      thickness=6, recess_thickness=2, anchor=[0, 0, 1]);
  ```
 */
module rounded_rect_recess(size,
                           recess_size,
                           r,
                           thickness,
                           recess_thickness,
                           recess_reverse=false,
                           anchor=[1, 1, 1],
                           color) {
  r = maybe_percent_string_to_num(r, min(size[0], size[1]));
  recess_t = is_undef(recess_thickness)
    ? max(1, thickness / 2.2)
    : recess_thickness;
  recess_size = recess_size && recess_size[0] && recess_size[1] ? recess_size : undef;
  recess_z = recess_reverse ? thickness - recess_t : 0;
  reference_size = [max(size[0], is_undef(recess_size) ? 0 : recess_size[0]),
                    max(size[1], is_undef(recess_size) ? 0 : recess_size[1]),
                    thickness];
  maybe_color(color) {
    with_anchor(anchor=anchor, size=reference_size, centered=true) {
      union() {
        linear_extrude(height=thickness,
                       center=false) {
          rounded_rect(size=[size[0], size[1]],
                       r=r,
                       center=true);
        }

        if (recess_size) {
          translate([0, 0, recess_z]) {
            linear_extrude(height=recess_t,
                           center=false) {
              rounded_rect(size=[recess_size[0],
                                 recess_size[1]],
                           r=r,
                           center=true);
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  cube_border
  ─────────────────────────────────────────────────────────────────────────────

  Create a rectangular frame extruded along Z.

  **Parameters:**
  - `size`: Reference dimensions `[width, length, height]`, or `[width, length]`
    when `h` is supplied.
  - `h`: Extrusion height; `undef` uses `size[2]`.
  - `border_w`: Difference between outer and inner footprint dimensions
    (default `0.5`), as a number or percentage of `min(size[0], size[1])`.
    Each straight wall is half this value.
  - `inner`: If `true` (default), the reference footprint is the outside.
    If `false`, it is the opening, with the border extending outward.
  - `r`: Common outline radius, as a number or percentage of the smaller
    reference footprint dimension (default `0`). `undef` uses `r_factor`.
  - `anchor`: Reference-box placement (default `[1, 1, 1]`). Components `1`,
    `0`, and `-1` select positive, centered, and negative placement. Z uses
    the resolved extrusion height.
  - `fn`: Fragment count for rounded corners.
  - `r_factor`: Radius fraction for each outline when `r=undef` (default `0.3`).
  - `round_side`: Rounded side or corner selection passed to `rect_border()`.
  - `color`: Optional OpenSCAD color; `undef` inherits the enclosing color.

  **Behavior:**
  With `inner=false`, the border extends `border_w / 2` beyond each X/Y edge
  of the anchored reference box. Both outlines share their X/Y center.

  **Examples:**
  ```scad
  cube_border([40, 20, 6], border_w="10%", r="5%", anchor=[0, 0, -1]);
  ```
 */
module cube_border(size,
                   h,
                   border_w=0.5,
                   inner=true,
                   r=0,
                   anchor=[1, 1, 1],
                   fn,
                   r_factor=0.3,
                   round_side,
                   color) {
  h = with_default(h, size[2]);
  maybe_color(color) {
    with_anchor(anchor=anchor, size=[size[0], size[1], h], centered=true) {
      linear_extrude(height=h, center=false, convexity=2) {
        rect_border(size=[size[0], size[1]],
                    border_w=border_w,
                    inner=inner,
                    r=r,
                    anchor=[0, 0, 1],
                    fn=fn,
                    r_factor=r_factor,
                    round_side=round_side);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  ring
  ─────────────────────────────────────────────────────────────────────────────

  Create a 3D ring by subtracting an inner cylinder from an outer cylinder.

  **Parameters:**
  - `d`: Inner diameter.
  - `d1`: Optional inner bottom diameter for a tapered inner cut.
  - `d2`: Optional inner top diameter for a tapered inner cut.
  - `od`: Outer diameter.
  - `od1`: Optional outer bottom diameter for a tapered outer wall.
  - `od2`: Optional outer top diameter for a tapered outer wall.
  - `h`: Ring height.
  - `fn`: Fragment count for both cylinders.
  - `color`: Optional color value.
  - `whole_color`: When `true` (default), color the complete ring. When
    `false`, apply color only to the outer solid before cutting the bore.
  - `anchor`: Placement on the final X/Y/Z axes, as in `cyl()` (default
    `[0, 0, 1]`). Explicit `undef` or individual `undef` components use `1`.
  - `orientation`: Logical width/length/height on X/Y/Z, as in `cyl()`;
    default and `undef` use `"wlh"`. The reference box uses the larger outer
    end diameter on both footprint axes and `h` along the cylinder axis.
    Inner and outer tapers rotate together.
 */
module ring(d,
            d1,
            d2,
            od,
            od1,
            od2,
            h,
            fn=30,
            color,
            whole_color=true,
            anchor=[0, 0, 1],
            orientation="wlh") {
  fn = with_default(fn, 30);
  // Match cylinder()'s default diameter when an end is unspecified.
  max_d = max(with_default(od1, with_default(od, 2)),
              with_default(od2, with_default(od, 2)));
  with_orientation(to=orientation, anchor=anchor, size=[max_d, max_d, h]) {
    maybe_color(whole_color ? color : undef) {
      difference() {
        maybe_color(whole_color ? undef : color) {
          cylinder(d=od, d1=od1, d2=od2, h=h, $fn=fn);
        }
        translate([0, 0, -0.05]) {
          cylinder(d=d, h=h + 0.1, $fn=fn, d1=d1, d2=d2);
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  y_chamfered_cube
  ─────────────────────────────────────────────────────────────────────────────

  Create an X-directed prism with the four corners of its Y/Z profile chamfered.

  **Parameters:**
  - `size`: Reference dimensions `[width, length, height]` on X/Y/Z.
  - `chamfer`: Non-negative corner trim, as a number or percentage of
    `min(size[1], size[2])`. Keep it at or below half that minimum to avoid
    crossing profile edges.
  - `anchor`: Reference-box placement (default `[1, 1, 1]`). Components `1`,
    `0`, and `-1` select positive, centered, and negative placement.
  - `lower_chamfer`: If `true`, shift the anchored prism down by the resolved
    chamfer distance (default `false`). The reference height stays `size[2]`.
  - `color`: Optional OpenSCAD color; `undef` inherits the enclosing color.

  **Examples:**
  ```scad
  y_chamfered_cube([30, 20, 10], chamfer="10%", anchor=[0, 0, 1]);
  ```
 */
module y_chamfered_cube(size, chamfer, anchor=[1, 1, 1], lower_chamfer=false, color) {
  x_size = size[0];
  y_size = size[1];
  z_size = size[2];
  chamfer = maybe_percent_string_to_num(chamfer, min(y_size, z_size));
  assert(is_num(chamfer) && chamfer >= 0,
         "y_chamfered_cube: chamfer must be non-negative or a percentage");
  pts = [[0, chamfer],
         [0, y_size - chamfer],
         [chamfer, y_size],
         [z_size - chamfer, y_size],
         [z_size, y_size - chamfer],
         [z_size, chamfer],
         [z_size - chamfer, 0],
         [chamfer, 0]];

  maybe_color(color) {
    with_anchor(anchor=anchor, size=size) {
      translate([0, 0, z_size + (lower_chamfer ? -chamfer : 0)]) {
        rotate([0, 90, 0]) {
          linear_extrude(height=x_size, center=false) {
            polygon(pts);
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  chamfered_cube
  ─────────────────────────────────────────────────────────────────────────────

  Create a box with chamfers around its top and bottom faces.

  **Parameters:**
  - `size`: Reference dimensions `[width, length, height]` on X/Y/Z.
  - `chamfer`: Non-negative edge trim, as a number or percentage of `min(size)`.
    Keep it at or below half that minimum so the chamfer bands fit.
  - `anchor`: Reference-box placement (default `[1, 1, 1]`). Components `1`,
    `0`, and `-1` select positive, centered, and negative placement.
  - `lower_chamfer`: If `true`, shift the anchored box down by the resolved
    chamfer distance (default `false`). The reference height stays `size[2]`.
  - `ignore_sides`: Side names whose top/bottom edges remain square (default
    `[]`): `"left"` is minimum X, `"right"` maximum X, `"bottom"` minimum Y,
    and `"top"` maximum Y. Names refer to the canonical box before anchoring.
  - `color`: Optional OpenSCAD color; `undef` inherits the enclosing color.

  **Examples:**
  ```scad
  chamfered_cube([30, 20, 10], chamfer="10%", anchor=[0, 0, 1],
                 ignore_sides=["right"]);
  ```
 */
module chamfered_cube(size,
                      chamfer,
                      anchor=[1, 1, 1],
                      lower_chamfer=false,
                      ignore_sides=[],
                      color) {
  x_size = size[0];
  y_size = size[1];
  z_size = size[2];
  chamfer = maybe_percent_string_to_num(chamfer, min(size));
  assert(is_num(chamfer) && chamfer >= 0,
         "chamfered_cube: chamfer must be non-negative or a percentage");

  is_left_non_chamfered = member("left", ignore_sides);
  is_right_non_chamfered = member("right", ignore_sides);

  maybe_color(color) {
    with_anchor(anchor=anchor, size=size) {
      translate([0, 0, lower_chamfer ? -chamfer : 0]) {
        intersection() {
          cube(size=[x_size, y_size, z_size]);
          union() {
            translate([x_size, 0, chamfer]) {
              rotate([0, 180, 0]) {
                roof() {
                  square(size=[x_size, y_size]);
                }
              }
            }

            for (side = ignore_sides) {
              if (side == "left") {
                y_chamfered_cube(size=[x_size / 2, y_size, z_size],
                                 chamfer=chamfer);
              } else if (side == "right") {
                translate([x_size / 2, 0, 0]) {
                  y_chamfered_cube(size=[x_size / 2, y_size, z_size],
                                   chamfer=chamfer);
                }
              } else if (side == "bottom") {
                translate([x_size, 0, 0]) {
                  rotate([0, 0, 90]) {
                    y_chamfered_cube(size=[y_size / 2, x_size, z_size],
                                     chamfer=chamfer);
                  }
                }
                if (is_left_non_chamfered) {
                  cube([chamfer, chamfer, z_size]);
                }
                if (is_right_non_chamfered) {
                  translate([x_size - chamfer, 0, 0]) {
                    cube([chamfer, chamfer, z_size]);
                  }
                }
              } else if (side == "top") {
                translate([x_size, y_size / 2, 0]) {
                  rotate([0, 0, 90]) {
                    y_chamfered_cube(size=[y_size / 2, x_size, z_size],
                                     chamfer=chamfer);
                  }
                }
                if (is_left_non_chamfered) {
                  translate([0, y_size - chamfer, 0]) {
                    cube([chamfer, chamfer, z_size]);
                  }
                }
                if (is_right_non_chamfered) {
                  translate([x_size - chamfer, y_size - chamfer, 0]) {
                    cube([chamfer, chamfer, z_size]);
                  }
                }
              }
            }
            translate([0, 0, chamfer]) {
              cube(size=[x_size, y_size, z_size - chamfer * 2]);
            }
            translate([0, 0, z_size - chamfer]) {
              roof() {
                square(size=[x_size, y_size]);
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
  tapered_box
  ─────────────────────────────────────────────────────────────────────────────

  Create a solid taper between concentric rounded rectangular footprints.

  **Parameters:**
  - `base_size`: Bottom footprint `[width, length]` on X/Y.
  - `top_size`: Top footprint `[width, length]` on X/Y.
  - `h`: Total height along Z; must be positive.
  - `r_top_factor`: Fraction of the smaller top dimension used when `r_top`
    is `undef` (default `0.1`).
  - `r_bottom_factor`: Fraction of the smaller base dimension used when
    `r_bottom` is `undef` (default `0.1`).
  - `r_top_side`: Top rounded side or corner selection for `rounded_rect()`.
  - `r_base_side`: Base rounded side or corner selection for `rounded_rect()`.
  - `r_top`: Top corner radius, as a number or percentage of `min(top_size)`.
    `undef` uses `r_top_factor`; the resolved radius is clamped to fit.
  - `r_bottom`: Base corner radius, as a number or percentage of `min(base_size)`.
    `undef` uses `r_bottom_factor`; the resolved radius is clamped to fit.
  - `anchor`: Reference-box placement (default `[0, 0, 1]`). Components `1`,
    `0`, and `-1` select positive, centered, and negative placement. The box
    uses the larger footprint dimension on each X/Y axis and `h` on Z.
  - `color`: Optional OpenSCAD color; `undef` inherits the enclosing color.

  **Examples:**
  ```scad
  tapered_box([40, 30], [24, 18], h=20, r_top="10%", r_bottom="5%",
              anchor=[0, 0, -1]);
  ```
 */
module tapered_box(base_size,
                   top_size,
                   h,
                   r_top_factor=0.1,
                   r_bottom_factor=0.1,
                   r_top_side,
                   r_base_side,
                   r_top,
                   r_bottom,
                   anchor=[0, 0, 1],
                   color) {
  max_w = max(base_size[0], top_size[0]);
  max_l = max(base_size[1], top_size[1]);
  assert(is_num(h) && h > 0, "tapered_box: h must be positive");
  slice_h = min(0.01, h / 2);
  maybe_color(color) {
    with_anchor(anchor=anchor, size=[max_w, max_l, h], centered=true) {
      hull() {
        linear_extrude(height=slice_h, center=false) {
          rounded_rect(base_size,
                       center=true,
                       r_factor=r_bottom_factor,
                       r=r_bottom,
                       side=r_base_side);
        }
        translate([0, 0, h - slice_h]) {
          linear_extrude(height=slice_h, center=false) {
            rounded_rect(top_size,
                         center=true,
                         r_factor=r_top_factor,
                         r=r_top,
                         side=r_top_side);
          }
        }
      }
    }
  }
}
