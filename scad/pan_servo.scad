/**
 * Module: A slot for pan servo
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <parameters.scad>
use <util.scad>

pan_servo_top_ribbon_cuttout_len = 18;
pan_servo_top_ribbon_cuttout_h   = 2;

module pan_servo_screws_2d(servo_screw_d=1.5,
                           screws_distance=0.5) {
  step = servo_screw_d + screws_distance;
  amount = floor(((chassis_width * 0.25) / 2) / step);
  screw_rad = servo_screw_d / 2;
  slot_rad = chassis_pan_servo_slot_dia / 2;

  union() {
    circle(d=chassis_pan_servo_slot_dia, $fn=360);
    for (dir = [-1, 1]) {
      group_offst = (dir < 0
                     ? -slot_rad - screw_rad - screws_distance
                     : slot_rad + screw_rad + screws_distance);

      translate([group_offst, 0, 0]) {
        for (i = [0 : amount - 1]) {
          x = i * step * dir;
          translate([x, 0, 0]) {
            circle(r=head_servo_screw_dia / 2, $fn=360);
          }
        }
      }
    }
  }
}

module pan_servo_slot() {
  y_offst = steering_panel_y_pos_from_center +
    chassis_pan_servo_y_distance_from_steering;
  d = chassis_pan_servo_slot_dia + 2;

  available_len = poly_width_at_y(chassis_shape_points,
                                  y_offst - d / 2) * 2;

  translate([0, y_offst,
             chassis_thickness - chassis_pan_servo_slot_depth + 0.1]) {
    linear_extrude(height=chassis_pan_servo_slot_depth, center=false,
                   convexity=2) {
      rounded_rect([available_len, d], center=true);
      rounded_rect([d, available_len], center=true);
    }
  }
}

module pan_servo_cutout_2d() {
  y_offst = steering_panel_y_pos_from_center +
    chassis_pan_servo_y_distance_from_steering;

  available_h = chassis_len / 2 -
    (y_offst + front_panel_chassis_y_offset + chassis_pan_servo_slot_dia / 2
     + pan_servo_top_ribbon_cuttout_h);

  available_len = poly_width_at_y(chassis_shape_points,
                                  y_offst +
                                  pan_servo_top_ribbon_cuttout_h) * 2;

  translate([0, y_offst, 0]) {
    pan_servo_screws_2d();
  }

  if (available_len > pan_servo_top_ribbon_cuttout_len
      && available_h > 1) {
    translate([0, (chassis_len / 2) - front_panel_chassis_y_offset, 0]) {
      rounded_rect([pan_servo_top_ribbon_cuttout_len,
                    pan_servo_top_ribbon_cuttout_h],
                   center=true);
    }
  }
}

pan_servo_cutout_2d();