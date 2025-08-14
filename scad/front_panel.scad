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
include <colors.scad>
use <util.scad>
use <placeholders/ultrasonic.scad>

front_panel_connector_offset_rad  = 3;
front_panel_ultrasonic_y_offset   = -1.9;
front_panel_screws_y_offst        = -1;
front_panel_screw_dia             = m3_hole_dia;
front_panel_offset_rad            = front_panel_height * 0.18;

front_panel_rear_panel_cutout_w   = ultrasonic_pins_jack_w + 4;

// list of [translate_values, square_size, offset_radius, offset_resolution]
front_panel_oscilator_slot_h      = ultrasonic_oscillator_h + 1.4;
front_panel_oscilator_slot_w      = ultrasonic_oscillator_w + 2;
front_panel_rear_panel_ring_width = 2;
front_panel_rect_slots            = [[[0, -8.8 +
                                       front_panel_ultrasonic_y_offset, 0],
                                      [13, 4], 1, 20],
                                     [[0, front_panel_height / 2
                                       - front_panel_oscilator_slot_h / 2
                                       - ultrasonic_oscillator_y_offset
                                       + front_panel_ultrasonic_y_offset
                                       - 2.5
                                       , 0], [ultrasonic_oscillator_w + 2,
                                              front_panel_oscilator_slot_h],
                                      1, 20]];

rear_panel_z                      = ultrasonic_pin_len_b
  - ultrasonic_thickness
  - ultrasonic_pin_protrusion_h
  + ultrasonic_pin_thickness;

module ultrasonic_sensor_mounts_2d(d=front_panel_ultrasonic_sensor_dia,
                                   distance=front_panel_ultrasonic_sensors_offset) {
  rad = d / 2;
  x_offset = rad + distance / 2;

  for (x = [-x_offset, x_offset]) {
    translate([x, front_panel_ultrasonic_y_offset, 0]) {
      circle(r=rad, $fn=100);
    }
  }
}

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

module ultrasonic_rect_slots_2d() {
  union() {
    for (spec = front_panel_rect_slots) {
      let (offst = spec[0],
           size = spec[1],
           rad = spec[2],
           fn = spec[3]) {
        translate(offst) {
          rounded_rect(size, center=true, r=rad, fn=fn);
        }
      }
    }
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
  }
}

module ultrasonic_screws_2d(size=ultrasonic_screw_size,
                            d=m1_hole_dia) {
  y_offsets = number_sequence(from = 0, to = 4, step = d + 0.4);
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
                       r=front_panel_connector_offset_rad);
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
      linear_extrude(thickness, convexity=2) {
        difference() {
          rounded_rect(size=[w, h],
                       r=front_panel_offset_rad,
                       center=true);
          ultrasonic_screws_2d();
          translate([0, front_panel_screws_y_offst, 0]) {
            two_x_screws_2d(x=screws_x_offset,
                            d=front_panel_screw_dia);
          }
          ultrasonic_sensor_mounts_2d();
          ultrasonic_rect_slots_2d();
        }
      }
      translate([0, 0, thickness / 2]) {
        linear_extrude(height=rear_panel_z, center=false) {
          mirror_copy([1, 0, 0]) {
            translate([screws_x_offset, front_panel_screws_y_offst, 0]) {
              circle(r=front_panel_screw_dia / 2
                     + front_panel_rear_panel_ring_width + 0.4,
                     $fn=100);
            }
          }
        }
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
                              h=ultrasonic_h,
                              screws_x_offset=front_panel_screws_x_offset,
                              bottom_cutout_size=
                              [front_panel_rear_panel_cutout_w,
                               ultrasonic_pins_jack_h
                               + 2.5],
                              thickness=front_panel_rear_panel_thickness) {
  union() {
    linear_extrude(thickness) {
      difference() {
        rounded_rect(size=[w, ultrasonic_h],
                     center=true,
                     r=front_panel_offset_rad);
        four_corner_holes_2d(size=ultrasonic_screw_size,
                             hole_dia=ultrasonic_screw_dia + 0.2,
                             center=true);

        ultrasonic_smd_chips(use_2d=true,
                             half_of_board_w = ultrasonic_w / 2,
                             length=ultrasonic_smd_len + 1.5,
                             h=ultrasonic_smd_h + 2.0,
                             thickness=ultrasonic_smd_thickness);
        translate([0, -front_panel_screws_y_offst, 0]) {
          two_x_screws_2d(x=screws_x_offset,
                          d=front_panel_screw_dia);
        }
        translate([0, -h * 0.5 + bottom_cutout_size[1] * 0.5]) {
          square(size = [bottom_cutout_size[0], bottom_cutout_size[1]],
                 center=true);
        }
      }
    }
    translate([0, 0, thickness]) {
      linear_extrude(height=rear_panel_z + front_panel_thickness / 2,
                     center=false,
                     convexity=2) {
        mirror_copy([1, 0, 0]) {
          translate([screws_x_offset, -front_panel_screws_y_offst, 0]) {
            ring_2d(r=front_panel_screw_dia / 2,
                    fn=100,
                    w=front_panel_rear_panel_ring_width,
                    outer=true);
          }
        }
      }
    }
  }
}

module front_panel_printable(spacing=2) {
  half_of_len = front_panel_width * 0.50;
  rotate([-90, 0, 0]) {
    translate([half_of_len + spacing, 0, 0]) {
      front_panel();
    }
  }
  translate([-half_of_len - spacing, 0, 0]) {
    front_panel_back_mount();
  }
}

module front_panel_assembly(panel_color="white",
                            show_ultrasonic=true,
                            show_front_rear_panel=true) {
  ultrasonic_x = 0;
  ultrasonic_y = (front_panel_height / 2 + ultrasonic_h / 2) - ultrasonic_h
    + front_panel_ultrasonic_y_offset;

  ultrasonic_z = front_panel_thickness
    + ultrasonic_thickness;
  rotate([-90, 0, 0]) {
    color(panel_color, alpha=1) {
      front_panel();
    }
  }
  if (show_ultrasonic) {
    translate([ultrasonic_x,
               ultrasonic_y,
               ultrasonic_z]) {
      rotate([180, 0, 0]) {
        ultrasonic();
      }
    }
  }
  if (show_front_rear_panel) {
    translate([0, ultrasonic_y,
               front_panel_thickness
               + ultrasonic_thickness
               + rear_panel_z]) {
      rotate([180, 0, 0]) {
        color(panel_color, alpha=1) {
          front_panel_back_mount();
        }
      }
    }
  }
}

color("white") {
  front_panel_printable();
}
// front_panel_back_mount();

// front_panel_assembly(show_ultrasonic=true);
