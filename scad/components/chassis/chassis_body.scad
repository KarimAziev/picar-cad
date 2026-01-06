/**
 * Module: Main body, that houses motors, batteries and electronics.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../parameters.scad>
include <../../colors.scad>

use <../../core/slot_layout.scad>
use <../../core/slot_layout_components.scad>
use <../../core/slot_placeholder_grid.scad>

use <../../lib/functions.scad>
use <../../lib/shapes2d.scad>
use <../../lib/holes.scad>
use <../../lib/trapezoids.scad>
use <../../lib/placement.scad>
use <../../lib/transforms.scad>
use <../../lib/debug.scad>
use <../../lib/shapes3d.scad>
use <../../lib/plist.scad>
use <../../lib/slots.scad>

use <../../placeholders/rpi_5.scad>
use <../../placeholders/ups_hat.scad>
use <../../placeholders/motor.scad>
use <../../placeholders/battery_holder/battery_holder.scad>
use <../../placeholders/bolt.scad>

use <../../motor_brackets/standard_motor_bracket.scad>
use <../../motor_brackets/n20_motor_bracket.scad>

use <../../panel_stack/fuse_panel.scad>
use <../../panel_stack/control_panel.scad>
use <../../panel_stack/panel_stack.scad>

use <../../power/power_lid.scad>
use <../../power/power_case.scad>

use <../../wheels/rear_wheel.scad>

use <../rear_panel.scad>

use <upper_chassis.scad>
use <chassis_connector.scad>

show_motor                        = false;
show_motor_brackets               = false;
show_wheels                       = false;
show_xt90e                        = false;
show_rear_panel                   = false;
show_buttons_panel                = false;
show_fuse_panel                   = false;
show_buttons                      = false;
show_fusers                       = false;
show_rear_panel_buttons           = false;
show_battery_holders              = false;
show_ups_hat                      = false;
show_power_case                   = false;
show_power_case_lid               = false;
show_lid_dc_regulator             = false;
show_lid_ato_fuse                 = false;
show_lid_voltmeter                = false;
show_lid_atm_fuse_holders         = false;
show_lid_perf_board               = false;
show_lipo_pack                    = false;

show_batteries                    = false;
show_socket_case                  = false;
show_socket_case_atm_fuse_holders = false;
show_socket_case_lid              = false;
show_socket                       = false;

/* [Raspberry PI] */
show_rpi                          = false;
show_ai_hat                       = false;
show_motor_driver_hat             = false;
show_servo_driver_hat             = false;
show_gpio_expansion_board         = false;

rpi_position_x                    = -rpi_bolt_spacing[0] / 2 + rpi_chassis_x_position;

rpi_position_y                    = -rpi_len - rpi_chassis_y_position;

power_case_position_y             = -power_case_length / 2 - power_case_chassis_y_offset;
power_case_position_x             = chassis_body_w / 2
  - power_case_width / 2
  + power_case_chassis_x_offset;

max_lower_cutout                  = max([for (v = chassis_lower_cutout_pts) v[1]]);

body_pts                          = concat(chassis_lower_cutout_pts,
                                           [[chassis_body_half_w, chassis_body_len +
                                             max_lower_cutout],
                                            [0, chassis_body_len  + max_lower_cutout]]);

function ups_hat_y_pos() = -chassis_body_len
  + battery_ups_module_bolt_spacing[1] / 2
  + max_lower_cutout
  + battery_ups_offset;

module chassis_body_2d() {
  offset_vertices_2d(r=chassis_offset_rad) {
    mirror_copy([1, 0, 0]) {
      polygon(body_pts);
    }
  }
}
function raspberry_pi_y_positions() =
  let (basic_y = (rpi_bolt_spacing[1]) / 2 + rpi_bolts_offset,
       end = -chassis_body_len + rpi_chassis_y_position - basic_y,
       start = end + rpi_len)
  [start, end];

function motor_bracket_y_pos() =
  (-chassis_body_len + standard_motor_bracket_width * 0.5)
  + standard_motor_bracket_y_offset;

