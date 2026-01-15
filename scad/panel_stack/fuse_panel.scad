/**
 * Module: Fuse holder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../core/slot_layout.scad>
use <../lib/holes.scad>
use <../lib/placement.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/atm_fuse_holder/atm_fuse_holder.scad>
use <../placeholders/standoff.scad>
use <../placeholders/toggle_switch.scad>
use <control_panel.scad>

max_body_height         = max([for (pl = fuse_panel_plist_specs)
                                  let (body = plist_get("body", pl, []),
                                       size = plist_get("size", body, []),
                                       height =
                                       with_default(size[2],
                                                    atm_fuse_holder_body_h))
                                    height]);

max_lid_height          = max([for (pl = fuse_panel_plist_specs)
                                  let (cap = plist_get("cap", pl, []),
                                       size = plist_get("size", cap, []),
                                       height =
                                       with_default(size[2],
                                                    atm_fuse_holder_cap_h))
                                    height]);

flipped_len             = len([for (pl = fuse_panel_plist_specs)
                                  if (plist_get("cap_to_bottom", pl) == true)
                                    pl]);

is_flipped              = flipped_len > 0;

is_all_flipped          = flipped_len == len(fuse_panel_plist_specs);

total_size              = get_total_size(fuse_panel_plist_specs,
                                         direction="ttb");

total_len               = total_size[1];

bolt_double_padding     = panel_stack_bolt_padding * 2;

full_panel_len          = sum([total_len,
                               panel_stack_padding_y,
                               bolt_double_padding]);

full_panel_width        = sum([panel_stack_bolt_dia,
                               total_size[0],
                               panel_stack_padding_x,
                               bolt_double_padding]) ;

panel_bolt_spacing      = [full_panel_width
                           - panel_stack_bolt_cbore_dia
                           - panel_stack_bolt_padding,
                           full_panel_len
                           - panel_stack_bolt_cbore_dia
                           - panel_stack_bolt_padding];

lower_h                 = is_all_flipped
                           ? max_lid_height
                           : is_flipped
                           ? max(max_body_height, max_lid_height)
                           : max_body_height;

upper_h                 = is_all_flipped
                           ? max_body_height
                           : is_flipped
                           ? max(max_body_height, max_lid_height)
                           : max_body_height;

standoff_desired_body_h = lower_h + chassis_thickness + 2;
standoff_bore_h         = fuse_panel_thickness / 2;
standoff_params         = calc_standoff_params(d=panel_stack_bolt_dia,
                                               min_h=standoff_desired_body_h);

standoff_upper_params   = calc_standoff_params(d=panel_stack_bolt_dia,
                                               min_h=upper_h);

lower_standoff_height   = non_empty(standoff_params[1])
                           ? sum(standoff_params[1])
                           : lower_h;

upper_standoff_height   = non_empty(standoff_upper_params[1])
                           ? sum(standoff_upper_params[1])
                           : upper_h;

function fuse_panel_bolt_spacing() = panel_bolt_spacing;

function fuse_panel_size() = [full_panel_width,
                              full_panel_len,
                              fuse_panel_thickness];

function fuse_panel_standoff_upper_height() =
  non_empty(standoff_params[1]) ? sum(standoff_params[1]) : upper_h;

module fuse_panel_slots(slot_mode = true,
                        show_atm_fuse_holders = true,
                        show_cap = true,
                        thickness=fuse_panel_thickness) {
  slot_layout(fuse_panel_plist_specs,
              direction="ttb",
              center=true,
              use_children=!slot_mode,
              thickness=thickness,
              align_to_axle=0,
              align=0) {
    plist = $spec;
    custom_slot_mode = $custom;
    placeholder = plist_get("placeholder", plist);

    if (!custom_slot_mode) {
      is_fuse_holder = placeholder == "atm_fuse_holder";

      if (show_atm_fuse_holders && is_fuse_holder) {
        let (body_size = plist_get("size", plist_get("body", plist, [])),
             flip = plist_get("cap_to_bottom", plist, false),
             body_h = with_default(body_size[2], atm_fuse_holder_body_h),
             merged_pl = show_cap == false
             ? plist_merge(plist, ["show_cap", show_cap])
             : plist) {

          if (flip) {
            translate([0, 0, body_h]) {
              rotate([180, 0, 0]) {
                atm_fuse_holder_from_spec(merged_pl);
              }
            }
          } else {
            translate([0, 0, -body_h]) {
              atm_fuse_holder_from_spec(merged_pl);
            }
          }
        }
      } else if (!is_fuse_holder && !is_undef(placeholder)) {
        echo(str("WARNING: unsupported placeholder ", placeholder, " in fuse panel",));
      }
    }
  }
}

module fuse_panel(show_fuses=false,
                  show_standoff=true,
                  center=false,
                  show_cap=true,
                  panel_color=white_snow_1,
                  size=[full_panel_width, full_panel_len],
                  bolt_spacing=panel_bolt_spacing,
                  show_bolt=false,
                  show_nut=false,
                  bolt_head_type="hex",
                  bolt_color=matte_black,
                  bolt_visible_h=chassis_thickness - standoff_bore_h,
                  corner_factor=panel_stack_corner_radius_factor) {

  full_w = size[0];
  full_l = size[1];

  z = show_standoff
    ? lower_standoff_height - standoff_bore_h
    : 0;

  translate([center ? 0 : full_w / 2,
             center ? 0 : full_l / 2,
             0]) {
    union() {
      maybe_translate([0,
                       0,
                       z]) {
        union() {
          difference() {
            color(panel_color) {
              linear_extrude(height=fuse_panel_thickness,
                             center=false,
                             convexity=2) {
                rounded_rect(size=size,
                             center=true,
                             r_factor=corner_factor);
              }
            }
            four_corner_counterbores(size=bolt_spacing,
                                     center=true,
                                     d=panel_stack_bolt_dia,
                                     h=fuse_panel_thickness,
                                     bore_h=standoff_bore_h,
                                     reverse=true,
                                     bore_d=panel_stack_bolt_cbore_dia,
                                     sink=false);

            fuse_panel_slots(slot_mode=true);
          }
        }

        if (show_fuses) {
          fuse_panel_slots(slot_mode=false,
                           show_cap=show_cap);
        }
        if (show_standoff) {
          translate([0,
                     0,
                     -lower_standoff_height + standoff_bore_h]) {
            four_corner_children(size=bolt_spacing,
                                 center=true) {
              standoffs_stack(d=panel_stack_bolt_dia,
                              min_h=standoff_desired_body_h,
                              show_bolt=show_bolt,
                              show_nut=show_nut,
                              bolt_color=bolt_color,
                              nut_pos=fuse_panel_thickness,
                              bolt_visible_h=bolt_visible_h,
                              bolt_head_type=bolt_head_type,
                              thread_at_top=true);
            }
          }
        }

        if ($children) {
          translate([0, 0, fuse_panel_thickness]) {
            four_corner_children(size=bolt_spacing, center=true) {
              standoffs_stack(d=panel_stack_bolt_dia,
                              min_h=upper_h,
                              show_bolt=show_bolt,
                              show_nut=show_nut,
                              bolt_color=bolt_color,
                              nut_pos=fuse_panel_thickness,
                              bolt_visible_h=bolt_visible_h,
                              bolt_head_type=bolt_head_type,
                              thread_at_top=true);
            }
            translate([0, 0, upper_standoff_height]) {
              children();
            }
          }
        }
      }
    }
  }
}

fuse_panel(center=false,
           show_fuses=true,
           show_cap=true,
           show_standoff=false);
