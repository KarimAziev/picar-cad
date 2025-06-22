// front_panel.scad - Defines the front panel of the vehicle.
//
// This module includes:
// - A base front panel with rounded corners and mount holes
// - Slots for the HC-SR04 ultrasonic sensor, which is attached using
// an R3090 rivet.
//
// Sensor: HC-SR04
// Attachment: R3090 rivet

include <parameters.scad>
use <util.scad>

module ultrasonic_sensor_mounts(d=front_panel_ultrasonic_sensor_dia,
                                distance=front_panel_ultrasonic_sensors_offset,
                                center=true,
                                h=10) {
  rad = d / 2;

  x_offset = rad + distance / 2;

  translate([-x_offset, 0, 0]) {
    cylinder(h, r=rad, $fn=360, center=center);
  }
  translate([x_offset, 0, 0]) {
    cylinder(h, r=rad, $fn=360, center=center);
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

    ultrasonic_sensor_mounts();
  }
}

module front_panel(w=front_panel_width,
                   h=front_panel_height,
                   screws_x_offset=front_panel_screws_x_offset,
                   thickness=2) {
  rotate([90, 180, 0]) {
    difference() {
      linear_extrude(thickness) {
        rounded_rect(size=[w, h], r=h * 0.18, center=true);
      }

      translate([0, -1, 0]) {
        two_x_screws_3d(screws_x_offset, m3_hole_dia);
      }
      translate([0, -2, 0]) {
        ultrasonic_slots();
      }
    }
  }
}

module front_panel_back_mount(w=front_panel_width,
                              h=front_panel_height * 0.8,
                              screws_x_offset=front_panel_screws_x_offset,
                              bottom_cutout_size = [15, 5],
                              side_screws_dia=m3_hole_dia,
                              screws_square_size=[25, 10],
                              screws_square_dia=m3_hole_dia,
                              thickness=1.5) {
  linear_extrude(thickness) {
    difference() {
      rounded_rect(size=[w, h], r=h * 0.18, center=true);
      two_x_screws_2d(screws_x_offset, m3_hole_dia);
      translate([0, -h * 0.5 + bottom_cutout_size[1] * 0.5]) {
        square(size = [bottom_cutout_size[0], bottom_cutout_size[1]], center = true);
      }
      four_corner_holes_2d(size=screws_square_size, center=true,
                           hole_dia=screws_square_dia);
    }
  }
}

color("white") {
  rotate(a = [90, 0, 0]) {
    translate([front_panel_width * 0.55, 0, 0]) {
      front_panel();
    }
  }

  translate([-front_panel_width * 0.55, 0, 0]) {
    front_panel_back_mount();
  }
}
