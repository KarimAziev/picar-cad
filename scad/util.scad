/**
 * Module: Utility modules that simplify common geometric constructions.
 *
 * This file provides several utility modules that simplify common geometric constructions
 * throughout the design. It includes helper modules to create:
 *   - Dotted lines (both along the X and Y directions),
 *   - Rounded rectangles,
 *   - Debugging visualizations for polygons (with numbered vertices and directional arrows),
 *   - Cubes with corner holes, and
 *   - Common four-corner hole patterns.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

/**
 * Calculates the translation positions for screws.
 *
 * Parameters:
 *   slot_w:    The width of the centered parent slot.
 *   screw_dia: The diameter of the screw.
 *   distance:  The desired distance between the centered parent slot and the screw.
 */
function screw_x_offst(slot_w, screw_dia, distance) =
  (slot_w * 0.5 + screw_dia * 0.5) + distance;

/**
 * Returns an array of numbers starting at `from` and incremented by `step`.
 *
 * The `from` value is always included, and `to` is included if the sequence
 * lands on it exactly, otherwise, the last number is the largest value that
 * does not exceed `to`.
 */

function number_sequence(from, to, step) = [for (i = [from : step : to]) i];

/**
 * Truncate a number to a specified number of decimal places.
 *
 * Parameters:
 * val:  The input number to truncate.
 * dec:  The number of decimal places to retain (default is 1).
 *
 * Example:
 *   truncate(3.14159, 2)  // returns 3.14
 *   truncate(-2.718, 1)   // returns -2.7
 */
function truncate(val, dec=1) =
  (val >= 0) ? floor(val * pow(10, dec)) / pow(10, dec)
  : ceil(val * pow(10, dec)) / pow(10, dec);

/**
 * Computes the depth (or reduction in width) at the notch on a circle.
 *
 * This function calculates the notch width by determining the chord’s offset
 * from the circle’s edge. It subtracts two times the distance from the circle's
 * center to the chord (computed using the Pythagorean theorem) from the full diameter.
 *
 * Parameters:
 *   dia - The diameter of the circle.
 *   w   - The chord length corresponding to the notch width at the circle’s center.
 *
 * Returns:
 *   The calculated notch width, which is the reduction in the diameter due to the notch.
 */

function calc_notch_width(dia, w) =
  dia - 2 * sqrt(((dia / 2) * (dia / 2)) - ((w / 2) * (w / 2)));

/**
   Recursively sum elements of a numeric list.

   Parameters:
   list: the list of numeric values
   count: optional number of first elements to sum. If omitted, the whole list
   is summed.

   Returns:
   The sum of the requested elements.
*/

function sum(list, count=undef) =
  let (length = is_undef(count) ? len(list) : count)
  length < 2
  ? list[0]
  : (list[length - 1] + sum(list, length - 1));

function drop(a, n) = n >= len(a) ? [] : [for (i = [n : len(a)-1]) a[i]];

function slice(a, start, end) = start > end ? [] : [for (i = [start : end]) a[i]];

/**
   Extracts a column (index) from a list of records, providing a default value for
   missing entries.

   Parameters:
   items: list of lists (records)
   idx: integer index to extract from each item
   def_val: value to use when items[i][idx] is undefined

   Returns:
   A list where each element is items[i][idx] when defined, otherwise def_val.
*/
function map_idx(items, idx, def_val) = [for (i = [0 : len(items) - 1])
    is_undef(items[i][idx])
      ? def_val
      : items[i][idx]];

function poly_width_at_y(pts, y_target) =
  let (intersections = [for (i = [0 : len(pts)-1])
           if (((pts[i][1] - y_target)
                * (pts[(i + 1) % len(pts)][1] - y_target) <= 0)
               && (pts[(i + 1) % len(pts)][1] - pts[i][1] != 0))
             pts[i][0] + ((y_target - pts[i][1])
                          / (pts[(i + 1) % len(pts)][1] - pts[i][1]))
               * (pts[(i + 1) % len(pts)][0] - pts[i][0])])
  (max(intersections) - min(intersections));

