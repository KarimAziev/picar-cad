/**
 * Module: Fuse holder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../core/slot_layout.scad>
use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/atm_fuse_holder/atm_fuse_holder.scad>
use <../placeholders/standoff.scad>

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
                           : max_lid_height;

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

/**
  ─────────────────────────────────────────────────────────────────────────────
  fuse_panel_wire_ports
  ─────────────────────────────────────────────────────────────────────────────
  Return free lead endpoints for the configured centered fuse row.
  **Parameters:**
  - `side`: Canonical holder X end: -1 or +1, before panel orientation.
  - `orientation`: Horizontal panel axis convention: wlh or lwh.
  **Returns:** XYZ endpoints above the panel mounting plane, in fuse row order.
 */
function fuse_panel_wire_ports(side=1, orientation="wlh") =
  let (specs = fuse_panel_plist_specs,
       ys = get_y_sizes(specs, "ttb"),
       before = get_gaps_before(specs),
       after = get_gaps_after(specs),
       total = get_total_size(specs, "ttb")[1])
  [for (i = [0:len(specs) - 1])
      let (pl = specs[i],
           body = plist_get("size", plist_get("body", pl)),
           wire = plist_get("wiring", pl),
           tail = plist_get(side == 1 ? "left_pts" : "right_pts", wire),
           rib = plist_get("thickness", plist_get("rib", plist_get("body", pl)), 1),
           flip = plist_get("cap_to_bottom", pl, false),
           y = total / 2 - sum(ys, i) - sum(before, i) - sum(after, i)
           - before[i] - ys[i] / 2 - plist_get("y_offset", pl, 0),
           pt = [side * ((body[0] - 2 * rib) / 2 + tail[len(tail) - 1][0]),
                 0, (flip ? 1 : -1) * body[2] / 2],
           local = rotZ(pt, plist_get("rotation", pl, 0))
           + [plist_get("x_offset", pl, 0), y,
              fuse_panel_height() - fuse_panel_thickness],
           v = orientation_matrix(orientation) * concat(local, [1]))
        [v[0], v[1], v[2]]];

function fuse_panel_bolt_spacing() = panel_bolt_spacing;

function fuse_panel_size() = [full_panel_width,
                              full_panel_len,
                              fuse_panel_thickness];

function fuse_panel_standoff_upper_height() =
  upper_standoff_height;

/**
  ─────────────────────────────────────────────────────────────────────────────
  fuse_panel_height
  ─────────────────────────────────────────────────────────────────────────────

  Return the height from the mounting plane to the fuse panel's top face.

  **Parameters:**
  - `show_standoff`: Include the supporting standoff height.

  **Returns:** Structural height, excluding fuse holders and fastener protrusions.
 */
function fuse_panel_height(show_standoff=true) =
  (show_standoff ? lower_standoff_height - standoff_bore_h : 0)
  + fuse_panel_thickness;

/**
  ─────────────────────────────────────────────────────────────────────────────
  fuse_panel_oriented_size / fuse_panel_oriented_bolt_spacing
  ─────────────────────────────────────────────────────────────────────────────
  Return the oriented structural box or mounting-center spans as `[x, y, z]`.
  `orientation` accepts the six axis conventions; `show_standoff` includes the
  support height in the structural box. Installed hardware is excluded.
 */
function fuse_panel_oriented_size(orientation="wlh", show_standoff=true) =
  orientation_size(orientation,
                   [full_panel_width, full_panel_len,
                    fuse_panel_height(show_standoff)]);

function fuse_panel_oriented_bolt_spacing(orientation="wlh") =
  orientation_size(orientation, concat(panel_bolt_spacing, [0]));

/**
  ─────────────────────────────────────────────────────────────────────────────
  fuse_panel_clearance_height
  ─────────────────────────────────────────────────────────────────────────────
  Return the installed hardware's upper envelope above the mounting plane.
  `show_standoff` includes the supporting standoffs. Used for overhead clearance,
  independently of hardware visibility in a preview.
 */
function fuse_panel_clearance_height(show_standoff=true) =
  fuse_panel_height(show_standoff) - fuse_panel_thickness
  + max(fuse_panel_thickness, upper_h);

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

/**
  ─────────────────────────────────────────────────────────────────────────────
  fuse_panel
  ─────────────────────────────────────────────────────────────────────────────
  Render a standalone panel or its four matching chassis mounting cutters.

  **Parameters:**
  - `show_fuses`: Display installed fuse holders.
  - `show_standoff`: Include supporting standoffs.
  - `center`: Legacy XY centering; used only when anchor is omitted.
  - `show_cap`: Display the fuse-holder caps.
  - `panel_color`: Printed panel color.
  - `size`: Canonical panel footprint [width, length].
  - `bolt_spacing`: Canonical mounting-hole center spacing [x, y].
  - `show_bolt`: Display the lower mounting screws.
  - `show_nut`: Display nuts on the upper studs.
  - `bolt_head_type`: Mounting screw head style.
  - `bolt_color`: Fastener display color.
  - `bolt_visible_h`: Length of screw outside the supporting standoff.
  - `corner_factor`: Panel corner radius as a fraction of its smaller dimension.
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
module fuse_panel(show_fuses=false,
                  show_standoff=true,
                  center=undef,
                  show_cap=true,
                  panel_color=white_snow_1,
                  size=[full_panel_width, full_panel_len],
                  bolt_spacing=panel_bolt_spacing,
                  show_bolt=false,
                  show_nut=false,
                  bolt_head_type="hex",
                  bolt_color=matte_black,
                  bolt_visible_h=chassis_thickness - standoff_bore_h,
                  corner_factor=panel_stack_corner_radius_factor,
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
    : [size[0], size[1], fuse_panel_height(show_standoff)];
  with_orientation(from="wlh",
                   to=orientation,
                   size=reference,
                   anchor=resolved_anchor) {
    if (slot_mode) {
      four_corner_children(size=bolt_spacing, center=true) {
        counterbore(d=panel_stack_bolt_dia,
                    h=slot_thickness,
                    bore_d=panel_stack_bolt_cbore_dia,
                    bore_h=slot_bore_h,
                    reverse=true);
      }
    } else {
      _fuse_panel(show_fuses=show_fuses,
                  show_standoff=show_standoff,
                  show_cap=show_cap,
                  panel_color=panel_color,
                  size=size,
                  bolt_spacing=bolt_spacing,
                  show_bolt=show_bolt,
                  show_nut=show_nut,
                  bolt_head_type=bolt_head_type,
                  bolt_color=bolt_color,
                  bolt_visible_h=bolt_visible_h,
                  corner_factor=corner_factor,
                  center=true,
                  has_children=$children > 0) {
        children();
      }
    }
  }
}

module _fuse_panel(show_fuses=false,
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
                   corner_factor=panel_stack_corner_radius_factor,
                   has_children=false) {

  full_w = size[0];
  full_l = size[1];

  z = fuse_panel_height(show_standoff) - fuse_panel_thickness;

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
                             fn=$fn > 0 ? ceil($fn / 4) * 4 : 32,
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

        if (has_children) {
          translate([0, 0, fuse_panel_thickness]) {
            if (show_standoff) {
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
            }
            translate([0,
                       0,
                       show_standoff
                       ? fuse_panel_standoff_upper_height() : 0]) {
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
