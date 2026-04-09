/**
  * Module: Bellcrank idler
  *
  * A bellcrank and idler system translates linear motion from the steering
  * servo into angular motion at the wheels.
  *
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/threading/threads.scad>
use <../../placeholders/ball_bearing.scad>
use <bellcrank_lever.scad>
use <bellcrank_post.scad>

show_bellcrank_post      = false;
show_idler_upper_bearing = false;
show_idler_lower_bearing = false;
show_idler_lever         = false;

module bellcrank_idler(color=cobalt_blue_light_1,
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
                       chamfer_angle=bellcrank_idler_chamfer_angle,
                       support_thickness=bellcrank_idler_support_thickness,
                       bush_h=bellcrank_post_h,
                       bush_od=bellcrank_post_od,
                       bush_d=bellcrank_post_bolt_d,
                       bush_hole_depth=bellcrank_post_lower_hole_depth,
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
                       use_hull=bellcrank_idler_use_hull,
                       rubber_seal_covers_outer_recess=true,
                       rubber_seal_both_sides=true,
                       show_idler_lever=show_idler_lever) {

  h = bush_h - shoulder_h + chamfer_h + extra_h;

  upper_bearing_z = bush_h - shoulder_h + extra_h - bearing_w;

  upper_h = h - arm_z;
  lower_h = h - upper_h;

  fn = $preview ? 25 : 360;

  module _bearing() {
    ball_bearing(bore_d=bearing_d,
                 outer_d=bearing_od,
                 shoulder_d=bearing_shoulder_d,
                 outer_recess_d=bearing_outer_recess_d,
                 rubber_seal_color=bearing_rubber_seal_color,
                 rubber_seal_covers_outer_recess=rubber_seal_covers_outer_recess,
                 rubber_seal_both_sides=rubber_seal_both_sides,
                 w=bearing_w);
  }

  translate([0, 0, shoulder_h]) {
    render() {
      difference() {
        color(color) {
          union() {
            cylinder(d=od, h=lower_h, $fn=fn);
            translate([0, 0, arm_z]) {
              screw_thread(od=od, height=upper_h);
            }
          }
        }

        bellcrank_idler_bearing_bush_hole(chamfer_h=chamfer_h,
                                          chamfer_angle=chamfer_angle,
                                          bearing_clearance=bearing_clearance,
                                          od=od,
                                          support_thickness=support_thickness,
                                          bearing_od=bearing_od,
                                          bearing_w=bearing_w,
                                          bush_h=bush_h,
                                          bush_od=bush_od,
                                          bush_clearance=bush_clearance,
                                          shoulder_h=shoulder_h);
      }
    }
    children();

    if (show_idler_lever) {
      rotate([0, 0, z_angle]) {
        translate([0, 0, arm_z]) {
          bellcrank_lever(od=arm_od,
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
                          use_hull=use_hull);
        }
      }
    }

    if (show_lower_bearing) {
      _bearing();
    }
    if (show_upper_bearing) {
      translate([0, 0, upper_bearing_z]) {
        _bearing();
      }
    }
  }
  if (show_insert_bush) {
    bellcrank_post(od=bush_od,
                   bolt_d=bush_d,
                   h=bush_h,
                   shoulder_d=shoulder_d,
                   shoulder_h=shoulder_h,
                   lower_hole_depth=bush_hole_depth);
  }
}

// The hole shape for the bearing and insert bush
module bellcrank_idler_bearing_bush_hole(chamfer_h=bellcrank_idler_chamfer_h,
                                         chamfer_angle=bellcrank_idler_chamfer_angle,
                                         bearing_clearance=bellcrank_bearing_clearance,
                                         extra_h=bellcrank_idler_extra_h,
                                         od=bellcrank_idler_od,
                                         support_thickness=bellcrank_idler_support_thickness,
                                         bearing_od=bellcrank_idler_bearing_od,
                                         bearing_w=bellcrank_idler_bearing_w,
                                         bush_h=bellcrank_post_h,
                                         bush_od=bellcrank_post_od,
                                         bush_clearance=bellcrank_post_hole_clearance,
                                         shoulder_h=bellcrank_post_flang_h) {
  h = bush_h - shoulder_h + chamfer_h + extra_h;

  upper_bearing_z = bush_h - shoulder_h + extra_h - bearing_w;

  bush_od = bush_od + bush_clearance;
  bearing_hole_od = bearing_od + bearing_clearance;

  fn = $preview ? 20 : 360;

  module _bearing_hole(h) {
    cylinder(h=h, d=bearing_hole_od, $fn=fn);
  }

  module _chamfer(h=chamfer_h) {
    cylinder(d1=bearing_hole_od, d2=od, h=h, $fn=fn);
  }

  module _bearing_holes() {
    union() {
      translate([0, 0, upper_bearing_z]) {
        _bearing_hole(h=bearing_w + chamfer_h + 0.1);
        translate([0, 0, -support_thickness]) {
          cylinder(d1=bush_od,
                   d2=bearing_hole_od,
                   h=support_thickness,
                   $fn=fn);
        }
      }

      translate([0, 0, -0.1]) {
        _bearing_hole(h=bearing_w + 0.1);
        translate([0, 0, bearing_w + 0.1]) {
          cylinder(d1=bearing_hole_od,
                   d2=bush_od,
                   h=support_thickness + 0.1,
                   $fn=fn);
        }
      }

      translate([0, 0, -0.1]) {
        cylinder(d=bush_od,
                 h=h + 0.1,
                 $fn=fn);
      }

      if (chamfer_h > 0) {
        let (h = (od - bearing_hole_od) / (2 * tan(chamfer_angle))) {
          translate([0, 0, upper_bearing_z + bearing_w]) {
            _chamfer(h=h + 0.1);
          }
        }
      }
    }
  }

  translate([0, 0, upper_bearing_z]) {
    _bearing_hole(h=bearing_w);
  }

  _bearing_holes();
}

bellcrank_idler();
