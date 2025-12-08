/**
 * Module: Placeholder for Servo Driver HAT
 * (https://www.waveshare.com/wiki/Servo_Driver_HAT)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
include <../colors.scad>

use <../lib/shapes2d.scad>
use <../lib/holes.scad>
use <../lib/transforms.scad>
use <pin_headers.scad>
use <screw_terminal.scad>
use <pad_hole.scad>
use <../lib/placement.scad>
use <standoff.scad>

module servo_driver_hat(show_standoff=true, center=true) {
  w = servo_driver_hat_size[0];
  l = servo_driver_hat_size[1];
  h = servo_driver_hat_size[2];

  translate([center ? 0 : w / 2, center ? 0 : l / 2, 0]) {
    union() {
      color(medium_blue_1, alpha=1) {
        linear_extrude(height=h, center=false) {
          difference() {
            rounded_rect(size=[servo_driver_hat_size[0],
                               servo_driver_hat_size[1]],
                         r=servo_driver_corner_rad,
                         center=true);
            four_corner_holes_2d(size=servo_driver_hat_screws_size, center=true);
          }
        }
      }
      four_corner_children(size=servo_driver_hat_screws_size) {
        pad_hole(specs=servo_driver_hat_mounting_hole_pad_spec,
                 thickness=h,
                 screw_d=servo_driver_hat_screw_dia);
      }

      translate([-w / 2 + rpi_pin_header_width,
                 -l / 2
                 + rpi_pin_header_width
                 * rpi_pin_headers_cols / 2
                 + rpi_screws_offset * 2,
                 -servo_driver_hat_header_height]) {
        pin_headers(cols=rpi_pin_headers_cols,
                    rows=rpi_pin_headers_rows,
                    header_width=rpi_pin_header_width,
                    header_height=servo_driver_hat_header_height,
                    pin_height=servo_driver_hat_pin_height,
                    z_offset=-servo_driver_hat_header_height,
                    p=0.65,
                    center=true);
      }
      translate([0,
                 -l / 2
                 + servo_driver_hat_screw_terminal_thickness / 2,
                 h]) {
        rotate([0, 0, 180]) {
          screw_terminal(thickness=servo_driver_hat_screw_terminal_thickness,
                         base_h=servo_driver_hat_screw_terminal_base_h,
                         top_l=servo_driver_hat_screw_terminal_top_l,
                         top_h=servo_driver_hat_screw_terminal_top_h,
                         contacts_n=servo_driver_hat_screw_terminal_contacts_n,
                         contact_w=servo_driver_hat_screw_terminal_contact_w,
                         contact_h=servo_driver_hat_screw_terminal_contact_h,
                         pitch=servo_driver_hat_screw_terminal_pitch,
                         colr="green");
        }
      }
      let (step = servo_driver_hat_side_pins_headers_margin
           + servo_driver_hat_side_pin_cols * rpi_pin_header_width,
           total_y = step * (servo_driver_hat_side_pins_headers_count - 1),
           z_offset=servo_driver_hat_side_pin_height / 2
           - servo_driver_hat_side_header_height / 2) {
        translate([w / 2 - servo_driver_hat_side_header_height,
                   -total_y / 2,
                   h + (servo_driver_hat_side_pin_rows * rpi_pin_header_width) / 2]) {
          for (i = [0 : servo_driver_hat_side_pins_headers_count - 1]) {
            let (y = step * i) {
              translate([0, y, 0]) {
                rotate([0, 90, 0]) {
                  pin_headers(cols=servo_driver_hat_side_pin_cols,
                              rows=servo_driver_hat_side_pin_rows,
                              header_width=rpi_pin_header_width,
                              header_height=servo_driver_hat_side_header_height,
                              pin_height=servo_driver_hat_side_pin_height,
                              z_offset=z_offset,
                              p=0.65,
                              center=true);
                }
              }
            }
          }
        }
      }
      if (show_standoff) {
        translate([0, 0, -servo_driver_hat_header_height]) {
          four_corner_children(servo_driver_hat_screws_size) {
            standoff(body_d=servo_driver_hat_screw_dia,
                     thread_d=servo_driver_hat_screw_dia / 2,
                     body_h=servo_driver_hat_header_height);
          }
        }
      }
    }
  }
}

servo_driver_hat();
