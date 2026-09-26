/**
 * Module: A holder for switch buttons
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/holes.scad>
use <../lib/placement.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/standoff.scad>
use <../placeholders/toggle_switch.scad>

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
terminal_heights        = [for (term_spec = terminal_specs) term_spec[2]];

slot_dias               = [for (spec=thread_specs)
                           spec[0] + with_default(spec[3], 0)];
slot_cbore_dias         = [for (spec=nut_specs)
                           spec[0] + with_default(spec[2], 0)];

heights                 = [for (i = [0 : len(body_heights)-1])
                           body_heights[i] + terminal_heights[i]];

bolt_double_padding     = panel_stack_bolt_padding * 2;

max_height              = max(heights);
max_len                 = max(lengths);
max_thickness           = max(concat(slot_cbore_dias, thicknesses, slot_dias));

y_sizes                 = [for (i = [0 : len(nut_specs) - 1])
                           max(thicknesses[i],
                           slot_cbore_dias[i],
                           slot_dias[i])];

total_len               = sum(y_sizes)
                           + (len(y_sizes) - 1)
                           * control_panel_row_gap;

full_panel_len          = (panel_stack_bolt_cbore_dia + total_len)
                           + panel_stack_padding_y
                           + bolt_double_padding;

full_panel_width        = panel_stack_bolt_cbore_dia
                           + max_len
                           + panel_stack_padding_x
                           + bolt_double_padding;

panel_bolt_spacing      = [full_panel_width
                           - panel_stack_bolt_cbore_dia
                           - panel_stack_bolt_padding,
                           full_panel_len
                           - panel_stack_bolt_cbore_dia
                           - panel_stack_bolt_padding];

standoff_desired_body_h = max_height + chassis_thickness + 1;
standoff_params         = calc_standoff_params(d=panel_stack_bolt_dia,
                                               min_h=standoff_desired_body_h);

standoff_plist          = with_default(standoff_params[0], [], "list");
standoff_heights        = standoff_params[1];

standoff_bore_h         = plist_get("thread_h", standoff_plist, 5) / 2;

standoff_full_h         = non_empty(standoff_heights)
                           ? sum(standoff_heights)
                           : max_height;

function control_panel_size() = [full_panel_width,
                                 full_panel_len,
                                 control_panel_thickness];

function control_panel_bolt_size() = panel_bolt_spacing;

/**
  ─────────────────────────────────────────────────────────────────────────────
  control_panel_height
  ─────────────────────────────────────────────────────────────────────────────

  Return the height from the mounting plane to the panel's top face.

  **Parameters:**
  - `show_standoff`: Include the supporting standoff height.

  **Returns:** Structural height, excluding switches and fastener protrusions.
 */
function control_panel_height(show_standoff=true, min_standoff_h=standoff_desired_body_h) =
  (show_standoff ? standoff_real_h(min_standoff_h, panel_stack_bolt_dia) - standoff_bore_h : 0)
  + control_panel_thickness;

/**
  ─────────────────────────────────────────────────────────────────────────────
  control_panel_oriented_size / control_panel_oriented_bolt_spacing
  ─────────────────────────────────────────────────────────────────────────────
  Return the oriented structural box or mounting-center spans as `[x, y, z]`.
  `orientation` accepts the six axis conventions; `show_standoff` includes the
  support height in the structural box. Installed hardware is excluded.
 */
function control_panel_oriented_size(orientation="wlh", show_standoff=true) =
  orientation_size(orientation, [full_panel_width, full_panel_len,
                                  control_panel_height(show_standoff)]);

function control_panel_oriented_bolt_spacing(orientation="wlh") =
  orientation_size(orientation, concat(panel_bolt_spacing, [0]));

/**
  ─────────────────────────────────────────────────────────────────────────────
  control_panel_clearance_height
  ─────────────────────────────────────────────────────────────────────────────
  Return the installed hardware's upper envelope above the mounting plane.
  `show_standoff` includes the supporting standoffs. Used for overhead clearance,
  independently of hardware visibility in a preview.
 */
function control_panel_clearance_height(show_standoff=true) =
  control_panel_height(show_standoff) - control_panel_thickness
  + max(control_panel_thickness,
        max([for (spec = control_panel_switch_button_specs)
          let (thread = plist_get("thread", spec), lever = plist_get("lever", spec))
          max(thread[1], thread[1] / 2 + lever[2] + max(lever[0], lever[1]) / 2)]));

