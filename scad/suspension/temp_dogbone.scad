
module temp_dogbone(l=61.2, ball_d=5.8, d=3.8, pin_l=9.82, pin_d=2) {
  module ball() {
    sphere(d=ball_d, $fn=40);
    rotate([90, 0, 0]) {
      cylinder(d=pin_d, h=pin_l, $fn=30, center=true);
    }
  }

  cylinder(d=d, h=l, $fn=40);

  translate([0, 0, ball_d / 2]) {
    ball();
  }
  translate([0, 0, l - ball_d / 2]) {
    ball();
  }
}

temp_dogbone();