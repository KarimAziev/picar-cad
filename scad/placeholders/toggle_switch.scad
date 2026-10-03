/**
 * Module: Toggle Switch Button
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <crimp_terminals/ring_terminal.scad>

// Shared by the physical lever and its clearance envelope.
function toggle_switch_lever_angle(thread_d,
                                   thread_border_w,
                                   lever_dia_2,
                                   lever_h) =
  let (r_inner = (thread_d - thread_border_w) / 2,
       a = sqrt(lever_h * lever_h + (lever_dia_2 + r_inner) * (lever_dia_2 + r_inner)))
  r_inner <= a ? asin(r_inner / a) - atan2(lever_dia_2 + r_inner, lever_h) : 0;

/**
  ─────────────────────────────────────────────────────────────────────────────
  toggle_switch_lever_bounds
  ─────────────────────────────────────────────────────────────────────────────
  Return a conservative lever envelope covering both switch positions.
  **Parameters:**
  - `thread`: Thread specification `[diameter, height, border_width, ...]`.
  - `lever`: Lever specification `[lower_diameter, upper_diameter, height]`.
  **Returns:** `[minimum_xyz, maximum_xyz]` relative to the threaded stem's base.
  The switch throws along X. Y includes the lever's full diameter.
 */
function toggle_switch_lever_bounds(thread, lever) =
  let (angle = toggle_switch_lever_angle(thread[0], thread[2], lever[1], lever[2]),
       radius = max(lever[0], lever[1]) / 2,
       reach = abs(sin(angle)) * (thread[1]/2 + lever[2]) + radius)
  [[-reach, -radius, cos(angle) * thread[1]/2 - radius],
   [reach, radius, thread[1]/2 + lever[2] + radius]];

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
                     anchor=[0, 0, 1],
                     orientation="wlh",
                     terminal_hole_d,
                     terminal_hole_z,
                     crimp_terminal_plist,
                     show_crimp_terminal) {
  anchor = with_default(anchor, [0, 0, 1]);
  body_w = size[0];
  body_l = size[1];
  body_h = size[2];

  terminal_t = terminal_size[0];
  terminal_h = terminal_size[2];
  terminal_hole_enabled = terminal_hole_d && terminal_hole_d > 0;

  thread_inner_dia = thread_d - thread_border_w;

  lever_angle = toggle_switch_lever_angle(thread_d=thread_d,
                                          thread_border_w=thread_border_w,
                                          lever_dia_2=lever_dia_2,
                                          lever_h=lever_h);

  module _terminal_base() {
    cuboid(terminal_size,
           anchor=[0, 0, 1],
           color=metallic_silver_1);
  }

  module _crimp_terminal() {
    if (terminal_hole_enabled) {
      terminal_hole_z = with_default(terminal_hole_z,
                                     (terminal_h - terminal_hole_d) / 2);

      union() {
        difference() {
          _terminal_base();
          translate([0, 0, terminal_hole_z]) {
            cyl(h=terminal_t + 0.1, d=terminal_hole_d, orientation="hlw");
          }
        }
        if (show_crimp_terminal && crimp_terminal_plist) {
          let (crimp_terminal_props = ring_terminal_props(crimp_terminal_plist),
               od = plist_get("od", crimp_terminal_props),
               d = plist_get("d", crimp_terminal_props),
               z = od / 2 + d / 2 + terminal_hole_z,
               t=plist_get("t", crimp_terminal_props)) {
            translate([terminal_t / 2 + t / 2, 0, z]) {
              ring_terminal(crimp_terminal_plist,
                            anchor=[0, 0, -1],
                            spin=90);
            }
          }
        }
      }
    } else {
      _terminal_base();
    }
  }

  with_orientation(from="wlh", to=orientation, size=size, anchor=anchor) {
    union() {
      translate([0, 0, terminal_h]) {
        let (h = body_h - metallic_head_h) {
          cuboid(size=[body_w, body_l, h],
                 anchor=[0, 0, 1],
                 color=brown_3);
          translate([0, 0, h]) {
            cuboid(size=[body_w, body_l, metallic_head_h],
                   anchor=[0, 0, 1],
                   color=metallic_silver_1);
          }
        }
      }

      // terminals
      mirror_copy([1, 0, 0]) {
        translate([body_w / 2 - terminal_t / 2 - 0.1, 0, 0]) {
          _crimp_terminal();
        }
      }

      translate([0, 0, terminal_h + body_h]) {
        color(metallic_silver_1, alpha=1) {
          cylinder(h=nut_bore_h, d=nut_d, $fn=6);

          difference() { // bordered cylinder
            cylinder(h=thread_h,
                     d=thread_d,
                     $fn=30);
            translate([0, 0, thread_h / 2]) {
              cylinder(h=thread_h,
                       d=thread_inner_dia,
                       $fn=30);
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
                                 teardrop_angle,
                                 teardrop_both_sides,
                                 total_thickness,
                                 center) {

  total_thickness = is_undef(total_thickness)
    ? extra_thickness + nut_bore_h
    : total_thickness;
  dia = d_tolerance + thread_d;
  cbore_d = nut_d + bore_tolerance;
  counterbore(h=total_thickness,
              d=dia,
              bore_d=cbore_d,
              bore_h=nut_bore_h,
              center=center,
              sink=sink,
              fn=$fn,
              autoscale_step=autoscale_step,
              teardrop_both_sides=teardrop_both_sides,
              reverse=reverse,
              teardrop_angle=teardrop_angle);
}

module toggle_switch_from_plist(plist,
                                anchor,
                                orientation="wlh",
                                size_prop="placeholder_size",
                                show_crimp_terminal) {
  size = plist_get(size_prop, plist, toggle_switch_size);
  thread_h = plist_get("thread_h", plist, toggle_switch_thread_h);
  thread_d = plist_get("thread_d", plist, toggle_switch_thread_d);
  nut_d = plist_get("nut_d", plist, toggle_switch_nut_d);
  nut_bore_h = plist_get("nut_bore_h", plist, toggle_switch_nut_out_h);
  lever_dia_1 = plist_get("lever_dia_1", plist, toggle_switch_lever_dia_1);
  lever_dia_2 = plist_get("lever_dia_2", plist, toggle_switch_lever_dia_2);
  lever_h = plist_get("lever_h", plist, toggle_switch_lever_h);
  terminal_size = plist_get("terminal_size",
                            plist,
                            toggle_switch_terminal_size);
  thread_border_w = plist_get("thread_border_w",
                              plist,
                              toggle_switch_thread_border_w);
  metallic_head_h = plist_get("metallic_head_h",
                              plist,
                              toggle_switch_metallic_head_h);
  terminal_hole_d = plist_get("terminal_hole_d", plist);
  terminal_hole_z = plist_get("terminal_hole_z", plist);
  crimp_terminal_plist = plist_get("crimp_terminal", plist);

  toggle_switch(size=size,
                thread_h=thread_h,
                thread_d=thread_d,
                nut_d=nut_d,
                nut_bore_h=nut_bore_h,
                lever_dia_1=lever_dia_1,
                lever_dia_2=lever_dia_2,
                lever_h=lever_h,
                terminal_size=terminal_size,
                thread_border_w=thread_border_w,
                metallic_head_h=metallic_head_h,
                anchor=with_default(anchor, [0, 0, 1]),
                orientation=orientation,
                terminal_hole_d=terminal_hole_d,
                terminal_hole_z=terminal_hole_z,
                crimp_terminal_plist=crimp_terminal_plist,
                show_crimp_terminal=show_crimp_terminal);
}

toggle_switch(terminal_hole_d=m3_hole_dia,
              show_crimp_terminal=true,
              crimp_terminal_plist=["d", 4.33,
                                    "od", 6.61,
                                    "w", 3.35,
                                    "l", 9.1,
                                    "t", 0.62,
                                    "color", metallic_silver_5,
                                    "insulate", ["color", "#3771E1",
                                                 "l", 10.5,
                                                 "d", 5.9]],
              terminal_hole_z=3.8);