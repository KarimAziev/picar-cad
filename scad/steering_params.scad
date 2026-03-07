include <colors.scad>
include <parameters.scad>


// Total length (bar plus two rings) of the “dogbone” plate
ackermann_plate_len                        = 56.7;
// Overall width of the “dogbone” plate
ackermann_plate_w                          = 4.8;
// Overall thickness of the “dogbone” plate
ackermann_plate_thickness                  = 3.9;
// Diameter of the holes
ackermann_plate_hole_d                     = 4.7;
// Outer diameter of the bosses
ackermann_plate_boss_od                    = 8;
// Height of the bosses
ackermann_plate_boss_h                     = 4.9;

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

chassis_bellcrank_position_y               = chassis_bellcrank_y_base
                                              + ((bellcrank_arm_dia
                                              - bellcrank_arm_w) / 2);
chassis_bellcrank_mount_len                = chassis_bellcrank_y_base;
chassis_bellcrank_link_padding_x           = bellcrank_arm_dia / 2;
chassis_bellcrank_mount_w                  = bellcrank_link_bolt_spacing[0]
                                              + chassis_bellcrank_link_padding_x * 2;

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

heat_insert_nut_flange_d                   = 6.95;
heat_insert_nut_flange_h                   = 5.4;
heat_insert_nut_outer_d                    = 5.85;
heat_insert_nut_hole_d                     = 5.0;
heat_insert_nut_h                          = 4.94;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle
// ─────────────────────────────────────────────────────────────────────────────
knuckle_total_len                          = 42.7;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's steering arm and it's outer ring
// ─────────────────────────────────────────────────────────────────────────────

knuckle_outer_wall_thickness               = 1.7;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's bearings
// ─────────────────────────────────────────────────────────────────────────────
// Knuckle uses two bearings: inner (bigger) and outer (smaller)

// ─────────────────────────────────────────────────────────────────────────────
// Inner (bigger) bearing
// ─────────────────────────────────────────────────────────────────────────────
// outer diameter
knuckle_inner_bearing_od                   = 15;
// hole diameter
knuckle_inner_bearing_bore_d               = 10;
// width of the bearing
knuckle_inner_bearing_w                    = 4;

// Clearance between the bearing OD and the knuckle bearing seat diameter.
knuckle_inner_bearing_clearance            = 0.1;
// Clearance between the bearing width and the knuckle bearing seat depth
knuckle_inner_bearing_z_clearance          = 0.1;

// The actual hole diameter in the knuckle for the bearing
knuckle_inner_bearing_seat_d               = 15.1;
knuckle_inner_bearing_shoulder_d           = 13;

// ─────────────────────────────────────────────────────────────────────────────
// Outer (smaller) bearing
// ─────────────────────────────────────────────────────────────────────────────

// outer diameter
knuckle_outer_bearing_od                   = 10;
// hole diameter
knuckle_outer_bearing_bore_d               = 5;
// width of the bearing
knuckle_outer_bearing_w                    = 4;

// Clearance between the bearing OD and the knuckle bearing seat diameter.
knuckle_outer_bearing_clearance            = 0.1;
// Clearance between the bearing width and the knuckle bearing seat depth
knuckle_outer_bearing_z_clearance          = 0.1;

knuckle_bearing_spacer_h                   = 1.6;
knuckle_bearing_spacer_ring_d              = 8;
// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's steering arm mount with its ring
// ─────────────────────────────────────────────────────────────────────────────
knuckle_arm_thickness                      = 4.2;
knuckle_arm_bolt_d                         = m3_hole_dia;
knuckle_arm_bolt_hole_offet                = 2.7;
knuckle_arm_ring_outer_d                   = knuckle_inner_bearing_seat_d
                                              + knuckle_outer_wall_thickness * 2;

knuckle_arm_base_w                         = 9;
knuckle_arm_narrow_w                       = 6.06;

// the length of the main part
knuckle_arm_base_len                       = 13.3;
// the length of the part, that connects arm with knuckle
knuckle_arm_ring_connector_l               = 4.5;
// the length of the part with bolt holes
knuckle_arm_ear_len                        = 13;

knuckle_arm_angle                          = 54;

knuckle_arm_holes_n                        = 2;
knuckle_arm_holes_gap                      = 2;

knuckle_arm_corner_r                       = 1;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's ball stud
// ─────────────────────────────────────────────────────────────────────────────

knuckle_ball_stud_shank_d                  = 4.8;
knuckle_ball_stud_ball_d                   = 8.8;
knuckle_ball_stud_ball_hole_d              = 3.3;
knuckle_ball_stud_h                        = 17.8;
knuckle_ball_stud_unthreaded_h             = 5;

// ─────────────────────────────────────────────────────────────────────────────
// Knuckle's ball stud housing for lower and upper arms
// ─────────────────────────────────────────────────────────────────────────────

