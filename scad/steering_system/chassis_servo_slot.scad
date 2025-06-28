/* chassis_servo_slot.scad - A module for creating a slot for the steering servo in the chassis.
 *
 * The dimensions of the slot are defined by two variables,
 * `steering_servo_slot_width` and `steering_servo_slot_height` (see "../parameters.scad").
 *
 * By default, these values match the Servo EMAX ES08MA II (23 x 11.5 x 24 mm).
 *
 * To use, for example, the popular SG90 servo (23 mm x 12.2 mm x 29 mm), you
 * should adjust the value of the `steering_servo_slot_height` variable to
 * approximately 12.8-13.0 mm to account for tolerance.
 *
 */

include <../parameters.scad>
use <../util.scad>

// This module creates a slot (cutout) for the steering servo.
module steering_servo_cutout_2d(size=[steering_servo_slot_width, steering_servo_slot_height],
                                screws_dia=steering_servo_screw_dia,
                                screws_offset=steering_servo_screws_offset) {
  translate([(size[0] * 0.25) + 1, wheels_offset_y + 2, 0]) {
    square([size[0], size[1]], center=true);
    offst_x = (size[0] / 2 + screws_dia * 0.5) + screws_offset;

    for (x = [-offst_x, offst_x]) {
      translate([x, 0, 0]) {
        circle(r=screws_dia * 0.5, $fn=360);
      }
    }
  }
}

steering_servo_cutout_2d();