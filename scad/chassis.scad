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
use <placeholders/battery_holder.scad>
use <placeholders/ups_hat.scad>
use <motor_brackets/standard_motor_bracket.scad>
use <motor_brackets/n20_motor_bracket.scad>
use <steering_system/steering_panel.scad>
use <steering_system/ackermann_geometry_triangle.scad>
use <steering_system/rack_and_pinion_assembly.scad>
use <placeholders/motor.scad>
use <steering_system/knuckle_shaft.scad>
use <wheels/rear_wheel.scad>

function raspberry_pi_y_positions() =
  let (chassis_len_half = chassis_len / 2,
       basic_y = (rpi_screws_size[1]) / 2 + rpi_5_screws_offset(),
       end = -chassis_len / 2 + rpi_chassis_y_position - basic_y,
       start = end + rpi_len)
  [start, end];

function motor_bracket_y_pos() =
  (-chassis_len * 0.5 + standard_motor_bracket_width * 0.5)
  + standard_motor_bracket_y_offset;

function motor_bracket_x_pos() =
  (chassis_width * 0.5) - (standard_motor_bracket_height * 0.5);

module raspberry_pi5_screws_2d(vertical=false, show_rpi=false) {
  size = vertical
    ? [rpi_screws_size[1],
       rpi_screws_size[0]]
    : rpi_screws_size;
  four_corner_holes_2d(size=size,
                       center=true,
                       hole_dia=rpi_screw_hole_dia);
}

module ups_hat_screws_2d() {
  four_corner_holes_2d(size=battery_ups_module_screws_size,
                       center=true,
                       hole_dia=m3_hole_dia);
}

module battery_holders_screws_2d(x_offst=battery_screws_x_offset) {
  union() {
    for (y = baterry_holes_y_positions) {
      translate([-x_offst, y, 0]) {
        four_corner_holes_2d(size = battery_holder_screw_holes_size,
                             center = true,
                             hole_dia = battery_holder_screw_hole_dia,
                             fn_val = battery_screws_fn_val);
      }

      translate([x_offst, y, 0]) {
        four_corner_holes_2d(size = battery_holder_screw_holes_size,
                             center = true,
                             hole_dia = battery_holder_screw_hole_dia,
                             fn_val = battery_screws_fn_val);
      }
    }
  }
}

module chassis_center_wiring_cutouts(dia=chassis_center_cutout_dia,
                                     spacing=chassis_center_cutout_spacing,
                                     circle_fn=chassis_center_cutout_fn,
                                     trapezoid_1=chassis_center_trapezoid_1,
                                     trapezoid_2=chassis_center_trapezoid_2,
                                     repeat_offsets=chassis_center_cutout_repeat_offsets,
                                     dotted_line_offsets=chassis_center_dotted_y_offsets) {
  positions = raspberry_pi_y_positions();
  half_of_chassis = chassis_len / 2;
  start = positions[0];
  end = positions[1];

  screw_offset = -rpi_5_screws_offset();
  x_offsets = [-1, 0, 1];

  // Horizontal rows of circles (in line with RPi screw zone)
  vertical_positions = number_sequence(from = -battery_ups_offset / 2
                                       - rpi_screws_size[1]
                                       - half_of_chassis
                                       + rpi_chassis_y_position,
                                       to = start - spacing - dia -
                                       chassis_center_wiring_cutout_y_margin,
                                       step = spacing + dia);

  for (j = [0 : len(vertical_positions) - 1]) {
    y = vertical_positions[j];
    corrected_y = y - screw_offset;
    curr_y = y + dia;

    translate([0, corrected_y, 0]) {
      circle(r = dia / 2);
      // Place 5 total circles only when within safe margin
      if (curr_y < battery_screws_y_start &&
          (curr_y < end || y - dia > end)) {
        for (xi = [0 : 2]) {
          translate([xi * (spacing + dia), 0]) {
            circle(r = dia / 2, $fn = circle_fn);
          }
          translate([-xi * (spacing + dia), 0]) {
            circle(r = dia / 2, $fn = circle_fn);
          }
        }
      }
    }
  }

  // Trapezoidal cutouts (stacked)
  trape_y = trapezoid_1[2];
  translate([0, start - chassis_center_wiring_cutout_y_margin, 0]) {
    trapezoid_rounded(b = chassis_width * trapezoid_1[0],
                      t = chassis_width * trapezoid_1[1],
                      h = trape_y,
                      center = true);

    for (z = [0 : len(repeat_offsets) - 1]) {
      translate([0, (chassis_center_wiring_cutout_y_margin
                     + spacing) + z *
                 repeat_offsets[1], 0]) {
        trapezoid_rounded(b = chassis_width * trapezoid_2[0],
                          t = chassis_width * trapezoid_2[1],
                          h = trapezoid_2[2],
                          center = true);
      }
    }
  }

  // Dotted screw line under chassis (mirrored left/right screw circles)
  translate([0, -0.04 * chassis_len, 0]) {
    for (dy_ratio = dotted_line_offsets)
      translate([0, dy_ratio * chassis_len, 0])
        dotted_screws_line_y([-(chassis_width * 0.5 - dia),
                              chassis_width * 0.5 - dia],
                             y = 0,
                             d = dia);
  }
}

