include <../parameters.scad>
use <../util.scad>
include <../placeholders/servo.scad>
use <bracket.scad>
use <shaft.scad>
use <steering_servo_panel.scad>
use <ring_connector.scad>
use <rack_knuckle.scad>
use <rack_connector.scad>
use <rack.scad>
use <pinion.scad>
use <rack_util.scad>

extra_w = steering_servo_panel_extra_w();

module bracket_assembly() {
  shared_params = pinion_sync_params(pinion_d, tooth_pitch, rack_len);
  gear_teeth       = shared_params[0];
  actual_pitch     = shared_params[1];
  rack_teeth       = shared_params[2];
  rack_margin      = shared_params[3];
  x_offst = -rack_len / 2 - rack_margin / 2 - rack_outer_connector_d / 2 - rack_bracket_width;
  y_offst = bracket_rack_side_h_length;
  z_offst = lower_knuckle_h / 2 + steering_servo_panel_thickness / 2 + rack_bracket_connector_h;

  offst = [x_offst,
           -y_offst - 1,
           z_offst + 2];

  // translate([bracket_rack_side_w_length / 2,
  //              bracket_rack_side_h_length - rack_bracket_width / 2,
  //              -rack_knuckle_total_connector_h -
  //              (rack_bracket_connector_h * 0.7) / 2]) {
  //     rack_connector();
  //   }
  rotate([0, 0, 180]) {
    translate(offst) {
      bracket();
    }
  }
}

module knuckle_assembly() {
  translate([rack_pan_full_len / 2 - upper_knuckle_d / 2,
             extra_w / 2,
             upper_knuckle_h + lower_knuckle_h]) {
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

module steering_system_assembly() {
  union() {
    steering_servo_panel(show_servo=true);

    translate([0,
               extra_w / 2,
               lower_knuckle_h / 2 - steering_servo_panel_thickness / 2]) {

      rack_assembly();
    }

    knuckle_assembly();
    mirror([1, 0, 0]) {
      knuckle_assembly();
    }

    rotate([90, 0, 0]) {
      translate([0, pinion_d + lower_knuckle_h / 2 + servo_gearbox_h / 2 - pinion_z_offst,
                 -servo_gear_h / 2 - pinion_thickness / 2]) {
        color("#191919") {
          pinion_mount();
        }
      }
    }
  }
}

union() {
  steering_system_assembly();
}
