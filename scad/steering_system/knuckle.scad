include <../parameters.scad>
use <../util.scad>
use <bracket.scad>
use <shaft.scad>

use <rack_connector.scad>
use <bearing_shaft.scad>
use <bearing_connector.scad>
use <../wheels/wheel_hub.scad>
use <../wheels/front_wheel.scad>

function knuckle_full_h() = wheel_hub_full_height(knuckle_height * 2, knuckle_hub_inner_rim_h);

module knuckle_mount(center=true, show_wheels=false) {
  total_h = knuckle_full_h();
  union() {
    translate([0, 0, center ? total_h / 4 - knuckle_hub_inner_rim_h * 2 : 0]) {
      wheel_hub_lower(d=knuckle_bearing_outer_dia,
                      h=knuckle_height * 2,
                      upper_d=knuckle_dia,
                      outer_d=knuckle_dia,
                      inner_rim_h=knuckle_hub_inner_rim_h,
                      inner_rim_w=knuckle_hub_inner_rim_w,
                      screws_dia=0,
                      screws_n=0,
                      screw_boss_h=0,
                      screw_boss_w=0,
                      center_screws=false);
      shaft_z_offst = -knuckle_height + knuckle_shaft_dia / 2;

      knuckle_rad = knuckle_dia / 2;
      notch_width = calc_notch_width(knuckle_dia, knuckle_shaft_dia);

      union() {
        translate([knuckle_shaft_len / 2 + knuckle_dia / 2, 0, shaft_z_offst]) {
          shaft(d=knuckle_shaft_dia, h=knuckle_shaft_len + notch_width);
          if (show_wheels) {
            rotate([90, 0, 90]) {
              color("#232323")
                front_wheel();
            }
          }
        }
      }

      rotate([0, 0, knuckle_bracket_connector_angle]) {
        w = knuckle_bracket_connector_len;
        params = calculate_params_from_dia(d=bracket_bearing_outer_d, center_dia=m2_hole_dia);
        connector_d = params[0];
        ring_w = params[1];
        tolerance = params[2];
        notch_width = calc_notch_width(knuckle_dia, w);;

        extra_wall = notch_width;

        translate([w / 2, 0, -knuckle_bracket_connector_height / 2]) {
          linear_extrude(height = knuckle_bracket_connector_height, center=true) {
            difference() {
              square([extra_wall, bracket_bearing_outer_d], center=true);
              translate([-knuckle_dia / 2, 0, 0]) {
                circle(d=knuckle_dia, $fn=60);
              }
            }
          }
        }

        translate([knuckle_dia / 2 + w / 2, 0,
                   -knuckle_bracket_connector_height / 2]) {

          union() {
            linear_extrude(height = knuckle_bracket_connector_height, center = true) {
              difference() {
                square([w, bracket_bearing_outer_d], center=true);
                translate([bracket_bearing_outer_d / 2, 0, 0]) {
                  circle(d=connector_d + ((ring_w + tolerance) * 2 + 2), $fn=360);
                }
              }
            }

            translate([bracket_bearing_outer_d / 2, 0, -knuckle_bracket_connector_height / 2]) {
              bearing_upper_connector();
            }
          }
        }
      }
    }
  }
}

union() {
  rotate([180, 0, 0]) {
    knuckle_mount();

    translate([-30, 0, 0]) {
      mirror([1, 0, 0]) {
        knuckle_mount();
      }
    }
  }
}