function reverse(list) = [for (i = [len(list)-1:-1:0]) list[i]];

function non_empty(items) = items && len(items) > 0;

/**
 *
 * Draws a horizontal row of circles spanning a given total width.
 *
 * Parameters:
 *   total_width:  The total width available for the row. This value is used to determine how many circles fit.
 *   d:            The diameter of each circle.
 *   spacing:      The additional distance between circles (beyond the circle diameter).
 *   starts:       An optional two-element list [x, y] that specifies the starting coordinate for the row.
 *                 Defaults to [0, 0] if not provided.
 *
 * For example, the code below will create 3 circles:

 * row_of_circles(total_width=20, d=5, spacing=1);
 *
 */

module row_of_circles(total_width,
                      d,
                      spacing,
                      starts=[0, 0],
                      vertical=false,
                      fn=360,
                      direction=1) {
  step = spacing + d;
  amount = floor(total_width / step);

  if (amount > 0) {
    for (i = [0 : amount - 1]) {
      let (s = i * step,
           x = vertical ? starts[0] : starts[0] + s,
           y = vertical ? starts[1] + s : starts[1]) {
        translate([direction > 0 ? x : -x, direction > 0 ? y : -y]) {
          circle(r = d / 2, $fn=fn);
        }
      }
    }
  }
}

module row_of_cubes(total_width,
                    size=[2.4, 2.4, 10],
                    spacing=3.6,
                    starts=[0, 0],
                    center=false,
                    y_center=false,
                    z_center=false,
                    direction=1) {
  step = spacing + size[0];
  amount = floor(total_width / step);

  if (amount > 0) {
    half_of_w = total_width / 2;

    x_offst = center ? -half_of_w : 0;

    translate([x_offst,
               y_center ? 0 : size[1] / 2,
               0]) {
      for (i = [1 : amount]) {
        let (s = i * step,
             x = starts[0] + s,
             y = starts[1]) {
          translate([direction > 0 ? x : -x, direction > 0 ? y : -y]) {
            translate([0, 0, z_center ? 0 : size[2] / 2]) {
              cube(size, center=true);
            }
          }
        }
      }
    }
  }
}

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

module debug_polygon(points, paths=undef, convexity=undef, debug=true,
                     arrow_size=1, font_size=4, font_color="red",
                     show_arrows=false) {
  polygon(points=points, paths=paths, convexity=convexity);

  if (debug) {
    for (i = [0 : len(points) - 1]) {
      pt = points[i];

      color(font_color)
        translate([pt[0], pt[1], 0.1]) {
        linear_extrude(height = 0.5) {
          text(str(i), size = font_size, valign="center", halign="center");
        }
      }

      color("yellow") {
        translate([pt[0], pt[1]]) {
          circle(r = 0.5);
        }
      }
    }

    if (show_arrows) {
      all_paths = paths == undef ?
        [[for (i = [0 : len(points)-1]) i]] : paths;

      for (path = all_paths)
        for (i = [0 : len(path) - 1]) {
          a = points[path[i]];
          b = points[path[(i + 1) % len(path)]];

          dx = b[0] - a[0];
          dy = b[1] - a[1];
          angle = atan2(dy, dx);
          mid = [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2];

          color("green") {
            translate([mid[0], mid[1], 0.1]) {
              rotate([0, 0, angle]) {
                linear_extrude(height = 0.5) {
                  polygon(points=[[0, 0],
                                  [arrow_size, arrow_size / 2],
                                  [arrow_size, -arrow_size / 2]]);
                }
              }
            }
          }
        }
    }
  }
}

module four_corner_children(size=[10, 10],
                            center=true) {
  for (x_ind = [0, 1])
    for (y_ind = [0, 1]) {
      x_pos = (center ? -size[0] / 2 : 0) + x_ind * size[0];
      y_pos = (center ? -size[1] / 2 : 0) + y_ind * size[1];
      translate([x_pos, y_pos]) {
        children();
      }
    }
}

