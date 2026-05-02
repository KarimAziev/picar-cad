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
  rounded_cube
  ─────────────────────────────────────────────────────────────────────────────

  Create a rounded cuboid by offsetting an inner cube.

  **Parameters:**
  - `size`: Cuboid size as `[x, y, z]`.
  - `r`: Explicit rounding radius. When `undef`, `r_factor` is used.
  - `center`: If `true`, center the shape on X and Y.
  - `z_center`: If `true`, center the shape on Z.
  - `fn`: Fragment count for the rounding sphere.
  - `r_factor`: Radius factor used when `r` is `undef`.
 */
module rounded_cube(size,
                    r=undef,
                    center=true,
                    z_center=false,
                    fn=36,
                    r_factor=0.02) {
  rad = is_undef(r) ? (min(size[0], size[1], size[2])) * r_factor : r;

  x = size[0] - rad * 2;
  y = size[1] - rad * 2;
  z = size[2] - rad * 2;
  translate([(center ? 0 : x / 2),
             (center ? 0 : y / 2),
             (z_center ? 0 : z / 2)
             + rad]) {
    offset_3d(r=rad, fn=fn) {
      cube([x, y, z], center=true);
    }
  }
}

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

  `anchor`:
    Per-axis anchor relative to the origin as `[x, y, z]`.

    Allowed values for each axis:
    - `1`  → object starts at the origin and extends in the positive direction
    - `0`  → object is centered on that axis
    - `-1` → object ends at the origin and extends in the negative direction

    Defaults to `[0, 0, 1]`, meaning centered on X/Y and extending upward on Z.

    Examples:
    - `[1, 1, 1]`  → same placement as `cube(size)`
    - `[0, 0, 0]`  → same placement as `cube(size, center=true)`
    - `[0, 0, 1]`  → centered on X/Y, rests on the XY plane
    - `[-1, 0, 1]` → extends into negative X, centered on Y, extends upward on Z

    If an element is `undef`, that axis falls back to:
    - X: `0`
    - Y: `0`
    - Z: `1`

  `r`:
    Absolute rounding radius.

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
    `"all"` (default behavior), `"top"`, `"left"`, `"right"`, or `"bottom"`.

  `fn`:
    Segment count used for spheres/circles when generating rounded geometry.
    Higher values produce smoother curves at greater render cost.

  **Behavior**

  - If both `r` and `r_factor` are `undef` or `0`, a plain `cube()` is created.
  - If rounding is requested and `use_minkowski=true`, all 3D edges/corners are
    rounded.
  - Otherwise, a rounded 2D profile is extruded along Z.

  The effective radius is always clamped so it cannot exceed half of any
  relevant dimension.

  **Examples**
  ```scad
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

  // Fully 3D-rounded box
  cuboid([20, 30, 10], r=2, use_minkowski=true, fn=48);
  ```
  */
