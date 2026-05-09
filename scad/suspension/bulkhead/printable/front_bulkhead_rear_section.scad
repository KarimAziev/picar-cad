/**
  * Module: Printable rear section of the front bulkhead.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../../colors.scad>

use <front_bulkhead_front_section_printable.scad>

module front_bulkhead_rear_section_printable(color=cobalt_blue_light_2) {
  front_bulkhead_printable_splitted(front=false, color=color);
}

front_bulkhead_rear_section_printable();