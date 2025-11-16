/**
 * Module: Mini ATM Blade Fuse Holder Inline placeholder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <../wire.scad>

module stairs_solid(total_size=[100, 50, 40], step_count=5, center=true) {
  length = total_size[0];
  width  = total_size[1];
  height = total_size[2];

  step_count = max(1, floor(step_count));
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
                            wiring_starting_len=100,
                            slot_mode=false) {

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
         thread_depth= mounting_hole_depth / n,
         thread_h = mounting_hole_h * 0.9,
         thread_l = mounting_hole_l * 0.9) {
      difference() {
        color(rib_colr, alpha=1) {
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
                      #linear_extrude(height=thread_depth
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
        rotate([0, 90, 0]) {
          color(red_1, alpha=1) {
            cylinder(h=wiring_starting_len, r=wiring_d / 2,
                     center=false,
                     $fn=35);
          }
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
                       lid_w=atm_fuse_holder_lid_w,
                       lid_top_l=atm_fuse_holder_lid_top_l,
                       lid_bottom_l=atm_fuse_holder_lid_bottom_l,
                       lid_h=atm_fuse_holder_lid_h,
                       lid_colr=matte_black_2,
                       lid_rib_thickness=atm_fuse_holder_lid_rib_thickness,
                       lid_rib_h=atm_fuse_holder_lid_rib_h,
                       lid_rib_l=atm_fuse_holder_lid_rib_l,
                       lid_rib_n=atm_fuse_holder_lid_rib_n,
                       lid_rib_distance=atm_fuse_holder_lid_rib_distance,
                       mounting_hole_l=atm_fuse_holder_mounting_hole_l,
                       mounting_hole_h=atm_fuse_holder_mounting_hole_h,
                       mounting_hole_r=atm_fuse_holder_mounting_hole_r,
                       mounting_hole_depth=atm_fuse_holder_mounting_hole_depth,
                       body_w=atm_fuse_holder_body_w,
                       body_top_l=atm_fuse_holder_body_top_l,
                       body_bottom_l=atm_fuse_holder_body_bottom_l,
                       body_h=atm_fuse_holder_body_h,
                       body_colr=matte_black_2,
                       rib_colr=matte_black,
                       rib_thickness=atm_fuse_holder_body_rib_thickness,
                       rib_h=atm_fuse_holder_body_rib_h,
                       rib_l=atm_fuse_holder_body_rib_l,
                       rib_n=atm_fuse_holder_body_rib_n,
                       wiring_d=atm_fuse_holder_body_wiring_d,
                       rib_distance=atm_fuse_holder_body_rib_distance,
                       wiring_starting_len=15,
                       center=true,
                       slot_mode=false) {
  translate([center ? 0 : -body_bottom_l / 2,
             center ? 0 : -body_h / 2,
             0]) {
    if (show_lid && !slot_mode) {
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
                           rib_thickness=rib_thickness,
                           rib_h=rib_h,
                           rib_l=rib_l,
                           rib_n=rib_n,
                           rib_distance=rib_distance,
                           mounting_hole_l=mounting_hole_l,
                           mounting_hole_depth=mounting_hole_depth,
                           mounting_hole_h=mounting_hole_h,
                           mounting_hole_r=mounting_hole_r,
                           wiring_d=wiring_d,
                           wiring_starting_len=wiring_starting_len,
                           slot_mode=slot_mode);
    }
  }
}

module rect_counterbore(size,
                        cbore_size,
                        r,
                        thickness,
                        cbore_thickness,
                        cbore_reverse=false,
                        center=false) {
  cbore_t = is_undef(cbore_thickness)
    ? max(1, thickness / 2.2)
    : cbore_thickness;
  cbore_z = cbore_reverse ? thickness - cbore_t : 0;
  translate([center ? 0 : max(size[0], cbore_size[0]) / 2,
             center ? 0 : max(size[1], cbore_size[1]) / 2,
             0]) {
    union() {
      linear_extrude(height=thickness,
                     center=false) {
        rounded_rect(size=[size[0], size[1]],
                     r=r,
                     center=true);
      }

      translate([0, 0, cbore_z]) {
        linear_extrude(height=cbore_t,
                       center=false) {
          rounded_rect(size=[cbore_size[0],
                             cbore_size[1]],
                       r=r,
                       center=true);
        }
      }
    }
  }
}

function fuse_center_y(specs, i) =
  let (y_sizes = map_idx(specs, 1, 0),
       y_spaces = map_idx(specs, 3, 0),
       prev_y_size = i > 0 ? sum(y_sizes, i) : 0,
       prev_y_space = i > 0 ? sum(y_spaces, i) : 0,
       spec = specs[i],
       y_offset = is_undef(spec[5]) ? 0 : spec[5])
  prev_y_size + prev_y_space + y_offset + spec[1] / 2;

module rect_counterbore_with_param() {
  spec = $spec;
  rect_counterbore(size=[spec[0],
                         spec[1]],
                   cbore_size=spec[6],
                   r=spec[2],
                   center=true,
                   cbore_reverse=false,
                   thickness=thickness);
}

module power_lid_side_rect_holes(specs, thickness) {
  y_sizes = map_idx(specs, 1, 0);
  y_spaces = map_idx(specs, 3, 0);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         prev_spec=i > 0 ? specs[i - 1] : undef,
         y_center = fuse_center_y(specs, i),
         prev_y_size= i > 0 ? sum(y_sizes, i) : 0,
         prev_y_space=i > 0 ? sum(y_spaces, i) : 0,
         y = prev_y_size + prev_y_space) {

      let (x = is_undef(spec[4]) ? 0 : spec[4],
           y_offset = is_undef(spec[5]) ? 0 : spec[5],
           extra_thickness = 1) {

        translate([x, y_center, 0]) {
          if (!$children) {
            rect_counterbore(size=[spec[0],
                                   spec[1]],
                             cbore_size=spec[6],
                             r=spec[2],
                             center=true,
                             cbore_reverse=false,
                             thickness=thickness);
          }

          children();
        }
      }
    }
  }
}

module power_lid_atm_fusers_placeholders(specs,
                                         thickness=power_case_side_wall_thickness
                                         + power_case_rail_tolerance
                                         + power_lid_extra_side_thickness,
                                         rotation=[0, 90, 0]) {
  for (specs=power_lid_side_wall_fuse_holes) {
    let (heights = map_idx(specs, 0, 0),
         max_h = max(heights)) {
      translate([0, 0, max_h / 2]) {
        power_lid_side_rect_holes(specs=specs,
                                  thickness=thickness) {
          rotate([0, 0, -90]) {
            atm_fuse_holder(show_lid=false,
                            show_body=true,
                            center=true,
                            slot_mode=false);
          }
        }
      }
    }
  }
}

module power_lid_side_wall_atm_fuse_slots() {
  for (specs=power_lid_side_wall_fuse_holes) {
    let (heights = map_idx(specs, 0, 0),
         max_h = max(heights)) {
      translate([0, 0, max_h / 2]) {
        rotate([0, 90, 0]) {
          power_lid_side_rect_holes(specs=specs,
                                    thickness=power_case_side_wall_thickness
                                    + power_case_rail_tolerance
                                    + power_lid_extra_side_thickness);
        }
      }
    }
  }
}

power_lid_side_wall_atm_fuse_slots();
power_lid_atm_fusers_placeholders();
// for (specs=power_lid_side_wall_fuse_holes) {
//   let (heights = map_idx(specs, 0, 0),
//        max_h = max(heights)) {
//     translate([0, 0, max_h / 2]) {
//       rotate([0, 90, -0]) {
//         power_lid_side_rect_holes(specs=specs,
//                                   thickness=power_case_side_wall_thickness
//                                   + power_case_rail_tolerance
//                                   + power_lid_extra_side_thickness) {
//           translate([0, 0, -max_h / 2]) {
//             rotate([90, 0, -90]) {
//               atm_fuse_holder(show_lid=false,
//                               show_body=true,
//                               center=true,
//                               slot_mode=false);
//             }
//           }
//         }
//       }
//     }
//   }
//  }

rect_c = power_lid_side_wall_fuse_holes[0][0];

rect_counterbore(size=[rect_c[0],
                       rect_c[1]],
                 cbore_size=rect_c[6],
                 r=rect_c[2],
                 center=true,
                 cbore_reverse=false,
                 thickness=power_case_side_wall_thickness
                 + power_case_rail_tolerance
                 + power_lid_extra_side_thickness);

// cube([atm_fuse_holder_body_w,
//       atm_fuse_holder_body_top_l,
//       atm_fuse_holder_body_bottom_l]);