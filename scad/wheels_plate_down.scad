// This file defines the models for the front wheels’ bottom plate connector and the steering servo horn.
// Both 2D and 3D representations are provided, and parameters such as wheel separation, wheel height,
// and screw diameters are defined for precise control of the design.

use <util.scad>;

wheels_distance           = 180;
wheel_height              = 30;
servo_screw_d             = 1.5;

steering_wheel_screws_dia = 3.5;
horn_height               = 6;

module side_screw_holes() {
  line_w = 2;
  screw_offset = 4;

  for (x_offsets = [[-wheels_distance/2 + screw_offset, steering_wheel_screws_dia + line_w], [wheels_distance/2 - screw_offset, -steering_wheel_screws_dia - line_w]]) {
    x1 = x_offsets[0];
    x2 = x_offsets[1];
    translate([x1, 0, 0]) {
      circle(d=steering_wheel_screws_dia, $fn=360);
      translate([x2, 0, 0]) {
        circle(d=steering_wheel_screws_dia, $fn=360);
      }
    }
  }
}

module wheels_plate_down_2d() {
  difference() {
    rounded_rect([wheels_distance, wheel_height], r=wheel_height/2, center=true);
    neckline_width=wheels_distance / 1.8;

    neckline_height=wheel_height;

    translate([0, -wheel_height * 0.75, 0]) {
      rounded_rect([neckline_width, neckline_height], center=true);
    }

    translate([0, wheel_height * 0.2, 0]) {
      rounded_rect([wheels_distance*0.5, wheel_height*0.13], r=1, center=true);
    }

    side_screw_holes();

    step = 10;
    amount = floor(wheel_height / step);
    cutoff_w = wheels_distance * 0.7;

    for (i = [0:amount-1]) {
      translate([0, 0 + -i * step]) {
        rounded_rect([cutoff_w, 4], r=2, center=true);
      }
    }

    translate([0, 9]) {
      rounded_rect([cutoff_w, 4], r=2, center=true);
    }
  }
}

module steering_servo_horn(height=2) {
  difference() {

    linear_extrude(height) {
      difference() {

        rounded_rect(size=[wheels_distance, horn_height], r=horn_height / 2, center=true);
        side_screw_holes();
      }
    }
    cylinder(h = 10, r = servo_screw_d / 2, center = true, $fn=360);
  }
}

module wheels_plate_down_3d(height=2) {
  linear_extrude(height) {
    wheels_plate_down_2d();
  }
}

color("white") {
  wheels_plate_down_3d();
  translate([0, wheel_height, 0]) {
    steering_servo_horn();
  }
}