function motor_bracket_x_pos() =
  (chassis_body_w * 0.5) - (standard_motor_bracket_height * 0.5);

module chassis_body(size, slots_and_placeholders, assembly) {
  union() {
    difference() {
      cube(size=size);
      make_slots(size=size, slots=slots_and_placeholders, mode="slots");
    }
    if (assembly) {
      make_slots(size=size, slots=slots_and_placeholders, mode="placeholder");
    }
  }
}
module standard_motor_bracket_wall(show_motor=false, show_wheel=false) {
  translate([motor_bracket_x_pos(),
             motor_bracket_y_pos(),
             chassis_thickness]) {
    rotate([0, 0, 90]) {
      standard_motor_bracket(show_motor=show_motor, show_wheel=show_wheel);
    }
  }
}
module standard_motor_bracket_bolts(extra_x=0, extra_y=0) {
  translate([motor_bracket_x_pos() + extra_x,
             motor_bracket_y_pos() + extra_y,
             0]) {
    four_corner_counterbores(size=standard_motor_bracket_bolt_spacing,
                             center=true,
                             h=chassis_thickness,
                             d=standard_motor_bracket_chassis_bolt_hole);
  }
}

module n20_bracket_left(show_motor=false, show_wheel=false) {
  x = -(chassis_body_w * 0.5) - n20_motor_chassis_x_distance;
  y = -chassis_body_len + n20_motor_bolts_panel_len / 2
    + n20_motor_chassis_y_distance;
  z = n20_motor_bolts_panel_x_offset() +
    chassis_thickness + n20_motor_bolts_panel_thickness();
  translate([x,
             y,
             z]) {
    rotate([0, 90, 0]) {
      n20_motor_assembly(show_motor=show_motor, show_wheel=show_wheel);
    }
  }
}
module chassis_with_panel_stack_position() {
  translate([-chassis_body_half_w + chassis_panel_stack_x_offset,
             -chassis_body_len + chassis_panel_stack_y_offset,
             0]) {
    children();
  }
}

module n20_bracket_bolts() {
  pan_len = n20_motor_bolts_panel_len;
  x = -chassis_body_w * 0.5 - n20_motor_chassis_x_distance + n20_can_height / 2;
  y = -chassis_body_len + pan_len / 2 + n20_motor_chassis_y_distance;

  translate([x, y, 0]) {
    rotate([0, 0, 90]) {
      n20_motor_bolt_holes_3d(h=chassis_thickness,
                              bore_h=n20_motor_bolt_bore_h,
                              reverse=false);
    }
  }
}

module chassis_body_border_slots(groups, center_group=true, center=true) {
  for (specs=groups) {
    rounded_rect_slots(specs=specs,
                       center=center_group,
                       thickness=chassis_thickness + 0.1) {
      let (spec = $spec,
           size = spec[0]) {

        translate([center ? 0 : size[0] / 2,
                   center ? 0 : size[1] / 2,
                   chassis_thickness]) {

          difference() {
            linear_extrude(height=chassis_side_hole_border_h,
                           center=false) {
              rounded_rect(size=[size[0] + chassis_side_hole_border_w * 2,
                                 size[1]
                                 + chassis_side_hole_border_w * 2],
                           r=size[2],
                           center=true);
            }
            translate([0, 0, -0.5]) {
              linear_extrude(height=chassis_side_hole_border_h + 1,
                             center=false) {
                rounded_rect(size=[size[0], size[1]],
                             r=
                             size[2],
                             center=true);
              }
            }
          }
        }
      }
    }
  }
}

