// front_panel.scad - Defines the front panel of the vehicle.

// This module includes:
//
//  - The main chassis-integrated front panel with integrated slots for mounting the HC-SR04 ultrasonic sensor.
//  - A detachable back panel that secures the ultrasonic sensor from behind.
//  - A separate sensor fixation detail which is secured using either two R3090 rivets, or M2.5 screws.
//
// Sensor and Attachment Information:
//
//  - Sensor: HC-SR04 ultrasonic sensor
//  - Attachment Hardware: R3090 rivet or M2.5 screws

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

module ultrasonic_screws_2d(size=[42.5, 17.5], d=m1_hole_dia) {
  y_offsets = number_sequence(from = 0, to = 4, step = m1_hole_dia + 0.4);
  for (y = y_offsets) {
    translate([0, -y, 0]) {
      four_corner_holes_2d(size=size, center=true, hole_dia=d);
    }
  }
}

module front_panel_connector_screws(reverse_y = false) {
  half_of_len = front_panel_connector_len / 2;
  half_of_w = front_panel_connector_width / 2;
  screw_rad = front_panel_connector_screw_dia / 2;

  for (pair = front_panel_connector_screw_offsets) {
    let (distance_x = pair[0],
         distance_y = pair[1],
         x =distance_x > 0
         ? (half_of_w - screw_rad - distance_x)
         : distance_x < 0
         ? (-half_of_w + screw_rad - distance_x)
         : 0,
         y = distance_y > 0
         ? (half_of_len - screw_rad - distance_y)
         : distance_y < 0
         ? (half_of_len - screw_rad + distance_y)
         : 0) {
      translate([x, reverse_y ? -y : y, 0]) {
        circle(r=screw_rad, $fn=360);
      }
    }
  }
}

module front_panel_connector() {
  linear_extrude(height=front_panel_thickness, center=false) {
    difference() {
      rounded_rect_two(size = [front_panel_connector_width,
                               front_panel_connector_len],
                       center=true,
                       r=3);
      front_panel_connector_screws();
    }
  }
}

module front_panel(w=front_panel_width,
                   h=front_panel_height,
                   screws_x_offset=front_panel_screws_x_offset,
                   thickness=front_panel_thickness) {
  rotate([90, 180, 0]) {
    difference() {
      linear_extrude(thickness) {
        difference() {
          rounded_rect(size=[w, h], r=h * 0.18, center=true);
          ultrasonic_screws_2d();
        }
      }

      translate([0, -1, 0]) {
        two_x_screws_3d(screws_x_offset, m3_hole_dia);
      }

      translate([0, -2, 0]) {
        ultrasonic_slots();
      }
    }
    translate([0, h / 2 + thickness,
               front_panel_connector_len / 2]) {
      rotate([90, 0, 0]) {
        front_panel_connector();
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
                              thickness=front_panel_rear_panel_thickness) {
  linear_extrude(thickness) {
    difference() {
      rounded_rect(size=[w, h], r=h * 0.18, center=true);
      two_x_screws_2d(screws_x_offset, side_screws_dia);
      translate([0, -h * 0.5 + bottom_cutout_size[1] * 0.5]) {
        square(size = [bottom_cutout_size[0], bottom_cutout_size[1]],
               center=true);
      }
      four_corner_holes_2d(size=screws_square_size,
                           hole_dia=screws_square_dia,
                           center=true);

      ultrasonic_screws_2d();
    }
  }
}

module front_panel_printable() {
  rotate(a = [-90, 0, 0]) {
    translate([front_panel_width * 0.55, 0, 0]) {
      front_panel();
    }
  }
  translate([-front_panel_width * 0.55, 0, 0]) {
    front_panel_back_mount();
  }
}

color("white") {
  front_panel_printable();
}
