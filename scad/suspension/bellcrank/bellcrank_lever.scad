/**
  * Module: Bellcrank lever.
  *
  * Part of both the drive and idler arms.
  *
  * It has two bolt holes:
  * - For the center link plate. This hole has both upper and lower bosses.
  *   The lower boss is for the Ackermann plate bushing.
  * - For the knuckle steering link, with an upper boss only.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/threading/threads.scad>
use <../../lib/trapezoids.scad>
use <bellcrank_ring.scad>

module bellcrank_lever(color=cobalt_blue_metallic,
                       alpha=1,
                       od=bellcrank_idler_od,
                       l=bellcrank_arm_l,
                       w_tip=bellcrank_arm_tip_w,
                       w_base=bellcrank_arm_root_w,
                       h,
                       thickness=bellcrank_arm_thickness,
                       bolt_d=bellcrank_arm_bolt_d,
                       bolt_bore_d=bellcrank_arm_bolt_bore_d,
                       bolt_bore_h=bellcrank_arm_bolt_bore_h,
                       bolt_spacing=bellcrank_arm_bolt_spacing,
                       bolt_offset=bellcrank_arm_bolt_edge_offset,
                       lower_boss_h=bellcrank_arm_lower_boss_h,
                       lower_boss_d=bellcrank_arm_lower_boss_d,
                       border_w=bellcrank_lever_border_w,
                       use_hull=bellcrank_lever_use_hull,
                       add_through_hole=bellcrank_lever_add_through_hole,
                       through_hole_d=bellcrank_lever_through_hole_d) {
  bolt_holes_x = -l + bolt_d / 2 + bolt_offset;

  h = is_undef(h) ? thickness : h;

  fn=$preview ? 20 : 360;

  module _base_shape() {
    if (w_base > w_tip) {
      translate([-l / 2, 0, 0]) {
        rotate([0, 0, 90]) {
          trapezoid_rounded_top(b=w_base,
                                t=w_tip,
                                h=l,
                                center=true,
                                $fn=fn,
                                r_factor=0.5);
        }
      }
    }
    else {
      translate([-l, -w_tip / 2, 0]) {
        rounded_rect([l, w_tip],
                     center=false,
                     r_factor=0.5,
                     fn=fn);
      }
    }
  }

  module _shape() {
    union() {
      if (use_hull) {
        hull() {
          _base_shape();
          circle(d=od + border_w * 2, $fn=fn);
        }
      } else {
        union() {
          _base_shape();
          circle(d=od + border_w * 2, $fn=fn);
        }
      }
    }
  }

  render() {
    difference() {
      color(color, alpha=alpha) {
        linear_extrude(height=h, center=false) {
          _shape();
        }
        translate([bolt_holes_x + bolt_spacing, 0, -lower_boss_h]) {
          cylinder(d=lower_boss_d, h=lower_boss_h, $fn=fn);
        }
      }

      translate([bolt_holes_x, 0, 0]) {
        counterbore(d=bolt_d,
                    h=h,
                    bore_h=bolt_bore_h,
                    bore_d=bolt_bore_d,
                    reverse=true);
        counterbore(d=bolt_d,
                    h=h,
                    bore_h=bolt_bore_h,
                    bore_d=bolt_bore_d,
                    reverse=false);
        translate([bolt_spacing, 0, -lower_boss_h]) {
          counterbore(d=bolt_d,
                      h=h + lower_boss_h,
                      bore_h=bolt_bore_h,
                      bore_d=bolt_bore_d,
                      reverse=true);
          counterbore(d=bolt_d,
                      h=h,
                      bore_h=bolt_bore_h,
                      bore_d=bolt_bore_d,
                      reverse=false);
        }
      }

      translate([0, 0, -0.1]) {
        screw_hole_thread(d=od, h=h + 0.2);
      }
      if (add_through_hole) {
        translate([0, -od / 4, h / 2]) {
          rotate([90, 0, 0]) {
            cylinder(d=through_hole_d, h=od / 2, $fn=fn);
          }
        }
      }
    }
  }
}

module bellcrank_lever_printable() {
  rotate([180, 0, 0]) {
    bellcrank_lever();
  }
}

bellcrank_lever_printable();
