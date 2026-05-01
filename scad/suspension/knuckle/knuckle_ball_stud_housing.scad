/**
  * Module: Upper and lower knuckle arm mount
  *
  * The mounts are cylindrical. Each arm ends with a threaded ball stud,
  * which is inserted into the arm mount.
  *
  * The ball stud is secured either by:
  * 1. a bushing and a threaded plug with an internal hex (hex socket), or
  * 2. a simple horizontal stopper bolt threaded through the housing (past the
  *    bushing) to prevent the ball stud from falling out. To use this option,
  *    set `knuckle_ball_stud_stopper_d` to the desired bolt diameter.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../steering_params.scad>

use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/threading/threaded_plug_hex_socket.scad>
use <../../lib/threading/threads.scad>
use <../../lib/transforms.scad>
use <knuckle_threaded_plug.scad>
use <util.scad>

color              = cobalt_blue_metallic;
show_threaded_plug = false;

module knuckle_ball_stud_housing(od=knuckle_ball_stud_mount_outer_d,
                                 base_h=knuckle_ball_stud_house_h,
                                 sphere_h=knuckle_ball_stud_sphere_h,
                                 hole_d=knuckle_ball_stud_mount_hole_d,
                                 ball_stud_d=front_arm_ball_stud_ball_d,
                                 sphere_hole_size=knuckle_ball_stud_cap_hole_size,
                                 stopper_d=knuckle_ball_stud_stopper_d,
                                 stopper_offset=knuckle_ball_stud_stopper_offset,
                                 show_threaded_plug=show_threaded_plug,
                                 color=cobalt_blue_metallic) {
  fn = $preview ? 30 : 360;

  module _cap() {
    difference() {
      intersection() {
        sphere(d=od, $fn=fn);
        cuboid([od, od, sphere_h]);
      }
      translate([0, 0, -0.5]) {
        linear_extrude(height=sphere_h + 1, center=false) {
          rounded_rect(size=sphere_hole_size,
                       center=true,
                       fn=fn,
                       r_factor=0.5);
        }
      }
    }
  }

  difference() {
    maybe_color(color) {
      union() {
        cylinder(d=od,
                 h=base_h,
                 $fn=fn);
        translate([0, 0, base_h]) {
          _cap();
        }
      }
    }
    translate([0, 0, -1]) {
      screw_hole_thread(d=knuckle_threaded_plug_d,
                        h=base_h + 1,
                        tolerance=knuckle_threaded_plug_tolerance);
    }

    if (is_num(stopper_d) && stopper_d > 0) {
      translate([0, 0, base_h + stopper_d / 2 - ball_stud_d - stopper_offset]) {
        rotate([90, 0, 0]) {
          cylinder(d=stopper_d, h=od + 1, center=true, $fn=fn);
        }
      }
    }

    translate([0, 0, -0.5]) {
      cylinder(d=hole_d,
               h=base_h + 1,
               $fn=fn);
    }
  }

  if (show_threaded_plug) {
    knuckle_threaded_plug();
  }
}

knuckle_ball_stud_housing();
