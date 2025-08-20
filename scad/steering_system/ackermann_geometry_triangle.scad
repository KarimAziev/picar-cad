/**
 * Module: Ackermann Geometry Triangle
 *
 * This is a simple visualization of the Ackermann geometry for developer purposes
 * and it is not supposed to be printed.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
use <../util.scad>

module ackermann_geometry_triangle(triangle_color="yellowgreen", alpha=0.2) {
  half_of_track_width = wheels_track_width / 2;

  triangle_points = [[0, 0],                       // center of the rack
                     [-half_of_track_width, 0],    // center of the wheels
                     [0, -wheelbase_effective]     // tie rod convergence point
                     ];

  color(triangle_color, alpha=alpha) {
    linear_extrude(height=0.5, center=false) {
      mirror_copy([1, 0, 0]) {
        polygon(points=triangle_points);
      }
    }
  }
}

ackermann_geometry_triangle();