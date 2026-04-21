/**
  * Module: Slots for mounting the steering servo brackets to the chassis
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../steering_params.scad>

use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <helpers.scad>

module steering_servo_chassis_slots(chassis_thickness=upper_chassis_t,
                                    bolt_d=steering_servo_mount_bolt_d,
                                    bolt_bore_d=steering_servo_mount_bolt_bore_d,
                                    bolt_bore_h=steering_servo_mount_bolt_bore_h,
                                    sink=steering_servo_chassis_bore_type,
                                    center_y=false) {
  maybe_translate([0, center_y ? 0 : -dsservo_flange_w / 2, 0]) {
    servo_l_bracket_slots_children() {
      servo_l_bracket_chassis_slot_child(skip_rotation=false) {
        counterbore(h=chassis_thickness,
                    d=bolt_d,
                    bore_d=bolt_bore_d,
                    bore_h=bolt_bore_h,
                    sink=sink == "countersunk",
                    reverse=true);
      }
    }
  }
}

steering_servo_chassis_slots();