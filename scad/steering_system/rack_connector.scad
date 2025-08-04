/**
 * Module: Rack Connector
 *
 * The rack connector forms the interface at each end of the steering rack,
 * where it attaches to L-shaped brackets holding flanged bearings.
 *
 * Purpose:
 * - Mechanically connects the rack to the L-brackets used in the steering linkage.
 * - Provides fixed geometry to seat bracket pins and bearing connectors.
 * - Forms part of the guided horizontal motion system for the rack.
 *
 * Structure:
 * - A central pin connector extrusion into which a bearing pin can be inserted.
 * - A stopper wall with embedded fillets that prevent over-travel of the linkage bracket.
 * - Bottom notch and stopper pads that provide alignment and restrict vertical movement.
 *
 * Placement:
 * - One rack connector is mirrored to each side of the rack using rack_connector_assembly().
 * - Located at both ends of the rack, aligned with mating L-brackets and steering knuckles.
 *
 * Use rack_connector_assembly() if you want to visualize the connector with its attached
 * bracket in motion with servo-actuated steering.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <rack_util.scad>
use <rack_connector.scad>
use <bracket.scad>
use <bearing_connector.scad>

function rack_connector_stopper_w() =
  (steering_bracket_bearing_outer_d - steering_bracket_linkage_width) / 2;

module rack_connector() {
  stopper_w = rack_connector_stopper_w();

  extra_h = 1;
  half_of_rw = steering_rack_width / 2;
  stopper_h = steering_rack_pin_base_height
    + steering_bracket_bearing_stopper_height
    + steering_bracket_linkage_thickness
    + extra_h;

  notch_w = calc_notch_width(steering_bracket_bearing_outer_d, stopper_w);
  stopper_len = steering_bracket_rack_side_h_length
    + steering_bracket_bearing_outer_d / 2
    + half_of_rw;

  fillet_rad = stopper_h / 2;

  union() {
    bearing_lower_connector(lower_h=steering_rack_pin_base_height);
    translate([steering_bracket_linkage_width / 2 + 0.2, half_of_rw, 0]) {
      points = [[-steering_rack_pin_base_height, 0],
                [-steering_rack_pin_base_height,
                 -stopper_len * 0.75],
                [-stopper_h, -stopper_len * 0.8],
                [-stopper_h, -stopper_len],
                [0, -stopper_len],
                [0, 0]];

      rotate([0, 90, 0]) {

        linear_extrude(height=stopper_w) {
          fillet(r=0.5) {
            polygon(points = points);
          }
        }
      }
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
    translate([-steering_bracket_rack_side_w_length / 2,
               -steering_bracket_rack_side_h_length - steering_bracket_bearing_outer_d / 2,
               steering_rack_pin_base_height]) {
      bracket(show_bearing=true, bracket_color=bracket_color);
    }
  }
}

// $t = 0.4;
// rack_connector_assembly(rotation_dir=-1);
rack_connector();