/**
 * Module: Power Case
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../placeholders/lipo_pack.scad>
use <../slider.scad>
use <power_lid.scad>
use <power_case_rail.scad>
use <../lib/shapes3d.scad>
use <../lib/holes.scad>
use <../lib/placement.scad>
use <../lib/transforms.scad>
use <../placeholders/standoff.scad>

module power_case(case_color=metallic_silver_5, alpha=1) {
  inner_x_cutout = power_case_width - power_case_side_wall_thickness * 2;
  inner_y_cutout = power_case_length - power_case_front_wall_thickness * 2;
  inner_lipo_x_cutout = lipo_pack_width + 0.8;

  color(case_color, alpha=alpha) {
    difference() {
      union() {
        difference() {
          // Outer case
          union() {
            rounded_cube([power_case_width,
                          power_case_length,
                          power_case_height],
                         center=true,
                         r=power_case_round_rad);
            translate([0,
                       0,
                       power_case_round_rad / 2 +
                       power_case_height
                       - power_case_round_rad]) {
              cube([power_case_width,
                    power_case_length,
                    power_case_round_rad],
                   center=true);
            }
          }
          translate([0,
                     0,
                     power_case_bottom_thickness]) {
            // Cutout for the 4 corner mounting screw positions
            rounded_cube([inner_x_cutout,
                          power_case_bottom_screw_size[1]
                          + (power_case_bottom_cbore_dia * 2),
                          power_case_height],
                         center=true);

            // Cutout for LiPo pack
            translate([0, 0, power_case_height / 2]) {
              cube([inner_lipo_x_cutout,
                    inner_y_cutout,
                    power_case_height],
                   center=true);
            }
          }

          // Holes for 4 corner mounting screws
          translate([power_case_screw_size_offset_x, 0, -0.0]) {
            translate([0, power_case_screw_size_offset_y, 0]) {
              four_corner_children(size=power_case_bottom_screw_size,
                                   center=true) {
                counterbore(d=power_case_bottom_screw_dia,
                            h=power_case_bottom_thickness,
                            bore_h=power_case_bottom_cbore_h,
                            bore_d=power_case_bottom_cbore_dia,
                            center=false,
                            autoscale_step=0.1,
                            sink=false);
              }
            }
          }

          // Front and rear panels cutout
          translate([0,
                     0,
                     power_case_front_back_wall_h]) {
            rounded_cube([inner_x_cutout,
                          power_case_length + 1,
                          lipo_pack_height + 1],
                         center=true);
          }

          // Front and rear panels vent
          power_case_vent(panel_height=power_case_front_back_wall_h,
                          bottom_thickness=power_case_bottom_thickness,
                          padding_x=power_case_front_slot_padding_x,
                          padding_z=power_case_front_slot_padding_z,
                          slot_h=power_case_front_slot_h,
                          slot_w=power_case_front_slot_w,
                          slot_depth=power_case_front_wall_thickness,
                          gap_x=power_case_front_slot_gap,
                          gap_z=power_case_front_slot_gap_z,
                          y_axle=false,
                          x_offset=-power_case_length / 2,
                          total_width=power_case_width - power_case_side_wall_thickness * 2);

          // Side panels vent
          power_case_vent(panel_height=power_case_height,
                          bottom_thickness=power_case_bottom_thickness,
                          padding_x=power_case_side_slot_padding_x,
                          padding_z=power_case_side_slot_padding_z,
                          slot_h=power_case_side_slot_h,
                          slot_w=power_case_side_slot_w,
                          slot_depth=(power_case_width - inner_lipo_x_cutout)
                          / 2,
                          gap_x=power_case_side_slot_gap,
                          gap_z=power_case_side_slot_gap_z,
                          y_axle=true,
                          x_offset=inner_lipo_x_cutout / 2,
                          total_width=inner_y_cutout);
        }
        mirror_copy([1, 0, 0]) {
          translate([power_case_width / 2
                     - power_case_side_wall_thickness / 2,
                     0,
                     power_case_height]) {
            power_case_rail(w=power_case_side_wall_thickness,
                            l=power_case_length);
          }
        }
      }

      mirror_copy([0, 1, 0]) {
        mirror_copy([1, 0, 0]) {
          translate([power_case_width / 2
                     - power_case_side_wall_thickness / 2,
                     power_case_length / 2
                     - power_case_rabet_thickness
                     + power_case_rabet_w,
                     power_case_height - power_case_rabet_h]) {
            translate([0, 0, power_case_rabet_h / 2]) {
              cube([power_case_rabet_w,
                    power_case_rabet_thickness,
                    power_case_rabet_h],
                   center=true);
              translate([0, -power_case_rabet_thickness / 2
                         + power_case_rabet_w / 2,
                         -power_case_rail_height / 2]) {
                cube([power_case_rabet_w,
                      power_case_rabet_w,
                      power_case_rail_height],
                     center=true);
              }
            }
          }
        }
      }
    }
  }
}

module power_case_vent(panel_height,
                       bottom_thickness,
                       padding_x,
                       padding_z,
                       slot_h,
                       slot_w,
                       slot_depth,
                       gap_x,
                       gap_z,
                       y_axle,
                       x_offset,
                       total_width) {

  available_h = panel_height
    - bottom_thickness
    - padding_z;

  slot_z_step = gap_z + slot_h;
  slot_y_rows = floor(available_h / slot_z_step);
  for (i = [0 : slot_y_rows - 1]) {
    let (s = i * slot_z_step) {
      translate([0, 0, s]) {
        mirror_copy([y_axle ? 1 : 0, y_axle ? 0 : 1, 0]) {
          translate([y_axle ? x_offset - 0.1 : 0,
                     y_axle ? 0 : x_offset - 0.1,
                     bottom_thickness
                     + padding_z]) {
            rotate([0, 0, y_axle ? -90 : 0]) {
              row_of_cubes(total_width -
                           (padding_x * 2),
                           center=true,
                           spacing=gap_x,
                           y_center=false,
                           starts=[0, 0],
                           size=[slot_w,
                                 slot_depth + 0.2,
                                 slot_h]);
            }
          }
        }
      }
    }
  }
}

module power_case_assembly(alpha=1,
                           standoff_h=power_case_standoff_h,
                           standoff_thread_h=power_case_standoff_thread_h,
                           show_lipo_pack=true,
                           show_lid=true,
                           show_standoffs=true,
                           case_color=metallic_silver_5,
                           slot_mode=false,
                           bolt_visible_h=chassis_thickness
                           - chassis_counterbore_h) {
  // Placeholder for LiPo pack

  if (slot_mode) {
    translate([power_case_screw_size_offset_x,
               power_case_screw_size_offset_y, 0]) {

      four_corner_children(power_case_bottom_screw_size,
                           center=true) {
        counterbore(d=power_case_bottom_screw_dia,
                    h=chassis_thickness,
                    bore_h=chassis_counterbore_h,
                    bore_d=power_case_bottom_cbore_dia,
                    autoscale_step=0.1,
                    sink=false,
                    reverse=false);
      }
    }
  } else {
    translate([0, 0, show_standoffs ? standoff_h + bolt_visible_h
               + chassis_counterbore_h : 0]) {
      if (show_lipo_pack) {
        translate([0, 0, power_case_bottom_thickness + 0.1]) {
          lipo_pack();
        }
      }

      if (show_lid) {
        translate([0, 0, power_case_height + power_lid_height + 0]) {
          rotate([180, 0, 0]) {

            power_lid(lid_color=case_color);
          }
        }
      }

      union() {
        // Power case
        power_case(case_color=case_color, alpha=alpha);
        if (show_standoffs) {
          translate([power_case_screw_size_offset_x, power_case_screw_size_offset_y, 0]) {

            four_corner_children(size=power_case_bottom_screw_size,
                                 center=true) {
              translate([0, 0, -(standoff_h + standoff_thread_h) + standoff_thread_h]) {
                standoff(body_h=standoff_h,
                         thread_at_top=true,
                         show_bolt=true,
                         bolt_visible_h=bolt_visible_h,
                         thread_h=standoff_thread_h);
              }
            }
          }
        }
      }
    }
  }
}

power_case_assembly(show_lipo_pack=false,
                    alpha=1,
                    show_lid=false,
                    show_standoffs=true,
                    slot_mode=false,
                    case_color=blue_grey_carbon);
