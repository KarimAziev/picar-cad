
/**
 * Module: Power Control Lid
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
include <../power_lid_parameters.scad>

use <power_case_rail.scad>
use <../placeholders/lipo_pack.scad>
use <../slider.scad>
use <../placeholders/toggle_switch.scad>
use <../placeholders/atc_ato_blade_fuse_holder.scad>;
use <../placeholders/step-down-voltage-d24vxf5.scad>
use <../placeholders/voltmeter.scad>
use <../wire.scad>
use <../lib/functions.scad>
use <../lib/shapes3d.scad>
use <../lib/holes.scad>
use <../lib/placement.scad>
use <../lib/transforms.scad>
use <../lib/shapes2d.scad>
use <../placeholders/bolt.scad>
use <../placeholders/xt90e-m.scad>
use <../core/slot_layout.scad>
use <../lib/plist.scad>
use <../core/slot_layout_components.scad>

show_xt90e            = false;
show_dc_regulator     = false;
show_ato_fuse         = false;
show_voltmeter        = false;
show_bolt             = false;
show_atm_fuse_holders = false;
show_perf_board       = false;

/* [Power lid switch button] */
use_toggle_switch     = false;
show_switch_button    = true;

bolt_visible_h        = power_lid_thickness + 4;

side_wall_w           = power_case_side_wall_thickness
  + power_case_rail_tolerance
  + power_lid_extra_side_thickness;

inner_y_cutout        = power_case_length - side_wall_w * 2;
inner_x_cutout        = power_lid_width - side_wall_w * 2;

half_of_inner_y       = inner_y_cutout / 2;
half_of_inner_x       = inner_x_cutout / 2;
half_of_side_wall_w   = side_wall_w / 2;

tumbler_side_cutout_h = side_wall_w + 0.2;
side_bolt_start       = power_case_length / 2
  - power_case_rail_bolt_dia / 2
  - power_case_rail_hole_distance_from_edge;

module power_lid_side_wall_slots(specs=power_lid_side_slots,
                                 slot_mode=true,
                                 direction="btt") {
  total_size = get_total_size(specs, direction=direction);
  max_xlen = total_size[0];
  y_len = total_size[1];
  mirror_copy([1, 0, 0]) {
    translate([half_of_inner_x,
               -y_len / 2,
               power_lid_thickness + max_xlen / 2]) {
      rotate([0, 90, 0]) {
        slot_layout_components(specs=specs,
                               thickness=side_wall_w,
                               align_to_axle=0,
                               direction=direction,
                               use_children=!slot_mode);
      }
    }
  }
}

module power_case_lid_bolt_holes_pair() {
  mirror_copy([0, 1, 0]) {
    translate([0,
               side_bolt_start,
               0]) {
      rotate([0, 90, 0]) {
        counterbore(d=power_case_rail_bolt_dia,
                    h=side_wall_w + 1,
                    bore_h=power_lid_thickness / 2,
                    bore_d=power_case_rail_bolt_dia * 1.5,
                    center=true,
                    sink=false);
      }
    }
  }
}

module power_lid_side_bolt_holes() {

  union() {
    mirror_copy([1, 0, 0]) {
      translate([half_of_inner_x
                 + half_of_side_wall_w,
                 0,
                 power_lid_height
                 - power_case_rail_bolt_dia]) {
        power_case_lid_bolt_holes_pair();
      }
    }
  }
}

