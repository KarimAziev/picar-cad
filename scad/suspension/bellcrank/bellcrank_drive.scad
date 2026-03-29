/**
  * Module: Bellcrank drive
  *
  * Bellcrank steering drive is a mechanism designed to translate the linear
  * motion of a steering servo into the left-right steering movement of the
  * front wheels.

  * Bellcrank drive is characterized by two pivoted levers (cranks) connected by
  * a drag link.
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
use <bellcrank_idler.scad>

show_idler_insert_bush   = false;
show_idler_upper_bearing = false;
show_idler_lower_bearing = false;

module bellcrank_drive(color=cobalt_blue_light_1,
                       z_angle=0,
                       od=bellcrank_idler_od,
                       extra_h=0.2,
                       bearing_clearance=0.1,
                       support_d=bellcrank_idler_support_d,
                       bearing_od=bellcrank_idler_bearing_od,
                       bearing_d=bellcrank_idler_bearing_d,
                       bearing_w=bellcrank_idler_bearing_w,
                       bush_h=bellcrank_idler_insert_bush_h,
                       bush_od=bellcrank_idler_insert_bush_od,
                       bush_d=bellcrank_idler_insert_bush_d,
                       shoulder_d=bellcrank_idler_insert_bush_flang_d,
                       shoulder_h=bellcrank_idler_insert_bush_flang_h,
                       show_insert_bush=show_idler_insert_bush,
                       show_lower_bearing=show_idler_lower_bearing,
                       show_upper_bearing=show_idler_upper_bearing,
                       arm_z=bellcrank_arm_z,
                       arm_od=bellcrank_arm_od,
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
                       servo_lever_z_offset=bellcrank_servo_lever_z_offset) {
  rotate([0, 0, z_angle]) {
    bellcrank_idler(color=color,
                    z_angle=0,
                    od=od,
                    extra_h=extra_h,
                    bearing_clearance=bearing_clearance,
                    support_d=support_d,
                    bearing_od=bearing_od,
                    bearing_d=bearing_d,
                    bearing_w=bearing_w,
                    bush_h=bush_h,
                    bush_od=bush_od,
                    bush_d=bush_d,
                    shoulder_d=shoulder_d,
                    shoulder_h=shoulder_h,
                    show_insert_bush=show_insert_bush,
                    show_lower_bearing=show_lower_bearing,
                    show_upper_bearing=show_upper_bearing,
                    arm_z=arm_z,
                    arm_od=arm_od,
                    l=l,
                    w=w,
                    thickness=thickness,
                    bolt_d=bolt_d,
                    bolt_spacing=bolt_spacing,
                    bolt_offset=bolt_offset,
                    upper_boss_h=upper_boss_h,
                    upper_boss_d=upper_boss_d,
                    lower_boss_h=lower_boss_h,
                    lower_boss_d=lower_boss_d);

    translate([0, 0, thickness + servo_lever_z_offset + arm_z]) {
      rotate([0, 0, 90]) {
        bellcrank_servo_lever(d=support_d);
      }
    }
  }
}

module bellcrank_servo_lever(color=cobalt_blue_metallic,
                             alpha=1,
                             od=bellcrank_arm_od,
                             d=bellcrank_idler_support_d,
                             l=bellcrank_arm_l,
                             w=bellcrank_arm_w,
                             thickness=bellcrank_arm_thickness,
                             bolt_d=bellcrank_arm_bolt_d,
                             bolt_offset=bellcrank_servo_lever_holes_edge_offset,
                             boss_h=bellcrank_servo_lever_boss_h,
                             boss_pad=bellcrank_servo_lever_boss_pad_x,
                             holes_gap=bellcrank_servo_lever_holes_gap,
                             holes_n=bellcrank_servo_lever_holes_n) {
  lever_l = l - od / 2;

  bolt_holes_x = -lever_l + bolt_offset;

  fn=$preview ? 20 : 100;
  holes_params = calc_cols_params(cols=holes_n, w=bolt_d, gap=holes_gap);
  total_x = holes_params[1];

  color(color, alpha=alpha) {
    union() {
      linear_extrude(height=thickness, center=false) {
        difference() {
          hull() {
            circle(d=od, $fn=$preview ? 20 : 200);
            translate([-lever_l, -w / 2, 0]) {
              rounded_rect([lever_l, w],
                           center=false,
                           r_factor=0.5,
                           fn=$preview ? 20 : 200);
            }
          }
          circle(d=d, $fn=fn);
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
            translate([bolt_holes_x - bolt_offset, -w / 2, 0]) {
              rounded_rect(size=[total_x + bolt_offset + boss_pad, w],
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

bellcrank_drive();