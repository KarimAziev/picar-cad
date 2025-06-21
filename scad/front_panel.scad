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

module front_panel_base(w=front_panel_width,
                        h=front_panel_height,
                        screws_x_offset=front_panel_screws_x_offset,
                        thickness=2) {
  difference() {
    linear_extrude(thickness) {
      rounded_rect(size=[w, h], r=h * 0.18, center=true);
    }

    two_x_screws_3d(screws_x_offset, m3_hole_dia);
  }
}

module front_panel(w=front_panel_width,
                   h=front_panel_height,
                   screws_x_offset=front_panel_screws_x_offset,
                   thickness=2) {
  rotate([90, 180, 0]) {
    difference() {
      front_panel_base(w, h, screws_x_offset, thickness);
      translate([0, -2, 0]) {
        ultrasonic_slots();
      }
    }
  }
}

color("white") {
  front_panel();
}
