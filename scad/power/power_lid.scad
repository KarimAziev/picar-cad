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
use <../placeholders/atc_ato_blade_fuse_holder.scad>;
use <../placeholders/step-down-voltage-d24vxf5.scad>;

module power_lid_base() {
  rounded_cube(size=[power_lid_width,
                     power_lid_len,
                     power_lid_height],
               center=true);
}

module power_lid_bottom_four_corner_holes(specs) {
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

module power_lid_bottom_cube_holes(specs, thickness) {
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
        linear_extrude(height=thickness + 1, center=false) {
          rounded_rect(size=[spec[0], spec[1]], r=spec[2]);
        }
      }
    }
  }
}

module power_lid_bottom_single_holes(specs, thickness, cfactor=1.5) {
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

      translate([x, y + y_offset, -0.1]) {
        counterbore(d=dia,
                    h=thickness
                    + 1,
                    upper_h=thickness / 2,
                    upper_d=dia * cfactor,
                    center=false,
                    sink=false);
      }
    }
  }
}

module power_lid(show_switch_button=true,
                 show_dc_regulator=true,
                 lid_color=blue_grey_carbon,
                 show_ato_fuse=true) {
  side_wall_w = power_case_side_wall_thickness
    + power_case_rail_tolerance
    + power_lid_extra_side_thickness;

  inner_y_cutout = power_case_length - side_wall_w * 2;
  inner_x_cutout = power_lid_width - side_wall_w * 2;

  half_of_inner_y = inner_y_cutout / 2;
  half_of_inner_x = inner_x_cutout / 2;
  half_of_side_wall_w = side_wall_w / 2;

  tumbler_cutout_h = power_lid_toggle_switch_wall_thickness + 0.2;
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
            power_lid_bottom_single_holes(specs=specs,
                                          thickness=power_lid_thickness);
          }

          for (specs=power_lid_rect_screw_holes) {
            power_lid_bottom_four_corner_holes(specs=specs);
          }
          for (specs=power_lid_cube_holes) {
            power_lid_bottom_cube_holes(specs=specs,
                                        thickness=power_lid_thickness);
          }

          mirror_copy([1, 0, 0]) {
            translate([half_of_inner_x,
                       power_lid_toggle_switch_size[0],
                       power_lid_thickness]) {
              for (specs=power_lid_side_wall_circle_holes) {
                heights = map_idx(specs, 0, 0);
                cfactor = 1.5;
                max_h = max(heights) * cfactor;

                translate([0, 0, max_h / 2]) {
                  rotate([0, 90, 0]) {
                    power_lid_bottom_single_holes(specs=specs,
                                                  cfactor=cfactor,
                                                  thickness=side_wall_w);
                  }
                }
              }
              for (specs=power_lid_side_wall_cube_holes) {
                heights = map_idx(specs, 0, 0);
                max_h = max(heights);
                translate([0, 0, max_h / 2]) {
                  rotate([0, 90, 0]) {
                    power_lid_bottom_cube_holes(specs=specs,
                                                thickness=side_wall_w);
                  }
                }
              }
            }
          }
        }

        translate([0, power_lid_toggle_switch_wall_thickness,
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
                   (power_lid_toggle_switch_dia * 1.2) / 2
                   + power_lid_thickness
                   + power_lid_toggle_switch_distance_from_bottom]) {
          rotate([90, 0, 0]) {
            counterbore(d=power_lid_toggle_switch_dia,
                        h=tumbler_cutout_h,
                        upper_h=tumbler_cutout_h / 2,
                        upper_d=power_lid_toggle_switch_cbore_dia);
          }
        }

        mirror_copy([1, 0, 0]) {
          translate([power_lid_width / 2 - tumbler_side_cutout_h,
                     -power_case_length / 2 + power_lid_toggle_switch_cbore_dia / 2
                     + power_lid_toggle_switch_wall_thickness
                     + toggle_switch_size[0] / 2,
                     (power_lid_toggle_switch_cbore_dia) / 2
                     + power_lid_thickness
// + power_lid_toggle_switch_distance_from_bottom
                    ]) {
            rotate([90, 0, 90]) {
              counterbore(d=power_lid_toggle_switch_dia,
                          h=tumbler_side_cutout_h,
                          upper_h=tumbler_side_cutout_h / 2,
                          upper_d=power_lid_toggle_switch_cbore_dia);
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
      }
    }

    if (show_switch_button || show_dc_regulator) {
      translate([0,
                 -power_case_length / 2 + power_lid_toggle_switch_cbore_dia / 2
                 + power_lid_toggle_switch_wall_thickness
                 + toggle_switch_size[0] / 2,
                 toggle_switch_size[1] / 2 + power_lid_thickness + 1.5]) {
        if (show_switch_button) {
          rotate([90, 0, 90]) {
            toggle_switch();
          }
        }
      }
    }
    if (show_dc_regulator) {
      translate([-half_of_inner_x
                 - power_lid_rect_screw_holes[0][0][4] +
                 power_lid_rect_screw_holes[0][0][2] / 2,
                 -half_of_inner_y + step_down_voltage_regulator_len / 2 +
                 power_lid_rect_screw_holes[0][0][5]
                 - power_lid_rect_screw_holes[0][0][2],
                 -step_down_voltage_regulator_standoff_h]) {
        rotate([180, 0, 90]) {
          step_down_voltage_regulator();
        }
      }
    }
    if (show_ato_fuse) {
      translate([half_of_inner_x - atc_ato_blade_full_w() / 2
                 - atc_ato_blade_mounting_wall_w / 2,
                 half_of_inner_y
                 - atc_ato_blade_fuse_y_distance,
                 atc_ato_blade_full_thickness() / 2
                 + power_lid_thickness]) {

        rotate([90, 0, 0]) {
          atc_ato_blade_fuse_holder();
        }
      }
    }
  }
}

power_lid(show_dc_regulator=true, show_switch_button=true, show_ato_fuse=true);
