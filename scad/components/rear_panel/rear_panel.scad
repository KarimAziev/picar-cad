/**
 * Module: a plate with two 12-mm mounting holes for two tumblers (switch
 * buttons)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../parameters.scad>

use <../../lib/holes.scad>
use <../../lib/l_bracket.scad>
use <../../lib/shapes2d.scad>
use <../../lib/slots.scad>
use <../../placeholders/toggle_switch.scad>



function rear_panel_bolt_panel_width() =
  max(rear_panel_bolt_hole_dia + rear_panel_bolt_offset * 2,
      rear_panel_size[2]);

module rear_panel_bolt_holes() {
  yw = rear_panel_bolt_panel_width();
  rad = rear_panel_bolt_hole_dia / 2;
  y = yw / 2 - rad - rear_panel_bolt_offset;

  union() {
    for (x=rear_panel_bolt_holes_x_offsets) {
      translate([x, y, 0]) {
        circle(r=rad, $fn=360);
      }
    }
  }
}

module rear_panel_bolt_holes_3d() {
  yw = rear_panel_bolt_panel_width();
  rad = rear_panel_bolt_hole_dia / 2;
  y = yw / 2 - rad - rear_panel_bolt_offset;

  rotate([90, 0, 0]) {
    union() {
      for (x=rear_panel_bolt_holes_x_offsets) {
        translate([x, y, -rear_panel_mount_thickness -0.05]) {
          counterbore(h=rear_panel_mount_thickness + 0.1,
                      d=rear_panel_bolt_hole_dia,
                      bore_h=rear_panel_bolt_cbore_h,
                      bore_d=rear_panel_bolt_cbore_hole_dia,
                      sink=false);
        }
      }
    }
  }
}

module rear_panel(show_switch_button=false, colr) {
  w = rear_panel_size[0];
  h = rear_panel_size[1];

  max_hole_x = max(rear_panel_bolt_holes_x_offsets);
  min_hole_x = min(rear_panel_bolt_holes_x_offsets);
  bolts_panel_w = rear_panel_bolt_panel_width();
  bolt_cut_h = bolts_panel_w - rear_panel_thickness;

  union() {
    color(colr, alpha=1) {
      difference() {
        l_bracket(size=[w, h, bolts_panel_w],
                  thickness=rear_panel_thickness,
                  convexity=2,
                  vertical_thickness=rear_panel_mount_thickness,
                  children_modes=[["difference", "vertical"],
                                  ["difference", "vertical"]],
                  y_r=3,
                  z_r=3) {
          w1 = w - (w - abs(min_hole_x));
          w2 = w - (w - abs(max_hole_x));
          translate([min_hole_x
                     - w1
                     - rear_panel_bolt_cbore_hole_dia / 2
                     - 1,
                     -bolt_cut_h / 2 + rear_panel_thickness / 2, 0]) {

            square([w1, bolt_cut_h], center=false);
          }

          translate([max_hole_x
                     + rear_panel_bolt_cbore_hole_dia / 2
                     + 1,
                     -bolt_cut_h / 2 + rear_panel_thickness / 2, 0]) {

            square([w2, bolt_cut_h], center=false);
          }
        }

        for (x=rear_panel_holes_x_offsets) {
          translate([x, 0, rear_panel_thickness / 2 + 0.05]) {
            rotate([0, 180, 0]) {
              counterbore(d=rear_panel_switch_slot_dia,
                          h=rear_panel_thickness + 0.1,
                          bore_h=rear_panel_switch_slot_cbore_h,
                          bore_d=rear_panel_switch_slot_cbore_dia,
                          sink=true);
            }
          }
        }

        translate([0, -h / 2
                   - rear_panel_mount_thickness / 2,
                   bolts_panel_w / 2]) {
          rear_panel_bolt_holes_3d();
        }
      }
    }
    if (show_switch_button) {
      for (x=rear_panel_holes_x_offsets) {
        translate([x, 0, toggle_switch_size[0] + rear_panel_thickness / 2
                   + 0.05]) {
          rotate([180, 0, 0]) {
            toggle_switch();
          }
        }
      }
    }
  }
}

rear_panel(show_switch_button=false);
