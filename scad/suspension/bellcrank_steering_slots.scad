/**
  * Module: Slots for mounting the bellcrank drive, bellcrank idler, and
  * steering servo brackets to the chassis.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../steering_params.scad>

use <../lib/shapes3d.scad>
use <../placeholders/dservo.scad>
use <bellcrank/bellcrank_slots.scad>
use <steering_servo_bracket/steering_servo_chassis_slots.scad>

function bellcrank_steering_servo_position() =
  let (y_dist=steering_servo_bellcrank_y(center=false),
       max_tie_rod_a_h=dservo_tie_rod_a_max_h(),
       tie_rod_center_x=max_tie_rod_a_h / 2,
       servo_h=dsservo_size[2],
       x_steering_tie_rod_center_x=servo_h - tie_rod_center_x,
       bellcrank_steering_arm_x=-bellcrank_servo_lever_l - chassis_bellcrank_spacing / 2
       + bellcrank_servo_lever_holes_edge_offset + bellcrank_arm_bolt_d / 2,
       x_dist=abs(bellcrank_steering_arm_x) - abs(x_steering_tie_rod_center_x),
       y_end=y_dist - dsservo_flange_w)
  [-x_dist, y_dist, y_end];

function bellcrank_steering_bbox() =
  let (params = bellcrank_steering_servo_position(),
       y_dist = params[1])
  y_dist + dsservo_flange_w;

module bellcrank_steering_with_servo_position() {
  params = bellcrank_steering_servo_position();

  x_dist = params[0];
  y_dist = params[1];

  translate([x_dist, y_dist, 0]) {
    children();
  }
}

module bellcrank_steering_slots() {
  bellcrank_slots();
  bellcrank_steering_with_servo_position() {
    steering_servo_chassis_slots(center_y=false);
  }
}

bellcrank_steering_slots();