module four_corner_holes_2d(size=[10, 10],
                            center=false,
                            hole_dia=3,
                            fn_val=60) {
  for (x_ind = [0, 1])
    for (y_ind = [0, 1]) {
      x_pos = (center ? -size[0] / 2 : 0) + x_ind * size[0];
      y_pos = (center ? -size[1] / 2 : 0) + y_ind * size[1];
      translate([x_pos, y_pos]) {
        circle(r=hole_dia / 2, $fn=fn_val);
        children();
      }
    }
}

module dotted_screws_line_y(x_poses, y, d=1.5) {
  for (x = x_poses) {
    translate([x, y]) {
      circle(d = d, $fn = 50);
    }
  }
}

module two_x_screws_3d(x=0, d=2.4, center=true, h=10) {
  translate([x, 0, 0]) {
    cylinder(h, r=d / 2, $fn=360, center=center);
  }

  mirror([1, 0, 0]) {
    translate([x, 0, 0]) {
      cylinder(h, r=d / 2, $fn=360, center=center);
    }
  }
}
module two_x_screws_2d(x=0, d=2.4, fn=360) {
  mirror_copy([1, 0, 0]) {
    translate([x, 0, 0]) {
      circle(r = d / 2, $fn=fn);
      children();
    }
  }
}

// Creates an isosceles trapezoid.
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

// Creates an isosceles trapezoid with rounded corners
module trapezoid_rounded(b=20, t=10, h=15, r=undef, center=false) {
  rad = is_undef(r) ? min(b, t, h) * 0.1 : r;
  offset(r=rad, chamfer=false) {
    offset(r=-rad, chamfer=false) {
      trapezoid(b=b, t=t, h=h, center=center);
    }
  }
}

// Creates an trapezoid with rounded bottom corners
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

module cylinder_cutted(h=10, r=5, cutted_w=1, center=true, fn) {
  difference() {
    cylinder(h=h, r=r, center=center, $fn=fn);

    d = r * 2;
    translate([d - cutted_w * 0.5, 0, 0]) {
      cube([d, d, h + 1], center=center);
    }
    translate([-d + cutted_w * 0.5, 0, 0]) {
      cube([d, d, h + 1], center=center);
    }
  }
}

module ring_2d_outer(r, w, d, fn) {
  r = is_undef(r) ? d / 2 : r;
  difference() {
    circle(r=r + w, $fn=fn);
    circle(r=r, $fn=fn);
  }
}

module ring_2d_inner(r, w, d, fn) {
  r = is_undef(r) ? d / 2 : r;
  difference() {
    circle(r=r, $fn=fn);
    circle(r=r - w, $fn=fn);
  }
}

module ring_2d(r, w, d, fn, outer) {
  if (outer) {
    ring_2d_outer(r, w, d, fn);
  } else {
    ring_2d_inner(r, w, d, fn);
  }
}

module star_2d(n=5, r_outer=20, r_inner=10) {
  pts = [for (i = [0 : 2 * n - 1])
      let (angle = 360 / (2*n) * i,
           r = (i % 2 == 0) ? r_outer : r_inner)
        [r * cos(angle), r * sin(angle)]];
  polygon(points = pts);
}

module star_3d(n=5, r_outer=20, r_inner=10, h=2) {
  linear_extrude(height=h, center=false) {
    star_2d(n=n, r_outer=r_outer, r_inner=r_inner);
  }
}

module fillet(r) {
  offset(r = -r) {
    offset(delta = r) {
      children();
    }
  }
}

// Generates the mirrored object in addition to the original one.
module mirror_copy(v = [1, 0, 0]) {
  children();
  mirror(v) {
    children();
  }
}

module translate_copy(v) {
  children();
  translate(v) {
    children();
  }
}

