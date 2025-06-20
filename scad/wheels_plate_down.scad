// This file defines the models for the front wheels’ bottom plate connector and the steering servo horn.
// Both 2D and 3D representations are provided, and parameters such as wheel separation, wheel height,
// and screw diameters are defined for precise control of the design.

include <parameters.scad>
use <util.scad>;

module side_screw_holes() {
  line_w = 2;
  screw_offset = 4;

  for (x_offsets = [[-wheels_distance/2 + screw_offset,
                     steering_wheel_screws_dia + line_w],
                    [wheels_distance/2 - screw_offset,
                     -steering_wheel_screws_dia - line_w]]) {
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
    rounded_rect([wheels_distance, bottom_wheel_plate_width], r=bottom_wheel_plate_width/2, center=true);

    neckline_width=wheels_distance / 1.8;
    neckline_height=bottom_wheel_plate_width;

    translate([0, -bottom_wheel_plate_width * 0.75, 0]) {
      rounded_rect([neckline_width, neckline_height], center=true);
    }

    translate([0, bottom_wheel_plate_width * 0.2, 0]) {
      rounded_rect([wheels_distance*0.5, bottom_wheel_plate_width*0.13], r=1, center=true);
    }

    side_screw_holes();

    step = 10;
    amount = floor(bottom_wheel_plate_width / step);
    cutoff_w = wheels_distance * 0.65;

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

module wheels_plate_up_2d() {
  difference() {
    rounded_rect([wheels_distance, bottom_wheel_plate_width], r=bottom_wheel_plate_width/2, center=true);

    neckline_width=wheels_distance / 1.8;
    neckline_height=bottom_wheel_plate_width;

    translate([0, -bottom_wheel_plate_width * 0.75, 0]) {
      rounded_rect([neckline_width, neckline_height], center=true);
    }

    translate([0, bottom_wheel_plate_width * 0.2, 0]) {
      rounded_rect([wheels_distance*0.5, bottom_wheel_plate_width*0.13], r=1, center=true);
    }

    side_screw_holes();

    step = 10;
    amount = floor(bottom_wheel_plate_width / step);
    cutoff_w = wheels_distance * 0.65;

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

module steering_servo_horn(size=[wheels_distance, steering_servo_horn_width], height=2) {
  difference() {
    linear_extrude(height) {
      difference() {
        rounded_rect(size=size, r=steering_servo_horn_width / 2, center=true);
        side_screw_holes();
      }
    }
    cylinder(h = 10, r = steering_servo_horn_center_screw_d / 2, center = true, $fn=360);
  }
}

module wheels_plate_down_3d(height=2) {
  linear_extrude(height) {
    wheels_plate_down_2d();
  }
}

module wheels_plate_axle(height=2) {
  union() {
    linear_extrude(height) {
      difference() {
        wheels_plate_down_2d();
        square([70, 20], center = true);
      }
    }
    translate([-35, 0, 0]) {
      cylinder(height, r1=bottom_wheel_plate_width/2, r2=bottom_wheel_plate_width/2);
    }
    translate([35, 0, 0]) {
      cylinder(height, r1=bottom_wheel_plate_width/2, r2=bottom_wheel_plate_width/2);
    }
  }
}

color("white") {
  wheels_plate_down_3d();
  translate([0, bottom_wheel_plate_width, 0]) {
    steering_servo_horn();
  }
}
