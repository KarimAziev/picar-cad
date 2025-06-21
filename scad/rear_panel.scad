// This is a plate with two 12-mm mounting holes for two tumblers (switch buttons)

include <parameters.scad>

module rear_panel(size=rear_panel_size, tumbler_switch_dia = rear_panel_switch_slot_dia, x_offsets = [-16, 16]) {
  difference() {
    cube(size = size, center = true);
    for (x = x_offsets) {
      translate([x, 0, 0]) {
        cylinder(10, r=tumbler_switch_dia / 2, center=true);
      }
    }
  }
}

rotate([90, 0, 0]) {
  rear_panel();
}