function notched_circle_square_center_x(r, cutout_w) =
  let (L = sqrt(r * r - (cutout_w / 2) * (cutout_w / 2)))
  L + cutout_w / 2;

function cutout_depth(r, cutout_w) =
  r - sqrt(r * r - (cutout_w / 2) * (cutout_w / 2));

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

/*
  - size: full width/height of the square (centered at origin)
  - chamfer: how much to cut from each corner along each axis (must be <= size/2)
  Produces an 8-vertex chamfered square (a common octagon shape).
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

// calculates width of the top (narrower) side of an isosceles trapezoid
// bottom_width : width of the bottom base
// side_length  : length of each equal leg (>= 0)
// angle_deg     : angle measured from vertical
function calc_isosceles_trapezoid_top_width(bottom_width,
                                            side_length,
                                            angle_deg) =
  let (a = angle_deg * PI / 180,
       s = abs(side_length),
       top = bottom_width - 2 * s * sin(a))
  max(0, top);

function calc_knuckle_connector_full_len(length,
                                         parent_dia,
                                         outer_d,
                                         border_w) =
  let (notch_width = calc_notch_width(max(parent_dia, outer_d),
                                      min(parent_dia, outer_d)))
  notch_width + length + border_w;

module vent_slots_panel(w, h, z, slot_w, slot_gap, slot_h, rows) {
  cols = max(0, floor((w - slot_gap)/(slot_w + slot_gap)));
  row_pitch = (rows>1) ? ((h-slot_h)/(rows-1)) : 0;
  for (r=[0:rows-1]) {
    y0 = h/2 - slot_h/2 - r*row_pitch;
    for (c=[0:cols-1]) {
      x = -w/2 + slot_gap + slot_w/2 + c*(slot_w + slot_gap);
      translate([x, y0, 0]) {
        cube([slot_w, slot_h, z], center=true);
      }
    }
  }
}

/**
 * Create a circular through-hole with an optional larger shallow counterbore
 * (or a tapered transition if sink=true).
 *
 * Parameters:
 *   h: total hole depth (height)
 *   d: main hole diameter
 *   upper_d: counterbore / upper-diameter (optional). If omitted a default is used.
 *   upper_h: depth of the counterbore (optional). If omitted defaults to ~h*0.3
 *   center: if true, the hole is centered in Z (translate by -h/2)
 *   sink: if true, the upper portion is a conical frustum (r1->r2). If false,
 *         the upper portion is a straight cylinder of upper_d.
 *   fn: $fn used for cylinder approximation (default 60)
 *
 * Behavior:
 * - The module draws a base cylinder of diameter d and height h.
 * - If upper_d is supplied (or implied by default), an upper region is drawn at
 *   Z = h - upper_h: either a larger cylinder (sink=false) or a frustum
 *   (sink=true) to create a tapered or cylindrical counterbore.
 * - center affects only the Z translation of the whole shape.
 */

module counterbore(h,
                   d,
                   upper_d,
                   upper_h,
                   center=false,
                   sink=false,
                   fn=60) {
  upper_h = is_undef(upper_h) ? h * 0.3 : upper_h;
  upper_rad = (is_undef(upper_d) ? d * 2.8 : upper_d) / 2;

  translate([0, 0, center ? -h / 2 : 0]) {
    cylinder(h=h, r=d / 2, center=false, $fn=fn);
    translate([0, 0, h - upper_h]) {
      if (sink) {
        cylinder(h=upper_h, r1=d / 2, r2=upper_rad, center=false, $fn=fn,
                 $fa = 12,
                 $fs = 20,);
      } else {
        cylinder(h=upper_h, r=upper_rad, center=false, $fn=fn,
                 $fa = 12,
                 $fs = 20,);
      }
    }
  }
}

/**
 * Convenience wrapper that builds a countersink by calling counterbore() with
 * sink=true. Uses the same parameters as counterbore but forces a tapered upper
 * region (conical frustum).
 */

