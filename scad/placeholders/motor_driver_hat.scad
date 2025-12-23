/**
 * Module: Placeholder for RPi Motor Driver Board
 * (https://www.waveshare.com/rpi-motor-driver-board.htm)
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
use <../lib/shapes3d.scad>
use <bcm.scad>
use <pad_hole.scad>
use <../lib/placement.scad>
use <standoff.scad>
use <screw_terminal.scad>
use <smd_chip.scad>

module motor_driver_chip() {
  smd_chip(length=motor_driver_hat_chip_len,
           w=motor_driver_hat_chip_w,
           j_lead_n=motor_driver_hat_chip_j_lead_n,
           j_lead_thickness=motor_driver_hat_chip_j_lead_thickness,
           total_w=motor_driver_hat_chip_total_w,
           h=motor_driver_hat_chip_h,
           smd_color=black_1,
           center=true);
}

module motor_driver_voltage_level_conversion_chip() {
  smd_chip(length=motor_driver_hat_voltage_chip_len,
           w=motor_driver_hat_voltage_chip_w,
           j_lead_n=motor_driver_hat_voltage_chip_j_lead_n,
           j_lead_thickness=motor_driver_hat_voltage_chip_j_lead_thickness,
           total_w=motor_driver_hat_voltage_chip_total_w,
           h=motor_driver_hat_voltage_chip_h,
           smd_color=black_1,
           center=true);
}

module motor_driver_hat_capacitor(d=7, h=2.58, cyl_h=6.85) {
  let (chamfer=d / 6,
       cube_y=d - chamfer * 2,
       cyl_cutout_w = d * 0.9) {
    union() {
      color(matte_black, alpha=1) {
        linear_extrude(height=h, center=false) {
          chamfered_square(size=d, chamfer=chamfer);
        }
        translate([-d / 2, -cube_y / 2 + chamfer, 0]) {
          cube([d, cube_y, h]);
        }
      }
      color(metallic_silver_1, alpha=1) {
        cylinder(h=cyl_h - 0.01, d=d, $fn=80);
      }
      color(matte_black) {
        translate([0, 0, cyl_h - 1]) {
          difference() {
            cylinder(h=1, d=d - 0.1, $fn=80);
            notched_circle(h=1 + 0.1, d=d + 0.1,
                           x_cutouts_n=0,
                           y_cutouts_n=1,
                           cutout_w=cyl_cutout_w);
          }
        }
      }
    }
  }
}

module motor_driver_hat(center=true, show_pins=true,
                        extra_standoff_h=0,
                        show_standoff=true) {
  w = motor_driver_hat_size[0];
  l = motor_driver_hat_size[1];
  h = motor_driver_hat_size[2];

  translate([center ? 0 : w / 2, center ? 0 : l / 2, 0]) {
    union() {
      color(medium_blue_1, alpha=1) {
        linear_extrude(height=h, center=false) {
          difference() {
            translate([-w / 2, -l / 2, 0]) {
              rounded_rect([w, l], r=motor_driver_hat_corner_rad, center=false);
            }

            four_corner_holes_2d(rpi_screws_size, center=true);
          }
        }
      }
      translate([-w / 2 + rpi_pin_header_width,
                 -l / 2
                 + rpi_pin_header_width
                 * rpi_pin_headers_cols / 2
                 + rpi_screws_offset * 2,
                 -motor_driver_hat_header_height]) {
        pin_headers(cols=rpi_pin_headers_cols,
                    rows=rpi_pin_headers_rows,
                    header_width=rpi_pin_header_width,
                    header_height=motor_driver_hat_header_height,
                    pin_height=motor_driver_hat_pin_height,
                    z_offset=-motor_driver_hat_header_height,
                    p=0.65,
                    center=true);
      }

      mirror_copy([1, 0, 0]) {
        translate([motor_driver_hat_chip_total_w / 2
                   + motor_driver_hat_chip_distance_between,
                   -l / 2 + motor_driver_hat_chip_len / 2
                   + motor_driver_hat_chip_y_distance,
                   h]) {
          rotate([0, 0, 90]) {
            motor_driver_chip();
          }
        }
      }

      translate([-w / 2 + motor_driver_hat_voltage_chip_total_w / 2
                 + motor_driver_hat_voltage_chip_x_distance,
                 l / 2
                 - motor_driver_hat_voltage_chip_len / 2
                 - motor_driver_hat_voltage_chip_y_distance,
                 h]) {
        rotate([0, 0, 90]) {
          motor_driver_voltage_level_conversion_chip();
        }
      }

      translate([-w / 2, -l / 2 + rpi_screws_offset * 2, 0]) {
        if (show_pins) {
          translate([0, 0, h]) {
            pin_headers(cols=rpi_pin_headers_cols,
                        rows=rpi_pin_headers_rows,
                        header_width=rpi_pin_header_width,
                        header_height=motor_driver_hat_upper_header_height,
                        pin_height=motor_driver_hat_upper_pin_height,
                        z_offset=-motor_driver_hat_upper_header_height,
                        p=0.65,
                        center=false);
          }
        }
      }

      translate([motor_driver_hat_capacitor_x_offset,
                 l / 2
                 - motor_driver_hat_capacitor_d / 2
                 - motor_driver_hat_capacitor_y_offset, h]) {
        motor_driver_hat_capacitor(h=motor_driver_hat_capacitor_h,
                                   d=motor_driver_hat_capacitor_d,
                                   cyl_h=motor_driver_hat_capacitor_cyl_h,);
      }

      for (params = motor_driver_hat_extra_capacitors) {
        let (d = params[0],
             h = params[1],
             cyl_d = params[2],
             x_offset = params[3],
             y_offset = params[4],) {
          translate([x_offset, y_offset, 0]) {
            motor_driver_hat_capacitor(h=h,
                                       d=d,
                                       cyl_h=cyl_d,);
          }
        }
      }

      translate([0,
                 -l / 2
                 + motor_driver_hat_screw_terminal_thickness / 2
                 + motor_driver_hat_screw_terminal_distance,
                 h]) {
        rotate([0, 0, 180]) {
          screw_terminal(thickness=motor_driver_hat_screw_terminal_thickness,
                         base_h=motor_driver_hat_screw_terminal_base_h,
                         top_h=motor_driver_hat_screw_terminal_top_h,
                         top_l=motor_driver_hat_screw_terminal_top_l,
                         contacts_n=motor_driver_hat_screw_terminal_contacts_n,
                         contact_w=motor_driver_hat_screw_terminal_contact_w,
                         contact_h=motor_driver_hat_screw_terminal_contact_h,
                         pitch=motor_driver_hat_screw_terminal_pitch);
        }
      }

      if (show_standoff) {
        translate([0, 0, -motor_driver_hat_header_height - extra_standoff_h]) {
          four_corner_children(rpi_screws_size) {
            standoffs_stack(d=motor_driver_hat_screw_dia,
                            colr=motor_driver_hat_standoff_color,
                            min_h=motor_driver_hat_header_height
                            + extra_standoff_h);
          }
        }
      }

      four_corner_children(rpi_screws_size) {
        pad_hole(specs=motor_driver_hat_mounting_hole_pad_spec,
                 thickness=h,
                 screw_d=motor_driver_hat_screw_dia);
      }
    }
  }
}

motor_driver_hat(center=false);
