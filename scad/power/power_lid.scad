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

module power_lid_voltmeters_screw_holes() {
  for (volt_spec=power_voltmeter_specs) {
    let (v_spec = volt_spec[0],
         positions = volt_spec[1],
         screw_size = v_spec[0],
         screw_dia = v_spec[1],
         board_size = v_spec[2],
         standoff_spec=v_spec[6],
         board_w=board_size[0],
         board_len=board_size[1],
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
                        pins_len=pins_len,
                        pin_thickness=pin_thickness,
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

module power_lid_side_wall_circular_slots(specs=power_lid_side_wall_1_circle_holes,
                                          cfactor=1.5) {
  for (specs=specs) {
    let (heights = map_idx(specs, 0, 0),
         max_h = max(heights) * cfactor) {
      translate([0, 0, max_h / 2]) {
        rotate([0, 90, 0]) {
          counterbore_single_slots_by_specs(specs=specs,
                                            cfactor=cfactor,
                                            thickness=side_wall_w);
        }
      }
    }
  }
}

module power_lid_single_side_wall_slots(circular_specs=power_lid_side_wall_1_circle_holes,
                                        atm_fuse_specs=power_lid_side_wall_1_atm_fuse_specs,
                                        slot_mode=true) {
  union() {
    translate([half_of_inner_x,
               power_lid_toggle_switch_size[0] - half_of_inner_y,
               power_lid_thickness]) {

      if (slot_mode) {
        power_lid_side_wall_circular_slots(specs=circular_specs);
      }

      power_lid_atm_fuse_placeholders(specs=atm_fuse_specs,
                                      slot_mode=slot_mode);
    }
  }
}

module power_lid_side_wall_slots(slot_mode=true) {
  union() {
    power_lid_single_side_wall_slots(circular_specs=power_lid_side_wall_1_circle_holes,
                                     atm_fuse_specs=power_lid_side_wall_1_atm_fuse_specs,
                                     slot_mode=slot_mode);
    mirror([1, 0, 0]) {
      power_lid_single_side_wall_slots(circular_specs=power_lid_side_wall_2_circle_holes,
                                       atm_fuse_specs=power_lid_side_wall_2_atm_fuse_specs,
                                       slot_mode=slot_mode);
    }
  }
}

module power_lid_atm_fuse_placeholders(specs=power_lid_side_wall_1_atm_fuse_specs,
                                       thickness=side_wall_w,
                                       slot_mode=true) {

  for (specs=specs) {
    let (sizes = map_idx(specs, 0, [0, 0]),
         cbore_sizes = map_idx(specs, 2, [0, 0]),
         heights = map_idx(sizes, 0, 0),
         cbore_heigts = map_idx(cbore_sizes, 0, 0),
         max_h = max(concat(cbore_heigts, heights)),) {

      translate([-0.1, 0, max_h / 2 + power_lid_thickness]) {
        if (slot_mode) {
          rounded_rect_slots(specs=specs,
                             thickness=thickness + 0.2,
                             rotation=[0, 90, 0],
                             center=true);
        } else {
          rounded_rect_slots(specs=specs,
                             thickness=thickness + 0.2,
                             center=true,
                             rotation=[0, 0, -90]) {

            let (spec = $spec,
                 mounting_hole_raw_spec = spec[0],
                 cbore_spec = spec[2],
                 reversed = cbore_spec[3],
                 body_spec = spec[3],
                 body_h = body_spec[3],
                 cbore_thickness=cbore_spec[2],
                 half_of_body_h = body_h / 2,
                 wire_spec=spec[7],
                 wire_d=wire_spec[0],
                 wire_points=wire_spec[1],
                 y_offset =  reversed ? half_of_body_h +
                 cbore_thickness
                 : -half_of_body_h + cbore_thickness) {

              translate([0, y_offset, -body_spec[2] / 2]) {
                rotate([0, 0, reversed ? 180 : 0]) {
                  atm_fuse_holder(show_lid=spec[4][5],
                                  show_body=body_spec[5],
                                  center=true,
                                  mounting_hole_spec=[mounting_hole_raw_spec[0],
                                                      mounting_hole_raw_spec[1],
                                                      mounting_hole_raw_spec[2],
                                                      mounting_hole_raw_spec[4],
                                                      mounting_hole_raw_spec[3]],
                                  body_spec=body_spec,
                                  lid_spec=spec[4],
                                  body_rib_spec=spec[5],
                                  wiring_d=wire_d,
                                  wire_points=wire_points,
                                  lid_rib_spec=spec[6]);
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
              counterbore_single_slots_by_specs(specs=specs,
                                                thickness=power_lid_thickness);
            }

            for (specs=power_lid_rect_screw_holes) {
              four_corner_hole_rows(specs=specs,
                                    thickness=power_lid_thickness);
            }
            for (specs=power_lid_cube_holes) {
              rounded_rect_slots(specs=specs,
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
        power_lid_side_wall_slots(slot_mode=false);
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

power_lid(show_dc_regulator=true,
          show_switch_button=true,
          show_voltmeter=true,
          show_ato_fuse=true,
          show_atm_side_fuse_holders=true);