module countersink(h, d, upper_d, upper_h, center=false, fn=60) {
  counterbore(h=h,
              d=d,
              upper_d=upper_d,
              center=center,
              upper_h=upper_h,
              fn=fn,
              sink=true);
}

module cube_3d(size, center=true) {
  if (center) {
    translate([0, 0, size[2] / 2]) {
      cube(size, center=center);
    }
  } else {
    cube(size, center=center);
  }
}

/**
 * Draws a rounded rectangular through-hole with an optional rectangular
 * counter-pocket (recess).
 * Parameters:
 *   size: [width_x, length_y, ...] - size of the main rounded rectangle. The
 *         corner radius is provided separately in r.
 *   recess_size: optional [recess_x, recess_y] - size of the recess. If undefined,
 *               no recess is created.
 *   r: corner radius for the rounded rectangle (applies to both main hole and
 *      the recess when recess_size is provided).
 *   thickness: total extrusion depth (depth of the main hole).
 *   recess_thickness: optional depth for the recess. If omitted, a reasonable
 *                    default (roughly thickness / 2.2, clamped to >= 1) is used.
 *   recess_reverse: boolean (default false). If true, the recess is located at
 *                  the opposite face along Z (i.e. near the top instead of at Z=0).
 *   center: boolean. If true the shapes are centered on X and Y; otherwise they
 *           are positioned with a corner at the origin.
 *
 * Behaviour:
 * - The main rounded rectangle is extruded through the full thickness.
 * - If recess_size is present a second rounded rectangle of recess_size is
 *   extruded by recess_thickness and positioned either at Z=0 or at the opposite
 *   face depending on recess_reverse.
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
  translate([center ? 0 : max(size[0], !recess_size  ? 0 : recess_size[0]) / 2,
             center ? 0 : max(size[1], !recess_size ? 0 : recess_size[1]) / 2,
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
 * Renders a sequence of rounded rectangular holes (or rectangular counter-bores)
 * laid out along the Y axis.
 *
 * Each entry in specs describes a single hole. Entries are placed one after
 * another along +Y; each entry may also provide an optional local offset and an
 * optional rectangular counter-bore (a shallow larger rectangular recess).
 *
 * Note on terminology:
 * - "counterbore" is commonly used for circular holes. For non-circular holes the
 *   terms "rectangular counterbore", "rectangular counter-pocket" or simply
 *   "rectangular recess" are clearer. This module implements a rectangular
 *   shallow recess in the same axis as the hole.
 *
 * Parameters:
 *   specs: list of per-hole specifications. Each item is a 2-4 element list:
 *     [ size, offset?, recess_spec? ]
 *
 *     - size: [ width_x, length_y, corner_radius, radius_tolerance? ]
 *         width_x      : hole width along the X axis
 *         length_y     : hole length along the Y axis (also used when stacking)
 *         corner_radius: radius used for rounded corners
 *         radius_tolerance (optional): additional radius applied on top of
 *             corner_radius (used for clearance). If omitted, default_r_tolerance
 *             is used.
 *
 *     - offset? (optional): [ y_gap, x_offset, y_offset, z_offset? ]
 *         y_gap   : distance (gap) after this hole before placing the next hole.
 *                   Has effect only if there is a following spec.
 *         x_offset: local X translation for this hole.
 *         y_offset: local Y translation for this hole; does NOT affect the
 *                   placement of subsequent holes (useful for intended overlaps).
 *         z_offset: local Z translation for this hole (optional).
 *
 *     - recess_spec? (optional): [ recess_x, recess_y, recess_thickness?, reverse? ]
 *         recess_x, recess_y : size of the rectangular recess (larger than main size)
 *         recess_thickness? : depth/thickness of the recess (optional - a sensible
 *                            default is chosen if omitted)
 *         reverse?         : boolean. If true, the recess is positioned at the
 *                            opposite face (i.e. reversed along Z).
 *
 *   thickness: extrusion depth (height) of the main hole
 *   center: boolean. If true the hole(s) are centered at the origin in X and Y;
 *           otherwise they are placed so their min corner is at the origin.
 *   rotation: optional rotation applied to each hole and to its children.
 *             Pass the same kind of value you supply to rotate().
 *   default_r_tolerance: fallback extra radius added to corner radius when a
 *                       per-size radius_tolerance is not supplied.
 *
 * Behaviour notes:
 * - Holes are placed sequentially along +Y. The stacking position for item i is
 *   the sum of all earlier size[length_y] plus the sum of earlier y_gap values.
 * - y_offset is local to the single hole and does not affect the stacking of
 *   later holes.
 * - If a recess_spec is provided, a larger shallow rectangular recess is
 *   created on top of the main hole. It does not affect the stacking position.
 * - If rotation is provided, the module rotates both the drawn hole and any
 *   children() placed inside the hole.
 *
 * Example:
 *   rect_holes(
 *     specs=[
 *       [[9.5, 30.4, 2.0], [0, -12.0, -10], [20, 38]],  // first hole + counterbore
 *       [[9.5, 8.4, 2.0], [26, -2.0, 0]]                // second hole
 *     ],
 *     thickness=4,
 *     center=false,
 *     default_r_tolerance=0
 *   );
 */

