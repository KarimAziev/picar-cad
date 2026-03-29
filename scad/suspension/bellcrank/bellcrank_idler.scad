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

use <../../lib/shapes3d.scad>
use <bellcrank_lever.scad>

show_idler_insert_bush   = false;
show_idler_upper_bearing = false;
show_idler_lower_bearing = false;

module bellcrank_idler(color=cobalt_blue_light_1,
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
                       lower_boss_d=bellcrank_arm_lower_boss_d) {

  h = bush_h - shoulder_h + extra_h;

  upper_bearing_z = bush_h - shoulder_h - bearing_w;

  module _bearing() {
    bellcrank_idler_bearing(w=bearing_w, od=bearing_od, d=bearing_d);
  }

  module _bearing_hole(h) {
    cylinder(h=h, d=bearing_od + bearing_clearance, $fn=$preview ? 16 : 40);
  }

  translate([0, 0, shoulder_h]) {
    difference() {
      ring(h=h, d=support_d, outer_d=od, color=color, fn=$preview ? 20 : 360);
      translate([0, 0, upper_bearing_z]) {
        _bearing_hole(h=bearing_w + extra_h + 0.1);
      }
      translate([0, 0, -0.1]) {
        _bearing_hole(h=bearing_w + 0.1);
      }
    }

    rotate([0, 0, z_angle]) {
      translate([0, 0, arm_z]) {
        bellcrank_lever(od=arm_od,
                        l=l,
                        w=w,
                        d=support_d,
                        thickness=thickness,
                        bolt_d=bolt_d,
                        bolt_spacing=bolt_spacing,
                        bolt_offset=bolt_offset,
                        upper_boss_h=upper_boss_h,
                        upper_boss_d=upper_boss_d,
                        lower_boss_h=lower_boss_h,
                        lower_boss_d=lower_boss_d);
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
    bellcrank_idler_insert_bush(od=bush_od,
                                bolt_d=bush_d,
                                h=bush_h,
                                shoulder_d=shoulder_d,
                                shoulder_h=shoulder_h);
  }
}

// The central cylindrical hub/housing that the bellcrank rotates about
module bellcrank_idler_insert_bush(color=metallic_silver_1,
                                   h=bellcrank_idler_insert_bush_h,
                                   od=bellcrank_idler_insert_bush_od,
                                   shoulder_d=bellcrank_idler_insert_bush_flang_d,
                                   shoulder_h=bellcrank_idler_insert_bush_flang_h,
                                   bolt_d=bellcrank_idler_insert_bush_d) {

  union() {
    ring(color=color, outer_d=od, d=bolt_d, h=h, fn=$preview ? 16 : 30);
    ring(color=color, outer_d=shoulder_d, d=bolt_d, h=shoulder_h, fn=6);
  }
}

module bellcrank_idler_bearing(od=bellcrank_idler_bearing_od,
                               d=bellcrank_idler_bearing_d,
                               w=bellcrank_idler_bearing_w,
                               color=dark_gold_2) {
  ring(color=color, outer_d=od, d=d, h=w, fn=$preview ? 16 : 40);
}

bellcrank_idler();
