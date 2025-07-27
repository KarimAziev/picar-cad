include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
include <../placeholders/servo.scad>
use <ackermann_geometry_triangle.scad>
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

module steering_system_distance_between_rack_and_knuckle(w=5) {
  translate([rack_left_connector_x -
             distance_between_knuckle_and_rack, 0,
             knuckle_height + knuckle_pin_lower_height]) {

    color("chartreuse", alpha=0.6) {
      linear_extrude(height=1, center=false) {
        square([distance_between_knuckle_and_rack, w], center=false);
      }
    }

    translate([distance_between_knuckle_and_rack / 2, w * 0.1, 0]) {
      color("darkblue") {
        linear_extrude(height=1, center=false) {
          text(str("B: ", distance_between_knuckle_and_rack, "mm"),
               size=w * 0.7, halign="center",
               valign="bottom",
               font = "Liberation Sans:style=Bold Italic");
        }
      }
    }
  }
}

module steering_system_assembly(rack_color=blue_grey_carbon,
                                pinion_color=matte_black,
                                show_ackermann_triangle=false,
                                show_wheels=true,
                                show_bearing=true,
                                show_brackets=true,
                                show_distance=false) {
  union() {
    steering_servo_panel(show_servo=true);
    if (show_distance) {
      steering_system_distance_between_rack_and_knuckle();
    }

    rotate([0, 0, 180]) {
      translate([0, 0, rack_mount_panel_thickness / 2]) {
        rack_mount(show_brackets=show_brackets, rack_color=rack_color);
      }
    }

    rotate([0, 0, 180]) {
      knuckle_assembly(show_wheel=show_wheels, show_bearing=show_bearing);
    }
    rotate([0, 0, 180]) {
      mirror([1, 0, 0]) {
        knuckle_assembly(show_wheel=show_wheels, show_bearing=show_bearing);
      }
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
    if (show_ackermann_triangle) {
      translate([0, 0, knuckle_height + knuckle_pin_lower_height
                 + rack_mount_panel_thickness / 2
                 + knuckle_pin_stopper_height
                 + knuckle_bearing_flanged_height]) {
        color("yellowgreen", alpha=0.2) {
          ackermann_geometry_triangle();
        }
      }
    }
  }
}

steering_system_assembly(show_wheels=false);