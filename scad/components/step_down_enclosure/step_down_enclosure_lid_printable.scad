include <../../colors.scad>
include <../../parameters.scad>

use <step_down_voltage_enclosure.scad>

module step_down_enclosure_lid_printable(plist=step_down_enclosure_plist,
                                         color=white_smoke_1) {
  color(color) {
    step_down_enclosure_printable(plist=plist, part="lid");
  }
}

step_down_enclosure_lid_printable();