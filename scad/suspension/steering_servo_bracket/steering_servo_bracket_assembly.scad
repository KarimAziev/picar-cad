/**
  * Module: Steering servo brackets assembly
  *
  * This module showcases the assembly of two mirrored brackets, one for each
  * side of the servo's mounting flange.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../placeholders/dservo.scad>
use <../bellcrank/bellcrank_drive.scad>
use <helpers.scad>
use <servo_bracket.scad>
use <util.scad>

show_servo_brackets   = true;

show_servo_bolt       = true;
show_servo_bolt_nut   = true;

show_chassis_bolt     = true;
show_chassis_bolt_nut = true;

show_servo            = true;
show_encoder          = true;
show_encoder_bracket  = true;
show_magnet           = true;

steering_servo_angle  = 0; //[-40:1:40]

module steering_servo_bracket_assembly(color=white_smoke_1,
                                       lower_thickness_clearance=steering_servo_bracket_lower_thickness_clearance,
                                       chassis_thickness=front_chassis_thickness,
                                       w_clearance=steering_servo_bracket_w_clearance,
                                       show_servo_brackets=show_servo_brackets,
                                       show_servo_bolt=show_servo_bolt,
                                       show_chassis_bolt=show_chassis_bolt,
                                       show_servo=show_servo,
                                       show_chassis_bolt_nut=show_chassis_bolt_nut,
                                       show_servo_bolt_nut=show_servo_bolt_nut,
                                       show_encoder=show_encoder,
                                       show_encoder_bracket=show_encoder_bracket,
                                       show_magnet=show_magnet,
                                       steering_servo_angle=steering_servo_angle,
                                       center_y=false) {

  bellcrank_z_coords = bellcrank_servo_lever_z_coords();
  bellcrank_lever_z_end = bellcrank_z_coords[1];

  maybe_translate([0, center_y ? 0 : -dsservo_flange_w / 2, 0]) {

    if (show_servo_brackets) {
      servo_l_bracket_slots_children() {
        servo_l_bracket(color=color,
                        lower_thickness_clearance=lower_thickness_clearance,
                        chassis_thickness=chassis_thickness,
                        w_clearance=w_clearance,
                        show_servo_bolt=show_servo_bolt,
                        show_chassis_bolt=show_chassis_bolt,
                        show_chassis_bolt_nut=show_chassis_bolt_nut,
                        show_servo_bolt_nut=show_servo_bolt_nut);
      }
    }

    if (show_servo) {
      translate([0, 0, dsservo_size[1]]) {
        rotate([180, 0, 0]) {
          translate([0, 0, dsservo_size[1] / 2]) {
            rotate([-90, 0, 90]) {
              dsservo(center=true,
                      bellcrank_lever_z_end=bellcrank_lever_z_end,
                      show_encoder=show_encoder,
                      show_encoder_bracket=show_encoder_bracket,
                      show_magnet=show_magnet,
                      servo_horn_angle=steering_servo_angle);
            }
          }
        }
      }
    }
  }
}

steering_servo_bracket_assembly(center_y=false);
