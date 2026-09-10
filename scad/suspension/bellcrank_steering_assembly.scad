/**
  * Module: Bellcrank and steering servo assembly
  *
  * This module showcases the assembly of the bellcrank drive, bellcrank idler,
  * center link, and steering servo.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../steering_params.scad>

use <../lib/shapes3d.scad>
use <../placeholders/dservo.scad>
use <bellcrank/bellcrank_assembly.scad>
use <bellcrank/bellcrank_drive.scad>
use <bellcrank_steering_slots.scad>
use <steering_servo_bracket/steering_servo_bracket_assembly.scad>

show_bellcrank_drive                 = true;
show_bellcrank_drive_idler_lever     = true;
show_bellcrank_drive_servo_lever     = true;
show_bellcrank_drive_upper_cap       = true;

show_bellcrank_idler                 = true;
show_bellcrank_post                  = true;
show_bellcrank_idler_lever           = true;

show_idler_upper_bearing             = true;
show_idler_lower_bearing             = true;
show_center_link                     = true;

show_steering_servo                  = true;
show_steering_servo_bracket_bolt     = true;
show_steering_servo_chassis_bolt     = true;
show_steering_servo_chassis_bolt_nut = true;
show_steering_servo_bracket_bolt_nut = true;
show_steering_servo_brackets         = true;
show_steering_servo_encoder          = true;
show_steering_servo_encoder_bracket  = true;
show_steering_servo_magnet           = true;

// Steering angle
steering_servo_angle                 = 0; // [-40:1:40]
steering_servo_spacing               = 0; // [0:1:30]

module bellcrank_steering_assembly(show_bellcrank_drive=show_bellcrank_drive,
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
                                   show_steering_servo_encoder=show_steering_servo_encoder,
                                   show_steering_servo_encoder_bracket=show_steering_servo_encoder_bracket,
                                   show_steering_servo_magnet=show_steering_servo_magnet,
                                   steering_servo_angle=steering_servo_angle,
                                   steering_servo_spacing=steering_servo_spacing) {

  bellcrank_assembly(show_bellcrank_drive=show_bellcrank_drive,
                     show_bellcrank_drive_idler_lever=show_bellcrank_drive_idler_lever,
                     show_bellcrank_drive_servo_lever=show_bellcrank_drive_servo_lever,
                     show_bellcrank_drive_upper_cap=show_bellcrank_drive_upper_cap,
                     show_bellcrank_idler=show_bellcrank_idler,
                     show_bellcrank_post=show_bellcrank_post,
                     show_bellcrank_idler_lever=show_bellcrank_idler_lever,
                     show_idler_upper_bearing=show_idler_upper_bearing,
                     show_idler_lower_bearing=show_idler_lower_bearing,
                     show_center_link=show_center_link,
                     bellcrank_z_angle=steering_servo_angle);

  // Only the servo belongs to the rear frame; bellcrank posts stay in front.
  translate([0, -steering_servo_spacing, 0]) {
    bellcrank_steering_with_servo_position() {
      steering_servo_bracket_assembly(show_servo=show_steering_servo,
                                      show_servo_brackets=show_steering_servo_brackets,
                                      show_servo_bolt=show_steering_servo_bracket_bolt,
                                      show_servo_bolt_nut=show_steering_servo_bracket_bolt_nut,
                                      show_chassis_bolt=show_steering_servo_chassis_bolt,
                                      show_chassis_bolt_nut=show_steering_servo_chassis_bolt_nut,
                                      show_encoder=show_steering_servo_encoder,
                                      show_encoder_bracket=show_steering_servo_encoder_bracket,
                                      show_magnet=show_steering_servo_magnet,
                                      steering_servo_angle=steering_servo_angle,
                                      center_y=false);
    }
  }
}

bellcrank_steering_assembly();
