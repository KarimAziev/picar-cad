/**
 * Module: Upper Wishbone Arm
 *
 * The upper arm is A-shaped control arm connecting the top of the steering
 * knuckle to the chassis.
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
use <../../placeholders/ball_stud.scad>
use <barrel_hinge.scad>

show_ball_stud = false;
debug          = false;

module upper_arm_barrel() {
  barrel_hinge(size=[upper_arm_hinge_barrel_len,
                     upper_arm_hinge_barrel_h,
                     upper_arm_thickness],
               d=upper_arm_hinge_barrel_hole_d,
               distance=upper_arm_hinge_barrel_hole_offset);
}

module upper_arm_hinge_barrels() {
  cut_h = upper_arm_h - upper_arm_hinge_barrel_h * 2;
  hole_end_x = upper_arm_hinge_barrel_hole_offset
    + upper_arm_hinge_barrel_hole_d;
  wall_len = upper_arm_hinge_barrel_len - hole_end_x;

  union() {
    upper_arm_barrel();
    translate([0, cut_h + upper_arm_hinge_barrel_h, 0]) {
      upper_arm_barrel();
    }
    translate([hole_end_x,
               upper_arm_hinge_barrel_h,
               0]) {

      linear_extrude(height=upper_arm_thickness, center=false) {
        difference() {
          square([wall_len, cut_h], center=false);
          translate([-hole_end_x, 0, 0]) {
            rounded_rect([upper_arm_hinge_barrel_len, cut_h],
                         r=wall_len,
                         fn=$preview ? 40 : 360,
                         side="right",
                         center=false);
          }
        }
      }
    }
  }
}

module upper_arm(color=cobalt_blue_metallic,
                 show_ball_stud=show_ball_stud,
                 debug=debug) {
  cut_h = upper_arm_h - upper_arm_hinge_barrel_h * 2;
  cut_y_offset = upper_arm_h / 2 - cut_h / 2;
  full_h = upper_arm_h + upper_arm_ball_stud_mount_extra_h;

  ball_stud_mount_length = upper_arm_ball_stud_mount_size[0];
  ball_stud_mount_h = upper_arm_ball_stud_mount_size[1];
  ball_stud_mount_thickness = upper_arm_ball_stud_mount_size[2];

  ball_stud_mount_extra_thickness = ball_stud_mount_thickness
    - upper_arm_thickness;

  ball_stud_mount_chamfer_thickness = ball_stud_mount_extra_thickness / 2;

  ball_stud_y = + upper_arm_ball_stud_mount_extra_h
    + upper_arm_h
    - ball_stud_mount_h / 2;

  upper_bent_len = upper_arm_len - ball_stud_mount_length;
  hole_start_x = upper_arm_hinge_barrel_len
    + upper_arm_leg_width;
  hole_start_y = cut_y_offset + upper_arm_ball_stud_mount_extra_h / 2;

  hinge_hole_end_x = upper_arm_hinge_barrel_hole_offset
    + upper_arm_hinge_barrel_hole_d;

  shape_pts = [[upper_arm_hinge_barrel_len - upper_arm_corner_r,
                -upper_arm_corner_r],
               [upper_arm_hinge_barrel_len,
                upper_arm_h - upper_arm_hinge_barrel_h],
               [hinge_hole_end_x, upper_arm_h],
               [upper_bent_len / 2,
                upper_arm_h + upper_arm_ball_stud_mount_extra_h],
               [upper_bent_len,
                upper_arm_h + upper_arm_ball_stud_mount_extra_h],
               [upper_arm_len, full_h],
               [upper_arm_len, full_h - ball_stud_mount_h]];

  hole_pts = [[0, 0],
              [0, cut_h + upper_arm_ball_stud_mount_extra_h * 0.3],
              [upper_bent_len / 2,
               cut_h + upper_arm_ball_stud_mount_extra_h],
              [upper_arm_len
               - ball_stud_mount_length
               - upper_arm_hinge_barrel_len
               - upper_arm_leg_width,
               cut_h],
              [(upper_arm_len
                - ball_stud_mount_length
                - upper_arm_hinge_barrel_len
                - upper_arm_leg_width) * 0.8,
               cut_h - upper_arm_ball_stud_mount_extra_h]];

  module upper_arm_hole() {
    polygon(hole_pts, $fn=$preview ? 30 : 360);
  }

  module base_shape() {
    polygon(shape_pts);
  }

  module _main() {
    difference() {
      offset_vertices_2d(r=upper_arm_corner_r, $fn=$preview ? 16 : 360) {
        base_shape();
      }

      translate([hole_start_x,
                 hole_start_y,
                 0]) {
        offset_vertices_2d(r=upper_arm_hole_corner_r) {
          upper_arm_hole();
        }
      }
    }
  }

  union() {
    if (debug) {
      translate([0, 0, upper_arm_thickness]) {
        debug_polygon_text(points=shape_pts);
        translate([hole_start_x,
                   hole_start_y,
                   0]) {
          debug_polygon_text(points=hole_pts, font_color="red");
        }
      }
    }
    render() {
      difference() {
        maybe_color(color) {
          difference() {
            linear_extrude(height=upper_arm_thickness, center=false) {
              _main();
            }

            // // Cutout on the outer upper-y edge.
            translate([hinge_hole_end_x, upper_arm_len + upper_arm_h, 0]) {
              cylinder(r=upper_arm_len,
                       $fn=$preview ? 40 : 360,
                       h=upper_arm_h + 1);
            }
          }

          upper_arm_hinge_barrels();

          translate([upper_bent_len,
                     upper_arm_h + upper_arm_ball_stud_mount_extra_h
                     - ball_stud_mount_h,
                     -ball_stud_mount_chamfer_thickness]) {
            chamfered_cube(size=upper_arm_ball_stud_mount_size,
                           chamfer=ball_stud_mount_chamfer_thickness,
                           ignore_sides=["right"],
                           lower_chamfer=false);
          }
        }
        translate([upper_arm_len,
                   ball_stud_y,
                   upper_arm_thickness / 2]) {
          rotate([-90, 0, 90]) {
            counterbore(h=upper_arm_ball_stud_hole_depth,
                        d=heat_insert_nut_hole_d,
                        sink=true,
                        fn=300,
                        reverse=true);
          }
        }
      }
    }
    if (show_ball_stud) {
      translate([upper_arm_len -
                 (knuckle_ball_stud_h - knuckle_ball_stud_unthreaded_h),
                 ball_stud_y,
                 upper_arm_thickness / 2]) {
        rotate([90, 0, 90]) {
          ball_stud(d=knuckle_ball_stud_shank_d,
                    ball_d=knuckle_ball_stud_ball_d,
                    ball_hole_d=knuckle_ball_stud_ball_hole_d,
                    h=knuckle_ball_stud_h,
                    unthreaded_len=knuckle_ball_stud_unthreaded_h);
        }
      }
    }
  }
}

upper_arm();
