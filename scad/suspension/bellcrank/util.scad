/**
  * Module: Bellcrank utilities
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../steering_params.scad>


function bellcrank_idler_arm_z_end(thickness=bellcrank_arm_thickness,
                                   arm_z=bellcrank_arm_z,
                                   shoulder_h=bellcrank_post_flang_h) =
  shoulder_h + arm_z + thickness;

function bellcrank_idler_full_mount_h(bush_h=bellcrank_post_h,
                                      shoulder_h=bellcrank_post_flang_h,
                                      chamfer_h=bellcrank_idler_chamfer_h,
                                      shoulder_h=bellcrank_post_flang_h,
                                      extra_h=bellcrank_idler_extra_h) =
  bush_h - shoulder_h + chamfer_h + extra_h;