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
use <../../placeholders/crimp_terminals/ring_terminal.scad>
use <../../placeholders/toggle_switch.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  button_bracket_props
  ─────────────────────────────────────────────────────────────────────────────
  Resolve the printed bracket and the installed switch envelope.
  **Parameters:**
  - `pl`: Bracket plist, including the switch's `button` hardware plist.
    `terminal_extension` reserves additional terminal length in mm (default 0)
    and moves the wiring opening that far toward local -Y. It leaves the
    measured switch placeholder and the opening's dimensions unchanged.
  **Returns:**
  `size` is the printed reference box, centered on XY with its base at Z=0.
  `bounds` includes terminals, both lever positions and the wiring opening.
  `mount_holes` and `wire_pos` use this same frame.
 */
function button_bracket_props(pl) =
  let (b = plist_get("button", pl),
       body = plist_get("body_size", b),
       terminal = plist_get("terminal_size", b),
       extension = plist_get("terminal_extension", pl, 0),
       tol = plist_get("d_tolerance", pl),
       wall_t = plist_get("vertical_extra_t", pl) + plist_get("nut_bore_h", b),
       wall_w = max(tol + plist_get("nut_d", b), body[0]),
       wall_h = max(tol + plist_get("nut_d", b), body[1]),
       t = plist_get("bottom_t", pl),
       pitch = wall_w + 2 * plist_get("bolt_pad", pl),
       size = [pitch + 2 * plist_get("side_pad", pl), body[2] + wall_t,
               t + wall_h + plist_get("vertical_top_pad", pl, 0)],
       lever = toggle_switch_lever_bounds([plist_get("thread_d", b), plist_get("thread_h", b),
                                           plist_get("thread_border_w", b)],
                                          [plist_get("lever_dia_1", b), plist_get("lever_dia_2", b),
                                           plist_get("lever_h", b)]),
       wire = plist_get("wire_size", pl, [body[0] * 0.6, terminal[2] + 2]),
       wire_y = -size[1] / 2 - terminal[2] / 2 - extension,
       half_w = max(size[0] / 2, lever[1][0], wire[0] / 2),
       bounds = [[-half_w, min(-size[1] / 2 - terminal[2] - extension, wire_y - wire[1] / 2), 0],
                 [half_w, max(size[1] / 2,
                              body[2] - size[1] / 2
                              + max(lever[1][2], plist_get("thread_h", b))), size[2]]])
  assert(is_num(extension) && extension >= 0,
         "Button terminal_extension must be nonnegative mm")
  assert(min(size) > 0 && plist_get("bolt_d", pl) > 0
         && min(wire) > 0,
         "Button bracket dimensions must be positive")
  ["size", size, "bounds", bounds, "wire_size", wire,
   "wire_pos", [0, wire_y], "mount_holes", [[-pitch / 2, 0], [pitch / 2, 0]]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  button_bracket
  ─────────────────────────────────────────────────────────────────────────────
  Render the switch bracket or matching parent mounting and wiring cutters.
  **Parameters:**
  - `plist`: Component dimensions accepted by button_bracket_props.
  - `anchor`: Oriented printed-envelope anchor, shared by solid and slot modes.
  - `parent_thickness`: Parent depth below the mounting plane in slot mode.
  - `debug`: Label the base polygon.
  - `orientation`: Axis convention accepted by with_orientation.
  - `show_bracket`: Display printed material.
  - `show_button`: Display switch hardware.
  - `slot_mode`: Cut parent holes downward from the base, with underside sinks.
  - `rotate_z_180`: Reverse the bracket around the oriented Z axis.
  - `color`: Fallback material color; the plist can override it.
 */
module button_bracket(plist,
                      anchor=[0, 0, 1],
                      parent_thickness=4,
                      debug=false,
                      orientation="wlh",
                      show_bracket=true,
                      show_crimp_terminal=true,
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
  resolved_color = plist_get("color", plist, color);
  props = button_bracket_props(plist);
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

  vertical_wall_t = vertical_extra_t + nut_bore_h;

  vertical_wall_w = max(d_tolerance + nut_d, body_w);
  vertical_wall_l = max(d_tolerance + nut_d, body_l);

  bottom_wall_l = body_h + vertical_wall_t;

  bolt_spacing_x = vertical_wall_w + bolt_pad * 2;
  mount_w = bolt_spacing_x + side_pad * 2;

  half_w = mount_w / 2;

  crimp_terminal = plist_get("crimp_terminal", plist, []);

  crimp_terminal_plist = plist_get("props", crimp_terminal);
  insulate_colors = plist_get("insulate_colors", crimp_terminal, []);
  z_offset = plist_get("z_offset", crimp_terminal, 0);

  crimp_terminal_props = !is_undef(crimp_terminal_plist)
    ? ring_terminal_props(crimp_terminal_plist)
    : undef;

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
  bracket_size = plist_get("size", props);

  module _button() {
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
    if (show_crimp_terminal && crimp_terminal_props) {
      t = plist_get("t", crimp_terminal_props);
      od = plist_get("od", crimp_terminal_props);
      insulate = plist_get("insulate", crimp_terminal_props);
      insulate_color = plist_get("insulate_color", crimp_terminal_props);

      let (half_t = t / 2,
           half_body_w = body_w / 2,
           half_terminal_t =  terminal_size[0] / 2,
           x_poses = [half_body_w + half_terminal_t - half_t - 0.1,
                      -half_body_w + half_t - half_terminal_t + 0.1]) {
        for (i = [0 : 1]) {
          let (merged_insulate = plist_merge(insulate,
                                             ["color", with_default(insulate_colors[i],
                                                                    insulate_color)]),
               merged_pl = plist_merge(crimp_terminal_plist, ["insulate", merged_insulate])) {
            translate([x_poses[i], 0, od / 2 + z_offset]) {
              ring_terminal(merged_pl, anchor=[0, 0, -1], spin=90);
            }
          }
        }
      }
    }
  }

  module _bottom_wall() {
    if (debug) {
      translate([0, 0, bottom_t]) {
        debug_polygon_text(pts);
      }
    }
    difference() {
      color(resolved_color, alpha=1) {
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
                      no_bore=true,
                      fn=60);
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
                 color=resolved_color,
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
        if (show_bracket) {
          translate([0, 0, full_body_h]) {
            _bracket();
          }
        }
        if (show_button) {
          _button();
        }
      }
    }
  }

  with_orientation(from="wlh",
                   to=orientation,
                   anchor=anchor,
                   size=bracket_size,
                   rotate_z_180=rotate_z_180) {
    if (slot_mode) {
      assert(parent_thickness >= plist_get("bore_h", plist, 1.8) + 0.4,
             "Button mounting countersinks need material above their heads");
      for (xy = plist_get("mount_holes", props)) {
        translate(concat(xy, [-parent_thickness])) {
          counterbore(h=parent_thickness,
                      d=bolt_d,
                      bore_d=plist_get("bore_d", plist, 6.4),
                      bore_h=plist_get("bore_h", plist, 1.8),
                      sink=true,
                      reverse=true);
        }
      }
      _wire_slot(parent_thickness);
    } else {
      difference() {
        _main();
        _wire_slot(0);
      }
    }
  }

  module _wire_slot(depth) {
    wire = plist_get("wire_size", props);
    translate(concat(plist_get("wire_pos", props), [-depth - 0.01])) {
      cuboid([wire[0], wire[1], depth + bottom_t + 0.02],
             anchor=[0, 0, 1],
             r=min(wire) / 4);
    }
  }
}

button_bracket(toggle_switch_bracket_plist,
               anchor=[0, 0, 1],
               slot_mode=false,
               show_button=true);
