include <colors.scad>
include <parameters.scad>


bellcrank_arm_dia                          = 10.24;
bellcrank_arm_h                            = 32;
bellcrank_arm_inner_dia                    = 7.9;
bellcrank_arm_w                            = 6.25;
bellcrank_link_bolt_spacing                = [48.0, 0];
bellcrank_arm_len                          = 20.8;
bellcrank_arm_thickness                    = 2.9;
chassis_bellcrank_y_base                   = 31.75;

bellcrank_arm_z                            = 10.3;
bellcrank_pitman_arm_z                     = 19.55;

bellcrank_arm_bolt_gap                     = 4;
bellcrank_arm_bolt_padding                 = 2;
bellcrank_arm_bolt_inner_padding           = 1;
bellcrank_arm_bolt_d                       = 3;
bellcrank_arm_bolt_n                       = 2;

pitman_arm_bolt_boss_spacing               = 1;
pitman_arm_h                               = 24.3;
pitman_arm_bolt_boss_padding               = 1.2;
pitman_arm_boss_h                          = 6.5;
pitman_arm_boss_w                          = 4.6;

pitman_arm_boss_inner_padding              = 1;
pitman_arm_bolt_n                          = 3;
pitman_arm_bolt_d                          = 3;

chassis_bellcrank_position_y               = chassis_bellcrank_y_base + ((bellcrank_arm_dia - bellcrank_arm_w) / 2);
chassis_bellcrank_mount_len                = chassis_bellcrank_y_base;
chassis_bellcrank_link_padding_x           = bellcrank_arm_dia / 2;
chassis_bellcrank_mount_w                  = bellcrank_link_bolt_spacing[0] + chassis_bellcrank_link_padding_x * 2;

upper_chassis_bellcrank_bolt_d             = m3_hole_dia;
upper_chassis_bellcrank_bolt_bore_d        = m3_countersunk_head_dia + 0.2;
upper_chassis_bellcrank_bolt_bore_h        = m3_countersunk_head_h + 0.15;
upper_chassis_t                            = 4;

lower_arm_chassis_mount_bolt_d             = m3_hole_dia;
lower_arm_chassis_mount_bolt_spacing_outer = [34.0, 18.45];
lower_arm_chassis_mount_bolt_spacing_inner = [34.0, 5.5];
lower_arm_chassis_mount_bolt_outer_padding = 4.6;

chassis_center_mount_padding_y             = 3;
chassis_center_mount_padding_x             = 2;
chassis_center_transition_len              = 7.5;

chassis_center_transition_w                = 27;

steering_servo_mount_bolt_d                = m3_hole_dia;
steering_servo_mount_bolt_bore_d           = m3_countersunk_head_dia + 0.2;
steering_servo_mount_bolt_bore_h           = m3_countersunk_head_h + 0.15;

steering_servo_tie_rod_body_total_len      = 73.16;
steering_servo_tie_rod_thread_len          = 8.8;
steering_servo_tie_rod_body_len            = steering_servo_tie_rod_body_total_len
                                              - steering_servo_tie_rod_thread_len * 2;
steering_servo_tie_rod_body_d              = 5.65;
steering_servo_tie_rod_body_end_len        = 5;
steering_servo_tie_rod_thread_d            = m3_hole_dia;
steering_servo_tie_rod_fn                  = 6;
steering_servo_tie_rod_color               = metallic_silver_1;

steering_servo_tie_rod_eye_od              = 7.5;
steering_servo_tie_rod_eye_h               = 3.20;

steering_servo_tie_rod_shank_od            = 4.4;
steering_servo_tie_rod_shank_bolt_d        = steering_servo_tie_rod_thread_d;
steering_servo_tie_rod_neck_len            = 2.05;
steering_servo_tie_rod_neck_h              = 3.22;
steering_servo_tie_rod_shank_len           = 10.5;

steering_servo_tie_rod_bushing_od          = 3.6;
steering_servo_tie_rod_bushing_d           = 2.5;
steering_servo_tie_rod_bushing_h           = 7;
steering_servo_tie_rod_bushing_flat_d      = 4.4;

steering_servo_tie_rod_bushing_color       = metallic_silver_9;

steering_servo_arm_total_l                 = 35.4;
steering_servo_arm_d                       = 14.75;
steering_servo_arm_len                     = steering_servo_arm_total_l - steering_servo_arm_d;
steering_servo_arm_w                       = 7.6;
steering_servo_arm_base_h                  = 6.0;

steering_servo_arm_bolt_boss_h             = 5.9;
steering_servo_arm_bolt_boss_w             = 6;

