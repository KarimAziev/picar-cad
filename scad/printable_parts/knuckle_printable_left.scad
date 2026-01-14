include <../parameters.scad>

use <../steering_system/knuckle.scad>

module knuckle_printable_left(knuckle_color="white",
                              knuckle_shaft_color="white") {

  translate([0, 0, knuckle_height]) {
    knuckle_printable(knuckle_color=knuckle_color,
                      knuckle_shaft_color=knuckle_shaft_color,
                      knuckle_color_alpha=1);
  }
}

knuckle_printable_left();
