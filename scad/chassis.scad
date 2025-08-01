/**
 * Module: a robot chassis
 *
 * This module defines a robot chassis designed for a four-wheeled vehicle.
 * The front wheels are controlled by servo steering while the rear wheels are powered by two separate motors.
 *
 * Key design features include:
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
include <colors.scad>
use <util.scad>
use <front_panel.scad>
use <rear_panel.scad>
use <pan_servo.scad>
use <motor_brackets/standard_motor_bracket.scad>
use <motor_brackets/n20_motor_bracket.scad>
use <steering_system/steering_servo_panel.scad>
use <steering_system/ackermann_geometry_triangle.scad>

module raspberry_pi5_screws_2d(vertical=false) {
  size = vertical
    ? [raspberry_pi5_screws_size[1],
       raspberry_pi5_screws_size[0]]
    : raspberry_pi5_screws_size;
  four_corner_holes_2d(size=size,
                       center=true,
                       hole_dia=raspberry_pi5_screws_hole_size);
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
  }
}

chassis_square_holes_len = 8;
chassis_square_holes_h = 3;
chassis_square_wiring_holes = [[10, 10]];

module chassis_extra_cutouts_2d() {
  wiring_holes = [];
  now = raspberry_pi5_screws_size[1] / 2 - raspberry_pi_offset
    - chassis_square_holes_len;
  translate([0, now, 0]) {
    y = 10;
    trapezoid_rounded(b=chassis_width / 2,
                      t=chassis_width / 2.9,
                      h=y,
                      center=true);
    translate([0, chassis_square_holes_len + 3, 0]) {
      trapezoid_rounded(b=chassis_width * 0.35,
                        t=chassis_width * 0.29,
                        h=y * 0.6,
                        center=true);
      translate([0, chassis_square_holes_len + 3, 0]) {
        trapezoid_rounded(b=chassis_width * 0.4,
                          t=chassis_width * 0.36,
                          h=y * 0.8,
                          center=true);
      }
    }
  }

  translate([0, -ups_hat_offset / 2 -
             raspberry_pi5_screws_size[1] +
             raspberry_pi_offset + extra_cutouts_dia, 0]) {
    for (i = [0:1:4]) {
      translate([0, i * (extra_cutouts_dia * 1.7), 0]) {
        circle(r=extra_cutouts_dia / 2);
      }
    }
  }

  translate([0, -0.04 * chassis_len, 0]) {
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
  target = ceil(0.2 * abs(init_pos_y));
  rear_panel_base_w = rear_panel_size[0] / 2;

  points =
    [[init_pos_x, init_pos_y],
     [-rear_panel_base_w, init_pos_y],
     [((-base_width - rear_panel_base_w) / 2) + 6, init_pos_y + 5],
     [(-base_width - rear_panel_base_w) / 2, init_pos_y + 5],
     [-base_width + 6, init_pos_y],
     [-base_width, init_pos_y + 5],
     [-base_width, init_pos_y + target],
     [-base_width + 2, (init_pos_y + chassis_len / 2) + 0.02 * chassis_len],
     [-base_width * 0.6, init_pos_y + chassis_len / 1.68],
     [-base_width * 0.24, chassis_len / 2],
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

steering_servo_to_pan_hole_wiring_holes_size = [36, 5];
pan_to_steering_square_hole_distance = 3;

module steering_servo_to_head_rect_holes() {
  distance_between_pan_and_steering_start = steering_servo_chassis_y_offset
    + steering_servo_panel_screws_offsets[1];
  distance_between_pan_and_steering_end = steering_servo_chassis_y_offset
    + pan_servo_y_offset_from_steering_panel - cam_pan_servo_slot_width / 2;
  distance = distance_between_pan_and_steering_end
    - distance_between_pan_and_steering_start;
  step = pan_to_steering_square_hole_distance
    + steering_servo_to_pan_hole_wiring_holes_size[1];
  amount = floor(distance / step);

  if (amount > 0) {
    for (i = [0 : amount - 1]) {
      translate([0, i * step + distance_between_pan_and_steering_start, 0]) {
        trapezoid_rounded(b=steering_servo_to_pan_hole_wiring_holes_size[0],
                          t=steering_servo_to_pan_hole_wiring_holes_size[0]
                          * 0.8,
                          h=steering_servo_to_pan_hole_wiring_holes_size[1],
                          center=true);
      }
    }
  }
}

module chassis_2d() {
  chassis_len_half = chassis_len / 2;
  rear_panel_bracket_w = rear_panel_screw_panel_width();

  difference() {
    chassis_base_2d();
    chassis_extra_cutouts_2d();

    battery_holders_screws_2d();
    steering_servo_to_head_rect_holes();
    translate([0, steering_servo_chassis_y_offset, 0]) {
      four_corner_holes_2d(steering_servo_panel_screws_offsets,
                           hole_dia=steering_servo_panel_screws_dia,
                           center=true);
    }

    n20_bracket_screws();
    mirror([1, 0, 0]) {
      n20_bracket_screws();
    }

    motor_bracket_screws();
    mirror([1, 0, 0]) {
      motor_bracket_screws();
    }

    motor_bracket_screws(-motor_mount_panel_thickness * 2);
    mirror([1, 0, 0]) {
      motor_bracket_screws(-motor_mount_panel_thickness * 2);
    }

    pan_servo_cutout_2d();

    translate([0, raspberry_pi_offset, 0]) {
      raspberry_pi5_screws_2d();

      translate([0, -ups_hat_offset - raspberry_pi5_screws_size[1], 0]) {
        ups_hat_screws_2d();
      }
    }

    translate([0,
               -chassis_len_half
               + rear_panel_bracket_w / 2
               - rear_panel_screw_hole_dia / 2,
               0]) {

      rear_panel_screw_holes();

      translate([0, rear_panel_screw_offset + rear_panel_screw_hole_dia, 0]) {
        rear_panel_screw_holes();
      }
    }

    translate([0,
               chassis_len * 0.5 - front_panel_connector_len / 2
               + chassis_offset_rad
               + front_panel_thickness
               + front_panel_chassis_y_offset,
               0]) {

      rotate([0, 0, 180]) {
        front_panel_connector_screws();
      }
    }
  }
}

module motor_bracket_screws(extra_x=0, extra_y=0) {
  translate([motor_bracket_x_pos() + extra_x,
             motor_bracket_y_pos() + extra_y,
             0]) {
    for (x = motor_bracket_screws) {
      translate([x, 0, 0]) {
        circle(r = m2_hole_dia / 2, $fn = 360);
      }
    }
  }
}

function motor_bracket_y_pos() =
  (-chassis_len * 0.5 + motor_mount_panel_width * 0.5) + motor_bracket_offest;

function motor_bracket_x_pos() =
  (chassis_width * 0.5) - (motor_bracket_panel_height * 0.5);

module chassis_base_3d() {
  linear_extrude(chassis_thickness, center=false) {
    chassis_2d();
  }
}

module rear_motor_mount_wall(show_motor=false, show_wheel=false) {
  translate([motor_bracket_x_pos(),
             motor_bracket_y_pos(),
             motor_mount_panel_thickness]) {
    rotate([0, 0, 90]) {
      motor_bracket(show_wheel_and_motor=show_motor || show_wheel);
    }
  }
}

module n20_bracket_left(show_motor=false, show_wheel=false) {
  x = -(chassis_width * 0.5) - n20_motor_chassis_x_distance;
  y = -chassis_len * 0.5 + n20_motor_screws_panel_len / 2
    + n20_motor_chassis_y_distance;
  z = n20_motor_screws_panel_x_offset() +
    chassis_thickness + n20_motor_screws_panel_thickness();
  translate([x,
             y,
             z]) {
    rotate([0, 90, 0]) {
      n20_motor_assembly(show_motor=show_motor, show_wheel=show_wheel);
    }
  }
}

module n20_bracket_screws(show_motor=false, show_wheel=false) {
  pan_len = n20_motor_screws_panel_len;
  x = -chassis_width * 0.5 - n20_motor_chassis_x_distance + n20_can_height / 2;
  y = -chassis_len * 0.5 + pan_len / 2 + n20_motor_chassis_y_distance;
  z = n20_motor_screws_panel_x_offset()
    + n20_motor_screws_panel_thickness()
    + chassis_thickness;

  translate([x, y, z]) {
    rotate([0, 0, 90]) {
      n20_motor_screw_holes();
    }
  }
}

module chassis_plate(motor_type=motor_type,
                     show_motor=false,
                     show_wheels=false,
                     show_rear_panel=false,
                     show_front_panel=false,
                     show_ackermann_triangle=false,
                     chassis_color="white") {
  union() {
    color(chassis_color) {
      chassis_base_3d();
      if (show_rear_panel) {
        translate([0,
                   -chassis_len / 2,
                   rear_panel_size[1] / 2
                   + rear_panel_thickness
                   + chassis_thickness]) {
          rotate([90, 0, 180]) {
            rear_panel();
          }
        }
      }
    }

    if (motor_type == "standard") {
      rear_motor_mount_wall(show_motor=show_motor, show_wheel=show_wheels);
      mirror([1, 0, 0]) {
        rear_motor_mount_wall(show_motor=show_motor, show_wheel=show_wheels);
      }
    }

    if (motor_type == "n20") {
      n20_bracket_left(show_motor=show_motor, show_wheel=show_wheels);
      mirror([1, 0, 0]) {
        n20_bracket_left(show_motor=show_motor, show_wheel=show_wheels);
      }
    }
    if (show_front_panel) {
      color(chassis_color) {
        translate([0,
                   chassis_len * 0.5
                   + chassis_offset_rad
                   + front_panel_thickness
                   + front_panel_chassis_y_offset,
                   front_panel_height * 0.5
                   + chassis_thickness
                   + front_panel_thickness]) {
          front_panel();
        }
      }
    }

    if (show_ackermann_triangle) {
      translate([0, steering_servo_chassis_y_offset, -chassis_thickness]) {
        color("yellowgreen", alpha=0.2) {
          ackermann_geometry_triangle();
        }
      }
    }
  }
}

translate([0, 0, chassis_thickness +
           n20_motor_screws_panel_x_offset()
           + n20_motor_screws_panel_thickness()
           + wheel_dia  / 2 + tire_thickness + (tire_fillet_gap * 2)]) {
  rotate([180, 0, 0]) {
    chassis_plate(motor_type="n20",
                  show_motor=true,
                  show_wheels=true,
                  show_rear_panel=true,
                  show_front_panel=true,
                  show_ackermann_triangle=false);
  }
}