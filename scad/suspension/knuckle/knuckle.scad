/**
 * Module: Double-wishbone suspension knuckle
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/debug.scad>
use <../../lib/placement.scad>
use <../../lib/shapes2d.scad>
use <../../lib/transforms.scad>
use <../../placeholders/bolt.scad>
use <knuckle_ball_stud_housing.scad>
use <knuckle_steering_arm.scad>

color                  = cobalt_blue_metallic;
show_shoulder_bolt     = false;
show_shoulder_bolt_nut = false;

module knuckle(color=color,
               show_shoulder_bolt=show_shoulder_bolt,
               debug=false) {
  joint_len  = (knuckle_total_len -
                (knuckle_ball_stud_mount_outer_d * 2)
                - knuckle_base_d) / 2;
  joint_w   = knuckle_ball_stud_mount_outer_d * 0.8;
  outer_od = knuckle_bearing_outer_od + knuckle_outer_wall_thickness * 2;
  outer_d = knuckle_bearing_outer_od;
  notch_a = notch_depth(outer_od, joint_w);
  notch_b = notch_depth(knuckle_ball_stud_mount_outer_d, joint_w);

  corner_r    = min(0.5, joint_len * 1.0);

  joint_pts = [[-notch_a - corner_r, -joint_w / 2],
               [-notch_a - corner_r, joint_w / 2],
               [joint_len / 2, (joint_w / 2) * 0.7],
               [joint_len + notch_b + corner_r, joint_w / 2],
               [joint_len + notch_b + corner_r, -joint_w / 2],
               [joint_len / 2, -(joint_w / 2) * 0.7]];

  height = knuckle_bearing_outer_h + knuckle_bearing_spacer_h;

  joint_h = min(height + knuckle_arm_base_w, knuckle_ball_stud_house_h);

  maybe_color(color) {
    union() {
      difference() {
        union() {
          cylinder(h=height,
                   d1=outer_od,
                   d2=knuckle_arm_ring_outer_d,

                   $fn=200);
          mirror_copy([1, 0, 0]) {
            translate([outer_od / 2,
                       0,
                       0]) {

              linear_extrude(height=joint_h,
                             center=false) {
                offset_vertices_2d(r=corner_r) {
                  polygon(joint_pts, $fs=300);
                }
              }

              translate([joint_len + knuckle_ball_stud_mount_outer_d / 2,
                         0,
                         0]) {
                knuckle_ball_stud_housing();
              }
            }
          }
        }
        translate([0, 0, -0.5]) {
          cylinder(d=outer_d, h=knuckle_bearing_outer_h + 0.5, $fn=300);
          cylinder(d=knuckle_bearing_spacer_ring_d, h=height + 0.51, $fn=300);
          translate([0, 0, height]) {
            cylinder(d=knuckle_bearing_inner_shoulder_d,
                     h=knuckle_arm_base_w + 0.5,
                     $fn=300);
            translate([0, 0, knuckle_bearing_inner_h + 1]) {
              cylinder(d=knuckle_bearing_inner_od,
                       h=knuckle_bearing_inner_h + 0.8,
                       $fn=300);
            }
          }
          mirror_copy([1, 0, 0]) {
            translate([outer_od / 2 + joint_len
                       + knuckle_ball_stud_mount_outer_d / 2,
                       0,
                       0]) {
              cylinder(d=knuckle_ball_stud_mount_hole_d,
                       h=joint_h + 0.5,
                       $fn=200);
            }
          }
        }
      }
      translate([0, 0, height - 0.1]) {
        rotate([90, 0, 0]) {
          rotate([0, 0, 90]) {
            knuckle_steering_arm();
          }
        }
      }
    }
  }
  if (debug) {
    translate([outer_od / 2, 0, height]) {
      debug_polygon_text(joint_pts, font_size=2);
    }
  }
  if (show_shoulder_bolt) {
    translate([0,
               0,
               -(wheel_shoulder_bolt_threaded_l
                 + wheel_shoulder_bolt_unthreaded_l)
               + height]) {

      bolt(d=wheel_shoulder_bolt_d,
           thread_starts=1,
           h=wheel_shoulder_bolt_threaded_l + wheel_shoulder_bolt_unthreaded_l,
           thread_len=wheel_shoulder_bolt_threaded_l,
           unthreaded=wheel_shoulder_bolt_unthreaded_l,
           unthreaded_d=wheel_bearing_bore_d,
           head_d=wheel_shoulder_bolt_head_d,
           show_nut=show_shoulder_bolt_nut,
           lock_nut=true,
           head_type="socket",
           bolt_color=matte_black,
           unthreaded_color=metallic_silver_2,
           head_h=wheel_shoulder_bolt_head_h);
    }
  }
}

knuckle();
