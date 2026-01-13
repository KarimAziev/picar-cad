/**
 * Module: Steering Servo Mount
 *
 * This file defines a detachable vertical panel with a servo slot.
 *
 * This panel attaches to the steering panel with two bolts. By default, M3
 * bolts are used, but this can be changed via the
 * `steering_servo_mount_connector_bolt_dia` variable.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/l_bracket.scad>
use <../lib/plist.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/servo.scad>
use <../placeholders/steering_servo.scad>
use <rack_util.scad>
use <steering_pinion.scad>

show_servo             = true;
show_pinion            = true;
show_bolts             = true;
show_nuts              = true;
echo_bolts_info        = true;
show_servo_horn        = true;
show_servo_horn_bolt   = true;
show_servo_horn_screws = true;

function steering_servo_mount_pass_through_len() =
  steering_rack_support_width
  + steering_vertical_panel_thickness
  + steering_servo_mount_connector_length;

module steering_servo_mount_connector(clearance=0.0) {
  thickness = steering_servo_mount_connector_thickness + clearance;
  length = clearance + steering_servo_mount_connector_length;
  translate([-steering_servo_mount_width / 2,
             -steering_rack_support_width / 2,
             -thickness / 2]) {
    cube([steering_servo_mount_width,
          length,
          thickness]);
  }
}

module steering_servo_mount_with_bolt_mirror_x_positions() {
  r = steering_servo_mount_connector_bolt_dia / 2;

  mirror_copy([1, 0, 0]) {
    translate([steering_servo_mount_width / 2
               - r
               - steering_servo_mount_connector_bolt_x,
               0,
               0]) {
      children();
    }
  }
}

module steering_servo_mount_panel_bolt_holes() {
  h = steering_servo_mount_pass_through_len()
    + 1;

  steering_servo_mount_with_bolt_mirror_x_positions() {
    rotate([90, 0, 0]) {
      cylinder(h=h,
               d=steering_servo_mount_connector_bolt_dia,
               center=false,
               $fn=150);
    }
  }
}

module steering_servo_mount(show_servo=show_servo,
                            show_pinion=show_pinion,
                            show_bolts=show_bolts,
                            show_nuts=show_nuts,
                            echo_bolts_info=echo_bolts_info,
                            show_servo_horn=show_servo_horn,
                            show_servo_horn_bolt=show_servo_horn_bolt,
                            show_servo_horn_screws=show_servo_horn_screws,
                            panel_color="white",
                            bolts_offset=steering_servo_bolts_offset,
                            servo_bolt_dia=steering_servo_bolt_dia,
                            slot_size=[steering_servo_slot_width + 0.4,
                                       steering_servo_slot_height + 0.2],
                            pinion_color="white") {
  slot_w = slot_size[0];
  slot_h = slot_size[1];
  bolts_offst = bolt_x_offst(slot_h,
                             servo_bolt_dia,
                             steering_servo_bolts_offset);

  slot_offset_y = steering_servo_mount_height / 2
    - bolts_offst
    - servo_bolt_dia * 0.5
    - steering_servo_bolt_distance_from_top;

  z_r = min(0.1 * steering_servo_mount_height, 3);

  union() {
    difference() {
      union() {

        translate([-steering_servo_mount_width / 2,
                   - steering_servo_mount_length
                   - steering_rack_support_width / 2
                   - steering_vertical_panel_thickness / 2,
                   - steering_rack_support_thickness / 2]) {
          l_bracket(size=[steering_servo_mount_width,
                          steering_servo_mount_length,
                          steering_servo_mount_height],
                    convexity=2,
                    bracket_color=panel_color,
                    vertical_thickness=steering_vertical_panel_thickness,
                    center=false,
                    thickness=steering_rack_support_thickness,
                    children_modes=[["difference", "vertical"],
                                    ["union", "vertical"]],
                    y_r=0,
                    z_r=z_r) {

            translate([0, slot_offset_y, 0]) {
              servo_slot_2d(size=[slot_w, slot_h],
                            bolts_dia=servo_bolt_dia,
                            bolts_offset=bolts_offset,
                            center=true,
                            y_axle=true);
            }

            if (show_bolts || echo_bolts_info) {
              let (d = servo_bolt_dia,
                   nut_spec = find_nut_spec(inner_d=d,
                                            lock=false),
                   nut_h = plist_get("height", nut_spec, 2),
                   bolt_h = ceil(nut_h
                                 + steering_servo_hat_thickness
                                 + steering_vertical_panel_thickness),
                   nut_head_distance=steering_servo_hat_thickness
                   + steering_vertical_panel_thickness) {
                if (echo_bolts_info) {
                  echo(str("The steering servo vertical bolt ",
                           ": M" ,
                           snap_bolt_d(d),
                           "x",
                           bolt_h,
                           "mm"));
                }
                if (show_bolts) {
                  translate([0,
                             slot_offset_y,
                             -steering_vertical_panel_thickness / 2
                             + bolt_h]) {
                    with_servo_slot_slots(size=[slot_w, slot_h],
                                          bolts_dia=servo_bolt_dia,
                                          bolts_offset=bolts_offset,
                                          center=true,
                                          y_axle=true) {
                      rotate([180, 0, 0]) {
                        bolt(h=bolt_h,
                             d=d,
                             nut_head_distance=nut_head_distance,
                             show_nut=show_nuts);
                      }
                    }
                  }
                }
              }
            }
          }
        }
        color(panel_color, alpha=1) {
          steering_servo_mount_connector();
        }
      }
      steering_servo_mount_panel_bolt_holes();
    }

    if (show_servo) {
      servo_dia = servo_bolt_dia + 0.3;
      servo_w = steering_servo_size[1];

      servo_y = -steering_servo_height_after_hat()
        - steering_servo_hat_thickness
        - steering_servo_mount_length
        - steering_vertical_panel_thickness / 2
        - steering_rack_support_width / 2;

      z_offset = steering_servo_mount_height -
        (steering_rack_support_thickness / 2)
        - bolts_offset
        - servo_dia
        - servo_dia / 2;
      translate([servo_w / 2, servo_y, z_offset]) {
        rotate([0, 90, 90]) {
          steering_servo(center=false,
                         show_servo_horn=show_servo_horn,
                         show_servo_horn_bolt=show_servo_horn_bolt,
                         show_servo_horn_screws=show_servo_horn_screws) {
            if (show_pinion) {
              rotate([0, 0, 0]) {
                translate([0, 0, 2]) {
                  color(pinion_color, alpha=1) {
                    steering_pinion();
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

module steering_servo_mount_printable(panel_color="white",) {
  steering_servo_mount(show_servo=false,
                       show_pinion=false,
                       show_bolts=false,
                       show_nuts=false,
                       show_servo_horn=false,
                       show_servo_horn_bolt=false,
                       show_servo_horn_screws=false,
                       panel_color=panel_color);
}

steering_servo_mount();
