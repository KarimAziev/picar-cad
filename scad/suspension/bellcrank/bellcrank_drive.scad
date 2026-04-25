/**
  * Module: Threaded bellcrank drive
  *
  * A bellcrank steering drive converts the linear motion of the steering
  * servo into the left-right steering movement of the front wheels.
  *
  * The mechanism consists of two pivoting levers (cranks) connected by
  * a drag link.
  *
  * In its unassembled form, this part is identical to the bellcrank idler.
  * The difference appears in the assembly: the threaded bellcrank idler
  * has only one bellcrank lever screwed on, whereas the bellcrank drive
  * additionally has a bellcrank servo lever screwed on.
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
use <bellcrank_lever.scad>
use <bellcrank_ring.scad>
use <bellcrank_servo_lever.scad>

show_bellcrank_post      = false;
show_idler_upper_bearing = false;
show_idler_lower_bearing = false;
show_idler_lever         = false;
show_servo_lever         = false;
show_upper_cap           = false;

function bellcrank_servo_lever_z_coords(servo_lever_thickness=bellcrank_servo_lever_thickness,
                                        drive_lever_thickness=bellcrank_arm_thickness,
                                        servo_lever_z_offset=bellcrank_servo_lever_z_offset,
                                        arm_z=bellcrank_arm_z,
                                        shoulder_h=bellcrank_post_flang_h,
                                        boss_h=bellcrank_servo_lever_boss_h) =
  let (servo_lever_z_start = drive_lever_thickness + servo_lever_z_offset + arm_z + shoulder_h,
       servo_lever_z_boss_end = servo_lever_thickness + boss_h + servo_lever_z_start)
  [servo_lever_z_start, servo_lever_z_boss_end];

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
                       show_insert_post=show_bellcrank_post,
                       show_lower_bearing=show_idler_lower_bearing,
                       show_upper_bearing=show_idler_upper_bearing,
                       arm_z=bellcrank_arm_z,
                       l=bellcrank_arm_l,
                       w_tip=bellcrank_arm_tip_w,
                       w_base=bellcrank_arm_root_w,
                       servo_lever_thickness=bellcrank_servo_lever_thickness,
                       thickness=bellcrank_arm_thickness,
                       bolt_d=bellcrank_arm_bolt_d,
                       bolt_spacing=bellcrank_arm_bolt_spacing,
                       bolt_offset=bellcrank_arm_bolt_edge_offset,
                       lower_boss_h=bellcrank_arm_lower_boss_h,
                       lower_boss_d=bellcrank_arm_lower_boss_d,
                       show_upper_cap=show_upper_cap,
                       show_servo_lever=show_servo_lever,
                       chamfer_angle=bellcrank_idler_chamfer_angle,
                       use_hull=bellcrank_lever_use_hull,
                       servo_lever_z_offset=bellcrank_servo_lever_z_offset,
                       servo_lever_boss_h=bellcrank_servo_lever_boss_h,
                       show_idler_lever=show_idler_lever) {

  total_h = bush_h - shoulder_h + chamfer_h + extra_h;

  drive_ring_h = thickness;
  cap_h = total_h - servo_lever_z_offset - arm_z - thickness - servo_lever_thickness;

  servo_lever_z_coords = bellcrank_servo_lever_z_coords(drive_lever_thickness=thickness,
                                                        servo_lever_z_offset=servo_lever_z_offset,
                                                        arm_z=arm_z,
                                                        shoulder_h=0,
                                                        boss_h=servo_lever_boss_h);

  servo_lever_z_start = servo_lever_z_coords[0];

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
                    show_bellcrank_post=show_insert_post,
                    show_lower_bearing=show_lower_bearing,
                    show_upper_bearing=show_upper_bearing,
                    arm_z=arm_z,
                    l=l,
                    w_tip=w_tip,
                    thickness=thickness,
                    bolt_d=bolt_d,
                    bolt_spacing=bolt_spacing,
                    bolt_offset=bolt_offset,
                    lower_boss_h=lower_boss_h,
                    lower_boss_d=lower_boss_d,
                    use_hull=use_hull,
                    chamfer_angle=chamfer_angle,
                    show_idler_lever=false) {
      if (show_idler_lever) {
        rotate([0, 0, z_angle]) {
          translate([0, 0, arm_z]) {
            bellcrank_lever(od=od,
                            l=l,
                            w_tip=w_tip,
                            w_base=w_base,
                            thickness=thickness,
                            bolt_d=bolt_d,
                            bolt_spacing=bolt_spacing,
                            bolt_offset=bolt_offset,
                            lower_boss_h=lower_boss_h,
                            lower_boss_d=lower_boss_d,
                            use_hull=use_hull);
          }
        }
      }

      if (show_servo_lever || show_upper_cap) {
        translate([0, 0, servo_lever_z_start]) {
          if (show_servo_lever) {
            rotate([0, 0, 90]) {
              bellcrank_servo_lever(boss_h=servo_lever_boss_h,
                                    thickness=servo_lever_thickness);
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

module bellcrank_drive_cap_ring(parent_od=bellcrank_idler_od,
                                border_w=bellcrank_lever_border_w,
                                ring_h) {
  bellcrank_ring(h=ring_h,
                 parent_od=parent_od,
                 border_w=border_w);
}

z_dims = bellcrank_servo_lever_z_coords();
z_end = z_dims[1];

bellcrank_drive();
