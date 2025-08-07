/**
 * Module: Bearing Connector
 *
 * This module defines parts that connect flanged ball bearings to steering
 * linkage components, such as knuckles and brackets. It supplies printable
 * upper and lower connector geometries as part of the mechanical interface for
 * smooth steering articulation.
 *
 *
 * - bearing_upper_connector(): Generates a flat circular ring (flanged-style)
 *     that serves as the top bearing connector to the knuckle component.
 *     Modeled as an outer ring and extruded vertically.
 *
 * - bearing_lower_connector(): Utilizes a shaft connector interface (from
 *     bearing_shaft.scad) to place the lower part of the bearing (pin and
 *     support base) into the bracket.
 *
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
use <../util.scad>
use <bearing_shaft.scad>
use <../wheels/wheel_hub.scad>

module bearing_upper_connector(connector_color,
                               h=knuckle_bracket_connector_height) {
  union() {
    color(connector_color) {
      linear_extrude(height = h) {
        ring_2d(r=steering_bracket_bearing_d / 2,
                w=(steering_bracket_bearing_outer_d - steering_bracket_bearing_d) / 2,
                fn=360,
                outer=true);
      }
    }
  }
}

module bearing_lower_connector(lower_d=steering_bracket_bearing_outer_d,
                               lower_h=steering_bracket_bearing_bearing_pin_base_h,
                               shaft_h=steering_bracket_bearing_pin_height,
                               shaft_d=steering_bracket_bearing_shaft_d,
                               stopper_h=steering_bracket_bearing_stopper_height) {
  bearing_shaft_connector(lower_d=lower_d,
                          lower_h=lower_h,
                          shaft_h=shaft_h,
                          shaft_d=shaft_d,
                          stopper_h=stopper_h);
}

module bearing_print_plate(step_offset=5) {
  translate([steering_bracket_bearing_outer_d / 2 + step_offset, 0, 0]) {
    bearing_upper_connector();
  }

  translate([-steering_bracket_bearing_outer_d / 2 - step_offset, 0, 0]) {
    bearing_lower_connector();
  }
}

module bearing_connector_assembly_view(animation_z_offset=5) {

  end_h = knuckle_bracket_connector_height + animation_z_offset;
  base_h = steering_bracket_bearing_bearing_pin_base_h;
  z_offst = $t >= 0.7 ? base_h : end_h + ((base_h - end_h) * $t);

  bearing_lower_connector();

  translate([0, 0, z_offst]) {
    bearing_upper_connector();
  }
}

union() {
  bearing_print_plate(step_offset=2);
}
