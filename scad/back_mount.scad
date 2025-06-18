// This is a plate with two 12-mm mounting holes for two tumblers (switch buttons)

back_mount_width  = 52;
back_mount_height = 25;
back_wheel_depth  = 2;
hole_dia          = 12;

module back_mount() {
  difference() {
    cube(size = [back_mount_width, back_mount_height, back_wheel_depth], center = true);
    offsets = [-16, 16];
    for (x = offsets) {
      translate([x, 0, 0]) {
        cylinder(10, r=hole_dia / 2, center=true);
      }
    }
  }
}
rotate([90, 0, 0]) {
  back_mount();
}
