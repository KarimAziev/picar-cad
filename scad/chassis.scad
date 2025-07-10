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

module raspberry_pi5_screws_2d(vertical=false) {
  size = vertical
    ? [raspberry_pi5_screws_size[1],
       raspberry_pi5_screws_size[0]]
    : raspberry_pi5_screws_size;
  four_corner_holes_2d(size=size,
                       center=true,
                       hole_dia=m25_hole_dia);
}

module ups_hat_screws_2d() {
  four_corner_holes_2d(size=ups_hat_screws_size,
                       center=true,
                       hole_dia=m3_hole_dia);
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

module chassis_extra_cutouts_2d() {
  translate([0, 50/600 * chassis_len, 0]) {
    y = 10/235 * chassis_len;
    square([30/100 * chassis_width, y], center=true);
    translate([0, y, 0]) {
      square([30/100 * chassis_width, 7/235 * chassis_len], center=true);
    }
  }

  translate([0, -10/235 * chassis_len, 0]) {
    for (y_offset = [-10/235 * chassis_len, 0, -20/235 * chassis_len]) {
      translate([0, y_offset, 0]) {
        dotted_screws_line_y([-(chassis_width * 0.5 - extra_cutouts_dia),
                              chassis_width * 0.5 - extra_cutouts_dia],
                             y = 0,
                             d = extra_cutouts_dia);
      }
    }
  }
}

module chassis_base_2d() {
  init_pos_x = 0;
  init_pos_y = 0 - chassis_len / 2;
  base_width = chassis_width / 2;
  target = ceil(0.34 * abs(init_pos_y));
  rear_panel_base_w = rear_panel_size[0] / 2;

  points = [[init_pos_x, init_pos_y],
            [-rear_panel_base_w, init_pos_y],
            [((-base_width - rear_panel_base_w) / 2) + 6, init_pos_y + 5],
            [(-base_width - rear_panel_base_w) / 2, init_pos_y + 5],
            [-base_width + 6, init_pos_y + 0.5],
            [-base_width, init_pos_y + 2],
            [-base_width, init_pos_y + ceil(0.34 * abs(init_pos_y))],
            [-base_width + 2, init_pos_y + chassis_len / 2 + 5],
            [-base_width * 0.65, init_pos_y + chassis_len / 1.4],
            [-base_width * 0.25, chassis_len / 2],
            [0, chassis_len / 2]];

  offset(r = chassis_offset_rad) {
    polygon(points = points);
  }

  mirror([1, 0, 0]) {
    offset(r = chassis_offset_rad) {
      polygon(points = points);
    }
  }
}

module chassis_2d() {
  chassis_len_half = (chassis_len / 2);
  difference() {
    chassis_base_2d();
    chassis_extra_cutouts_2d();
    battery_holders_screws_2d();

    pan_servo_cutout_2d();

    translate([0, raspberry_pi_offset, 0]) {
      raspberry_pi5_screws_2d();
      raspberry_pi5_screws_2d(vertical=true);
    }
    translate([0, -chassis_len_half + round(chassis_len_half * 0.36)]) {
      ups_hat_screws_2d();
    }
  }
}

module chassis_base_3d() {
  linear_extrude(chassis_thickness, center=false) {
    chassis_2d();
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
  union() {
    chassis_base_3d();

    rear_motor_mount_wall();
    mirror([1, 0, 0]) {
      rear_motor_mount_wall();
    }

    translate([0, chassis_len * 0.5 + chassis_offset_rad, front_panel_height * 0.5]) {
      front_panel();
    }

    translate([0, -(chassis_len / 2) + 1, 25 / 2]) {
      rotate([90, 0, 0]) {
        rear_panel();
      }
    }
  }
}

color("white") {
  chassis_plate();
}
