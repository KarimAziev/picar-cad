/**
  * Module: Printable front section of the front bulkhead.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../../colors.scad>

use <../../../lib/shapes3d.scad>
use <../util.scad>
use <front_bulkhead_printable_solid.scad>

module front_bulkhead_printable_splitted(front=true, color=cobalt_blue_light_1) {
  bbox = front_bulkhead_bbox_size();
  render() {
    difference() {
      front_bulkhead_printable(color=color);
      translate([0, 0, -0.5]) {
        cuboid(size=[bbox[0] + 1, bbox[1], bbox[2] + 1],
               anchor=[0, front ? -1 : 1,
                       1]);
      }
    }
  }
}

module front_bulkhead_front_section_printable(color=cobalt_blue_light_1) {
  front_bulkhead_printable_splitted(front=true, color=color);
}

front_bulkhead_front_section_printable();