module chassis_head_wiring_pass_through_holes(hole_size                = chassis_head_wiring_hole_size,
                                              hole_spacing             = chassis_head_wiring_hole_spacing,
                                              profile_height           = chassis_head_profile_height,
                                              side_taper_height        = chassis_head_side_taper_height,
                                              cutout_relative_width    = chassis_head_cutout_relative_width,
                                              taper_ratio              = chassis_head_taper_ratio,
                                              side_cutout_margin       = chassis_head_side_cutout_margin,
                                              final_cutout_spacing     = chassis_head_final_spacing,
                                              corner_radius            = chassis_head_corner_radius,
                                              min_center_cutout_width  = chassis_head_min_cutout_w,
                                              trapezoid_corner_offset  = chassis_head_trapezoid_corner_offset,
                                              center_hole_radius       = chassis_head_center_hole_radius) {
  wiring_w = hole_size[0];
  wiring_h = hole_size[1];

  // Compute top and bottom Y ranges for hole placements
  cutout_spacing_y_start = steering_panel_y_pos_from_center
    + steering_panel_center_screws_offsets[1];

  cutout_spacing_y_end = steering_panel_y_pos_from_center
    + chassis_pan_servo_y_distance_from_steering
    - head_neck_pan_servo_slot_width / 2;

  vertical_distance = cutout_spacing_y_end - cutout_spacing_y_start;
  step_y = hole_spacing + wiring_h;
  hole_count = floor(vertical_distance / step_y);

  base_y = cutout_spacing_y_start;
  last_y = base_y + step_y;

  base_width =
    poly_width_at_y(chassis_shape_points, last_y) * 2;
  top_width  =
    poly_width_at_y(chassis_shape_points, last_y + side_taper_height) * 2;

  center_cutout_width = max(top_width *
                            cutout_relative_width,
                            min_center_cutout_width);
  base_taper = base_width * taper_ratio;
  top_taper  = top_width * taper_ratio;

  if (hole_count > 0) {
    for (i = [0 : hole_count - 1]) {
      y_pos = base_y + i * step_y;
      translate([0, y_pos, 0]) {

        is_last_hole = i == hole_count - 1;
        if (is_last_hole) {

          // Left trapezoidal cutout
          translate([base_width/2 - base_taper - side_cutout_margin,
                     -side_taper_height / 2, 0])
            offset_vertices_2d(r=corner_radius)
            polygon([[-base_taper, 0],
                     [0 - base_taper, side_taper_height],
                     [top_taper - trapezoid_corner_offset, side_taper_height],
                     [base_taper, 0]]);

          // Center stacked twin rectangle cutouts
          translate([0, -profile_height / 2, 0]) {
            rounded_rect([center_cutout_width, profile_height],
                         center=true,
                         r=center_hole_radius);
            translate([0, profile_height / 2 + final_cutout_spacing, 0])
              rounded_rect([center_cutout_width, profile_height],
                           center=true,
                           r=center_hole_radius);
          }

          // Right trapezoidal cutout
          translate([-base_width/2 + base_taper +
                     side_cutout_margin,
                     -side_taper_height / 2, 0])
            offset_vertices_2d(r=corner_radius)
            polygon([[-base_taper, 0],
                     [-top_taper + trapezoid_corner_offset,
                      side_taper_height],
                     [base_taper, side_taper_height],
                     [base_taper, 0]]);
        } else {
          // Regular center rectangular cutout
          rounded_rect([center_cutout_width, profile_height],
                       center=true,
                       r=center_hole_radius);
        }
      }
    }
  }
}

