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
use <../../lib/threading/threaded_plug_hex_socket.scad>
use <../../lib/transforms.scad>
use <../../placeholders/ball_bearing.scad>
use <../../placeholders/bolt.scad>
use <../wishbone_arms/lower_arm.scad>
use <../wishbone_arms/upper_arm.scad>
use <knuckle_ball_stud_housing.scad>
use <knuckle_bushing.scad>
use <knuckle_steering_arm.scad>
use <knuckle_threaded_plug.scad>
use <steering_link.scad>
use <util.scad>
use <../wishbone_arms/util.scad>



show_lower_arm             = false;
show_upper_arm             = false;
show_knuckle_bushing       = false;
show_knuckle_inner_bearing = false;
show_knuckle_outer_bearing = false;
show_knuckle_tie_rod       = true;
show_knuckle_socket_plug   = false;
show_lower_arm_ball_stud   = true;
show_upper_arm_ball_stud   = true;

color                      = cobalt_blue_metallic;

module knuckle(color=color,
               debug=false) {
  lower_params = knuckle_outer_bearing_params(bearing_od=knuckle_outer_bearing_od,
                                              bearing_w=knuckle_outer_bearing_w,
                                              bearing_z_clearance=knuckle_outer_bearing_z_clearance,
                                              bearing_clearance=knuckle_outer_bearing_clearance,
                                              spacer_h=knuckle_bearing_spacer_h,
                                              wall_thickness=knuckle_outer_wall_thickness);

  outer_bearing_seat_od = lower_params[0];
  outer_bearing_seat_d = lower_params[1];
  outer_bearing_seat_h = lower_params[2];
  lower_height = lower_params[3];

  ball_stud_joint_params =
    knuckle_ball_stud_joint_params(lower_height=lower_height,
                                   outer_bearing_seat_od=outer_bearing_seat_od,
                                   total_knuckle_len=knuckle_total_len,
                                   base_knuckle_d=knuckle_base_d,
                                   ball_stud_mount_od=knuckle_ball_stud_mount_outer_d,
                                   ball_stud_housing_h=knuckle_ball_stud_house_h,
                                   steering_arm_base_w=knuckle_arm_base_w);

  ball_stud_housing_x = ball_stud_joint_params[0];
  ball_stud_mount_x = ball_stud_joint_params[1];
  joint_w = ball_stud_joint_params[2];
  joint_len = ball_stud_joint_params[3];
  joint_h = ball_stud_joint_params[4];

  notch_a = notch_depth(outer_bearing_seat_od, joint_w);
  notch_b = notch_depth(knuckle_ball_stud_mount_outer_d, joint_w);

  corner_r = min(0.5, joint_len);

  joint_pts = [[-notch_a - corner_r, -joint_w / 2],
               [-notch_a - corner_r, joint_w / 2],
               [joint_len / 2, (joint_w / 2) * 0.7],
               [joint_len + notch_b + corner_r, joint_w / 2],
               [joint_len + notch_b + corner_r, -joint_w / 2],
               [joint_len / 2, -(joint_w / 2) * 0.7]];

  fn = $preview ? 30 : 300;

  maybe_color(color) {
    union() {
      difference() {
        union() {
          cylinder(h=lower_height,
                   d1=outer_bearing_seat_od,
                   d2=knuckle_arm_ring_outer_d,
                   $fn=fn);
          mirror_copy([1, 0, 0]) {
            translate([outer_bearing_seat_od / 2, 0, 0]) {
              linear_extrude(height=joint_h, center=false) {
                offset_vertices_2d(r=corner_r) {
                  polygon(joint_pts, $fs=fn);
                }
              }

              translate([ball_stud_housing_x, 0, 0]) {
                knuckle_ball_stud_housing();
              }
            }
          }
        }
        translate([0, 0, -0.5]) {
          cylinder(d=outer_bearing_seat_d,
                   h=outer_bearing_seat_h + 0.5,
                   $fn=fn);
          cylinder(d=knuckle_bearing_spacer_ring_d,
                   h=lower_height + 0.5,
                   $fn=fn);
          translate([0, 0, lower_height]) {
            cylinder(d=knuckle_inner_bearing_shoulder_d,
                     h=knuckle_arm_base_w + 0.5,
                     $fn=fn);
            translate([0,
                       0,
                       knuckle_inner_bearing_w
                       + knuckle_inner_bearing_clearance + 1]) {
              cylinder(d=knuckle_inner_bearing_seat_d,
                       h=knuckle_inner_bearing_w
                       + knuckle_inner_bearing_clearance + 1,
                       $fn=fn);
            }
          }
          mirror_copy([1, 0, 0]) {
            translate([ball_stud_mount_x, 0, 0]) {
              cylinder(d=knuckle_ball_stud_mount_hole_d,
                       h=joint_h + 0.5,
                       $fn=fn);
            }
          }
        }
      }
      translate([0, 0, lower_height]) {
        rotate([90, 0, 0]) {
          rotate([0, 0, 90]) {
            knuckle_steering_arm();
          }
        }
      }
    }
  }
  if (debug) {
    translate([outer_bearing_seat_od / 2, 0, lower_height]) {
      debug_polygon_text(joint_pts, font_size=2);
    }
  }
}

