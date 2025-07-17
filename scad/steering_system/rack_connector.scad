include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <../placeholders/servo.scad>
use <rack_connector.scad>
use <bracket.scad>
use <ring_connector.scad>
use <bearing_connector.scad>

module rack_connector(x = bracket_bearing_outer_d, stopper_w=3) {
  union() {
    bearing_lower_connector();
    extra_h = 1;
    stopper_h = knuckle_bracket_connector_height + rack_bracket_thickness + extra_h;

    h = bracket_bearing_lower_h;

    side_y = bracket_bearing_outer_d / 2;
    notch_w = calc_notch_width(bracket_bearing_outer_d, stopper_w);

    x_offst = -stopper_w  + (max(rack_bracket_width, bracket_bearing_outer_d)) / 2;

    translate([x / 2, 0, h / 2]) {
      linear_extrude(height = h, center=true) {
        translate([notch_w, -side_y / 2, 0]) {
          square([x, side_y], center=true);
        }
      }
    }
    translate([x / 2 - stopper_w / 2, -x / 2, 0]) {
      rotate([0, 90, 0]) {
        base_ofst = bracket_rack_side_h_length * 0.4;
        linear_extrude(height = stopper_w) {
          points = [[0, -bracket_rack_side_h_length],
                    [-stopper_h, -bracket_rack_side_h_length],
                    [-stopper_h, -bracket_rack_side_h_length * 0.8],
                    [-h, -base_ofst],
                    [-h, 0],
                    [0, 0]];
          polygon(points = points);
        }
      }
    }
  }
}

module rack_connector_assembly(bracket_color=blue_grey_carbon, rack_color=blue_grey_carbon) {
  color(rack_color) {
    rack_connector();
  }

  translate([-bracket_rack_side_w_length / 2 ,
             -bracket_rack_side_h_length - bracket_bearing_outer_d / 2,
             0.5]) {
    color(bracket_color, alpha = 0.6) {
      bracket();
    }
  }
}

rack_connector();
