/**
  * Module: Bellcrank lever.
  *
  * Part of both the drive and idler arms.
  *
  * It has two bolt holes:
  * - For the Ackermann plate. This hole has both upper and lower bosses.
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

module bellcrank_lever(color=cobalt_blue_metallic,
                       alpha=1,
                       od=bellcrank_arm_od,
                       d=bellcrank_idler_support_d,
                       l=bellcrank_arm_l,
                       w=bellcrank_arm_w,
                       thickness=bellcrank_arm_thickness,
                       bolt_d=bellcrank_arm_bolt_d,
                       bolt_spacing=bellcrank_arm_bolt_spacing,
                       bolt_offset=bellcrank_arm_bolt_edge_offset,
                       upper_boss_h=bellcrank_arm_upper_boss_h,
                       upper_boss_d=bellcrank_arm_upper_boss_d,
                       lower_boss_h=bellcrank_arm_lower_boss_h,
                       lower_boss_d=bellcrank_arm_lower_boss_d,
                       blend_upper_bosses=bellcrank_lever_blend_upper_bosses,
                       use_hull=true) {
  upper_boss_wall_t = bolt_offset > 0 ? 0 : ((upper_boss_d - bolt_d) / 2);
  lever_l = l - od / 2;

  bolt_holes_x = -lever_l + bolt_d / 2 + bolt_offset;

  upper_boss_full_h = thickness + upper_boss_h;

  fn=$preview ? 20 : 100;

  module _base_shape() {
    circle(d=od, $fn=$preview ? 20 : 200);
    translate([-lever_l - upper_boss_wall_t, -w / 2, 0]) {
      rounded_rect([lever_l + upper_boss_wall_t, w],
                   center=false,
                   r_factor=0.5,
                   fn=$preview ? 20 : 200);
    }
  }

  module _shape() {
    if (use_hull) {
      hull() {
        _base_shape();
      }
    } else {
      union() {
        _base_shape();
      }
    }
  }

  color(color, alpha=alpha) {

    union() {
      if (blend_upper_bosses) {
        difference() {
          hull() {
            linear_extrude(height=thickness, center=false) {
              _shape();
            }
            translate([bolt_holes_x, 0, thickness]) {
              cylinder(d=upper_boss_d, h=upper_boss_h, $fn=fn);
              translate([bolt_spacing, 0, 0]) {
                cylinder(d=upper_boss_d, h=upper_boss_h, $fn=fn);
              }
            }
          }
          translate([0, 0, -0.5]) {
            translate([bolt_holes_x, 0, 0]) {
              cylinder(d=bolt_d, $fn=fn, h=upper_boss_full_h + 1);
              translate([bolt_spacing, 0, 0]) {
                cylinder(d=bolt_d, $fn=fn, h=upper_boss_full_h + 1);
              }
            }
            cylinder(d=d, h=upper_boss_full_h + 1, $fn=fn);
          }
        }
      } else {
        union() {
          linear_extrude(height=thickness, center=false) {
            difference() {
              _shape();
              circle(d=d, $fn=fn);
              translate([bolt_holes_x, 0, 0]) {
                circle(d=bolt_d, $fn=fn);
                translate([bolt_spacing, 0, 0]) {
                  circle(d=bolt_d, $fn=fn);
                }
              }
            }
          }
          translate([bolt_holes_x, 0, thickness]) {
            ring(outer_d=upper_boss_d, h=upper_boss_h, d=bolt_d, fn=fn);
            translate([bolt_spacing, 0, 0]) {
              ring(outer_d=upper_boss_d, h=upper_boss_h, d=bolt_d, fn=fn);
            }
          }
        }
      }
      translate([bolt_holes_x + bolt_spacing, 0, -lower_boss_h]) {
        ring(outer_d=lower_boss_d, h=lower_boss_h, d=bolt_d, fn=fn);
      }
    }
  }
}

bellcrank_lever();