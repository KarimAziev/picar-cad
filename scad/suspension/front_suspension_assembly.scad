/**
  * Module: Front suspension assembly.
  *
  * Assembles the front bulkhead, bulkhead housing, upper suspension
  * components, and left and right knuckles.
  * Optional solve_linkage closes the arms, knuckles and wheel rods at a
  * prescribed lower_arm_angle and displayed bellcrank_angle. steering_hole
  * selects the zero-based knuckle attachment. This is rigid kinematics;
  * see steering_characterization/README.md for mounting assumptions and limits.
  * show_wheels attaches touring-wheel placeholders to each visible knuckle;
  * show_tires controls the rubber while retaining the same mounting frame.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../rc_params.scad>

use <bulkhead/front_bulkhead.scad>
use <bulkhead/front_bulkhead_housing.scad>
use <front_linkage.scad>
use <knuckle/knuckle.scad>
use <rc_wheels.scad>
use <wishbone_arms/util.scad>

show_front_lower_arm                        = true;
show_front_lower_arm_pin                    = true;
show_front_lower_pin_e_clip                 = true;
show_front_lower_arm_ball_stud              = true;

show_front_upper_arm                        = true;

show_front_bulkhead                         = true;
show_front_bulkhead_upper_suspension_holder = true;

show_upper_arm_ball_stud                    = true;
show_front_upper_arm_pin                    = true;

show_front_shock_tower                      = true;
show_front_suspension_arm_pad               = true;

show_left_knuckle                           = true;
show_right_knuckle                          = true;

show_knuckle_bushing                        = true;
show_knuckle_inner_bearing                  = true;
show_knuckle_outer_bearing                  = true;
show_knuckle_tie_rod                        = true;

show_front_bulkhead_housing                 = true;

module front_suspension_assembly(show_front_lower_arm=show_front_lower_arm,
                                 show_front_upper_arm=show_front_upper_arm,
                                 show_knuckle_bushing=show_knuckle_bushing,
                                 show_knuckle_inner_bearing=show_knuckle_inner_bearing,
                                 show_knuckle_outer_bearing=show_knuckle_outer_bearing,
                                 show_knuckle_tie_rod=show_knuckle_tie_rod,
                                 show_front_bulkhead=show_front_bulkhead,
                                 show_front_shock_tower=show_front_shock_tower,
                                 show_front_bulkhead_upper_suspension_holder=show_front_bulkhead_upper_suspension_holder,
                                 show_front_suspension_arm_pad=show_front_suspension_arm_pad,
                                 show_upper_arm_ball_stud=show_upper_arm_ball_stud,
                                 show_front_upper_arm_pin=show_front_upper_arm_pin,
                                 show_front_lower_arm_pin=show_front_lower_arm_pin,
                                 show_front_lower_pin_e_clip=show_front_lower_pin_e_clip,
                                 show_front_lower_arm_ball_stud=show_front_lower_arm_ball_stud,
                                 show_left_knuckle=show_left_knuckle,
                                 show_right_knuckle=show_right_knuckle,
                                 show_front_bulkhead_housing=show_front_bulkhead_housing,
                                 solve_linkage=false,
                                 lower_arm_angle=0,
                                 bellcrank_angle=0,
                                 steering_hole=0,
                                 show_wheels=false,
                                 show_tires=true) {
  assert(!solve_linkage || (knuckle_angles == [0, 0, 0] && knuckle_z_shift == 0),
         "Solved linkage owns the knuckle pose; reset legacy angles and Z shift");
  poses = solve_linkage
    ? [for (side = [-1, 1])
      front_linkage_pose(lower_angle=lower_arm_angle,
                         bellcrank_angle=bellcrank_angle,
                         side=side,
                         hole=steering_hole)]
    : [undef, undef];
  barrel_size = front_lower_arm_mount_cutout_size();
  barrel_y_start = front_bulkhead_len - front_bulkhead_barrel_y_offset
                   - barrel_size[1];
  bulkhead_full_w = front_bulkhead_w + front_bulkhead_barrel_hinge_w * 2;
  bolt_stud_y_pos = front_lower_arm_ball_stud_y_pos();

  lower_arm_offset = front_lower_arm_hinge_barrel_hole_offset
                     + front_bulkhead_barrel_pin_hole_offset
                     + front_lower_arm_hinge_barrel_hole_d;

  union() {
    if (show_front_bulkhead_housing) {
      front_bulkhead_housing(center_y=false,
                             show_front_lower_arm=show_front_lower_arm && !solve_linkage,
                             show_front_lower_arm_pin=show_front_lower_arm_pin,
                             show_front_lower_pin_e_clip=show_front_lower_pin_e_clip,
                             show_front_lower_arm_ball_stud=show_front_lower_arm_ball_stud);
    }

    if (show_front_bulkhead) {
      translate([0, front_bulkhead_len / 2, front_bulkhead_housing_h]) {
        front_bulkhead(show_shock_tower=show_front_shock_tower,
                       show_upper_suspension_holder=show_front_bulkhead_upper_suspension_holder,
                       show_suspension_arm_pad=show_front_suspension_arm_pad,
                       show_upper_arm_ball_stud=show_upper_arm_ball_stud,
                       show_front_upper_arm_pin=show_front_upper_arm_pin,
                       show_front_upper_arm=show_front_upper_arm && !solve_linkage);
      }
    }

    for (i = [0:1]) {
      if (solve_linkage) {
        if (show_front_lower_arm && show_front_bulkhead_housing) {
          front_linkage_arm(poses[i], show_ball=show_front_lower_arm_ball_stud);
        }
        if (show_front_upper_arm && show_front_bulkhead) {
          front_linkage_arm(poses[i],
                            upper=true,
                            show_ball=show_upper_arm_ball_stud);
        }
        if (show_knuckle_tie_rod) {
          front_linkage_rod(poses[i]);
        }
      }
      front_linkage_knuckle(poses[i]) {
        translate([0,
                   bolt_stud_y_pos - front_lower_arm_lower_hinge_barrel_h + barrel_y_start,
                   knuckle_total_len / 2 - knuckle_ball_stud_mount_outer_d / 2
                   + front_bulkhead_housing_h / 2]) {
          if (i == 0) {
            translate([-bulkhead_full_w / 2 + lower_arm_offset, 0, 0]) {
              knuckle_left(show_knuckle=show_left_knuckle,
                           show_lower_arm=false,
                           show_upper_arm=false,
                           show_knuckle_bushing=show_knuckle_bushing,
                           show_knuckle_inner_bearing=show_knuckle_inner_bearing,
                           show_knuckle_outer_bearing=show_knuckle_outer_bearing,
                           show_knuckle_tie_rod=show_knuckle_tie_rod && !solve_linkage) {
                if (show_wheels && show_left_knuckle) {
                  rc_knuckle_wheel(show_tire=show_tires);
                }
              }
            }
          } else {
            translate([bulkhead_full_w / 2 - lower_arm_offset, 0, 0]) {
              knuckle_right(show_knuckle=show_right_knuckle,
                            show_lower_arm=false,
                            show_upper_arm=false,
                            show_knuckle_bushing=show_knuckle_bushing,
                            show_knuckle_inner_bearing=show_knuckle_inner_bearing,
                            show_knuckle_outer_bearing=show_knuckle_outer_bearing,
                            show_knuckle_tie_rod=show_knuckle_tie_rod && !solve_linkage) {
                if (show_wheels && show_right_knuckle) {
                  rc_knuckle_wheel(show_tire=show_tires);
                }
              }
            }
          }
        }
      }
    }
  }
}

front_suspension_assembly();
