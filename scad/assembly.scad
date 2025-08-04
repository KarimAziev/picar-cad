/**
 * Module: Assembly view.
 *
 * The module shows the complete 3D assembled model for demonstration purposes.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <parameters.scad>
use <placeholders/ups_hat.scad>
use <head/head_assembly.scad>
use <head/head_mount.scad>
use <head/head_neck_mount.scad>
use <chassis.scad>
use <steering_system/rack_and_pinion_assembly.scad>
use <placeholders/motor.scad>
use <steering_system/knuckle_shaft.scad>
use <placeholders/rpi_5.scad>
use <wheels/rear_wheel.scad>
use <placeholders/battery_holder.scad>
use <motor_brackets/n20_motor_bracket.scad>

batteries_holder_assembly_y_idx = len(baterry_holes_y_positions) / 2 + 1;

chassis_assembly_center         = true;
show_motor                      = true;
show_motor_brackets             = true;
show_wheels                     = true;
show_rear_panel                 = true;
show_front_panel                = true;
show_ackermann_triangle         = false;
show_ups_hat                    = true;
show_steering                   = true;
show_bearing                    = true;
show_brackets                   = true;
show_battery_holders            = true;
show_rpi                        = true;
show_head                       = true;
chassis_color                   = "white";

module chassis_assembly(center=false,
                        show_rpi=true,
                        motor_type=motor_type,
                        show_motor=false,
                        show_wheels=false,
                        show_rear_panel=false,
                        show_front_panel=false,
                        show_ackermann_triangle=false,
                        show_ups_hat=false,
                        show_steering=false,
                        show_bearing=true,
                        show_brackets=true,
                        show_battery_holders=false,
                        show_motor_brackets=false,
                        chassis_color="white") {
  global_x_offset = chassis_width / 2 + (front_wheel_offset() * 2);
  global_z_offset = chassis_thickness +
    n20_motor_screws_panel_x_offset()
    + n20_motor_screws_panel_thickness()
    + wheel_dia  / 2 + tire_thickness + (tire_fillet_gap * 2);
  translate([center ? 0 : global_x_offset,
             0,
             global_z_offset]) {

    children();

    if (show_steering) {
      translate([0,
                 steering_panel_y_pos_from_center,
                 rack_mount_panel_thickness / 2]) {
        steering_system_assembly(show_wheels=show_wheels,
                                 show_bearing=show_bearing,
                                 show_brackets=show_brackets);
      }
    }

    if (show_rpi) {
      standow_lower_h = chassis_thickness + 1;
      y = (raspberry_pi5_screws_size[1]) / 2 + rpi_5_screws_offset();
      end = -chassis_len / 2 + raspberry_pi_offset - y;

      z = chassis_thickness + rpi_standoff_height - standow_lower_h;
      translate([-rpi_width / 2,
                 end,
                 z]) {
        rpi_5(show_standoffs=true, standoff_height=rpi_standoff_height,
              standoff_lower_height=standow_lower_h);
      }
    }
    if (show_ups_hat) {
      rotate([0, 0, 0]) {
        translate([-ups_hat_size[0] / 2,
                   ups_hat_y_pos() + -ups_hat_size[1] / 2,
                   0]) {
          rotate([0, 0, 0]) {
            translate([0, 0, 0]) {
              ups_hat();
            }
          }
        }
      }
    }

    rotate([0, 180, 0]) {
      if (show_battery_holders && len(baterry_holes_y_positions) > 0) {
        batteries_holder_assembly_y_idx = batteries_holder_assembly_y_idx;
        battery_holder_y_pos = is_undef(baterry_holes_y_positions
                                        [batteries_holder_assembly_y_idx])
          ? baterry_holes_y_positions[batteries_holder_assembly_y_idx - 1]
          : baterry_holes_y_positions[batteries_holder_assembly_y_idx];
        full_holder_len = battery_holder_full_len(battery_holder_thickness)
          * battery_holder_batteries_count;
        full_holder_width = battery_holder_full_width(battery_holder_thickness)
          * battery_holder_batteries_count;
        half_of_holder_len = full_holder_len / 2;
        half_of_holder_width = full_holder_width / 2;

        translate([0, battery_holder_y_pos, chassis_thickness]) {
          translate([battery_screws_x_offset - half_of_holder_width,
                     battery_holder_y_pos - half_of_holder_len,
                     0]) {
            battery_holder();
          }

          if (battery_holder_batteries_count <= 2) {
            translate([- battery_screws_x_offset
                       - battery_screws_x_offset,
                       battery_holder_y_pos - half_of_holder_len,
                       0]) {
              battery_holder();
            }
          }
        }
      }
      chassis(motor_type=motor_type,
              show_motor=show_motor,
              show_motor_brackets=show_motor_brackets,
              show_wheels=show_wheels,
              show_rear_panel=show_rear_panel,
              show_front_panel=show_front_panel,
              show_ackermann_triangle=show_ackermann_triangle,
              show_rpi=show_rpi,
              chassis_color=chassis_color);
    }
  }
}

module assembly_view(center=chassis_assembly_center,
                     motor_type=motor_type,
                     show_motor=show_motor,
                     show_wheels=show_wheels,
                     show_rear_panel=show_rear_panel,
                     show_front_panel=show_front_panel,
                     show_ackermann_triangle=show_ackermann_triangle,
                     show_ups_hat=show_ups_hat,
                     show_steering=show_steering,
                     show_bearing=show_bearing,
                     show_brackets=show_bearing,
                     show_battery_holders=show_battery_holders,
                     show_rpi=show_rpi,
                     show_head=show_head,
                     show_motor_brackets=show_motor_brackets,
                     chassis_color=chassis_color) {

  union() {
    chassis_assembly(motor_type=motor_type,
                     show_motor=show_motor,
                     show_wheels=show_wheels,
                     chassis_color=chassis_color,
                     show_motor_brackets=show_motor_brackets,
                     show_ups_hat=show_ups_hat,
                     show_rear_panel=show_rear_panel,
                     show_front_panel=show_front_panel,
                     show_ackermann_triangle=show_ackermann_triangle,
                     show_rpi=show_rpi,
                     show_steering=show_steering,
                     show_bearing=show_bearing,
                     show_brackets=show_brackets,
                     show_battery_holders=show_battery_holders,
                     center=center) {
      if (show_head) {
        translate([0, steering_panel_y_pos_from_center
                   + pan_servo_y_offset_from_steering_panel,
                   chassis_thickness]) {
          translate([-2, 0, 25.9]) {
            rotate([0, 0, 180]) {
              head_assembly();
            }
          }
        }
      }
    }
  }
}

assembly_view(center=chassis_assembly_center,
              motor_type=motor_type,
              show_motor=show_motor,
              show_wheels=show_wheels,
              show_rear_panel=show_rear_panel,
              show_front_panel=show_front_panel,
              show_ackermann_triangle=show_ackermann_triangle,
              show_ups_hat=show_ups_hat,
              show_steering=show_steering,
              show_bearing=show_bearing,
              show_brackets=show_bearing,
              show_battery_holders=show_battery_holders,
              show_rpi=show_rpi,
              show_head=show_head);