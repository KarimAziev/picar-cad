/**
  * Module: Transform helpers.
  *
  * This file provides wrapper modules for common copy, alignment, and offset
  * operations used across the CAD library.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

use <functions.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  fillet
  ─────────────────────────────────────────────────────────────────────────────

  Round inward corners of a 2D child shape by applying a fillet radius.

  **Parameters:**
  - `r`: Fillet radius.
  - `fn`: Optional fragment count passed to `offset()`.
 */
module fillet(r, fn) {
  offset(r = -r, $fn=fn) {
    offset(delta = r, $fn=fn) {
      children();
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  mirror_copy
  ─────────────────────────────────────────────────────────────────────────────

  Emit the original children and an additional mirrored copy.

  **Parameters:**
  - `v`: Mirror normal passed to `mirror()`.
 */
module mirror_copy(v = [1, 0, 0]) {
  children();
  mirror(v) {
    children();
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  translate_copy
  ─────────────────────────────────────────────────────────────────────────────

  Emit the original children and an additional translated copy.

  **Parameters:**
  - `v`: Translation vector for the duplicate.
 */
module translate_copy(v) {
  children();
  translate(v) {
    children();
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rotate_copy
  ─────────────────────────────────────────────────────────────────────────────

  Emit the original children and an additional copy shifted by `v`.

  **Parameters:**
  - `v`: Translation vector applied to the duplicate child geometry.
 */
module rotate_copy(v) {
  children();
  translate(v) {
    children();
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  offset_3d
  ─────────────────────────────────────────────────────────────────────────────

  Expand or contract 3D child geometry by a radius-like offset.

  Positive `r` performs an outward Minkowski expansion. Negative `r` carves an
  inward offset volume inside a temporary bounding cube.

  **Parameters:**
  - `r`: Offset distance. Positive grows, negative shrinks, `0` passes through.
  - `size`: Bounding cube size used by the negative-offset branch.
  - `fn`: Fragment count for the helper sphere.
 */
module offset_3d(r=1, size=20, fn=12) {
  if (r == 0) {
    children();
  } else if (r > 0) {
    minkowski(convexity=5) {
      children();
      sphere(r, $fn=fn);
    }
  }
  else {
    size2 = size * [1, 1, 1];
    size1 = size2 * 2;

    difference() {
      cube(size2, center=true);
      minkowski(convexity=5) {
        difference() {
          cube(size1, center=true);
          children();
        }
        sphere(-r, $fn=fn);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  offset_vertices_2d
  ─────────────────────────────────────────────────────────────────────────────

  Smooth polygon vertices without changing the overall silhouette drastically.

  This applies paired positive and negative `offset()` operations to the child
  shape, which is useful for softening sharp 2D corners.

  **Parameters:**
  - `r`: Offset radius used for the smoothing passes.
  - `fn`: Optional fragment count passed to `offset()`.
 */
module offset_vertices_2d(r, fn) {
  offset(-r, $fn=fn) {
    offset(r, $fn=fn) {
      offset(r, $fn=fn) {
        offset(-r, $fn=fn) {
          children();
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  four_corner_children
  ─────────────────────────────────────────────────────────────────────────────

  Place child geometry at the four corners of a rectangular span.

  The module also exposes `$x_i` and `$y_i` in each child invocation so nested
  code can tell which corner is being rendered.

  **Parameters:**
  - `size`: Corner-to-corner spacing as `[x, y]`.
  - `center`: If `true`, the corner grid is centered on the origin.
 */
module four_corner_children(size=[10, 10],
                            center=true) {
  for (x_ind = [0, 1])
    for (y_ind = [0, 1]) {
      x_pos = (center ? -size[0] / 2 : 0) + x_ind * size[0];
      y_pos = (center ? -size[1] / 2 : 0) + y_ind * size[1];

      translate([x_pos, y_pos]) {
        $x_i = x_ind;
        $y_i = y_ind;
        children();
      }
    }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  four_corner_holes_2d
  ─────────────────────────────────────────────────────────────────────────────

  Draw circular holes at the four corners of a rectangular span.

  Any children passed in are emitted at each hole location after the circle.

  **Parameters:**
  - `size`: Corner-to-corner spacing as `[x, y]`.
  - `center`: If `true`, the hole pattern is centered on the origin.
  - `d`: Hole diameter.
  - `fn`: Fragment count for the circles.
 */
module four_corner_holes_2d(size=[10, 10],
                            center=false,
                            d=3,
                            fn=60) {
  for (x_ind = [0, 1])
    for (y_ind = [0, 1]) {
      x_pos = (center ? -size[0] / 2 : 0) + x_ind * size[0];
      y_pos = (center ? -size[1] / 2 : 0) + y_ind * size[1];
      translate([x_pos, y_pos]) {
        circle(r=d / 2, $fn=fn);
        children();
      }
    }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  maybe_rotate
  ─────────────────────────────────────────────────────────────────────────────

  Rotate child geometry only when a non-zero 3-axis rotation is provided.

  **Parameters:**
  - `rotation`: Rotation vector `[x, y, z]`. Invalid or all-zero values pass
    the children through unchanged.
 */
module maybe_rotate(rotation) {
  if (is_list(rotation) &&
      len([for (v = rotation) if (is_num(v)) v]) == 3 &&
      len([for (v = rotation) if (v != 0) v]) > 0) {
    rotate(rotation) {
      children();
    }
  } else {
    children();
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  maybe_translate
  ─────────────────────────────────────────────────────────────────────────────

  Translate child geometry only when a non-zero vector is provided.

  **Parameters:**
  - `v`: Translation vector `[x, y, z]`. Invalid or all-zero values pass the
    children through unchanged.
 */
module maybe_translate(v) {
  if (is_list(v)
      && len([for (n = v) if (is_num(n)) n]) == 3
      && len([for (n = v) if (n != 0) n]) > 0) {
    translate(v) {
      children();
    }
  } else {
    children();
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  spin_keep_bbox_at_origin
  ─────────────────────────────────────────────────────────────────────────────

  Rotate 2D child geometry around Z and shift it so the rotated bounding box
  still starts at the origin.

  **Parameters:**
  - `size`: Unrotated bounding-box size as `[x, y]`.
  - `a`: Z rotation angle in degrees. `undef` or `0` leaves children unchanged.
 */
module spin_keep_bbox_at_origin(size, a) {
  if (is_undef(a) || a == 0) {
    children();
  } else {
    p = calc_rotated_bbox(size[0], size[1], a);
    translate([p[2], p[3], 0]) {
      rotate([0, 0, a]) {
        children();
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  align_children
  ─────────────────────────────────────────────────────────────────────────────

  Align child geometry inside a 2D parent footprint.

  **Parameters:**
  - `parent_size`: Available area as `[x, y]`.
  - `size`: Child footprint as `[x, y]`.
  - `align_x`: Horizontal alignment. `-1` left, `0` center, `1` right.
  - `align_y`: Vertical alignment. `-1` bottom, `0` center, `1` top.
 */
module align_children(parent_size,
                      size,
                      align_x=-1,
                      align_y=-1) {
  if (!is_list(parent_size)
      || !is_num(parent_size[0])
      || !is_num(parent_size[1])) {
    children();
  } else {
    cell_x = parent_size[0];
    cell_y = parent_size[1];
    full_x = size[0];
    full_y = size[1];

    dx = cell_x - full_x;
    dy = cell_y - full_y;

    x = align_x == -1
      ? 0
      : align_x == 0
      ? dx / 2
      : dx;

    y = align_y == 0
      ? dy / 2
      : align_y == 1
      ? dy
      : 0;

    translate([x, y, 0]) {
      children();
    }
  }
}

/**
 ─────────────────────────────────────────────────────────────────────────────
 align_children_with_spin
 ─────────────────────────────────────────────────────────────────────────────

 Align child geometry inside a parent footprint after optional Z rotation.

 The child bounding box is expanded to its rotated extents before alignment so
 the final placement still respects the requested cell boundaries.

 **Parameters:**
 - `parent_size`: Available area as `[x, y]`.
 - `size`: Unrotated child footprint as `[x, y]`.
 - `align_x`: Horizontal alignment. `-1` left, `0` center, `1` right.
 - `align_y`: Vertical alignment. `-1` bottom, `0` center, `1` top.
 - `spin`: Z rotation angle in degrees applied before placement.

 **Example**:
 ```scad

 module example(angle=16,
                l=15,
                thickness=3,
                w=3) {
  bbox = rot_x_bbox_align([thickness, l, w,], angle=angle);
  bbox_y = bbox[0];
  bbox_z = bbox[1];

  #cube([bbox_y, bbox_z, thickness]);
  align_children_with_spin(parent_size=[l, w, thickness],
                           size=[l, w, thickness],
                           spin=-angle,
                           align_x=-1,
                           align_y=-1) {
    cube([l, w, thickness]);
  }
}

 ```
*/
module align_children_with_spin(parent_size,
                                size,
                                align_x=-1,
                                align_y=-1,
                                spin=0) {
  if (!is_undef(spin) && spin != 0) {
    let (params = calc_rotated_bbox(size[0], size[1],
                                    spin),
         full_x = params[0],
         full_y = params[1],
         sx = params[2],
         sy = params[3]) {
      align_children(parent_size=parent_size,
                     size=[full_x, full_y],
                     align_x=align_x,
                     align_y=align_y) {
        translate([sx, sy, 0]) {
          rotate([0, 0, spin]) {
            children();
          }
        }
      }
    }
  } else {
    align_children(parent_size=parent_size,
                   size=size,
                   align_x=align_x,
                   align_y=align_y) {
      children();
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  maybe_color
  ─────────────────────────────────────────────────────────────────────────────

  Apply `color()` to child geometry only when a color value is provided.

  **Parameters:**
  - `color`: OpenSCAD color value. `undef` leaves children unchanged.
  - `alpha`: Alpha component forwarded to `color()`.
 */
module maybe_color(color, alpha=1) {
  if (is_undef(color)) {
    children();
  } else {
    color(color, alpha=alpha) {
      children();
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rotate_children_with_shift
  ─────────────────────────────────────────────────────────────────────────────

  Rotate child geometry and shift it so the rotated bounding box begins at the
  origin.

  **Parameters:**
  - `size`: Unrotated child size as `[x, y, z]`.
  - `angles`: Rotation angles `[x, y, z]` in degrees.
  - `show_bbox`: If `true`, render the rotated bounding box as debug geometry.
 */
module rotate_children_with_shift(size=[0, 0, 0],
                                  angles=[0, 0, 0],
                                  show_bbox=false) {
  bb = rotated_bbox(size, angles);
  x_shift = bb[3];
  y_shift = bb[4];
  z_shift = bb[5];
  translate([with_default(x_shift, 0), y_shift, z_shift]) {
    rotate(angles) {
      children();
    }
  }
  if (show_bbox) {
    #cube([bb[0], bb[1], bb[2]]);
  }
}

/**
─────────────────────────────────────────────────────────────────────────────
with_anchor
─────────────────────────────────────────────────────────────────────────────

Translate child geometry so that the requested anchor lies at the origin.

This is a convenience wrapper around `normalize_anchor()` and `to_anchor()`.
It computes the anchor translation from the given size and applies it to
`children()`.

If `size` is a scalar, it is expanded to `[size, size, size]`.

Anchor values use this convention per axis:

- `1`: near/min side
- `0`: center
- `-1`: far/max side

Use `centered=true` when the child geometry is already centered on X and Y.
The flag is ignored for Z, where child geometry is always expected to span
from `0` to `size[2]`.

**Parameters:**

`anchor`: Anchor vector as `[x, y, z]`, or `undef`.
`size`: Object size as a scalar or `[x, y, z]`.
`centered`: Whether the child geometry is already centered on X and Y. It does
not affect Z placement.

**Children:**

Child geometry to translate.

**Examples:**
```scad
with_anchor(anchor=[1, 1, 1], size=[20, 30, 10]) {
  cube([20, 30, 10]);
}

with_anchor(anchor=[0, 0, 0], size=[20, 30, 10]) {
  cube([20, 30, 10]);
}

with_anchor(anchor=[-1, 0, 1], size=[20, 30, 10], centered=true) {
  translate([0, 0, 5]) {
    cube([20, 30, 10], center=true);
  }
}
```
*/
module with_anchor(anchor, size, centered=false) {
  anchor = normalize_anchor(anchor);
  size = is_num(size) ? [size, size, size] : size;
  coords = to_anchor(anchor=anchor, size=size, centered=centered);

  if (coords == [0, 0, 0]) {
    children();
  } else {
    translate(coords) {
      children();
    }
  }
}
