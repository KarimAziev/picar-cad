/**
  * Module: L-Bracket for toggle switch that should lies on the side.
  *
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../steering_params.scad>

use <../../lib/debug.scad>
use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../placeholders/toggle_switch.scad>

module button_bracket(plist,
                      anchor=[0, 0, 1],
                      debug=false,
                      orientation="wlh",
                      show_bracket=true,
                      show_button=true,
                      slot_mode=false,
                      rotate_z_180=false,
                      color=white_smoke_1) {
  button = plist_get("button", plist);
  bolt_d = plist_get("bolt_d", plist);
  bottom_t = plist_get("bottom_t", plist);
  vertical_extra_t = plist_get("vertical_extra_t", plist);
  side_pad = plist_get("side_pad", plist);
  bolt_pad = plist_get("bolt_pad", plist);
  d_tolerance= plist_get("d_tolerance", plist);
  color = plist_get("color", plist);
  vertical_r = plist_get("vertical_r", plist);
  bottom_r = plist_get("bottom_r", plist);
  vertical_top_pad = plist_get("vertical_top_pad", plist, 0);

  body_size = plist_get("body_size", button);
  thread_h = plist_get("thread_h", button);
  thread_d = plist_get("thread_d", button);
  nut_d = plist_get("nut_d", button);
  nut_bore_h = plist_get("nut_bore_h", button);
  lever_dia_1 = plist_get("lever_dia_1", button);
  lever_dia_2 = plist_get("lever_dia_2", button);
  lever_h = plist_get("lever_h", button);
  terminal_size = plist_get("terminal_size", button);
  thread_border_w = plist_get("thread_border_w", button);

  metallic_head_h = plist_get("metallic_head_h", button);

  body_w = body_size[0];
  body_l = body_size[1];
  body_h = body_size[2];
  terminal_h = terminal_size[2];
  full_body_h = body_h + terminal_h;

  thread_spec = [thread_d, thread_h, thread_border_w];
  lever_spec = [lever_dia_1, lever_dia_2, lever_h];

  bounds = toggle_switch_lever_bounds(thread_spec, lever_spec);
  lever_full_h = bounds[1][2] - bounds[1][1]; // not sure whether it is correct

  full_h = lever_full_h + full_body_h; // probably worth to move to function

  vertical_wall_t = vertical_extra_t + nut_bore_h;

  vertical_wall_w = max(d_tolerance + nut_d, body_w);
  vertical_wall_l = max(d_tolerance + nut_d, body_l);

  bottom_wall_l = body_h + vertical_wall_t;

  bolt_spacing_x = vertical_wall_w + bolt_pad * 2;
  mount_w = bolt_spacing_x + side_pad * 2;

  half_w = mount_w / 2;

  pts = [[-vertical_wall_w / 2, -bottom_wall_l],
         [-half_w, -bottom_wall_l / 2 - bolt_d],
         [-half_w, -bottom_wall_l / 2],
         [-half_w, -bottom_wall_l / 2 + bolt_d],
         [-vertical_wall_w / 2, 0],
         [vertical_wall_w / 2, 0],
         [half_w, -bottom_wall_l / 2 + bolt_d],
         [half_w, -bottom_wall_l / 2],
         [half_w, -bottom_wall_l / 2 - bolt_d],
         [vertical_wall_w / 2, -bottom_wall_l],];

  // rotated size
  bracket_size = [mount_w, bottom_wall_l, bottom_t];

  module _bottom_wall() {
    if (debug) {
      translate([0, 0, bottom_t]) {
        debug_polygon_text(pts);
      }
    }
    difference() {
      color(color, alpha=1) {
        union() {
          cuboid([vertical_wall_w, bottom_wall_l, bottom_t],
                 anchor=[0, -1, -1],
                 side="bottom",
                 r=bottom_r);
          translate([0, 0, -bottom_t]) {
            linear_extrude(height=bottom_t, center=false) {
              offset_vertices_2d(r=bottom_r) {
                polygon(pts);
              }
            }
          }
        }
      }

      translate([0, -bottom_wall_l / 2, -bottom_t]) {
        four_corner_children(size=[bolt_spacing_x, 0], center=true) {
          counterbore(h=bottom_t,
                      d=bolt_d,
                      fn=100,
                      reverse=false);
        }
      }
    }
  }

  module _vertical_wall() {
    union() {
      difference() {
        translate([0, -vertical_top_pad / 2, 0]) {
          cuboid([vertical_wall_w,
                  vertical_wall_l
                  + vertical_top_pad,
                  vertical_wall_t],
                 color=color,
                 r=vertical_r,
                 side="bottom");
        }
        toggle_switch_counterbore(thread_d=thread_d,
                                  nut_d=nut_d,
                                  reverse=true,
                                  sink=true,
                                  center=true,
                                  nut_bore_h=nut_bore_h,
                                  bore_tolerance=d_tolerance,
                                  extra_thickness=vertical_extra_t);
      }
    }
  }

  module _bracket() {
    _vertical_wall();
    translate([0, vertical_wall_l / 2, vertical_wall_t]) {
      rotate([90, 0, 0]) {
        _bottom_wall();
      }
    }
  }
  module _main() {
    translate([0,
               -terminal_h - bottom_wall_l / 2,
               vertical_wall_l / 2 + bottom_t]) {
      rotate([-90, 0, 0]) {
        if (slot_mode) {
        } else {
          if (show_bracket) {
            translate([0, 0, full_body_h]) {
              _bracket();
            }
          }
          if (show_button) {
            toggle_switch(size=body_size,
                          thread_h=thread_h,
                          thread_d=thread_d,
                          nut_d=nut_d,
                          nut_bore_h=nut_bore_h,
                          lever_dia_1=lever_dia_1,
                          lever_dia_2=lever_dia_2,
                          lever_h=lever_h,
                          terminal_size=terminal_size,
                          thread_border_w=thread_border_w,
                          metallic_head_h=metallic_head_h);
          }
        }
      }
    }
  }

  with_orientation(from="wlh",
                   to=orientation,
                   anchor=anchor,
                   size=bracket_size,
                   rotate_z_180=rotate_z_180) {
    _main();
  }
}

button_bracket(toggle_switch_bracket_plist,
               anchor=[0, 0, 1],
               slot_mode=false,
               show_button=true);