module rounded_rect_slots(specs,
                          thickness,
                          center=false,
                          rotation,
                          default_r_tolerance=0) {
  sizes = map_idx(specs, 0, [0, 0, 0, 0]);
  y_sizes = map_idx(sizes, 1, 0);

  offsets = map_idx(specs, 1, [0, 0, 0]);
  y_gaps = map_idx(offsets, 0, 0);
  x_offsets = map_idx(offsets, 1, 0);
  y_offsets = map_idx(offsets, 2, 0);
  z_offsets = map_idx(offsets, 3, 0);

  recess_specs = map_idx(specs, 2, []);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         prev_y_size= i > 0 ? sum(y_sizes, i) : 0,
         prev_y_space=i > 0 ? sum(y_gaps, i) : 0,
         y = prev_y_size + prev_y_space) {

      let (x_offset = x_offsets[i],
           y_offset = y_offsets[i],
           z_offset = z_offsets[i],
           recess_spec = recess_specs[i]) {

        $spec = spec;

        translate([x_offset, y + y_offset, z_offset]) {
          if (!$children) {
            if (rotation) {
              rotate(rotation) {
                rounded_rect_recess(size=sizes[i],
                                    recess_size=recess_spec,
                                    r=sizes[i][2] + (is_undef(sizes[i][3])
                                                     ? default_r_tolerance
                                                     : sizes[i][3]),
                                    center=center,
                                    recess_thickness=recess_spec[2],
                                    recess_reverse=recess_spec[3],
                                    thickness=thickness);
              }
            } else {
              rounded_rect_recess(size=sizes[i],
                                  recess_size=recess_spec,
                                  recess_thickness=recess_spec[2],
                                  r=sizes[i][2] + (is_undef(sizes[i][3])
                                                   ? default_r_tolerance
                                                   : sizes[i][3]),
                                  center=center,
                                  recess_reverse=recess_spec[3],
                                  thickness=thickness);
            }
          }

          if (rotation) {
            rotate(rotation) {
              children();
            }
          } else {
            children();
          }
        }
      }
    }
  }
}

