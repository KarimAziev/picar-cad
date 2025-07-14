include <../parameters.scad>
use <../util.scad>
use <../placeholders/servo.scad>
use <rack_connector.scad>
use <bracket.scad>
use <ring_connector.scad>
use <bearing_connector.scad>

function calculate_params_from_dia(d=bracket_bearing_outer_d, center_dia, tolerance=0.4) =
  let (center_d = is_num(center_dia) ? max(center_dia, 0.3 * d) : 0.3 * d,
       ring_w = ((d - center_d) / 4) - ceil(tolerance * 2),
       connector_d = center_d + ring_w * 2)
  [connector_d, ring_w, tolerance];

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

module rack_connector_assembly() {
  rack_connector();

  translate([-bracket_rack_side_w_length / 2 ,
             -bracket_rack_side_h_length - bracket_bearing_outer_d / 2,
             0.5]) {
    color([1, 0, 0], alpha = 0.6) {
      bracket();
    }
  }
}

rack_connector();
