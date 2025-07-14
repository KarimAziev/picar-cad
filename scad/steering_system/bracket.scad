include <../parameters.scad>
use <../util.scad>
use <../placeholders/servo.scad>
use <rack_connector.scad>
use <bearing_shaft.scad>
use <bearing_connector.scad>

module bracket(a_len=bracket_rack_side_w_length,
               b_len=bracket_rack_side_h_length,
               w=rack_bracket_width,
               thickness=rack_bracket_thickness,
               connector_d=bracket_bearing_outer_d) {

  lower_connector_h = bracket_bearing_lower_h + thickness;

  a_full_len = a_len + w;

  notch_w = calc_notch_width(connector_d, w);

  translate([0, 0, thickness / 2 + lower_connector_h]) {
    union() {
      difference() {
        union() {
          linear_extrude(height = thickness, center = true) {
            translate([-notch_w / 2, 0, 0]) {
              rounded_rect([a_full_len + notch_w, w], center=true, fn=360, r=0.4);
            }
          }

          translate([-a_full_len / 2 - connector_d / 2, 0, -thickness / 2]) {
            bearing_lower_connector();
          }
        }
      }

      union() {
        x_offst = a_full_len / 2 - w / 2;
        linear_extrude(height=thickness, center = true) {

          translate([x_offst, b_len / 2, 0]) {
            square([w, b_len + notch_w], center=true);
          }
        }

        translate([x_offst, b_len + connector_d / 2, -rack_bracket_connector_h / 2 - thickness / 2]) {
          bearing_upper_connector();
        }
      }
    }
  }
}

union() {
  rotate([0, 0, 180]) {
    bracket();
    translate([bracket_rack_side_w_length + bracket_bearing_outer_d + 3, 0, 0]) {
      mirror([1, 0, 0]) {
        bracket();
      }
    }
  }
}