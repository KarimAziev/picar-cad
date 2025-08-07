/**
 * Module: Basic part of the wheel.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <tire.scad>

function wheel_inner_d(d, rim_h) =  d - rim_h;

module wheel(w=wheel_w,
             d=wheel_dia,
             thickness=wheel_thickness,
             rim_h=wheel_rim_h,
             rim_w=wheel_rim_w,
             rim_bend=wheel_rim_bend) {

  inner_d = wheel_inner_d(d, rim_h);
  union() {
    linear_extrude(height = w + rim_w * 2,
                   center=true,
                   convexity=2) {
      ring_2d(r=inner_d / 2,
              w=thickness,
              fn=360);
    }

    z_offset_parts = [w * 0.5, rim_w * 0.5];
    for (i = [0 : 1]) {
      z = i == 0
        ? z_offset_parts[0] + z_offset_parts[1]
        : -z_offset_parts[0] - z_offset_parts[1];
      bend_z = i == 0 ? -rim_bend : rim_bend;
      translate([0, 0, z]) {
        rad = inner_d / 2 + rim_h;
        inner_rad = rad - rim_bend;

        difference() {
          linear_extrude(height = rim_w,
                         center=true,
                         convexity=2) {
            ring_2d(r=rad, w=rim_h, fn=360);
          }

          translate([0, 0, bend_z]) {
            linear_extrude(height=rim_w,
                           center=true,
                           convexity=2) {
              w = rim_h - rim_bend;
              ring_2d(r=inner_rad, w=w);
            }
          }
        }
      }
    }
  }
}

union() {
  color(matte_black) {
    wheel();
  }
  color(jet_black, alpha=0.7) {
    tire();

    translate([65, 0, 3]) {
      tire();
    }
  }
}
