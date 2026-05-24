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

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../lib/trapezoids.scad>
use <../../placeholders/bolt.scad>
use <../../placeholders/suspension_arm_pin.scad>
use <../bellcrank/bellcrank_drive.scad>
use <../bellcrank/bellcrank_idler.scad>
use <../bellcrank/util.scad>
use <../wishbone_arms/front_lower_arm.scad>
use <../wishbone_arms/front_upper_arm.scad>
use <../wishbone_arms/util.scad>
use <front_bulkhead_chassis.scad>
use <front_bulkhead_housing.scad>
use <front_shock_tower.scad>
use <front_upper_suspension_holder.scad>
use <suspension_arm_pad.scad>
use <util.scad>

show_front_shock_tower       = false;
show_upper_suspension_holder = false;
show_suspension_arm_pad      = false;
show_front_upper_arm         = false;
show_upper_arm_ball_stud     = false;
show_front_upper_arm_pin     = false;
show_front_upper_pin_e_clip  = false;

module front_bulkhead(color=cobalt_blue_light_1,
                      shock_tower_color=cobalt_blue_metallic,
                      show_upper_suspension_holder=show_upper_suspension_holder,
                      show_shock_tower=show_front_shock_tower,
                      show_suspension_arm_pad=show_suspension_arm_pad,
                      show_front_upper_arm=show_front_upper_arm,
                      show_upper_arm_ball_stud=show_upper_arm_ball_stud,
                      show_front_upper_arm_pin=show_front_upper_arm_pin,
                      show_front_upper_pin_e_clip=show_front_upper_pin_e_clip,
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
                      upper_holder_round_cutout_y_offset=front_upper_suspension_holder_round_cutout_offset,
                      pin_d=front_upper_arm_hinge_barrel_hole_d,
                      arm_pin_l=front_upper_arm_pin_len,
                      arm_pad_hook_h=front_suspension_arm_pad_hook_len_y,
                      arm_pad_thickness=front_suspension_arm_pad_thickness,
                      arm_pad_holder_thickness=front_bulkhead_suspension_pad_thickness,
                      arm_pad_clearance=front_bulkhead_suspension_pad_clearance,
                      extra_rear_len=front_bulkhead_extra_len,
                      groove_offset=0.85,
                      upper_bolt_d=upper_steering_panel_bolt_d,
                      upper_bolt_spacing=upper_steering_panel_bulkhead_spacing,
                      upper_bolt_boss_od=upper_steering_panel_boss_od,
                      upper_bolt_bore_h=upper_steering_panel_bulkhead_bore_h,
                      upper_bolt_bore_d=upper_steering_panel_bulkhead_bore_d,
                      shoulder_h=bellcrank_post_flang_h) {

  l2 = bulkhead_l / 2;

  // Common Y position for the upper arm hinge pin axis (relative to the shock tower reference)
  common_pin_y = tower_pin_hole_y_offset + pin_d / 2;

  // Thickness of the bulkhead “shelf” where the upper holder mounts
  upper_holder_mount_thickness = upper_holder_barrel_h - upper_holder_thickness;

  arm_pin_d = snap_bolt_d(pin_d);

  upper_suspension_holder_y = -l2 - upper_holder_barrel_h - extra_rear_len;

  bellcrank_z_end = bellcrank_idler_arm_z_end();

  rear_h = shock_tower_mount_offset + upper_holder_w - bellcrank_z_end;

  bulkhead_h = shock_tower_mount_offset + shock_tower_bolt_spacing[1];

  bellcrank_h = bellcrank_idler_full_mount_h() + shoulder_h;

  upper_panel_boss_h = bellcrank_h
    - bulkhead_housing_h
    - bellcrank_z_end
    - rear_h;

  upper_panel_hole_depth = bellcrank_h
    - bulkhead_housing_h
    - bellcrank_z_end;

  upper_suspension_holder_z_pos =
    front_bulkhead_upper_suspension_holder_z_pos(tower_pin_hole_y_offset=tower_pin_hole_y_offset,
                                                 shock_tower_mount_offset=shock_tower_mount_offset,
                                                 upper_holder_bore_y_offset=upper_holder_bore_y_offset,
                                                 pin_d=pin_d,
                                                 upper_holder_bore_d=upper_holder_bore_d,
                                                 upper_holder_bolt_d=upper_holder_bolt_d);
  upper_suspension_holes_z = upper_suspension_holder_z_pos[1];

  union() {
    maybe_color(color) {
      difference() {
        union() {
          translate([-bulkhead_w / 2, -l2, bulkhead_h]) {
            rotate([0, 90, 0]) {
              linear_extrude(height=bulkhead_w,
                             center=false) {
                rounded_rect([bulkhead_h,
                              bulkhead_l],
                             center=false,
                             side="left",
                             fn=$preview ? 6 : 360,
                             r_factor=0.5);
              }
            }
          }
          // fill gap between rear support and the main part
          translate([0, -l2, 0]) {
            cube_center_x(size=[bulkhead_w,
                                extra_rear_len,
                                shock_tower_mount_offset + upper_holder_w]);
          }

          // bosses for the upper steering panel
          let (fn = $preview ? 30 : 360) {
            translate([0, -l2, bellcrank_z_end + rear_h]) {
              cylinder(d=upper_bolt_boss_od,
                       h=upper_panel_boss_h,
                       $fn=fn);
              mirror_copy([1, 0, 0]) {
                translate([upper_bolt_spacing / 2, 0, 0]) {
                  cylinder(d=upper_bolt_boss_od,
                           h=upper_panel_boss_h,
                           $fn=fn);
                }
              }
            }
          }

          // front lower protrusion for the arm pad
          translate([0, l2, 0]) {
            cube_center_x(size=[bulkhead_w,
                                arm_pad_holder_thickness + arm_pad_thickness,
                                arm_pad_hook_h + arm_pad_holder_thickness]);
          }
          front_bulkhead_support(bulkhead_w=bulkhead_w,
                                 bulkhead_l=bulkhead_l,
                                 upper_holder_w=upper_holder_w,
                                 shock_tower_mount_offset=shock_tower_mount_offset,
                                 shock_tower_bolt_spacing=shock_tower_bolt_spacing,
                                 upper_holder_barrel_h=upper_holder_barrel_h,
                                 upper_holder_bore_d=upper_holder_bore_d,
                                 upper_holder_thickness=upper_holder_thickness,
                                 upper_holder_round_cutout_d=upper_holder_round_cutout_d,
                                 support_extra_len=support_extra_len,
                                 upper_holder_round_cutout_y_offset=upper_holder_round_cutout_y_offset,
                                 tower_pin_hole_y_offset=tower_pin_hole_y_offset,
                                 pin_d=pin_d,
                                 upper_holder_bore_y_offset=upper_holder_bore_y_offset,
                                 upper_holder_bolt_d=upper_holder_bolt_d,
                                 extra_rear_len=extra_rear_len);
        }
        // front lower cutout for the arm pad
        translate([0, -arm_pad_clearance / 2, -1]) {
          translate([0, l2, 0]) {
            cube_center_x(size=[bulkhead_w
                                - arm_pad_holder_thickness * 2,
                                arm_pad_thickness + arm_pad_clearance,
                                arm_pad_hook_h + 1]);
          }
        }

        // holes for the upper steering panel
        let (fn = $preview ? 20 : 360) {
          translate([0, -l2, bellcrank_z_end]) {
            counterbore(d=upper_bolt_d,
                        h=upper_panel_hole_depth,
                        bore_h=upper_bolt_bore_h,
                        bore_d=upper_bolt_bore_d,
                        fn=fn);
            mirror_copy([1, 0, 0]) {
              translate([upper_bolt_spacing / 2, 0, 0]) {
                counterbore(d=upper_bolt_d,
                            h=upper_panel_hole_depth,
                            bore_h=upper_bolt_bore_h,
                            bore_d=upper_bolt_bore_d,
                            fn=fn);
              }
            }
          }
        }

        // rear holes for the upper suspension holder
        translate([0, -l2 + upper_holder_hole_depth, 0]) {
          rotate([90, 0, 0]) {
            translate([0, upper_suspension_holes_z, 0]) {
              mirror_copy([1, 0, 0]) {
                translate([upper_holder_bolt_spacing / 2, 0, 0]) {
                  counterbore(d=upper_holder_bolt_d,
                              h=upper_holder_mount_thickness
                              + upper_holder_hole_depth
                              + extra_rear_len,
                              bore_d=front_bulkhead_counterbore_d,
                              bore_h=front_bulkhead_counterbore_h,
                              teardrop_angle=45,
                              reverse=false,
                              sink=false);
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

    translate([0, shock_tower_mount_thickness / 2, 0]) {
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
      translate([0, front_upper_arm_y_offset, 0]) {
        mirror_copy([1, 0, 0]) {
          translate([front_bulkhead_pin_spacing / 2
                     - pin_d / 2
                     - front_upper_arm_hinge_barrel_hole_offset,
                     shock_tower_mount_thickness / 2 - front_upper_arm_h,
                     shock_tower_mount_offset + front_upper_arm_thickness / 2]) {

            front_upper_arm(show_ball_stud=show_upper_arm_ball_stud);
          }
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
            suspension_arm_pin(d=arm_pin_d,
                               l=arm_pin_l,
                               show_e_clip=show_front_upper_pin_e_clip,
                               groove_offset=groove_offset,
                               groove_side="top");
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

  shock_mount_size_x = shock_tower_mount_size_x(bolt_d=shock_tower_bolt_d,
                                                pad_x=pad_x,
                                                bolt_spacing=shock_tower_bolt_spacing);
  shock_mount_size_y = shock_tower_mount_size_y(bolt_d=shock_tower_bolt_d,
                                                pad_y=shock_tower_pad_y,
                                                bolt_spacing=shock_tower_bolt_spacing);

  maybe_color(color) {
    translate([0, shock_mount_size_y / 2 + mount_offset, 0]) {
      linear_extrude(height=thickness,
                     center=false) {
        difference() {
          union() {
            translate([-shock_mount_size_x / 2, -shock_mount_size_y / 2, 0]) {
              rounded_rect([shock_mount_size_x, shock_mount_size_y + pad_y_top],
                           center=false,
                           side="top",
                           r=tower_mount_corner_r,
                           fn=$preview ? 40 : 300);
            }
            translate([0,
                       -mount_offset / 4
                       -shock_mount_size_y / 2,
                       0]) {
              trapezoid(b=bulkhead_w,
                        t=shock_mount_size_x,
                        h=mount_offset / 2,
                        center=true);
            }
          }
          four_corner_holes_2d(size=shock_tower_bolt_spacing,
                               d=shock_tower_bolt_d,
                               center=true) {
            teardrop_2d(d=shock_tower_bolt_d,
                        ang=45,
                        fn=$preview ? 40 : 300,
                        both_sides=true);
          }
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
                                   pad_x=front_bulkhead_mount_hinge_pad_x,
                                   pad_y=front_bulkhead_mount_hinge_pad_y,
                                   padding=front_bulkhead_mount_bolt_padding,
                                   outer_spacing=front_bulkhead_mount_bolt_spacing_1,
                                   inner_spacing=front_bulkhead_mount_bolt_spacing_2,
                                   d=front_bulkhead_mount_bolt_d,
                                   h=front_bulkhead_hinge_thickness,
                                   rear=false,
                                   barrel_y_offset=front_bulkhead_barrel_y_offset,
                                   hinge_clearance=front_bulkhead_barrel_hinge_clearance) {
  barrel_size = front_lower_arm_mount_cutout_size();
  barrel_len = barrel_size[1] - hinge_clearance;

  bolt_spacing_max_y = max(front_bulkhead_mount_bolt_spacing_1[1],
                           front_bulkhead_mount_bolt_spacing_2[1]);

  full_bolt_spacing_y = bolt_spacing_max_y + front_bulkhead_mount_bolt_d;
  x = outer_spacing[0] + bolt_d + pad_x * 2;

  y = bolt_d + pad_y * 2;

  module _hinge() {
    translate([-bolt_d / 2, 0, 0]) {
      rounded_rect([x, y],
                   center=true,
                   r_factor=0.5,
                   fn=$preview ? 30 : 200);
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
                                                    center_x=false,
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

module front_bulkhead_support(bulkhead_w=front_bulkhead_w,
                              bulkhead_l=front_bulkhead_len,
                              upper_holder_w=front_upper_suspension_w,
                              shock_tower_mount_offset=front_bulkhead_shock_tower_mount_offset,
                              shock_tower_bolt_spacing=front_shock_tower_bolt_spacing,
                              upper_holder_barrel_h=front_upper_suspension_holder_pin_barrel_h,
                              upper_holder_thickness=front_upper_suspension_holder_thickness,
                              upper_holder_bore_d=front_upper_suspension_holder_bolt_bore_d,
                              upper_holder_round_cutout_d=front_upper_suspension_holder_round_cutout_d,
                              support_extra_len=front_bulkhead_support_extra_len,
                              upper_holder_round_cutout_y_offset=front_upper_suspension_holder_round_cutout_offset,
                              tower_pin_hole_y_offset=front_shock_tower_pin_y_offset,
                              pin_d=front_upper_arm_hinge_barrel_hole_d,
                              upper_holder_bore_y_offset=front_upper_suspension_holder_bolt_y_offset,
                              upper_holder_bolt_d=front_upper_suspension_holder_bolt_d,
                              extra_rear_len=front_bulkhead_extra_len) {
  l2 = bulkhead_l / 2;

  upper_suspension_holder_z_pos =
    front_bulkhead_upper_suspension_holder_z_pos(tower_pin_hole_y_offset=tower_pin_hole_y_offset,
                                                 shock_tower_mount_offset=shock_tower_mount_offset,
                                                 upper_holder_bore_y_offset=upper_holder_bore_y_offset,
                                                 pin_d=pin_d,
                                                 upper_holder_bore_d=upper_holder_bore_d,
                                                 upper_holder_bolt_d=upper_holder_bolt_d);

  bellcrank_z_end = bellcrank_idler_arm_z_end();

  upper_holder_mount_thickness = upper_holder_barrel_h - upper_holder_thickness;
  z = shock_tower_bolt_spacing[1]
    + upper_holder_round_cutout_d / 2
    - upper_holder_bore_d / 2
    - upper_holder_round_cutout_y_offset;

  rear_h = shock_tower_mount_offset + upper_holder_w - bellcrank_z_end;
  min_rear_h = (upper_suspension_holder_z_pos[2] - upper_suspension_holder_z_pos[0]) + 0.5;
  holder_h = max(min_rear_h, rear_h);

  rear_l = extra_rear_len + upper_holder_mount_thickness;

  length = rear_l + support_extra_len;

  poly_h = 0.5;

  pts2 = [[0, 0],
          [0, bellcrank_z_end - front_bulkhead_housing_h],
          [rear_l, bellcrank_z_end - front_bulkhead_housing_h]];

  module _cyl() {
    rotate([90, 0, 0]) {
      hull() {
        difference() {
          cylinder(d=upper_holder_round_cutout_d,
                   h=length,
                   $fn=$preview ? 30 : 360);
          translate([0, -upper_holder_round_cutout_d, -0.5]) {
            cube_center_x([upper_holder_round_cutout_d,
                           upper_holder_round_cutout_d,
                           length + 1]);
          }
        }
        translate([0, -upper_holder_round_cutout_d / 2, -0.5]) {
          cube_center_x([poly_h,
                         upper_holder_round_cutout_d / 2,
                         poly_h]);
        }
      }
    }
  }

  union() {
    hull() {
      translate([0, -l2, 0]) {
        translate([0, 0, shock_tower_mount_offset + upper_holder_w]) {
          cuboid(size=[bulkhead_w,
                       rear_l,
                       holder_h],
                 anchor=[0, -1, -1]);
        }
        translate([0, 0, front_bulkhead_housing_h]) {
          rotate([90, 0, -90]) {
            linear_extrude(height=poly_h, center=true) {
              polygon(pts2);
            }
          }
        }
      }
    }
    translate([0, -l2, z]) {
      _cyl();
    }
  }
}

front_bulkhead();