knuckle_ball_stud_mount_hole_d             = knuckle_ball_stud_ball_d + 0.8;
knuckle_ball_stud_mount_thickness          = 1.6;
knuckle_ball_stud_mount_outer_d            = knuckle_ball_stud_mount_hole_d + knuckle_ball_stud_mount_thickness * 2;
knuckle_ball_stud_house_h                  = 14.5;
knuckle_ball_stud_sphere_h                 = 2;
knuckle_ball_stud_cap_hole_size            = [6.8, knuckle_ball_stud_ball_d];

/** The ball stud is secured either by:
 *   1. a bushing and a threaded plug with an internal hex (hex socket), or
 *   2. a simple horizontal stopper bolt threaded through the housing (past the
 *      bushing) to prevent the ball stud from falling out. To use this option,
 *      set `knuckle_ball_stud_stopper_d` to the desired bolt diameter.
 */
knuckle_ball_stud_stopper_d                = 0;
knuckle_ball_stud_stopper_offset           = 2;
// ─────────────────────────────────────────────────────────────────────────────
// Bushing for the ball stud
// ─────────────────────────────────────────────────────────────────────────────
knuckle_bushing_d                          = 9;
knuckle_bushing_hole_d                     = 4;
knuckle_bushing_h                          = 3;
knuckle_bushing_thickness                  = 0.6;
knuckle_bushing_hole_border_w              = 0.8;

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
steering_servo_arm_len                     = steering_servo_arm_total_l
                                              - steering_servo_arm_d;
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
// Lower Wishbone Arm
// ─────────────────────────────────────────────────────────────────────────────

// Overall length of the lower arm (X direction), from hinge end to ball-stud end.
lower_arm_len                              = 48.8;

// Overall height/envelope of the arm profile (Y direction).
lower_arm_h                                = 39.25;

// Main body thickness of the arm (Z direction) for the extruded profile.
lower_arm_thickness                        = 7.5;

// Width of the apex/bridge region near the ball-stud end used in profile shaping/cutouts.
lower_arm_apex_width                       = 9.1;

// Nominal width of each “leg” of the A-arm in the 2D profile.
lower_arm_leg_width                        = 4.0;

// Outer fillet radius applied to the arm outline (rounded outer edges).
lower_arm_corner_r                         = 1.5;

// Length of a hinge barrel (one of the cylindrical hinge lugs) along X.
lower_arm_hinge_barrel_len                 = 10.3;

// Height envelope of the upper hinge barrel feature (used by the 2D barrel sketch).
lower_arm_upper_hinge_barrel_h             = 7.85;

// Height envelope of the lower hinge barrel feature (used by the 2D barrel sketch).
lower_arm_lower_hinge_barrel_h             = 6.6;

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
lower_arm_ball_stud_mount_size             = [14, 6.5, 7.5];

// If printing is difficult, you can disable the cutout on the outer bottom edge
// and print it on that edge.
lower_arm_use_lower_edge_cutout            = true;

// Depth of the ball-stud mounting hole/counterbore along X.
lower_arm_ball_stud_hole_depth             = knuckle_ball_stud_h
                                              - knuckle_ball_stud_unthreaded_h;

// ─────────────────────────────────────────────────────────────────────────────
// Upper wishbone arm
// ─────────────────────────────────────────────────────────────────────────────

// Overall length of the upper arm (X direction), from hinge end to ball-stud end.
upper_arm_len                              = 41.8;

// Overall height/envelope of the arm profile (Y direction) excluding
// upper_arm_ball_stud_mount_extra_h
upper_arm_h                                = 24;

// rounding radius of the hole on the arm
upper_arm_hole_corner_r                    = 2.5;

// Outer fillet radius applied to the arm outline (rounded outer edges).
upper_arm_corner_r                         = 0.5;

// Main body thickness of the arm (Z direction) for the extruded profile.
upper_arm_thickness                        = 6.5;

// Length of a hinge barrel (one of the cylindrical hinge lugs) along X.
upper_arm_hinge_barrel_len                 = 9;

// Height envelope of the hinge barrel feature (used by the 2D barrel sketch).
upper_arm_hinge_barrel_h                   = 6.9;

// Diameter of the hinge pin hole through each hinge barrel.
upper_arm_hinge_barrel_hole_d              = 3.4;

// Offset from the barrel’s left edge to the hinge hole center (sets hole position).
upper_arm_hinge_barrel_hole_offset         = 1.7;

// Size of the ball-stud/rod-end mounting block: [length(X), width(Y), thickness(Z)]
upper_arm_ball_stud_mount_size             = [15.19, 9.5, upper_arm_thickness + 1.5];

// the addional height for ball stud
upper_arm_ball_stud_mount_extra_h          = upper_arm_ball_stud_mount_size[1] / 2;

// Nominal width of each “leg” of the A-arm in the 2D profile.
upper_arm_leg_width                        = 4.5;

// Depth of the ball-stud mounting hole/counterbore along X.
upper_arm_ball_stud_hole_depth             = knuckle_ball_stud_h - knuckle_ball_stud_unthreaded_h;
