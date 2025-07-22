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

include <../parameters.scad>

module tire() {
  inner_r = wheel_dia / 2;
  outer_r = inner_r + tire_thickness + wheel_rim_h;
  half_of_width = tire_width / 2;
  rotate_extrude(convexity=10, $fn=tire_fn) {
    children();
  }

  difference() {
    rotate_extrude(convexity=10, $fn=tire_fn) {
      offset(r=tire_fillet_gap) {
        polygon(points=[[inner_r, -half_of_width],
                        [inner_r,  half_of_width],
                        [outer_r,  half_of_width],
                        [outer_r, -half_of_width]]);
      }
    }
    cylinder(h=wheel_w - wheel_rim_w * 2,
             r=wheel_dia / 2 + tire_offset,
             center=true,
             $fn=360);
  }
}

tire();