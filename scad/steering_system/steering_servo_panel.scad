/**
 * Module: Steering servo panel
 *
 *
 **************************************************************************************
 *                          Simplified View (A frontal perspective)
 **************************************************************************************
 *                          +---------------------------+
 *                          |                           |
 *                          |         M2 screws         |
 *                          |        /         \        |
 *                          |       *          *        |
 *                          |      +-------------+      |
 *                          |      |             |      |
 *                          |      |  vertical   |      |
 *                          |      |  servo slot |      |
 *                          |      |  hole for   |      |
 *                          |      |  pinion     |      |
 *                          |      |             |      |
 *                          |      |             |      |
 * knuckle_lower_connector  |      |             |      |                   knuckle_lower_connector
 * ---------                |      |             |      |                  ----------
 *    |                     |      |             |      |                     |
 *    v                     |      |             |      |                     v
 *   +---+                 +-----------------------------+                 +---+
 *   |   |                 |         front_h             |                 |   |
 *   +---+-----------------+-----------------------------+-----------------+---+
 *   |                         rack_mount_panel()                              |
 *   +-------------------------------------------------------------------------+
 *
 *  z
 *  |
 *  y---x
 *
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
use <../util.scad>
include <../placeholders/servo.scad>
use <bracket.scad>
use <shaft.scad>

use <rack_knuckle.scad>
use <rack_connector.scad>
use <rack.scad>
use <pinion.scad>

function steering_servo_panel_extra_w() = (servo_gearbox_h + servo_gear_h / 2);

extra_w = steering_servo_panel_extra_w();

module rack_mount_panel(rack_size=[rack_pan_full_len,
                                   rack_rail_width,
                                   rack_base_h],
                        rack_r=rack_rad) {
  panel_len = rack_size[0];
  y = rack_size[1];
  z = rack_size[2];
  offst = panel_len / 2;
  rad = y / 2;
  side_offsets = [-offst + rad, offst - rad];
  union() {
    linear_extrude(height=z, center=true) {
      rounded_rect(size=[panel_len, y], center=true, r=rad);
    }
    for (x = side_offsets) {
      translate([x, 0, lower_knuckle_h]) {
        knuckle_lower_connector(upper_knuckle_d=upper_knuckle_d,
                                upper_knuckle_h=upper_knuckle_h,
                                lower_knuckle_h=lower_knuckle_h,
                                lower_knuckle_d=lower_knuckle_d,
                                center_screw_dia=m2_hole_dia);
      }
    }
  }
}

module steering_servo_panel(size=[servo_hat_w,
                                  rack_width,
                                  pinion_d + steering_servo_slot_width],
                            thickness=steering_servo_panel_thickness,
                            front_h=rack_base_h + lower_knuckle_h,
                            front_w=10,
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

            rack_mount_panel();

            rotate([90, 0, 0]) {
              translate([0, (front_h + thickness) / 2, -y / 2]) {
                translate([0, 0, rack_width + thickness / 2]) {
                  linear_extrude(height=thickness, center=true) {
                    rounded_rect([front_w, front_h], center=center, r=0);
                  }
                }

                translate([0, 0, -thickness / 2]) {
                  linear_extrude(height=thickness, center=true) {
                    rounded_rect([front_w, front_h], center=center, r=0);
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

steering_servo_panel();