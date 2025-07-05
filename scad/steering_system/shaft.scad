include <../parameters.scad>
use <../util.scad>
use <../placeholders/servo.scad>

module shaft(d=shaft_dia, h=shaft_height) {
  rotate([0, 90, 0]) {
    linear_extrude(height=h, center=true) {
      circle(r=d / 2, $fn=120);
    }
  }
}
