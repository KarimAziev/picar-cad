/**
  * Module: Screw-on bellcrank servo lever
  *
  * This servo lever screws onto the threaded bellcrank drive.
  *
  * It connects to the steering servo arm and converts the linear motion
  * from the steering servo into the left-right steering movement of the
  * front wheels.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/placement.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/threading/threads.scad>
use <../../lib/trapezoids.scad>
use <bellcrank_ring.scad>

module bellcrank_servo_lever(color=cobalt_blue_metallic,
                             alpha=1,
                             od=bellcrank_idler_od,
                             border_w=bellcrank_lever_border_w,
                             l=bellcrank_servo_lever_l,
                             w_tip=bellcrank_arm_tip_w,
                             w_base=bellcrank_arm_root_w,
                             thickness=bellcrank_servo_lever_thickness,
                             bolt_d=bellcrank_arm_bolt_d,
                             bolt_offset=bellcrank_servo_lever_holes_edge_offset,
                             boss_h=bellcrank_servo_lever_boss_h,
                             boss_pad=bellcrank_servo_lever_boss_pad_x,
                             holes_gap=bellcrank_servo_lever_holes_gap,
                             holes_n=bellcrank_servo_lever_holes_n,
                             add_through_hole=bellcrank_lever_add_through_hole,
                             through_hole_d=bellcrank_lever_through_hole_d) {

  bolt_holes_x = -l + bolt_offset;
  final_od = od + border_w * 2;

  fn=$preview ? 20 : 100;
  holes_params = calc_cols_params(cols=holes_n, w=bolt_d, gap=holes_gap);
  total_x = holes_params[1];

  h = thickness + boss_h;

  color(color, alpha=alpha) {
    union() {
      difference() {
        cylinder(d=final_od, h=h, $fn=fn);
        translate([0, 0, -0.1]) {
          screw_hole_thread(d=od, h=h + 0.2);
        }
        if (add_through_hole) {
          translate([final_od / 4, 0, h / 2]) {
            rotate([90, 0, 90]) {
              cylinder(d=through_hole_d, h=final_od / 2, $fn=fn);
            }
          }
        }
      }
      linear_extrude(height=thickness, center=false) {
        difference() {
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

          circle(d=od, $fn=fn);
          translate([bolt_holes_x, 0, 0]) {
            columns_children(cols=holes_n, w=bolt_d, gap=holes_gap) {
              circle(d=bolt_d, $fn=fn);
            }
          }
        }
      }
      translate([0, 0, thickness]) {
        linear_extrude(height=boss_h, center=false) {
          difference() {
            translate([bolt_holes_x - bolt_offset, -w_tip / 2, 0]) {
              rounded_rect(size=[total_x + bolt_offset + boss_pad, w_tip],
                           fn=fn,
                           r_factor=0.5);
            }
            translate([bolt_holes_x, 0, 0]) {
              columns_children(cols=holes_n, w=bolt_d, gap=holes_gap) {
                circle(d=bolt_d, $fn=fn);
              }
            }
          }
        }
      }
    }
  }
}

bellcrank_servo_lever();