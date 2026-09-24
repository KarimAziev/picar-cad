/**
 * Module: Color coverage for every public shapes3d module.
 *
 * The left specimen in each cell inherits blue through color=undef; the
 * right specimen sets orange directly. Ring's outer-only mode is included.
*
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <../../scad/lib/shapes3d.scad>
use <fixtures.scad>

names = ["cuboid", "cyl", "cylinder_cut", "star_3d", "notched_circle",
         "rounded_rect_recess", "cube_border", "ring", "y_chamfered_cube",
         "chamfered_cube", "tapered_box", "ring / outer color"];

module color_fixture(index, color) {
  if (index == 0) {
    cuboid([16, 12, 8], r=2, color=color);
  } else if (index == 1) {
    cyl(d=16, h=8, color=color);
  } else if (index == 2) {
    cylinder_cut(r=8, h=8, cut_w=6, fn=48, color=color);
  } else if (index == 3) {
    star_3d(r_outer=8, r_inner=4, h=8, color=color);
  } else if (index == 4) {
    notched_circle(d=16, cutout_w=11, h=8, convexity=4, color=color);
  } else if (index == 5) {
    rounded_rect_recess([12, 8],
                        [16, 12],
                        r=1,
                        thickness=8,
                        recess_thickness=2,
                        anchor=[0, 0, 1],
                        color=color);
  } else if (index == 6) {
    cube_border([16, 12, 8],
                border_w=3,
                r=1,
                anchor=[0, 0, 1],
                color=color);
  } else if (index == 7 || index == 11) {
    ring(od=16, d=9, h=8, whole_color=index == 7, color=color);
  } else if (index == 8) {
    y_chamfered_cube([16, 12, 8],
                     chamfer=2,
                     anchor=[0, 0, 1],
                     color=color);
  } else if (index == 9) {
    chamfered_cube([16, 12, 8],
                   chamfer=2,
                   anchor=[0, 0, 1],
                   color=color);
  } else if (index == 10) {
    tapered_box([16, 12], [10, 6], h=8, color=color);
  }
}

$fn = 48;
for (index = [0 : len(names) - 1]) {
  translate([(index % 3) * 72, -floor(index / 3) * 42, 0]) {
    color("SteelBlue") {
      color_fixture(index, color=undef);
    }
    translate([24, 0, 0]) {
      color_fixture(index, color="DarkOrange");
    }
    translate([12, -16, 0]) {
      shape_test_label(names[index], size=2.5);
    }
  }
 }
