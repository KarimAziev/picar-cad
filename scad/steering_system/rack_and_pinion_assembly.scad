/**
 * Module: Rack And Pinion Assembly
 *
 * This file defines the complete structural and visual assembly of the steering system,
 * including key interactive mechanical components such as the steering rack, pinion gear,
 * rack links, knuckles, kingpins, tie rods etc.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

use <../placeholders/servo.scad>
use <../placeholders/steering_servo.scad>
use <ackermann_geometry_triangle.scad>
use <steering_pinion.scad>
use <rack_link.scad>
use <steering_panel.scad>
use <knuckle.scad>
use <rack_connector.scad>
use <rack.scad>
use <rack_util.scad>
use <tie_rod.scad>

show_ackermann_triangle = false;
show_wheels             = false;
show_bearing            = true;
show_servo_mount_panel  = true;
show_brackets           = true;
show_rack               = true;
show_kingpin_posts      = true;
show_pinion             = true;
show_tie_rod            = true;
show_servo              = true;
show_knuckles           = true;

show_knuckle_bolts      = true;

show_bolts_info         = true;
show_kingpin_bolt       = true;
show_hinges_bolts       = true;
show_panel_bolt         = true;

fasten_kingpin_bolt     = true;
fasten_hinges_bolts     = true;
fasten_panel_bolt       = true;

show_distance           = false;

module knuckle_assembly(show_wheel=true,
                        show_bearing=true,
                        show_shaft=true,
                        show_tie_rod=false,
                        show_knuckle_bolts=true,
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
                    show_tie_rod=show_tie_rod,
                    show_bolts=show_knuckle_bolts,
                    show_shaft=show_shaft);
    }
  }
}

module steering_system_distance_between_rack_and_knuckle(w=5) {
  translate([steering_rack_connector_x_pos -
             steering_distance_between_kingpin_and_rack,
             0,
             knuckle_height + knuckle_pin_lower_height]) {
    color("chartreuse", alpha=0.6) {
      linear_extrude(height=1, center=false) {
        square([steering_distance_between_kingpin_and_rack, w], center=false);
      }
    }

    translate([steering_distance_between_kingpin_and_rack / 2, w * 0.1, 0]) {
      color("darkblue") {
        linear_extrude(height=1, center=false) {
          text(str(steering_distance_between_kingpin_and_rack, "mm"),
               size=w * 0.7,
               halign="center",
               valign="bottom",
               font = "Liberation Sans:style=Bold Italic");
        }
      }
    }
  }
}

module steering_system_assembly(rack_color="white",
                                pinion_color=matte_black,
                                panel_color="white",
                                show_wheels=show_wheels,
                                show_bearing=show_bearing,
                                show_servo_mount_panel=show_servo_mount_panel,
                                show_brackets=show_brackets,
                                show_rack=show_rack,
                                show_distance=show_distance,
                                show_kingpin_posts=show_kingpin_posts,
                                show_pinion=show_pinion,
                                show_tie_rod=show_tie_rod,
                                show_servo=show_servo,
                                show_knuckles=show_knuckles,
                                show_ackermann_triangle=show_ackermann_triangle,
                                show_kingpin_bolt=show_kingpin_bolt,
                                show_hinges_bolts=show_hinges_bolts,
                                show_panel_bolt=show_panel_bolt,
                                fasten_kingpin_bolt=fasten_kingpin_bolt,
                                fasten_hinges_bolts=fasten_hinges_bolts,
                                fasten_panel_bolt=fasten_panel_bolt,
                                show_knuckle_bolts=show_knuckle_bolts,
                                show_bolts_info=show_bolts_info,
                                center_y=true) {

  translate([0,
             center_y ? 0 : -steering_rack_support_width / 2,
             steering_rack_support_thickness / 2]) {
    union() {
      steering_panel(show_servo=show_servo,
                     show_pinion=show_pinion,
                     panel_color=panel_color,
                     pinion_color=pinion_color,
                     show_rack=show_rack,
                     show_servo_mount_panel=show_servo_mount_panel,
                     show_kingpin_posts=show_kingpin_posts,
                     show_brackets=show_brackets,
                     show_kingpin_bolt=show_kingpin_bolt,
                     show_hinges_bolts=show_hinges_bolts,
                     show_panel_bolt=show_panel_bolt,
                     fasten_kingpin_bolt=fasten_kingpin_bolt,
                     fasten_hinges_bolts=fasten_hinges_bolts,
                     fasten_panel_bolt=fasten_panel_bolt,
                     show_bolts_info=show_bolts_info,
                     rack_color=rack_color);

      knuckle_rotation_angle = assembly_use_front_steering ? 0 : 180;

      if (show_distance) {
        steering_system_distance_between_rack_and_knuckle();
      }
      if (show_knuckles) {
        rotate([0, 0, knuckle_rotation_angle]) {
          knuckle_assembly(show_wheel=show_wheels,
                           show_bearing=show_bearing,
                           show_knuckle_bolts=show_knuckle_bolts,
                           show_tie_rod=show_tie_rod);
        }
        rotate([0, 0, knuckle_rotation_angle]) {
          mirror([1, 0, 0]) {
            knuckle_assembly(show_wheel=show_wheels,
                             show_knuckle_bolts=show_knuckle_bolts,
                             show_bearing=show_bearing);
          }
        }
      }

      if (show_ackermann_triangle) {
        translate([0,
                   0,
                   knuckle_height + knuckle_pin_lower_height
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
}

steering_system_assembly();