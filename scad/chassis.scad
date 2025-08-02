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
use <placeholders/rpi_5.scad>
use <placeholders/ups_hat.scad>
use <motor_brackets/standard_motor_bracket.scad>
use <motor_brackets/n20_motor_bracket.scad>
use <steering_system/steering_servo_panel.scad>
use <steering_system/ackermann_geometry_triangle.scad>
use <steering_system/rack_and_pinion_assembly.scad>
use <placeholders/motor.scad>
use <steering_system/knuckle_shaft.scad>
use <wheels/rear_wheel.scad>

module raspberry_pi5_screws_2d(vertical=false, show_rpi=false) {
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

module chassis_extra_cutouts_2d() {
  raspberry_pi_extra_holes();
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
  mirror_copy([1, 0, 0]) {
    offset(r = chassis_offset_rad) {
      polygon(points=chassis_shape_points);
    }
  }
}

function raspberry_pi_y_positions() =
  let (chassis_len_half = chassis_len / 2,
       basic_y = (raspberry_pi5_screws_size[1]) / 2 + rpi_5_screws_offset(),
       end = -chassis_len / 2 + raspberry_pi_offset - basic_y,
       start = end + rpi_len)
  [start, end];

module raspberry_pi_extra_holes() {
  positions = raspberry_pi_y_positions();
  half_of_chassis = chassis_len / 2;
  start = positions[0];
  end = positions[1];
  spacing = 4;
  rpi_screws_offst = -rpi_5_screws_offset();
  horizontal_holes_y = [-rpi_screws_offst + spacing,
                        rpi_screws_offst,
                        rpi_screws_offst * 2 - spacing];
  step = spacing + extra_cutouts_dia;
  nums = number_sequence(from=-ups_hat_offset / 2 -
                         raspberry_pi5_screws_size[1] +
                         -chassis_len / 2 + raspberry_pi_offset,
                         to=start
                         - spacing
                         - extra_cutouts_dia
                         - chassis_square_holes_len,
                         step=step);

  for (i = [0 : len(nums) - 1]) {
    y = nums[i];
    translate([0, y - rpi_screws_offst, 0]) {
      curr_y = y + extra_cutouts_dia;
      if (curr_y < extra_battery_screws_y_offset_start
          && curr_y > end) {
        circle(r=extra_cutouts_dia / 2);
      } else {
        circle(r=extra_cutouts_dia / 2);
      }

      if (curr_y < extra_battery_screws_y_offset_start
          && (curr_y < end || y - extra_cutouts_dia > end)) {
        for (i = [0 : 2]) {
          translate([i * step, 0, 0]) {
            circle(r=extra_cutouts_dia / 2, $fn=10);
          }
        }
        for (i = [0 : 2]) {
          translate([-i * step, 0, 0]) {
            circle(r=extra_cutouts_dia / 2, $fn=10);
          }
        }
      };
    }
  }

  x = number_sequence(from=extra_battery_screws_y_offset_end,
                      to=extra_battery_screws_y_offset_end,
                      step=extra_battery_screws_y_offset_step);

  y = 8;
  translate([0, start - chassis_square_holes_len, 0]) {
    trapezoid_rounded(b=chassis_width / 2.2,
                      t=chassis_width / 3.2,
                      h=y,
                      center=true);
    translate([0, chassis_square_holes_len + 3, 0]) {
      trapezoid_rounded(b=chassis_width * 0.35,
                        t=chassis_width * 0.29,
                        h=y * 0.8,
                        center=true);
      translate([0, chassis_square_holes_len + 3, 0]) {
        trapezoid_rounded(b=chassis_width * 0.35,
                          t=chassis_width * 0.29,
                          h=y * 0.8,
                          center=true);
      }
    }
  }
}

module steering_servo_to_head_rect_holes() {
  distance_between_pan_and_steering_start = steering_panel_y_position_from_center
    + steering_servo_panel_center_screws_offsets[1];
  distance_between_pan_and_steering_end = steering_panel_y_position_from_center
    + pan_servo_y_offset_from_steering_panel - cam_pan_servo_slot_width / 2;
  distance = distance_between_pan_and_steering_end
    - distance_between_pan_and_steering_start;
  step = pan_to_steering_square_hole_distance
    + steering_servo_to_pan_hole_wiring_holes_size[1];
  amount = floor(distance / step);
  position = step + distance_between_pan_and_steering_start;
  height = 4;
  side_height = 9;
  width_1 = poly_width_at_y(chassis_shape_points, step + distance_between_pan_and_steering_start) * 2;
  width_2 = poly_width_at_y(chassis_shape_points, step + distance_between_pan_and_steering_start
                            + side_height) * 2;

  if (amount > 0) {
    for (i = [0 : amount - 1]) {
      translate([0, i * step + distance_between_pan_and_steering_start, 0]) {
        if (i > 0) {
          translate([0, 0, 0]) {
            let (length=width_1,
                 h=side_height,
                 sq_w=max(width_2 * 0.4, 20),
                 side_distance=2,
                 t1=width_1 * 0.05,
                 t2=width_2 * 0.05) {

              translate([width_1 / 2 - t1 - side_distance, -side_height / 2, 0]) {
                offset_vertices_2d(r=0.5) {
                  polygon([[- t1, 0],
                           [0 - t1, h],
                           [t2 - 1.5, ++h],
                           [t1, 0]]);
                }
              }
              translate([0, -height / 2, 0]) {
                rounded_rect([sq_w, height], center=true, r=0.2);
                translate([0, height / 2 + 3, 0]) {
                  rounded_rect([sq_w, height], center=true, r=0.2);
                }
              }

              translate([-width_1 / 2 + t1 + side_distance, -side_height / 2, 0]) {
                offset_vertices_2d(r=0.5) {
                  polygon([[- t1, 0],
                           [- t2 + 1.5, h],
                           [t1, h],
                           [t1, 0]]);
                }
              }
            }
          }
        } else {
          trapezoid_rounded(b=steering_servo_to_pan_hole_wiring_holes_size[0],
                            t=steering_servo_to_pan_hole_wiring_holes_size[0]
                            * 0.95,
                            h=steering_servo_to_pan_hole_wiring_holes_size[1],
                            center=true);
        }
      }
    }
  }
}

function ups_hat_y_pos() = -chassis_len / 2
  + ups_hat_screws_size[1] / 2
  + chassis_base_rear_cutout_depth
  + m3_hole_dia / 2 + ups_hat_offset;

module chassis_2d() {
  chassis_len_half = chassis_len / 2;
  rear_panel_bracket_w = rear_panel_screw_panel_width();

