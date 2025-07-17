include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
include <../placeholders/servo.scad>
use <bracket.scad>
use <shaft.scad>
use <steering_servo_panel.scad>
use <ring_connector.scad>
use <knuckle.scad>
use <rack_connector.scad>
use <rack.scad>
use <pinion.scad>
use <rack_util.scad>

module knuckle_assembly() {
  translate([rack_pan_full_len / 2 - knuckle_dia / 2 - 0.5,
             0,
             knuckle_pin_lower_height]) {
    knuckle_mount(show_wheels=true);
  }
}

module pinion_mount() {
  rotate([0, 0, 4]) {
    pinion(d=pinion_d,
           tooth_height=tooth_h,
           thickness=pinion_thickness,
           servo_dia=pinion_servo_dia,
           tooth_pitch=tooth_pitch,
           rack_len=rack_len);
  }
}

module steering_system_assembly(rack_color=blue_grey_carbon, pinion_color=black_1) {
  union() {
    steering_servo_panel(show_servo=true);
    translate([0,
               0,
               knuckle_pin_lower_height / 2 - steering_servo_panel_thickness / 2]) {
      rack_assembly(rack_color=rack_color);
    }

    knuckle_assembly();
    mirror([1, 0, 0]) {
      knuckle_assembly();
    }

    rotate([90, 0, 0]) {
      translate([0, pinion_d + knuckle_pin_lower_height / 2 + servo_gearbox_h / 2 - pinion_z_offst,
                 -servo_gear_h / 2 - pinion_thickness / 2]) {
        color(pinion_color) {
          pinion_mount();
        }
      }
    }
  }
}

steering_system_assembly();