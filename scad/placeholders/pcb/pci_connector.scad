/**
  * Module: PCI connector placeholder
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>

use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>

function pci_connector_oriented_size(plist,
                                     orientation="lwh") =
  let (size = plist_get("size", plist))
  orientation_size(orientation, size);

module pci_connector(size=[16.0, 2, 2.5],
                     latch_pad=3.66,
                     color=metallic_yellow_silver_2,
                     latch_color=jet_black,
                     anchor=[0, 0, 1],
                     latch_thickness = 0.4,
                     orientation="lwh") {
  latch_w = size[0] / 2;
  latch_pad = with_default(latch_pad, size[1] * 0.23);
  latch_thickness = with_default(latch_thickness, 0.4);
  h = size[2];

  with_orientation(from="wlh", to=orientation, anchor=anchor, size=size) {
    union() {
      color(color) {
        cuboid(size=size);
      }
      color(latch_color, alpha=1) {
        translate([0, 0, h]) {
          translate([-size[0] / 2 - latch_thickness, 0, 0]) {
            cuboid(size=[latch_w + latch_thickness, size [1] + 0.1, latch_thickness],
                   anchor=[1, 0, 1]);
          }

          mirror_copy([0, 1, 0]) {
            translate([0, size[1] / 2 - latch_pad / 2, 0]) {
              cuboid(size=[size[0] + latch_thickness, latch_pad, latch_thickness]);
            }
          }
        }
      }
    }
  }
}

module pci_connector_from_plist(plist,
                                anchor=[0, 0, 1],
                                orientation="lwh") {
  size = plist_get("size", plist);
  latch_pad = plist_get("latch_pad", plist);
  color = plist_get("color", plist);
  latch_color = plist_get("latch_color", plist);
  anchor = plist_get("anchor", plist);
  latch_thickness = plist_get("latch_thickness", plist);

  pci_connector(size=size,
                latch_pad=latch_pad,
                color=color,
                latch_color=latch_color,
                anchor=anchor,
                latch_thickness=latch_thickness,
                orientation=orientation);
}

pci_connector(size=[16.0, 2, 2.5],
              latch_pad=3.66,
              color=metallic_yellow_silver_2,
              latch_color=jet_black,
              anchor=[0, 0, 1],
              latch_thickness = 0.4,
              orientation="lwh");