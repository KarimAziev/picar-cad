/**
 * Module: Front suspension bulkhead.
 *
 * Main front bulkhead body, including:
 * - shock tower mounting tab
 * - chassis mounting hinges (front and rear sets)
 * - recess for the suspension arm pad (to retain hinge pins)
 * - mounting features for the front upper suspension holder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../parameters.scad>
include <../../steering_params.scad>

use <../../lib/functions.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>
use <../../placeholders/bolt.scad>
use <../../placeholders/suspension_arm_pin.scad>
use <../wishbone_arms/lower_arm.scad>
use <../wishbone_arms/upper_arm.scad>
use <front_bulkhead_chassis.scad>
use <front_bulkhead_housing.scad>
use <front_shock_tower.scad>
use <front_upper_suspension_holder.scad>
use <suspension_arm_pad.scad>

show_front_shock_tower       = false;
show_upper_suspension_holder = false;
show_suspension_arm_pad      = false;
show_front_upper_arm         = false;
show_upper_arm_ball_stud     = false;
show_front_upper_arm_pin     = false;

module front_bulkhead(color=cobalt_blue_light_1,
                      shock_tower_color=cobalt_blue_metallic,
                      show_upper_suspension_holder=show_upper_suspension_holder,
                      show_shock_tower=show_front_shock_tower,
                      show_suspension_arm_pad=show_suspension_arm_pad,
                      bulkhead_w=front_bulkhead_w,
                      bulkhead_l=front_bulkhead_len,
                      bulkhead_housing_h=front_bulkhead_housing_h,
                      shock_tower_mount_offset=front_bulkhead_shock_tower_mount_offset,
                      shock_tower_mount_thickness=front_bulkhead_shock_tower_mount_thickness,
                      shock_tower_bolt_spacing=front_shock_tower_bolt_spacing,
                      shock_tower_bolt_d=front_shock_tower_bolt_d,
                      shock_tower_pad_y=front_shock_tower_damper_holes_pad_y,
                      shock_tower_mount_pad_x=front_bulkhead_shock_tower_mount_pad_x,
                      shock_tower_mount_pad_y_top=front_bulkhead_shock_tower_mount_pad_y_top,
                      tower_mount_corner_r=front_bulkhead_shock_tower_mount_corner_r,
                      tower_pin_hole_y_offset=front_shock_tower_pin_y_offset,
                      upper_holder_barrel_h=front_upper_suspension_holder_pin_barrel_h,
                      upper_holder_w=front_upper_suspension_w,
                      upper_holder_bolt_d=front_upper_suspension_holder_bolt_d,
                      upper_holder_bolt_spacing=front_upper_suspension_holder_bolt_spacing,
                      upper_holder_bore_d=front_upper_suspension_holder_bolt_bore_d,
                      upper_holder_thickness=front_upper_suspension_holder_thickness,
                      upper_holder_bore_y_offset=front_upper_suspension_holder_bolt_y_offset,
                      upper_holder_round_cutout_d=front_upper_suspension_holder_round_cutout_d,
                      upper_holder_hole_depth=front_bulkhead_upper_holder_hole_depth,
                      support_extra_len=front_bulkhead_support_extra_len,
                      support_clearance=front_bulkhead_support_clearance,
                      upper_holder_round_cutout_y_offset=front_upper_suspension_holder_round_cutout_offset,
                      pin_d=front_upper_arm_hinge_barrel_hole_d,
                      show_front_upper_arm=show_front_upper_arm,
                      show_upper_arm_ball_stud=show_upper_arm_ball_stud,
                      show_front_upper_arm_pin=show_front_upper_arm_pin,
                      arm_pin_l=front_upper_arm_pin_len,
                      arm_pad_hook_h=front_suspension_arm_pad_hook_len_y,
                      arm_pad_thickness=front_suspension_arm_pad_thickness,
                      arm_pad_holder_thickness=front_bulkhead_suspension_pad_thickness,
                      arm_pad_clearance=front_bulkhead_suspension_pad_clearance) {

  l2 = bulkhead_l / 2;

  // Common Y position for the upper arm hinge pin axis (relative to the shock tower reference)
  common_pin_y = tower_pin_hole_y_offset + pin_d / 2;

  // Thickness of the bulkhead “shelf” where the upper holder mounts
  upper_holder_mount_thickness = upper_holder_barrel_h - upper_holder_thickness;

  // Width of the internal support feature, accounting for clearance
  support_w = upper_holder_round_cutout_d - support_clearance;

  arm_pin_d = snap_bolt_d(pin_d);

  upper_suspension_holder_y = -l2 - upper_holder_barrel_h;

  union() {
    maybe_color(color) {
      difference() {
        union() {
          hull() {
            translate([-bulkhead_w / 2,
                       -l2,
                       shock_tower_mount_offset + shock_tower_bolt_spacing[1]]) {
              rotate([0, 90, 0]) {
                linear_extrude(height=bulkhead_w,
                               center=false) {
                  rounded_rect([shock_tower_mount_offset
                                + shock_tower_bolt_spacing[1],
                                bulkhead_l],
                               center=false,
                               side="left",
                               fn=$preview ? 6 : 360,
                               r_factor=0.5);
                }
              }
            }
            translate([0, -l2 -upper_holder_mount_thickness, 0]) {
              cube_center_x(size=[bulkhead_w,
                                  upper_holder_mount_thickness,
                                  shock_tower_mount_offset + upper_holder_w]);
            }
            translate([0, l2, 0]) {
              cube_center_x(size=[bulkhead_w,
                                  arm_pad_holder_thickness + arm_pad_thickness,
                                  arm_pad_hook_h + arm_pad_holder_thickness]);
            }
          }

          translate([-support_w / 2,
                     -l2 - upper_holder_mount_thickness,
                     0]) {
            rotate([90, 0, 0]) {
              linear_extrude(height=upper_holder_mount_thickness + support_extra_len,
                             center=false) {
                rounded_rect([support_w,
                              upper_holder_round_cutout_d
                              + shock_tower_bolt_spacing[1]
                              - upper_holder_round_cutout_y_offset
                              - upper_holder_bore_d / 2],
                             center=false,
                             side="top",
                             r_factor=0.5);
              }
            }
          }
        }
        translate([0, -arm_pad_clearance / 2, -1]) {
          translate([0, l2, 0]) {
            cube_center_x(size=[bulkhead_w - arm_pad_holder_thickness * 2,
                                arm_pad_thickness + arm_pad_clearance,
                                arm_pad_hook_h + 1]);
          }
        }
        translate([0,
                   -l2 - upper_holder_mount_thickness + upper_holder_hole_depth,
                   0]) {
          rotate([90, 0, 0]) {
            translate([0, shock_tower_mount_offset + common_pin_y, 0]) {
              mirror_copy([1, 0, 0]) {
                translate([upper_holder_bolt_spacing / 2,
                           - upper_holder_bore_d / 2 - upper_holder_bore_y_offset,
                           0]) {
                  counterbore(d=upper_holder_bolt_d,
                              h=upper_holder_mount_thickness + upper_holder_hole_depth,
                              reverse=true,
                              sink=true);
                }
              }
            }
          }
        }
      }

      translate([0, -l2, 0]) {
        front_bulkhead_mount_hinges();
        front_bulkhead_mount_hinges(rear=true);
      }
    }

    translate([0, shock_tower_mount_thickness, 0]) {
      rotate([90, 0, 0]) {
        front_bulkhead_shock_tower_mount(color=color,
                                         shock_tower_color=shock_tower_color,
                                         show_tower=show_shock_tower,
                                         bulkhead_w=bulkhead_w,
                                         mount_offset=shock_tower_mount_offset,
                                         thickness=shock_tower_mount_thickness,
                                         tower_mount_corner_r=tower_mount_corner_r,
                                         shock_tower_bolt_spacing=shock_tower_bolt_spacing,
                                         shock_tower_bolt_d=shock_tower_bolt_d,
                                         shock_tower_pad_y=shock_tower_pad_y,
                                         pad_y_top=shock_tower_mount_pad_y_top,
                                         pad_x=shock_tower_mount_pad_x);
      }
    }

    if (show_suspension_arm_pad) {
      translate([0,
                 l2,
                 -bulkhead_housing_h]) {
        rotate([90, 0, 180]) {
          suspension_arm_pad();
        }
      }
    }

    if (show_upper_suspension_holder) {
      translate([0,
                 upper_suspension_holder_y,
                 shock_tower_mount_offset + common_pin_y]) {
        rotate([90, 0, 180]) {
          front_upper_suspension_holder();
        }
      }
    }
    if (show_front_upper_arm) {
      mirror_copy([1, 0, 0]) {
        translate([front_bulkhead_pin_spacing / 2
                   - pin_d / 2
                   - front_upper_arm_hinge_barrel_hole_offset,
                   shock_tower_mount_thickness - front_upper_arm_h,
                   shock_tower_mount_offset + front_upper_arm_thickness / 2]) {

          upper_arm(show_ball_stud=show_upper_arm_ball_stud);
        }
      }
    }
    if (show_front_upper_arm_pin) {
      mirror_copy([1, 0, 0]) {
        translate([-front_bulkhead_pin_spacing / 2,
                   upper_suspension_holder_y,
                   shock_tower_mount_offset
                   + common_pin_y
                   + arm_pin_d / 2
                   + (pin_d - arm_pin_d) / 2]) {
          rotate([-90, 0, 0]) {
            suspension_arm_pin(d=arm_pin_d, l=arm_pin_l);
          }
        }
      }
    }
  }
}

module front_bulkhead_shock_tower_mount(color=cobalt_blue_metallic,
                                        shock_tower_color=cobalt_blue_metallic,
                                        show_tower=false,
                                        bulkhead_w=front_bulkhead_w,
                                        thickness=front_bulkhead_shock_tower_mount_thickness,
                                        tower_mount_corner_r=front_bulkhead_shock_tower_mount_corner_r,
                                        shock_tower_bolt_spacing=front_shock_tower_bolt_spacing,
                                        shock_tower_bolt_d=front_shock_tower_bolt_d,
                                        mount_offset=front_bulkhead_shock_tower_mount_offset,
                                        pad_y_top=front_bulkhead_shock_tower_mount_pad_y_top,
                                        shock_tower_pad_y=front_shock_tower_damper_holes_pad_y,
                                        pad_x=front_bulkhead_shock_tower_mount_pad_x) {

  shock_mount_size_x = shock_tower_bolt_spacing[0]
    + shock_tower_bolt_d
    + pad_x * 2;

  shock_mount_size_y = shock_tower_bolt_spacing[1]
    + shock_tower_bolt_d
    + shock_tower_pad_y * 2;

  maybe_color(color) {
    translate([0,
               shock_mount_size_y / 2 + mount_offset,
               0]) {
      linear_extrude(height=thickness,
                     center=false) {
        difference() {
          union() {
            rounded_rect([shock_mount_size_x, shock_mount_size_y],
                         center=true,
                         side="top",
                         r=tower_mount_corner_r,
                         fn=$preview ? 40 : 300);
            translate([-shock_mount_size_x / 2, -shock_mount_size_y / 2, 0]) {
              rounded_rect([shock_mount_size_x, shock_mount_size_y + pad_y_top],
                           center=false,
                           side="top",
                           r=tower_mount_corner_r,
                           fn=$preview ? 40 : 300);
            }
            translate([0,
                       -mount_offset / 2
                       -shock_mount_size_y / 2,
                       0]) {
              trapezoid(b=bulkhead_w,
                        t=shock_mount_size_x,
                        h=mount_offset,
                        center=true);
            }
          }
          four_corner_holes_2d(size=shock_tower_bolt_spacing,
                               d=shock_tower_bolt_d,
                               center=true);
        }
      }
    }
  }
  if (show_tower) {
    translate([0, mount_offset, 0]) {
      rotate([0, 180, 0]) {
        front_shock_tower(color=shock_tower_color);
      }
    }
  }
}

module front_bulkhead_mount_hinges(bolt_d=front_bulkhead_mount_bolt_d,
                                   pad_x=2,
                                   pad_y=1.5,
                                   padding=front_bulkhead_mount_bolt_padding,
                                   outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                   inner_spacing=front_bulkhead_mount_bolt_spacing_2,
                                   d=front_bulkhead_mount_bolt_d,
                                   h=front_bulkhead_hinge_thickness,
                                   padding=front_bulkhead_mount_bolt_padding,
                                   rear=false,
                                   barrel_y_offset=front_bulkhead_barrel_y_offset,
                                   hinge_clearance=front_bulkhead_barrel_hinge_clearance) {
  barrel_size = lower_arm_mount_cutout_size();
  barrel_len = barrel_size[1] - hinge_clearance;

  bolt_spacing_max_y = max(front_bulkhead_mount_bolt_spacing_1[1],
                           front_bulkhead_mount_bolt_spacing_2[1]);

  full_bolt_spacing_y = bolt_spacing_max_y + front_bulkhead_mount_bolt_d;
  x = outer_spacing[0] + bolt_d + pad_x * 2;

  y = bolt_d + pad_y * 2;

  module _hinge() {
    translate([x / 2 - (x - $full_x), 0, 0]) {
      rounded_rect([x, y], center=true, r_factor=0.5, fn=$preview ? 30 : 200);
    }
  }

  translate([0,
             front_bulkhead_len / 2
             - full_bolt_spacing_y
             - barrel_y_offset
             - barrel_len / 2 + full_bolt_spacing_y / 2
             + front_bulkhead_len / 2,
             0]) {
    difference() {
      linear_extrude(height=h, center=false) {
        front_bulkhead_chassis_with_slots_positions(outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                                    inner_spacing=front_bulkhead_mount_bolt_spacing_2,
                                                    d=front_bulkhead_mount_bolt_d,
                                                    padding=front_bulkhead_mount_bolt_padding,
                                                    center_x=true,
                                                    center_y=false) {

          if ($x_i == 0) {
            if (($outer && !rear && $y_i == 1)) {
              _hinge();
            } else if (rear && !$outer && $y_i == 0) {
              _hinge();
            }
          }
        }
      }

      front_bulkhead_chassis_with_slots_positions(outer_spacing=outer_spacing,
                                                  inner_spacing=inner_spacing,
                                                  d=d,
                                                  padding=padding,
                                                  center_x=true,
                                                  center_y=false) {
        counterbore(d=d, h=h, sink=true);
      }
    }
  }
}

front_bulkhead();