module chassis_body_3d(panel_color="white") {
  union() {
    difference() {
      color(panel_color, alpha=1) {

        union() {
          translate([0, -chassis_body_len - max_lower_cutout, 0]) {
            linear_extrude(height=chassis_thickness, center=false) {
              difference() {
                chassis_body_2d();
              }
            }
          }
          translate([0, -chassis_offset_rad / 2, 0]) {
            cube_3d(size=[chassis_body_w,
                          chassis_offset_rad,
                          chassis_thickness]);
          }
        }
      }
      if (chassis_use_connector) {
        chassis_connector_groove();
      }

      mirror_copy([1, 0, 0]) {
        if (motor_type == "n20") {
          n20_bracket_bolts();
        }

        if (motor_type == "standard") {
          standard_motor_bracket_bolts();
        }
      }

      chassis_with_panel_stack_position() {
        panel_stack_bolt_holes(center=false,
                               y_axle=chassis_panel_stack_orientation
                               == "vertical");
      }

      translate([-chassis_body_w / 2, 0, 0]) {
        slot_or_placeholder_grid(mode="slot",
                                 thickness=chassis_thickness,
                                 debug_spec=["border_h", chassis_thickness + 1],
                                 grid=chassis_body_battery_holders_specs,
                                 debug=false);
      }

      translate([rpi_position_x, rpi_position_y, 0]) {
        rpi_5(slot_mode=true);
      }

      translate([power_case_position_x, power_case_position_y, 0]) {
        power_case_assembly(slot_mode=true);
      }

      chassis_with_panel_stack_position() {
        let (bolt_spacing = panel_stack_bolt_spacing(),
             size_i = chassis_panel_stack_orientation == "vertical" ? 0 : 1) {

          translate([max(panel_stack_bolt_cbore_dia,
                         panel_stack_bolt_dia)
                     + bolt_spacing[size_i] / 2,
                     0,
                     -0.05]) {
            for (specs=chassis_panel_stack_slot_specs) {
              rounded_rect_slots(specs=specs,
                                 center=false,
                                 thickness=chassis_thickness + 0.1);
            }
          }
        }
      }

      translate([0, -chassis_upper_len, -0.05]) {
        for (specs=chassis_rect_holes_specs) {
          rounded_rect_slots(specs=specs,
                             center=true,
                             thickness=chassis_thickness + 0.1);
        }
        for (specs=chassis_single_holes_specs) {
          counterbore_single_slots_by_specs(specs=specs,
                                            cfactor=0,
                                            thickness=chassis_thickness);
        }
      }
    }

    chassis_with_panel_stack_position() {
      let (bolt_spacing = panel_stack_bolt_spacing(),
           size_i = chassis_panel_stack_orientation == "vertical" ? 0 : 1) {

        translate([max(panel_stack_bolt_cbore_dia,
                       panel_stack_bolt_dia)
                   + bolt_spacing[size_i] / 2,
                   0,
                   -0.05]) {
          chassis_body_border_slots(groups=chassis_panel_stack_slot_specs,
                                    center_group=false,
                                    center=false);
        }
      }
    }

    if (battery_ups_holes_enabled) {
      translate([0, ups_hat_y_pos(), 0]) {
        four_corner_counterbores(size=battery_ups_module_bolt_spacing,
                                 center=true,
                                 h=chassis_thickness,
                                 d=battery_ups_bolt_dia);
      }
    }
    translate([0, -chassis_upper_len, -0.05]) {
      chassis_body_border_slots(groups=chassis_rect_holes_specs);
    }
  }
}

