/**
  * Module: Wago bracket fit and mounting examples.
  * Set view to bracket, variants, rear, rear_open, or lid.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/rc_params.scad>

use <../../scad/lib/plist.scad>
use <../../scad/lipo_pack_case/multi_lipo_pack_lid.scad>
use <../../scad/suspension/rear_chassis/computed_params.scad>
use <../../scad/suspension/rear_chassis/rear_chassis.scad>
use <../../scad/wago/wago_bracket.scad>

view      = "bracket";
lid_spec  = plist_merge(plist_get("lid", multi_lipo_packs_case),
                        ["wago_mounts", [["pos", [-54, 0]],
                                         ["pos", [54, 0],
                                          "rotation", 180]]]);
case_spec = plist_merge(multi_lipo_packs_case, ["lid", lid_spec]);

if (view == "bracket") {
  wago_bracket(show_wago=true, show_bolts=true);
} else if (view == "variants") {
  wago_bracket(show_wago=true);
  translate([55, 0, 0]) {
    wago_bracket(pl=["mount_side", "sides"], show_wago=true);
  }
  translate([0, 50, 0]) {
    wago_bracket(pl=["wago", ["n", 3,
                              "total_w", 22.7]],
                 show_wago=true);
  }
} else if (view == "rear" || view == "rear_open") {
  rear_chassis(layout=rear_chassis_layout(power_case=case_spec,
                                          wago_mounts=[["placement", "auto",
                                                        "rotation", 270],
                                                       ["placement", "after",
                                                        "rotation", 180]]),
               show_power_case=view == "rear",
               show_lipo_packs=view == "rear",
               show_lidar=view == "rear",
               show_lidar_lid=view == "rear");
} else if (view == "lid") {
  multi_lipo_pack_lid(case_spec,
                      show_wago_brackets=true,
                      show_lidar=true,
                      show_adapter=true);
}
