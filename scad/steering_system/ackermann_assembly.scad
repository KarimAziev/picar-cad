include <../parameters.scad>
use <../util.scad>
use <../steering_system/ackermann.scad>
use <../steering_system/knuckle.scad>
use <../placeholders/servo.scad>
use <steering_lower_link_detachable.scad>

module ackermann_trapezoid() {
  translate([0, 0, 2]) {
    translate([0, steering_link_width - 6, 0]) {
      ackermann_steering_linkage_long();
    }

    translate([0, -steering_link_width, 0]) {
      ackermann_steering_linkage_short();
      translate([steering_short_linkage_len * 0.5 + 0.9, 10, 0]) {
        rotate([0, 0, -116]) {
          ackermann_linkage_connector_right();
        }
      }
      translate([-steering_short_linkage_len * 0.5 - 0.9, 10, 0]) {
        rotate([0, 0, 116]) {
          ackermann_linkage_connector_left();
        }
      }
    }
  }
}

module servo_horn() {
  union() {
    translate([0, 0, -0.5]) {
      difference() {
        linear_extrude(height=1, center=true) {
          trapezoid_rounded(b = 6, t = 4, r=2, h = 15, center = true);
        }

        servo_hole_distances = number_sequence(from=-5, to=5, step=2);
        for (dist = servo_hole_distances) {
          linear_extrude(height=2, center=true) {
            translate([0, dist, 1]) {
              circle(d = 1.5, $fn = 60);
            }
          }
        }
      }
    }
    translate([0, -10, 0]) {
      difference() {
        cylinder(h = 2, r = 4, center = true, $fn = 60);
        translate([0, 0, 0.5]) {
          cylinder(h = 3, r = 2, center = true);
        }
        translate([0, 0, 0]) {
          cylinder(h = 3, r = 1, center = true);
        }
      }
    }
  }
}

module ackermann_assembly_demo() {
  union() {
    color("white") {
      ackermann_trapezoid();
    }

    lower_link_y_offst = -(steering_knuckle_lower_height +
                           steering_knuckle_upper_height - steering_link_width - 1) * 0.3;
    lower_link_z_offst = -(steering_knuckle_upper_height +
                           steering_knuckle_lower_height) * 0.5 +
      steering_knuckle_thickness;

    translate([-0.4, lower_link_y_offst - 2.2, lower_link_z_offst]) {
      rotate([0, 0, 0]) {
        color("white") {
          steering_lower_link_detachable();
        }
      }
    }

    color("white") {
      translate([0, -3, 0]) {
        offst = 5.6;
        half_wheels_dist = wheels_distance * 0.5;
        left_x = (-half_wheels_dist - steering_knuckle_width * 0.5) + steering_knuckle_side_hole_offset + offst;
        right_x = (half_wheels_dist + steering_knuckle_width * 0.5) - steering_knuckle_side_hole_offset - offst;
        union() {
          translate([left_x, 0, 0]) {
            rotate([90, -90, 90]) {
              knuckle_left();
            }
          }

          translate([right_x, 0, 0]) {
            rotate([90, 90, -90]) {
              knuckle_right();
            }
          }
        }
      }
    }

    translate([0, -18, 2.3]) {
      color("silver") {
        translate([0, 0, 2]) {
          servo_horn();
        }
      }

      servo_size = [23, 11, 20];
      translate([-servo_size[0] * 0.5 + 4.5, -9.5, servo_size[1] + 7.5]) {
        servo(size=servo_size);
      }
    }
  }
}

ackermann_assembly_demo();