function _control_panel_switch_y(i, gap=control_panel_row_gap, center=true) =
  gap * i + (i > 0 ? sum(y_sizes, i) : 0) + y_sizes[i]
  - (center ? total_len / 2 + y_sizes[0] / 2 : 0);

/**
  ─────────────────────────────────────────────────────────────────────────────
  control_panel_clearance_regions
  ─────────────────────────────────────────────────────────────────────────────
  Return separate low-panel and tall-lever envelopes for overhead placement.
  **Parameters:**
  - `orientation`: Horizontal mounting orientation, `"wlh"` or `"lwh"`.
  **Returns:** A list of `[minimum_xyz, maximum_xyz]` bounds relative to the
  panel's `[0, 0, 1]` anchor, including its standoffs. The first region covers
  the low panel, switch stems, nuts and mounting hardware. Each later region
  covers one lever in both switch positions. This allows an overhead case to
  overlap the low part without being raised to the full lever height.
 */
function control_panel_clearance_regions(orientation="wlh") =
  assert(orientation == "wlh" || orientation == "lwh",
         "Control clearance regions require horizontal mounting")
  let (z = control_panel_height() - control_panel_thickness,
       low_h = max(standoff_real_h(standoff_desired_body_h, panel_stack_bolt_dia)
                   + plist_get("thread_h", standoff_plist),
                   z + max(control_panel_thickness,
                        max([for (s = control_panel_switch_button_specs)
                          max(plist_get("thread", s)[1], plist_get("nut", s)[1])]))),
       low = [[-full_panel_width/2, -full_panel_len/2, 0],
              [full_panel_width/2, full_panel_len/2, low_h]],
       regions = concat([low],
         [for (i = [0:len(control_panel_switch_button_specs)-1])
           let (spec = control_panel_switch_button_specs[i],
                bounds = toggle_switch_lever_bounds(plist_get("thread", spec), plist_get("lever", spec)),
                pos = [0, _control_panel_switch_y(i), z])
           [bounds[0] + pos, bounds[1] + pos]]))
  orientation == "wlh" ? regions
  : [for (b = regions) [[-b[1][1], b[0][0], b[0][2]],
                        [-b[0][1], b[1][0], b[1][2]]]];

