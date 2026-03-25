include <../colors.scad>
include <../parameters.scad>
include <../steering_params.scad>

use <../lib/functions.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../lib/trapezoids.scad>
use <../placeholders/rpi_5.scad>
use <../power/power_case.scad>
use <bulkhead/front_bulkhead_chassis.scad>
use <bulkhead/front_bulkhead_housing.scad>
use <front_suspension_assembly.scad>
use <pitman_arm.scad>
use <servo_mount.scad>

module bellcrank_mount(h=upper_chassis_t,
                       top_w=chassis_center_transition_w,
                       bottom_w=chassis_bellcrank_mount_w,
                       length=chassis_bellcrank_mount_len,
                       bellcrank_y=chassis_bellcrank_position_y,
                       bolt_spacing=bellcrank_link_bolt_spacing,
                       d=upper_chassis_bellcrank_bolt_d,
                       bore_d=upper_chassis_bellcrank_bolt_bore_d,
                       bore_h=upper_chassis_bellcrank_bolt_bore_h,
                       arm_d=bellcrank_arm_dia,
                       pitman_angle=14,
                       idle_angle,
                       show_pitman_arm=true,
                       show_idle_arm=true) {
  idle_angle = with_default(idle_angle, -abs(pitman_angle));
  difference() {
    linear_extrude(height=h, center=false) {
      translate([-bottom_w / 2, -length, 0]) {
        union() {
          trapezoid(b=bottom_w, h=length, t=top_w, center=false);
          rounded_rect([bottom_w, arm_d],
                       r_factor=0.5,
                       center=false,
                       side="top");
        }
      }
    }
    translate([0, -bellcrank_y - bore_d / 2, 0]) {
      four_corner_counterbores(d=d,
                               h=h,
                               bore_d=bore_d,
                               bore_h=bore_h,
                               size=bolt_spacing,
                               reverse=true,
                               center=true);
    }
  }
  if (show_pitman_arm) {
    translate([-bottom_w / 2 + bellcrank_arm_dia /2,
               -bellcrank_y - bore_d / 2,
               h]) {
      maybe_rotate([0, 0, pitman_angle]) {
        rotate([0, 0, -90]) {
          pitman_arm();
        }
      }
    }
  }
  if (show_idle_arm) {
    translate([bottom_w / 2 - bellcrank_arm_dia /2,
               -bellcrank_y - bore_d / 2,
               h]) {
      maybe_rotate([0, 0, idle_angle]) {
        rotate([0, 0, -90]) {

          bellcrank_arm();
        }
      }
    }
  }
}

module upper_chassis(show_pitman_arm=true,
                     show_steering_assembly=true,
                     show_idle_arm=true,
                     show_servo=true) {
  shaft_len = steering_servo_tie_rod_body_len
    + ((steering_servo_tie_rod_shank_len
        + steering_servo_tie_rod_eye_od) * 2);
  extra_len = shaft_len + bellcrank_arm_dia / 2
    + steering_servo_tie_rod_eye_od / 2
    + ((dsservo_hat_w - dsservo_size[0]) / 2);

  servo_mount_x = -bellcrank_arm_len - bellcrank_arm_dia / 2
    + dsservo_size[2]
    - steering_servo_tie_rod_eye_od / 2
    - bellcrank_arm_len / 2;

  servo_mount_y = -chassis_bellcrank_position_y
    - shaft_len
    + bellcrank_arm_dia / 2
    + bellcrank_arm_w / 2
    + steering_servo_tie_rod_eye_od / 2;

  module _servo_hole_probes() {
    translate([0, servo_mount_y, 0]) {
      for (i = [0 : round(((steering_servo_tie_rod_body_len
                            - bellcrank_arm_dia
                            - steering_servo_tie_rod_shank_len)
                           / (steering_servo_mount_bolt_bore_d + 2)))]) {
        let (step = i * (steering_servo_mount_bolt_bore_d + 2)) {
          translate([servo_mount_x,
                     step,
                     0]) {

            servo_mount(slot_mode=true);
          }
        }
      }
    }
  }

  difference() {
    union() {
      front_bulkhead_chassis();
      bellcrank_mount(show_pitman_arm=show_pitman_arm,
                      show_idle_arm=show_idle_arm);
      translate([0, -extra_len / 2 - chassis_bellcrank_mount_len, 0]) {
        linear_extrude(height=upper_chassis_t, center=false) {
          trapezoid(t=chassis_bellcrank_mount_w,
                    b=chassis_bellcrank_mount_w + dsservo_size[1],
                    h=extra_len,
                    center=true);
        }
      }
    }

    for (i = [1 : 2]) {
      let (step = i * (steering_servo_mount_bolt_bore_d + 2)) {
        translate([-step, 0, 0]) {

          _servo_hole_probes();
        }
      }
    }

    _servo_hole_probes();
  }
  translate([0, 0, upper_chassis_t]) {
    if (show_steering_assembly) {
      front_suspension_assembly();
    }
  }
  if (show_servo) {
    translate([servo_mount_x,
               servo_mount_y,
               upper_chassis_t]) {

      servo_mount();
    }
  }
}

module upper_chassis_printable() {
  rotate([0, 180, 0]) {
    upper_chassis(show_pitman_arm=false,
                  show_idle_arm=false,
                  show_servo=false);
  }
}

upper_chassis();
