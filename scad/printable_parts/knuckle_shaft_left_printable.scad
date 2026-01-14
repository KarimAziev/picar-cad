include <../parameters.scad>

use <../steering_system/knuckle_shaft.scad>

module knuckle_shaft_left_printable() {
  translate([0, 0, knuckle_shaft_vertical_len + knuckle_shaft_dia]) {
    knuckle_shaft(show_wheel=false);
  }
}
knuckle_shaft_left_printable();