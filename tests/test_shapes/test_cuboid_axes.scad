/**
 * Module: Cuboid extrusion axes and profile-side selections.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <../../scad/lib/shapes3d.scad>
use <fixtures.scad>

axes = ["z", "y", "x"];
sizes = [[30, 10, 2], [30, 2, 10], [2, 30, 10]];

for (i = [0:2]) {
  translate([i * 45, 0, 0]) {
    cuboid(sizes[i], r=1.5, axis=axes[i], color="SteelBlue");
    translate([0, -24, 0]) {
      shape_test_label(str("axis = ", axes[i]));
    }
  }
  translate([i * 45, 50, 0]) {
    cuboid(sizes[i],
           axis=axes[i],
           side=[["top", 3], ["bottom_right", 1]],
           color="DarkOrange");
  }
}

translate([45, 78, 0]) {
  shape_test_label("top = 3, bottom-right = 1");
}
