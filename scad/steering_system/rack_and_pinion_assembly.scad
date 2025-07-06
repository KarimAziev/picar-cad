include <../parameters.scad>
use <../util.scad>
include <../placeholders/servo.scad>
use <bracket.scad>
use <shaft.scad>

use <rack_knuckle.scad>
use <rack_connector.scad>
use <rack.scad>
use <pinion.scad>

wall_thickness = 2;
extra_w        = (servo_gearbox_h + servo_gear_h / 2);

module rack_rail(rack_size=[rack_len / 3,
                            rack_rail_width,
                            rack_base_h + lower_knuckle_h],
                 rack_r=rack_rad,
                 panel_len=rack_pan_full_len) {
  x = rack_size[0];
  y = rack_size[1];
  z = rack_size[2];
  offst = panel_len / 2;
  rad = y / 2;
  side_offsets = [-offst + rad, offst - rad];
  difference() {
    union() {
      linear_extrude(height=wall_thickness, center=true) {
        rounded_rect(size=[panel_len, y], center=true, r=rad);
      }
      for (x = side_offsets) {
        translate([x, 0, 0]) {
          translate([0, 0, lower_knuckle_h]) {
            knuckle_lower_connector(upper_knuckle_d=upper_knuckle_d,
                                    upper_knuckle_h=upper_knuckle_h,
                                    lower_knuckle_h=lower_knuckle_h,
                                    lower_knuckle_d=lower_knuckle_d,
                                    center_screw_dia=m2_hole_dia);
          }
        }
      }
    }
  }
}

module steering_servo_panel(size=[servo_hat_w,
                                  rack_width,
                                  pinion_d + steering_servo_slot_width],
                            thickness=wall_thickness,
                            front_h=rack_base_h + lower_knuckle_h,
                            panel_len=rack_pan_full_len,
                            z_r=undef,
                            center=true,
                            show_servo=false) {

  x = size[0];
  y = size[1];
  z = size[2];

  y_r = is_undef(z_r) ? 0 : z_r;
  z_r = y / 2;

  union() {
    difference() {
      union() {
        translate([0, extra_w / 2, 0]) {
          union() {
            l_bracket(size=[x, y + extra_w, z],
                      thickness=thickness,
                      y_r=y_r,
                      z_r=z_r,
                      center=center);

            rack_rail();

            rotate([90, 0, 0]) {
              translate([0, (front_h + thickness) / 2, -y / 2]) {
                translate([0, 0, rack_width + thickness / 2]) {
                  linear_extrude(height=thickness, center=true) {
                    rounded_rect([x, front_h], center=center, r=0);
                  }
                }

                translate([0, 0, -thickness / 2]) {
                  linear_extrude(height=thickness, center=true) {
                    rounded_rect([x, front_h], center=center, r=0);
                  }
                }
              }
            }
          }
        }
      }

      translate([0, -y / 2 - thickness / 2, z / 2 - pinion_z_offst]) {
        rotate([90, 90, 0]) {
          linear_extrude(height=thickness * 2, center=true) {
            servo_slot_2d(size=[steering_servo_slot_width,
                                steering_servo_slot_height],
                          screws_dia=steering_servo_screw_dia,
                          screws_offset=steering_servo_screws_offset);
          }
        }
      }
    }
    if (show_servo) {
      translate([0, -servo_size[2] / 2
                 + screws_hat_z_offset - servo_hat_thickness / 2
                 - y / 2 - thickness, 0]) {
        rotate([90, -90, 0]) {
          translate([z / 2 - pinion_z_offst, 0, 0]) {
            servo();
          }
        }
      }
    }
  }
}

module bracket_assembly() {
  x_offst = -rack_len / 2 - rack_side_connector_size[0] - rack_side_connector_thickness / 2;
  y_offst = bracket_size[1] + bracket_screws_dia - 1;
  z_offst = bracket_thickness / 2 + rack_side_connector_size[0] / 2 + rack_side_connector_thickness + 0.5;

  translate([x_offst, y_offst, z_offst]) {
    rotate([0, 0, 90]) {
      bracket();
    }
  }
}

module knuckle_assembly() {
  translate([rack_pan_full_len / 2 - upper_knuckle_d / 2, extra_w / 2, upper_knuckle_h + lower_knuckle_h]) {
    knuckle_mount();
  }
}

module pinion_mount() {
  pinion(d=pinion_d,
         tooth_height=tooth_h,
         thickness=pinion_thickness,
         servo_dia=pinion_servo_dia,
         tooth_pitch=tooth_pitch,
         screw_dia=pinion_screw_dia,
         rack_len=rack_len);
}

module assembly() {
  union() {
    steering_servo_panel(show_servo=true);

    translate([0, extra_w / 2, rack_base_h / 2 + lower_knuckle_h / 2 - wall_thickness / 2 + 1]) {
      color("#f0fff0") {
        rack_mount();
      }
    }

    knuckle_assembly();
    mirror([1, 0, 0]) {
      knuckle_assembly();
    }

    bracket_assembly();
    mirror([1, 0, 0]) {
      bracket_assembly();
    }
    rotate([90, 0, 0]) {
      translate([0, pinion_d + lower_knuckle_h / 2 + servo_gearbox_h / 2 - pinion_z_offst,
                 -servo_gear_h / 2 - pinion_thickness / 2]) {
        color("#d3d3d3") {
          pinion_mount();
        }
      }
    }
  }
}

union() {

  steering_servo_panel();
  // translate([0, 30, 0]) {
  //   translate([0, 30, 0]) {
  //     pinion_mount();
  //   }
  // }
  // assembly();
}
