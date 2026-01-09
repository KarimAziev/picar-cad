/**
 * Module: Uninterruptible Power Supply Module 3S
 * https://www.waveshare.com/ups-module-3s.html
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>

use <../lib/holes.scad>
use <../lib/shapes2d.scad>
use <../lib/transforms.scad>
use <battery.scad>

function ups_hat_polygon_cutout_points(max_len, max_height) =
  let (end_x = max_len / 2,
       end_y = max_height)
  [[0, 0],
   [0, end_y],
   [0.24 * end_x, end_y],
   [0.34 * end_x, 0.66 * end_y],
   [0.55 * end_x, 0.66 * end_y],
   [0.61 * end_x, 0.46 * end_y],
   [end_x, 0.46 * end_y],
   [end_x, 0]];

module ups_hat(size=battery_ups_size,
               holder_size=battery_ups_holder_size,
               holder_thickness=battery_ups_holder_thickness,
               bolt_dia=battery_ups_bolt_dia,
               standoff_h=5,
               max_cutout_len,
               max_cutout_height,
               center=true) {
  total_len = size[0];
  total_w = size[1];
  plate_h = size[2];
  holder_len = holder_size[0];
  holder_w = holder_size[1];
  holder_h = holder_size[2];
  double_thickness = holder_thickness * 2;
  holder_size = [holder_len - double_thickness, holder_w - double_thickness];
  battery_step = 1 + battery_dia;
  batteries_amount = round(holder_size[1] / battery_step);
  max_cutout_len = is_undef(max_cutout_len)
    ? holder_len - double_thickness - 4
    : max_cutout_len;
  max_cutout_height = is_undef(max_cutout_height)
    ? holder_h
    : max_cutout_height;
  cutout_thickness = holder_thickness + 2;
  points = ups_hat_polygon_cutout_points(max_len=max_cutout_len,
                                         max_height=max_cutout_height);

  lowest_height = min([for (pair = points) if (pair[0] != 0) pair[0]]);

  translate([center ? -total_len / 2 : 0, center ? -total_w / 2 : 0, 0]) {
    translate([0, 0, standoff_h]) {
      union() {
        color(black_1, alpha=1) {
          linear_extrude(height=plate_h, center=false) {
            difference() {
              rounded_rect([total_len, total_w],
                           r=total_len * 0.05,
                           center=false);
              translate([(total_len - battery_ups_module_bolt_spacing[0]) / 2,
                         (total_w - battery_ups_module_bolt_spacing[1]) / 2,
                         0]) {
                four_corner_holes_2d(size=battery_ups_module_bolt_spacing,
                                     center=false,
                                     hole_dia=bolt_dia,
                                     fn=10);
              }
            }
          }
        }
        difference() {
          translate([(total_len - holder_len) / 2,
                     (total_w - holder_w) / 2,
                     plate_h]) {
            color(matte_black, alpha=1) {
              linear_extrude(height=holder_h,
                             center=false,
                             convexity=2) {
                difference() {
                  square([holder_len, holder_w], center=false);
                  translate([(holder_len - holder_size[0]) / 2,
                             (holder_w - holder_size[1]) / 2,
                             0]) {
                    square([holder_size[0], holder_size[1]], center=false);
                  }
                }
              }
            }
          }
          translate([(total_len) / 2,
                     holder_thickness / 2
                     + cutout_thickness / 2,
                     plate_h + holder_h + lowest_height / 2]) {
            ups_hat_wall_cutout(max_len=max_cutout_len,
                                max_height=max_cutout_height,
                                thickness=cutout_thickness,
                                points=points);

            translate([0, holder_w - cutout_thickness / 2, 0]) {
              ups_hat_wall_cutout(max_len=max_cutout_len,
                                  max_height=max_cutout_height,
                                  thickness=cutout_thickness,
                                  points=points);
            }
          }
        }
        translate([(total_len - battery_length) / 2 +
                   holder_thickness,
                   battery_dia,
                   battery_dia / 2]) {
          for (i = [0 : batteries_amount - 1]) {
            translate([0, battery_step * i - battery_dia / 2, 0]) {
              rotate([90, 0, 90]) {
                battery();
              }
            }
          }
        }
      }
    }
    color("gold", alpha=1) {
      translate([(total_len - battery_ups_module_bolt_spacing[0]) / 2,
                 (total_w - battery_ups_module_bolt_spacing[1]) / 2,
                 0]) {
        for (x_ind = [0, 1])
          for (y_ind = [0, 1]) {
            x_pos = x_ind * battery_ups_module_bolt_spacing[0];
            y_pos = y_ind * battery_ups_module_bolt_spacing[1];
            translate([x_pos, y_pos]) {
              linear_extrude(height=standoff_h, center=false) {
                circle(r=bolt_dia / 2);
              }
            }
          }
      }
    }
  }
}

module ups_hat_wall_cutout(max_len=battery_ups_holder_size[0] - 4,
                           max_height=battery_ups_holder_size[2],
                           thickness=battery_ups_holder_thickness + 1,
                           offset_rad=1,
                           points) {

  pts = is_undef(points)
    ? ups_hat_polygon_cutout_points(max_len=max_len, max_height=max_height)
    : points;
  rotate([90, 0, 0]) {
    mirror_copy([1, 0, 0]) {
      linear_extrude(height=thickness,
                     center=false) {
        rotate([0, 0, 180]) {
          fillet(r=offset_rad) {
            polygon(points=pts);
          }
        }
      }
    }
  }
}

ups_hat();