module knuckle_left(color=color,
                    angles=knuckle_angles,
                    show_upper_arm=show_upper_arm,
                    show_lower_arm=show_lower_arm,
                    show_knuckle_bushing=show_knuckle_bushing,
                    show_knuckle_inner_bearing=show_knuckle_inner_bearing,
                    show_knuckle_socket_plug=show_knuckle_socket_plug,
                    show_knuckle_outer_bearing=show_knuckle_outer_bearing,
                    show_knuckle_tie_rod=show_knuckle_tie_rod,
                    show_lower_arm_ball_stud=show_lower_arm_ball_stud,
                    show_upper_arm_ball_stud=show_upper_arm_ball_stud,
                    show_knuckle=true) {

  lower_params = knuckle_outer_bearing_params(bearing_od=knuckle_outer_bearing_od,
                                              bearing_w=knuckle_outer_bearing_w,
                                              bearing_z_clearance=knuckle_outer_bearing_z_clearance,
                                              bearing_clearance=knuckle_outer_bearing_clearance,
                                              spacer_h=knuckle_bearing_spacer_h,
                                              wall_thickness=knuckle_outer_wall_thickness);

  outer_bearing_seat_od = lower_params[0];
  lower_height = lower_params[3];

  ball_stud_joint_params =
    knuckle_ball_stud_joint_params(lower_height=lower_height,
                                   outer_bearing_seat_od=outer_bearing_seat_od,
                                   total_knuckle_len=knuckle_total_len,
                                   base_knuckle_d=knuckle_base_d,
                                   ball_stud_mount_od=knuckle_ball_stud_mount_outer_d,
                                   ball_stud_housing_h=knuckle_ball_stud_house_h,
                                   steering_arm_base_w=knuckle_arm_base_w);

  ball_stud_mount_x = ball_stud_joint_params[1];

  full_len = knuckle_assembly_full_len();
  bushing_z = knuckle_ball_stud_house_h - front_arm_ball_stud_ball_d;

  full_main_h = knuckle_arm_base_w + lower_height;

  camber_angle = angles[1];
  caster_angle = angles[0];

  shifted_angles = [angles[2], camber_angle, caster_angle];

  lower_arm_size = lower_arm_full_size();
  lower_ball_stud_y_pos = lower_arm_ball_stud_y_pos();
  upper_ball_stud_y_pos = upper_arm_ball_stud_y_pos();

  upper_arm_size = upper_arm_full_size();
  lower_arm_y_angle = y_angle_from_zshift(-knuckle_z_shift,
                                          lower_arm_size[0]);
  upper_arm_y_angle = y_angle_from_zshift(-knuckle_z_shift,
                                          upper_arm_size[0]);

  translate([-full_len, 0, 0]) {
    rotate([0, 90, 0]) {
      translate([knuckle_z_shift,
                 0,
                 -max(front_upper_arm_ball_stud_insert_out_depth,
                      front_lower_arm_ball_stud_insert_out_depth)]) {
        maybe_rotate(shifted_angles) {
          if (show_knuckle) {
            knuckle(color=color);
          }

          if (show_knuckle_outer_bearing) {
            ball_bearing(bore_d=knuckle_outer_bearing_bore_d,
                         w=knuckle_outer_bearing_w,
                         outer_d=knuckle_outer_bearing_od);
          }

          if (show_knuckle_bushing) {
            translate([0, 0, bushing_z]) {
              translate([ball_stud_mount_x, 0, 0]) {
                knuckle_bushing();
              }

              translate([-ball_stud_mount_x, 0, 0]) {
                knuckle_bushing();
              }
            }
          }

          if (show_knuckle_socket_plug) {

            translate([0, 0, 0]) {
              translate([ball_stud_mount_x, 0, 0]) {
                knuckle_threaded_plug();
              }

              translate([-ball_stud_mount_x, 0, 0]) {
                knuckle_threaded_plug();
              }
            }
          }

          if (show_knuckle_inner_bearing) {
            translate([0, 0, full_main_h - knuckle_inner_bearing_w]) {
              ball_bearing(bore_d=knuckle_inner_bearing_bore_d,
                           w=knuckle_inner_bearing_w,
                           outer_d=knuckle_inner_bearing_od);
            }
          }
        }
      }
      if (show_lower_arm) {
        let (ball_stud_y_pos = lower_arm_ball_stud_y_pos()) {
          translate([ball_stud_mount_x,
                     0,
                     0]) {

            translate([-front_lower_arm_thickness / 2,
                       -lower_ball_stud_y_pos,
                       front_lower_arm_len
                       + front_arm_ball_stud_unthreaded_h
                       + knuckle_ball_stud_house_h]) {
              rotate([0, 90, 0]) {
                lower_arm(show_ball_stud=show_lower_arm_ball_stud,
                          y_angle=lower_arm_y_angle);
              }
            }
          }
        }
      }
      if (show_upper_arm) {
        translate([-ball_stud_mount_x, 0, 0]) {
          translate([-front_upper_arm_thickness / 2,
                     -upper_ball_stud_y_pos,
                     front_upper_arm_len
                     + front_arm_ball_stud_unthreaded_h
                     + knuckle_ball_stud_house_h]) {
            rotate([0, 90, 0]) {
              upper_arm(show_ball_stud=show_upper_arm_ball_stud,
                        y_angle=upper_arm_y_angle);
            }
          }
        }
      }

      translate([knuckle_z_shift,
                 0,
                 -max(front_upper_arm_ball_stud_insert_out_depth,
                      front_lower_arm_ball_stud_insert_out_depth)]) {
        rotate(shifted_angles) {
          if (show_knuckle_tie_rod) {
            translate([0,
                       0,
                       lower_height]) {
              rotate([90, 0, 0]) {
                rotate([0, 0, 90]) {
                  steering_link();
                }
              }
            }
          }
        }
      }
    }
  }
}

