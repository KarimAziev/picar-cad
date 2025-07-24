/**
 * Module: A dummy mockup of the N20-Motor
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

function n20_motor_screws_panel_len() =
  n20_motor_width()
  + (n20_motor_screws_dia * 2)
  + (n20_motor_screws_panel_len * 2);

function n20_motor_screws_panel_x_offset() =
  notched_circle_square_center_x(r=n20_can_dia / 2,
                                 cutout_w=n20_can_cutout_w)
  - n20_can_cutout_w / 2 + (n20_motor_bracket_thickness / 2);

module n20_motor_screw_holes() {
  screws_rad = n20_motor_screws_dia / 2;
  w = n20_motor_screws_panel_len();
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
  w = n20_motor_screws_panel_len();

  effective_h = n20_motor_screws_panel_thickness();

  screws_rad = n20_motor_screws_dia / 2;
  x_offst = n20_motor_screws_panel_x_offset();

  translate([x_offst,
             0,
             h]) {
    rotate([90, 0, 90]) {
      linear_extrude(height=effective_h, center=false) {
        difference() {
          rounded_rect(size = [w, h], r=min(h, w) * 0.3, center=true);
          n20_motor_screw_holes();
        }
      }
    }
  }
}
// (7.057370639048867 9.848077530122083 18.79385241571817 70 0 350 100)
module n20_motor_bracket() {
  center_x = notched_circle_square_center_x(r=n20_can_dia / 2,
                                            cutout_w=n20_can_cutout_w);

  translate([0, 0, 0]) {
    union() {
      difference() {
        notched_circle(h=n20_can_height,
                       d=n20_motor_width(),
                       cutout_w=n20_can_cutout_w,
                       x_cutouts_n=1, $fn=360);
        translate([0, 0, -1]) {
          notched_circle(h=n20_can_height + 2,
                         d=n20_can_dia + 0.2,
                         cutout_w=n20_can_cutout_w,
                         x_cutouts_n=2, $fn=360);
        }
      }
      n20_motor_screws_panel();

      translate([0,
                 0,
                 n20_can_height + n20_end_cap_h + n20_end_circle_h - 0.5]) {
        rad = 1;
        h = n20_end_cap_h + n20_end_circle_h + n20_motor_bracket_thickness;
        rotate([90, 0, 0]) {
          linear_extrude(height = n20_motor_bracket_thickness, center=false) {
            difference() {
              rounded_rect_two(size = [n20_can_dia, h],
                               r=rad,
                               center=true);
              translate([0, -n20_motor_bracket_thickness, 0]) {
                rounded_rect_two(size = [n20_can_dia -
                                         n20_motor_bracket_thickness * 2,
                                         h],
                                 r=rad,
                                 center=true);
              }
            }
          }
        }
      }
    }
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
          wheel_shaft_outer_h = wheel_w / 2 + wheel_shaft_offset;
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
