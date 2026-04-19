include <../colors.scad>
include <../parameters.scad>
include <../steering_params.scad>

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
use <bellcrank/center_link.scad>
use <bellcrank_steering_assembly.scad>
use <bellcrank_steering_slots.scad>
use <bulkhead/front_bulkhead_chassis.scad>
use <bulkhead/front_bulkhead_housing.scad>
use <front_suspension_assembly.scad>
use <steering_servo_bracket/steering_servo_bracket_assembly.scad>
use <steering_servo_bracket/steering_servo_chassis_slots.scad>

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

module upper_chassis(show_bellcrank_drive=show_bellcrank_drive,
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
                     show_chassis=show_chassis) {

  dservo_bb = dservo_tie_rod_bbox();
  shaft_len = dservo_bb[1] - dservo_bb[4];

  extra_len = shaft_len
    + servo_tie_rod_a_eye_od / 2
    + ((dsservo_hat_w - dsservo_size[0]) / 2);

  bellcrank_mount_len = max(chassis_bellcrank_position_y,
                            chassis_bellcrank_mount_len)
    + max(upper_chassis_bellcrank_bolt_bore_d,
          bellcrank_idler_od);

  module _chassis() {
    difference() {
      union() {
        front_bulkhead_chassis();
        linear_extrude(height=upper_chassis_t, center=false) {
          hull() {
            translate([-chassis_bellcrank_mount_w / 2,
                       -bellcrank_mount_len,
                       0]) {
              union() {
                trapezoid(b=chassis_bellcrank_mount_w,
                          h=bellcrank_mount_len,
                          t=chassis_center_transition_w,
                          center=false);
              }
            }
            translate([0,
                       -chassis_bellcrank_position_y - upper_chassis_bellcrank_bolt_bore_d / 2,
                       0]) {
              four_corner_children(size=[chassis_bellcrank_spacing, 0],
                                   center=true) {
                circle(d=bellcrank_idler_od);
              }
            }
            translate([0, -extra_len / 2 - bellcrank_mount_len, 0]) {
              trapezoid_rounded_top(t=chassis_bellcrank_mount_w,
                                    b=chassis_bellcrank_mount_w,
                                    h=extra_len,
                                    center=true,
                                    r=2);
            }
          }
        }
      }
      translate([0,
                 -chassis_bellcrank_position_y - upper_chassis_bellcrank_bolt_bore_d / 2,
                 0]) {
        bellcrank_steering_slots();
      }
    }
  }

  if (show_chassis) {
    _chassis();
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
             -chassis_bellcrank_position_y - upper_chassis_bellcrank_bolt_bore_d / 2,
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
                                show_steering_servo_brackets=show_steering_servo_brackets);
  }
}

module upper_chassis_printable() {
  rotate([0, 180, 0]) {
    upper_chassis(show_chassis=true,
                  show_bellcrank_drive=false,
                  show_bellcrank_drive_idler_lever=false,
                  show_bellcrank_drive_servo_lever=false,
                  show_bellcrank_drive_upper_cap=false,
                  show_bellcrank_idler=false,
                  show_bellcrank_post=false,
                  show_bellcrank_idler_lever=false,
                  show_idler_upper_bearing=false,
                  show_idler_lower_bearing=false,
                  show_steering_servo=false,
                  show_steering_servo_bracket_bolt=false,
                  show_steering_servo_chassis_bolt=false,
                  show_steering_servo_chassis_bolt_nut=false,
                  show_steering_servo_bracket_bolt_nut=false,
                  show_steering_servo_brackets=false,
                  show_steering_assembly=false,
                  show_center_link=false,
                  show_front_lower_arm=false,
                  show_front_lower_arm_pin=false,
                  show_front_lower_pin_e_clip=false,
                  show_front_lower_arm_ball_stud=false,
                  show_front_upper_arm=false,
                  show_front_bulkhead=false,
                  show_front_bulkhead_upper_suspension_holder=false,
                  show_upper_arm_ball_stud=false,
                  show_front_upper_arm_pin=false,
                  show_front_shock_tower=false,
                  show_front_suspension_arm_pad=false,
                  show_left_knuckle=false,
                  show_right_knuckle=false,
                  show_knuckle_bushing=false,
                  show_knuckle_inner_bearing=false,
                  show_knuckle_outer_bearing=false,
                  show_knuckle_tie_rod=false,
                  show_front_bulkhead_housing=false);
  }
}

upper_chassis_printable();
// upper_chassis();