module cuboid(size,
              anchor=[0, 0, 1],
              r,
              r_factor,
              use_minkowski=false,
              side,
              fn=36) {
  assert(is_num(size) || is_list(size) && len([for (v = size)
                                                  if (is_num(v)) v]) == 3,
         "Size should be number or [number, number, number]");
  size = is_num(size) ? [size, size, size] : size;

  anchor = is_undef(anchor) ? [0, 0, 0] : anchor;
  align_x = is_undef(anchor[0]) ? 0 : anchor[0];
  align_y = is_undef(anchor[1]) ? 0 : anchor[1];
  align_z = is_undef(anchor[2]) ? 1 : anchor[2];

  _align = [align_x, align_y, align_z];

  function xyz(item_size) =
    [for (i = [0 : len(_align) - 1])
        let (n = _align[i],
             v = item_size[i])
          n == 0 ? -v / 2 : n == -1 ? -v : 0];

  if ((is_undef(r) || r == 0) && (is_undef(r_factor) || r_factor == 0)) {
    translate(xyz(size)) {
      cube(size);
    }
  } else if (use_minkowski) {
    rad = min(is_undef(r) ? (min(size[0], size[1], size[2])) * r_factor : r,
              size[0] / 2,
              size[1] / 2,
              size[2] / 2);
    inner = [for (i=[0:2]) max(0.001, size[i] - rad * 2)];

    translate(xyz(size)) {
      minkowski(convexity=5) {
        cube(inner);
        translate([rad, rad, rad]) {
          sphere(r=rad, $fn=fn);
        }
      }
    }
  } else {
    translate(xyz(size)) {
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

/**
  ─────────────────────────────────────────────────────────────────────────────
  cylinder_cut
  ─────────────────────────────────────────────────────────────────────────────

  Create a cylinder with two opposite flats cut into its sides.

  **Parameters:**
  - `h`: Cylinder height.
  - `r`: Cylinder radius.
  - `cut_w`: Distance between each flat cut and the outer diameter.
  - `center`: Forwarded to the underlying cylinder and cutter cubes.
  - `fn`: Fragment count for the cylinder.
 */
module cylinder_cut(h=10, r=5, cut_w=1, center=true, fn) {
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
 */
module star_3d(n=5, r_outer=20, r_inner=10, h=2) {
  linear_extrude(height=h, center=false) {
    star_2d(n=n, r_outer=r_outer, r_inner=r_inner);
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
  - `center`: Forwarded to `linear_extrude()`.
  - `convexity`: Convexity hint for the extrusion.
  - `fn`: Fragment count for the base circle.
 */
module notched_circle(d,
                      cutout_w,
                      h,
                      x_cutouts_n=1,
                      y_cutouts_n=0,
                      center=false,
                      convexity=1,
                      fn=360) {
  square_center_x = notched_circle_square_center_x(r=d / 2, cutout_w=cutout_w);
  linear_extrude(h=h, center=center, convexity=convexity) {
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

/**
  ─────────────────────────────────────────────────────────────────────────────
  rounded_rect_recess
  ─────────────────────────────────────────────────────────────────────────────

  Create a rounded rectangular prism with an optional larger recess layer.

  **Parameters:**
  - `size`: Main footprint as `[x, y]`.
  - `recess_size`: Optional recess footprint as `[x, y]`.
  - `r`: Corner radius used for both layers.
  - `thickness`: Main extrusion depth.
  - `recess_thickness`: Optional recess depth. When `undef`, defaults to
    roughly `thickness / 2.2`.
  - `recess_reverse`: If `true`, place the recess on the opposite face.
  - `center`: If `true`, center the footprint on XY.
 */
module rounded_rect_recess(size,
                           recess_size,
                           r,
                           thickness,
                           recess_thickness,
                           recess_reverse=false,
                           center=false) {
  recess_t = is_undef(recess_thickness)
    ? max(1, thickness / 2.2)
    : recess_thickness;
  recess_size = recess_size && recess_size[0] && recess_size[1] ? recess_size : undef;
  recess_z = recess_reverse ? thickness - recess_t : 0;
  translate([center
             ? 0
             : max(size[0], is_undef(recess_size) ? 0 : recess_size[0]) / 2,
             center ? 0 : max(size[1], is_undef(recess_size) ? 0 : recess_size[1]) / 2,
             0]) {
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

/**
  ─────────────────────────────────────────────────────────────────────────────
  cube_center_y
  ─────────────────────────────────────────────────────────────────────────────

  Place a cube so it is centered on Y while still starting at `z = 0`.

  **Parameters:**
  - `size`: Cube size, either a scalar or `[x, y, z]`.
 */
module cube_center_y(size) {
  translate([0, -(is_num(size) ? size : size[1]) / 2, 0]) {
    cube(size);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  cube_center_x
  ─────────────────────────────────────────────────────────────────────────────

  Place a cube so it is centered on X while still starting at `z = 0`.

  **Parameters:**
  - `size`: Cube size, either a scalar or `[x, y, z]`.
 */
module cube_center_x(size) {
  translate([-(is_num(size) ? size : size[0]) / 2, 0, 0]) {
    cube(size);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  cube_border
  ─────────────────────────────────────────────────────────────────────────────

  Extrude `rect_border()` into a 3D rectangular frame.

  **Parameters:**
  - `size`: Reference size as `[x, y, z]`.
  - `h`: Extrusion height. When `undef`, `size[2]` is used.
  - `border_w`: Difference between the outer and inner rectangle sizes.
  - `inner`: Forwarded to `rect_border()`.
  - `r`: Explicit corner radius.
  - `center`: If `true`, center the border footprint on XY.
  - `fn`: Fragment count for rounded corners.
  - `r_factor`: Radius factor used when `r` is `undef`.
  - `round_side`: Optional side selection forwarded to `rect_border()`.
 */
module cube_border(size,
                   h,
                   border_w=0.5,
                   inner=true,
                   r=0,
                   center=false,
                   fn,
                   r_factor=0.3,
                   round_side) {
  linear_extrude(height=is_undef(h) ? size[2] : h,
                 center=false,
                 convexity=2) {
    rect_border(size=[size[0], size[1]],
                border_w=border_w,
                inner=inner,
                r=r,
                center=center,
                fn=fn,
                r_factor=r_factor,
                round_side=round_side);
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
  - `outer_d`: Outer diameter.
  - `outer_d1`: Optional outer bottom diameter for a tapered outer wall.
  - `outer_d2`: Optional outer top diameter for a tapered outer wall.
  - `h`: Ring height.
  - `fn`: Fragment count for both cylinders.
  - `color`: Optional color value.
  - `whole_color`: When `true`, color is applied to the whole ring. The current
    implementation only emits geometry in this mode.
 */
module ring(d,
            d1,
            d2,
            outer_d,
            outer_d1,
            outer_d2,
            h,
            fn=30,
            color,
            whole_color=true) {
  fn = with_default(fn, 30);
  module _ring() {
    difference() {
      if (!whole_color) {
        maybe_color(color) {
          cylinder(d=outer_d, h=h, $fn=fn, outer_d1=d1, outer_d2=d2);
        }
      } else {
        cylinder(d=outer_d, d1=outer_d1, d2=outer_d2, h=h, $fn=fn);
      }

      translate([0, 0, -0.05]) {
        cylinder(d=d, h=h + 0.1, $fn=fn, d1=d1, d2=d2);
      }
    }
  }
  if (whole_color) {
    maybe_color(color, alpha=1) {
      _ring();
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  y_chamfered_cube
  ─────────────────────────────────────────────────────────────────────────────

  Create a prism whose Y-facing edges are chamfered by extruding a chamfered
  X/Z profile along X.

  **Parameters:**
  - `size`: Prism size as `[x, y, z]`.
  - `chamfer`: Chamfer size.
  - `center_x`: If `true`, center the prism on X.
  - `center_y`: If `true`, center the prism on Y.
  - `lower_chamfer`: If `true`, shift the prism so the lower chamfer reaches
    below `z = 0`.
 */
module y_chamfered_cube(size, chamfer, center_x, center_y, lower_chamfer=false) {
  x_size = size[0];
  y_size = size[1];
  z_size = size[2];
  pts = [[0, chamfer],
         [0, y_size - chamfer],
         [chamfer, y_size],
         [z_size - chamfer, y_size],
         [z_size, y_size - chamfer],
         [z_size, chamfer],
         [z_size - chamfer, 0],
         [chamfer, 0]];

  translate([center_x ? -x_size / 2 : 0,
             center_y ? -y_size / 2 : 0,
             z_size + (lower_chamfer ? -chamfer : 0)]) {
    rotate([0, 90, 0]) {
      linear_extrude(height=x_size, center=false) {
        polygon(pts);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  chamfered_cube
  ─────────────────────────────────────────────────────────────────────────────

  Create a cube-like solid with chamfered top and side edges.

  **Parameters:**
  - `size`: Solid size as `[x, y, z]`.
  - `chamfer`: Chamfer size.
  - `center_x`: If `true`, center the solid on X.
  - `center_y`: If `true`, center the solid on Y.
  - `lower_chamfer`: If `true`, shift the solid downward so lower chamfers can
    extend below `z = 0`.
  - `ignore_sides`: List of side names to leave unchamfered. Supported values
    are `"left"`, `"right"`, `"bottom"`, and `"top"`.
 */
module chamfered_cube(size,
                      chamfer,
                      center_x,
                      center_y,
                      lower_chamfer=false,
                      ignore_sides=[]) {
  x_size = size[0];
  y_size = size[1];
  z_size = size[2];

  is_left_non_chamfered = member("left", ignore_sides);
  is_right_non_chamfered = member("right", ignore_sides);

  translate([center_x ? -x_size / 2 : 0,
             center_y ? -y_size / 2 : 0,
             lower_chamfer ? -chamfer : 0]) {
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
