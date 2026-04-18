include <../colors.scad>
include <../parameters.scad>
include <../steering_params.scad>

use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/dservo.scad>
use <../placeholders/tie_rod_end.scad>
use <../placeholders/tie_rod_shaft.scad>

total_x = (dsservo_size[2] - dsservo_hat_z_offset) - servo_mount_wiring_offset;

module servo_bracket(clearance=steering_servo_clearance, color=white_smoke_1) {
  slot_w = dsservo_size[0] + clearance;

  wall_thickness = (steering_servo_mount_len - slot_w) / 2;
  bolt_spacing_y = (slot_w + steering_servo_mount_bolt_d) + wall_thickness / 2;

  maybe_color(color) {
    difference() {
      cube_3d(size=[total_x, steering_servo_mount_len, steering_servo_mount_h]);
      translate([0, 0, -steering_servo_bracket_plate_thickness]) {
        cube_3d(size=[total_x + 1, slot_w, steering_servo_mount_h]);
      }
      translate([-0.5, 0, -steering_servo_bracket_plate_thickness]) {
        cube_center_y(size=[total_x / 2 + 1,
                            steering_servo_mount_len + 1,
                            steering_servo_mount_h]);
      }

      translate([-total_x / 2 + steering_servo_mount_hat_thickness,
                 0,
                 -steering_servo_bracket_plate_thickness]) {
        cube_center_y(size=[total_x / 2 - steering_servo_mount_hat_thickness,
                            steering_servo_mount_len + 1,
                            steering_servo_mount_h]);
      }

      translate([total_x / 4,
                 0,
                 steering_servo_mount_h - steering_servo_bracket_plate_thickness]) {
        four_corner_counterbores(size=[0, bolt_spacing_y],
                                 d=steering_servo_mount_bolt_d,
                                 bore_d=steering_servo_mount_bolt_bore_d,
                                 h=steering_servo_bracket_plate_thickness,
                                 bore_h=steering_servo_mount_bolt_bore_h,
                                 sink=true,
                                 reverse=true,
                                 center=true);
      }
      translate([-total_x / 2,
                 0,
                 dsservo_size[1] / 2]) {
        rotate([0, 90, 0]) {
          four_corner_counterbores(size=[dsservo_bolt_spacing[1], dsservo_bolt_spacing[0]],
                                   d=dsservo_bolt_dia,
                                   h=steering_servo_mount_hat_thickness,
                                   sink=true,
                                   reverse=true,
                                   center=true);
        }
      }
    }
  }
}

module servo_mount(show_servo=false,
                   clearance=steering_servo_clearance,
                   color=white_smoke_1,
                   slot_mode=false) {
  slot_w = dsservo_size[0] + clearance;

  wall_thickness = (steering_servo_mount_len - slot_w) / 2;
  bolt_spacing_y = (slot_w + steering_servo_mount_bolt_d) + wall_thickness / 2;

  translate([-total_x / 2 - servo_mount_wiring_offset, 0, 0]) {
    if (slot_mode) {
      translate([total_x / 4, 0, 0]) {
        four_corner_counterbores(size=[0, bolt_spacing_y],
                                 d=steering_servo_mount_bolt_d,
                                 bore_d=steering_servo_mount_bolt_bore_d,
                                 h=upper_chassis_t,
                                 bore_h=steering_servo_mount_bolt_bore_h,
                                 sink=true,
                                 reverse=true,
                                 center=true);
      }
    } else {
      translate([0, 0, steering_servo_mount_h]) {
        rotate([180, 0, 0]) {
          servo_bracket(clearance=clearance, color=color);
        }
      }
    }
  }

  translate([0, 0, steering_servo_mount_h]) {
    rotate([180, 0, 0]) {
      if (show_servo && !slot_mode) {
        translate([0, 0, dsservo_size[1] / 2]) {
          rotate([-90, 0, 90]) {
            dsservo(center=true);
          }
        }
      }
    }
  }
}

module servo_mount_printable() {
  translate([total_x / 2, 0, 0]) {
    servo_bracket();
  }
}

// servo_mount_printable();
servo_mount(slot_mode=false, show_servo=true);
