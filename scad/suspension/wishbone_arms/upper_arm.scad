/**
 * Module: Upper Wishbone Arm
 *
 * The upper arm is A-shaped control arm connecting the top of the steering
 * knuckle to the chassis.
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

show_ball_stud = false;
debug          = false;

module upper_arm(color=cobalt_blue_metallic,
                 show_ball_stud=show_ball_stud,
                 debug=debug) {
  cut_h = upper_arm_h - upper_arm_hinge_barrel_h * 2;
  cut_y_offset = upper_arm_h / 2 - cut_h / 2;
  full_h = upper_arm_h + upper_arm_ball_stud_mount_extra_h;

  ball_stud_y = + upper_arm_ball_stud_mount_extra_h
    + upper_arm_h
    - upper_arm_joint_mount_h / 2;

  upper_bent_len = upper_arm_len - upper_arm_joint_mount_len;
  hole_start_x = upper_arm_side_cutout_depth
    + upper_arm_side_w;
  hole_start_y = cut_y_offset + upper_arm_ball_stud_mount_extra_h / 2;

  base_shape_pts = [[0, 0],
                    [0, upper_arm_h],
                    [upper_arm_side_cutout_depth, upper_arm_h],
                    [upper_bent_len / 2,
                     upper_arm_h + upper_arm_ball_stud_mount_extra_h * 0.3],
                    [upper_bent_len,
                     upper_arm_h + upper_arm_ball_stud_mount_extra_h],
                    [upper_arm_len, full_h],
                    [upper_arm_len, full_h - upper_arm_joint_mount_h],
                    [upper_arm_side_cutout_depth, 0]];

  hole_pts = [[0, 0],
              [0, cut_h + upper_arm_ball_stud_mount_extra_h * 0.3],
              [upper_bent_len / 2,
               cut_h + upper_arm_ball_stud_mount_extra_h],
              [upper_arm_len
               - upper_arm_joint_mount_len
               - upper_arm_side_cutout_depth
               - upper_arm_side_w,
               cut_h],
              [(upper_arm_len
                - upper_arm_joint_mount_len
                - upper_arm_side_cutout_depth
                - upper_arm_side_w) * 0.8,
               cut_h - upper_arm_ball_stud_mount_extra_h]];

  module upper_arm_hole() {
    polygon(hole_pts);
  }

  module base_shape() {
    polygon(base_shape_pts);
  }

  module _main() {
    union() {
      difference() {
        offset_vertices_2d(r=upper_arm_corner_rad, $fn=34) {
          base_shape();
        }

        translate([hole_start_x,
                   hole_start_y,
                   0]) {
          offset_vertices_2d(r=upper_arm_hole_corner_r) {
            upper_arm_hole();
          }
        }

        translate([-1, cut_y_offset, 0]) {
          rounded_rect(size=[upper_arm_side_cutout_depth + 1,
                             cut_h],
                       fn=$preview ? 20 : 40,
                       side="right",
                       center=false);
        }
      }
    }
  }

  union() {
    if (debug) {
      translate([0, 0, upper_arm_thickness]) {
        debug_polygon_text(points=base_shape_pts);
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
          linear_extrude(height=upper_arm_thickness, center=false) {
            _main();
          }
          translate([upper_bent_len,
                     upper_arm_h + upper_arm_ball_stud_mount_extra_h
                     - upper_arm_joint_mount_h,
                     -upper_arm_ball_stud_mount_extra_thickness / 2]) {
            chamfered_cube(size=[upper_arm_joint_mount_len,
                                 upper_arm_joint_mount_h,
                                 upper_arm_thickness
                                 + upper_arm_ball_stud_mount_extra_thickness],
                           chamfer=upper_arm_ball_stud_mount_extra_thickness / 2,
                           ignore_sides=["right"],
                           lower_chamfer=false);
          }
        }
        translate([0, 0, upper_arm_thickness / 2]) {
          translate([upper_arm_side_cutout_depth / 2, 0, 0]) {
            rotate([-90, 0, 0]) {
              cylinder(d=upper_arm_pin_d, h=upper_arm_h + 1, $fn=40);
            }
          }

          translate([upper_arm_len,
                     ball_stud_y,
                     0]) {
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