module power_lid(show_switch_button=show_switch_button,
                 show_dc_regulator=show_dc_regulator,
                 lid_color=blue_grey_carbon,
                 show_ato_fuse=show_ato_fuse,
                 show_voltmeter=show_voltmeter,
                 show_bolt=show_bolt,
                 show_xt90e=show_xt90e,
                 show_perf_board=show_perf_board,
                 show_atm_fuse_holders=show_atm_fuse_holders,
                 left_columns = power_lid_left_slots,
                 right_columns = power_lid_right_slots) {

  difference() {
    union() {
      color(lid_color, alpha=1) {
        difference() {
          rounded_cube(size=[power_lid_width,
                             power_case_length,
                             power_lid_height],
                       center=true);

          translate([0, 0, 0]) {
            power_lid_side_wall_slots();
          }

          translate([0, 0, -1]) {
            cube_3d(size=[inner_x_cutout,
                          power_case_length + 1,
                          power_lid_height + 2]);
          }

          power_lid_side_bolt_holes();
        }
      }

      translate([0, 0, power_lid_thickness]) {
        rotate([180, 0, 0]) {
          power_lid_base(lid_color=lid_color,
                         show_switch_button=show_switch_button,
                         show_dc_regulator=show_dc_regulator,
                         show_perf_board=show_perf_board,
                         show_ato_fuse=show_ato_fuse,
                         show_bolt=show_bolt,
                         show_voltmeter=show_voltmeter,
                         show_xt90e=show_xt90e,
                         show_atm_fuse_holders=show_atm_fuse_holders,
                         left_columns=left_columns,
                         right_columns=right_columns);
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
  }
}

module power_lid_base(size=[inner_x_cutout,
                            power_case_length,
                            power_lid_thickness],
                      lid_color=blue_grey_carbon,
                      show_switch_button=false,
                      show_dc_regulator=show_dc_regulator,
                      show_ato_fuse=false,
                      show_voltmeter=false,
                      show_xt90e=false,
                      show_perf_board=show_perf_board,
                      show_atm_fuse_holders=false,
                      show_bolt=show_bolt,
                      left_columns=power_lid_left_slots,
                      right_columns=power_lid_right_slots) {

  w = size[0];
  l = size[1];
  thickness = size[2];

  difference() {
    union() {
      color(lid_color, alpha=1) {
        difference() {
          rounded_cube(size=[w, l, thickness]);
          power_lid_slots(left_columns=left_columns,
                          right_columns=right_columns);
        }
      }

      translate([0, 0, thickness]) {
        power_lid_slots(use_children=true,
                        left_columns=left_columns,
                        right_columns=right_columns,
                        show_switch_button=show_switch_button,
                        show_dc_regulator=show_dc_regulator,
                        show_bolt=show_bolt,
                        show_ato_fuse=show_ato_fuse,
                        show_voltmeter=show_voltmeter,
                        show_perf_board=show_perf_board,
                        show_xt90e=show_xt90e,
                        show_atm_fuse_holders=show_atm_fuse_holders);
      }
    }
  }
}

module power_lid_slots(left_columns,
                       right_columns,
                       debug=false,
                       use_children=false,
                       show_switch_button=false,
                       show_dc_regulator=show_dc_regulator,
                       show_ato_fuse=false,
                       show_voltmeter=show_voltmeter,
                       show_xt90e=false,
                       show_perf_board=show_perf_board,
                       show_atm_fuse_holders=false,
                       show_bolt=show_bolt,
                       thickness=power_lid_thickness) {

  union() {
    translate([0, half_of_inner_y, 0]) {
      translate([-half_of_inner_x, 0, 0]) {
        slot_layout_components(specs=left_columns,
                               thickness=thickness,
                               debug=debug,
                               align_to_axle=1,
                               use_children=use_children,
                               direction="ttb",
                               show_perf_board=show_perf_board,
                               bolt_visible_h=bolt_visible_h,
                               show_switch_button=show_switch_button,
                               show_dc_regulator=show_dc_regulator,
                               show_ato_fuse=show_ato_fuse,
                               show_voltmeter=show_voltmeter,
                               show_xt90e=show_xt90e,
                               show_bolt=show_bolt,
                               show_atm_fuse_holders=show_atm_fuse_holders);
      }

      translate([half_of_inner_x, 0, 0]) {
        slot_layout_components(specs=right_columns,
                               thickness=thickness,
                               debug=debug,
                               align_to_axle=-1,
                               use_children=use_children,
                               direction="ttb",
                               show_perf_board=show_perf_board,
                               bolt_visible_h=bolt_visible_h,
                               show_switch_button=show_switch_button,
                               show_dc_regulator=show_dc_regulator,
                               show_ato_fuse=show_ato_fuse,
                               show_voltmeter=show_voltmeter,
                               show_xt90e=show_xt90e,
                               show_bolt=show_bolt,
                               show_atm_fuse_holders=show_atm_fuse_holders);
      }
    }
  }
}

power_lid(show_switch_button=show_switch_button,
          show_dc_regulator=show_dc_regulator,
          show_ato_fuse=show_ato_fuse,
          show_voltmeter=show_voltmeter,
          show_bolt=show_bolt,
          show_xt90e=show_xt90e,
          show_atm_fuse_holders=show_atm_fuse_holders);
