/**
  * Module: Steering encoder stack and fixed chassis envelope checks.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/suspension/front_chassis/computed_params.scad>

use <../scad/lib/plist.scad>
use <../scad/placeholders/dservo.scad>
use <../scad/suspension/steering_servo_bracket/helpers.scad>

module near(a, b) {
  assert(abs(a - b) < 0.000001, str(a, " != ", b));
}

// Preserve the mating width of the printed chassis and the servo datum.
near(front_chassis_rear_frame_w, 151.26);
near(bellcrank_params[0], -9.85);
near(steering_servo_encoder_chassis_reach(), 65.78);
near(dsservo_magnet_sleeve_offset(), 7.5);

pcb = plist_get("size", steering_encoder_plist);
chip = plist_get("chip_size", plist_get("sensor_ic", steering_encoder_plist));
for (magnet_h = [1.5, 2.5, 3], arm_base_h = [5.5, 6, 7], wall = [2, 3]) {
  // Physical stack from the gearbox attachment through the seated horn,
  // recessed sleeve floor, screw-head pocket, and magnet.
  magnet_face = dsservo_output_attachment_height()
                + (arm_base_h - steering_servo_arm_gear_depth)
                + (arm_base_h - steering_servo_arm_center_bolt_bore_h)
                + steering_magnet_sleeve_bottom_thickness
                + steering_servo_arm_gear_bolt_head_h
                + steering_magnet_sleeve_bolt_head_h_clearance
                + magnet_h;
  sensor_face = steering_servo_encoder_bracket_bend_reach(
    magnet_h=magnet_h, arm_base_h=arm_base_h, side_thickness=wall)
                - wall - pcb[2] - chip[2];
  near(sensor_face - magnet_face, steering_encoder_magnet_distance);
}

foot_l = steering_encoder_bottom_pan_bolt_pad
         + steering_encoder_bottom_pan_bolt_d;
// Material margins at the outer foot edge and the chassis countersinks.
near((foot_l - steering_encoder_bottom_pan_bolt_d) / 2, 1.95);
near((foot_l - steering_servo_mount_bolt_bore_d) / 2, 0.5);
near(steering_servo_encoder_chassis_reach(plist=undef), 0);
echo("PASS: steering encoder gap, mounting margins, and 151.26 mm chassis width");
