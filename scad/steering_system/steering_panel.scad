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
 *                          |         M2 bolt hole     |
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

use <../placeholders/steering_servo.scad>
use <steering_kingpin_post.scad>
use <rack_util.scad>
use <steering_pinion.scad>
use <bearing_shaft.scad>
use <steering_rail.scad>
use <rack.scad>
use <knuckle_connector.scad>
use <../lib/l_bracket.scad>
use <steering_servo_mount.scad>
use <../lib/functions.scad>
use <../lib/shapes2d.scad>
use <../lib/transforms.scad>
use <../lib/holes.scad>
use <../components/chassis/util.scad>
use <../lib/slots.scad>



steering_hinge_bolt_rad = steering_panel_hinge_bolt_dia / 2;

hinge_pts = scale_upper_trapezoid_pts(x=steering_panel_hinge_w,
                                      y=steering_panel_hinge_length
                                      + steering_panel_hinge_corner_rad);

hinge_h                 = max(steering_rack_support_thickness * 0.8,
                              1);

module steering_panel_kingpin_connector() {
  knuckle_rad = knuckle_dia / 2;
  border_w = steering_kingpin_post_border_w;
  difference() {
    linear_extrude(height=steering_rack_support_thickness,
                   convexity=2,
                   center=false) {
      difference() {
        ring_2d(r=knuckle_rad, $fn=360, fn=100, w=border_w);
        circle(r=steering_hinge_bolt_rad, $fn=360);
      }
    }
    steering_kingpin_post_bolt_holes();
  }
}

function steering_panel_hinges_calc_x_distance() =
  poly_width_at_y(chassis_upper_pts,
                  chassis_upper_len - steering_panel_distance_from_top)
  - steering_panel_hinge_w / 2
  - steering_panel_hinge_x_offset;

function knuckle_connectors_x_offsets() =
  let (half_of_len=steering_panel_length / 2,
       knuckle_rad = knuckle_dia / 2)
  [half_of_len - knuckle_rad,
   -half_of_len + knuckle_rad];

module hinge_3d(slot_mode=false) {
  max_d = max(steering_panel_hinge_bolt_dia, steering_panel_hinge_bore_dia);
  if (slot_mode) {
    translate([max_d / 2 + steering_panel_hinge_bolt_x_distance,
               max_d / 2 + steering_panel_hinge_bolt_distance,
               0]) {
      counterbore(h=chassis_thickness,
                  d=steering_panel_hinge_bolt_dia,
                  bore_d=steering_panel_hinge_chassis_bore_dia,
                  bore_h=chassis_counterbore_h,
                  sink=true,
                  fn=100,
                  reverse=true);
    }
  } else {
    difference() {
      linear_extrude(height=hinge_h, center=false) {
        offset_vertices_2d(r=steering_panel_hinge_corner_rad) {
          polygon(hinge_pts);
        }
      }
      translate([max_d / 2 + steering_panel_hinge_bolt_x_distance,
                 max_d / 2 + steering_panel_hinge_bolt_distance,
                 0]) {
        counterbore(h=hinge_h,
                    d=steering_panel_hinge_bolt_dia,
                    bore_d=steering_panel_hinge_bore_dia,
                    bore_h=hinge_h / 2,
                    sink=false,
                    fn=100,
                    reverse=false);
      }
    }
  }
}

module steering_chassis_bar_3d(length=steering_panel_length,
                               x_offsets=knuckle_connectors_x_offsets(),
                               center_y=false) {
  translate([0, center_y ? 0 : -steering_rack_support_width / 2, 0]) {
    difference() {
      linear_extrude(height=chassis_thickness, center=false) {
        rounded_rect(size=[length,
                           steering_rack_support_width],
                     center=true,
                     r=steering_rack_support_width * 0.5);
      }
      for (x = x_offsets) {
        translate([x, 0, 0]) {
          counterbore(h=chassis_thickness,
                      d=steering_panel_hinge_bolt_dia,
                      bore_d=steering_panel_hinge_bore_dia,
                      bore_h=steering_panel_hinge_bore_h,
                      sink=true,
                      fn=100,
                      reverse=true);
        }
      }
    }
  }
}

module steering_hinges(slot_mode=false) {
  side_connector_offst_x = steering_panel_hinges_calc_x_distance();
  mirror_copy([1, 0, 0]) {
    translate([side_connector_offst_x,
               -steering_rack_support_width / 2 - steering_panel_hinge_length,
               slot_mode ? 0 : -steering_rack_support_thickness / 2]) {
      hinge_3d(slot_mode=slot_mode);
    }
  }
}

module steering_rack_support(show_rack=false,
                             show_brackets=true,
                             show_kingpin_posts=false,
                             panel_color,
                             rack_color) {
  half_of_len = steering_panel_length / 2;
  notch_w = calc_notch_width(steering_rack_support_width < knuckle_dia
                             ? knuckle_dia
                             : steering_rack_support_width,
                             steering_rack_support_width < knuckle_dia
                             ? steering_rack_support_width
                             : knuckle_dia);
  knuckle_rad = knuckle_dia / 2;
  knuckle_x_poses = [half_of_len - knuckle_rad,
                     -half_of_len + knuckle_rad];
  servo_mount_clearance = 0.2;

  union() {
    color(panel_color, alpha=1) {
      union() {
        difference() {
          linear_extrude(height=steering_rack_support_thickness,
                         center=true) {
            rounded_rect(size=[steering_panel_length
                               - knuckle_dia * 2
                               + (is_num(notch_w) ? notch_w : 0),
                               steering_rack_support_width],
                         center=true,
                         r=0);
          }
          translate([0, steering_rack_support_width, 0]) {
            steering_servo_mount_panel_bolt_holes();
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

        steering_hinges();
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
                      pinion_color=blue_grey_carbon,
                      center_y=true) {
  translate([0, center_y ? 0 : -steering_rack_support_width / 2, 0]) {
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

// steering_panel(panel_color="white",
//                show_servo=false,
//                show_rack=false,
//                show_brackets=false,
//                rack_color=cobalt_blue_metallic,
//                show_kingpin_posts=false,
//                show_servo_mount_panel=false,
//                show_pinion=true,
//                center_y=false);
steering_rack_support();

// translate([0, 0, 0]) {
//   #cube([steering_panel_hinge_w, steering_panel_hinge_length, 7]);
// }
