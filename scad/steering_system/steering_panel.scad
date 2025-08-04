/**
 * Module: Steering servo panel
 *
 * This module defines the main steering servo mounting structure responsible for
 * housing and aligning the servo motor and its associated steering pinion with
 * the rack-and-pinion steering mechanism. It functions as the core frame
 * for motion transfer from a servo to the rack, and ultimately to the front wheels
 * via brackets and steering knuckles.
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
 *   |                         steering_rack_support()                              |
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
use <rack_util.scad>
use <steering_pinion.scad>
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

function steering_panel_center_rect_y() =
  steering_panel_center_screws_offsets[1]
  + steering_panel_center_screw_dia * 2 + 3;

function steering_panel_hinges_calc_distance_from_center() =
  poly_width_at_y(chassis_shape_points,
                  steering_panel_y_pos_from_center
                  - steering_panel_hinge_length)
  - steering_rack_support_width / 2;

function knuckle_connectors_x_offsets() =
  let (half_of_len=steering_panel_length / 2,
       knuckle_rad = knuckle_dia / 2)
  [half_of_len - knuckle_rad,
   -half_of_len + knuckle_rad];

module steering_panel_hinge_2d() {
  y = steering_panel_hinge_length
    + steering_panel_hinge_rad;
  difference() {
    rounded_rect(size=[steering_rack_support_width, y],
                 center=true,
                 r=steering_panel_hinge_rad,
                 fn=100);
    translate([0,
               -y / 2
               + steering_panel_hinge_screw_dia / 2
               + steering_panel_hinge_screw_distance,
               0]) {
      circle(r=steering_panel_hinge_screw_dia / 2, $fn=360);
    }
  }
}

module steering_panel_hinges_screws_holes() {
  side_connector_offst_x = steering_panel_hinges_calc_distance_from_center();

  y = steering_panel_hinge_length
    + steering_panel_hinge_rad;

  difference() {
    translate([side_connector_offst_x,
               (-steering_rack_support_width / 2
                -steering_panel_hinge_length / 2
                + steering_panel_hinge_rad)
               + steering_panel_y_pos_from_center - y / 2
               + steering_panel_hinge_screw_distance
               + steering_panel_hinge_screw_dia / 2,
               0]) {
      circle(r=steering_panel_hinge_screw_dia / 2, $fn=360);
    }
  }
}

module steering_chassis_bar_2d(x_offsets) {
  difference() {
    rounded_rect(size=[steering_panel_length,
                       steering_rack_support_width],
                 center=true,
                 r=steering_rack_support_width * 0.5);
    for (x = is_undef(x_offsets)
           ? knuckle_connectors_x_offsets()
           : x_offsets) {
      translate([x, 0, steering_rack_support_thickness / 2]) {
        circle(r=steering_panel_hinge_screw_dia / 2, $fn=360);
      }
    }
  }
}

module steering_rack_support(show_rack=false) {
  half_of_len = steering_panel_length / 2;
  knuckle_rad = knuckle_dia / 2;
  knuckle_x_poses = [half_of_len - knuckle_rad,
                     -half_of_len + knuckle_rad];

  center_panel_width = steering_panel_center_rect_y();
  side_connector_offst_x = steering_panel_hinges_calc_distance_from_center();

  union() {
    linear_extrude(height=steering_rack_support_thickness,
                   center=true) {
      difference() {
        union() {
          for (x = knuckle_x_poses) {
            translate([x, 0, 0]) {
              difference() {
                circle(r = knuckle_rad, $fn=360);
                circle(r = steering_panel_hinge_screw_dia / 2, $fn=360);
              }
            }
          }
          rounded_rect_two(size=[steering_servo_slot_width,
                                 center_panel_width],
                           center=true,
                           r=min(steering_servo_slot_width,
                                 center_panel_width) * 0.1);
          steering_chassis_bar_2d(knuckle_x_poses);
        }
        four_corner_holes_2d(steering_panel_center_screws_offsets,
                             hole_dia=steering_panel_center_screw_dia,
                             center=true);
      }
    }

    for (x = knuckle_x_poses) {
      translate([x, 0, steering_rack_support_thickness
                 / 2]) {
        knuckle_lower_connector();
      }
    }

    mirror_copy([1, 0, 0]) {
      translate([side_connector_offst_x,
                 -steering_rack_support_width / 2
                 -steering_panel_hinge_length / 2
                 + steering_panel_hinge_rad,
                 -steering_rack_support_thickness / 2]) {
        linear_extrude(height=max(steering_rack_support_thickness * 0.4, 1),
                       center=false) {
          steering_panel_hinge_2d();
        }
      }
    }

    if (show_rack) {
      translate([0, 0, steering_rack_support_thickness / 2]) {
        rack_mount(show_brackets=true);
      }
    }
  }
}

module steering_panel(size=[servo_hat_w,
                            steering_rack_width],
                      front_h=steering_panel_rail_height,
                      thickness=steering_panel_rail_thickness,
                      front_w=steering_panel_rail_len,
                      show_rack=false,
                      z_r=undef,
                      center=true,
                      show_servo=false,
                      show_pinion=true) {

  x = size[0];
  y = size[1];

  y_r = is_undef(z_r) ? 0 : z_r;
  z_r = y / 2;

  union() {
    union() {
      steering_rack_support(show_rack=show_rack);
      translate([0, -steering_center_panel_width / 2, 0]) {
        steering_vertical_servo_mount();
        translate([0,
                   -steering_vertical_panel_thickness / 2,
                   -steering_rack_support_thickness / 2]) {
          width = steering_servo_extra_width + steering_servo_slot_height;
          rotate([0, 0, 180]) {
            linear_extrude(height=steering_rack_support_thickness) {
              rounded_rect_two([steering_servo_slot_width,
                                steering_vertical_panel_thickness],
                               center=true);
            }
          }
        }
      }
      rotate([90, 0, 0]) {
        translate([0, (front_h + thickness) / 2, -y / 2]) {
          rad = min((min(front_w, front_h) * 0.1), 2);

          translate([0, 0, steering_rack_width + thickness / 2]) {
            linear_extrude(height=thickness, center=true) {
              rounded_rect_two([front_w, front_h], center=center, r=rad);
            }
          }

          translate([0, 0, -thickness / 2 - 0.1]) {
            linear_extrude(height=thickness, center=true) {
              rounded_rect_two([front_w, front_h], center=center, r=rad);
            }
          }
        }
      }
    }

    if (show_servo) {
      slot_w = steering_servo_slot_width;
      slot_h = steering_servo_slot_height;
      screws_dia = steering_servo_screw_dia;
      screws_offset=steering_servo_screws_offset;
      extra_h=steering_rack_support_thickness + steering_servo_extra_h;
      extra_w=steering_servo_extra_width;
      screws_offst_x = screw_x_offst(slot_w, screws_dia, screws_offset);
      w = extra_w + screws_dia * 2 + slot_w;
      h = slot_h + extra_w;
      full_h = h + extra_h;
      z_offst = 0;

      y_offst = -servo_size[2] / 2
        - steering_center_panel_width / 2
        + screws_hat_z_offset
        - steering_vertical_panel_thickness
        - servo_hat_thickness / 2;

      translate([0, 0, full_h]) {
        translate([0, y_offst, 0]) {
          rotate([90, -90, 0]) {
            if (show_pinion) {
              servo() {
                translate([0, 0, 0]) {
                  rotate([0, 0, $t == 0 ? 12.0 : 7 + pinion_angle(t=$t)]) {
                    translate([0, 0, 2]) {
                      color(blue_grey_carbon, alpha=1) {
                        steering_pinion();
                      }
                    }
                  }
                }
              }
            } else {
              servo();
            }
          }
        }
      }
    }
  }
}

module steering_vertical_servo_mount(size=[steering_servo_slot_width,
                                           steering_servo_slot_height],
                                     screws_dia=steering_servo_screw_dia,
                                     screws_offset=steering_servo_screws_offset,
                                     extra_h=steering_rack_support_thickness
                                     + steering_servo_extra_h,
                                     extra_w=steering_servo_extra_width,
                                     thickness=
                                     steering_vertical_panel_thickness,
                                     center=false) {

  slot_w = size[0];
  slot_h = size[1];
  screws_offst_x = screw_x_offst(slot_w, screws_dia, screws_offset);
  w = extra_w + screws_dia * 2 + slot_w;
  h = slot_h + extra_w;
  full_h = h + extra_h;

  rotate([90, 0, 0]) {
    translate([0, full_h, 0]) {
      linear_extrude(height=thickness, center=center) {
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

steering_panel(show_servo=false,
               show_rack=false,
               show_pinion=true);
