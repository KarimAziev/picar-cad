include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <rack_util.scad>
use <rack_connector.scad>
use <bracket.scad>
use <bearing_connector.scad>

function rack_connector_stopper_w() =
  (bracket_bearing_outer_d - steering_bracket_linkage_width) / 2;

module rack_connector() {
  stopper_w = rack_connector_stopper_w();

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

  fillet_rad = stopper_h / 2;

  union() {
    bearing_lower_connector(lower_h=rack_pin_base_height);
    translate([steering_bracket_linkage_width / 2 + 0.2, half_of_rw, 0]) {
      points = [[-rack_pin_base_height, 0],
                [-rack_pin_base_height,
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
      linear_extrude(height=rack_pin_base_height, center=false) {
        translate([0, -rack_width, 0]) {
          square([stopper_w * 2, rack_width]);
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
    translate([-bracket_rack_side_w_length / 2,
               -bracket_rack_side_h_length - bracket_bearing_outer_d / 2,
               rack_pin_base_height]) {
      bracket(show_bearing=true, bracket_color=bracket_color);
    }
  }
}

// $t = 0.4;
// rack_connector_assembly(rotation_dir=-1);
rack_connector();