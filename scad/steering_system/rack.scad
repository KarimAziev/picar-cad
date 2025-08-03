/**
 * This file contains modules to generate a rack for a steering system. The rack
 * is designed with a toothed profile to mesh with a pinion and integrates the
 * appropriate mounting connectors both sides.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <rack_connector.scad>
use <rack_util.scad>
use <bracket.scad>
use <../util.scad>
use <steering_pinion.scad>
use <../gear.scad>

module shifted_tooth(points, height) {
  translate([0, -min(points[0]), 0]) {
    linear_extrude(height = height, center = false) {
      polygon(points);
    }
  }
}

module steering_rack(length=rack_len,
                     width=rack_width,
                     base_height=rack_base_h,
                     r_pitch=steering_pinion_d / 2,
                     teeth_count=steering_pinion_teeth_count,
                     pressure_angle=steering_pinion_pressure_angle,
                     clearance=steering_pinion_clearance,
                     backlash=steering_pinion_backlash,
                     show_brackets=false,
                     bracket_color=blue_grey_carbon,
                     rack_color=blue_grey_carbon) {

  circular_pitch = calc_circular_pitch(r_pitch, teeth_count);

  tooth_height = calc_tooth_height(r_pitch, teeth_count, clearance);
  base_circle_rad = r_pitch * cos(pressure_angle);
  root_rad = r_pitch - (circular_pitch / PI) - clearance;
  outer_rad = outer_radius(r_pitch, circular_pitch, clearance);
  inv_angle = -involute_angle(base_circle_rad, r_pitch)
    - (circular_pitch / 2 - backlash / 2) / (2 * r_pitch) / PI * 180;

  total_teeth = round(length / circular_pitch);
  tooth_points = concat([polar_to_cartesian(root_rad, -180 / total_teeth)],
                        [for (f = [0:5])
                            involute_point_at_fraction(f / 5, root_rad,
                                                       base_circle_rad,
                                                       outer_rad,
                                                       inv_angle, 1)],
                        [for (f = [5:-1:0])
                            involute_point_at_fraction(f / 5, root_rad,
                                                       base_circle_rad,
                                                       outer_rad,
                                                       inv_angle,
                                                       -1)],
                        [polar_to_cartesian(root_rad, 180 / total_teeth)]);
  shifted_points = [for (pt = tooth_points) [pt[0], pt[1] - root_rad]];

  ys = abs(min([for (pt = shifted_points) pt[1]]));
  offst = [-rack_len / 2 - bracket_bearing_outer_d / 2 - 0.4,
           0,
           0];

  difference() {
    union() {
      color(rack_color) {
        linear_extrude(height=base_height, center=false) {
          square([length, width], center=true);
        }

        difference() {
          translate([circular_pitch / 2, width / 2, ys + base_height]) {
            rotate([90, 0, 0]) {
              translate([-length * 0.5, 0, 0]) {
                linear_extrude(height=width, center=false, convexity = 10) {
                  for (i = [0 : total_teeth - 1]) {
                    translate([i * circular_pitch, 0, 0]) {
                      polygon(shifted_points);
                    }
                  }
                }
              }
            }
          }
          mirror_copy([1, 0, 0]) {
            translate([0, 0, base_height / 2]) {
              extra_w = 2;
              linear_extrude(height=base_height, center=false) {
                translate([-rack_len / 2 - bracket_bearing_outer_d,
                           -width / 2 - extra_w / 2,
                           0]) {
                  square([bracket_bearing_outer_d, width + extra_w]);
                }
              }
            }
          }
        }
      }

      mirror_copy([1, 0, 0]) {
        translate(offst) {
          if (show_brackets) {
            rack_connector_assembly(bracket_color=bracket_color, rotation_dir=-1);
          } else {
            color(rack_color) {
              rack_connector();
            }
          }
        }
      }
    }
    mirror_copy([1, 0, 0]) {
      hole_depth = 0.8;
      hole_w = 0.5;
      hole_h = min(base_height * 0.8, 3);
      translate([steering_servo_panel_rail_len / 2,
                 rack_width / 2 - hole_depth / 2,
                 min(1, base_height)]) {
        linear_extrude(height=hole_h, center=false) {
          square([hole_w, hole_depth], center=false);
        }
      }
      translate([steering_servo_panel_rail_len / 2,
                 -rack_width / 2 - hole_depth / 2,
                 min(1, base_height)]) {
        linear_extrude(height=hole_h, center=false) {
          square([hole_w, hole_depth], center=false);
        }
      }
    }
  }
}

module rack_mount(show_brackets=false, rack_color=blue_grey_carbon) {
  translate([rack_offset($t), 0, 0]) {
    steering_rack(show_brackets = show_brackets,
                  rack_color = rack_color);
  }
}

module rack_assembly(show_brackets=true, rack_color=blue_grey_carbon) {
  rack_mount(show_brackets=show_brackets, rack_color=rack_color);
}

rack_mount(show_brackets=false);

// translate([0, 0, steering_pinion_d / 2 +
//            rack_base_h +
//            steering_pinion_tooth_height()]) {
//   rotate([90, 41.7, 0]) {
//     steering_pinion();
//   }
// }