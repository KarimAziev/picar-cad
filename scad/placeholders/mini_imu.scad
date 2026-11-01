/**
  * Module: Generic Mini IMU placeholder
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../colors.scad>

use <../lib/placement.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>

mini_imu_example_plist = ["size", [12.7, 20.3, 1.02],
                          "color", green_5,
                          "bolt_d", 2.5,
                          "bolt_spacing", [7.69, 15.3],
                          "bolt_spacing_corners", ["top_left"],
                          "interface", ["hole_d", 1.02,
                                        "pad", 0.5,
                                        "gap", 1.52,
                                        "corner_pad", 0.76,
                                        "reverse_side", false,
                                        "cols", 5, // cols | rows
                                        "default_text_props", ["gap", 4],
                                        "texts", ["SCL", "SDA", "GND", "VIN", "VDD"]],];

module mini_imu(plist, anchor=[0, 0, 1]) {
  size = plist_get("size", plist);
  w = size[0];
  l = size[1];
  t = size[2];
  color = plist_get("color", plist, green_5);

  bolt_d = plist_get("bolt_d", plist);
  bolt_spacing = plist_get("bolt_spacing", plist);
  bolt_spacing_corners = plist_get("bolt_spacing_corners", plist);

  interface = plist_get("interface", plist, []);
  interface_hole_d = plist_get("hole_d", interface);
  interface_pad = plist_get("pad", interface);
  interface_cols = plist_get("cols", interface);
  interface_gap = plist_get("gap", interface, 1.52);
  interface_rows = plist_get("rows", interface);
  interface_reverse_side = plist_get("reverse_side", interface, false);
  interface_corner_pad = plist_get("corner_pad", interface);
  interface_default_text_props = plist_get("default_text_props", interface, []);
  interface_default_text_props_gap = plist_get("gap",
                                               interface_default_text_props);
  interface_texts = plist_get("texts", interface);

  difference() {
    color(color, alpha=1) {
      cuboid(size=size);
    }
    if (bolt_spacing) {
      translate([0, 0, -0.1]) {
        four_corner_children(size=bolt_spacing, include=bolt_spacing_corners) {
          cylinder(d=bolt_d, h=t + 0.2, $fn=10);
        }
      }
    }

    if (interface_hole_d) {

      if (interface_cols) {
        mirror([0, interface_reverse_side ? 1 : 0, 0]) {
          translate([0,
                     -l / 2 + interface_hole_d / 2 + interface_corner_pad,
                     0]) {
            columns_children(cols=interface_cols,
                             w=interface_hole_d,
                             center=true,
                             gap=interface_gap) {
              counterbore(d=interface_hole_d, h=t);
            }
          }
        }
      } else if (interface_rows) {
        mirror([interface_reverse_side ? 1 : 0, 0, 0]) {
          translate([-w / 2 + interface_hole_d / 2 + interface_corner_pad,
                     0,
                     0]) {
            rows_children(rows=interface_rows,
                          w=interface_hole_d,
                          anchor=0,
                          gap=interface_gap) {
              counterbore(d=interface_hole_d, h=t);
            }
          }
        }
      }
    }
  }
}

mini_imu(mini_imu_example_plist);