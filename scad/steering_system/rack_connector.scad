include <../parameters.scad>
use <../util.scad>
use <../placeholders/servo.scad>
use <rack_connector.scad>
use <bracket.scad>
use <ring_connector.scad>

function calculate_params_from_dia(d=rack_outer_connector_d, center_dia, tolerance=0.4) =
  let (center_d = is_num(center_dia) ? max(center_dia, 0.3 * d) : 0.3 * d,
       ring_w = ((d - center_d) / 4) - ceil(tolerance * 2),
       connector_d = center_d + ring_w * 2)
  [connector_d, ring_w, tolerance];

module rack_connector(x = rack_outer_connector_d, stopper_w=3) {
  union() {
    lower_ring_connector(d=rack_outer_connector_d,
                         h=knuckle_bracket_connector_height,
                         connector_h=rack_bracket_connector_h,
                         center_dia=m2_hole_dia);

    extra_h = 1;
    stopper_h = knuckle_bracket_connector_height + rack_bracket_thickness + extra_h;
    stopper_y = bracket_rack_side_h_length;
    y_distance = 1;

    h = knuckle_bracket_connector_height - rack_bracket_connector_h;

    y  = rack_outer_connector_d + 0.0;
    ring_params = calculate_params_from_dia(rack_outer_connector_d, center_dia=m2_hole_dia);
    connector_d = ring_params[0];

    ring_w = ring_params[1];
    side_y = rack_outer_connector_d / 3;
    x_offst = -stopper_w  + (max(rack_bracket_width, rack_outer_connector_d) - connector_d) / 2;

    translate([x / 2, 0, h / 2]) {
      linear_extrude(height = h, center=true) {

        // translate([x / 2 - 0.4, 0, 0]) {
        //   square([x, connector_d], center=true);
        // }

        translate([x_offst,
                   -side_y, 0]) {
          square([stopper_w, side_y], center=true);
          translate([-stopper_w, 0, 0]) {
            square([stopper_w, side_y], center=true);
          }
        }
      }

      translate([0, 0, rack_bracket_connector_h]) {
        difference() {
          linear_extrude(height = stopper_h, center=true) {
            translate([x_offst, -y / 2 - connector_d - side_y / 2, 0]) {
              rotate([180, 0, 0]) {
                rounded_rect_two([stopper_w, stopper_y], center=true);
              }
            }
          }
          translate([0, -2, -rack_bracket_connector_h - 0.5]) {
            rotate([-35, 0, 0]) {
              linear_extrude(height = stopper_h, center=false) {
                translate([x_offst, -y / 2 - side_y]) {
                  square(size = [stopper_w * 2, stopper_y * 2], center = true);
                }
              }
            }
          }
        }
      }
    }
  }
}

module rack_connector_assembly() {
  rack_connector();

  translate([-bracket_rack_side_w_length / 2 ,
             -bracket_rack_side_h_length - rack_outer_connector_d / 2 + 1,
             0]) {
    color([1, 0, 0], alpha = 0.6) {
      bracket(connector_height=rack_bracket_connector_h);
    }
  }
}

union() {
  rack_connector();
  // translate([-30, 0, 0]) {
  //   rack_connector();
  // }
}