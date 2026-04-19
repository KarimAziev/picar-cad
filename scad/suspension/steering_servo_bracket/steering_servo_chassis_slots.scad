include <../../steering_params.scad>

use <../../lib/slots.scad>
use <helpers.scad>

module steering_servo_chassis_slots(chassis_thickness=upper_chassis_t) {
  servo_l_bracket_slots_children() {
    servo_l_bracket_chasis_slot_child() {
      counterbore(h=chassis_thickness,
                  d=steering_servo_mount_bolt_d,
                  bore_d=steering_servo_mount_bolt_bore_d,
                  bore_h=steering_servo_mount_bolt_bore_h,
                  sink=false,
                  fn=100,
                  reverse=true);
    }
  }
}

steering_servo_chassis_slots();