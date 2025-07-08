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

          translate([-a_full_len / 2 - w, 0, -thickness / 2]) {
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
                   b_len + w,
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

module rack_connector() {
  union() {
    lower_ring_connector(d=rack_outer_connector_d,
                         h=rack_knuckle_total_connector_h,
                         connector_h=rack_bracket_connector_h,
                         center_dia=m2_hole_dia);

    extra_h = 1;
    stopper_h = rack_knuckle_total_connector_h + rack_bracket_thickness + extra_h;
    stopper_y = bracket_rack_side_h_length / 2;
    y_distance = 1;

    h = rack_knuckle_total_connector_h - rack_bracket_connector_h;
    x = rack_outer_connector_d;

    y  = rack_outer_connector_d + 0.0;
    y_offst = -stopper_y / 2 - rack_outer_connector_d / 2;

    translate([x / 2 + m2_hole_dia / 2, y / 2 - rack_outer_connector_d / 2, h / 2]) {
      linear_extrude(height = h, center=true) {
        square([x, y], center=true);
      }
    }
    translate([0, 2, 0]) {
      linear_extrude(height = h, center=false) {
        square([10, 1], center=true);
      }
    }
    difference() {
      hull() {
        translate([0, 0, h / 2]) {
          linear_extrude(height = h, center=true) {
            translate([x / 2, -y_distance / 2 - rack_outer_connector_d / 2, 0]) {
              square([x, y_distance], center=true);
            }
          }
        }
        translate([0, -y_distance, 0]) {
          translate([rack_bracket_width / 2, -stopper_y / 2 - rack_outer_connector_d / 2, stopper_h / 2]) {
            linear_extrude(height = stopper_h, center=true) {
              rotate([180, 0, 0]) {
                rounded_rect_two([rack_bracket_width, stopper_y], center=true, r=rack_bracket_width / 2);
              }
            }
          }
        }
      }
      translate([0, -y_distance, 0]) {
        stopper_slot_z = rack_bracket_thickness + extra_h / 2;
        stopper_slot_w = rack_bracket_width;
        stopper_slot_y = stopper_y + 1;
        translate([0, y_offst + 0.5, stopper_h - extra_h - stopper_slot_z / 2]) {
          linear_extrude(height = stopper_slot_z * 3, center=true) {
            rounded_rect([stopper_slot_w, stopper_slot_y + 1], r=0.5, center=true);
          }
        }
      }
    }
  }
}

module rack_connector_assembly() {
  rack_connector();

  translate([-bracket_rack_side_w_length / 2 ,
             -bracket_rack_side_h_length - rack_bracket_width,
             0]) {
    color([1, 0, 0], alpha = 0.6) {
      bracket(connector_height=rack_bracket_connector_h);
    }
  }
}

union() {
  // rotate([0, 0, 180]) {
  //   bracket();
  //   translate([bracket_rack_side_w_length + rack_outer_connector_d + 3, 0, 0]) {
  //     mirror([1, 0, 0]) {
  //       bracket();
  //     }
  //   }
  // }
  rack_connector();
  // translate([-30, 0, 0]) {
  //   rack_connector();
  // }
}