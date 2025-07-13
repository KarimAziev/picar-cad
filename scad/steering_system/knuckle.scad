include <../parameters.scad>
use <../util.scad>
use <bracket.scad>
use <shaft.scad>
use <ring_connector.scad>
use <rack_connector.scad>
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
        params = calculate_params_from_dia(d=rack_outer_connector_d, center_dia=m2_hole_dia);
        connector_d = params[0];
        ring_w = params[1];
        tolerance = params[2];
        notch_width = calc_notch_width(knuckle_dia, w);;

        extra_wall = notch_width;

        translate([w / 2, 0, -knuckle_bracket_connector_height / 2]) {
          linear_extrude(height = knuckle_bracket_connector_height, center=true) {
            difference() {
              square([extra_wall, rack_outer_connector_d], center=true);
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
                square([w, rack_outer_connector_d], center=true);
                translate([rack_outer_connector_d / 2, 0, 0]) {
                  circle(d=connector_d + ((ring_w + tolerance) * 2 + 2), $fn=360);
                }
              }
            }

            translate([rack_outer_connector_d / 2, 0, -knuckle_bracket_connector_height / 2]) {
              upper_ring_connector(d=rack_outer_connector_d,
                                   h=knuckle_bracket_connector_height,
                                   connector_h=rack_bracket_connector_h,
                                   center_dia=m2_hole_dia);
            }
          }
        }
      }
    }
  }
}

module knuckle_lower_connector(upper_dia=knuckle_dia,
                               lower_h=knuckle_pin_lower_height,
                               chamfer_h=knuckle_pin_chamfer_height,
                               shaft_dia=knuckle_bearing_inner_dia) {

  upper_rad = upper_dia / 2;

  lower_z_offset = -lower_h / 2;

  bearing_total_h = knuckle_pin_bearing_height;
  h1 = bearing_total_h - chamfer_h;

  union() {
    translate([0, 0, lower_z_offset]) {
      linear_extrude(height=lower_h, center=true) {
        circle(r=upper_rad, $fn=360);
      }

      translate([0, 0, -lower_z_offset]) {
        union() {
          translate([0, 0, 0]) {
            linear_extrude(height=h1, center=false) {
              circle(r=shaft_dia / 2, $fn=360);
            }
          }

          scale_factor = ((shaft_dia / 2) - chamfer_h) / (shaft_dia / 2);

          translate([0, 0, bearing_total_h - chamfer_h]) {
            linear_extrude(height = chamfer_h,
                           center=false,
                           scale=scale_factor) {
              circle(r=shaft_dia / 2, $fn=360);
            }
          }
        }
      }
    }
  }
}

module knuckle_probes() {
  bigger_val = 4.2;
  vals = [3.0, 3.1, 3.2, 3.8, 3.9, 4.0, 4.1, bigger_val];

  union() {
    for (i = [0:len(vals) - 1]) {
      translate([i * knuckle_dia, 0, 0]) {
        knuckle_lower_connector(lower_h=0, shaft_dia=vals[i]);
      }
    }
  }
  translate([-knuckle_dia / 2, -(bigger_val + 2) / 2, 0]) {
    linear_extrude(height = 2, center=true) {
      square([knuckle_dia * len(vals), bigger_val + 2]);
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
