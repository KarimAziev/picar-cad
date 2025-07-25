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
include <../colors.scad>
use <bracket.scad>
use <knuckle.scad>
use <rack_connector.scad>
use <rack.scad>
use <bearing_shaft.scad>

module knuckle_lower_connector() {
  bearing_shaft_connector(lower_d=knuckle_dia,
                          lower_h=knuckle_pin_lower_height,
                          shaft_h=knuckle_pin_bearing_height,
                          shaft_d=knuckle_bearing_inner_dia,
                          chamfer_h=knuckle_pin_chamfer_height,
                          stopper_h=knuckle_pin_stopper_height);
}

module rack_mount_panel() {
  half_of_len = rack_mount_panel_len / 2;
  half_of_width = rack_mount_panel_width / 2;
  knuckle_rad = knuckle_dia / 2;
  knuckle_connectors_x_offsets = [-half_of_len + knuckle_dia / 2,
                                  half_of_len - knuckle_dia / 2];

  union() {
    linear_extrude(height=rack_mount_panel_thickness, center=true) {
      difference() {
        union() {
          translate([half_of_len - knuckle_rad, 0, 0]) {
            circle(r = knuckle_rad, $fn=360);
          }
          translate([-half_of_len + knuckle_rad, 0, 0]) {
            circle(r = knuckle_rad, $fn=360);
          }
          rounded_rect(size=[steering_servo_slot_width,
                             steering_servo_panel_screws_offsets[1]
                             + steering_servo_panel_screws_dia * 2 + 3],
                       center=true, r=min(steering_servo_slot_width,
                                          rack_mount_panel_width) * 0.2);
          rounded_rect(size=[rack_mount_panel_len,
                             rack_mount_rack_panel_width],
                       center=true);
        }
        four_corner_holes_2d(steering_servo_panel_screws_offsets,
                             hole_dia=steering_servo_panel_screws_dia,
                             center=true);
      }
    }
    translate([0, -rack_mount_panel_width / 2, 0]) {
      vertical_servo_plate();
    }

    translate([0,
               -half_of_width - steering_servo_panel_thickness / 2,
               -rack_mount_panel_thickness / 2]) {
      width = steering_servo_extra_width + steering_servo_slot_height;
      linear_extrude(height = rack_mount_panel_thickness) {
        square([width, steering_servo_panel_thickness],
               center=true);
      }
    }
    for (x = knuckle_connectors_x_offsets) {
      translate([x, 0, rack_mount_panel_thickness / 2]) {
        knuckle_lower_connector();
      }
    }
  }
}

module vertical_servo_plate(size=[steering_servo_slot_width,
                                  steering_servo_slot_height],
                            screws_dia=steering_servo_screw_dia,
                            screws_offset=steering_servo_screws_offset,
                            extra_h=rack_mount_panel_thickness + 0.5,
                            extra_w=steering_servo_extra_width,
                            thickness=steering_servo_panel_thickness,
                            center=false) {

  slot_w = size[0];
  slot_h = size[1];
  screws_offst_x = screw_x_offst(slot_w, screws_dia, screws_offset);
  w = extra_w + screws_dia * 2 + slot_w;
  h = slot_h + extra_w;

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

          square([slot_h + 0.2, slot_w + 0.4], center=true);

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

module steering_servo_panel(size=[servo_hat_w,
                                  rack_width],
                            front_h=rack_base_h + tooth_h,
                            thickness=1,
                            front_w=10,
                            z_r=undef,
                            center=true,
                            show_servo=false) {

  x = size[0];
  y = size[1];

  y_r = is_undef(z_r) ? 0 : z_r;
  z_r = y / 2;

  union() {
    difference() {
      union() {
        color(matte_black) {
          union() {
            rack_mount_panel();
            rotate([90, 0, 0]) {
              translate([0, (front_h + thickness) / 2, -y / 2]) {
                rad = min(front_w, front_h) * 0.3;

                translate([0, 0, rack_width + thickness / 2]) {
                  linear_extrude(height=thickness, center=true) {
                    rounded_rect_two([front_w, front_h], center=center, r=rad);
                  }
                }

                translate([0, 0, -thickness / 2]) {
                  linear_extrude(height=thickness, center=true) {
                    rounded_rect_two([front_w, front_h], center=center, r=rad);
                  }
                }
              }
            }
          }
        }
      }
    }

    if (show_servo) {
      z_offst = rack_mount_panel_thickness + 1;

      y_offst = -servo_size[2] / 2
        - rack_mount_panel_width / 2
        + screws_hat_z_offset
        - steering_servo_panel_thickness
        - servo_hat_thickness / 2;

      translate([0, y_offst, servo_hat_w / 2 + z_offst / 2]) {
        rotate([90, -90, 0]) {
          servo();
        }
      }
    }
  }
}

steering_servo_panel(show_servo=false);
