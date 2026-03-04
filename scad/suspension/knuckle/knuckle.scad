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
use <../wishbone_arms/lower_arm.scad>
use <../wishbone_arms/upper_arm.scad>
use <knuckle_ball_stud_housing.scad>
use <knuckle_bushing.scad>
use <knuckle_steering_arm.scad>

color                  = cobalt_blue_metallic;
show_shoulder_bolt     = false;
show_shoulder_bolt_nut = false;
show_lower_arm         = true;
show_upper_arm         = true;
show_knuckle_bushing   = true;

function knuckle_assembly_full_len(x, y) =
  let (arm_len = max(upper_arm_len, lower_arm_len),
       knuckle_h = max(knuckle_bearing_outer_h
                       + knuckle_bearing_spacer_h
                       + knuckle_arm_base_w,
                       knuckle_ball_stud_house_h))
  arm_len + knuckle_h + knuckle_ball_stud_unthreaded_h;

module knuckle(color=color,
               show_shoulder_bolt=show_shoulder_bolt,
               show_upper_arm=show_upper_arm,
               show_lower_arm=show_lower_arm,
               show_knuckle_bushing=show_knuckle_bushing,
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

  ball_stud_housing_x = joint_len + knuckle_ball_stud_mount_outer_d / 2;

  ball_stud_mount_x = outer_od / 2 + ball_stud_housing_x;
  bushing_z = knuckle_ball_stud_house_h - knuckle_ball_stud_ball_d;

  module _with_arm_pos(mount_x, mount_y) {
    translate([mount_x, 0, 0]) {
      if (show_knuckle_bushing) {
        translate([0, 0, bushing_z]) {
          knuckle_bushing();
        }
      }
      translate([-upper_arm_thickness / 2,
                 -mount_y,
                 upper_arm_len
                 + knuckle_ball_stud_unthreaded_h
                 + knuckle_ball_stud_house_h]) {
        rotate([0, 90, 0]) {
          children();
        }
      }
    }
  }

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

              translate([ball_stud_housing_x, 0, 0]) {
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
            translate([ball_stud_mount_x, 0, 0]) {
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

  if (show_lower_arm) {
    let (ball_stud_y_pos = lower_arm_ball_stud_y_pos()) {
      translate([ball_stud_mount_x,
                 0,
                 0]) {
        if (show_knuckle_bushing) {
          translate([0, 0, bushing_z]) {
            knuckle_bushing();
          }
        }
        translate([-lower_arm_thickness / 2,
                   -ball_stud_y_pos,
                   lower_arm_len
                   + knuckle_ball_stud_unthreaded_h
                   + knuckle_ball_stud_house_h]) {
          rotate([0, 90, 0]) {
            lower_arm(show_ball_stud=true);
          }
        }
      }
    }
  }

  if (show_upper_arm) {
    let (ball_stud_y_pos = upper_arm_ball_stud_y_pos()) {
      translate([-ball_stud_mount_x, 0, 0]) {
        if (show_knuckle_bushing) {
          translate([0, 0, bushing_z]) {
            knuckle_bushing();
          }
        }
        translate([-upper_arm_thickness / 2,
                   -ball_stud_y_pos,
                   upper_arm_len
                   + knuckle_ball_stud_unthreaded_h
                   + knuckle_ball_stud_house_h]) {
          rotate([0, 90, 0]) {
            upper_arm(show_ball_stud=true);
          }
        }
      }
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

module knuckle_left(color=color,
                    show_shoulder_bolt=show_shoulder_bolt,
                    show_upper_arm=show_upper_arm,
                    show_lower_arm=show_lower_arm,
                    show_knuckle_bushing=show_knuckle_bushing) {
  full_len = knuckle_assembly_full_len();
  translate([-full_len, 0, 0]) {
    rotate([0, 90, 0]) {
      knuckle(color=color,
              show_shoulder_bolt=show_shoulder_bolt,
              show_upper_arm=show_upper_arm,
              show_lower_arm=show_lower_arm,
              show_knuckle_bushing=show_knuckle_bushing);
    }
  }
}

module knuckle_right(color=color,
                     show_shoulder_bolt=show_shoulder_bolt,
                     show_upper_arm=show_upper_arm,
                     show_lower_arm=show_lower_arm,
                     show_knuckle_bushing=show_knuckle_bushing) {
  full_len = knuckle_assembly_full_len();
  rotate([0, 0, 0]) {
    translate([full_len, 0, 0]) {
      rotate([0, -90, 0]) {
        mirror([1, 0, 0]) {
          knuckle(color=color,
                  show_shoulder_bolt=show_shoulder_bolt,
                  show_upper_arm=show_upper_arm,
                  show_lower_arm=show_lower_arm,
                  show_knuckle_bushing=show_knuckle_bushing);
        }
      }
    }
  }
}

// knuckle_left();
// knuckle_right();
knuckle();