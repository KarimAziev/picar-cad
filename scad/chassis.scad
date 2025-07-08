/**
 * Module: a robot chassis
 *
 * This module defines a robot chassis designed for a four-wheeled vehicle.
 * The front wheels are controlled by servo steering while the rear wheels are powered by two separate motors.
 *
 * Key design features include:++
 *   - A top plate with cutouts for a Raspberry Pi 5 and a UPS Module 3S
 *     (refer to: https://www.waveshare.com/wiki/UPS_Module_3S),
 *   - A bottom plate with openings for standard battery holders (accommodating two 18650 LiPo batteries),
 *   - Back plate provisions with holes for mounting two switch buttons (tumblers).
 *
 * The overall design focuses on providing flexible mounting options for separate power suppliers, such as:
 *   - A power supply for the servo HAT,
 *   - A power supply for the motor driver HAT, and
 *   - A power module for the Raspberry Pi 5 itself.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <parameters.scad>
use <util.scad>
use <front_panel.scad>
use <rear_panel.scad>
use <pan_servo.scad>
use <motor_mount_panel.scad>
use <steering_system/chassis_servo_slot.scad>
use <steering_system/steering_chassis_upper_link.scad>

module raspberry_pi5_screws() {
  four_corner_holes(size = raspberry_pi5_screws_size,
                    center = true,
                    hole_dia = m25_hole_dia);
}

module ups_hat_screws() {
  four_corner_holes(size = ups_hat_screws_size,
                    center = true,
                    hole_dia = m3_hole_dia);
}

// This module generates a lot of the 2D profiles for battery screw holes for both the extra battery holders
// (placed on the sides of the chassis) and the center battery holders
module battery_holders_screws_2d(x_offst=extra_battery_screws_x_offset) {
  union() {
    for (y = number_sequence(from=extra_battery_screws_y_offset_start,
                             to=extra_battery_screws_y_offset_end,
                             step=extra_battery_screws_y_offset_step)) {
      translate([0, y, 0]) {
        four_corner_holes_2d(size = extra_battery_screws_y_size,
                             center = true,
                             hole_dia = extra_battery_screws_dia,
                             fn_val = extra_battery_screws_fn_val);
      }

      translate([-x_offst, y, 0]) {
        four_corner_holes_2d(size = extra_battery_screws_y_size,
                             center = true,
                             hole_dia = extra_battery_screws_dia,
                             fn_val = extra_battery_screws_fn_val);
      }

      translate([x_offst, y, 0]) {
        four_corner_holes_2d(size = extra_battery_screws_y_size,
                             center = true,
                             hole_dia = extra_battery_screws_dia,
                             fn_val = extra_battery_screws_fn_val);
      }
    }

    // for (y = number_sequence(from=battery_screws_center_y_offset_start,
    //                          to=battery_screws_center_y_offset_end,
    //                          step=battery_screws_center_y_step)) {
    //   translate([0, y, 0]) {
    //     four_corner_holes_2d(size = battery_screws_center_size,
    //                          center = true,
    //                          hole_dia = battery_screws_center_dia,
    //                          fn_val = battery_screws_center_fn_val);
    //   }
    // }
  }
}

module battery_holders_screws() {
  z_offst=0.5;
  translate([0, 0, -z_offst]) {
    linear_extrude(height = chassis_thickness + z_offst * 2) {
      battery_holders_screws_2d();
    }
  }
}

module chassis_shape_cutouts() {
  offset1_x = 0.49 * chassis_width;
  offset1_y = 18/235 * chassis_len;
  rot1 = 23;

  sq1_w = 15/100 * chassis_width;
  sq1_h = 55/235 * chassis_len;
  sq2_w = 26/100 * chassis_width;
  sq2_h = 40/235 * chassis_len;
  sq3_w = 15/100 * chassis_width;
  sq3_h = 40/235 * chassis_len;

  tx_for_sq2 = 6/100 * chassis_width;
  ty_for_sq2 = 32/235 * chassis_len;
  ty_for_sq3 = -26/235 * chassis_len;

  offset2_x = 35/100 * chassis_width;
  offset2_y = -125/235 * chassis_len;
  rot2 = 44;
  sq4_w = 30/100 * chassis_width;
  sq4_h = chassis_width * 0.25;

  translate([offset1_x, offset1_y, 0]) {
    rotate([0, 0, rot1]) {
      square([sq1_w, sq1_h], center=true);
      translate([tx_for_sq2, ty_for_sq2, 0]) {
        square([sq2_w, sq2_h], center=true);
      }
      translate([0, ty_for_sq3, 0]) {
        square([sq3_w, sq3_h], center=true);
      }
    }
  }
  translate([offset2_x, offset2_y, 0]) {
    rotate([0, 0, rot2]) {
      square([sq4_w, sq4_h], center=true);
    }
  }
  translate([35, 58, 0]) {
    hull() {
      circle(r = 10);
      translate([8, -30, 0]) {
        circle(r = 5);
      }
    }
  }
}

module chassis_extra_cutouts_2d() {
  translate([0, 50/600 * chassis_len, 0]) {
    y = 10/235 * chassis_len;
    square([30/100 * chassis_width, y], center=true);
    translate([0, y, 0]) {
      square([30/100 * chassis_width, 7/235 * chassis_len], center=true);
    }
  }

  chassis_shape_cutouts();
  mirror([1, 0, 0]) {
    chassis_shape_cutouts();
  }

  translate([0, -10/235 * chassis_len, 0]) {
    for (offset = [-10/235 * chassis_len, 0, -20/235 * chassis_len]) {
      translate([0, offset, 0]) {
        dotted_screws_line_y([-(chassis_width*0.5 - extra_cutouts_dia),
                              chassis_width*0.5 - extra_cutouts_dia],
                             y = 0,
                             d = extra_cutouts_dia);
      }
    }
  }
}

module chassis_front_cutout_2d() {
  translate([-chassis_width * 0.5, (chassis_len * 0.5) - 20]) {
    rotate([20, 45, 0]) {
      square([chassis_width * 0.9, (chassis_len * 0.2)], center=true);
    }
  }

  for (x = [-chassis_width, chassis_width]) {
    translate([x * 0.7, wheels_offset_y, 0]) {
      circle(r = 35);
    }
  }
  // for (x = [chassis_width, -chassis_width]) {
  //   translate([x * 0.5, chassis_len * 0.4, 0]) {
  //     rounded_rect(size=[80, 4], r=2, center=true);
  //   }
  // }
}

module chassis_base_2d() {
  union() {
    difference() {
      rounded_rect(size=[chassis_width, chassis_len], center=true, r=5);
      chassis_extra_cutouts_2d();
      chassis_front_cutout_2d();
      mirror([1, 0, 0]) {
        chassis_front_cutout_2d();
      }
    }
  }
}

module chassis_base_3d() {
  linear_extrude(chassis_thickness, center = false) {
    difference() {
      chassis_base_2d();
      pan_servo_cutout_2d();
    }
  }
}

module rear_motor_mount_wall() {
  translate([(chassis_width * 0.5) - (motor_mount_panel_thickness * 0.5),
             (-chassis_len * 0.5 + motor_mount_panel_width * 0.5) + 20,
             0.5]) {
    motor_mount_panel();
  }
}

module chassis_plate() {
  difference() {
    union() {
      chassis_base_3d();
      rear_motor_mount_wall();
      mirror([1, 0, 0]) {
        rear_motor_mount_wall();
      }

      translate([0, chassis_len * 0.5, front_panel_height * 0.5]) {
        front_panel();
      }

      translate([0, -(chassis_len / 2) + 1, 25 / 2]) {
        rotate([90, 0, 0]) {
          rear_panel();
        }
      }
    }

    translate([0, -(chassis_len / 2) + 42]) {
      rotate([0, 0, 90]) {
        ups_hat_screws();
      }
    }

    translate([0, raspberry_pi_offset, 0]) {
      raspberry_pi5_screws();
      rotate([0, 0, 90]) {
        raspberry_pi5_screws();
      }
    }

    battery_holders_screws();
  }
}

color("white") {
  chassis_plate();
}
