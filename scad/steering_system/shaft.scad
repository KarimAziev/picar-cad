include <../parameters.scad>
use <../util.scad>
use <../placeholders/servo.scad>

module shaft(d=knuckle_shaft_dia, h=knuckle_shaft_len) {
  rotate([0, 90, 0]) {
    linear_extrude(height=h, center=true) {
      circle(r=d / 2, $fn=120);
    }
  }
}