steering_servo_arm_bolt_boss_spacing       = 1;
steering_servo_arm_bolt_boss_padding       = 1.2;
steering_servo_arm_bolt_boss_inner_padding = 1.0;
steering_servo_arm_thickness               = 3.75;
steering_servo_arm_bolt_d                  = m3_hole_dia;
steering_servo_arm_center_bolt_d           = m3_hole_dia;
steering_servo_arm_center_bolt_bore_d      = 7.8;
steering_servo_arm_center_bolt_bore_h      = 1.2;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle
// ─────────────────────────────────────────────────────────────────────────────

heat_insert_nut_flange_d                   = 6.95;
heat_insert_nut_flange_h                   = 5.4;
heat_insert_nut_outer_d                    = 5.85;
heat_insert_nut_hole_d                     = 5.0;
heat_insert_nut_h                          = 4.94;

// ─────────────────────────────────────────────────────────────────────────────
// Ball stud
// ─────────────────────────────────────────────────────────────────────────────

knuckle_ball_stud_shank_d                  = 4.8;
knuckle_ball_stud_ball_d                   = 8.6;
knuckle_ball_stud_ball_hole_d              = 3.3;
knuckle_ball_stud_h                        = 17.8;
knuckle_ball_stud_unthreaded_h             = 5;

// ─────────────────────────────────────────────────────────────────────────────
// Upper wishbone arm
// ─────────────────────────────────────────────────────────────────────────────
upper_arm_len                              = 41.8;
// the height of the arm excluding upper_arm_ball_stud_mount_extra_h
upper_arm_h                                = 24;
// rounding radius of the hole on the arm
upper_arm_hole_corner_r                    = 2.5;

// rounding radius of the shape
upper_arm_corner_rad                       = 0.5;
upper_arm_thickness                        = 6.5;
upper_arm_pin_d                            = 3.4;

// the length of the side cutout between barrels
upper_arm_side_cutout_depth                = 9;
// the height of one hinge barrel
upper_arm_hinge_barrel_h                   = 6.9;

upper_arm_joint_mount_len                  = 15.19;
upper_arm_joint_mount_h                    = 9.5;
upper_arm_ball_stud_mount_extra_thickness  = 1.5;
// the addional height for ball stud
upper_arm_ball_stud_mount_extra_h          = upper_arm_joint_mount_h / 2;

upper_arm_side_w                           = 4.5;

upper_arm_ball_stud_hole_depth             = knuckle_ball_stud_h - knuckle_ball_stud_unthreaded_h;

// ─────────────────────────────────────────────────────────────────────────────
// Lower Wishbone Arm
// ─────────────────────────────────────────────────────────────────────────────

// Overall length of the lower arm (X direction), from hinge end to ball-stud end.
lower_arm_len                              = 48.8;

// Overall height/envelope of the arm profile (Y direction).
lower_arm_h                                = 39.25;

// Main body thickness of the arm (Z direction) for the extruded profile.
lower_arm_thickness                        = 6.0;

// Width of the apex/bridge region near the ball-stud end used in profile shaping/cutouts.
lower_arm_apex_width                       = 9.1;

// Nominal width of each “leg” of the A-arm in the 2D profile.
lower_arm_leg_width                        = 4.0;

// Outer fillet radius applied to the arm outline (rounded outer edges).
lower_arm_corner_r                         = 1.5;

// Length of a hinge barrel (one of the cylindrical hinge lugs) along X.
lower_arm_hinge_barrel_len                 = 10.3;

// Height/diameter envelope of the hinge barrel feature (used by the 2D barrel sketch).
lower_arm_hinge_barrel_h                   = 7.85;

// Diameter of the hinge pin hole through each hinge barrel.
lower_arm_hinge_barrel_hole_d              = 3.4;

// Offset from the barrel’s left edge to the hinge hole center (sets hole position).
lower_arm_hinge_barrel_hole_offset         = 1.7;

// Height (projection) of the damper mounting boss.
lower_arm_damper_boss_h                    = 8.2;

// Diameter of the damper mounting boss (outer).
lower_arm_damper_boss_d                    = 5.6;

// Diameter of the through-hole in the damper boss for the damper fastener.
lower_arm_damper_boss_hole_d               = 3;

// Corner radius used for the inner profile hole.
lower_arm_relief_hole_corner_r             = 2;

// X-offset used when positioning the damper boss relative to the arm end.
lower_arm_upper_boss_x_offset              = 5.9;

// Y-offset used when positioning the damper boss / upper cutout reference.
lower_arm_upper_boss_y_offset              = 3.7;

// Size of the ball-stud/rod-end mounting block: [length(X), width(Y), thickness(Z)]
lower_arm_ball_stud_mount_size             = [14, 5.5, 7.5];

// Depth of the ball-stud mounting hole/counterbore along X.
lower_arm_ball_stud_hole_depth             = knuckle_ball_stud_h
                                              - knuckle_ball_stud_unthreaded_h;