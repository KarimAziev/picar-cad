/**
 * Module: A holder for switch buttons and fusers
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>
include <../colors.scad>

use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>

use <../placeholders/toggle_switch.scad>
use <../lib/holes.scad>
use <../placeholders/standoff.scad>
use <../lib/placement.scad>
use <../lib/transforms.scad>
use <../lib/functions.scad>
use <../placeholders/bolt.scad>
use <../lib/plist.scad>
use <../lib/slots.scad>

sizes                   = [for (spec = control_panel_switch_button_specs)
    plist_get("size", spec)];
thread_specs            = [for (spec = control_panel_switch_button_specs)
    plist_get("thread", spec)];
nut_specs               = [for (spec = control_panel_switch_button_specs)
    plist_get("nut", spec)];
terminal_specs          = [for (spec = control_panel_switch_button_specs)
    plist_get("terminal", spec)];
lever_specs             = [for (spec = control_panel_switch_button_specs)
    plist_get("lever", spec)];
head_specs              = [for (spec = control_panel_switch_button_specs)
    plist_get("head", spec)];
lengths                 = [for (size = sizes) size[0]];
thicknesses             = [for (size = sizes) size[1]];
body_heights            = [for (size = sizes) size[2]];
terminal_heights        = [for (terminal_spec = terminal_specs)
    terminal_spec[2]];

slot_dias               = [for (spec=thread_specs) spec[0] +
                                                     with_default(spec[3], 0)];
slot_cbore_dias         = [for (spec=nut_specs) spec[0] +
                                                  with_default(spec[2], 0)];

heights                 = [for (i = [0 : len(body_heights)-1])
    body_heights[i] + terminal_heights[i]];

max_height              = max(heights);
max_len                 = max(lengths);
max_thickness           = max(concat(slot_cbore_dias, thicknesses, slot_dias));

y_sizes                 = [for (i = [0 : len(nut_specs) - 1]) max(thicknesses[i],
                                                                  slot_cbore_dias[i],
                                                                  slot_dias[i])];

total_len               = sum(y_sizes) + (len(y_sizes) - 1) * control_panel_row_gap;

full_panel_len          = (panel_stack_bolt_cbore_dia + total_len)
  + panel_stack_padding_y + panel_stack_bolt_padding * 2;

full_panel_width        = (panel_stack_bolt_cbore_dia + max_len) +
  panel_stack_padding_x + panel_stack_bolt_padding * 2;

panel_bolt_spacing      = [full_panel_width
                           - panel_stack_bolt_cbore_dia
                           - panel_stack_bolt_padding,
                           full_panel_len
                           - panel_stack_bolt_cbore_dia
                           - panel_stack_bolt_padding];

standoff_desired_body_h = max_height + chassis_thickness + 1;
standoff_params = calc_standoff_params(d=panel_stack_bolt_dia,
                                       min_h=standoff_desired_body_h);

standoff_bore_h         = (is_undef(standoff_params) || is_undef(standoff_params[0])) ? 0 :
  plist_get("thread_h", standoff_params[0]) / 2;

function control_panel_size() = [full_panel_width, full_panel_len, control_panel_thickness];
function control_panel_bolt_size() = panel_bolt_spacing;
function control_panel_max_height() = max_height;

function control_panel_standoff_height() =
  let (params = calc_standoff_params(d=panel_stack_bolt_dia,
                                     min_h=standoff_desired_body_h),
       height = (is_undef(params) || is_undef(params[1])) ? max_height : sum(params[1]))
  height;

module control_panel_slots(specs=control_panel_switch_button_specs,
                           gap=control_panel_row_gap,
                           center=true,
                           slot_mode=false) {

  translate([0, center ? -total_len / 2 - y_sizes[0] / 2 : 0, 0]) {
    for (i = [0 : len(specs) - 1]) {
      let (spec                               = specs[i],
           size                               = plist_get("size", spec),
           thread_spec                        = plist_get("thread", spec),
           nut_spec                           = plist_get("nut", spec),
           terminal_spec                      = plist_get("terminal", spec),
           lever_spec                         = plist_get("lever", spec),
           head_spec                          = plist_get("head", spec),
           thread_d                           = thread_spec[0],
           thread_h                           = thread_spec[1],
           d_tolerance                        = thread_spec[2],
           thread_border_w                    = thread_spec[2],
           nut_d                              = nut_spec[0],
           nut_bore_h                         = nut_spec[1],
           nut_bore_tolerance                 = nut_spec[2],
           lever_dia_1                        = lever_spec[0],
           lever_dia_2                        = lever_spec[1],
           lever_h                            = lever_spec[2],
           terminal_size                      = terminal_spec,
           metallic_head_h                    = head_spec[0],
           prev_y_size = i > 0 ? sum(y_sizes, i) : 0,
           curr_size = y_sizes[i],
           y = (gap * i) + prev_y_size + curr_size) {

        translate([0, y, 0]) {
          if (!slot_mode) {
            translate([0, 0, -terminal_size[2] - size[2]]) {
              toggle_switch(size                               = size,
                            thread_d                           = thread_d,
                            thread_h                           = thread_h,
                            nut_d                              = nut_d,
                            nut_bore_h                         = nut_bore_h,
                            lever_dia_1                        = lever_dia_1,
                            lever_dia_2                        = lever_dia_2,
                            lever_h                            = lever_h,
                            terminal_size                      = terminal_size,
                            center_y                           = true,
                            thread_border_w                    = thread_border_w,
                            metallic_head_h                    = metallic_head_h);
            }
          } else {
            toggle_switch_counterbore(thread_d=thread_d,
                                      center=true,
                                      d_tolerance=d_tolerance,
                                      nut_d=nut_d,
                                      nut_bore_h=nut_bore_h,
                                      bore_tolerance=nut_bore_tolerance,
                                      reverse=false,
                                      sink=true,
                                      total_thickness=control_panel_thickness);
          }
        }
      }
    }
  }
}

module control_panel(specs=control_panel_switch_button_specs,
                     gap=control_panel_row_gap,
                     show_buttons=true,
                     show_standoff=true,
                     center=true,
                     min_standoff_h=standoff_desired_body_h,
                     show_bolt=false,
                     show_nut=false,
                     bolt_head_type="hex",
                     bolt_color=matte_black,
                     bolt_visible_h=chassis_thickness - standoff_bore_h,
                     panel_color = white_snow_1,
                     size=[full_panel_width, full_panel_len],
                     bolt_spacing=panel_bolt_spacing) {
  standoff_full_h = control_panel_standoff_height();
  standoff_real_h = standoff_full_h - standoff_bore_h;
  full_w = size[0];
  full_l = size[1];

  translate([center ? 0 : full_w / 2,
             center ? 0 : full_l / 2,
             show_standoff ? standoff_real_h : 0]) {
    union() {
      difference() {
        color(panel_color, alpha=1) {
          linear_extrude(height=control_panel_thickness,
                         center=false,
                         convexity=2) {
            rounded_rect(size=size,
                         center=true,
                         r_factor=panel_stack_corner_radius_factor);
          }
        }

        four_corner_children(size=bolt_spacing, center=true) {
          counterbore(d=panel_stack_bolt_dia,
                      h=control_panel_thickness,
                      bore_h=standoff_bore_h,
                      reverse=true,
                      autoscale_step=0.1,
                      bore_d=panel_stack_bolt_cbore_dia,
                      center=true,
                      sink=false);
        }

        control_panel_slots(specs=specs,
                            gap=gap,
                            slot_mode=true,
                            center=true);
      }
      if (show_buttons) {
        control_panel_slots(slot_mode=false);
      }
      if (show_standoff) {
        translate([0,
                   0,
                   -standoff_full_h + standoff_bore_h]) {
          four_corner_children(size=bolt_spacing,
                               center=true) {

            standoffs_stack(d=panel_stack_bolt_dia,
                            min_h=min_standoff_h,
                            thread_at_top=true,
                            show_nut=show_nut,
                            show_bolt=show_bolt,
                            bolt_color=bolt_color,
                            bolt_visible_h=bolt_visible_h,
                            bolt_head_type=bolt_head_type);
          }
        }
      }
    }
  }
}

control_panel(show_buttons=true,
              show_standoff=true,
              center=true);