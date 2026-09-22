/**
  * Module: Middle chassis.
  *
  * Provides a lightweight lattice deck for the paired power cases, Raspberry
  * Pi, and motor carrier. Both ends carry wide male joints so the frame can be
  * printed with its upper face on the bed. The central volume remains available
  * for a future lidar tower above the electronics.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>
include <../computed.scad>
include <../front_chassis/computed_params.scad>

use <../../head/head_neck.scad>
use <../../lib/placement.scad>
use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../../lipo_pack_case/multi_lipo_pack_case.scad>
use <../../placeholders/lidar.scad>
use <../../placeholders/lipo_pack.scad>

show_middle_chassis               = true;
show_middle_chassis_components    = true;
show_middle_chassis_power_case    = true;
show_middle_chassis_lipo_packs    = true;
show_middle_chassis_lidar         = true;
show_middle_chassis_lidar_support = true;

module middle_chassis(power_case_plist=multi_lipo_packs_case,
                      color=white_off_1,
                      anchor=[0, -1, 1]) {
  lipo_pack_case_props = multi_lipo_pack_props(plist=power_case_plist);
  lipo_pack_case_size     = plist_get("size", lipo_pack_case_props);
  size = [front_middle_chassis_max_w,
          lipo_pack_case_size[1],
          chassis_thickness];

  with_anchor(anchor=anchor, size=size, centered=true) {
    difference() {
      maybe_color(color) {
        cuboid(size=[front_middle_chassis_max_w,
                     lipo_pack_case_size[1],
                     chassis_thickness],
               anchor=[0, 0, 1]);
      }
      translate([0, 0, -chassis_thickness]) {
        multi_lipo_pack_case(power_case_plist,
                             anchor=[0, 0, 1],
                             slot_mode=true,
                             parent_thickness=chassis_thickness,
                             show_packs=show_middle_chassis_lipo_packs);
      }
    }
  }
}

module middle_chassis_assembly(show_middle_chassis=show_middle_chassis,
                               show_middle_chassis_components=show_middle_chassis_components,
                               show_middle_chassis_power_case=show_middle_chassis_power_case,
                               show_middle_chassis_lipo_packs=show_middle_chassis_lipo_packs,
                               show_middle_chassis_lidar=show_middle_chassis_lidar,
                               show_middle_chassis_lidar_support=show_middle_chassis_lidar_support,
                               power_case_plist=multi_lipo_packs_case,
                               color=white_off_1,
                               anchor=[0, -1, 1]) {

  lidar_h = head_neck_max_z();
  lipo_pack_case_props = multi_lipo_pack_props(plist=power_case_plist);
  lipo_pack_case_size     = plist_get("size", lipo_pack_case_props);
  size = [front_middle_chassis_max_w,
          lipo_pack_case_size[1],
          lipo_pack_case_size[2]];

  lipo_case_h = size[2];

  lidar_mount_h = lidar_h - lipo_case_h;

  with_anchor(anchor=anchor,
              size=size,
              centered=true) {
    if (show_middle_chassis) {
      middle_chassis(power_case_plist=power_case_plist,
                     anchor=[0, 0, 1],
                     color=color);
    }

    if (show_middle_chassis_components) {
      translate([0, 0, chassis_thickness]) {
        if (show_middle_chassis_power_case) {
          multi_lipo_pack_case(power_case_plist,
                               anchor=[0, 0, 1],
                               show_packs=show_middle_chassis_lipo_packs);
        }
        translate([0, 0, lipo_case_h]) {
          if (show_middle_chassis_lidar_support) {
            color(noir_1, alpha=1) {
              cuboid(size=concat(plist_get("size", rplidar_c1_plist),
                                 [lidar_mount_h - plist_get("base_h", rplidar_c1_plist)]),
                     anchor=[0, 0, 1]);
            }
          }

          if (show_middle_chassis_lidar) {
            translate([0, 0,  lidar_mount_h]) {
              lidar(plist=rplidar_c1_plist, anchor=[0, 0, -1]);
            }
          }
        }
      }
    }
  }
}

middle_chassis_assembly();
