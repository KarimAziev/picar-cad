/**
  * Module: Front shock mounting and surrounding-part clearance probes.
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/rc_params.scad>

use <../../scad/lib/plist.scad>
use <../../scad/suspension/front_linkage.scad>
use <../../scad/suspension/front_shocks.scad>
use <../../scad/suspension/front_suspension_assembly.scad>

part            = "shock_structure_collision";
solved          = false;
arm_angle       = 0;
probe_clearance = 0.1;
probe_overlap   = 0.02;
probe_fn        = 32;
poses = [for (side = [-1, 1]) solved
                              ? front_linkage_pose(lower_angle=arm_angle,
                                                   side=side,
                                                   bellcrank_angle=0,
                                                   hole=0)
                              : undef];

module structure() {
  front_suspension_assembly(show_front_shocks=false,
                            solve_linkage=solved,
                            lower_arm_angle=arm_angle,
                            bellcrank_angle=0,
                            steering_hole=0,
                            show_front_lower_arm_pin=false,
                            show_front_lower_pin_e_clip=false,
                            show_front_lower_arm_ball_stud=false,
                            show_front_upper_arm_pin=false,
                            show_upper_arm_ball_stud=false,
                            show_knuckle_bushing=false,
                            show_knuckle_inner_bearing=false,
                            show_knuckle_outer_bearing=false,
                            show_knuckle_tie_rod=true,
                            show_wheels=false);
}

module hardware() {
  for (i = [0:1]) {
    side = i == 0 ? -1 : 1;
    mounts = front_shock_mounts(front_shock_settings,
                                front_shock_spec,
                                side,
                                poses[i]);
    if (part == "shock_structure_collision") {
      front_suspension_shock(settings=plist_put("show_fasteners", false, front_shock_settings),
                             shock=front_shock_spec,
                             side=side,
                             pose=poses[i]);
    } else if (part == "fastener_structure_collision") {
      front_shock_mount_hardware(mounts,
                                 front_shock_settings,
                                 front_shock_spec);
    } else if (part == "blocked_mount_bores") {
      for (j = [0:1]) {
        depth = j == 0
                ? plist_get("lower_engagement", front_shock_settings)
                : front_shock_tower_thickness;
        translate(plist_get("faces", mounts)[j] + [0, probe_overlap, 0]) {
          rotate([90, 0, 0]) {
            cylinder(d=plist_get("bolt_d", front_shock_settings) - probe_clearance,
                     h=depth + 2 * probe_overlap,
                     $fn=probe_fn);
          }
        }
      }
    } else {
      assert(false, "Unknown front shock clearance probe");
    }
  }
}
intersection() {
  structure();
  hardware();
}
