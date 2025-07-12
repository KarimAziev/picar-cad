include <../parameters.scad>
use <../util.scad>
use <../placeholders/servo.scad>
use <rack_connector.scad>
use <ring_connector.scad>

module bracket(a_len=bracket_rack_side_w_length,
               b_len=bracket_rack_side_h_length,
               w=rack_bracket_width,
               thickness=rack_bracket_thickness,
               connector_d=rack_outer_connector_d,
               connector_a_h=rack_bracket_connector_h,
               connector_b_h=rack_bracket_connector_h,
               connector_height=rack_bracket_connector_h,
               screws_d=m2_hole_dia) {

  connector_h = is_undef(connector_height) ?
    (connector_a_h > connector_b_h ? connector_b_h : connector_a_h) * 0.7
    : connector_height;
  lower_connector_h = connector_height + thickness;

  a_full_len = a_len + w;

  translate([0, 0, thickness / 2 + lower_connector_h]) {
    union() {
      difference() {
        union() {
          linear_extrude(height = thickness, center = true) {
            rounded_rect([a_full_len, w], center=true, fn=360, r=0.4);
          }

          translate([-a_full_len / 2 - connector_d / 2 + 1, 0, -thickness / 2]) {
            lower_ring_connector(d = connector_d,
                                 h = connector_a_h + thickness,
                                 connector_h = connector_h,
                                 tolerance = 0.4,
                                 center_dia=screws_d,
                                 fn = 360);
          }
        }
      }

      union() {
        x_offst = a_full_len / 2 - w / 2;
        linear_extrude(height = thickness, center = true) {
          translate([x_offst, b_len / 2, 0]) {
            rounded_rect_two([w, b_len], center=true, r=0.4);
          }
        }

        translate([x_offst,
                   b_len + connector_d / 2 - 1,
                   -connector_b_h - thickness / 2]) {
          upper_ring_connector(d = connector_d,
                               h = connector_b_h + thickness,
                               connector_h = connector_h,
                               tolerance = 0.4,
                               center_dia=screws_d,
                               fn = 360);
        }
      }
    }
  }
}

union() {
  rotate([0, 0, 180]) {
    bracket();
    translate([bracket_rack_side_w_length + rack_outer_connector_d + 3, 0, 0]) {
      mirror([1, 0, 0]) {
        bracket();
      }
    }
  }
}