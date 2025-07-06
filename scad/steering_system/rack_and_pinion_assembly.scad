include <../parameters.scad>
use <../util.scad>
include <../placeholders/servo.scad>
use <bracket.scad>
use <shaft.scad>
use <steering_servo_panel.scad>

use <rack_knuckle.scad>
use <rack_connector.scad>
use <rack.scad>
use <pinion.scad>

extra_w = steering_servo_panel_extra_w();

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

    translate([0, extra_w / 2, rack_base_h / 2 + lower_knuckle_h / 2 - steering_servo_panel_thickness / 2 + 1]) {
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
  assembly();
}
