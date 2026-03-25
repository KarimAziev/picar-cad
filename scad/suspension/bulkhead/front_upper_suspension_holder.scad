/**
* Module: Front Upper Suspension Holder
*
* Author: Karim Aziiev <karim.aziiev@gmail.com>
* License: GPL-3.0-or-later
*/

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/holes.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>

module front_upper_suspension_holder(l=front_upper_suspension_holder_l,
                                     w=front_upper_suspension_w,
                                     thickness=front_upper_suspension_holder_thickness,
                                     color=cobalt_blue_metallic,
                                     center_cutout_w=front_upper_suspension_holder_rect_cutout_w,
                                     pin_hole_spacing=front_bulkhead_pin_spacing,
                                     pin_d=front_upper_arm_hinge_barrel_hole_d,
                                     bolt_d=front_upper_suspension_holder_bolt_d,
                                     bolt_spacing=front_upper_suspension_holder_bolt_spacing,
                                     bore_d=front_upper_suspension_holder_bolt_bore_d,
                                     bore_h=front_upper_suspension_holder_bolt_bore_h,
                                     round_cutout_y_offset=front_upper_suspension_holder_round_cutout_offset,
                                     round_cutout_d=front_upper_suspension_holder_round_cutout_d,
                                     pad=front_upper_suspension_holder_bolt_pad,
                                     barrel_d=front_upper_suspension_holder_pin_barrel_d,
                                     barrel_h=front_upper_suspension_holder_pin_barrel_h,
                                     bore_y_offset=front_upper_suspension_holder_bolt_y_offset) {

  translate([0, 0, thickness]) {
    maybe_color(color) {
      translate([0, 0, -thickness]) {
        difference() {
          linear_extrude(height=thickness, center=false, convexity=3) {
            difference() {
              union() {
                hull() {
                  mirror_copy([1, 0, 0]) {
                    translate([pin_hole_spacing / 2, pin_d / 2, 0]) {
                      circle(r=pin_d / 2, $fn=$preview ? 40 : 50);
                    }
                  }

                  translate([0, -w / 2, 0]) {
                    rounded_rect([l, w],
                                 center=true,
                                 fn=30,
                                 r_factor=0.2,
                                 side="bottom");
                  }

                  translate([0, -w - pad / 2, 0]) {
                    trapezoid_rounded_bottom(b=bolt_spacing + bore_d,
                                             t=bolt_spacing + bore_d * 2,
                                             h=pad,
                                             center=true);
                  }
                }
                let (border_w = (barrel_d - pin_d) / 2) {
                  mirror_copy([1, 0, 0]) {
                    translate([pin_hole_spacing / 2 - barrel_d / 2,
                               -border_w,
                               0]) {
                      rounded_rect([barrel_d, barrel_d],
                                   center=false,
                                   fn=$preview ? 100 : 360,
                                   side="top",
                                   r_factor=0.5);
                    }
                  }
                }
              }

              translate([0, pin_d / 2, 0]) {
                rounded_rect([center_cutout_w, pin_d],
                             center=true,
                             side="bottom");
              }

              translate([0,
                         - round_cutout_d / 2
                         - bore_d / 2
                         - round_cutout_y_offset,
                         0]) {
                circle(r=round_cutout_d / 2, $fn=$preview ? 16 : 360);
              }

              translate([0, pin_d / 2, 0]) {
                two_x_bolts_2d(x=pin_hole_spacing / 2,
                               d=pin_d);
              }
            }
          }
          mirror_copy([1, 0, 0]) {
            translate([bolt_spacing / 2, -bore_d / 2 - bore_y_offset, 0]) {
              counterbore(d=bolt_d,
                          bore_d=bore_d,
                          h=thickness,
                          reverse=true,
                          bore_h=bore_h,
                          sink=true);
            }
          }
        }
      }
      mirror_copy([1, 0, 0]) {
        translate([pin_hole_spacing / 2,
                   pin_d / 2,
                   -barrel_h + (barrel_h - thickness)]) {
          ring(outer_d=barrel_d, d=pin_d, h=barrel_h, fn=$preview ? 100 : 360);
        }
      }
    }
  }
}

front_upper_suspension_holder();
