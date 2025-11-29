/**
 * Module: Mini ATM Blade Fuse Holder Inline placeholder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

use <../wire.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/trapezoids.scad>
use <../lib/transforms.scad>

side_wall_w = power_case_side_wall_thickness
  + power_case_rail_tolerance
  + power_lid_extra_side_thickness;

module stairs_solid(total_size=[100, 50, 40], step_count=5, center=true) {
  length = total_size[0];
  width  = total_size[1];
  height = total_size[2];

  step_count = max(1, round(step_count));
  run  = length / step_count;
  rise = height / step_count;

  translate([center ? -length / 2 : 0, center ? -width / 2 : 0, 0]) {
    for (i = [0 : step_count-1]) {
      translate([i * run, 0, i * rise]) {
        cube_3d([length - i*run, width, rise], center=false);
      }
    }
  }
}

module atm_fuse_holder_body(body_w=atm_fuse_holder_body_w,
                            top_l=atm_fuse_holder_body_top_l,
                            bottom_l=atm_fuse_holder_body_bottom_l,
                            body_h=atm_fuse_holder_body_h,
                            body_colr=matte_black_2,
                            rib_colr=matte_black,
                            rib_thickness=atm_fuse_holder_body_rib_thickness,
                            rib_h=atm_fuse_holder_body_rib_h,
                            rib_l=atm_fuse_holder_body_rib_l,
                            rib_n=atm_fuse_holder_body_rib_n,
                            rib_distance=atm_fuse_holder_body_rib_distance,
                            mounting_hole_l=atm_fuse_holder_mounting_hole_l,
                            mounting_hole_depth=atm_fuse_holder_mounting_hole_depth,
                            mounting_hole_h=atm_fuse_holder_mounting_hole_h,
                            mounting_hole_r=atm_fuse_holder_mounting_hole_r,
                            wiring_d=atm_fuse_holder_body_wiring_d,
                            wire_points=[[15, 0, 0],
                                         [0, 0, 0]]) {

  wiring_rad_jack = min(body_w, body_h) / 2.5;

  union() {
    color(body_colr, alpha=1) {
      linear_extrude(height=body_w, center=false, convexity=2) {
        trapezoid_rounded_bottom(b=bottom_l, t=top_l, h=body_h, center=true);
      }
    }
    color(rib_colr, alpha=1) {
      translate([0,
                 -body_h / 2 + rib_h / 2 + rib_distance,
                 0]) {
        rotate([180, 0, -90]) {
          stairs_solid(total_size=[rib_h,
                                   rib_l,
                                   rib_thickness],
                       step_count=rib_n);
        }
        translate([0,
                   0,
                   body_w]) {
          rotate([0, 0, -90]) {
            stairs_solid(total_size=[rib_h, rib_l, rib_thickness],
                         step_count=rib_n);
          }
        }
      }
    }

    let (fuse_slot_l = mounting_hole_l * 0.3,
         fuse_slot_thickness = mounting_hole_h * 0.35,
         fuse_slot_side_offst = mounting_hole_l * 0.1,
         n=4,
         thread_depth = mounting_hole_depth / n,
         thread_h = mounting_hole_h * 0.9,
         thread_l = mounting_hole_l * 0.9) {
      difference() {
        #color(rib_colr, alpha=1) {
          union() {
            for (i = [0 : n - 1]) {
              translate([0,
                         i * thread_depth,
                         0]) {
                if (i % 2 != 1) {
                  translate([-thread_l / 2,
                             body_h / 2
                             + thread_depth + thread_depth * 0.5,
                             body_w / 2 - thread_h / 2]) {
                    rotate([90, 0, 0]) {
                      linear_extrude(height=thread_depth
                                     + thread_depth * 0.5, center=false) {
                        rounded_rect([thread_l,
                                      thread_h],
                                     r=mounting_hole_r,
                                     center=false);
                      }
                    }
                  }
                } else {
                  translate([-mounting_hole_l / 2,
                             body_h / 2
                             + thread_depth,
                             body_w / 2 - mounting_hole_h / 2]) {
                    rotate([90, 0, 0]) {
                      linear_extrude(height=thread_depth * 0.5, center=false) {
                        rounded_rect([mounting_hole_l,
                                      mounting_hole_h],
                                     r=mounting_hole_r,
                                     center=false);
                      }
                    }
                  }
                }
              }
            }
          }
        }

        mirror_copy([1, 0, 0]) {
          translate([mounting_hole_l / 2
                     - fuse_slot_l / 2
                     - fuse_slot_side_offst,
                     body_h / 2
                     + mounting_hole_depth
                     - mounting_hole_depth / 2,
                     mounting_hole_h / 2
                     + fuse_slot_thickness / 2]) {
            cube_3d([fuse_slot_l,
                     mounting_hole_depth + 0.1,
                     fuse_slot_thickness],
                    center=true);
          }
        }
      }
    }

    mirror_copy([1, 0, 0]) {
      translate([bottom_l / 2, 0, body_w / 2]) {
        color(body_colr, alpha=1) {
          sphere(r=wiring_rad_jack);
        }

        color(red_1, alpha=1) {
          wire_path(points=wire_points,
                    d=wiring_d,
                    put_joints=true);
        }
      }
    }
  }
}

module atm_fuse_lid(lid_w=atm_fuse_holder_lid_w,
                    top_l=atm_fuse_holder_lid_top_l,
                    bottom_l=atm_fuse_holder_lid_bottom_l,
                    lid_h=atm_fuse_holder_lid_h,
                    lid_colr=matte_black_2,
                    rib_colr=matte_black,
                    rib_thickness=atm_fuse_holder_lid_rib_thickness,
                    rib_h=atm_fuse_holder_lid_rib_h,
                    rib_l=atm_fuse_holder_lid_rib_l,
                    rib_n=atm_fuse_holder_lid_rib_n,
                    rib_distance=atm_fuse_holder_lid_rib_distance,
                    mounting_hole_l=atm_fuse_holder_mounting_hole_l,
                    mounting_hole_h=atm_fuse_holder_mounting_hole_h,
                    mounting_hole_r=atm_fuse_holder_mounting_hole_r) {

  difference() {
    union() {
      color(lid_colr, alpha=1) {
        linear_extrude(height=lid_w, center=false) {
          trapezoid_rounded_top(b=bottom_l, t=top_l, h=lid_h, center=true);
        }
      }

      translate([0,
                 top_l / 2 - rib_h / 2 - rib_distance,
                 0]) {
        rotate([180, 0, 90]) {
          color(rib_colr, alpha=1) {
            stairs_solid(total_size=[rib_h, rib_l, rib_thickness],
                         step_count=rib_n);
          }
        }
        translate([0,
                   0,
                   lid_w]) {
          rotate([0, 0, 90]) {
            color(rib_colr, alpha=1) {
              stairs_solid(total_size=[rib_h, rib_l, rib_thickness],
                           step_count=rib_n);
            }
          }
        }
      }
    }

    translate([0,
               0,
               lid_w / 2]) {
      rotate([90, 0, 0]) {
        linear_extrude(height=lid_h * 0.8, center=false) {
          rounded_rect([mounting_hole_l,
                        mounting_hole_h],
                       r=mounting_hole_r,
                       center=true);
        }
      }
    }
  }
}

module atm_fuse_holder(show_lid=true,
                       show_body=true,
                       mounting_hole_spec=[atm_fuse_holder_mounting_hole_h,
                                           atm_fuse_holder_mounting_hole_l,
                                           atm_fuse_holder_mounting_hole_r,
                                           atm_fuse_holder_mounting_hole_depth],
                       body_spec=[atm_fuse_holder_body_top_l,
                                  atm_fuse_holder_body_bottom_l,
                                  atm_fuse_holder_body_w,
                                  atm_fuse_holder_body_h,
                                  matte_black_2],
                       lid_spec=[atm_fuse_holder_lid_top_l,
                                 atm_fuse_holder_lid_bottom_l,
                                 atm_fuse_holder_lid_w,
                                 atm_fuse_holder_lid_h,
                                 matte_black_2],
                       body_rib_spec=[atm_fuse_holder_body_rib_l,
                                      atm_fuse_holder_body_rib_h,
                                      atm_fuse_holder_body_rib_n,
                                      atm_fuse_holder_body_rib_distance,
                                      atm_fuse_holder_body_rib_thickness],
                       lid_rib_spec=[atm_fuse_holder_lid_rib_l,
                                     atm_fuse_holder_lid_rib_h,
                                     atm_fuse_holder_lid_rib_n,
                                     atm_fuse_holder_lid_rib_distance,
                                     atm_fuse_holder_lid_rib_thickness],
                       lid_rib_thickness=atm_fuse_holder_lid_rib_thickness,
                       lid_rib_h=atm_fuse_holder_lid_rib_h,
                       lid_rib_l=atm_fuse_holder_lid_rib_l,
                       lid_rib_n=atm_fuse_holder_lid_rib_n,
                       lid_rib_distance=atm_fuse_holder_lid_rib_distance,
                       rib_colr=matte_black,
                       wiring_d=atm_fuse_holder_body_wiring_d,
                       wire_points=[[15, 0, 0],
                                    [0, 0, 0]],
                       center=true) {

  body_top_l = body_spec[0];
  body_bottom_l = body_spec[1];
  body_w = body_spec[2];
  body_h = body_spec[3];
  body_colr = is_undef(body_spec[4]) ? matte_black_2 : body_spec[4];

  lid_top_l = lid_spec[0];
  lid_bottom_l = lid_spec[1];
  lid_w = lid_spec[2];
  lid_h = lid_spec[3];
  lid_colr = is_undef(lid_spec[4]) ? matte_black_2 : body_spec[4];

  mounting_hole_h = mounting_hole_spec[0];
  mounting_hole_l = mounting_hole_spec[1];
  mounting_hole_r = mounting_hole_spec[2];
  mounting_hole_depth = is_undef(mounting_hole_spec[3])
    ? atm_fuse_holder_mounting_hole_depth
    : mounting_hole_spec[3];

  body_rib_l=body_rib_spec[0];
  body_rib_h=body_rib_spec[1];
  body_rib_n=body_rib_spec[2];
  body_rib_distance=body_rib_spec[3];
  body_rib_thickness=body_rib_spec[4];

  lid_rib_l=lid_rib_spec[0];
  lid_rib_h=lid_rib_spec[1];
  lid_rib_n=lid_rib_spec[2];
  lid_rib_distance=lid_rib_spec[3];
  lid_rib_thickness=lid_rib_spec[4];

  translate([center ? 0 : -body_bottom_l / 2,
             center ? 0 : -body_h / 2,
             0]) {
    if (show_lid) {
      translate([0, body_h / 2 + lid_h / 2 + 0.8, 0]) {
        atm_fuse_lid(lid_w=lid_w,
                     top_l=lid_top_l,
                     bottom_l=lid_bottom_l,
                     lid_h=lid_h,
                     lid_colr=lid_colr,
                     rib_thickness=lid_rib_thickness,
                     rib_h=lid_rib_h,
                     rib_l=lid_rib_l,
                     rib_n=lid_rib_n,
                     rib_distance=lid_rib_distance,
                     mounting_hole_l=mounting_hole_l,
                     mounting_hole_h=mounting_hole_h,
                     mounting_hole_r=mounting_hole_r);
      }
    }

    if (show_body) {
      atm_fuse_holder_body(body_w=body_w,
                           top_l=body_top_l,
                           bottom_l=body_bottom_l,
                           body_h=body_h,
                           body_colr=body_colr,
                           rib_colr=rib_colr,
                           rib_thickness=body_rib_thickness,
                           rib_h=body_rib_h,
                           rib_l=body_rib_l,
                           rib_n=body_rib_n,
                           rib_distance=body_rib_distance,
                           mounting_hole_l=mounting_hole_l,
                           mounting_hole_depth=mounting_hole_depth,
                           mounting_hole_h=mounting_hole_h,
                           mounting_hole_r=mounting_hole_r,
                           wiring_d=wiring_d,
                           wire_points=wire_points);
    }
  }
}

atm_fuse_holder();