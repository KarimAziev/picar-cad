include <../parameters.scad>
use <bracket.scad>
use <shaft.scad>
use <../util.scad>
use <rack_connector.scad>

module knuckle(shaft_h,
               connector_shaft_h=knuckle_shaft_len,
               connector_angle=knuckle_connector_angle,
               shaft_connector_dia=rack_knuckle_connector_dia,
               upper_knuckle_d=upper_knuckle_d,
               shaft_dia=shaft_dia,
               upper_knuckle_h=upper_knuckle_h,
               lower_knuckle_h=lower_knuckle_h,
               lower_knuckle_d=lower_knuckle_d,
               connector_size=rack_side_connector_size,
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
        translate([connector_shaft_h / 2 + upper_rad - 0.5, 0, -upper_knuckle_h / 2 - connector_thickness / 2]) {
          union() {

            shaft(d=shaft_connector_dia, h=connector_shaft_h + 0.5);
            translate([connector_shaft_h / 2, 0, 0]) {
              rack_side_connector(size=connector_size,
                                  thickness=connector_thickness,
                                  screws_d=connector_screws_dia);
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
  inner_d = upper_knuckle_d - lower_knuckle_d;

  union() {
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
}

module knuckle_mount() {
  knuckle(shaft_h=shaft_height,
          connector_shaft_h=knuckle_shaft_len,
          connector_angle=knuckle_connector_angle,
          shaft_dia=shaft_dia,
          upper_knuckle_h=upper_knuckle_h,
          lower_knuckle_h=lower_knuckle_h,
          lower_knuckle_d=lower_knuckle_d,
          connector_size=rack_side_connector_size,
          connector_thickness=rack_side_connector_thickness,
          connector_screws_dia=m2_hole_dia,
          center_screw_dia=m2_hole_dia);
}

knuckle_mount();