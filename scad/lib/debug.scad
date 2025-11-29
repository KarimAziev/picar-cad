/**
 * Module: Debug utilities
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

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