  difference() {
    union() {
      chassis_base_2d();
      translate([0, steering_panel_y_position_from_center, 0]) {
        steering_chassis_bar_2d();
      }
    }

    mirror_copy([1, 0, 0]) {
      steering_panel_hinges_screws_holes();
    }

    chassis_extra_cutouts_2d();

    battery_holders_screws_2d();
    steering_servo_to_head_rect_holes();
    translate([0, steering_panel_y_position_from_center, 0]) {
      four_corner_holes_2d(steering_servo_panel_center_screws_offsets,
                           hole_dia=steering_servo_panel_center_screw_dia,
                           center=true);
    }

    mirror_copy([1, 0, 0]) {
      n20_bracket_screws();
      motor_bracket_screws();
    }

    mirror_copy([1, 0, 0]) {
      motor_bracket_screws(-motor_mount_panel_thickness * 2);
    }

    pan_servo_cutout_2d();

    translate([0, -chassis_len_half + raspberry_pi_offset, 0]) {
      raspberry_pi5_screws_2d();
    }

    raspberry_pi5_screws_2d();

    translate([0, ups_hat_y_pos(), 0]) {
      ups_hat_screws_2d();
    }

    translate([0,
               -chassis_len_half
               + rear_panel_bracket_w / 2
               - rear_panel_screw_hole_dia / 2,
               0]) {

      rear_panel_screw_holes();

      translate([0, rear_panel_screw_offset
                 + rear_panel_screw_hole_dia, 0]) {
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

module chassis_assembly(show_rpi=true,
                        motor_type=motor_type,
                        show_motor=false,
                        show_wheels=false,
                        show_rear_panel=false,
                        show_front_panel=false,
                        show_ackermann_triangle=false,
                        show_ups_hat=false,
                        show_steering=false,
                        show_bearing=true,
                        show_brackets=true,
                        chassis_color="white") {
  translate([chassis_width / 2 + (front_wheel_offset() * 2),
             0,
             chassis_thickness +
             n20_motor_screws_panel_x_offset()
             + n20_motor_screws_panel_thickness()
             + wheel_dia  / 2 + tire_thickness + (tire_fillet_gap * 2)]) {

    children();

    if (show_steering) {
      translate([0,
                 steering_panel_y_position_from_center,
                 rack_mount_panel_thickness / 2]) {
        steering_system_assembly(show_wheels=show_wheels,
                                 show_bearing=show_bearing,
                                 show_brackets=show_brackets);
      }
    }

    if (show_rpi) {
      standow_lower_h = chassis_thickness + 1;
      y = (raspberry_pi5_screws_size[1]) / 2 + rpi_5_screws_offset();
      end = -chassis_len / 2 + raspberry_pi_offset - y;

      z = chassis_thickness + rpi_standoff_height - standow_lower_h;
      translate([-rpi_width / 2,
                 end,
                 z]) {
        rpi_5(show_standoffs=true, standoff_height=rpi_standoff_height,
              standoff_lower_height=standow_lower_h);
      }
    }
    if (show_ups_hat) {
      rotate([0, 0, 0]) {
        translate([-ups_hat_size[0] / 2,
                   ups_hat_y_pos() + -ups_hat_size[1] / 2,
                   0]) {
          rotate([0, 0, 0]) {
            translate([0, 0, 0]) {
              ups_hat();
            }
          }
        }
      }
    }

    rotate([0, 180, 0]) {
      chassis_plate(show_motor=show_motor,
                    show_wheels=show_wheels,
                    motor_type=motor_type,
                    show_rear_panel=show_rear_panel,
                    show_front_panel=show_front_panel,
                    show_ackermann_triangle=show_ackermann_triangle,
                    show_rpi=show_rpi);
    }
  }
}

module chassis_plate(motor_type=motor_type,
                     show_motor=false,
                     show_wheels=false,
                     show_rear_panel=false,
                     show_front_panel=false,
                     show_ackermann_triangle=false,
                     show_rpi=false,
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

    if (show_motor && motor_type == "standard") {
      rear_motor_mount_wall(show_motor=show_motor, show_wheel=show_wheels);
      mirror([1, 0, 0]) {
        rear_motor_mount_wall(show_motor=show_motor, show_wheel=show_wheels);
      }
    }

    if (show_motor && motor_type == "n20") {
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
      translate([0, steering_panel_y_position_from_center, -chassis_thickness]) {
        color("yellowgreen", alpha=0.2) {
          ackermann_geometry_triangle();
        }
      }
    }
  }
}

chassis_assembly(motor_type=undef,
                 show_motor=false,
                 show_wheels=false,
                 show_rear_panel=false,
                 show_front_panel=false,
                 show_rpi=false,
                 show_ackermann_triangle=false,
                 show_steering=false,
                 show_ups_hat=false);

// #chassis_base_2d();
