include <../colors.scad>
include <../parameters.scad>
include <../steering_params.scad>

use <../lib/debug.scad>
use <../lib/functions.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../lib/trapezoids.scad>
use <../placeholders/dservo.scad>
use <../placeholders/rpi_5.scad>
use <../power/power_case.scad>
use <bellcrank/bellcrank_drive.scad>
use <bellcrank/bellcrank_idler.scad>
use <bellcrank/bellcrank_slots.scad>
use <bellcrank/center_link.scad>
use <bellcrank_steering_assembly.scad>
use <bellcrank_steering_slots.scad>
use <bulkhead/front_bulkhead_chassis.scad>
use <bulkhead/front_bulkhead_housing.scad>
use <front_suspension_assembly.scad>
use <steering_servo_bracket/steering_servo_bracket_assembly.scad>
use <steering_servo_bracket/steering_servo_chassis_slots.scad>
use <wishbone_arms/lower_arm.scad>

show_chassis                                = true;

show_bellcrank_drive                        = true;
show_bellcrank_drive_idler_lever            = true;
show_bellcrank_drive_servo_lever            = true;
show_bellcrank_drive_upper_cap              = true;

show_bellcrank_idler                        = true;
show_bellcrank_post                         = true;
show_bellcrank_idler_lever                  = true;

show_idler_upper_bearing                    = true;
show_idler_lower_bearing                    = true;

show_steering_servo                         = true;
show_steering_servo_bracket_bolt            = true;
show_steering_servo_chassis_bolt            = true;
show_steering_servo_chassis_bolt_nut        = true;
show_steering_servo_bracket_bolt_nut        = true;
show_steering_servo_brackets                = true;

show_steering_assembly                      = true;

show_center_link                            = true;

show_front_lower_arm                        = false;
show_front_lower_arm_pin                    = false;
show_front_lower_pin_e_clip                 = false;
show_front_lower_arm_ball_stud              = false;

show_front_upper_arm                        = true;

show_front_bulkhead                         = true;
show_front_bulkhead_upper_suspension_holder = true;

show_upper_arm_ball_stud                    = true;
show_front_upper_arm_pin                    = true;

show_front_shock_tower                      = true;
show_front_suspension_arm_pad               = true;

show_left_knuckle                           = true;
show_right_knuckle                          = false;
show_knuckle_bushing                        = false;
show_knuckle_inner_bearing                  = false;
show_knuckle_outer_bearing                  = false;
show_knuckle_tie_rod                        = true;

show_front_bulkhead_housing                 = true;

// Steering angle
steering_servo_angle                        = 0; // [-40:1:40]

module upper_chassis(debug=false, color=white_smoke_1) {
  bellcrank_params = bellcrank_steering_servo_position();
  bellcrank_x_dist = abs(bellcrank_params[0]);
  bellcrank_y_dist = bellcrank_params[1];
  bellcrank_zone_y_len = bellcrank_params[2];

  bellcrank_mount_d = max(bellcrank_idler_od,
                          upper_chassis_bellcrank_bolt_d,
                          upper_chassis_bellcrank_bolt_bore_d);

  bellcrank_mount_r = bellcrank_mount_d / 2;

  servo_slot_min_w = dsservo_height_after_flange() + bellcrank_x_dist;

  bulkhead_barrel_size = lower_arm_mount_cutout_size();
  bulkhead_barrel_len = bulkhead_barrel_size[1]
    - front_bulkhead_barrel_hinge_clearance;
  bulkhead_transition_len = front_bulkhead_len
    - bulkhead_barrel_len
    - front_bulkhead_barrel_y_offset;

  bulkhead_base_size = front_bulkhead_base_size(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                                d=front_bulkhead_mount_bolt_d,
                                                padding_x=chassis_center_mount_padding_x,
                                                padding_y=chassis_center_mount_padding_y);
  bulkhead_size_x = bulkhead_base_size[0];
  bulkhead_size_y = bulkhead_base_size[1];

  bellcrank_x = chassis_bellcrank_spacing / 2;

  pts = [[0, bulkhead_size_y + bulkhead_transition_len],
         [bulkhead_size_x / 2, bulkhead_size_y + bulkhead_transition_len],
         [bulkhead_size_x / 2, bulkhead_transition_len],
// [front_bulkhead_w / 2, 0],
         [bellcrank_x,
          -bellcrank_y_distance_from_bulkhead + bellcrank_mount_r],
         [bellcrank_x,
          -bellcrank_y_distance_from_bulkhead + bellcrank_mount_r],
         [bellcrank_x + bellcrank_mount_r,
          -bellcrank_y_distance_from_bulkhead],
         [bellcrank_x + bellcrank_mount_r,
          -bellcrank_y_distance_from_bulkhead - bellcrank_mount_r],
         [servo_slot_min_w,
          -bellcrank_y_distance_from_bulkhead + bellcrank_y_dist],
         [servo_slot_min_w,
          -bellcrank_y_distance_from_bulkhead + bellcrank_zone_y_len],
         [0, -bellcrank_y_distance_from_bulkhead + bellcrank_zone_y_len]];

