/**
 * Module: Debug utilities
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>


module debug_polygon_text(points,
                          font_size=3.0,
                          font_color=green_1,
                          circle_color=yellow_3,
                          circle_r=0.3,
                          h=0.5) {
  has_h = is_num(h);
  for (i = [0 : len(points) - 1]) {
    pt = points[i];

    color(font_color)
      translate([pt[0], pt[1], 0.1]) {
      if (has_h) {
        linear_extrude(height = 0.5) {
          text(str(i), size = font_size, valign="center", halign="center");
        }
      } else {
        text(str(i), size = font_size, valign="center", halign="center");
      }
    }

    color(circle_color) {
      translate([pt[0], pt[1]]) {
        if (has_h) {
          linear_extrude(height=h - 0.01, center=false) {
            circle(r=circle_r, $fn=20);
          }
        } else {
          circle(r=circle_r, $fn=20);
        }
      }
    }
  }
}

module debug_polygon_arrows(points,
                            paths=undef,
                            arrow_size=1) {
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

module debug_polygon(points,
                     paths=undef,
                     convexity=undef,
                     debug=true,
                     arrow_size=1,
                     font_size=3.0,
                     font_color=green_2,
                     show_arrows=false) {
  polygon(points=points, paths=paths, convexity=convexity);

  if (debug) {
    debug_polygon_text(points=points,
                       font_size=font_size,
                       font_color=font_color);
    if (show_arrows) {
      debug_polygon_arrows(points=points,
                           paths=paths,
                           arrow_size=arrow_size);
    }
  }
}

module debug_highlight(debug=false) {
  if (debug) {
    #children();
  } else {
    children();
  }
}

module bounding_box(excess=0, planar=false) {
  module _xProjection() {
    if (planar) {
      projection()
        rotate([90, 0, 0]) {
        linear_extrude(1, center=true) {
          hull() {
            children();
          }
        }
      }
    } else {
      xs = excess < .1 ? 1: excess;
      linear_extrude(xs, center=true)
        projection() {
        rotate([90, 0, 0]) {
          linear_extrude(xs, center=true) {
            projection() {
              hull() {
                children();
              }
            }
          }
        }
      }
    }
  }

  // a bounding box with an offset of 1 in all axis
  module _oversize_bbox() {
    if (planar) {
      minkowski() {
        _xProjection() {
          children(); // x axis
        }
        rotate(-90) {
          _xProjection() {
            rotate(90) {
              children(); // y axis
            }
          }
        }
      }
    } else {
      minkowski() {
        _xProjection() {
          children(); // x axis
        }
        rotate(-90) {
          _xProjection() {
            rotate(90) {
              children(); // y axis
            }
          }
        }
        rotate([0,-90, 0]) {
          _xProjection() {
            rotate([0, 90, 0]) {
              children(); // z axis
            }
          }
        }
      }
    }
  }

  // offsets a cube by `excess`
  module _shrink_cube() {
    intersection() {
      translate((1-excess)*[1, 1, 1]) {
        children();
      }
      translate((1-excess)*[-1,-1,-1]) {
        children();
      }
    }
  }

  if (planar) {
    offset(excess-1/2) {
      _oversize_bbox() {
        children();
      }
    }
  } else {
    render(convexity=2)
      if (excess>.1) {
        _oversize_bbox() {
          children();
        }
      } else {
        _shrink_cube() {
          _oversize_bbox() {
            children();
          }
        }
      }
  }
}

// // Example(3D):
// module shapes() {
//   translate([10, 8, 4]) cube(5);
// }
// #bounding_box() {
//   shapes();
// }
// shapes();

// module shapes_2d() {
//   translate([10, 8]) square(5);
//   translate([3, 0]) square(2);
// }

// translate([-20, 0, 0]) {
//   #bounding_box(planar=true) {
//     shapes_2d();
//   }
// }
