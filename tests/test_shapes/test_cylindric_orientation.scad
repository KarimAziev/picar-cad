/**
 * Module: Visual comparison of all six cylindrical orientations.
 *
 * Each column uses the same final anchor [0, 0, 1]. All specimens must rest
 * on z=0. Tapers show the axial direction; flats and asymmetric notches show
 * profile rotation. Local axes are red X, green Y, and blue Z.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

use <fixtures.scad>

orientations = ["wlh", "whl", "lwh", "lhw", "hlw", "hwl"];
shapes       = ["cylinder", "frustum", "cone", "flats", "notches", "ring",
                "tapered ring"];
colors       = ["SteelBlue", "DarkOrange", "MediumSeaGreen", "Orchid",
                "Goldenrod", "Turquoise", "Salmon"];
cell_size    = [42, 44];

for (column = [0 : len(orientations) - 1]) {
  translate([column * cell_size[0], 28, 0]) {
    shape_test_label(orientations[column], size=4);
  }
  for (row = [0 : len(shapes) - 1]) {
    translate([column * cell_size[0], -row * cell_size[1], 0]) {
      cylindric_fixture(shapes[row],
                        orientation=orientations[column],
                        color=colors[row]);
      shape_test_axes();
    }
  }
 }
for (row = [0 : len(shapes) - 1]) {
  translate([-24, -row * cell_size[1], 0]) {
    shape_test_label(shapes[row], halign="right");
  }
 }
