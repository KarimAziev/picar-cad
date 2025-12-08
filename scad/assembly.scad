/**
 * Module: Assembly view.
 *
 * The module shows the complete 3D assembled model for demonstration purposes.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <parameters.scad>

include <colors.scad>
use <placeholders/ups_hat.scad>
use <placeholders/pan_servo.scad>
use <head/head_mount.scad>
use <head/head_neck.scad>
use <chassis.scad>
use <steering_system/rack_and_pinion_assembly.scad>
use <placeholders/motor.scad>
use <steering_system/knuckle_shaft.scad>
use <placeholders/rpi_5.scad>
use <wheels/rear_wheel.scad>
use <placeholders/battery_holder.scad>
use <motor_brackets/n20_motor_bracket.scad>
use <power/power_case.scad>

chassis_assembly_center         = true;
show_motor                      = true;
show_motor_brackets             = true;
show_wheels                     = true;
show_rear_panel                 = true;
show_rear_panel_buttons         = true;
show_front_panel                = true;
show_front_rear_panel           = true;
show_ultrasonic                 = true;
show_ups_hat                    = false;
show_power_case                 = true;
show_steering                   = true;
show_bearing                    = true;
show_brackets                   = true;
show_battery_holders            = true;
show_rpi                        = true;
show_head                       = true;
show_pan_servo                  = true;
show_tilt_servo                 = true;
show_camera                     = true;
show_ir_case                    = true;
show_ir_led                     = true;
chassis_color                   = "white";
head_color                      = chassis_color;
batteries_holder_assembly_y_idx = len(baterry_holes_y_positions) / 2 + 1;
show_ackermann_triangle         = false;

chassis_color_bottom            = "#353935";

function calc_chassis_z_offset() =
  let (motor_z_offset = motor_type == "n20"
       ? n20_motor_screws_panel_x_offset() + n20_motor_screws_panel_thickness()
       : standard_motor_bracket_height / 2)
  chassis_thickness
  + wheel_dia  / 2
  + wheel_tire_thickness
  + (wheel_tire_fillet_gap * 2)
  + motor_z_offset;

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
                        show_front_rear_panel=show_front_rear_panel,
                        show_rear_panel_buttons=show_rear_panel_buttons,
                        show_ultrasonic=show_ultrasonic,
                        chassis_color="white") {
  global_x_offset = chassis_width / 2 + (wheel_center_offset * 2);
  global_z_offset = calc_chassis_z_offset();

  translate([center
             ? 0
             : global_x_offset,
             0,
             global_z_offset]) {

    children();

    if (show_steering) {
      translate([0,

                 steering_panel_y_pos_from_center,
                 steering_rack_support_thickness / 2]) {
        steering_system_assembly(show_wheels=show_wheels,
                                 show_bearing=show_bearing,
                                 show_brackets=show_brackets,
                                 panel_color=chassis_color);
      }
    }

    if (show_rpi) {
      standow_lower_h = chassis_thickness + 1;
      y = (rpi_screws_size[1]) / 2 + rpi_screws_offset;
      end = -chassis_len / 2 + rpi_chassis_y_position - y;

      z = chassis_thickness + rpi_standoff_height - standow_lower_h;
      translate([-rpi_width / 2 - rpi_chassis_x_position,
                 end,
                 z]) {

        rpi_5(show_standoffs=true,
              standoff_height=rpi_standoff_height,
              standoff_lower_height=standow_lower_h);
      }
    }

    if (show_power_case) {
      translate([chassis_width / 2
                 - power_case_width / 2
                 - power_case_chassis_x_offset,
                 -chassis_len / 2
                 + power_case_length / 2
                 - power_case_chassis_y_offset,
                 0]) {

        power_case_assembly(case_color=matte_black);
      }
    }
    if (show_ups_hat) {
      translate([-battery_ups_size[0] / 2,
                 ups_hat_y_pos() + -battery_ups_size[1] / 2,
                 0]) {
        ups_hat();
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
              show_rear_panel_buttons=show_rear_panel_buttons,
              show_front_rear_panel=show_front_rear_panel,
              show_ultrasonic=show_ultrasonic,
              show_front_panel=show_front_panel,
              show_ackermann_triangle=show_ackermann_triangle,
              chassis_color=chassis_color,
              chassis_color_bottom=chassis_color_bottom,
              rotate_chassis=true);
    }
  }
}

module assembly_view(center=chassis_assembly_center,
                     motor_type=motor_type,
                     show_motor=show_motor,
                     show_wheels=show_wheels,
                     show_rear_panel=show_rear_panel,
                     show_rear_panel_buttons=show_rear_panel_buttons,
                     show_front_panel=show_front_panel,
                     show_ackermann_triangle=show_ackermann_triangle,
                     show_ups_hat=show_ups_hat,
                     show_steering=show_steering,
                     show_bearing=show_bearing,
                     show_brackets=show_bearing,
                     show_battery_holders=show_battery_holders,
                     show_rpi=show_rpi,
                     show_head=show_head,
                     show_tilt_servo=show_tilt_servo,
                     show_pan_servo=show_pan_servo,
                     show_motor_brackets=show_motor_brackets,
                     show_ir_led=show_ir_led,
                     show_ir_case=show_ir_case,
                     show_camera=show_camera,
                     chassis_color=chassis_color,
                     show_front_rear_panel=show_front_rear_panel,
                     show_ultrasonic=show_ultrasonic) {

  union() {

    chassis_assembly(motor_type=motor_type,
                     show_motor=show_motor,
                     show_wheels=show_wheels,
                     chassis_color=chassis_color,
                     show_motor_brackets=show_motor_brackets,
                     show_ups_hat=show_ups_hat,
                     show_rear_panel=show_rear_panel,
                     show_rear_panel_buttons=show_rear_panel_buttons,
                     show_front_panel=show_front_panel,
                     show_front_rear_panel=show_front_rear_panel,
                     show_ultrasonic=show_ultrasonic,
                     show_ackermann_triangle=show_ackermann_triangle,
                     show_rpi=show_rpi,
                     show_steering=show_steering,
                     show_bearing=show_bearing,
                     show_brackets=show_brackets,
                     show_battery_holders=show_battery_holders,

                     center=center) {
      if (show_head) {
        head_x = -head_neck_full_pan_panel_h() / 2
          - head_neck_tilt_servo_slot_thickness / 2;

        head_full_w = head_neck_full_w();
        slot_w = (head_full_w - pan_servo_size[0]) / 2;

        extra_head_y = head_neck_pan_servo_assembly_reversed
          ? -pan_servo_gearbox_d1 - pan_servo_gearbox_d2
          : -pan_servo_gearbox_d1 / 2;

        head_y = steering_panel_y_pos_from_center
          + chassis_pan_servo_y_distance_from_steering
          + head_full_w - slot_w + extra_head_y;

        head_z = chassis_thickness + pan_servo_gear_height() + servo_horn_h
          - chassis_pan_servo_slot_depth;

        translate([head_x,
                   head_y,
                   head_z]) {
          rotate([0, 0, -90]) {
            head_neck(show_pan_servo=show_pan_servo,
                      show_tilt_servo=show_tilt_servo,
                      show_ir_case=show_ir_case,
                      show_camera=show_camera,
                      show_ir_led=show_ir_led,
                      show_head=show_head,
                      head_color=head_color);
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
              show_front_rear_panel=show_front_rear_panel,
              show_ultrasonic=show_ultrasonic,
              show_ackermann_triangle=show_ackermann_triangle,
              show_ups_hat=show_ups_hat,
              show_steering=show_steering,
              show_bearing=show_bearing,
              show_brackets=show_bearing,
              show_battery_holders=show_battery_holders,
              show_rear_panel_buttons=show_rear_panel_buttons,
              show_rpi=show_rpi,
              show_head=show_head);
