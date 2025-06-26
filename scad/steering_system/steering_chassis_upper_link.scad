include <../parameters.scad>
use <steering_lower_link_detachable.scad>

// Creates upper steering link that is the plotted in the chassis. Shouldn't be printed.
// Each side is connected to the top of the knuckle.
module steering_upper_chassis_link(thickness=steering_upper_chassis_link_thickness) {
  union() {
    linear_extrude(thickness) {
      difference() {
        steering_lower_link_detachable_2d();
        square([70, 20], center=true);
      }
    }
    translate([-35, 0, 0]) {
      cylinder(thickness, r1=steering_link_width / 2, r2=steering_link_width/2);
    }
    translate([35, 0, 0]) {
      cylinder(thickness, r1=steering_link_width / 2, r2=steering_link_width/2);
    }
  }
}

color("white") {
  steering_upper_chassis_link();
}
