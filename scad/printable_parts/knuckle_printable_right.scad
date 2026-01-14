include <../parameters.scad>

use <../steering_system/knuckle.scad>

module knuckle_printable_right(knuckle_color="white",
                               knuckle_shaft_color="white") {

  translate([0, 0, knuckle_height]) {
    knuckle_printable(knuckle_color=knuckle_color,
                      knuckle_shaft_color=knuckle_shaft_color,
                      knuckle_color_alpha=1,
                      use_mirror=true);
  }
}

knuckle_printable_right();
