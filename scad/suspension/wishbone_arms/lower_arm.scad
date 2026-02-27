/**
 * Module: Lower Wishbone Arm
 *
 * The lower wishbone arm is a A-shaped component connecting the chassis to the
 * lower part of the steering knuckle.
 *
 * The model is oriented along the x-axis, from the left (where the hinges are)
 * to the right apex.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../steering_params.scad>

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <barrel_hinge.scad>

default_debug = false;

module lower_arm_hinge() {
  barrel_hinge(size=[lower_arm_hinge_barrel_len,
                     lower_arm_hinge_barrel_h,
                     lower_arm_thickness],
               d=lower_arm_hinge_barrel_hole_d,
               distance=lower_arm_hinge_barrel_hole_offset);
}

module damper_boss() {
  cylinder(d1=lower_arm_damper_boss_d,
           d2=max(lower_arm_thickness, lower_arm_damper_boss_d),
           $fn=$preview ? 16 : 360,
           h=lower_arm_damper_boss_h);
}

module lower_arm(color=cobalt_blue_metallic,
                 debug=default_debug,
                 use_lower_edge_cutout=lower_arm_use_lower_edge_cutout) {
  hole_resolution = $preview ? 16 : 360;
  profile_x0 = lower_arm_hinge_barrel_hole_d / 2
    + lower_arm_hinge_barrel_hole_offset
    + lower_arm_hinge_barrel_hole_d;

  profile_length = lower_arm_len - profile_x0;

  hinge_cutout_len = lower_arm_hinge_barrel_len - profile_x0;
  hinge_cutout_h = lower_arm_h - lower_arm_hinge_barrel_h * 2;

  boss_rad = lower_arm_damper_boss_d / 2;

  cutout_depth = lower_arm_damper_boss_h + lower_arm_upper_boss_y_offset;

  hole_start_x = hinge_cutout_len + lower_arm_leg_width;

  hinge_cutout_corner_r= calc_corner_rad(size=[hinge_cutout_len,
                                               hinge_cutout_h],
                                         r_factor=0.5);

  stud_mount_len = lower_arm_ball_stud_mount_size[0];
  stud_mount_y_size = lower_arm_ball_stud_mount_size[1];
  stud_mount_thickness = lower_arm_ball_stud_mount_size[2];
  stud_mount_extra_thickness = stud_mount_thickness - lower_arm_thickness;

  available_h = lower_arm_h - cutout_depth - lower_arm_apex_width;

  outer_profile_pts = [[0, 0],
                       [0, lower_arm_h],
                       [hinge_cutout_len, lower_arm_h],
                       [(profile_length
                         - stud_mount_len
                         - lower_arm_leg_width) * 0.6, lower_arm_h * 0.9],
                       [profile_length
                        - stud_mount_len
                        - lower_arm_leg_width,
                        lower_arm_h - cutout_depth],
                       [profile_length, lower_arm_h - cutout_depth],
                       [profile_length, available_h],
                       [profile_length - stud_mount_len * 0.8,
                        available_h * 0.8],
                       [hole_start_x +
                        profile_length
                        - stud_mount_len
                        - lower_arm_leg_width * 3,
                        available_h * 0.4],
                       [hinge_cutout_len, 0]];

  triangle_cutout_pts = [[0, 0],
                         [0, hinge_cutout_h - hinge_cutout_corner_r],
                         [profile_length
                          - stud_mount_len
                          - lower_arm_leg_width * 3
                          + lower_arm_relief_hole_corner_r * 5.5,
                          hinge_cutout_h - cutout_depth
                          - hinge_cutout_corner_r
                          + lower_arm_leg_width
                          - stud_mount_y_size],
                         [profile_length
                          - stud_mount_len
                          - lower_arm_leg_width * 5,
                          hinge_cutout_h - cutout_depth
                          - hinge_cutout_corner_r]];

  render() {
    difference() {
      maybe_color(color) {
        union() {
          lower_arm_hinge();
          translate([0, lower_arm_h - lower_arm_hinge_barrel_h, 0]) {
            lower_arm_hinge();
          }
          translate([profile_x0, 0, 0]) {
            linear_extrude(height=lower_arm_thickness, center=false) {
              difference() {
                union() {
                  offset_vertices_2d(r=lower_arm_corner_r) {
                    polygon(outer_profile_pts);
                  }
                }

                // The cutout for hinges area
                translate([0, lower_arm_hinge_barrel_h, 0]) {
                  rounded_rect([hinge_cutout_len, hinge_cutout_h],
                               center=false,
                               side="right",
                               r=hinge_cutout_corner_r);
                }

                // The cutout in the center
                translate([hole_start_x, lower_arm_hinge_barrel_h, 0]) {
                  offset_vertices_2d(r=lower_arm_relief_hole_corner_r) {
                    polygon(triangle_cutout_pts);
                  }
                }
                // Cutout on the outer bottom edge. If printing is difficult,
                // you can disable the cutout and print it on that edge.
                if (use_lower_edge_cutout) {
                  translate([hinge_cutout_len,
                             -lower_arm_h / 2
                             - lower_arm_leg_width * 2,
                             0]) {
                    rounded_rect([profile_length, lower_arm_h],
                                 center=false,
                                 r_factor=0.5,
                                 fn=$preview ? 16 : 360,
                                 side="top");
                  }
                }

                // Cutout on the outer upper edge.
                translate([hinge_cutout_len + lower_arm_leg_width,
                           lower_arm_h / 2 +
                           lower_arm_leg_width * 2,
                           0]) {
                  rounded_rect([profile_length, lower_arm_h],
                               center=false,
                               r_factor=0.5,
                               fn=$preview ? 16 : 360,
                               side="left");
                }
              }
            }
          }
          translate([lower_arm_len
                     - boss_rad
                     - lower_arm_upper_boss_x_offset,
                     lower_arm_h
                     - cutout_depth
                     + lower_arm_damper_boss_h,
                     boss_rad]) {
            rotate([90, 0, 0]) {
              damper_boss();
            }
          }
          // Thickened section for screwing in a ball stud.
          if (stud_mount_extra_thickness > 0) {
            translate([lower_arm_len - stud_mount_len,
                       lower_arm_h
                       - cutout_depth
                       - stud_mount_y_size / 2
                       - lower_arm_apex_width / 2,
                       - stud_mount_extra_thickness / 2]) {

              chamfered_cube(size=[stud_mount_len,
                                   stud_mount_y_size,
                                   lower_arm_thickness
                                   + stud_mount_extra_thickness],
                             chamfer=stud_mount_extra_thickness / 2,
                             ignore_sides=["right"],
                             lower_chamfer=false);
            }
          }
        }
      }

      // The hole on the damper boss
      translate([lower_arm_len
                 - boss_rad
                 - lower_arm_upper_boss_x_offset,
                 lower_arm_h - cutout_depth + lower_arm_damper_boss_h,
                 boss_rad]) {

        rotate([90, 0, 0]) {
          cylinder(d=lower_arm_damper_boss_hole_d,
                   h=lower_arm_damper_boss_h
                   + (lower_arm_apex_width / 2)
                   + 1,
                   $fn=hole_resolution);
        }
      }

      // The hole on the apex for screwing ball stud
      translate([lower_arm_len - lower_arm_ball_stud_hole_depth,
                 lower_arm_h
                 - cutout_depth
                 - lower_arm_apex_width / 2,
                 lower_arm_thickness / 2]) {
        rotate([0, 90, 0]) {
          counterbore(h=lower_arm_ball_stud_hole_depth,
                      d=heat_insert_nut_hole_d,
                      sink=false,
                      fn=hole_resolution,
                      reverse=false);
        }
      }
    }
  }

  if (debug) {
    translate([profile_x0, 0, lower_arm_thickness]) {
      debug_polygon_text(outer_profile_pts);
      translate([hole_start_x, lower_arm_hinge_barrel_h, 0]) {
        debug_polygon_text(triangle_cutout_pts, font_color=metallic_yellow_1);
      }
    }
  }
}

lower_arm();
