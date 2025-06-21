// This module defines the front panel of the car and includes mounting slots
// for the standard ultrasonic distance sensor HC-SR04, which is attached using
// an R3090 rivet.

include <parameters.scad>
use <util.scad>;

module ultrasonic_eyes_slots(d=17, distance=9, center=true, h=10) {
  x_offset = d / 2 + distance / 2;
  translate([-x_offset, 0, 0]) {
    cylinder(h, r=d/2, $fn=360, center=center);
  }
  translate([x_offset, 0, 0]) {
    cylinder(h, r=d/2, $fn=360, center=center);
  }
}

module ultrasonic_slots() {
  union() {
    translate([0, -8.9, 0]) {
      minkowski() {
        cube(size = [11, 2, 11], center = true);
        cylinder(5, center=true);
      }
    }

    translate([0, 7.8, 0]) {
      minkowski() {
        cube(size = [10, 4, 12], center = true);
        cylinder(5, center=true);
      }
    }

    ultrasonic_eyes_slots();
  }
}

module front_wall_base(w=front_wall_width, h=front_wall_height, thickness=2) {
  difference() {
    linear_extrude(thickness) {
      rounded_rect(size=[w, h], r=5, center=true);
    }

    two_x_screws_3d(-27, m3_hole_dia);
  }
}

module front_wall(w=front_wall_width, h=front_wall_height, thickness=1) {
  rotate([90, 180, 0]) {
    difference() {
      front_wall_base();
      translate([0, -2, 0]) {
        ultrasonic_slots();
      }
    }
  }
}

module front_mount_wall(w=front_wall_width, h=front_wall_height, thickness=1) {
  difference() {
    front_wall_base();
  }
}

color("white") {
  front_wall();
}