module chassis_body(panel_color="white",
                    power_case_color="lightgrey",
                    show_xt90e=show_xt90e,
                    motor_type=motor_type,
                    show_motor=show_motor,
                    show_motor_brackets=show_motor_brackets,
                    show_wheels=show_wheels,
                    show_rear_panel=show_rear_panel,
                    show_buttons_panel=show_buttons_panel,
                    show_fuse_panel=show_fuse_panel,
                    show_buttons=show_buttons,
                    show_fusers=show_fusers,
                    show_rear_panel_buttons=show_rear_panel_buttons,
                    show_battery_holders=show_battery_holders,
                    show_ups_hat=show_ups_hat,
                    show_power_case=show_power_case,
                    show_power_case_lid=show_power_case_lid,
                    show_lipo_pack=show_lipo_pack,
                    show_socket_case=show_socket_case,
                    show_socket=show_socket,
                    show_socket_case_lid=show_socket_case_lid,
                    show_socket_case_atm_fuse_holders=show_socket_case_atm_fuse_holders,
                    show_rpi=show_rpi,
                    show_ai_hat=show_ai_hat,
                    show_motor_driver_hat=show_motor_driver_hat,
                    show_servo_driver_hat=show_servo_driver_hat,
                    show_gpio_expansion_board=show_gpio_expansion_board,
                    show_lid_dc_regulator=show_lid_dc_regulator,
                    show_lid_ato_fuse=show_lid_ato_fuse,
                    show_lid_voltmeter=show_lid_voltmeter,
                    show_lid_atm_fuse_holders=show_lid_atm_fuse_holders,
                    show_lid_perf_board=show_lid_perf_board) {
  chassis_body_3d(panel_color=panel_color);
  if (show_buttons_panel || show_fuse_panel) {
    translate([0, 0, chassis_thickness / 2]) {
      chassis_with_panel_stack_position() {
        panel_stack(center=false,
                    y_axle=chassis_panel_stack_orientation == "vertical",
                    show_fusers=show_fusers,
                    show_buttons=show_buttons);
      }
    }
  }

  if (show_rpi) {
    translate([rpi_position_x, rpi_position_y, 0]) {
      rpi_5(slot_mode=false,
            show_standoffs=true,
            standoff_height=rpi_standoff_height,
            show_ai_hat=show_ai_hat,
            show_motor_driver_hat=show_motor_driver_hat,
            show_servo_driver_hat=show_servo_driver_hat,
            show_gpio_expansion_board=show_gpio_expansion_board);
    }
  }

  if (show_battery_holders) {
    translate([-chassis_body_w / 2, 0, 0]) {
      slot_or_placeholder_grid(mode="placeholder",
                               thickness=chassis_thickness,
                               debug_spec=["border_h", chassis_thickness + 1],
                               grid=chassis_body_battery_holders_specs,
                               debug=false);
    }
  }

  rotate([0, 180, 0]) {
    translate([0, 0, -chassis_thickness]) {
      if (show_rear_panel) {
        translate([0,
                   -chassis_body_len - max_lower_cutout,
                   rear_panel_size[1] / 2
                   + rear_panel_mount_thickness
                   + chassis_thickness]) {
          rotate([90, 0, 180]) {
            rear_panel(show_switch_button=show_rear_panel_buttons,
                       colr=panel_color);
          }
        }
      }

      if ((show_motor || show_motor_brackets) && motor_type == "standard") {
        mirror_copy([1, 0, 0]) {
          standard_motor_bracket_wall(show_motor=show_motor,
                                      show_wheel=show_wheels);
        }
      }

      if ((show_motor || show_motor_brackets) && motor_type == "n20") {
        mirror_copy([1, 0, 0]) {
          n20_bracket_left(show_motor=show_motor, show_wheel=show_wheels);
        }
      }
    }
  }

  if (show_power_case || show_socket_case) {
    translate([power_case_position_x,
               power_case_position_y,
               -chassis_counterbore_h]) {
      power_case_assembly(case_color=power_case_color,
                          show_lipo_pack=show_lipo_pack,
                          show_standoffs=true,
                          show_lid=show_power_case_lid,
                          show_lid_xt90e=show_xt90e,
                          show_socket_case=show_socket_case,
                          show_socket_case_atm_fuse_holders=show_socket_case_atm_fuse_holders,
                          show_socket_case_lid=show_socket_case_lid,
                          show_socket=show_socket,
                          show_lid_dc_regulator=show_lid_dc_regulator,
                          show_lid_ato_fuse=show_lid_ato_fuse,
                          show_lid_voltmeter=show_lid_voltmeter,
                          show_atm_fuse_holders=show_lid_atm_fuse_holders,
                          show_perf_board=show_lid_perf_board);
    }
  }
  if (show_ups_hat) {
    translate([0, ups_hat_y_pos(), 0]) {
      ups_hat();
    }
  }
}

union() {
  chassis_body();
}
