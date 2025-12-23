/**
 * Module: Fusers holder
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
use <../placeholders/atm_fuse_holder.scad>
use <control_panel.scad>
use <../lib/plist.scad>

slot_specs              = [for (spec = fuse_panels_specs) plist_get("slot", spec)];
body_specs              = [for (spec = fuse_panels_specs) plist_get("body", spec)];
body_rib_specs          = [for (spec = fuse_panels_specs) plist_get("body_ribs", spec)];
lid_specs               = [for (spec = fuse_panels_specs) plist_get("lid", spec)];
lid_rib_specs           = [for (spec = fuse_panels_specs) plist_get("lid_ribs", spec)];
lengths                 = [for (slot_spec = slot_specs) slot_spec[1]];
thicknesses             = [for (body_spec = body_specs) body_spec[2]];
rib_thicknesses         = [for (rib_spec = body_rib_specs) rib_spec[4]];
hole_depths             = [for (slot_spec = slot_specs) slot_spec[3]];
body_heights            = [for (body_spec = body_specs) body_spec[3]];
lid_heights             = [for (lid_spec = lid_specs) lid_spec[3]];

max_hole_depth          = max(hole_depths);
max_body_height         = max(body_heights);
max_lid_height          = max(lid_heights);
max_len                 = max(lengths);

y_sizes                 = [for (i = [0 : len(fuse_panels_specs) - 1])
    max(slot_specs[i][0],
        thicknesses[i] + rib_thicknesses[i] * 2)];

total_len               = sum(y_sizes) + (len(y_sizes) - 1)
  * fuse_panel_row_gap;

full_panel_len          = (panel_stack_bolt_dia + total_len) +
  panel_stack_padding_y + panel_stack_bolt_padding * 2;

full_panel_width        = (panel_stack_bolt_dia + max_len) +
  panel_stack_padding_x + panel_stack_bolt_padding * 2;

panel_screw_size        = [full_panel_width
                           - panel_stack_bolt_cbore_dia
                           - panel_stack_bolt_padding,
                           full_panel_len
                           - panel_stack_bolt_cbore_dia
                           - panel_stack_bolt_padding];

standoff_desired_body_h = max_body_height + chassis_thickness + 2;
standoff_bore_h         = fuse_panel_thickness / 2;

function fuse_panel_size() = [full_panel_width, full_panel_len,
                              fuse_panel_thickness];
function fuse_panel_screw_size() = panel_screw_size;
function fuse_panel_max_body_height() = max_body_height;
function fuse_panel_max_lid_height() = max_lid_height;
function fuse_panel_max_hole_depth() = max_hole_depth;

function fuse_panel_standoff_height() =
  let (params = calc_standoff_params(d=panel_stack_bolt_dia,
                                     min_h=standoff_desired_body_h),
       height = (is_undef(params) || is_undef(params[1])) ?
       max_body_height : sum(params[1]))
  height;

function fuse_panel_standoff_translate_height(x, y) =
  fuse_panel_standoff_height() - standoff_bore_h;

module fuse_panel_slots(slot_mode = true,
                        gap = fuse_panel_row_gap,
                        show_lid = true,
                        center = true) {
  translate([center ? 0 : max_len / 2,
             center
             ? -total_len / 2 - y_sizes[0] / 2
             : -y_sizes[0] / 2,
             0]) {
    for (i = [0 : len(fuse_panels_specs) - 1]) {
      let (spec = fuse_panels_specs[i],
           slot_spec = plist_get("slot", spec),
           body_spec = plist_get("body", spec),
           body_rib_spec = plist_get("body_ribs", spec),
           lid_spec = plist_get("lid", spec),
           lid_rib_spec = plist_get("lid_ribs", spec),
           prev_y_size = i > 0 ? sum(y_sizes, i) : 0,
           curr_size = y_sizes[i],
           y = (gap * i) + prev_y_size + curr_size) {
        translate([0, y, 0]) {
          if (!slot_mode) {
            rotate([90, 0, 0]) {
              atm_fuse_holder(body_spec=body_spec,
                              body_rib_spec=body_rib_spec,
                              lid_spec=lid_spec,
                              lid_rib_spec=lid_rib_spec,
                              show_lid=show_lid,
                              lid_z_offset=fuse_panel_thickness,
                              center_x=true,
                              center_y=false,
                              center_z=true);
            }
          } else {
            translate([0, 0, -0.5]) {
              linear_extrude(height=fuse_panel_thickness + 1, center=false) {
                rounded_rect(size=[slot_spec[1],
                                   slot_spec[0]],
                             r=slot_spec[2],
                             center=true,
                             fn=100);
              }
            }
          }
        }
      }
    }
  }
}

module fuse_panel(show_fusers=false,
                  show_standoff=true,
                  center=false,
                  show_lid=true,
                  panel_color=white_snow_1,
                  size=[full_panel_width, full_panel_len],
                  screws_size=panel_screw_size,
                  show_bolt=false,
                  show_nut=false,
                  bolt_head_type="hex",
                  bolt_color=matte_black,
                  bolt_visible_h=chassis_thickness - standoff_bore_h,
                  corner_factor=panel_stack_corner_radius_factor) {

  standoff_full_h = fuse_panel_standoff_height();
  standoff_real_h = fuse_panel_standoff_translate_height();
  full_w = size[0];
  full_l = size[1];

  translate([center ? 0 : full_w / 2,
             center ? 0 : full_l / 2,
             0]) {
    union() {
      translate([0,
                 0,
                 show_standoff ? standoff_real_h : 0]) {
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

            four_corner_children(size=screws_size, center=true) {
              counterbore(d=panel_stack_bolt_dia,
                          h=fuse_panel_thickness,
                          bore_h=standoff_bore_h,
                          reverse=true,
                          autoscale_step=0.1,
                          bore_d=panel_stack_bolt_cbore_dia,
                          center=false,
                          sink=false);
            }

            fuse_panel_slots(gap=fuse_panel_row_gap,
                             slot_mode=true,
                             center=true);
          }
          if (show_fusers) {
            fuse_panel_slots(slot_mode=false,
                             show_lid=show_lid);
          }
          if (show_standoff) {
            translate([0,
                       0,
                       -standoff_full_h + standoff_bore_h]) {
              four_corner_children(size=screws_size,
                                   center=true,) {
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
        }
        translate([0, 0, fuse_panel_thickness]) {
          children();
        }
      }
    }
  }
}

fuse_panel(center=false,
           show_fusers=true,
           show_standoff=true,
           show_nut=true,
           show_bolt=true,
           show_lid=false);