function ups_hat_y_pos() = -chassis_len / 2
  + battery_ups_module_screws_size[1] / 2
  + chassis_base_rear_cutout_depth
  + m3_hole_dia / 2 + battery_ups_offset;

module chassis_2d() {
  chassis_len_half = chassis_len / 2;
  rear_panel_bracket_w = rear_panel_screw_panel_width();

  difference() {
    union() {
      chassis_base_2d();
      translate([0, steering_panel_y_pos_from_center, 0]) {
        steering_chassis_bar_2d();
      }
    }

    mirror_copy([1, 0, 0]) {
      steering_panel_hinges_screws_holes();
    }

    chassis_center_wiring_cutouts();
    battery_holders_screws_2d();
    chassis_head_wiring_pass_through_holes();
    translate([0, steering_panel_y_pos_from_center, 0]) {
      four_corner_holes_2d(steering_panel_center_screws_offsets,
                           hole_dia=steering_panel_center_screw_dia,
                           center=true);
    }

    mirror_copy([1, 0, 0]) {
      n20_bracket_screws();
      standard_standard_motor_bracket_screws_size();
    }

    mirror_copy([1, 0, 0]) {
      standard_standard_motor_bracket_screws_size(-standard_motor_bracket_thickness * 2);
    }

    pan_servo_cutout_2d();

    translate([0, -chassis_len_half + rpi_chassis_y_position, 0]) {
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

module standard_standard_motor_bracket_screws_size(extra_x=0, extra_y=0) {
  translate([motor_bracket_x_pos() + extra_x,
             motor_bracket_y_pos() + extra_y,
             0]) {
    for (x = standard_motor_bracket_screws_size) {
      translate([x, 0, 0]) {
        circle(r = m2_hole_dia / 2, $fn = 360);
      }
    }
  }
}

module chassis_base_3d() {
  linear_extrude(chassis_thickness, center=false) {
    chassis_2d();
  }
}

module rear_motor_mount_wall(show_motor=false, show_wheel=false) {
  translate([motor_bracket_x_pos(),
             motor_bracket_y_pos(),
             standard_motor_bracket_thickness]) {
    rotate([0, 0, 90]) {
      standard_motor_bracket(show_motor=show_motor, show_wheel=show_wheel);
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

module chassis_base_2d() {
  mirror_copy([1, 0, 0]) {
    offset(r = chassis_offset_rad) {
      polygon(points=chassis_shape_points);
    }
  }
}

module chassis(motor_type=motor_type,
               show_motor=false,
               show_motor_brackets=false,
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

    if ((show_motor || show_motor_brackets) && motor_type == "standard") {
      mirror_copy([1, 0, 0]) {
        rear_motor_mount_wall(show_motor=show_motor, show_wheel=show_wheels);
      }
    }

    if ((show_motor || show_motor_brackets) && motor_type == "n20") {
      mirror_copy([1, 0, 0]) {
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
      translate([0, steering_panel_y_pos_from_center,
                 -chassis_thickness]) {
        color("yellowgreen", alpha=0.2) {
          ackermann_geometry_triangle();
        }
      }
    }
  }
}

chassis();