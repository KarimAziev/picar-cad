/**
 * Module: Bracket
 *
 * This module defines an L-shaped bracket used in the steering linkage system.
 * The bracket connects the rack (via a flanged bearing interface) to the
 * steering knuckles, forming a critical joint for steering motion transfer.
 *
 * STRUCTURE OVERVIEW:
 * - Shape:
 *     L-shaped profile, consisting of two arms of configurable lengths (a_len and b_len),
 *     connected at a right angle and extruded to a specified thickness.
 *
 * - Purpose:
 *     The horizontal section attaches to the rack using a flanged 685-Z bearing seated
 *     in a circular connector. The vertical arm then links to the steering knuckle
 *     through a similarly connected bearing pin via the knuckle bracket.
 *
 * - Bearing Support:
 *     Optional rendering of a representation of the bearing (toggle with `show_bearing`).
 *     This helps visualize alignment with both rack and knuckle interfaces.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <../placeholders/bearing.scad>
use <rack_connector.scad>
use <bearing_shaft.scad>
use <bearing_connector.scad>

module bracket(a_len=steering_bracket_rack_side_w_length,
               b_len=steering_bracket_rack_side_h_length,
               w=steering_bracket_linkage_width,
               thickness=steering_bracket_linkage_thickness,
               connector_d=steering_bracket_bearing_outer_d,
               show_bearing=false,
               bearing_flanged_h=steering_bracket_bearing_flanged_height,
               bearing_flanged_w=steering_breacket_bearing_flanged_width,
               bearing_shaft_d = round(steering_bracket_bearing_shaft_d),
               bearing_h=steering_bracket_bearing_height,
               bracket_color=blue_grey_carbon,
               show_text=false) {

  a_full_len = a_len + w;

  notch_w = calc_notch_width(connector_d, w);

  translate([0, 0, thickness / 2]) {
    union() {
      color(bracket_color) {
        difference() {
          union() {
            linear_extrude(height=thickness,
                           center=true) {
              translate([-notch_w / 2, 0, 0]) {
                rounded_rect([a_full_len + notch_w, w],
                             center=true,
                             fn=360,
                             r=0.4);
              }
            }

            translate([-a_full_len / 2 - connector_d / 2, 0, -thickness / 2]) {
              bearing_lower_connector();
            }
          }
        }
      }
      if (show_text) {
        color("white") {
          linear_extrude(height=thickness + 2, center=true) {
            translate([-notch_w / 2, 0, 0]) {
              text(str("D: ", a_len),
                   size=4, halign="center",
                   valign="center",
                   font = "Liberation Sans:style=Bold Italic");
            }
          }
        }
      }

      union() {
        x_offst = a_full_len / 2 - w / 2;
        color(bracket_color) {
          linear_extrude(height=thickness, center=true) {

            translate([x_offst, b_len / 2, 0]) {
              square([w, b_len + notch_w], center=true);
            }
          }
        }
        if (show_text) {
          color("white") {
            translate([0, 0, 5]) {
              linear_extrude(height=thickness, center=true) {
                translate([x_offst, b_len / 2, 0]) {
                  text(str("C: ", b_len),
                       size=4,
                       valign="bottom",
                       font = "Liberation Sans:style=Bold Italic");
                }
              }
            }
          }
        }

        translate([x_offst, b_len + connector_d / 2, -thickness / 2]) {
          union() {
            color(bracket_color, alpha=0.6) {
              bearing_upper_connector(h=steering_bracket_bearing_bearing_pin_base_h);
            }

            if (show_bearing) {
              translate([0, 0, bearing_flanged_h]) {
                bearing(d=steering_bracket_bearing_d,
                        h=bearing_h,
                        flanged_w=bearing_flanged_w,
                        flanged_h=bearing_flanged_h,
                        shaft_d=bearing_shaft_d,
                        shaft_ring_w=1,
                        outer_ring_w=0.5,
                        outer_col=metalic_silver_3,
                        rings=[[1, metalic_yellow_silver]]);
              }
            }
          }
        }
      }
    }
  }
}

union() {
  rotate([0, 0, 180]) {
    bracket();
    translate([steering_bracket_rack_side_w_length + steering_bracket_bearing_outer_d
               + 5, 0, 0]) {
      mirror([1, 0, 0]) {
        bracket();
      }
    }
  }
}