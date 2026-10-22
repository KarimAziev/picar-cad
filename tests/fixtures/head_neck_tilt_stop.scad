/**
  * Module: Camera-plate contact with the neck's upright.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/parameters.scad>

use <../../scad/head/head_mount.scad>
use <../../scad/head/head_neck.scad>

offset = 0;
angle = head_neck_lower_tilt_stop() + offset;
axis = head_tilt_axis_position();

intersection() {
  head_neck_printable();
  translate(_head_neck_tilt_pivot()) {
    rotate([90, 0, 0]) {
      rotate([0, 0, angle]) {
        translate([-axis[0], head_front_height / 2 - axis[1],
                   -head_front_width / 2]) {
          rotate([0, 90, 0]) {
            head_mount(show_front=true, show_sides=false, show_bridge=false);
          }
        }
      }
    }
  }
}
