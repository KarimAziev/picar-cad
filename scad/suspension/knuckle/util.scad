// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's common functions
// ─────────────────────────────────────────────────────────────────────────────
include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../placeholders/bolt.scad>

function knuckle_ball_stud_housing_h(base_h=knuckle_ball_stud_house_h,
                                     sphere_h=knuckle_ball_stud_sphere_h) =
  base_h + sphere_h;

function knuckle_full_w() =
  let (knuckle_h = max(knuckle_outer_bearing_w
                       + knuckle_outer_bearing_z_clearance
                       + knuckle_bearing_spacer_h
                       + knuckle_arm_base_w,
                       knuckle_ball_stud_house_h),
       ball_stud_housing_h = knuckle_ball_stud_housing_h())
  max(knuckle_h, ball_stud_housing_h);

function knuckle_assembly_full_len(x, y) =
  let (arm_len = max(front_upper_arm_len, front_lower_arm_len),
       knuckle_h = max(knuckle_outer_bearing_w
                       + knuckle_outer_bearing_z_clearance
                       + knuckle_bearing_spacer_h
                       + knuckle_arm_base_w,
                       knuckle_ball_stud_house_h))
  arm_len + knuckle_h + front_arm_ball_stud_unthreaded_h;

// Returns the parameters of the lower part of the knuckle's central cylinder
// for the outer bearing seat: the minimum outer diameter, the bearing seat
// diameter, the bearing seat height without spacer and the height.
function knuckle_outer_bearing_params(bearing_od=knuckle_outer_bearing_od,
                                      bearing_w=knuckle_outer_bearing_w,
                                      bearing_z_clearance=knuckle_outer_bearing_z_clearance,
                                      bearing_clearance=knuckle_outer_bearing_clearance,
                                      spacer_h=knuckle_bearing_spacer_h,
                                      wall_thickness=knuckle_outer_wall_thickness) =
  let (outer_bearing_seat_h=bearing_w + bearing_z_clearance,
       height=outer_bearing_seat_h + spacer_h,
       outer_bearing_seat_d=bearing_od + bearing_clearance,
       outer_bearing_seat_od=outer_bearing_seat_d + wall_thickness * 2)
  [outer_bearing_seat_od, outer_bearing_seat_d, outer_bearing_seat_h, height];

function knuckle_ball_stud_joint_params(lower_height,
                                        outer_bearing_seat_od,
                                        total_knuckle_len=knuckle_total_len,
                                        base_knuckle_d=knuckle_base_d,
                                        ball_stud_mount_od=knuckle_ball_stud_mount_outer_d,
                                        ball_stud_housing_h=knuckle_ball_stud_house_h,
                                        steering_arm_base_w=knuckle_arm_base_w) =
  let (joint_len = (total_knuckle_len
                    - (ball_stud_mount_od * 2)
                    - base_knuckle_d) / 2,
       joint_w = ball_stud_mount_od * 0.8,
       ball_stud_housing_x = joint_len + ball_stud_mount_od / 2,
       ball_stud_mount_x = outer_bearing_seat_od / 2 + ball_stud_housing_x,
       joint_h = min(lower_height + knuckle_arm_base_w, knuckle_ball_stud_house_h))
  [ball_stud_housing_x, ball_stud_mount_x, joint_w, joint_len, joint_h];

function steering_arm_planar_params(arm_len=knuckle_arm_base_len,
                                    arm_angle=knuckle_arm_angle,
                                    ear_len=knuckle_arm_ear_len,
                                    bolt_d=knuckle_arm_bolt_d,
                                    bolt_edge_offset=knuckle_arm_bolt_hole_offset) =
  let (arm_dx=arm_len * sin(arm_angle),
       arm_dy=arm_len * cos(arm_angle),
       ear_base_len=ear_len - bolt_d - bolt_edge_offset)
  [arm_dx, arm_dy, ear_base_len];

// Calculate the position of the center of the bolt hole for the steering link
// (tie rod end) on the knuckle’s steering arm, measured from the center of the knuckle.
function steering_arm_bolt_pos_from_planar(planar_params,
                                           knuckle_outer_d=knuckle_arm_ring_outer_d,
                                           bolt_d=knuckle_arm_bolt_d,
                                           bolt_edge_offset=knuckle_arm_bolt_hole_offset,
                                           thickness=knuckle_arm_thickness) =
  let (arm_dy=planar_params[1],
       ear_base_len=planar_params[2],
       pos=thickness + knuckle_outer_d / 2 + arm_dy
       + ear_base_len
       + bolt_d / 2
       - (bolt_d - snap_bolt_d(bolt_d)))
  pos;
