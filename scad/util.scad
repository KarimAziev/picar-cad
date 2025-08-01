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

module row_of_circles(total_width, d, spacing, starts=[0, 0]) {
  step = spacing + d;
  amount = floor(total_width / step);

  if (amount > 0) {
    for (i = [0 : amount - 1]) {
      translate([starts[0] + i * step, starts[1]]) {
        circle(r = d / 2, $fn = 360);
      }
    }
  }
}

module rounded_rect(size, r=undef, center=false, fn) {
  w = size[0];
  h = size[1];
  rad = is_undef(r) ? (min(h, w)) * 0.3 : r;
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

module rounded_cube(size, r=undef, center=true, z_center=false, fn) {
  linear_extrude(height = size[2], center=z_center) {
    rounded_rect(size, r=r, center=center, fn=fn);
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
          mid = [(a[0]+b[0]) / 2, (a[1] + b[1]) / 2];

          color("green") {
            translate([mid[0], mid[1], 0.1]) {
              rotate([0, 0, angle]) {
                linear_extrude(height = 0.5) {
                  polygon(points=[[0, 0],
                                  [arrow_size,arrow_size / 2],
                                  [arrow_size, -arrow_size / 2]]);
                }
              }
            }
          }
        }
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
module two_x_screws_2d(x=0, d=2.4) {
  mirror_copy([1, 0, 0]) {
    translate([x, 0, 0]) {
      circle(r = d / 2, $fn=360);
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

module l_bracket(size, thickness=1, y_r=undef, z_r=undef, center=true) {
  x = size[0];
  y = size[1];
  z = size[2];

  ur = (y_r == undef) ? 0 : y_r;
  lr = (z_r == undef) ? 0 : z_r;

  union() {
    linear_extrude(height=thickness, center=center) {
      difference() {
        rounded_rect_two([x, y], center=center, r=ur);
        if ($children > 0) {
          children(0);
        }
      }
    }
    translate([0, -y / 2, z / 2 - thickness / 2]) {
      rotate([90, 0, 0]) {
        linear_extrude(height=thickness) {
          difference() {
            rounded_rect_two([x, z], center=center, r=lr);
            if ($children > 1) {
              children([1:$children-1]);
            }
          }
        }
      }
    }
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
