// This module defines a wall that connects the motor and rear wheel to the chassis.

include <parameters.scad>
use <util.scad>;

module rear_wheel_motor_mount() {
  translate([0, 0, motor_wall_height * 0.5]) {
    difference() {
      cube(size = [motor_wall_thickness, motor_wall_width, motor_wall_height],
           center = true);
      translate([0, 0, -4]) {
        offst = 9;
        for (y = [-offst, offst]) {
          translate([0, -(motor_wall_width / 2) + 5, y]) {
            rotate([90, 0, 90]) {
              cylinder(10, r=m3_hole_dia / 2, $fn=360, center=true);
            }
          }
        }
      }
    }
  }
}

module motor_wall_connector(size=[motor_wall_width * 0.6, 5], thickness=motor_wall_thickness) {
  linear_extrude(height=thickness) {
    square(size, center = true);
  }
}

module rear_wheel_motor_mount_3d(height=motor_wall_thickness) {
  difference() {
    linear_extrude(height=height) {
      rounded_rect([motor_wall_width, motor_wall_height], 2, center=true);
    }
    translate([0, -3.5, -1]) {
      linear_extrude(height = height + 2) {
        offst = 9;
        for (y = [-offst, offst]) {
          translate([0, y, 0]) {
            circle(r = m3_hole_dia / 2, $fn = 360);
          }
        }
      }
    }
  }
}

module motor_wall_mount() {
  connector_size = [motor_wall_width * 0.6, chassis_thickness + 1];
  rotate([180, 0, 0]) {
    translate([0, 0, -(motor_wall_height * 0.5) - (connector_size[1] * 0.5) - 1]) {
      rotate([90, 0, 90]) {
        union() {
          rear_wheel_motor_mount_3d();
          translate([0, (motor_wall_height * 0.5) + (connector_size[1] * 0.5) - 1, 0]) {
            motor_wall_connector([connector_size[0], connector_size[1]]);
          }
        }
      }
    }
  }
}

color("white") {
  motor_wall_mount();
}
