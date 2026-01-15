/**
 * Module: Wheel Tire
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 *
 * This module defines shapes used to construct a tire for a wheel.
 * We assume that it will be printed using TPU.
 *
 * For users of Bambulab printers using TPU 95A HF,
 * I recommend changing the following default preset settings:
 *
 * - Maximum volumetric speed: 2 mm³/s (default is 12)
 * - Retraction length: 1 mm (default is 0.8)
 *
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/shapes2d.scad>
use <../lib/transforms.scad>

module tire_arc(outer_r) {
  linear_extrude(height=wheel_tire_groove_thickness, center=true, convexity=2)
    ring_2d(r=outer_r + wheel_tire_fillet_gap,
            w=wheel_tire_groove_thickness,
            fn=360,
            outer=false);
}

module groove_triangle() {
  groove_w = wheel_tire_width + wheel_tire_fillet_gap;
  cut_len = groove_w - wheel_tire_groove_thickness;
  base_points = reverse([[0, 0],
                         [groove_w, 0],
                         [groove_w, groove_w]]);

  cut_points = reverse([[0, 0],
                        [cut_len, 0],
                        [cut_len, cut_len]]);

  linear_extrude(height=wheel_tire_groove_depth, center=false)
    difference() {
    translate([-groove_w / 2, 0, 0]) {
      polygon(points = base_points);
    }
    translate([-cut_len / 2 - wheel_tire_groove_thickness / 2,
               wheel_tire_groove_thickness,
               0]) {
      polygon(points = cut_points);
    }
  }
}

module place_groove() {
  inner_r    = wheel_dia / 2;
  outer_r    = inner_r + wheel_tire_thickness + wheel_rim_h;
  half_groove_w = (wheel_tire_width + wheel_tire_fillet_gap) / 2;

  translate([0, -outer_r - wheel_tire_fillet_gap, 0]) {
    rotate([0, 45, 0]) {
      rotate([90, 0, 180]) {
        translate([0, -half_groove_w, 0]) {
          groove_triangle();
        }
      }
    }
  }
}

module add_grooves() {
  for (i = [0 : wheel_tire_num_grooves - 1]) {
    angle = i * 360 / wheel_tire_num_grooves;
    rotate([0, 0, angle])
      place_groove();
  }
}

module tire() {
  inner_r    = wheel_dia / 2;
  outer_r    = inner_r + wheel_tire_thickness + wheel_rim_h;
  half_width = wheel_tire_width / 2;

  if ($children > 0)
    rotate_extrude(convexity = 10, $fn = wheel_tire_fn)
      children();

  difference() {
    rotate_extrude(convexity = 10, $fn = wheel_tire_fn) {
      offset(r = wheel_tire_fillet_gap) {
        polygon(points = [[inner_r, -half_width],
                          [inner_r,  half_width],
                          [outer_r,  half_width],
                          [outer_r, -half_width]]);
      }
    }

    cylinder(h=wheel_w - wheel_rim_w * 2,
             r=wheel_dia / 2 + wheel_tire_offset,
             center=true,
             $fn=360);

    add_grooves();
    tire_arc(outer_r);
    mirror_copy([0, 0, 1]) {
      translate([0, 0, half_width - (half_width / 2)])
        tire_arc(outer_r);
    }
  }
}

color(matte_black, alpha=1) {
  tire();
}
