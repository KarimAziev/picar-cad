/**
 * Module: a plate with two 12-mm mounting holes for two tumblers (switch
 * buttons)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <parameters.scad>

use <l_bracket.scad>
use <lib/holes.scad>
use <lib/shapes2d.scad>
use <placeholders/toggle_switch.scad>

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

module rear_panel_screw_holes_3d() {
  yw = rear_panel_screw_panel_width();
  rad = rear_panel_screw_hole_dia / 2;
  y = yw / 2 - rad - rear_panel_screw_offset;

  rotate([-90, 0, 0]) {
    union() {
      for (x=rear_panel_screw_holes_x_offsets) {
        translate([x, y, -0.05]) {
          counterbore(h=rear_panel_mount_thickness + 0.1,
                      d=rear_panel_screw_hole_dia,
                      upper_h=rear_panel_screw_cbore_h,
                      upper_d=rear_panel_screw_cbore_hole_dia);
        }
      }
    }
  }
}

module rear_panel(show_switch_button=false, colr) {
  w = rear_panel_size[0];
  h = rear_panel_size[1];

  max_hole_x = max(rear_panel_screw_holes_x_offsets);
  min_hole_x = min(rear_panel_screw_holes_x_offsets);
  screws_panel_w = rear_panel_screw_panel_width();
  screw_cut_h = screws_panel_w - rear_panel_thickness;

  union() {
    color(colr, alpha=1) {
      difference() {
        l_bracket(size=[w, h, screws_panel_w],
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
                     - rear_panel_screw_cbore_hole_dia / 2
                     - 1,
                     -screw_cut_h / 2 + rear_panel_thickness / 2, 0]) {

            square([w1, screw_cut_h], center=false);
          }

          translate([max_hole_x
                     + rear_panel_screw_cbore_hole_dia / 2
                     + 1,
                     -screw_cut_h / 2 + rear_panel_thickness / 2, 0]) {

            square([w2, screw_cut_h], center=false);
          }
        }

        for (x=rear_panel_holes_x_offsets) {
          translate([x, 0, rear_panel_thickness / 2 + 0.05]) {
            rotate([0, 180, 0]) {
              counterbore(d=rear_panel_switch_slot_dia,
                          h=rear_panel_thickness + 0.1,
                          upper_d=rear_panel_switch_slot_cbore_dia);
            }
          }
        }

        translate([0, -h / 2
                   - rear_panel_mount_thickness / 2,
                   screws_panel_w / 2]) {
          rear_panel_screw_holes_3d();
        }
      }
    }
    if (show_switch_button) {
      for (x=rear_panel_holes_x_offsets) {
        translate([x, 0, toggle_switch_size[0] + rear_panel_thickness / 2 + 0.05]) {
          rotate([180, 0, 0]) {
            toggle_switch();
          }
        }
      }
    }
  }
}

rear_panel(show_switch_button=true);
