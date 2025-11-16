/**
 * Module: Power Control Lid
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>
use <power_case_rail.scad>
use <../placeholders/lipo_pack.scad>
use <../slider.scad>
use <../placeholders/toggle_switch.scad>
use <../placeholders/atc_ato_blade_fuse_holder.scad>;
use <../placeholders/step-down-voltage-d24vxf5.scad>
use <../placeholders/voltmeter.scad>
use <../wire.scad>
use <../placeholders/atm_fuse_holder.scad>

side_wall_w           = power_case_side_wall_thickness
  + power_case_rail_tolerance
  + power_lid_extra_side_thickness;

inner_y_cutout        = power_case_length - side_wall_w * 2;
inner_x_cutout        = power_lid_width - side_wall_w * 2;

half_of_inner_y       = inner_y_cutout / 2;
half_of_inner_x       = inner_x_cutout / 2;
half_of_side_wall_w   = side_wall_w / 2;

tumbler_side_cutout_h = side_wall_w + 0.2;
side_screw_start      = power_case_length / 2 -
  power_case_groove_edge_distance
  -power_case_groove_thickness / 2
  - power_case_rail_screw_dia / 2
  - power_case_rail_screw_groove_distance;

function fuse_center_y(specs, i) =
  let (y_sizes = map_idx(specs, 1, 0),
       y_spaces = map_idx(specs, 3, 0),
       prev_y_size = i > 0 ? sum(y_sizes, i) : 0,
       prev_y_space = i > 0 ? sum(y_spaces, i) : 0,
       spec = specs[i],
       y_offset = is_undef(spec[5]) ? 0 : spec[5])
  prev_y_size + prev_y_space + y_offset + spec[1] / 2;

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

module power_lid_rect_holes(specs, thickness) {
  y_sizes = map_idx(specs, 1, 0);
  y_spaces = map_idx(specs, 3, 0);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         prev_spec=i > 0 ? specs[i - 1] : undef,
         prev_y_size= i > 0 ? sum(y_sizes, i) : 0,
         prev_y_space=i > 0 ? sum(y_spaces, i) : 0,
         y = prev_y_size + prev_y_space,
         x = is_undef(spec[4]) ? 0 : spec[4],
         y_offset = is_undef(spec[5]) ? 0 : spec[5],
         extra_thickness = 1) {

      if (!is_undef(spec[6]) && !is_undef(spec[6][0])) {
        let (counterbore_spec=spec[6],
             w=is_undef(counterbore_spec[0])
             ? spec[0] * 1.4
             : counterbore_spec[0],
             l=is_undef(counterbore_spec[1])
             ? spec[1] * 1.4
             : counterbore_spec[1],
             z=is_undef(counterbore_spec[2])
             ? max(1, thickness / 2.2)
             : counterbore_spec[2],
             ztr = is_undef(counterbore_spec[3]) ? thickness - z - 0.1 : 0) {

          translate([x - w / 2 ,
                     y + y_offset - (l / 2 - spec[1] / 2),
                     ztr]) {
            linear_extrude(height=z + 0.2, center=false,
                           convexity=2) {
              rounded_rect(size=[w,
                                 l],
                           r=spec[2]);
            }
          }
        }
      }
      translate([x - spec[0] / 2, y + y_offset, -extra_thickness / 2]) {
        linear_extrude(height=thickness + extra_thickness,
                       center=false,
                       convexity=2) {
          rounded_rect(size=[spec[0], spec[1]], r=spec[2]);
        }
      }
    }
  }
}

module power_lid_side_rect_holes(specs, thickness) {
  y_sizes = map_idx(specs, 1, 0);
  y_spaces = map_idx(specs, 3, 0);

  for (i = [0 : len(specs) - 1]) {
    let (spec=specs[i],
         prev_spec=i > 0 ? specs[i - 1] : undef,
         prev_y_size= i > 0 ? sum(y_sizes, i) : 0,
         prev_y_space=i > 0 ? sum(y_spaces, i) : 0,
         y_center = fuse_center_y(specs, i),
         y = prev_y_size + prev_y_space,
         x = is_undef(spec[4]) ? 0 : spec[4],
         y_offset = is_undef(spec[5]) ? 0 : spec[5],
         extra_thickness = 1) {

      if (!is_undef(spec[6]) && !is_undef(spec[6][0])) {
        let (counterbore_spec=spec[6],
             w=is_undef(counterbore_spec[0])
             ? spec[0] * 1.4
             : counterbore_spec[0],
             l=is_undef(counterbore_spec[1])
             ? spec[1] * 1.4
             : counterbore_spec[1],
             z=is_undef(counterbore_spec[2])
             ? max(1, thickness / 2.2)
             : counterbore_spec[2],
             ztr = is_undef(counterbore_spec[3]) ? thickness - z - 0.1 : 0) {

          translate([x - w / 2 ,
                     y_center - (l / 2 - spec[1] / 2),
                     ztr]) {
            linear_extrude(height=z + 0.2, center=false,
                           convexity=2) {
              rounded_rect(size=[w,
                                 l],
                           r=spec[2]);
            }
          }
        }
      }
      translate([x - spec[0] / 2, y_center, -extra_thickness / 2]) {
        linear_extrude(height=thickness + extra_thickness,
                       center=false,
                       convexity=2) {
          rounded_rect(size=[spec[0], spec[1]], r=spec[2]);
        }
      }
    }
  }
}

module power_lid_counterbore_single_slots(specs, thickness, cfactor=1.5) {
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

module power_lid_voltmeters_screw_holes() {
  for (volt_spec=power_voltmeter_specs) {
    let (v_spec = volt_spec[0],
         positions = volt_spec[1],
         screw_size = v_spec[0],
         screw_dia = v_spec[1],
         board_size = v_spec[2],
         display_spec = v_spec[3],
         pins_spec = v_spec[4],
         wiring_spec = v_spec[5],
         standoff_spec=v_spec[6],
         board_w=board_size[0],
         board_len=board_size[1],
         board_h=board_size[2],
         standoff_body_d = standoff_spec[0]) {
      translate([positions[0], positions[1], 0]) {
        translate([half_of_inner_x - board_w / 2,
                   -half_of_inner_y +
                   max(board_len, screw_size[1]) / 2, 0]) {
          rotate([0, 0, is_undef(positions[3]) ? 0 : positions[3]]) {
            four_corner_children(size=screw_size) {
              translate([0, 0, -0.5]) {
                rotate([0, 0, 180]) {
                  counterbore(d=screw_dia,
                              h=power_lid_thickness + 1,
                              upper_d=standoff_body_d + 0.5);
                }
              }
            }
          }
        }
      }
    }
  }
}

module power_lid_voltmeters_placeholders(echo_wiring_len=true) {
  for (i = [0 : len(power_voltmeter_specs) - 1]) {
    let (v_spec = power_voltmeter_specs[i][0],
         positions = power_voltmeter_specs[i][1],
         screw_size = v_spec[0],
         screw_dia = v_spec[1],
         board_size = v_spec[2],
         display_spec = v_spec[3],
         pins_spec = v_spec[4],
         wiring_spec = v_spec[5],
         standoff_spec=v_spec[6],
         text_spec=v_spec[7],
         board_w=board_size[0],
         board_len=board_size[1],
         board_h=board_size[2],
         display_w=display_spec[0],
         display_len=display_spec[1],
         display_h=display_spec[2],
         display_top_h=display_spec[3],
         display_indicators_len=display_spec[4],
         standoff_body_d = standoff_spec[0],
         pins_count=pins_spec[0],
         pin_h=pins_spec[1],
         pin_thickness=pins_spec[2],
         pins_len=pins_spec[3],
         wiring_d=wiring_spec[0],
         wiring=wiring_spec[1],
         wiring_gap=wiring_spec[2],
         wiring_distance=wiring_spec[3],) {
      translate([positions[0], positions[1], -pin_h
                 - positions[2]]) {
        translate([half_of_inner_x - board_w / 2,
                   -half_of_inner_y +
                   max(board_len, screw_size[1]) / 2, 0]) {
          if (echo_wiring_len) {
            echo(str("total_wire_length for voltmeter ", str(i),
                     " (",
                     text_spec[0],
                     "): ",),
                 total_wire_length(concat([[0, 0, 0]],
                                          wiring)));
          }

          rotate([180, 0, is_undef(positions[3]) ? 0 : positions[3]]) {
            if (positions[4]) {
              voltmeter(show_standoffs=true,
                        snandoff_body_h=positions[2]
                        + pin_h,
                        standoff_body_d=standoff_body_d,
                        board_w=board_w,
                        board_len=board_len,
                        board_h=board_h,
                        screw_size=screw_size,
                        screw_dia=screw_dia,
                        display_w=display_w,
                        display_len=display_len,
                        display_h=display_h,
                        display_indicators_len=display_indicators_len,
                        display_top_h=display_top_h,
                        pin_h=pin_h,
                        pins_len=voltmeter_pins_len,
                        pin_thickness=voltmeter_pin_thickness,
                        pins_count=pins_count,
                        wiring_d=wiring_d,
                        wiring=wiring,
                        wiring_gap=wiring_gap,
                        wiring_distance=wiring_distance,
                        text_spec=text_spec);
            }
          }
        }
      }
    }
  }
}

module power_lid_side_wall_circular_slots(cfactor=1.5) {
  for (specs=power_lid_side_wall_circle_holes) {
    let (heights = map_idx(specs, 0, 0),
         max_h = max(heights) * cfactor) {
      translate([0, 0, max_h / 2]) {
        rotate([0, 90, 0]) {
          power_lid_counterbore_single_slots(specs=specs,
                                             cfactor=cfactor,
                                             thickness=side_wall_w);
        }
      }
    }
  }
}

module power_lid_side_wall_slots() {
  union() {
    mirror_copy([1, 0, 0]) {
      translate([half_of_inner_x,
                 power_lid_toggle_switch_size[0] - half_of_inner_y,
                 power_lid_thickness]) {
        // power_lid_side_wall_circular_slots();
        power_lid_side_wall_atm_fuse_slots();
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
                                    thickness=side_wall_w);
        }
      }
    }
  }
}

module power_lid_atm_fuse_placeholders(show_lid=true) {
  for (specs=power_lid_side_wall_fuse_holes) {
    let (heights = map_idx(specs, 0, 0),
         max_h = max(heights),

         total_l = atm_fuse_holder_body_top_l * len(specs),
         max_l = max(map_idx(specs, 1, 0)),
         y_sizes =  map_idx(specs, 1, 0),
         y_spaces = map_idx(specs, 3, 0),) {
      translate([power_lid_width / 2
                 - atm_fuse_holder_body_h
                 - side_wall_w,
                 power_lid_thickness + max_h / 2
                 - atm_fuse_holder_body_h / 2]) {
        for (i = [0 : len(specs) - 1]) {
          let (spec=specs[i],
               l=atm_fuse_holder_body_top_l,
               z=atm_fuse_holder_body_w,
               y_center=fuse_center_y(specs, i),
               prev_spec=i > 0 ? specs[i - 1] : undef,
               prev_y_size= i > 0 ? sum(y_sizes, i) : 0,
               prev_y_space=i > 0 ? sum(y_spaces, i) : 0,
               y = prev_y_size + prev_y_space,
               x = is_undef(spec[4]) ? 0 : spec[4],

               y_offset = is_undef(spec[5]) ? 0 : spec[5]) {

            translate([0,
                       y_center,
                       -x]) {
              rotate([0, 0, -90]) {
                translate([atm_fuse_holder_body_bottom_l / 2,
                           atm_fuse_holder_body_h / 2,
                           0]) {
                  atm_fuse_holder(show_lid=show_lid, center=false);
                }
              }
            }
          }
        }
      }
    }
  }
}

module power_case_lid_screw_holes_pair() {
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

module power_lid_side_screw_holes() {

  union() {
    mirror_copy([1, 0, 0]) {
      translate([half_of_inner_x
                 + half_of_side_wall_w, 0,
                 power_lid_height
                 - power_case_rail_screw_dia]) {
        power_case_lid_screw_holes_pair();
      }
    }
    mirror_copy([1, 0, 0]) {
      translate([half_of_inner_x
                 + half_of_side_wall_w, 0,
                 + power_case_rail_screw_dia]) {
        power_case_lid_screw_holes_pair();
      }
    }
  }
}

module power_lid(show_switch_button=true,
                 show_dc_regulator=true,
                 lid_color=blue_grey_carbon,
                 show_ato_fuse=true,
                 show_voltmeter=true,
                 show_atm_side_fuse_holders=true,
                 echo_wiring_len=true) {

  difference() {
    union() {
      color(lid_color, alpha=1) {
        difference() {
          rounded_cube(size=[power_lid_width,
                             power_case_length,
                             power_lid_height],
                       center=true);

          translate([0, -half_of_inner_y, 0]) {
            for (specs=power_lid_single_holes_specs) {
              power_lid_counterbore_single_slots(specs=specs,
                                                 thickness=power_lid_thickness);
            }

            for (specs=power_lid_rect_screw_holes) {
              power_lid_bottom_four_corner_holes(specs=specs);
            }
            for (specs=power_lid_cube_holes) {
              power_lid_rect_holes(specs=specs,
                                   thickness=power_lid_thickness);
            }
          }

          power_lid_side_wall_slots();

          translate([0,
                     power_lid_toggle_switch_wall_thickness,
                     power_lid_thickness +
                     (power_lid_height / 2)]) {
            cube(size=[inner_x_cutout,
                       power_case_length + 1,
                       power_lid_height],
                 center=true);
          }

          power_lid_side_screw_holes();
        }
      }

      if (show_switch_button || show_dc_regulator) {
        translate([0,
                   -power_case_length / 2
                   + power_lid_toggle_switch_cbore_dia / 2
                   + power_lid_toggle_switch_wall_thickness
                   + power_lid_toggle_switch_distance_from_y
                   + toggle_switch_size[0] / 2,
                   toggle_switch_size[1] / 2
                   + max(power_lid_thickness, power_case_rail_height)
                   + power_lid_toggle_switch_distance_from_bottom]) {
          if (show_switch_button) {
            rotate([90, 0, 90]) {
              toggle_switch();
            }
          }
        }
      }

      if (show_voltmeter) {
        power_lid_voltmeters_placeholders(echo_wiring_len=echo_wiring_len);
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
      if (show_atm_side_fuse_holders) {
        power_lid_atm_fuse_placeholders(show_lid=false);
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

    power_lid_voltmeters_screw_holes();

    mirror_copy([1, 0, 0]) {
      translate([power_lid_width / 2 - tumbler_side_cutout_h,
                 -power_case_length / 2
                 + power_lid_toggle_switch_cbore_dia / 2
                 + power_lid_toggle_switch_wall_thickness
                 + power_lid_toggle_switch_distance_from_y
                 + toggle_switch_size[0] / 2,
                 power_lid_toggle_switch_cbore_dia / 2
                 + max(power_lid_thickness, power_case_rail_height)
                 + power_lid_toggle_switch_distance_from_bottom]) {
        rotate([90, 0, 90]) {
          counterbore(d=power_lid_toggle_switch_dia,
                      h=tumbler_side_cutout_h + 0.1,
                      upper_h=tumbler_side_cutout_h / 2,
                      upper_d=power_lid_toggle_switch_cbore_dia);
        }
      }
    }
  }
}

// power_lid_side_wall_atm_fuse_slots();
// power_lid_atm_fuse_placeholders();

power_lid(show_dc_regulator=false,
          show_switch_button=false,
          show_voltmeter=false,
          show_ato_fuse=false,
          show_atm_side_fuse_holders=true);

// power_lid_atm_fuse_placeholders(show_lid=false);
#power_lid_side_wall_slots();

rotate([0, 0, -90]) {
  translate([0,
             0,
             0]) {
    atm_fuse_holder(show_lid=false,
                    show_body=true,
                    center=true);
  }
}