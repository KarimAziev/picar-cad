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
use <../../lib/threading/threads.scad>
use <bellcrank_ring.scad>

bellcrank_lever_add_through_hole = true;
bellcrank_lever_through_hole_d   = 2;

module bellcrank_lever(color=cobalt_blue_metallic,
                       alpha=1,
                       parent_od=bellcrank_idler_od,
                       od=bellcrank_arm_od,
                       l=bellcrank_arm_l,
                       w=bellcrank_arm_w,
                       h,
                       thickness=bellcrank_arm_thickness,
                       bolt_d=bellcrank_arm_bolt_d,
                       bolt_spacing=bellcrank_arm_bolt_spacing,
                       bolt_offset=bellcrank_arm_bolt_edge_offset,
                       upper_boss_h=bellcrank_arm_upper_boss_h,
                       upper_boss_d=bellcrank_arm_upper_boss_d,
                       lower_boss_h=bellcrank_arm_lower_boss_h,
                       lower_boss_d=bellcrank_arm_lower_boss_d,
                       border_w=bellcrank_lever_border_w,
                       use_hull=bellcrank_idler_use_hull,
                       add_through_hole=bellcrank_lever_add_through_hole,
                       through_hole_d=bellcrank_lever_through_hole_d) {
  upper_boss_wall_t = bolt_offset > 0 ? 0 : ((upper_boss_d - bolt_d) / 2);
  lever_l = l - od / 2;

  bolt_holes_x = -lever_l + bolt_d / 2 + bolt_offset;

  h = is_undef(h) ? thickness + upper_boss_h : h;

  fn=$preview ? 20 : 360;

  module _base_shape() {

    translate([-lever_l - upper_boss_wall_t, -w / 2, 0]) {
      rounded_rect([lever_l + upper_boss_wall_t, w],
                   center=false,
                   r_factor=0.5,
                   fn=fn);
    }
  }

  module _shape() {
    union() {
      if (use_hull) {
        hull() {
          _base_shape();
          circle(d=parent_od + border_w * 2, $fn=$preview ? 40 : 360);
        }
      } else {
        union() {
          _base_shape();
          circle(d=parent_od + border_w * 2, $fn=$preview ? 40 : 360);
        }
      }
    }
  }

  color(color, alpha=alpha) {
    union() {
      render() {
        union() {
          difference() {
            linear_extrude(height=h, center=false) {
              difference() {
                _shape();
                translate([bolt_holes_x, 0, 0]) {
                  circle(d=bolt_d, $fn=fn);
                  translate([bolt_spacing, 0, 0]) {
                    circle(d=bolt_d, $fn=fn);
                  }
                }
              }
            }
            translate([0, 0, -0.1]) {
              screw_hole_thread(d=parent_od, h=h + 0.2);
            }
            if (add_through_hole) {
              translate([0, -parent_od / 4, h / 2]) {
                rotate([90, 0, 0]) {
                  cylinder(d=through_hole_d, h=parent_od / 2, $fn=fn);
                }
              }
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

module bellcrank_lever_printable() {
  rotate([180, 0, 0]) {
    bellcrank_lever();
  }
}

bellcrank_lever_printable();
