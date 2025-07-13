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
 * knuckle_lower_connector  |      |             |      |
 *                          |      |             |      |                 knuckle_lower_connector
 *    |                     |      |             |      |                    |
 *    v                     |      |             |      |                    v
 *   +---+                  |      |_ +--------+_|      |                  +---+
 *   |   |                  |         | front_h|        |                  |   |
 *   +---+------------------+--------+--------+---------+------------------+---+
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
use <knuckle.scad>
use <rack_connector.scad>
use <rack.scad>
use <pinion.scad>
use <bearing_shaft.scad>

function steering_servo_panel_extra_w() = (servo_gearbox_h + servo_gear_h / 2);

extra_w = steering_servo_panel_extra_w();

module knuckle_lower_connector() {
  bearing_shaft_connector(lower_d=knuckle_dia,
                          lower_h=knuckle_pin_lower_height,
                          shaft_h=knuckle_pin_bearing_height,
                          shaft_d=knuckle_bearing_inner_dia,
                          chamfer_h=knuckle_pin_chamfer_height);
}

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
  difference() {
    union() {
      linear_extrude(height=z, center=true) {
        rounded_rect(size=[panel_len, y], center=true, r=rad);
      }

      translate([0, -y / 2, -z / 2]) {
        color("lightcoral") {
          vertical_servo_plate();
        }
      }
      for (x = side_offsets) {
        translate([x, 0, knuckle_pin_lower_height]) {
          difference() {
            knuckle_lower_connector();
          }
        }
      }
    }
  }
}

module vertical_servo_plate(size=[steering_servo_slot_width,
                                  steering_servo_slot_height],
                            screws_dia=steering_servo_screw_dia,
                            screws_offset=steering_servo_screws_offset,
                            extra_h=pinion_z_offst,
                            extra_w=4,
                            thickness=steering_servo_panel_thickness,
                            center=false) {

  slot_w = size[0];
  slot_h = size[1];
  screws_offst_x = screw_x_offst(slot_w, screws_dia, screws_offset);
  w = extra_w + screws_dia * 2 + slot_w;
  h = slot_h + extra_w;

  translate([0, 0, 0]) {
    rotate([90, 0, 0]) {
      linear_extrude(height=thickness, center=center) {
        full_h = h + extra_h;
        translate([0, full_h, 0]) {
          difference() {
            union() {
              rounded_rect_two([h, w], r=4, center=true);
              translate([0, -w / 2 - extra_h / 2, 0]) {
                square([h, extra_h], center=true);
              }
            }

            square([slot_h, slot_w], center=true);

            for (x = [-screws_offst_x, screws_offst_x]) {
              translate([0, x, 0]) {
                circle(r=screws_dia * 0.5, $fn=360);
              }
            }
          }
        }
      }
    }
  }
}

module steering_servo_panel(size=[servo_hat_w,
                                  rack_width,
                                  pinion_d + steering_servo_slot_width],
                            thickness=steering_servo_panel_thickness,
                            front_h=rack_base_h + knuckle_pin_lower_height,
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

            rack_mount_panel();

            rotate([90, 0, 0]) {
              thickness = 1;
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
    }

    if (show_servo) {
      y_offst = -servo_gear_h / 2 - servo_gearbox_h / 2 - screws_hat_z_offset;
      translate([0, -servo_size[2] / 2 - rack_rail_width / 2
                 + screws_hat_z_offset + servo_hat_thickness / 2, 0]) {
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
// vertical_servo_plate();
