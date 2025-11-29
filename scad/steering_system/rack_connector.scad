/**
 * Module: Rack Connector
 *
 * The rack connector forms the interface at each end of the steering rack,
 * where it attaches to L-shaped rack link holding flanged bearing.
 *
 * IMPORTANT: connect only one rack link and only on **one** of the knuckles - it
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

use <rack_util.scad>
use <rack_connector.scad>
use <rack_link.scad>
use <bearing_connector.scad>

function rack_connector_stopper_w() =
  (steering_rack_link_bearing_outer_d - steering_rack_link_linkage_width) / 2;

module rack_connector() {
  stopper_w = rack_connector_stopper_w();
  half_of_rw = steering_rack_width / 2;

  union() {
    bearing_lower_connector(lower_h=steering_rack_pin_base_height);
    translate([steering_rack_link_linkage_width / 2 + 0.2, half_of_rw, 0]) {
      linear_extrude(height=steering_rack_pin_base_height, center=false) {
        translate([0, -steering_rack_width, 0]) {
          square([stopper_w * 2, steering_rack_width]);
        }
      }
    }
  }
}

module rack_connector_assembly(bracket_color=blue_grey_carbon,
                               rack_color=blue_grey_carbon,
                               rotation_dir=1) {
  color(rack_color) {
    rack_connector();
  }
  angle = rotation_dir > 0 ?
    ($t < 0.5 ? -(pinion_angle_sync($t)) : 0) :
    ($t > 0.5 ? -(pinion_angle_sync($t)) : 0);

  rotate([0, 0, rotation_dir * angle]) {
    translate([-steering_rack_link_rack_side_w_length / 2,
               -steering_rack_link_rack_side_h_length
               - steering_rack_link_bearing_outer_d / 2,
               steering_rack_pin_base_height]) {
      rack_link(show_bearing=true, bracket_color=bracket_color);
    }
  }
}

// $t = 0.4;
// rack_connector_assembly(rotation_dir=-1);
rack_connector();