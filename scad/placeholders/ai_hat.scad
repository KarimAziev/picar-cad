/**
 * Module: Placeholder for AI HAT+
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

module ai_hat(center=true, show_pins=true, show_standoff=true) {
  w = ai_hat_size[0];
  l = ai_hat_size[1];
  h = ai_hat_size[2];
  max_hole_pad_spec = max([for (n = ai_hat_mounting_hole_pad_spec) n[0]]);

  translate([center ? 0 : w / 2, center ? 0 : l / 2, 0]) {
    union() {
      color(green_4, alpha=1) {
        linear_extrude(height=h, center=false) {
          difference() {
            translate([-w / 2, -l / 2, 0]) {
              difference() {
                rounded_rect([w, l], r=ai_hat_corner_rad, center=false);
                translate([rpi_csi_position_x,
                           rpi_csi_position_y - max_hole_pad_spec
                           - max_hole_pad_spec / 2,
                           0]) {
                  rounded_rect(ai_hat_csi_slot_size,
                               r=ai_hat_csi_cutout_corner_r,
                               center=false);
                }
              }
            }
            translate([0, -l / 2 + ai_hat_front_cutout_size[1] / 2, 0]) {
              rounded_rect_two(size=ai_hat_front_cutout_size, center=true);
            }
            four_corner_holes_2d(rpi_screws_size, center=true);
          }
        }
      }
      translate([-w / 2, -l / 2 + rpi_screws_offset * 2, 0]) {
        translate([0, 0, h]) {
          pin_headers(cols=rpi_pin_headers_cols,
                      rows=rpi_pin_headers_rows,
                      header_width=rpi_pin_header_width,
                      header_height=rpi_pin_header_height,
                      pin_height=0,
                      z_offset=rpi_thickness / 2 + 0.5,
                      p=0.65,
                      center=false);
        }
        if (show_pins) {
          translate([0, 0, - ai_hat_header_height]) {
            pin_headers(cols=rpi_pin_headers_cols,
                        rows=rpi_pin_headers_rows,
                        header_width=rpi_pin_header_width,
                        header_height=ai_hat_header_height,
                        pin_height=ai_hat_pin_height,
                        z_offset=-ai_hat_header_height,
                        p=0.65,
                        center=false);
          }
        }
      }

      if (show_standoff) {
        translate([0, 0, -ai_hat_header_height]) {
          four_corner_children(rpi_screws_size) {
            standoff(body_d=ai_hat_screw_dia, thread_d=ai_hat_screw_dia / 2,
                     body_h=ai_hat_header_height);
          }
        }
      }

      translate([0, 0, h]) {
        rotate([0, 0, 180]) {
          bcm_processor(size=ai_hat_processor_size,
                        center=true,
                        scale_both_sides=true,
                        txt=ai_hat_processor_text,
                        txt_color=metallic_silver_1);
        }
      }
      four_corner_children(rpi_screws_size) {
        pad_hole(specs=ai_hat_mounting_hole_pad_spec,
                 thickness=h,
                 screw_d=ai_hat_screw_dia);
      }
    }
  }
}

ai_hat(center=false);