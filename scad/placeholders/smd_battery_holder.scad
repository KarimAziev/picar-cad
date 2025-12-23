/**
 * Module: Open-frame battery holder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
include <../colors.scad>
use <battery.scad>

use <../lib/shapes3d.scad>
use <../lib/shapes2d.scad>
use <../lib/transforms.scad>

use <../lib/trapezoids.scad>
use <../lib/placement.scad>
use <../lib/functions.scad>
use <bolt.scad>

function smd_battery_holder_full_len(bottom_thickness) = battery_height + bottom_thickness * 2;
function smd_battery_holder_full_width(inner_thickness) = battery_dia + inner_thickness * 2;

function smd_battery_holder_calc_full_w(inner_thickness=smd_battery_holder_inner_thickness,
                                        amount=smd_battery_holder_batteries_count) =
  let (single_width = smd_battery_holder_full_width(inner_thickness),
       total_w = single_width * amount)
  total_w;

smd_battery_holder_side_wall_h                          = 12.5;
smd_battery_holder_side_wall_center_cutout_size         = [25, 7];
smd_battery_holder_side_wall_top_rear_cutout_size       = [9, 7];

smd_battery_holder_contact_outer_cutout_size            = [3.25,
                                                           (smd_battery_holder_front_rear_thickness / 2) - 0.5,
                                                           smd_battery_holder_height];
smd_battery_holder_contact_outer_hook_cutout_size       = [2.96, 2.35, 1.5]; // trapezoid bottom, top and height
smd_battery_holder_contact_outer_hook_cutout_y_position = smd_battery_holder_contact_outer_cutout_size[2] / 2;

smd_battery_holder_contact_inner_cutout_size            = [6.0,
                                                           (smd_battery_holder_front_rear_thickness / 2),
                                                           smd_battery_holder_height - 2];
smd_battery_holder_contact_inner_hook_cutout_size       = [2.96, 2.35, 0.5]; // trapezoid bottom, top and height
smd_battery_holder_contact_inner_hook_cutout_y_position = smd_battery_holder_contact_inner_cutout_size[2]
  - smd_battery_holder_contact_inner_hook_cutout_size[0] / 2;
smd_battery_holder_contact_width                        = 6.5;
smd_battery_holder_contact_thickness                    = 0.6;
smd_battery_holder_contact_outer_bottom_cutout_size     = [2.96,
                                                           (smd_battery_holder_front_rear_thickness / 2),
                                                           smd_battery_holder_height - 2];

module smd_battery_holder(height=smd_battery_holder_height,
                          length=smd_battery_holder_length,
                          amount=smd_battery_holder_batteries_count,
                          screw_dia=smd_battery_holder_screw_dia,
                          screws_size=smd_battery_holder_screws_size,
                          screw_recess_size=smd_battery_holder_screw_recess_size,
                          bottom_thickness=smd_battery_holder_bottom_thickness,
                          side_thickness=smd_battery_holder_side_thickness,
                          front_rear_thickness=smd_battery_holder_front_rear_thickness,
                          inner_cutout_size=smd_battery_holder_inner_cutout_size,
                          inner_thickness=smd_battery_holder_inner_thickness,
                          inner_cutout_h=smd_battery_holder_inner_side_h,
                          side_wall_h=smd_battery_holder_side_wall_h,
                          side_wall_center_cutout_size=smd_battery_holder_side_wall_center_cutout_size,
                          side_wall_top_rear_cutout_size=smd_battery_holder_side_wall_top_rear_cutout_size,
                          contact_width=smd_battery_holder_contact_width,
                          contact_thickness=smd_battery_holder_contact_thickness,
                          outer_contact_size=smd_battery_holder_contact_outer_cutout_size,
                          inner_contact_cutout_size=smd_battery_holder_contact_inner_cutout_size,
                          contact_hole_d=1,
                          contact_mount_bottom_size=[smd_battery_holder_contact_width,
                                                     4.54,
                                                     smd_battery_holder_contact_thickness],
                          inner_hook_cutout_size=smd_battery_holder_contact_inner_hook_cutout_size,
                          inner_hook_y_position=smd_battery_holder_contact_inner_hook_cutout_y_position,
                          outer_hook_cutout_size=smd_battery_holder_contact_outer_hook_cutout_size,
                          outer_bottom_cutout_size=smd_battery_holder_contact_outer_bottom_cutout_size,

                          show_battery=false,
                          show_contact=true,
                          show_bolt=true,
                          show_nut=true,
                          lock_nut=false,
                          bolt_head_type="round",
                          bolt_visible_h = 2) {

  if (amount > 0) {

    single_width = smd_battery_holder_full_width(inner_thickness);

    total_w = smd_battery_holder_calc_full_w(inner_thickness, amount);

    full_len = is_undef(length)
      ? smd_battery_holder_full_len(front_rear_thickness)
      : length;

    total_l = full_len - front_rear_thickness * 2;

    union() {
      difference() {
        translate([-total_w / 2, -full_len / 2, 0]) {
          union() {
            for (i = [0 : amount - 1]) {
              translate([i * single_width, 0, 0]) {
                smd_battery_holder_single_assembly(full_width=single_width,
                                                   full_len=full_len,
                                                   height=height,
                                                   bottom_thickness=bottom_thickness,
                                                   inner_cutout_size=inner_cutout_size,
                                                   front_rear_thickness=front_rear_thickness,
                                                   center=false,
                                                   tolerance=1,
                                                   show_contact=show_contact,
                                                   show_battery=show_battery,
                                                   contact_width=contact_width,
                                                   contact_thickness=contact_thickness,
                                                   outer_contact_size=outer_contact_size,
                                                   inner_contact_cutout_size=inner_contact_cutout_size,
                                                   contact_hole_d=contact_hole_d,
                                                   contact_mount_bottom_size=contact_mount_bottom_size,
                                                   inner_hook_cutout_size=inner_hook_cutout_size,
                                                   inner_hook_y_position=inner_hook_y_position,
                                                   outer_hook_cutout_size=outer_hook_cutout_size,
                                                   outer_bottom_cutout_size=outer_bottom_cutout_size,);
              }
            }
          }
        }

        mirror_copy([1, 0, 0]) {
          translate([total_w / 2 - side_thickness / 2,
                     0,
                     side_wall_center_cutout_size[1]]) {
            cube_3d(size=[side_thickness + 1,
                          side_wall_center_cutout_size[0],
                          side_wall_center_cutout_size[1] + 1]);
          }
          translate([total_w / 2 - side_thickness / 2,
                     0,
                     side_wall_h]) {
            cube_3d(size=[side_thickness + 1,
                          full_len - front_rear_thickness * 2 ,
                          height - side_wall_h + 1]);
          }
          mirror_copy([0, 1, 0]) {
            translate([total_w / 2 - side_thickness / 2,
                       full_len / 2
                       - side_wall_top_rear_cutout_size[0] / 2
                       - front_rear_thickness,
                       height - side_wall_top_rear_cutout_size[1]]) {
              cube_3d(size=[side_thickness + 1,
                            side_wall_top_rear_cutout_size[0],
                            side_wall_top_rear_cutout_size[1] + 1]);
            }
          }
        }
        translate([0, 0, inner_cutout_h]) {
          cube_3d(size=[total_w - side_thickness * 2,
                        total_l,
                        height,]);
        }
        four_corner_children(size=screws_size) {
          translate([0, 0, screw_recess_size[2]]) {
            cube_3d(size=[screw_recess_size[0],
                          screw_recess_size[1],
                          height]);
          }
          translate([0, 0, -0.1]) {
            cylinder(d=screw_dia,
                     h=height + 0.1,
                     $fn=360);
          }
        }
      }
      translate([-total_w / 2, -full_len / 2, 0]) {
        for (i = [0 : amount - 1]) {
          translate([i * single_width, 0, 0]) {
            if (show_battery) {
              translate([single_width / 2, full_len / 2, 0]) {
                translate([0, battery_height / 2,
                           battery_dia / 2]) {
                  rotate([90, 0, 0]) {
                    battery();
                  }
                }
              }
            }
          }
        }
      }
      if (show_bolt) {
        let (blt_h = round(bottom_thickness + chassis_thickness + bolt_visible_h),
             bolt_h = blt_h % 2 == 0 ? blt_h : blt_h + 1) {
          translate([0, 0, -bolt_h + bottom_thickness]) {
            four_corner_children(size=screws_size) {
              bolt(d=screw_dia,
                   h=bolt_h,
                   head_type=bolt_head_type,
                   nut_head_distance=bottom_thickness + chassis_thickness,
                   show_nut=show_nut,
                   lock_nut=lock_nut);
            }
          }
        }
      }
    }
  }
}

module smd_battery_holder_single_assembly(full_width,
                                          full_len,
                                          height,
                                          bottom_thickness=battery_holder_thickness,
                                          front_rear_thickness,
                                          center=false,
                                          inner_cutout_size,
                                          tolerance=1,
                                          show_contact=true,
                                          show_battery=true,
                                          contact_width=smd_battery_holder_contact_width,
                                          contact_thickness=smd_battery_holder_contact_thickness,
                                          outer_contact_size=smd_battery_holder_contact_outer_cutout_size,
                                          inner_contact_cutout_size=smd_battery_holder_contact_inner_cutout_size,
                                          contact_hole_d=1,
                                          contact_mount_bottom_size=[smd_battery_holder_contact_width,
                                                                     4.54,
                                                                     smd_battery_holder_contact_thickness],
                                          inner_hook_cutout_size=smd_battery_holder_contact_inner_hook_cutout_size,
                                          inner_hook_y_position=smd_battery_holder_contact_inner_hook_cutout_y_position,
                                          outer_hook_cutout_size=smd_battery_holder_contact_outer_hook_cutout_size,
                                          outer_bottom_cutout_size=smd_battery_holder_contact_outer_bottom_cutout_size) {
  full_dia= battery_dia + tolerance;
  full_width = is_undef(full_width)
    ? smd_battery_holder_full_width(bottom_thickness)
    : full_width;

  full_len = is_undef(full_len)
    ? smd_battery_holder_full_len(front_rear_thickness)

    : full_len;

  union() {
    translate([center ? 0 : full_width / 2, center ? 0 : full_len / 2, 0]) {
      color(matte_black, alpha=1) {
        difference() {
          cube_3d(size=[full_width, full_len, height]);
          mirror_copy([0, 1, 0]) {
            translate([0, -full_len / 2 + front_rear_thickness / 2, 0]) {
              smd_battery_holder_contact_cutout(contact_w=contact_width,
                                                contact_h=contact_thickness,
                                                inner_size=inner_contact_cutout_size,
                                                inner_hook_cutout_size=inner_hook_cutout_size,
                                                inner_hook_y_position=inner_hook_y_position,
                                                outer_size=outer_contact_size,
                                                outer_hook_cutout_size=outer_hook_cutout_size,
                                                outer_hook_y_position=smd_battery_holder_contact_outer_hook_cutout_y_position,
                                                total_height=height,
                                                front_rear_thickness=front_rear_thickness,
                                                outer_bottom_cutout_size=outer_bottom_cutout_size,);
            }
          }

          if (!is_undef(inner_cutout_size)) {
            translate([0, 0, -0.2]) {
              cube_3d(size=[inner_cutout_size[0],
                            inner_cutout_size[1],
                            height + 0.2]);
            }
          }

          translate([0, 0, bottom_thickness]) {
            cube_3d(size=[inner_cutout_size[0],
                          full_len - front_rear_thickness * 2,
                          height + 0.2]);
          }
          translate([0, 0, full_dia / 2 + bottom_thickness]) {
            rotate([90, 0, 0]) {
              cylinder(d=full_dia,
                       h=max(battery_height + battery_positive_pole_height,
                             inner_cutout_size[1],
                             full_len - front_rear_thickness * 2) + 0.01,
                       center=true,
                       $fn=10);
            }
          }
        }
      }
      if (show_contact) {
        mirror_copy([0, 1, 0]) {
          translate([0, full_len / 2 - front_rear_thickness + 0.01, 0.01]) {
            smd_battery_contact(width=contact_width,
                                total_height=height,
                                thickness=contact_thickness,
                                outer_size=outer_contact_size,
                                inner_cutout_size=inner_contact_cutout_size,
                                contact_hole_d=contact_hole_d,
                                contact_mount_bottom_size=contact_mount_bottom_size);
          }
        }
      }
      if (show_battery) {
        translate([0, battery_height / 2,
                   battery_dia / 2]) {
          rotate([90, 0, 0]) {
            battery();
          }
        }
      }
    }
  }
}

module smd_battery_holder_contact_cutout_base(size=smd_battery_holder_contact_outer_cutout_size,
                                              hook_cutout_size=smd_battery_holder_contact_outer_hook_cutout_size,
                                              hook_y_position=smd_battery_holder_contact_outer_hook_cutout_y_position,
                                              inc_step=0) {
  b = hook_cutout_size[0];
  t = hook_cutout_size[1];
  h = hook_cutout_size[2];
  w = size[0];
  thickness = size[1];
  union() {
    translate([0, 0, inc_step != 0 ? (-inc_step / 2) : 0]) {
      cube_3d(size=[size[0], thickness, size[2] + inc_step]);
    }
    mirror_copy([1, 0, 0]) {
      translate([-h / 2 - w / 2, 0, hook_y_position]) {
        rotate([0, 90, 90]) {
          linear_extrude(height=thickness, center=true) {
            trapezoid(b=b, t=t, h=h, center=true);
          }
        }
      }
    }
  }
}

module smd_battery_holder_contact_cutout(contact_w=smd_battery_holder_contact_width,
                                         contact_h=smd_battery_holder_contact_thickness,
                                         inner_size=smd_battery_holder_contact_inner_cutout_size,
                                         inner_hook_cutout_size=smd_battery_holder_contact_inner_hook_cutout_size,
                                         inner_hook_y_position=smd_battery_holder_contact_inner_hook_cutout_y_position,
                                         outer_size=smd_battery_holder_contact_outer_cutout_size,
                                         outer_hook_cutout_size=smd_battery_holder_contact_outer_hook_cutout_size,
                                         outer_hook_y_position=smd_battery_holder_contact_outer_hook_cutout_y_position,
                                         total_height=smd_battery_holder_height,
                                         front_rear_thickness=smd_battery_holder_front_rear_thickness,
                                         outer_bottom_cutout_size=smd_battery_holder_contact_outer_bottom_cutout_size,
                                         inc_step=4) {
  // -outer_size[1] / 2 + front_rear_thickness / 2
  outer_thickness = outer_size[1] + inc_step;
  inner_thickness = inner_size[1] + inc_step;
  bottom_outer_thickness = outer_bottom_cutout_size[1] + inc_step;

  translate([0, 0, 0]) {
    union() {
      cube([contact_w,
            contact_h,
            total_height + 1],
           center=true);
      translate([0, -inner_size[1] / 2
                 + front_rear_thickness / 2
                 + inc_step / 2,
                 total_height - inner_size[2]]) {
        smd_battery_holder_contact_cutout_base(size=[inner_size[0], inner_thickness, inner_size[2] + inc_step],
                                               hook_cutout_size=inner_hook_cutout_size,
                                               hook_y_position=inner_hook_y_position);
      }
      translate([0, outer_size[1] / 2 - front_rear_thickness / 2 - inc_step / 2, 0]) {
        smd_battery_holder_contact_cutout_base(size=[outer_size[0], outer_thickness, outer_size[2] + inc_step],
                                               hook_cutout_size=outer_hook_cutout_size,
                                               hook_y_position=outer_hook_y_position);
      }
      translate([0, outer_bottom_cutout_size[1] / 2 - front_rear_thickness / 2 - inc_step / 2,
                 -inc_step]) {
        cube_3d(size=[outer_bottom_cutout_size[0], bottom_outer_thickness, outer_bottom_cutout_size[2] + inc_step]);
      }
    }
  }
}

module cube_center_x(size) {
  translate([-size[0] / 2, 0, 0]) {
    cube(size);
  }
}

module smd_battery_contact(width=smd_battery_holder_contact_width,
                           thickness=smd_battery_holder_contact_thickness,
                           total_height=smd_battery_holder_height,
                           front_rear_thickness=smd_battery_holder_front_rear_thickness,
                           outer_size=smd_battery_holder_contact_outer_cutout_size,
                           inner_cutout_size=smd_battery_holder_contact_inner_cutout_size,
                           contact_hole_d=1,
                           contact_mount_bottom_size=[smd_battery_holder_contact_width,
                                                      4.54,
                                                      smd_battery_holder_contact_thickness],
                           angle = 0) {

  half_of_front_thickness = front_rear_thickness / 2;
  half_of_inner_cutout_h = inner_cutout_size[2] / 2;

  bbox = rot_x_bbox_align([width, thickness,
                           half_of_inner_cutout_h],
                          angle=angle);

  color(metallic_yellow_1, alpha=1) {
    union() {
      hull() {
        translate([0, bbox[2] + thickness, total_height - bbox[5]]) {
          rotate([-angle, 0, 0]) {
            translate([0, 0, 0]) {
              cube_center_x([width, thickness, half_of_inner_cutout_h]);
            }
          }
        }
        translate([0, 0, total_height - bbox[5] * 2]) {
          rotate([angle, 0, 0]) {
            translate([0, 0, 0]) {
              cube_center_x([width, thickness, half_of_inner_cutout_h]);
            }
          }
        }
      }

      translate([0, 0, total_height - inner_cutout_size[2]]) {
        cube_center_x([width, thickness, inner_cutout_size[2]]);
      }

      translate([0, thickness, 0]) {
        translate([0, 0, total_height - thickness]) {
          cube_center_x([width, half_of_front_thickness, thickness]);
        }
        translate([0, half_of_front_thickness, 0]) {
          cube_center_x([width, thickness, total_height]);
          translate([0, thickness, 0]) {
            cube_center_x([outer_size[0], half_of_front_thickness, thickness]);
            translate([0, half_of_front_thickness, 0]) {
              difference() {
                cube_center_x(contact_mount_bottom_size);
                translate([0, contact_mount_bottom_size[1] / 2, -0.5]) {
                  cylinder(r=contact_hole_d / 2, h=thickness + 1);
                }
              }
            }
          }
        }
      }
    }
  }
}

smd_battery_holder();
