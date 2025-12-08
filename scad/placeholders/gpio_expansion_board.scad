/**
 * Module: GPIO Expansion Board
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
use <../lib/shapes3d.scad>

module gpio_expansion_board(show_standoff=true,
                            center=true,
                            extra_standoff_h=0) {
  w = gpio_expansion_size[0];
  l = gpio_expansion_size[1];
  h = gpio_expansion_size[2];

  translate([center ? 0 : w / 2, center ? 0 : l / 2, 0]) {
    union() {
      color(medium_blue_1, alpha=1) {
        linear_extrude(height=h, center=false) {
          difference() {
            rounded_rect(size=[gpio_expansion_size[0],
                               gpio_expansion_size[1]],

                         r=gpio_expansion_corner_rad,
                         center=true);
            four_corner_holes_2d(size=rpi_screws_size, center=true);
            four_corner_holes_2d(size=gpio_expansion_screws_size_2, center=true);
          }
        }
      }
      four_corner_children(size=rpi_screws_size) {
        pad_hole(specs=gpio_expansion_mounting_hole_pad_spec,
                 thickness=h,
                 screw_d=gpio_expansion_screw_dia);
      }
      four_corner_children(size=gpio_expansion_screws_size_2) {
        pad_hole(specs=gpio_expansion_mounting_hole_pad_spec,
                 thickness=h,
                 screw_d=gpio_expansion_screw_dia);
      }

      translate([-w / 2 + rpi_pin_header_width,
                 -l / 2
                 + rpi_pin_header_width
                 * rpi_pin_headers_cols / 2
                 + rpi_screws_offset * 2,
                 -gpio_expansion_header_height]) {
        union() {
          pin_headers(cols=rpi_pin_headers_cols,
                      rows=rpi_pin_headers_rows,
                      header_width=rpi_pin_header_width,
                      header_height=gpio_expansion_header_height,
                      pin_height=gpio_expansion_pin_height,
                      z_offset=-gpio_expansion_header_height,
                      p=0.65,
                      center=true);
        }
      }
      translate([-w / 2 + rpi_pin_header_width * 4,
                 -l / 2
                 + rpi_pin_header_width
                 * rpi_pin_headers_cols / 2
                 + rpi_screws_offset * 2,
                 h]) {
        union() {
          pin_headers(cols=rpi_pin_headers_cols,
                      rows=rpi_pin_headers_rows,
                      header_width=rpi_pin_header_width,
                      header_height=0,
                      pin_height=gpio_expansion_pin_height,
                      z_offset=0,
                      p=0.65,
                      center=true);
          let (total_x = rpi_pin_header_width * rpi_pin_headers_rows,
               total_y = rpi_pin_header_width * rpi_pin_headers_cols) {
            pin_headers(cols=rpi_pin_headers_cols,
                        rows=rpi_pin_headers_rows,
                        header_width=rpi_pin_header_width,
                        header_height=0,
                        pin_height=gpio_expansion_pin_up_height,
                        z_offset=0,
                        p=0.65,
                        center=true);
            translate([0, 0, 0]) {
              color(yellow_1, alpha=1) {
                cube_3d([total_x, total_y, gpio_expansion_header_up_height]);
              }
            }
          }
        }
      }
      let (step = gpio_expansion_inner_header_gap +
           gpio_expansion_inner_header_rows * rpi_pin_header_width,
           total_y = step * (gpio_expansion_inner_headers_count - 1),) {
        translate([0, -total_y / 2, 0]) {
          for (i = [0 : gpio_expansion_inner_headers_count - 1]) {
            let (y = i * step,
                 total_x = rpi_pin_header_width * gpio_expansion_inner_header_rows,
                 total_y = rpi_pin_header_width * gpio_expansion_inner_header_cols) {
              translate([0, y, 0]) {
                rotate([0, 0, 90]) {
                  translate([0, 0, h]) {
                    pin_headers(cols=gpio_expansion_inner_header_cols,
                                rows=gpio_expansion_inner_header_rows,
                                header_width=rpi_pin_header_width,
                                header_height=0,
                                pin_height=gpio_expansion_inner_header_pin_height,
                                z_offset=0,
                                p=0.65,
                                center=true);
                    color(yellow_1, alpha=1) {
                      cube_3d([total_x, total_y, gpio_expansion_header_up_height]);
                    }
                  }
                }
              }
            }
          }
        }
      }

      mirror_copy([0, 1, 0]) {
        translate([gpio_expansion_screw_terminal_x_offset,
                   -l / 2
                   + gpio_expansion_screw_terminal_thickness / 2,
                   h]) {
          rotate([0, 0, 180]) {
            screw_terminal(thickness=gpio_expansion_screw_terminal_thickness,
                           base_h=gpio_expansion_screw_terminal_base_h,
                           top_l=gpio_expansion_screw_terminal_top_l,
                           top_h=gpio_expansion_screw_terminal_top_h,
                           contacts_n=gpio_expansion_screw_terminal_contacts_n,
                           contact_w=gpio_expansion_screw_terminal_contact_w,
                           contact_h=gpio_expansion_screw_terminal_contact_h,
                           pitch=gpio_expansion_screw_terminal_pitch,
                           colr=metallic_silver_1);
          }
        }
      }

      translate([w / 2 - gpio_expansion_screw_terminal_thickness / 2,
                 0,
                 h]) {
        rotate([0, 0, -90]) {
          screw_terminal(thickness=gpio_expansion_screw_terminal_thickness,
                         base_h=gpio_expansion_screw_terminal_base_h,
                         top_l=gpio_expansion_screw_terminal_top_l,
                         top_h=gpio_expansion_screw_terminal_top_h,
                         contacts_n=gpio_expansion_screw_terminal_contacts_n,
                         contact_w=gpio_expansion_screw_terminal_contact_w,
                         contact_h=gpio_expansion_screw_terminal_contact_h,
                         pitch=gpio_expansion_screw_terminal_pitch,
                         colr=metallic_silver_1);
        }
      }

      if (show_standoff) {
        translate([0, 0, -gpio_expansion_header_height - extra_standoff_h]) {
          four_corner_children(rpi_screws_size) {
            standoff(body_d=gpio_expansion_screw_dia, thread_d=gpio_expansion_screw_dia / 2,
                     body_h=gpio_expansion_header_height + extra_standoff_h);
          }
        }
      }
    }
  }
}

gpio_expansion_board();
