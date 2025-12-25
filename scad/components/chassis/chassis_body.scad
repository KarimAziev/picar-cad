/**
 * Module: Main body, that houses motors, batteries and electronics.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../parameters.scad>
include <../../colors.scad>

use <../../lib/functions.scad>
use <../../lib/shapes2d.scad>
use <../../lib/holes.scad>
use <../../lib/trapezoids.scad>
use <../../lib/placement.scad>
use <../../lib/transforms.scad>
use <../../lib/debug.scad>
use <../../lib/shapes3d.scad>

use <../../placeholders/rpi_5.scad>
use <../../placeholders/battery_holder.scad>
use <../../placeholders/ups_hat.scad>
use <../../placeholders/motor.scad>
use <../../placeholders/smd_battery_holder.scad>
use <../../placeholders/bolt.scad>

use <../../rear_panel.scad>

use <../../motor_brackets/standard_motor_bracket.scad>
use <../../motor_brackets/n20_motor_bracket.scad>

use <../../panel_stack/fuse_panel.scad>
use <../../panel_stack/control_panel.scad>
use <../../panel_stack/panel_stack.scad>

use <../../wheels/rear_wheel.scad>

use <../../power/power_lid.scad>
use <../../power/power_case.scad>

use <upper_chassis.scad>
use <chassis_connector.scad>

show_motor               = true;
show_motor_brackets      = true;
show_wheels              = false;
show_xt90e               = false;
show_rear_panel          = false;
show_buttons_panel       = false;
show_fuse_panel          = false;
show_buttons             = false;
show_fusers              = false;
show_rear_panel_buttons  = false;
show_battery_holders     = false;
show_smd_battery_holders = true;
show_ups_hat             = false;
show_power_case          = false;
show_power_case_lid      = false;
show_lipo_pack           = false;
show_batteries           = false;
show_rpi                 = false;

rpi_position_x           = -rpi_bolt_spacing[0] / 2 + rpi_chassis_x_position;
rpi_position_y           = -rpi_len - rpi_chassis_y_position;

power_case_position_y    = -power_case_length / 2 - power_case_chassis_y_offset;
power_case_position_x    = chassis_body_w / 2
                            - power_case_width / 2
                            + power_case_chassis_x_offset;

max_lower_cutout         = max([for (v = chassis_lower_cutout_pts) v[1]]);

body_pts                 = concat(chassis_lower_cutout_pts,
                            [[chassis_body_half_w, chassis_body_len +
                            max_lower_cutout],
                            [0, chassis_body_len  + max_lower_cutout]]);

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

module ups_hat_bolts_2d() {
  four_corner_holes_2d(size=battery_ups_module_bolt_spacing,
                       center=true,
                       hole_dia=battery_ups_bolt_dia);
}

module standard_battery_holders_bolts_2d(x_offst=battery_bolts_x_offset) {
  battery_holders_bolts(x_offst=x_offst,
                        y_positions=battery_holes_y_positions,
                        d=battery_holder_bolt_dia,
                        size=battery_holder_bolt_holes_size,
                        fn=battery_bolts_fn_val);
}

module battery_holders_bolts(x_offst,
                             y_positions,
                             d,
                             size,
                             fn=battery_bolts_fn_val) {
  union() {
    for (y = y_positions) {
      mirror_copy([1, 0, 0]) {
        translate([-x_offst, y, 0]) {
          if ($children) {
            children();
          } else {
            four_corner_holes_2d(size = size,
                                 center = true,
                                 hole_dia = d,
                                 fn = fn);
          }
        }
      }
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
        n20_bracket_bolts();

        // standard_motor_bracket_bolts();
      }

      chassis_with_panel_stack_position() {
        panel_stack_bolt_holes(center=false,
                               y_axle=chassis_panel_stack_orientation
                               == "vertical");
      }

      for (specs = smd_battery_holder_chassis_specs) {
        translate([0, -smd_battery_holder_length, 0]) {
          rotate([0, 0, 0]) {
            four_corner_hole_rows(specs,
                                  thickness=chassis_thickness,
                                  default_bore_dia_factor=1,
                                  default_bore_h_factor=0.1,
                                  sink=true,
                                  center=true);
          }
        }
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
    translate([0, -chassis_upper_len, -0.05]) {
      chassis_body_border_slots(groups=chassis_rect_holes_specs);
    }
  }
}
function ups_hat_y_pos() = -chassis_len / 2
  + battery_ups_module_bolt_spacing[1] / 2
  + max_lower_cutout
  + m3_hole_dia / 2 + battery_ups_offset;

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
                    show_smd_battery_holders=show_smd_battery_holders,
                    show_ups_hat=show_ups_hat,
                    show_power_case=show_power_case,
                    show_power_case_lid=show_power_case_lid,
                    show_lipo_pack=show_lipo_pack,
                    show_batteries=show_batteries,
                    show_rpi=show_rpi) {
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
            standoff_height=rpi_standoff_height);
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

      if (show_battery_holders && len(battery_holes_y_positions) > 0) {
        batteries_holder_assembly_y_idx = batteries_holder_assembly_y_idx;
        battery_holder_y_pos = is_undef(battery_holes_y_positions
                                        [batteries_holder_assembly_y_idx])
                                        ? battery_holes_y_positions[batteries_holder_assembly_y_idx - 1]
          : battery_holes_y_positions[batteries_holder_assembly_y_idx];
        full_holder_len = battery_holder_full_len(battery_holder_thickness)
          * battery_holder_batteries_count;
        full_holder_width = battery_holder_full_width(battery_holder_thickness)
          * battery_holder_batteries_count;
        half_of_holder_len = full_holder_len / 2;
        half_of_holder_width = full_holder_width / 2;

        translate([0, battery_holder_y_pos, chassis_thickness]) {
          translate([battery_bolts_x_offset - half_of_holder_width,
                     battery_holder_y_pos - half_of_holder_len,
                     0]) {
            battery_holder();
          }

          if (battery_holder_batteries_count <= 2) {
            translate([- battery_bolts_x_offset
                       - battery_bolts_x_offset,
                       battery_holder_y_pos - half_of_holder_len,
                       0]) {
              battery_holder(show_battery=show_batteries);
            }
          }
        }
      }
    }
  }

  if (show_smd_battery_holders) {
    translate([0, 0, chassis_thickness]) {
      for (specs = smd_battery_holder_chassis_specs) {
        let (width = smd_battery_holder_calc_full_w(smd_battery_holder_inner_thickness,
                                                    smd_battery_holder_batteries_count)) {

          translate([0, -smd_battery_holder_length, 0]) {
            rotate([0, 0, 0]) {

              four_corner_hole_rows(specs=specs,
                                    thickness=chassis_thickness,
                                    default_bore_dia_factor=1,
                                    default_bore_h_factor=0,
                                    sink=true,
                                    center=false) {

                translate([0, 0, -chassis_thickness + 0.1]) {
                  rotate([180, 0, 0]) {
                    smd_battery_holder(show_battery=show_batteries);
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  if (show_power_case) {
    translate([power_case_position_x,
               power_case_position_y,
               -chassis_counterbore_h]) {
      power_case_assembly(case_color=power_case_color,
                          show_lipo_pack=show_lipo_pack,
                          show_lid=show_power_case_lid,
                          show_xt90e=show_xt90e);
    }
  }
  if (show_ups_hat) {
    translate([-battery_ups_size[0] / 2,
               ups_hat_y_pos() + -battery_ups_size[1] / 2,
               0]) {
      ups_hat();
    }
  }
}

union() {
  chassis_body();
}