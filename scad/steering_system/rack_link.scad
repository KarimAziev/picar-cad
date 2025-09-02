/**
 * Module: Rack link
 *
 * The rack link is an L-shaped "arm." One side has a hole for a 685-Z bearing,
 * and the other side is a shaft for the bearing. The side with the hole (into
 * which the bearing is pressed) connects to the rack, the other side (with the
 * shaft) connects to one of the knuckles.
 *
 * IMPORTANT: install only one rack link and only on **one** of the knuckles - it
 * doesn't matter which one, but only one. Movement of the rack will cause that
 * "leading" knuckle to rotate, the "leading" knuckle is then connected to the
 * second, "driven" knuckle via a tie rod, which is required for Ackermann
 * geometry.
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

module rack_link(a_len=steering_rack_link_rack_side_w_length,
                 b_len=steering_rack_link_rack_side_h_length,
                 w=steering_rack_link_linkage_width,
                 thickness=steering_rack_link_linkage_thickness,
                 connector_d=steering_rack_link_bearing_outer_d,
                 show_bearing=false,
                 bearing_flanged_h=steering_rack_link_bearing_flanged_height,
                 bearing_flanged_w=steering_breacket_bearing_flanged_width,
                 bearing_shaft_d = round(steering_rack_link_bearing_shaft_d),
                 bearing_h=steering_rack_link_bearing_height,
                 bracket_color="white",
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
              bearing_upper_connector(h=steering_rack_link_bearing_bearing_pin_base_h);
            }

            if (show_bearing) {
              translate([0, 0, bearing_flanged_h]) {
                bearing(d=steering_rack_link_bearing_d,
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

module rack_links_printable() {
  union() {
    rotate([0, 0, 180]) {
      rack_link();
      translate([steering_rack_link_rack_side_w_length
                 + steering_rack_link_bearing_outer_d
                 + 5, 0, 0]) {
        mirror([1, 0, 0]) {
          rack_link();
        }
      }
    }
  }
}

// steering_rack_links_printable();

rack_link();