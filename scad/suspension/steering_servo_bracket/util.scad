/**
  * Module: Utility functions
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../steering_params.scad>

use <../../lib/functions.scad>
use <../../placeholders/bolt.scad>
use <../../placeholders/dservo.scad>

function steering_servo_bracket_params(lower_thickness_clearance=steering_servo_bracket_lower_thickness_clearance) =
  let (bolt_spec = find_bolt_nut_spec(steering_servo_bracket_servo_bolt_d,
                                      default=[]),
       lock_nut_spec = plist_get("lock_nut", bolt_spec, []),
       servo_nut_d = plist_get("outer_dia", lock_nut_spec, 0),
       servo_w = dsservo_size[0],
       servo_h = dsservo_size[2],
       bracket_w = (dsservo_flange_w - servo_w) / 2,
       bracket_extra_h = (dsservo_size[1] - dsservo_flange_h) / 2,
       max_bracket_l = dsservo_height_max_bracket_l() - dsservo_socket_size[2],
       servo_bracket_y = -dsservo_flange_h / 2 - bracket_extra_h,
       lower_thickness = bracket_extra_h +
       ((dsservo_flange_h - (dsservo_bolt_spacing[1]
                             + max(servo_nut_d,
                                   steering_servo_bracket_servo_bolt_d))) / 2)
       - lower_thickness_clearance,
       chassis_mount_pan_l = min(max_bracket_l,
                                 (servo_h / 2) + steering_servo_mount_bolt_d / 2
                                 + steering_servo_bracket_lower_wall_bolt_edge_pad),
       chassis_bolt_y=chassis_mount_pan_l - steering_servo_mount_bolt_d / 2
       - steering_servo_bracket_lower_wall_bolt_edge_pad)
       [bracket_w, chassis_mount_pan_l, servo_bracket_y, bracket_extra_h, lower_thickness, chassis_bolt_y];
