/**
 * Module: Ring Connector Module
 * This file contains modules for creating detachable connectors in the form of vertical cylinders that slide onto each other.
 *
 * The module created by `bearing_upper_connector` fits over the module created by `lower_ring_connector`.
 *
 * Parameters:
 *
 * - d            : Diameter of the main cylinder.
 * - h            : Total height of the cylinder.
 * - connector_h : Height of the connector. This value must not exceed the total
 *   height (h). In the case of bearing_upper_connector, it represents the depth of
 *   the cut-out at the bottom of the cylinder, in the case of
 *   lower_ring_connector, it is the height of the cylinder that fits into the
 *   cut-out of the bearing_upper_connector. For a matching pair of
 *   bearing_upper_connector and lower_ring_connector modules, this parameter needs
 *   to be identical.
 * - center_dia   : An optional parameter for creating a through-hole along the
 *   entire cylinder.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
use <../util.scad>
use <../placeholders/bearing.scad>
use <bracket.scad>
use <bearing_shaft.scad>
use <../wheels/wheel_hub.scad>

module bearing_upper_connector(connector_color, h=knuckle_bracket_connector_height) {
  union() {
    color(connector_color) {
      linear_extrude(height = h) {
        ring_2d(r=bracket_bearing_d / 2,
                w=(bracket_bearing_outer_d - bracket_bearing_d) / 2,
                fn=360,
                outer=true);
      }
    }
  }
}

module bearing_lower_connector(lower_d=bracket_bearing_outer_d,
                               lower_h=bracket_bearing_lower_h,
                               shaft_h=bracket_bearing_shaft_h,
                               shaft_d=bracket_bearing_shaft_d,
                               stopper_h=bracket_bearing_stopper_height) {
  bearing_shaft_connector(lower_d=lower_d,
                          lower_h=lower_h,
                          shaft_h=shaft_h,
                          shaft_d=shaft_d,
                          stopper_h=stopper_h);
}

module print_plate(step_offset = 5) {
  translate([bracket_bearing_outer_d / 2 + step_offset, 0, 0]) {
    bearing_upper_connector();
  }

  translate([-bracket_bearing_outer_d / 2 - step_offset, 0, 0]) {
    bearing_lower_connector();
  }
}

module assembly_view(animation_z_offset=5) {

  end_h = knuckle_bracket_connector_height + animation_z_offset;
  base_h = bracket_bearing_lower_h;
  z_offst = $t >= 0.7 ? base_h : end_h + ((base_h - end_h) * $t);

  bearing_lower_connector();

  translate([0, 0, z_offst]) {
    bearing_upper_connector();
  }
}

union() {
  print_plate(step_offset=2);

  // assembly_view();

  // translate([-20, 0, 0]) {
  //   bearing_upper_connector();
  // }
  // bearing_lower_connector();

  // assembly_view(animation_z_offset = 5);
}
