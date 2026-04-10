/**
  * Module: Bellcrank drive
  *
  * Bellcrank steering drive is a mechanism designed to translate the linear
  * motion of a steering servo into the left-right steering movement of the
  * front wheels.

  * Bellcrank drive is characterized by two pivoted levers (cranks) connected by
  * a drag link.
  *nn
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
use <bellcrank_lever.scad>
use <bellcrank_ring.scad>

show_bellcrank_post      = true;
show_idler_upper_bearing = true;
show_idler_lower_bearing = true;
show_idler_lever         = true;
show_servo_lever         = true;
show_upper_cap           = true;

module bellcrank_drive(color=cobalt_blue_light_1,
                       z_angle=0,
                       od=bellcrank_idler_od,
                       extra_h=bellcrank_idler_extra_h,
                       chamfer_h=bellcrank_idler_chamfer_h,
                       bearing_od=bellcrank_idler_bearing_od,
                       bearing_d=bellcrank_idler_bearing_d,
                       bearing_w=bellcrank_idler_bearing_w,
                       bearing_outer_recess_d=bellcrank_idler_bearing_outer_recess_d,
                       bearing_shoulder_d=bellcrank_idler_bearing_shoulder_d,
                       bearing_rubber_seal_color=matte_black,
                       bearing_clearance=bellcrank_bearing_clearance,
                       support_thickness=bellcrank_idler_support_thickness,
                       bush_h=bellcrank_post_h,
                       bush_od=bellcrank_post_od,
                       bush_d=bellcrank_post_bolt_d,
                       bush_clearance=bellcrank_post_hole_clearance,
                       shoulder_d=bellcrank_post_flang_d,
                       shoulder_h=bellcrank_post_flang_h,
                       show_insert_bush=show_bellcrank_post,
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
                       show_upper_cap=show_upper_cap,
                       show_servo_lever=show_servo_lever,
                       chamfer_angle=bellcrank_idler_chamfer_angle,
                       use_hull=bellcrank_idler_use_hull,
                       servo_lever_z_offset=bellcrank_servo_lever_z_offset,
                       show_idler_lever=show_idler_lever) {

  total_h = bush_h - shoulder_h + chamfer_h + extra_h;
  lever_h = thickness + upper_boss_h;
  drive_ring_h = thickness + upper_boss_h;
  cap_h = total_h - servo_lever_z_offset - arm_z - thickness - lever_h;

  rotate([0, 0, z_angle]) {
    bellcrank_idler(color=color,
                    z_angle=0,
                    od=od,
                    extra_h=extra_h,
                    chamfer_h=chamfer_h,
                    bearing_od=bearing_od,
                    bearing_d=bearing_d,
                    bearing_w=bearing_w,
                    bearing_outer_recess_d=bearing_outer_recess_d,
                    bearing_shoulder_d=bearing_shoulder_d,
                    bearing_rubber_seal_color=bearing_rubber_seal_color,
                    bearing_clearance=bearing_clearance,
                    support_thickness=support_thickness,
                    bush_h=bush_h,
                    bush_od=bush_od,
                    bush_d=bush_d,
                    bush_clearance=bush_clearance,
                    shoulder_d=shoulder_d,
                    shoulder_h=shoulder_h,
                    show_bellcrank_post=show_insert_bush,
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
                    lower_boss_d=lower_boss_d,
                    use_hull=use_hull,
                    chamfer_angle=chamfer_angle,
                    show_idler_lever=false) {
      if (show_idler_lever) {
        rotate([0, 0, z_angle]) {
          translate([0, 0, arm_z]) {
            bellcrank_lever(od=arm_od,
                            l=l,
                            w=w,
                            parent_od=od,
                            thickness=thickness,
                            bolt_d=bolt_d,
                            bolt_spacing=bolt_spacing,
                            bolt_offset=bolt_offset,
                            upper_boss_h=upper_boss_h,
                            upper_boss_d=upper_boss_d,
                            lower_boss_h=lower_boss_h,
                            lower_boss_d=lower_boss_d,
                            use_hull=use_hull);
          }
        }
      }
      if (show_servo_lever || show_upper_cap) {
        translate([0, 0, thickness + servo_lever_z_offset + arm_z]) {
          if (show_servo_lever) {
            rotate([0, 0, 90]) {
              bellcrank_servo_lever();
            }
          }

          if (show_upper_cap) {
            translate([0, 0, drive_ring_h]) {
              bellcrank_drive_cap_ring(ring_h=cap_h);
            }
          }
        }
      }
    }
  }
}

module bellcrank_servo_lever(color=cobalt_blue_metallic,
                             alpha=1,
                             parent_od=bellcrank_idler_od,
                             border_w=bellcrank_lever_border_w,
                             ring_h,
                             od=bellcrank_arm_od,
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
      bellcrank_ring(h=ring_h,
                     parent_od=parent_od,
                     thickness=thickness,
                     border_w=border_w);
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
          circle(d=parent_od, $fn=fn);
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

module bellcrank_drive_cap_ring(parent_od=bellcrank_idler_od,
                                border_w=bellcrank_lever_border_w,
                                ring_h) {
  bellcrank_ring(h=ring_h,
                 parent_od=parent_od,
                 border_w=border_w);
}

bellcrank_servo_lever();