/**
 * Module: Placeholder for RPi Motor Driver Board
 * (https://www.waveshare.com/rpi-motor-driver-board.htm)
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../core/pcb_grid.scad>
use <../lib/holes.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>
use <pad_hole.scad>
use <pin_header.scad>
use <standoff.scad>

module motor_driver_hat(plist=motor_driver_grid,
                        show_upper_pin_header=true,
                        show_lower_pin_header=true,
                        extra_standoff_h=0,
                        show_standoff=true,
                        center=true,
                        debug=false,
                        debug_spec=["border_h", motor_driver_hat_size[2]]) {
  w = motor_driver_hat_size[0];
  l = motor_driver_hat_size[1];
  h = motor_driver_hat_size[2];
  max_pad_hole = len(motor_driver_hat_mounting_hole_pad_spec) > 0
    ? max([for (v = motor_driver_hat_mounting_hole_pad_spec) v[0]])
    : motor_driver_hat_bolt_dia;

  translate([center ? -w / 2 : 0, center ? l / 2 : l, 0]) {
    union() {
      translate([w / 2, -l / 2, 0]) {
        union() {
          color(medium_blue_1, alpha=1) {
            linear_extrude(height=h, center=false) {
              difference() {
                translate([-w / 2, -l / 2, 0]) {
                  rounded_rect([w, l],
                               r=motor_driver_hat_corner_rad,
                               center=false);
                }

                four_corner_holes_2d(rpi_bolt_spacing, center=true);
              }
            }
          }

          if (show_upper_pin_header || show_lower_pin_header) {
            translate([-w / 2, -l / 2 + rpi_bolts_offset * 2, 0]) {
              if (show_upper_pin_header) {
                translate([0, 0, h]) {
                  pin_header(cols=rpi_pin_headers_cols,
                             rows=rpi_pin_headers_rows,
                             header_width=rpi_pin_header_width,
                             header_height=motor_driver_hat_upper_header_height,
                             pin_height=motor_driver_hat_upper_pin_height,
                             z_offset=-motor_driver_hat_upper_header_height,
                             p=0.65,
                             center=false);
                }
              }

              if (show_lower_pin_header) {
                translate([0, 0, -motor_driver_hat_lower_header_height]) {
                  pin_header(cols=rpi_pin_headers_cols,
                             rows=rpi_pin_headers_rows,
                             header_width=rpi_pin_header_width,
                             header_height=motor_driver_hat_lower_header_height,
                             pin_height=motor_driver_hat_lower_header_pin_height,
                             z_offset=-motor_driver_hat_lower_header_height,
                             p=0.65,
                             center=false);
                }
              }
            }
          }

          if (show_standoff) {
            translate([0,
                       0,
                       -motor_driver_hat_lower_header_height - extra_standoff_h]) {
              four_corner_children(rpi_bolt_spacing) {
                standoffs_stack(d=motor_driver_hat_bolt_dia,
                                colr=motor_driver_hat_standoff_color,
                                min_h=motor_driver_hat_lower_header_height
                                + extra_standoff_h);
              }
            }
          }

          four_corner_children(rpi_bolt_spacing) {
            pad_hole(specs=motor_driver_hat_mounting_hole_pad_spec,
                     thickness=h,
                     bolt_d=motor_driver_hat_bolt_dia);
          }
        }
      }

      translate([max_pad_hole, 0, 0]) {
        pcb_grid(plist,
                 debug=debug,
                 mode="placeholder",
                 debug_spec=debug_spec);
      }
    }
  }
}

motor_driver_hat(center=false, debug=false);
