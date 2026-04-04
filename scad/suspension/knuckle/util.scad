// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's common functions
// ─────────────────────────────────────────────────────────────────────────────
include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>


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