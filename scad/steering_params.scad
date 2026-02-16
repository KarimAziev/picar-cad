include <colors.scad>
include <parameters.scad>


bellcrank_arm_dia                          = 10.24;
bellcrank_arm_h                            = 32;
bellcrank_arm_inner_dia                    = 7.9;
bellcrank_arm_w                            = 6.25;
bellcrank_link_bolt_spacing                = [50.0, 0];
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
pitman_arm_boss_l                          = 12.7;
pitman_arm_boss_inner_padding              = 1;
pitman_arm_bolt_n                          = 3;
pitman_arm_bolt_d                          = 3;

chassis_bellcrank_position_y               = chassis_bellcrank_y_base + ((bellcrank_arm_dia - bellcrank_arm_w) / 2);
chassis_bellcrank_mount_len                = chassis_bellcrank_y_base + bellcrank_arm_dia;
chassis_bellcrank_link_padding_x           = bellcrank_arm_dia / 2;
chassis_bellcrank_mount_w                  = bellcrank_link_bolt_spacing[0] + chassis_bellcrank_link_padding_x * 2;

upper_chassis_base_w                       = 100;

upper_chassis_transition_len               = 40;
upper_chassis_base_len                     = 60;
upper_chassis_upper_len                    = 51;

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
chassis_center_upper_transition_len        = 8.54;
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
steering_servo_arm_bolt_boss_l             = 10;
steering_servo_arm_bolt_boss_spacing       = 1;
steering_servo_arm_bolt_boss_padding       = 1.2;
steering_servo_arm_bolt_boss_inner_padding = 1.0;
steering_servo_arm_thickness               = 3.75;
steering_servo_arm_bolt_d                  = m3_hole_dia;
steering_servo_arm_center_bolt_d           = m3_hole_dia;
steering_servo_arm_center_bolt_bore_d      = 7.8;
steering_servo_arm_center_bolt_bore_h      = 1.2;
