/**
  * Module: PCB button placeholder
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

module pcb_button(size=[4.5, 3.3, 3],
                  button_h=1.36,
                  button_d=1.8,
                  color=matte_black,
                  button_color=metallic_yellow_silver,
                  orientation="wlh",
                  anchor=[0, 0, 1]) {

  with_orientation(from="wlh", to=orientation, anchor=anchor, size=size) {
    color(with_default(color, matte_black), alpha=1) {
      cuboid(size=size);
    }
    translate([0, 0, size[2]]) {
      color(with_default(button_color, metallic_yellow_silver), alpha=1) {
        cyl(d=button_d, h=button_h, $fn=10);
      }
    }
  }
}

module pcb_button_from_plist(plist,
                             orientation="wlh",
                             anchor=[0, 0, 1]) {
  size = plist_get("size", plist);
  button_h = plist_get("button_h", plist);
  button_d = plist_get("button_d", plist);
  color = plist_get("color", plist);
  button_color = plist_get("button_color", plist);
  pcb_button(size=size,
             button_h=button_h,
             button_d=button_d,
             color=color,
             button_color=button_color,
             orientation=orientation,
             anchor=anchor);
}

pcb_button();