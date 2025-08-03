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

module ackermann_geometry_triangle() {
  triangle_points = [[0, 0],                // center of the rack
                     [x_left_knuckle, 0],    // center of the steering knuckle
                     [0, ackermann_y_intersection]     // tie rod convergence point
                     ];

  linear_extrude(height=0.5, center=false) {
    polygon(points = triangle_points);
    mirror([1, 0, 0]) {
      polygon(points = triangle_points);
    }
  }
}

ackermann_geometry_triangle();