module knuckle_right(color=color,
                     angles=knuckle_angles,
                     show_upper_arm=show_upper_arm,
                     show_lower_arm=show_lower_arm,
                     show_knuckle_bushing=show_knuckle_bushing,
                     show_knuckle_inner_bearing=show_knuckle_inner_bearing,
                     show_knuckle_outer_bearing=show_knuckle_outer_bearing,
                     show_knuckle_socket_plug=show_knuckle_socket_plug,
                     show_knuckle_tie_rod=show_knuckle_tie_rod,
                     show_lower_arm_ball_stud=show_lower_arm_ball_stud,
                     show_upper_arm_ball_stud=show_upper_arm_ball_stud,
                     show_knuckle=true) {

  mirror([1, 0, 0]) {
    knuckle_left(color=color,
                 show_upper_arm=show_upper_arm,
                 show_lower_arm=show_lower_arm,
                 show_knuckle_bushing=show_knuckle_bushing,
                 show_knuckle_inner_bearing=show_knuckle_inner_bearing,
                 show_knuckle_outer_bearing=show_knuckle_outer_bearing,
                 show_knuckle_tie_rod=show_knuckle_tie_rod,
                 show_knuckle_socket_plug=show_knuckle_socket_plug,
                 show_lower_arm_ball_stud=show_lower_arm_ball_stud,
                 show_upper_arm_ball_stud=show_upper_arm_ball_stud,
                 show_knuckle=show_knuckle,
                 angles=[angles[0], angles[1], -angles[2]]);
  }
}

module knuckle_printable() {
  knuckle(debug=false);
}

knuckle_printable();
