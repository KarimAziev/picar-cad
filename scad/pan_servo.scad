/**
 * Module: A slot for pan servo
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <parameters.scad>
use <util.scad>

module pan_servo_screws_2d(servo_screw_d=1.5,
                           screws_distance=0.5) {
  step = servo_screw_d + screws_distance;
  amount = floor(((chassis_width * 0.25) / 2) / step);
  screw_rad = servo_screw_d / 2;
  slot_rad = pan_servo_slot_dia / 2;

  union() {
    circle(d=pan_servo_slot_dia, $fn=360);
    for (dir = [-1, 1]) {
      group_offst = (dir < 0
                     ? -slot_rad - screw_rad - screws_distance
                     : slot_rad + screw_rad + screws_distance);

      translate([group_offst, 0, 0]) {
        for (i = [0 : amount - 1]) {
          x = i * step * dir;
          translate([x, 0, 0]) {
            circle(r=head_servo_screw_dia / 2, $fn=360);
          }
        }
      }
    }
  }
}

module pan_servo_cutout_2d() {
  translate([0, steering_servo_chassis_y_offset +
             pan_servo_y_offset_from_steering_panel, 0]) {
    pan_servo_screws_2d();
  }
}

pan_servo_cutout_2d();