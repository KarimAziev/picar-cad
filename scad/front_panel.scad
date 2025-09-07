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
//  - Attachment Hardware: M2.5 screws

include <parameters.scad>
include <colors.scad>
use <util.scad>
use <placeholders/ultrasonic.scad>
use <placeholders/smd_chip.scad>

rear_panel_z = ultrasonic_pin_len_b
  - ultrasonic_thickness
  - ultrasonic_pin_protrusion_h
  + ultrasonic_pin_thickness;

module ultrasonic_sensor_mounts_2d(d=front_panel_ultrasonic_sensor_dia) {
  rad = d / 2;
  x_offset = rad + front_panel_ultrasonic_sensors_offset / 2;

  for (x = [-x_offset, x_offset]) {
    translate([x, front_panel_ultrasonic_y_offset, 0]) {
      circle(r=rad, $fn=100);
    }
  }
}

module ultrasonic_rect_slots_2d(h=front_panel_height,
                                oscilator_w=ultrasonic_oscillator_w + 2,
                                oscilator_h=ultrasonic_oscillator_h + 2,
                                jack_w=ultrasonic_pins_jack_w + 2,
                                jack_h=ultrasonic_pins_jack_h + 2) {

  union() {
    if (oscilator_h > 0 && oscilator_w > 0) {
      translate([0, h / 2 - oscilator_h / 2
                 - ultrasonic_oscillator_y_offset]) {
        rounded_rect([oscilator_w, oscilator_h], center=true,
                     r=min(2,
                           min(oscilator_h, oscilator_w) * 0.3),
                     fn=20);
      }
    }

    if (jack_h > 0 && jack_w > 0) {
      translate([0, -h / 2 + jack_h / 2]) {
        rounded_rect([jack_w, jack_h], center=true,
                     r=min(2,
                           min(jack_h, jack_w) * 0.3), fn=20);
      }
    }
  }
}

module ultrasonic_screws_2d(size=ultrasonic_screw_size,
                            d=ultrasonic_screw_dia) {

  four_corner_holes_2d(size=size, center=true, hole_dia=d);
}

module front_panel_connector_screws(reverse_y = false) {
  half_len = front_panel_connector_len / 2;
  half_w   = front_panel_connector_width / 2;
  screw_r  = front_panel_connector_screw_dia / 2;

  s_x = half_w - screw_r;
  s_y = half_len - screw_r;

  function screw_x(dx) = sign(dx) * s_x - dx;
  function screw_y(dy) = s_y - abs(dy);

  for (off = front_panel_connector_screw_offsets) {
    x = screw_x(off[0]);
    y = screw_y(off[1]);
    translate([x, reverse_y ? -y : y, 0])
      circle(r = screw_r, $fn = 360);
  }
}

module front_panel_connector() {
  linear_extrude(height=front_panel_thickness, center=false) {
    difference() {
      rounded_rect_two(size = [front_panel_connector_width,
                               front_panel_connector_len],
                       center=true,
                       r=front_panel_connector_offset_rad);
      if (front_panel_connector_rect_cutout_size[0] > 0
          && front_panel_connector_rect_cutout_size[1] > 0) {
        translate([0, -front_panel_connector_len / 2 +
                   front_panel_connector_rect_cutout_size[1] / 2
                   + rear_panel_z
                   + front_panel_thickness,
                   0]) {
          square(front_panel_connector_rect_cutout_size, center=true);
        }
      }
      front_panel_connector_screws();
    }
  }
}