module control_panel_slots(specs=control_panel_switch_button_specs,
                           gap=control_panel_row_gap,
                           center=true,
                           slot_mode=false) {

  maybe_translate([0, center ? -total_len / 2 - y_sizes[0] / 2 : 0, 0]) {
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
           y = _control_panel_switch_y(i, gap, center=false)) {

        translate([0, y, 0]) {
          if (!slot_mode) {
            translate([0, 0, -terminal_size[2] - size[2]]) {
              toggle_switch(size                             = size,
                            thread_d                         = thread_d,
                            thread_h                         = thread_h,
                            nut_d                            = nut_d,
                            nut_bore_h                       = nut_bore_h,
                            lever_dia_1                      = lever_dia_1,
                            lever_dia_2                      = lever_dia_2,
                            lever_h                          = lever_h,
                            terminal_size                    = terminal_size,
                            center_y                         = true,
                            thread_border_w                  = thread_border_w,
                            metallic_head_h                  = metallic_head_h);
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

/**
  ─────────────────────────────────────────────────────────────────────────────
  control_panel
  ─────────────────────────────────────────────────────────────────────────────
  Render a standalone panel or its four matching chassis mounting cutters.

  **Parameters:**
  - `specs`: Switch hardware specifications.
  - `gap`: Gap between switch rows.
  - `show_buttons`: Display the switches.
  - `show_standoff`: Include supporting standoffs.
  - `center`: Legacy XY centering; used only when anchor is omitted.
  - `min_standoff_h`: Minimum supporting standoff body length.
  - `show_bolt`: Display the lower mounting screws.
  - `show_nut`: Display nuts on the upper studs.
  - `bolt_head_type`: Mounting screw head style.
  - `bolt_color`: Fastener display color.
  - `bolt_visible_h`: Length of screw outside the supporting standoff.
  - `panel_color`: Printed panel color.
  - `size`: Canonical panel footprint [width, length].
  - `bolt_spacing`: Canonical mounting-hole center spacing [x, y].
  - `anchor`: Final oriented reference-box anchor.
  - `orientation`: One of the six with_orientation axis conventions.
  - `anchor_mode`: Use the structural size or mounting-hole spans as the reference.
  - `slot_mode`: Emit parent mounting cutters instead of the component.
  - `slot_thickness`: Parent cutter depth along canonical Z.
  - `slot_bore_h`: Parent counterbore depth.

  The existing hardware, color, size and bolt-spacing arguments configure the
  canonical panel. `center` is retained for older callers; an explicit `anchor`
  takes precedence. With neither supplied, placement uses `[1, 1, 1]`.
  `orientation` accepts the six `with_orientation` conventions. `anchor_mode`
  selects the structural `"size"` box or the `"bolts"` box at the mounting plane.
  `slot_mode` cuts the parent using `slot_thickness` and `slot_bore_h`; it retains
  the solid's reference height and anchor regardless of cutter depth.
 */
module control_panel(specs=control_panel_switch_button_specs,
                     gap=control_panel_row_gap,
                     show_buttons=true,
                     show_standoff=true,
                     center=undef,
                     min_standoff_h=standoff_desired_body_h,
                     show_bolt=false,
                     show_nut=false,
                     bolt_head_type="hex",
                     bolt_color=matte_black,
                     bolt_visible_h=chassis_thickness - standoff_bore_h,
                     panel_color = white_snow_1,
                     size=[full_panel_width, full_panel_len],
                     bolt_spacing=panel_bolt_spacing,
                     anchor=undef,
                     orientation="wlh",
                     anchor_mode="size",
                     slot_mode=false,
                     slot_thickness=chassis_thickness,
                     slot_bore_h=chassis_counterbore_h) {
  assert(anchor_mode == "size" || anchor_mode == "bolts");
  resolved_anchor = is_undef(anchor)
    ? (is_undef(center) || !center ? [1, 1, 1] : [0, 0, 1]) : anchor;
  reference = anchor_mode == "bolts" ? concat(bolt_spacing, [0])
    : [size[0], size[1], control_panel_height(show_standoff, min_standoff_h)];
  with_orientation(from="wlh", to=orientation, size=reference, anchor=resolved_anchor) {
    if (slot_mode) {
      four_corner_children(size=bolt_spacing, center=true) {
        counterbore(d=panel_stack_bolt_dia, h=slot_thickness,
                    bore_d=panel_stack_bolt_cbore_dia, bore_h=slot_bore_h);
      }
    } else {
      _control_panel(specs=specs,
                      gap=gap,
                      show_buttons=show_buttons,
                      show_standoff=show_standoff,
                      min_standoff_h=min_standoff_h,
                      show_bolt=show_bolt,
                      show_nut=show_nut,
                      bolt_head_type=bolt_head_type,
                      bolt_color=bolt_color,
                      bolt_visible_h=bolt_visible_h,
                      panel_color=panel_color,
                      size=size,
                      bolt_spacing=bolt_spacing,
                      center=true);
    }
  }
}

module _control_panel(specs=control_panel_switch_button_specs,
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
  panel_z = control_panel_height(show_standoff, min_standoff_h) - control_panel_thickness;
  full_w = size[0];
  full_l = size[1];

  translate([center ? 0 : full_w / 2,
             center ? 0 : full_l / 2,
             panel_z]) {
    union() {
      difference() {
        color(panel_color, alpha=1) {
          linear_extrude(height=control_panel_thickness,
                         center=false,
                         convexity=2) {
            rounded_rect(size=size,
                         center=true,
                         fn=$fn > 0 ? ceil($fn / 4) * 4 : 32,
                         r_factor=panel_stack_corner_radius_factor);
          }
        }

        four_corner_counterbores(size=bolt_spacing,
                                 center=true,
                                 d=panel_stack_bolt_dia,
                                 h=control_panel_thickness,
                                 bore_h=standoff_bore_h,
                                 reverse=true,
                                 autoscale_step=0.1,
                                 bore_d=panel_stack_bolt_cbore_dia,
                                 sink=false);

        control_panel_slots(specs=specs,
                            gap=gap,
                            slot_mode=true,
                            center=true);
      }
      if (show_buttons) {
        control_panel_slots(specs=specs, gap=gap, slot_mode=false);
      }
      if (show_standoff) {
        translate([0,
                   0,
                   -standoff_real_h(min_standoff_h, panel_stack_bolt_dia) + standoff_bore_h]) {
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

control_panel(show_buttons=false,
              show_standoff=true,
              center=true);
