// This is a plate with two 12-mm mounting holes for two tumblers (switch buttons)

include <parameters.scad>

module back_mount(size=back_wheel_size, tumbler_switch_dia = tumbler_switch_hole_dia, x_offsets = [-16, 16]) {
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
  back_mount();
}
