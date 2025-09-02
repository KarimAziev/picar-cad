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
 *                          |         M2 screw hole     |
 *                          |                           |
 *                          |            *              |
 *                          |      +-------------+      |
 *                          |      |             |      |
 *                          |      |  vertical   |      |
 *                          |      |  servo slot |      |
 *                          |      |  hole for   |      |
 *                          |      |  pinion     |      |
 *                          |      |             |      |
 *                          |      |             |      |
 * steering_kingpin_post    |      |             |      |
 *                          |      |             |      |                 steering_kingpin_post
 *    |                     |      |             |      |                    |
 *    v                     |      |             |      |                    v
 *   +---+                  |      +------------+|      |                  +---+
 *   |   |                  |         | front_h|        |                  |   |
 *   +---+------------------+--------+--------+---------+------------------+---+
 *   |   |                      steering_rack_support()                    |   | -----> steering_panel_kingpin_connector
 *   +-------------------------------------------------------------------------+
 *     |
 *     |
 *     v
 *     steering_panel_kingpin_connector
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
include <../colors.scad>
use <../util.scad>
use <../placeholders/steering_servo.scad>
use <steering_kingpin_post.scad>
use <rack_util.scad>
use <steering_pinion.scad>
use <bearing_shaft.scad>
use <steering_rail.scad>
use <rack.scad>
use <knuckle_connector.scad>
use <../l_bracket.scad>
use <steering_servo_mount.scad>

steering_hinge_screw_rad = steering_panel_hinge_screw_dia / 2;

module steering_panel_kingpin_connector() {
  knuckle_rad = knuckle_dia / 2;
  border_w = steering_kingpin_post_border_w;
  difference() {
    linear_extrude(height=steering_rack_support_thickness,
                   convexity=2,
                   center=false) {
      difference() {
        ring_2d(r=knuckle_rad, $fn=360, fn=100, w=border_w);
        circle(r=steering_hinge_screw_rad, $fn=360);
      }
    }
    steering_kingpin_post_screw_holes();
  }
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
               + steering_hinge_screw_rad
               + steering_panel_hinge_screw_distance,
               0]) {
      circle(r=steering_hinge_screw_rad, $fn=360);
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
               + steering_hinge_screw_rad,
               0]) {
      circle(r=steering_hinge_screw_rad, $fn=360);
    }
  }
}

module steering_chassis_bar_2d(x_offsets) {
  notch_w = calc_notch_width(knuckle_dia, steering_rack_support_width);
  difference() {
    rounded_rect(size=[steering_panel_length
                       - knuckle_dia * 2
                       + notch_w,
                       steering_rack_support_width],
                 center=true,
                 r=0);
    for (x = is_undef(x_offsets)
           ? knuckle_connectors_x_offsets()
           : x_offsets) {
      translate([x, 0, steering_rack_support_thickness / 2]) {
        circle(r=steering_hinge_screw_rad, $fn=360);
      }
    }
  }
}

module steering_rack_support(show_rack=false,
                             show_brackets=true,
                             show_kingpin_posts=false,
                             panel_color,
                             rack_color) {
  half_of_len = steering_panel_length / 2;
  knuckle_rad = knuckle_dia / 2;
  knuckle_x_poses = [half_of_len - knuckle_rad,
                     -half_of_len + knuckle_rad];

  side_connector_offst_x = steering_panel_hinges_calc_distance_from_center();
  servo_mount_clearance = 0.2;

  union() {
    color(panel_color, alpha=1) {
      union() {
        difference() {
          linear_extrude(height=steering_rack_support_thickness,
                         center=true) {
            steering_chassis_bar_2d(knuckle_x_poses);
          }
          translate([0, steering_rack_support_width, 0]) {
            steering_servo_mount_panel_screw_holes();
          }

          translate([0, -servo_mount_clearance / 2, 0]) {
            steering_servo_mount_connector(clearance=servo_mount_clearance);
          }
        }

        for (x = knuckle_x_poses) {
          translate([x, 0, -steering_rack_support_thickness
                     / 2]) {
            steering_panel_kingpin_connector();
            if (show_kingpin_posts) {
              translate([0, 0, 0.01]) {
                steering_kingpin_post();
              }
            }
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
      }
    }

    if (show_rack) {
      translate([0, 0, steering_rack_support_thickness / 2
                 + steering_rack_z_distance_from_panel]) {
        rotate([0, 0, 180]) {
          rack_mount(show_brackets=show_brackets,
                     rack_color=is_undef(rack_color) ?
                     panel_color
                     : rack_color);
        }
      }
    }
  }
}

module steering_panel(panel_color,
                      rack_color,
                      show_rack=false,
                      show_servo_mount_panel=false,
                      show_servo=false,
                      show_pinion=true,
                      show_brackets=true,
                      show_kingpin_posts=false,
                      pinion_color=blue_grey_carbon) {
  union() {
    union() {
      steering_rack_support(panel_color=panel_color,
                            show_rack=show_rack,
                            show_brackets=show_brackets,
                            show_kingpin_posts=show_kingpin_posts,
                            rack_color=rack_color);
      translate([0, 0, steering_rack_support_thickness / 2]) {
        color(panel_color, alpha=1) {
          steering_rail();
          mirror_copy([0, 1, 0]) {
            steering_rack_anti_tilt_key();
          }
        }
      }
      if (show_servo_mount_panel) {
        steering_servo_mount(show_pinion=show_pinion,
                             show_servo=show_servo,
                             pinion_color=pinion_color);
      }
    }
  }
}

steering_panel(panel_color="white",
               show_servo=false,
               show_rack=false,
               show_brackets=false,
               rack_color=cobalt_blue_metalic,
               show_kingpin_posts=false,
               show_servo_mount_panel=false,
               show_pinion=true);
