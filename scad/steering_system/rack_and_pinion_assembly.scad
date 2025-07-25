include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
include <../placeholders/servo.scad>
use <bracket.scad>
use <steering_servo_panel.scad>
use <knuckle.scad>
use <rack_connector.scad>
use <rack.scad>
use <pinion.scad>
use <rack_util.scad>

module knuckle_assembly(show_wheel=true, show_bearing=true, show_shaft=true) {
  x_offst = rack_mount_panel_len / 2 - knuckle_dia / 2;

  z_offst = knuckle_pin_lower_height
    + rack_mount_panel_thickness / 2
    + knuckle_pin_stopper_height
    + knuckle_bearing_flanged_height;

  translate([x_offst, 0, z_offst]) {
    knuckle_mount(show_wheel=show_wheel,
                  show_bearing=show_bearing,
                  show_shaft=show_shaft);
  }
}

module steering_system_assembly(rack_color=blue_grey_carbon,
                                pinion_color=matte_black,
                                show_wheels=true,
                                show_bearing=true,
                                show_brackets=true) {
  union() {
    steering_servo_panel(show_servo=true);

    translate([0, 0, rack_mount_panel_thickness / 2]) {
      rack_mount(show_brackets=show_brackets, rack_color=rack_color);
    }

    knuckle_assembly(show_wheel=show_wheels, show_bearing=show_bearing);
    mirror([1, 0, 0]) {
      knuckle_assembly(show_wheel=show_wheels, show_bearing=show_bearing);
    }

    translate([0, 0, pinion_d / 2
               + tooth_h * 2 - 1
               + rack_mount_panel_thickness / 2
               + rack_base_h]) {

      rotate([90, 5, 0]) {
        color(pinion_color) {
          pinion(d=pinion_d,
                 tooth_height=tooth_h,
                 thickness=pinion_thickness,
                 servo_dia=pinion_servo_dia,
                 tooth_pitch=tooth_pitch,
                 rack_len=rack_len);
        }
      }
    }
  }
}

steering_system_assembly(show_wheels=false);