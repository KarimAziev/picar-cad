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

module dotted_lines_fill_y(y_length, starts, y_offset, r) {
  step = y_offset + 2*r;
  amount = floor(y_length / step) + 1;

  for (i = [0 : amount - 1]) {
    translate([starts[0], starts[1] + i * step]) {
      circle(r = r, $fn = 50);
    }
  }
}

function number_sequence(from, to, step) = [for (i = [from : step : to]) i];

module dotted_lines_fill_x(length, starts, x_offset, r) {
  step = x_offset + 2*r;
  amount = floor(length / step) + 1;

  for (i = [0 : amount - 1]) {
    translate([starts[0] + i * step, starts[1]]) {
      circle(r = r, $fn = 50);
    }
  }
}

module dotted_lines_y(amount, starts, y_offset, r) {
  for (i = [0:amount-1]) {
    translate([starts[0], starts[1] + i*(y_offset + r*2)]) {
      circle(r = r, $fn = 50);
    }
  }
}

module rounded_rect(size, r=5, center=false) {
  w = size[0];
  h = size[1];
  offst = center ? [-w/2, -h/2] : [0, 0];

  hull() {
    translate([r, r] + offst) {
      circle(r);
    }
    translate([w - r, r] + offst) {
      circle(r);
    }
    translate([r, h - r] + offst) {
      circle(r);
    }
    translate([w - r, h - r] + offst)
      circle(r);
  }
}

module debug_polygon(points, paths=undef, convexity=undef, debug=false,
                     arrow_size=1, font_size=4, font_color="red",
                     show_arrows=true) {
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
      all_paths = paths == undef ? [[for (i = [0 : len(points)-1]) i]] : paths;

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
                  polygon(points=[[0,0],[arrow_size,arrow_size/2],[arrow_size,-arrow_size/2]]);
                }
              }
            }
          }
        }
    }
  }
}

module cube_with_corner_holes(size = [10, 10, 10], center = false, hole_dia = 3) {
  difference() {
    cube(size, center = center);
    z_center = center ? 0 : size[2] / 2;
    for (x_ind = [0, 1]) {
      for (y_ind = [0, 1]) {
        x_pos = (center ? -size[0] / 2 : 0) + x_ind * size[0];
        y_pos = (center ? -size[1] / 2 : 0) + y_ind * size[1];

        translate([x_pos, y_pos, z_center]) {
          cylinder(h = size[2] + 2, r = hole_dia / 2, center = true, $fn = 360);
        }
      }
    }
  }
}

module four_corner_holes(size = [10, 10, 10], center = false, hole_dia = 3, fn_val = 360) {
  z_center = center ? 0 : size[2] / 2;
  for (x_ind = [0, 1]) {
    for (y_ind = [0, 1]) {

      x_pos = (center ? -size[0] / 2 : 0) + x_ind * size[0];
      y_pos = (center ? -size[1] / 2 : 0) + y_ind * size[1];

      translate([x_pos, y_pos, z_center]) {
        cylinder(h = size[2] + 2, r = hole_dia / 2, center = center, $fn = fn_val);
      }
    }
  }
}

module four_corner_holes_2d(size = [10, 10], center = false, hole_dia = 3, fn_val = 24) {
  for (x_ind = [0, 1])
    for (y_ind = [0, 1]) {
      x_pos = (center ? -size[0] / 2 : 0) + x_ind * size[0];
      y_pos = (center ? -size[1] / 2 : 0) + y_ind * size[1];
      translate([x_pos, y_pos])
        circle(r = hole_dia / 2, $fn = fn_val);
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
  translate([x, 0, 0]) {
    circle(r = d / 2, $fn=360);
  }

  mirror([1, 0, 0]) {
    translate([x, 0, 0]) {
      circle(r = d / 2, $fn=360);
    }
  }
}

// Creates an isosceles trapezoid.
module trapezoid(b = 20, t = 10, h = 15, center = false) {
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
module trapezoid_rounded(b = 20, t = 10, h = 15, r = 2, center = false) {
  m = (b - t) / 2;

  pts = [[0, 0],
         [b, 0],
         [b - m, h],
         [m, h]];

  offset(r = r, chamfer = false)
    offset(r = -r, chamfer = false)
    polygon(points = center ? [for (p = pts) [p[0] - b/2, p[1] - h/2]] : pts);
}

module rounded_rect_two(size, r=5, center=false, segments=10) {
  w = size[0];
  h = size[1];
  offst = center ? [-w/2, -h/2] : [0, 0];

  pts_bottom = [[0, 0], [w, 0]];
  pts_right = [[w, 0], [w, h - r]];
  arc_top_right = [for (i = [1 : segments])
      let (a = i * (90 / segments))
        [(w - r) + r * cos(a), (h - r) + r * sin(a)]];
  pts_top_edge = [[w - r, h], [r, h]];

  arc_top_left = [for (i = [1 : segments])
      let (a = 90 + i * (90 / segments))
        [r + r * cos(a), (h - r) + r * sin(a)]];

  pts_left = [[0, h - r], [0, 0]];

  pts = concat(pts_bottom, pts_right, arc_top_right, pts_top_edge, arc_top_left, pts_left);

  translate(offst)
    polygon(points = pts);
}

module cylinder_cutted(h=10, r=5, cutted_w = 1) {
  difference() {
    cylinder(h = h, r = r, center = true);

    y = h + 1;
    d = r * 2;
    translate([d - cutted_w * 0.5, 0, 0]) {
      cube([d, d, h + 1], center=true);
    }
    translate([-d + cutted_w * 0.5, 0, 0]) {
      cube([d, d, h + 1], center=true);
    }
  }
}