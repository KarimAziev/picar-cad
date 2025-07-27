/**
 * Module: a plate with two 12-mm mounting holes for two tumblers (switch buttons)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <parameters.scad>
use <util.scad>

function rear_panel_screw_panel_width() =
  max(rear_panel_screw_hole_dia + rear_panel_screw_offset * 2,
      rear_panel_size[2]);

module rear_panel_screw_holes() {
  yw = rear_panel_screw_panel_width();
  rad = rear_panel_screw_hole_dia / 2;

  y = yw / 2 - rad - rear_panel_screw_offset;
  union() {
    for (x=rear_panel_screw_holes_x_offsets) {
      translate([x, y, 0]) {
        circle(r=rad, $fn=360);
      }
    }
  }
}

module rear_panel() {
  w = rear_panel_size[0];
  h = rear_panel_size[1];
  half_of_w = w / 2;
  hole_rad = rear_panel_switch_slot_dia / 2;
  screws_panel_w = rear_panel_screw_panel_width();
  l_bracket(size=[w, h, screws_panel_w],
            thickness=rear_panel_thickness,
            y_r=3,
            z_r=3) {

    union() {
      for (x=rear_panel_holes_x_offsets) {
        translate([x, 0, 0]) {
          circle(r=hole_rad, $fn=360);
        }
      }
    }
    rear_panel_screw_holes();
  }
}

rear_panel();