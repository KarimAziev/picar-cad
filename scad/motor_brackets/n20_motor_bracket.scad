/**
 * Module: A mounting bracket for the N20 micro gear motor.
 *
 * This module provides a mechanical bracket for securely mounting an N20 motor
 * to a robot or chassis, using two side bolt holes. The bracket surrounds the
 * cylindrical body of the motor and includes a bolt panel that can be mounted
 * to a flat surface (e.g., robot chassis).
 *
 * The bracket includes:
 * - A circular cutout with notches to hold the motor's flattened sides, preventing rotation.
 * - A bolt panel with two mounting holes to affix the bracket securely to a surface.
 * - An integrated support structure to ensure a snug and vibration-resistant fit.
 *
 * The `n20_motor_assembly()` module visualizes how the motor (and optionally a rear wheel)
 * appears within the bracket and in the context of the chassis.
 *
 * @modules:
 * - `n20_motor_bracket()`: Renders the actual bracket geometry.
 * - `n20_motor_bolt_holes()`: Renders the mounting holes on the bolt panel.
 * - `n20_motor_bolts_panel()`: Renders the panel containing mounting holes.
 * - `n20_motor_assembly(show_motor=true, show_wheel=false)`: Full motor-bracket assembly:
 *    including the motor and optionally a rear wheel.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/holes.scad>
use <../lib/l_bracket.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../placeholders/bolt.scad>
use <../placeholders/n20_motor.scad>
use <../wheels/rear_wheel.scad>

function n20_motor_width() = n20_can_dia + n20_motor_bracket_thickness * 2;

function n20_motor_bolts_panel_thickness() =
  n20_reductor_dia -
  (n20_can_dia -  cutout_depth(r=n20_can_dia / 2, cutout_w=n20_can_cutout_w));

function n20_motor_bolts_panel_x_offset() =
  notched_circle_square_center_x(r=n20_can_dia / 2,
                                 cutout_w=n20_can_cutout_w)
  - n20_can_cutout_w / 2 + (n20_motor_bracket_thickness / 2);

module n20_motor_bolt_holes_2d() {
  bolts_rad = n20_motor_bolt_dia / 2;
  n20_motor_with_bolt_holes_positions() {
    circle(r=bolts_rad, $fn=360);
  }
}

module n20_motor_with_bolt_holes_positions() {
  for (i = [0:1]) {
    translate([i == 0
               ? -n20_motor_bolts_panel_offset
               : n20_motor_bolts_panel_offset,
               0,
               0]) {
      children();
    }
  }
}

module n20_motor_bolt_holes_3d(reverse=false,
                               h,
                               sink=false,
                               bore_h) {
  n20_motor_with_bolt_holes_positions() {
    counterbore(h=h,
                d=n20_motor_bolt_dia,
                bore_d=n20_motor_bolt_bore_dia,
                bore_h=(is_undef(bore_h) ? h / 2 : bore_h),
                sink=sink,
                fn=100,
                reverse=reverse);
  }
}

module n20_motor_bolts_panel() {
  cutout_depth = cutout_depth(r=n20_can_dia / 2, cutout_w=n20_can_cutout_w);
  h = n20_can_height / 2;
  w = n20_motor_bolts_panel_len;

  effective_h = n20_motor_bolts_panel_thickness();
  x_offst = n20_motor_bolts_panel_x_offset();

  translate([x_offst, 0, h]) {
    rotate([90, 0, 90]) {
      difference() {
        linear_extrude(height=effective_h, center=false) {
          difference() {
            union() {
              rounded_rect(size = [w, h],
                           r=min(h, w) * 0.5,
                           center=true,
                           fn=360);
              rounded_rect(size = [w, h * 2],
                           r=min(h, w) * 0.5,
                           center=true,
                           fn=360);
            }
          }
        }
        n20_motor_bolt_holes_3d(h=effective_h,
                                sink=false,
                                reverse=true);
      }
    }
  }
}

module n20_motor_bracket() {
  full_dia = n20_motor_width();

  union() {
    difference() {
      union() {
        notched_circle(h=n20_can_height,
                       d=full_dia,
                       cutout_w=n20_can_cutout_w,
                       x_cutouts_n=1,
                       $fn=360);
        linear_extrude(height=n20_can_height, center=false) {
          translate([0, -full_dia / 2, 0]) {
            square([full_dia / 2, full_dia], center=false);
          }
        }
      }

      extra_h = 2;
      translate([0, 0, -extra_h / 2]) {
        notched_circle(h=n20_can_height + extra_h,
                       d=n20_can_dia +
                       n20_motor_bracket_tolerance,
                       cutout_w=n20_can_cutout_w,
                       x_cutouts_n=2,
                       $fn=360);
      }
    }
    n20_motor_bolts_panel();
  }
}

module n20_motor_assembly(show_motor=true,
                          show_wheel=false,
                          show_bolt=true,
                          bolt_head_type="pan",
                          bolt_color=metallic_silver_1,
                          lock_nut=true,
                          show_nut=true,
                          bolt_visible_h=m25_lock_nut_h,
                          bolt_h) {
  union() {
    color(matte_black) {
      n20_motor_bracket();
    }
    if (show_bolt) {

      h = n20_can_height / 2;
      x_offst = n20_motor_bolts_panel_x_offset();

      bolt_height = round(with_default(bolt_h, chassis_thickness - n20_motor_bolt_bore_h
                                       + n20_motor_bolts_panel_thickness() + bolt_visible_h));
      translate([x_offst + bolt_height, 0, h]) {
        rotate([90, 0, 90]) {
          n20_motor_with_bolt_holes_positions() {

            rotate([0, 180, 0]) {
              bolt(h=bolt_height,
                   head_type=bolt_head_type,
                   nut_head_distance=bolt_height,
                   lock_nut=lock_nut,
                   show_nut=show_nut,
                   bolt_color=bolt_color,
                   d=n20_motor_bolt_dia);
            }
          }
        }
      }
    }

    if (show_motor) {
      translate([0, 0, -n20_shaft_height - n20_reductor_height]) {
        n20_motor();
        if (show_wheel) {
          wheel_shaft_outer_h = wheel_rear_shaft_protrusion_height;
          translate([0,
                     0,
                     -(wheel_w / 2) - wheel_shaft_outer_h
                     + n20_shaft_height - 0.5]) {
            rear_wheel_animated();
          }
        }
      }
    }
  }
}

n20_motor_assembly(show_motor=false, show_wheel=false);
