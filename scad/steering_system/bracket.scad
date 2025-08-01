include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <../placeholders/bearing.scad>
use <rack_connector.scad>
use <bearing_shaft.scad>
use <bearing_connector.scad>

module bracket(a_len=bracket_rack_side_w_length,
               b_len=bracket_rack_side_h_length,
               w=steering_bracket_linkage_width,
               thickness=steering_bracket_linkage_thickness,
               connector_d=bracket_bearing_outer_d,
               show_bearing=false,
               bearing_flanged_h=bracket_bearing_flanged_height,
               bearing_flanged_w=bracket_bearing_flanged_width,
               bearing_shaft_d = round(bracket_bearing_shaft_d),
               bearing_h=bracket_bearing_height,
               bracket_color=blue_grey_carbon,
               show_text=false) {

  a_full_len = a_len + w;

  notch_w = calc_notch_width(connector_d, w);

  translate([0, 0, thickness / 2]) {
    union() {
      color(bracket_color) {
        difference() {
          union() {
            linear_extrude(height=thickness,
                           center=true) {
              translate([-notch_w / 2, 0, 0]) {
                rounded_rect([a_full_len + notch_w, w],
                             center=true,
                             fn=360,
                             r=0.4);
              }
            }

            translate([-a_full_len / 2 - connector_d / 2, 0, -thickness / 2]) {
              bearing_lower_connector();
            }
          }
        }
      }
      if (show_text) {
        color("white") {
          linear_extrude(height=thickness + 2, center=true) {
            translate([-notch_w / 2, 0, 0]) {
              text(str("D: ", a_len),
                   size=4, halign="center",
                   valign="center",
                   font = "Liberation Sans:style=Bold Italic");
            }
          }
        }
      }

      union() {
        x_offst = a_full_len / 2 - w / 2;
        color(bracket_color) {
          linear_extrude(height=thickness, center=true) {

            translate([x_offst, b_len / 2, 0]) {
              square([w, b_len + notch_w], center=true);
            }
          }
        }
        if (show_text) {
          color("white") {
            translate([0, 0, 5]) {
              linear_extrude(height=thickness, center=true) {
                translate([x_offst, b_len / 2, 0]) {
                  text(str("C: ", b_len),
                       size=4,
                       valign="bottom",
                       font = "Liberation Sans:style=Bold Italic");
                }
              }
            }
          }
        }

        translate([x_offst, b_len + connector_d / 2, -thickness / 2]) {
          union() {
            color(bracket_color, alpha=0.6) {
              bearing_upper_connector(h=bracket_bearing_pin_base_height);
            }

            if (show_bearing) {
              translate([0, 0, -bearing_flanged_h]) {
                bearing(d=bracket_bearing_d,
                        h=bearing_h,
                        flanged_w=bearing_flanged_w,
                        flanged_h=bearing_flanged_h,
                        shaft_d=bearing_shaft_d,
                        shaft_ring_w=1,
                        outer_ring_w=0.5,
                        outer_col=metalic_silver_3,
                        rings=[[1, metalic_yellow_silver]]);
              }
            }
          }
        }
      }
    }
  }
}

union() {
  rotate([0, 0, 180]) {
    bracket();
    translate([bracket_rack_side_w_length + bracket_bearing_outer_d
               + 5, 0, 0]) {
      mirror([1, 0, 0]) {
        bracket();
      }
    }
  }
}