module front_panel(w=front_panel_width,
                   h=front_panel_height,
                   screws_x_offset=front_panel_screws_x_offset,
                   thickness=front_panel_thickness) {
  ultrasonic_rect_cutout_w = ultrasonic_w + 1;
  ultrasonic_rect_cutout_h = ultrasonic_h + 1.5;
  rotate([90, 180, 0]) {
    difference() {
      linear_extrude(thickness, convexity=2) {
        difference() {
          rounded_rect(size=[w, h],
                       r=front_panel_offset_rad,
                       center=true);
          translate([0, front_panel_screws_y_offst, 0]) {
            two_x_screws_2d(x=screws_x_offset,
                            d=front_panel_screw_dia);
          }
          translate([0, front_panel_screws_y_offst, 0]) {
            ultrasonic_screws_2d();
          }

          ultrasonic_sensor_mounts_2d();
          ultrasonic_rect_slots_2d(h=ultrasonic_h);
        }
      }

      translate([0, 0,
                 thickness - front_panel_ultrasonic_cutout_depth + 0.1]) {
        linear_extrude(height=front_panel_ultrasonic_cutout_depth,
                       center=false) {
          rounded_rect([ultrasonic_rect_cutout_w,
                        ultrasonic_rect_cutout_h],
                       r=ultrasonic_offset_rad,
                       center=true);
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
    translate([0, h / 2 + thickness - 0.1,
               front_panel_connector_len / 2]) {
      rotate([90, 0, 0]) {
        front_panel_connector();
      }
    }
  }
}

module front_panel_back_mount(h=front_panel_height,
                              w=front_panel_width,
                              screws_x_offset=front_panel_screws_x_offset,
                              thickness=front_panel_rear_panel_thickness) {

  union() {
    linear_extrude(thickness) {
      difference() {
        rounded_rect(size=[w, h],
                     center=true,
                     r=front_panel_offset_rad);
        four_corner_holes_2d(size=ultrasonic_screw_size,
                             hole_dia=ultrasonic_screw_dia + 0.2,
                             center=true);

        ultrasonic_smd_slots(half_of_board_w=ultrasonic_w / 2,
                             length=ultrasonic_smd_len,
                             w=ultrasonic_smd_w,
                             thickness=ultrasonic_smd_h,
                             x_offset=ultrasonic_smd_x_offst) {
          smd_chip_slot_2d(length=ultrasonic_smd_len,
                           total_w=ultrasonic_smd_w,
                           center=true);
        }

        translate([0, -front_panel_screws_y_offst, 0]) {
          two_x_screws_2d(x=screws_x_offset,
                          d=front_panel_screw_dia);
        }
        four_corner_holes_2d(size=ultrasonic_solder_blobs_positions,
                             hole_dia=front_panel_solder_blob_dia,
                             center=true);
        ultrasonic_rect_slots_2d(h=ultrasonic_h,
                                 jack_w=ultrasonic_pins_jack_w + 2,
                                 jack_h=0,
                                 oscilator_h=ultrasonic_oscillator_h,
                                 oscilator_w=ultrasonic_oscillator_w);
        pw = ultrasonic_pins_jack_w + 2;
        ph = h - ultrasonic_h + ultrasonic_pins_jack_h;

        translate([0, -h / 2 + ph / 2]) {
          square([pw, ph], center=true);
        }
      }
    }
    translate([0, 0, thickness]) {
      linear_extrude(height=rear_panel_z
                     + front_panel_thickness / 2
                     - front_panel_ultrasonic_cutout_depth,
                     center=false,
                     convexity=2) {
        mirror_copy([1, 0, 0]) {
          translate([screws_x_offset,
                     -front_panel_screws_y_offst, 0]) {
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
  rotate([-90, 0, 0]) {
    front_panel();
  }
  translate([0, front_panel_height + spacing, 0]) {
    front_panel_back_mount();
  }
}

module front_panel_assembly(panel_color="white",
                            show_front_panel=true,
                            show_ultrasonic=true,
                            show_front_rear_panel=true) {
  ultrasonic_x = 0;

  ultrasonic_y = 0;
  ultrasonic_z = front_panel_thickness
    + ultrasonic_thickness;
  if (show_front_panel) {
    rotate([-90, 0, 0]) {
      color(panel_color, alpha=1) {
        front_panel();
      }
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

// front_panel_assembly(show_ultrasonic=true,
//                      show_front_rear_panel=true,
//                      show_front_panel=true);