  difference() {
    maybe_color(color) {
      linear_extrude(height=upper_chassis_t, center=false, convexity=2) {
        offset_vertices_2d(r=0) {
          mirror_copy([1, 0, 0]) {
            polygon(pts);
          }
        }
      }
    }
    front_bulk_head_housing_slots_non_center_y();
    translate([0,
               -bellcrank_y_distance_from_bulkhead,
               0]) {
      bellcrank_steering_slots();
    }
  }

  if (debug) {
    translate([0, 0, upper_chassis_t]) {
      debug_polygon_text(pts);
    }
  }
}

module upper_chassis_assembly(show_bellcrank_drive=show_bellcrank_drive,
                              show_bellcrank_idler=show_bellcrank_idler,
                              show_bellcrank_post=show_bellcrank_post,
                              show_bellcrank_idler_lever=show_bellcrank_idler_lever,
                              show_idler_upper_bearing=show_idler_upper_bearing,
                              show_idler_lower_bearing=show_idler_lower_bearing,
                              show_steering_servo=show_steering_servo,
                              show_steering_servo=show_steering_servo,
                              show_steering_servo_bracket_bolt=show_steering_servo_bracket_bolt,
                              show_steering_servo_chassis_bolt=show_steering_servo_chassis_bolt,
                              show_steering_servo_chassis_bolt_nut=show_steering_servo_chassis_bolt_nut,
                              show_steering_servo_bracket_bolt_nut=show_steering_servo_bracket_bolt_nut,
                              show_steering_servo_brackets=show_steering_servo_brackets,
                              show_steering_assembly=show_steering_assembly,
                              show_center_link=show_center_link,
                              show_front_lower_arm=show_front_lower_arm,
                              show_front_lower_arm_pin=show_front_lower_arm_pin,
                              show_front_lower_pin_e_clip=show_front_lower_pin_e_clip,
                              show_front_lower_arm_ball_stud=show_front_lower_arm_ball_stud,
                              show_front_upper_arm=show_front_upper_arm,
                              show_front_bulkhead=show_front_bulkhead,
                              show_front_bulkhead_upper_suspension_holder=show_front_bulkhead_upper_suspension_holder,
                              show_upper_arm_ball_stud=show_upper_arm_ball_stud,
                              show_front_upper_arm_pin=show_front_upper_arm_pin,
                              show_front_shock_tower=show_front_shock_tower,
                              show_front_suspension_arm_pad=show_front_suspension_arm_pad,
                              show_left_knuckle=show_left_knuckle,
                              show_right_knuckle=show_right_knuckle,
                              show_knuckle_bushing=show_knuckle_bushing,
                              show_knuckle_inner_bearing=show_knuckle_inner_bearing,
                              show_knuckle_outer_bearing=show_knuckle_outer_bearing,
                              show_knuckle_tie_rod=show_knuckle_tie_rod,
                              show_front_bulkhead_housing=show_front_bulkhead_housing,
                              show_bellcrank_drive_idler_lever=show_bellcrank_drive_idler_lever,
                              show_bellcrank_drive_servo_lever=show_bellcrank_drive_servo_lever,
                              show_bellcrank_drive_upper_cap=show_bellcrank_drive_upper_cap,
                              steering_servo_angle=steering_servo_angle,
                              show_chassis=show_chassis) {
  if (show_chassis) {
    upper_chassis();
  }

  if (show_steering_assembly) {
    translate([0, 0, upper_chassis_t]) {
      front_suspension_assembly(show_front_lower_arm=show_front_lower_arm,
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
                                show_front_bulkhead_housing=show_front_bulkhead_housing);
    }
  }

  translate([0,
             -bellcrank_y_distance_from_bulkhead,
             upper_chassis_t]) {
    bellcrank_steering_assembly(show_bellcrank_drive=show_bellcrank_drive,
                                show_bellcrank_drive_idler_lever=show_bellcrank_drive_idler_lever,
                                show_bellcrank_drive_servo_lever=show_bellcrank_drive_servo_lever,
                                show_bellcrank_drive_upper_cap=show_bellcrank_drive_upper_cap,
                                show_bellcrank_idler=show_bellcrank_idler,
                                show_bellcrank_post=show_bellcrank_post,
                                show_bellcrank_idler_lever=show_bellcrank_idler_lever,
                                show_idler_upper_bearing=show_idler_upper_bearing,
                                show_idler_lower_bearing=show_idler_lower_bearing,
                                show_center_link=show_center_link,
                                show_steering_servo=show_steering_servo,
                                show_steering_servo_bracket_bolt=show_steering_servo_bracket_bolt,
                                show_steering_servo_chassis_bolt=show_steering_servo_chassis_bolt,
                                show_steering_servo_chassis_bolt_nut=show_steering_servo_chassis_bolt_nut,
                                show_steering_servo_bracket_bolt_nut=show_steering_servo_bracket_bolt_nut,
                                show_steering_servo_brackets=show_steering_servo_brackets,
                                steering_servo_angle=steering_servo_angle);
  }
}

module upper_chassis_printable() {
  rotate([0, 180, 0]) {
    upper_chassis();
  }
}

upper_chassis_printable();

// upper_chassis_assembly();