/**
 * Create groups of four circular holes (one in each corner of a rectangle)
 * according to a list of specifications. Each specification produces a rectangle
 * of size [width, height] and places four corner holes (via four_corner_children)
 * with the specified hole diameter and optional per-row offsets.
 *
 * specs format:
 *   specs = [
 *     [ width_x, height_y, hole_diameter, y_gap, x_offset?, y_offset?, counterbore_spec? ],
 *     ...
 *   ]
 *
 *   - width_x         : rectangle width (X direction) used for corner placement
 *   - height_y        : rectangle height (Y direction) used when stacking rows
 *   - hole_diameter   : diameter of each corner hole (passed to counterbore)
 *   - y_gap           : extra gap after this row before placing the next row
 *   - x_offset (opt)  : local X translation for this row (default 0)
 *   - y_offset (opt)  : local Y translation for this row (default 0)
 *   - counterbore_spec(optional): if you want a counterbore at each corner,
 *       supply a nested counterbore spec (format used by your counterbore module).
 *
 * Parameters:
 *   specs: array of per-row specs (see format above)
 *   thickness: total thickness/depth passed to the counterbore operation
 *
 * Behavior:
 * - Rows are stacked along +Y. The Y position for a row is the sum of earlier
 *   rows' height_y values, earlier y_gap values and earlier hole_diameter values
 *   (matches the original accumulation logic).
 * - Each row is translated by the optional x_offset and y_offset before
 *   generating the four corner holes.
 * - Each corner hole is created by calling counterbore() inside four_corner_children.
 */

module four_corner_hole_rows(specs, thickness) {
  y_sizes = map_idx(specs, 1, 0);
  dia_sizes = map_idx(specs, 2, 0);
  y_spaces = map_idx(specs, 3, 0);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         dia=spec[2],
         prev_y_size= i > 0 ? sum(y_sizes, i) : 0,
         prev_y_space=i > 0 ? sum(y_spaces, i) : 0,
         prev_dias=i > 0 ? sum(dia_sizes, i) : 0,
         y = prev_y_size + prev_y_space + prev_dias,
         x = is_undef(spec[4]) ? 0 : spec[4],
         y_offset = is_undef(spec[5]) ? 0 : spec[5]) {

      translate([x - spec[0] / 2, y + y_offset, 0]) {
        four_corner_children(size=[spec[0], spec[1]],
                             center=false) {
          counterbore(d=dia,
                      h=thickness
                      + 0.2,
                      upper_h=thickness / 2,
                      upper_d=dia * 1.5,
                      center=false,
                      sink=false);
        }
      }
    }
  }
}

/**
 * Create a vertical sequence of single circular counterbores (slots) from a
 * compact specs list.
 *
 * specs format:
 *   specs = [
 *     [ diameter, y_gap, x_offset?, y_offset? ],
 *     ...
 *   ]
 *
 *   - diameter     : hole diameter
 *   - y_gap        : gap after this slot before placing the next slot
 *   - x_offset (opt): local X translation for this slot (default 0)
 *   - y_offset (opt): local Y translation for this slot (default 0)
 *
 * Parameters:
 *   specs: list of slot specifications (see format above)
 *   thickness: main depth passed to counterbore()
 *   cfactor: multiplier applied to diameter to obtain the counterbore upper diameter
 *            (default 1.5)
 *
 * Behavior:
 * - Slots are stacked along +Y. The Y position for a slot is computed by
 *   accumulating previous y_gap and previous diameters (matching the original logic).
 * - Each slot is translated by its x_offset/y_offset and placed slightly below Z=0
 *   (-0.1) before the counterbore() call (preserving original behavior).
 */

module counterbore_single_slots_by_specs(specs, thickness, cfactor=1.5) {
  dia_sizes = map_idx(specs, 0, 0);
  y_spaces = map_idx(specs, 1, 0);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         dia=spec[0],
         prev_y_space=i > 0 ? sum(y_spaces, i) : 0,
         prev_dias=i > 0 ? sum(dia_sizes, i) : 0,
         y = prev_y_space + prev_dias,
         x = is_undef(spec[2]) ? 0 : spec[2],
         y_offset = is_undef(spec[3]) ? 0 : spec[3]) {

      translate([x, y + y_offset, -0.1]) {
        counterbore(d=dia,
                    h=thickness
                    + 1,
                    upper_h=thickness / 2,
                    upper_d=dia * cfactor,
                    center=false,
                    sink=false);
      }
    }
  }
}
