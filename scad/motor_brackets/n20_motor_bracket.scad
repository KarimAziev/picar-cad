/**
 * Module: A bracket for the N20-Motor
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <../wheels/rear_wheel.scad>
use <../placeholders/n20_motor.scad>

function n20_motor_width() = n20_can_dia + n20_motor_bracket_thickness * 2;

function n20_motor_screws_panel_thickness() =
  n20_reductor_dia -
  (n20_can_dia -  cutout_depth(r=n20_can_dia / 2, cutout_w=n20_can_cutout_w));

function n20_motor_screws_panel_x_offset() =
  notched_circle_square_center_x(r=n20_can_dia / 2,
                                 cutout_w=n20_can_cutout_w)
  - n20_can_cutout_w / 2 + (n20_motor_bracket_thickness / 2);

module n20_motor_screw_holes() {
  screws_rad = n20_motor_screws_dia / 2;
  w = n20_motor_screws_panel_len;
  for (i = [0:1]) {
    offst = w / 2 - n20_motor_screws_dia / 2;
    translate([i == 0
               ? (w / 2) - screws_rad - n20_motor_screws_panel_offset
               : (-w / 2) + screws_rad + n20_motor_screws_panel_offset,
               0,
               0]) {
      circle(r=screws_rad, $fn=360);
    }
  }
}

module n20_motor_screws_panel() {
  center_x = notched_circle_square_center_x(r=n20_can_dia / 2,
                                            cutout_w=n20_can_cutout_w);
  cutout_depth = cutout_depth(r=n20_can_dia / 2, cutout_w=n20_can_cutout_w);
  h = n20_can_height / 2;
  w = n20_motor_screws_panel_len;

  effective_h = n20_motor_screws_panel_thickness();

  screws_rad = n20_motor_screws_dia / 2;
  x_offst = n20_motor_screws_panel_x_offset();

  translate([x_offst,
             0,
             h]) {
    rotate([90, 0, 90]) {
      linear_extrude(height=effective_h, center=false) {
        difference() {
          union() {
            rounded_rect(size = [w, h],
                         r=min(h, w) * 0.5,
                         center=true,
                         fn=360);
            rounded_rect(size = [w, h * 2],
                         r=min(h, w) * 0.5,
                         center=true, fn=360);
          }
          n20_motor_screw_holes();
        }
      }
    }
  }
}

module n20_motor_bracket() {
  center_x = notched_circle_square_center_x(r=n20_can_dia / 2,
                                            cutout_w=n20_can_cutout_w);
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

      translate([0, 0, -1]) {
        notched_circle(h=n20_can_height + 2,
                       d=n20_can_dia +
                       n20_motor_bracket_tolerance,
                       cutout_w=n20_can_cutout_w,
                       x_cutouts_n=2, $fn=360);
      }
    }
    n20_motor_screws_panel();
  }
}

module n20_motor_assembly(show_motor=true, show_wheel=false) {
  union() {
    color(matte_black) {
      n20_motor_bracket();
    }
    if (show_motor) {
      translate([0, 0, -n20_shaft_height - n20_reductor_height]) {
        n20_motor();
        if (show_wheel) {
          wheel_shaft_outer_h = wheel_shaft_offset;
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
