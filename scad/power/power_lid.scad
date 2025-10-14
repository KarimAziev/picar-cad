/**
 * Module: Power Control Lid
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>;
use <power_case_rail.scad>
use <../placeholders/lipo_pack.scad>;
use <../slider.scad>
use <../placeholders/toggle_switch.scad>;

power_lid_side_holes_dia       = 8;
power_lid_side_holes_x_gap     = 10;
power_lid_side_holes_z_padding = 2;

dc_len                         = 40.6;
dc_w                           = 20;
dc_thickness                   = 1.8;

module power_lid_base() {
  rounded_cube(size=[power_lid_width,
                     power_lid_len,
                     power_lid_height],
               center=true);
}

module power_lid_bottom_rect_holes(specs) {
  y_sizes = map_idx(specs, 1, 0);
  dia_sizes = map_idx(specs, 2, 0);
  y_spaces = map_idx(specs, 3, 0);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         prev_spec=i > 0 ? specs[i - 1] : undef,
         dia=spec[2],
         prev_y_size= i > 0 ? sum(y_sizes, i) : 0,
         prev_y_space=i > 0 ? sum(y_spaces, i) : 0,
         prev_dias=i > 0 ? sum(dia_sizes, i) : 0,
         y = prev_y_size + prev_y_space + prev_dias,
         x = is_undef(spec[4]) ? 0 : spec[4],
         y_offset = is_undef(spec[5]) ? 0 : spec[5]) {

      translate([x - spec[0] / 2, y + y_offset, 0]) {
        four_corner_children(size=[spec[0], spec[1]],
                             center=false) {
          counterbore(d=dia,
                      h=power_lid_thickness
                      + 0.2,
                      upper_h=power_lid_thickness / 2,
                      upper_d=dia * 1.5,
                      center=false,
                      sink=false);
        }
      }
    }
  }
}

module power_lid_bottom_cube_holes(specs) {
  y_sizes = map_idx(specs, 1, 0);
  y_spaces = map_idx(specs, 3, 0);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         prev_spec=i > 0 ? specs[i - 1] : undef,
         prev_y_size= i > 0 ? sum(y_sizes, i) : 0,
         prev_y_space=i > 0 ? sum(y_spaces, i) : 0,
         y = prev_y_size + prev_y_space,
         x = is_undef(spec[4]) ? 0 : spec[4],
         y_offset = is_undef(spec[5]) ? 0 : spec[5]) {

      translate([x - spec[0] / 2, y + y_offset, -0.5]) {
        linear_extrude(height=power_lid_thickness + 1, center=false) {
          rounded_rect(size=[spec[0], spec[1]], r=spec[2]);
        }
      }
    }
  }
}

module power_lid_bottom_single_holes(specs) {
  dia_sizes = map_idx(specs, 0, 0);
  y_spaces = map_idx(specs, 1, 0);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         prev_spec=i > 0 ? specs[i - 1] : undef,
         dia=spec[0],
         prev_y_space=i > 0 ? sum(y_spaces, i) : 0,
         prev_dias=i > 0 ? sum(dia_sizes, i) : 0,
         y = prev_y_space + prev_dias,
         x = is_undef(spec[2]) ? 0 : spec[2],
         y_offset = is_undef(spec[3]) ? 0 : spec[3]) {

      translate([x, y + y_offset, 0]) {
        counterbore(d=dia,
                    h=power_lid_thickness
                    + 0.2,
                    upper_h=power_lid_thickness / 2,
                    upper_d=dia * 1.5,
                    center=false,
                    sink=false);
      }
    }
  }
}

module power_lid(show_switch_button=true, show_dc=true, lid_color=blue_grey_carbon) {
  side_wall_w = power_case_side_wall_thickness
    + power_case_rail_tolerance
    + power_lid_extra_side_thickness;

  inner_y_cutout = power_case_length - side_wall_w * 2;
  inner_x_cutout = power_lid_width - side_wall_w * 2;

  half_of_inner_y = inner_y_cutout / 2;
  half_of_inner_x = inner_x_cutout / 2;
  half_of_side_wall_w = side_wall_w / 2;

  tumbler_cutout_h = power_lid_tumbler_wall_thickness + 0.2;
  tumbler_side_cutout_h = side_wall_w + 0.2;
  side_screw_start = power_case_length / 2 -
    power_case_groove_edge_distance
    -power_case_groove_thickness / 2
    - power_case_rail_screw_dia / 2
    - power_case_rail_screw_groove_distance;

  union() {
    color(lid_color, alpha=1) {
      difference() {
        rounded_cube(size=[power_lid_width,
                           power_case_length,
                           power_lid_height],
                     center=true);

        translate([0, -half_of_inner_y, 0]) {
          for (specs=power_lid_single_holes_specs) {
            power_lid_bottom_single_holes(specs=specs);
          }

          for (specs=power_lid_rect_screw_holes) {
            power_lid_bottom_rect_holes(specs=specs);
          }
          for (specs=power_lid_cube_holes) {
            power_lid_bottom_cube_holes(specs=specs);
          }
        }

        translate([0, power_lid_tumbler_wall_thickness,
                   power_lid_thickness +
                   (power_lid_height / 2)]) {
          cube(size=[inner_x_cutout,
                     power_case_length,
                     power_lid_height],
               center=true);
        }

        translate([0,
                   -power_case_length / 2
                   + tumbler_cutout_h,
                   (power_lid_tumbler_dia * 1.2) / 2
                   + power_lid_thickness
                   + power_lid_tumbler_distance_from_bottom]) {
          rotate([90, 0, 0]) {
            counterbore(d=power_lid_tumbler_dia,
                        h=tumbler_cutout_h,
                        upper_h=tumbler_cutout_h / 2,
                        upper_d=power_lid_tumbler_cbore_dia);
          }
        }

        mirror_copy([1, 0, 0]) {
          translate([power_lid_width / 2 - tumbler_side_cutout_h,
                     -power_case_length / 2 + power_lid_tumbler_cbore_dia / 2
                     + power_lid_tumbler_wall_thickness
                     + toggle_switch_size[0] / 2,
                     (power_lid_tumbler_cbore_dia) / 2
                     + power_lid_thickness
// + power_lid_tumbler_distance_from_bottom
                    ]) {
            rotate([90, 0, 90]) {
              counterbore(d=power_lid_tumbler_dia,
                          h=tumbler_side_cutout_h,
                          upper_h=tumbler_side_cutout_h / 2,
                          upper_d=power_lid_tumbler_cbore_dia);
            }
          }
        }

        mirror_copy([1, 0, 0]) {
          translate([power_lid_width / 2
                     - half_of_side_wall_w,
                     0,
                     0]) {
            rotate([0, 0, 90]) {
              power_case_rail_relief_cutter();
            }
          }
        }

        mirror_copy([1, 0, 0]) {
          translate([power_lid_width / 2
                     - half_of_side_wall_w,
                     0,
                     power_lid_height
                     - power_case_rail_height]) {
            rotate([0, 0, 90]) {
              power_case_rail_relief_cutter();
            }
          }
        }
        mirror_copy([1, 0, 0]) {
          translate([half_of_inner_x
                     + half_of_side_wall_w, 0,
                     power_lid_height
                     - power_case_rail_screw_dia]) {
            mirror_copy([0, 1, 0]) {
              translate([0,
                         side_screw_start,
                         0]) {

                rotate([0, 90, 0]) {
                  counterbore(d=power_case_rail_screw_dia,
                              h=side_wall_w + 1,
                              upper_h=power_lid_thickness / 2,
                              upper_d=power_case_rail_screw_dia * 1.5,
                              center=true,
                              sink=false);
                }
              }
            }
          }
        }
        mirror_copy([1, 0, 0]) {
          translate([half_of_inner_x
                     + half_of_side_wall_w, 0,
                     + power_case_rail_screw_dia]) {
            mirror_copy([0, 1, 0]) {
              translate([0,
                         side_screw_start,
                         0]) {

                rotate([0, 90, 0]) {
                  counterbore(d=power_case_rail_screw_dia,
                              h=side_wall_w + 1,
                              upper_h=power_lid_thickness / 2,
                              upper_d=power_case_rail_screw_dia * 1.5,
                              center=true,
                              sink=false);
                }
              }
            }
          }
        }
        translate([0, 30, 0]) {
          mirror_copy([1, 0, 0]) {

            translate([half_of_inner_x - 1,
                       half_of_inner_y +
                       power_lid_side_holes_x_gap,
                       power_lid_side_holes_dia
                       / 2
                       + power_lid_thickness
                       + power_lid_side_holes_z_padding]) {
              rotate([0, 90, 0]) {
                linear_extrude(height=side_wall_w + 1, center=false) {
                  row_of_circles(total_width=inner_y_cutout,
                                 d = power_lid_side_holes_dia,
                                 spacing=power_lid_side_holes_x_gap,
                                 starts = [0, -inner_y_cutout],
                                 vertical=true,
                                 fn=360,
                                 direction=1);
                }
              }
            }
          }
        }
      }
    }

    if (show_switch_button || show_dc) {
      translate([0,
                 -power_case_length / 2 + power_lid_tumbler_cbore_dia / 2
                 + power_lid_tumbler_wall_thickness
                 + toggle_switch_size[0] / 2,
                 toggle_switch_size[1] / 2 + power_lid_thickness + 1.5]) {
        if (show_switch_button) {
          rotate([90, 0, 90]) {
            toggle_switch();
          }
        }
      }
    }
    if (show_dc) {
      translate([-half_of_inner_x, -half_of_inner_y + 10, 0]) {
        rotate([180, 0, 90]) {
          dc_dc();
        }
      }
    }
  }
}

module dc_dc() {
  color("green", alpha=1) {
    import("../placeholders/step-down-voltage-regulator-d24vxf5.stl");
  }
}

power_lid(show_dc=false, show_switch_button=false);
