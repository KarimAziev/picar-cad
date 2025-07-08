include <../parameters.scad>
use <../util.scad>
use <bracket.scad>
use <shaft.scad>
use <ring_connector.scad>
use <rack_connector.scad>

module knuckle(shaft_h,
               connector_shaft_h=knuckle_shaft_len,
               connector_angle=knuckle_connector_angle,
               upper_knuckle_d=upper_knuckle_d,
               shaft_dia=shaft_dia,
               upper_knuckle_h=upper_knuckle_h,
               lower_knuckle_h=lower_knuckle_h,
               lower_knuckle_d=lower_knuckle_d,
               connector_thickness=1,
               connector_screws_dia=m2_hole_dia,
               center_screw_dia=m2_hole_dia) {

  upper_rad = upper_knuckle_d / 2;

  total_h = upper_knuckle_h + lower_knuckle_h;
  lower_z_offset = -lower_knuckle_h / 2;

  difference() {
    union() {
      translate([0, 0, lower_z_offset]) {
        linear_extrude(height=total_h, center=true) {
          circle(r=upper_rad, $fn=360);
        }
      }
      translate([shaft_h / 2, 0, -upper_knuckle_h / 2]) {
        shaft(d=shaft_dia, h=shaft_h);
      }

      rotate([0, 0, connector_angle]) {
        translate([connector_shaft_h / 2 + upper_rad - 0.5, 0, 1]) {
          union() {
            w = connector_shaft_h + rack_outer_connector_d;
            linear_extrude(height = rack_knuckle_total_connector_h, center = true) {
              difference() {
                square([w, rack_outer_connector_d], center=true);
                params = calculate_params_from_dia(d=rack_outer_connector_d, center_dia=center_screw_dia);
                connector_d = params[0];
                ring_w = params[1];
                tolerance = params[2];
                translate([connector_shaft_h / 2 + rack_outer_connector_d / 2, 0, 0]) {
                  circle(d=connector_d + ((ring_w + tolerance) * 2 + 0.1), $fn=360);
                }
              }
            }

            translate([connector_shaft_h / 2 + rack_outer_connector_d / 2, 0,
                       -rack_knuckle_total_connector_h / 2]) {
              upper_ring_connector(d=rack_outer_connector_d,
                                   h=rack_knuckle_total_connector_h,
                                   connector_h=rack_bracket_connector_h,
                                   center_dia=center_screw_dia);
            }
          }
        }
      }
    }

    translate([0, 0, lower_z_offset]) {
      translate([0, 0, -upper_knuckle_h / 2]) {
        linear_extrude(height=lower_knuckle_h + 1, center=true) {
          ring_2d(r=(lower_knuckle_d / 2),
                  w=knuckle_ring_inner_w + 0.4, fn=360, outer=true);
        }
      }

      linear_extrude(height=total_h + 1, center=true) {
        circle(r=center_screw_dia / 2, $fn=360);
      }
    }
  }
}

module knuckle_lower_connector(upper_knuckle_d=upper_knuckle_d,
                               upper_knuckle_h=upper_knuckle_h,
                               lower_knuckle_h=lower_knuckle_h,
                               lower_knuckle_d=lower_knuckle_d,
                               center_screw_dia=m2_hole_dia) {

  upper_rad = upper_knuckle_d / 2;

  total_h = lower_knuckle_h + lower_knuckle_h;
  lower_z_offset = -lower_knuckle_h / 2;

  difference() {
    union() {
      translate([0, 0, lower_z_offset]) {
        linear_extrude(height=lower_knuckle_h, center=true) {
          circle(r=upper_rad, $fn=360);
        }
        translate([0, 0, -lower_z_offset]) {
          linear_extrude(height=lower_knuckle_h + 1, center=true) {
            ring_2d(r=lower_knuckle_d / 2,
                    w=knuckle_ring_inner_w, fn=360, outer=true);
          }
        }
      }
    }
    translate([0, 0, lower_z_offset]) {
      linear_extrude(height=total_h + 1, center=true) {
        circle(r=center_screw_dia / 2, $fn=360);
      }
    }
  }
}

module knuckle_mount() {
  knuckle(shaft_h=shaft_height,
          connector_shaft_h=knuckle_shaft_len,
          connector_angle=knuckle_connector_angle,
          shaft_dia=shaft_dia,
          upper_knuckle_h=upper_knuckle_h,
          lower_knuckle_h=lower_knuckle_h,
          lower_knuckle_d=lower_knuckle_d,
          connector_thickness=rack_side_connector_thickness,
          connector_screws_dia=m2_hole_dia,
          center_screw_dia=m2_hole_dia);
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
