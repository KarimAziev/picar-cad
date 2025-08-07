/**
 * Module: Rack And Pinion Assembly
 *
 * This file defines the complete structural and visual assembly of the steering system,
 * including key interactive mechanical components such as the steering rack, pinion gear,
 * bracket connectors, knuckles, and optional Ackermann geometry support.
 *
 * INTENDED USAGE:
 * - Visual simulation of mechanical alignment and animation.
 * - Printable (with selective module use) or for demonstration and analysis.
 * - Supports inspection of Ackermann steering characteristics.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <../placeholders/servo.scad>
use <../placeholders/steering_servo.scad>
use <ackermann_geometry_triangle.scad>
use <steering_pinion.scad>
use <bracket.scad>
use <steering_panel.scad>
use <knuckle.scad>
use <rack_connector.scad>
use <rack.scad>
use <rack_util.scad>

module knuckle_assembly(show_wheel=true,
                        show_bearing=true,
                        show_shaft=true,
                        rotation_dir=1) {
  x_offst = steering_panel_length / 2 - knuckle_dia / 2;

  z_offst = knuckle_pin_lower_height
    + steering_rack_support_thickness / 2
    + knuckle_pin_stopper_height
    + knuckle_bearing_flanged_height;
  angle = $t > 0.0 ? pinion_angle_sync($t) : 0;
  translate([x_offst, 0, z_offst]) {
    rotate([0, 0, rotation_dir * angle]) {
      knuckle_mount(show_wheel=show_wheel,
                    show_bearing=show_bearing,
                    show_shaft=show_shaft);
    }
  }
}

module steering_system_distance_between_rack_and_knuckle(w=5) {
  translate([steering_rack_connector_x_pos -
             steering_distance_between_knuckle_and_rack, 0,
             knuckle_height + knuckle_pin_lower_height]) {
    color("chartreuse", alpha=0.6) {
      linear_extrude(height=1, center=false) {
        square([steering_distance_between_knuckle_and_rack, w], center=false);
      }
    }

    translate([steering_distance_between_knuckle_and_rack / 2, w * 0.1, 0]) {
      color("darkblue") {
        linear_extrude(height=1, center=false) {
          text(str("B: ", steering_distance_between_knuckle_and_rack, "mm"),
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
                                panel_color="white",
                                show_ackermann_triangle=false,
                                show_wheels=true,
                                show_bearing=true,
                                show_brackets=true,
                                show_distance=false,
                                show_pinion=true,
                                show_servo=true) {
  union() {
    steering_panel(show_servo=show_servo,
                   show_pinion=show_pinion,
                   panel_color=panel_color,
                   pinion_color=pinion_color);
    if (show_distance) {
      steering_system_distance_between_rack_and_knuckle();
    }

    translate([0, 0, steering_rack_support_thickness / 2]) {
      rack_mount(show_brackets=show_brackets, rack_color=rack_color);
    }

    rotate([0, 0, 180]) {
      knuckle_assembly(show_wheel=show_wheels,
                       show_bearing=show_bearing,
                       rotation_dir=3.6);
    }
    rotate([0, 0, 180]) {
      mirror([1, 0, 0]) {
        knuckle_assembly(show_wheel=show_wheels,
                         show_bearing=show_bearing,
                         rotation_dir=-3.6);
      }
    }

    if (show_ackermann_triangle) {
      translate([0, 0, knuckle_height + knuckle_pin_lower_height
                 + steering_rack_support_thickness / 2
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