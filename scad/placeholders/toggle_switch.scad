/**
 * Module: Toggle Switch Button
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

use <../lib/shapes3d.scad>
use <../lib/transforms.scad>
use <../lib/holes.scad>
use <../lib/functions.scad>

function toggle_switch_calc_desired_thickness(extra_thickness, nut_bore_h) =
  extra_thickness + nut_bore_h;

module toggle_switch(size                               = toggle_switch_size,
                     thread_h                           = toggle_switch_thread_h,
                     thread_d                           = toggle_switch_thread_d,
                     nut_d                              = toggle_switch_nut_d,
                     nut_bore_h                         = toggle_switch_nut_out_h,
                     lever_dia_1                        = toggle_switch_lever_dia_1,
                     lever_dia_2                        = toggle_switch_lever_dia_2,
                     lever_h                            = toggle_switch_lever_h,
                     terminal_size                      = toggle_switch_terminal_size,
                     thread_border_w                    = toggle_switch_thread_border_w,
                     metallic_head_h                    = toggle_switch_metallic_head_h,
                     center_x=true,
                     center_y= true) {
  thread_inner_dia = thread_d - thread_border_w;

  r_inner = thread_inner_dia / 2;

  A   = sqrt(lever_h * lever_h + (lever_dia_2 + r_inner) *
             (lever_dia_2 + r_inner));
  phi = atan2((lever_dia_2 + r_inner), lever_h);

  lever_angle =
    (r_inner <= A)
    ? asin(r_inner / A) - phi
    : 0;

  translate([center_x ? 0 : size[0] / 2,
             center_y ? 0 : size[1] / 2,
             0]) {

    union() {
      translate([0, 0, terminal_size[2]]) {
        color(brown_3, alpha=1) {
          rounded_cube(size=[size[0],
                             size[1],
                             size[2]
                             - metallic_head_h]);
        }
        translate([0, 0, size[2]
                   - metallic_head_h]) {
          color(metallic_silver_1, alpha=1) {
            rounded_cube(size=[size[0],
                               size[1],
                               metallic_head_h]);
          }
        }
      }
      mirror_copy([1, 0, 0]) {
        color(metallic_silver_1, alpha=1) {
          translate([size[0] / 2
                     - terminal_size[0] / 2 - 0.1, 0, 0]) {
            rounded_cube(terminal_size);
          }
        }
      }

      translate([0, 0, terminal_size[2] + size[2]]) {
        color(metallic_silver_1, alpha=1) {
          cylinder(h=nut_bore_h,
                   d=nut_d, $fn=6);

          difference() { // bordered cylinder
            cylinder(h=thread_h,
                     d=thread_d, $fn=30);
            translate([0, 0, thread_h / 2]) {
              cylinder(h=thread_h,
                       d=thread_inner_dia, $fn=30);
            }
          }
          rotate([0, lever_angle, 0]) {
            translate([0, 0, thread_h / 2]) {
              union() {
                sphere(d=lever_dia_2);
                cylinder(h=lever_h,
                         r1=lever_dia_1 / 2,
                         r2=lever_dia_2 / 2,
                         $fn=30);
              }
            }
          }
        }
      }
    }
  }
}

module toggle_switch_counterbore(thread_d                           = toggle_switch_thread_d,
                                 d_tolerance                        = toggle_switch_slot_d_tolerance,
                                 nut_d                              = toggle_switch_nut_d,
                                 nut_bore_h                         = toggle_switch_nut_out_h,
                                 bore_tolerance                     = toggle_switch_slot_counterbore_tolerance,
                                 extra_thickness                    = 2,
                                 sink                               = false,
                                 autoscale_step                     = 0.1,
                                 $fn                                = 60,
                                 reverse                            = false,
                                 total_thickness) {

  total_thickness = is_undef(total_thickness)
    ? extra_thickness + nut_bore_h
    : total_thickness;
  dia = d_tolerance + thread_d;
  cbore_d = nut_d + bore_tolerance;
  counterbore(h=total_thickness,
              d=dia,
              bore_d=cbore_d,
              bore_h=nut_bore_h,
              center=false,
              sink=sink,
              fn=$fn,
              autoscale_step=autoscale_step,
              reverse=reverse);
}

toggle_switch(center_x=false, center_y=false);
