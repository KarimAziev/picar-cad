/**
 * Module: The box rim
 *
 * Features: configurable rim/rails, lid hooks/latches, and optional inner cell grids.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <../../lib/shapes2d.scad>

module rim(h1, h2, size_1, size_2, corner_rad, fn) {
  hull() {
    linear_extrude(height=h1, center=false, convexity=2) {
      rounded_rect(size_1, center=true, r=corner_rad, fn=fn);
    }
    translate([0, 0, h1]) {
      linear_extrude(height=h2, center=false, convexity=2) {
        rounded_rect(size_2, center=true, r=corner_rad, fn=fn);
      }
    }
  }
}

rim(h1=1.5,
    h2=1.5,
    size_1=[25, 40],
    size_2=[21, 38],
    corner_rad=1,
    fn=100);