include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <rack_connector.scad>
use <bracket.scad>
use <bearing_connector.scad>

module rack_connector(stopper_w=3) {
  extra_h = 1;
  half_of_rw = rack_width / 2;
  stopper_h = rack_pin_base_height
    + bracket_bearing_stopper_height
    + steering_bracket_linkage_thickness
    + extra_h;

  notch_w = calc_notch_width(bracket_bearing_outer_d, stopper_w);
  stopper_len = bracket_rack_side_h_length
    + bracket_bearing_outer_d / 2
    + half_of_rw;

  union() {
    rotate([0, 0, 0]) {
      bearing_lower_connector(lower_h=rack_pin_base_height);
    }
    translate([steering_bracket_linkage_width / 2, half_of_rw, 0]) {
      rotate([0, 90, 0]) {
        linear_extrude(height = stopper_w) {
          points = [[0, -stopper_len],
                    [-stopper_h, -stopper_len],
                    [-stopper_h, -stopper_len * 0.8],
                    [-rack_pin_base_height, -bracket_bearing_outer_d / 2
                     - half_of_rw],
                    [-rack_pin_base_height, 0],
                    [0, 0]];

          fillet(r=stopper_h / 2) {
            polygon(points = points);
          }
        }
      }
    }
  }
}

module rack_connector_assembly(bracket_color=blue_grey_carbon,
                               rack_color=blue_grey_carbon) {
  color(rack_color) {
    rack_connector();
  }
  translate([-bracket_rack_side_w_length / 2,
             -bracket_rack_side_h_length - bracket_bearing_outer_d / 2,
             rack_pin_base_height]) {
    bracket(show_bearing=true, bracket_color=bracket_color);
  }
}

rack_connector_assembly();
