/**
 * Module: Visual anchor checks for horizontal cylindrical shapes.
 *
 * Each origin has positive X/Y/Z axes (red/green/blue). Anchor components
 * must move the reference box along the final axes, including negative Z.
 * Flats/notches anchor to the uncut circle rather than the remaining edges.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <fixtures.scad>

anchors      = [[0, 0, 1], [0, 0, 0], [1, 1, 1], [-1, -1, -1],
                [1, -1, 0], [-1, 0, 1]];
shapes       = ["frustum", "flats",
                "notches", "tapered ring"];
orientations = ["hwl", "whl",
                "lhw", "hlw"];
colors       = ["DarkOrange", "Orchid",
                "Goldenrod", "Salmon"];
cell_size    = [50, 54];

for (column = [0 : len(anchors) - 1]) {
  translate([column * cell_size[0], 32, 0]) {
    shape_test_label(str(anchors[column]));
  }
  for (row = [0 : len(shapes) - 1]) {
    translate([column * cell_size[0], -row * cell_size[1], 0]) {
      cylindric_fixture(shapes[row],
                        orientation=orientations[row],
                        anchor=anchors[column],
                        color=colors[row]);
      shape_test_axes(length=29);
    }
  }
}
for (row = [0 : len(shapes) - 1]) {
  translate([-30, -row * cell_size[1], 0]) {
    shape_test_label(str(shapes[row], " / ", orientations[row]),
                     halign="right");
  }
}
