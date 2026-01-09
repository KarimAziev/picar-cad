/**
 * Module: Placement modules
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../parameters.scad>

use <../colors.scad>
use <../lib/debug.scad>
use <../lib/functions.scad>
use <../lib/holes.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/text.scad>
use <../lib/transforms.scad>



function slot_spec_is_valid(spec) =
  plist_is(spec)
  && (!plist_has("specs", spec)
      || slot_specs_are_valid(plist_get("specs", spec, [])));

function slot_specs_are_valid(specs) =
  len([for (v = specs) if (!slot_spec_is_valid(v)) 1]) == 0;

function get_rect_sizes(spec) =
  let (recess_size = plist_get("recess_size", spec, [0, 0]),
       slot_size  = plist_get("slot_size", spec, [0, 0]),
       placeholder_size = plist_get("placeholder_size", spec, [0, 0]))
  [slot_size, recess_size, placeholder_size];

function get_rect_sizes_at(i, spec) =
  [for (v = get_rect_sizes(spec)) with_default(v[i], 0)];

function get_rect_max_size_at(i, spec) =
  max(get_rect_sizes_at(i, spec));

function get_counterbore_size_at(i, spec) =
  let (d = plist_get("d", spec, 0),
       bore_d  = plist_get("bore_d", spec, 0),
       placeholder_size = plist_get("placeholder_size", spec, [0, 0]))
  max([d, bore_d, with_default(placeholder_size[i], 0)]);

function get_four_corner_hole_size_at(i, spec) =
  let (d = plist_get("d", spec, 0),
       bore_d  = plist_get("bore_d", spec, 0),
       effective_dia = max(d, bore_d),
       slot_size = plist_get("slot_size", spec, [0, 0]),
       placeholder_size = plist_get("placeholder_size", spec, [0, 0]))
  max((with_default(slot_size[i], 0)
       + effective_dia),
      with_default(placeholder_size[i], 0));

function get_placeholder_size(spec) =
  let (slot_size = plist_get("slot_size", spec, [0, 0]),
       placeholder_size = plist_get("placeholder_size", spec, [0, 0]))
  [with_default(slot_size[0], with_default(placeholder_size[0], 0)),
   with_default(slot_size[1], with_default(placeholder_size[1], 0))];

function is_nested_spec(spec) =
  plist_has("specs", spec);

function get_nested_specs(spec) =
  plist_get("specs", spec, []);

function get_nested_direction(spec, parent_direction="btt") =
  plist_get("direction", spec, parent_direction);

function should_swap_size(spec) =
  let (rotation = plist_get("rotation", spec, 0),
       flipped = abs(rotation) == 90)
  flipped;

function get_spec_base_size(spec, parent_direction="btt") =
  is_nested_spec(spec)
  ? get_total_size(get_nested_specs(spec),
                   direction=get_nested_direction(spec, parent_direction))
  : let (type = plist_get("type", spec),
         fallback_size = get_placeholder_size(spec))
  type == "rect" || type == "custom"
  ? [get_rect_max_size_at(0, spec),
     get_rect_max_size_at(1, spec)]
  : type == "counterbore"
  ? [get_counterbore_size_at(0, spec),
     get_counterbore_size_at(1, spec)]
  : type == "four_corner_holes"
  ? [get_four_corner_hole_size_at(0, spec),
     get_four_corner_hole_size_at(1, spec)]
  : fallback_size;

function get_size_at(i, spec, parent_direction="btt") =
  get_spec_base_size(spec, parent_direction)[i];

function get_x_size(spec, parent_direction="btt") =
  let (base_size = get_spec_base_size(spec, parent_direction),
       swapped = should_swap_size(spec))
  swapped ? base_size[1] : base_size[0];

function get_y_size(spec, parent_direction="btt") =
  let (base_size = get_spec_base_size(spec, parent_direction),
       swapped = should_swap_size(spec))
  swapped ? base_size[0] : base_size[1];

function get_gap_before(spec) =
  plist_get("gap_before", spec, 0);

function get_gap_after(spec) =
  plist_get("gap_after", spec, 0);

function get_gap_x_offset(spec) =
  plist_get("x_offset", spec, 0);

function get_gap_y_offset(spec) =
  plist_get("y_offset", spec, 0);

function get_y_sizes(specs, parent_direction="btt") =
  [for (v = specs) get_y_size(v, parent_direction)];

function get_x_sizes(specs, parent_direction="btt") =
  [for (v = specs) get_x_size(v, parent_direction)];

function get_gaps_before(specs) =
  [for (v = specs) get_gap_before(v)];

function get_gaps_after(specs) =
  [for (v = specs) get_gap_after(v)];

function get_max_x(specs, parent_direction="btt") =
  len(specs) == 0 ? 0 : max(get_x_sizes(specs, parent_direction));

function get_max_y(specs, parent_direction="btt") =
  len(specs) == 0 ? 0 : max(get_y_sizes(specs, parent_direction));

function get_total_x(specs, parent_direction="btt") =
  len(specs) == 0 ? 0 :
  sum(concat(get_x_sizes(specs, parent_direction),
             get_gaps_before(specs),
             get_gaps_after(specs)));

function get_total_len(specs, direction) =
  len(specs) == 0
  ? 0
  : sum(concat((direction == "ltr"
                || direction == "rtl" ?
                get_x_sizes(specs, direction)
                : get_y_sizes(specs, direction)),
               get_gaps_before(specs),
               get_gaps_after(specs)));

function get_total_size(specs, direction) =
  len(specs) == 0
  ? [0, 0]
  : (direction == "ltr"
     || direction == "rtl")
  ? [sum(concat(get_x_sizes(specs, direction),
                get_gaps_before(specs),
                get_gaps_after(specs))),
     get_max_y(specs, direction),]
  : [get_max_x(specs, direction),
     sum(concat(get_y_sizes(specs, direction),
                get_gaps_before(specs),
                get_gaps_after(specs)))];

/**
 *
 * Linear layout helper that places a sequence of “slot” items along one axis
 * (vertical or horizontal), with optional gaps, alignment, offsets, rotation,
 * and debug rendering. Items are described by property-lists (“plists”) in
 * `specs`. The module can also act as a layout engine for arbitrary children.
 *
 * Conceptually this is a 1-D layout:
 * - along Y for `btt` / `ttb`
 * - along X for `ltr` / `rtl`
 *
 * Each item is positioned at its running offset (including gaps) and may be
 * aligned within the cross-axis extent (max size among all items).
 *
 * **Parameters**
 * ----------
 * `specs` : list(plist)
 *   List of item specifications. Each spec must be a plist (see “Spec fields”).
 *
 * `direction` : string = "btt"
 *   Layout direction:
 *   - "btt" bottom-to-top (positive Y)
 *   - "ttb" top-to-bottom (negative Y)
 *   - "ltr" left-to-right (positive X)
 *   - "rtl" right-to-left (negative X)
 *
 * `center` : bool = false
 *   When true, centers the whole laid-out group on its primary axis:
 *   - for "btt"/"ttb": centers on Y
 *   - for "ltr"/"rtl": centers on X
 *   (Cross-axis centering is controlled via `align_to_axle` / `align`.)
 *
 * `align_to_axle` : -1|0|1 = 1
 *   Cross-axis anchoring of the *whole group* relative to the origin using the
 *   max cross size:
 *   -  1 aligns the group to the positive side of the cross axis
 *   -  0 no cross-axis shift
 *   - -1 aligns to the negative side
 *
 * `align_on_primary_axle` : -1|0|1 = 0
 *   Primary-axis anchoring of the *whole group* relative to the origin when
 *   `center == false`. This controls whether the layout starts/ends at the
 *   origin (depending on direction):
 *   -  0 no primary-axis shift (default behavior)
 *   -  1 align the group so its “start” edge sits on the origin
 *        ("ltr"/"btt": start at 0; "rtl"/"ttb": start at total size)
 *   - -1 align the group so its “end” edge sits on the origin
 *        ("ltr"/"btt": end at -total size; "rtl"/"ttb": end at 0)
 *
 * `align` : -1|0|1 = 0
 *   Default per-item alignment on the cross-axis within the group envelope:
 *   -  1 align to positive side
 *   -  0 center
 *   - -1 align to negative side
 *   Can be overridden per item via spec field `"align"`.
 *
 * `use_children` : bool = false
 *   If true and children are provided, uses `children()` as the geometry for
 *   each placed item (placeholders). If false, renders builtin item types
 *   (rect / counterbore / four_corner_holes). For `"custom"` specs, children
 *   are used when `use_children==false` as well.
 *
 * `thickness` : number = 3
 *   Z thickness used by builtin slot generators and debug visuals.
 *   (Assumed to be extruded “up” from Z=0; not centered on Z.)
 *
 * `debug` : bool = false
 *   If true, draws index labels at each item position.
 *
 * `show_borders` : bool = false
 *   If true, draws a border box for each item’s computed footprint
 *   (useful to debug sizing / alignment).
 *
 * Special variables set for children
 * ---------------------------------
 * `$spec` : plist
 *   The spec of the current item.
 * `$i` : number
 *   Index of the current item in `specs`.
 * `$custom` : bool
 *   True when the current spec is `"custom"` and builtin rendering is disabled.
 *
 * Spec fields (per item)
 * ----------------------
 * Common fields:
 * - `"type"`: One of `"rect"`, `"counterbore"`, `"four_corner_holes"`, `"custom".`
 * - `"slot_size"` : [x,y] Nominal footprint of the item for layout and (for "rect") geometry.
 * - `"gap_before"` and `"gap_after"` : Spacing inserted before/after this item in the running direction.
 * - `"x_offset"`and `"y_offset"` : number
 *     Additional per-item offset (applied with layout direction sign).
 * - `"rotation"` : degrees (default 0)
 *     Rotation around Z applied to the rendered geometry. Size computation
 *     swaps X/Y when rotation is ±90° to keep layout consistent.
 * - `"align"` : -1|0|1
 *     Overrides the module-level `align` for this item.
 * - `"debug"` : bool,
 * - `"debug_text"` : Plist or string. Optional per-item debug controls (shown when not using children).
 * - `"placeholder_size"` : [x,y], Alternative footprint used for size computation (useful with children).
 *
 * Nested layout fields:
 * - `"specs"` : list(plist). When present, renders a nested `slot_layout` using these specs.
 * - `"direction"` : string. Direction passed to the nested layout (defaults to the parent `direction`).
 * - `"center"`, `"align"`, `"align_to_axle"`, `"align_on_primary_axle"` :
 *     Optional overrides forwarded to the nested layout.
 * - `"use_children"`, `"show_borders"`, `"debug"`, `"thickness"` :
 *     Optional rendering overrides forwarded to the nested layout.
 *
 *
 * `"rect"` fields:
 * - `"corner_rad"`, `"corner_factor"`, `"round_side"`
 * - "`recess_h"`, `"recess_size"`, `"recess_corner_rad"`, `"recess_reverse"`
 *
 * `"counterbore"` fields:
 * - `"d"`, and optional fields `"bore_d"`, `"bore_h"`, `"sink"`, `"bore_reverse".`
 *
 * `""four_corner_holes"` fields:
 * - Same as "counterbore" plus uses "slot_size" for hole pattern extent.
 */

module slot_layout(specs,
                   direction = "btt",
                   center = false,
                   debug = false,
                   align = 0,
                   align_to_axle = 1,
                   align_on_primary_axle = 0,
                   use_children=false,
                   show_borders=false,
                   thickness=3) {

  // was_valid = slot_specs_are_valid(specs);

  // if (!was_valid) {
  //   specs =plist_get("specs", specs);
  //   direction = plist_get("direction", plist,  "btt");
  //   center = plist_get("center", plist,  false);
  //   debug = plist_get("debug", plist,  false);
  //   align = plist_get("align", plist,  0);
  //   align_to_axle = plist_get("align_to_axle", plist,  1);
  //   align_on_primary_axle = plist_get("align_on_primary_axle", plist,  0);
  //   use_children = plist_get("use_children", plist, false);
  //   show_borders = plist_get("show_borders", plist, false);
  // }

  align = with_default(align, 0);
  align_to_axle = with_default(align_to_axle, 1);
  global_debug = debug;

  assert(member(direction, ["btt", "ttb", "ltr", "rtl"]), "Invalid direction");

  assert(member(align, [0, 1, -1]),
         str("Invalid align ", align, " should be 1, 0 or -1"));

  assert(member(align_to_axle, [0, 1, -1]),
         str("Invalid align to axle: ", align_to_axle,
             " but should be 1, 0 or -1"));

  assert(slot_specs_are_valid(specs),
         "Provided specs are not list of plists");

  mapped_specs = specs;
  x_sizes = get_x_sizes(mapped_specs, direction);
  y_sizes = get_y_sizes(mapped_specs, direction);
  gaps_before = get_gaps_before(mapped_specs);
  gaps_after = get_gaps_after(mapped_specs);
  max_x_size = get_max_x(mapped_specs, direction);
  max_y_size = get_max_y(mapped_specs, direction);

  is_ltr = direction == "ltr";
  is_btt = direction == "btt";
  is_ttb = direction == "ttb";

  y_axle = is_ttb || is_btt;

  x_axle = !y_axle;

  total_size = get_total_size(specs, direction);
  total_x = total_size[0];
  total_y = total_size[1];

  group_x = y_axle
    ? (max_x_size / 2 * align_to_axle)
    : center
    ? total_x / 2
    : align_on_primary_axle == 1
    ? (is_ltr ? 0 : total_x)
    : align_on_primary_axle == -1
    ? (is_ltr ? -total_x : 0)
    : 0;

  group_y = x_axle
    ? (max_y_size / 2 * align_to_axle)
    : center
    ? total_y / 2
    : align_on_primary_axle == 1
    ? (is_btt ? 0 : total_y)
    : align_on_primary_axle == -1
    ? (is_btt ? -total_y : 0)
    : 0;

  ratio = (is_ltr || is_btt) ? 1 : -1;

  translate([group_x, group_y, 0]) {
    if (global_debug) {
      translate([y_axle ? max_y_size : 0,
                 x_axle ? max_x_size : 0,
                 thickness + 0.5]) {

        #text_from_plist(str("Total X ", total_x, " , total Y, ", total_y),
                         default_height=0.5);
      }
    }
    for (i = [0 : len(mapped_specs) - 1]) {
      let (spec = specs[i],
           spec_type = plist_get("type", spec),
           nested = is_nested_spec(spec),
           nested_specs = get_nested_specs(spec),
           direction = get_nested_direction(spec, direction),
           debug = plist_get("debug", spec),
           debug_text = plist_get("debug_text", spec),
           prev_y_acc = sum(y_sizes, i),
           prev_x_acc = sum(x_sizes, i),
           prev_gap_after = sum(gaps_after, i),
           prev_gap_before = sum(gaps_before, i),
           curr_gap_before = get_gap_before(spec),
           rotation = plist_get("rotation", spec, 0),
           align_self = plist_get("align", spec, align),
           align_self_x = y_axle ? align_self : 0,
           align_self_y = x_axle ? align_self : 0,
           slot_size = plist_get("slot_size", spec, [0, 0]),
           x_offset = plist_get("x_offset", spec, 0),
           y_offset = plist_get("y_offset", spec, 0),
           curr_x = x_sizes[i],
           curr_y = y_sizes[i],
           gap_acc = sum([prev_gap_after,
                          prev_gap_before,
                          curr_gap_before]),
           x_acc = y_axle ? 0 : ratio * sum([prev_x_acc, gap_acc, curr_x / 2]),
           y_acc = x_axle ? 0 : ratio * sum([prev_y_acc, gap_acc, curr_y / 2]),
           x_align = align_self_x * (max_x_size / 2 - curr_x / 2),
           y_align = align_self_y * (max_y_size / 2 - curr_y / 2),
           final_y = y_acc + y_align + ratio * y_offset,
           final_x = x_acc + x_align + ratio * x_offset) {

        assert(member(align_self, [0, 1, -1]),
               str("'", spec_type, "'", " item at idx ", "'", i,
                   "'", "has invalid align ", align, " should be 1, 0 or -1"));
        translate([final_x,
                   final_y + (align_self_y * (max_y_size / 2 - curr_y / 2)),
                   0]) {
          if (global_debug) {
            let (txt = str(i)) {
              %translate([0, 0, thickness]) {
                translate([0, 0, thickness + 1]) {
                  #text_from_plist(txt);
                }
              }
            }
          }

          if (show_borders) {
            #difference() {
              cube_3d(size=[curr_x,
                            curr_y,
                            thickness]);
              translate([0, 0, -0.5]) {
                cube_3d(size=[curr_x - 1,
                              curr_y - 1,
                              thickness + 1]);
              }
            }
          }

          $spec = spec;
          $i = i;
          $custom = !use_children && spec_type == "custom";

          rotate([0, 0, rotation]) {

            if (nested) {
              slot_layout(specs=nested_specs,
                          direction=direction,
                          center=plist_get("center", spec, center),
                          debug=plist_get("debug", spec, debug),
                          align=plist_get("align", spec, align),
                          align_to_axle=plist_get("align_to_axle",
                                                  spec,
                                                  align_to_axle),
                          align_on_primary_axle=plist_get("align_on_primary_axle",
                                                          spec,
                                                          align_on_primary_axle),
                          use_children=plist_get("use_children",
                                                 spec,
                                                 use_children),
                          show_borders=plist_get("show_borders",
                                                 spec,
                                                 show_borders),
                          thickness=plist_get("thickness",
                                              spec,
                                              thickness)) {
                children();
              }
            } else if (use_children && $children) {
              children();
            } else {
              if (debug && !is_undef(debug_text)) {
                text_from_plist(debug_text);
              }
              debug_highlight(debug=debug) {
                if (spec_type == "rect") {
                  let (recess_h = plist_get("recess_h", spec, 0),
                       recess_size = plist_get("recess_size", spec, 0),
                       round_side = plist_get("round_side", spec, 0),
                       corner_rad = plist_get("corner_rad", spec),
                       recess_corner_rad = plist_get("recess_corner_rad",
                                                     spec,
                                                     corner_rad),
                       corner_factor = plist_get("corner_factor", spec, 0.3),
                       reverse = plist_get("recess_reverse", spec, false)) {
                    rect_slot(size=[with_default(slot_size[0], 0),
                                    with_default(slot_size[1], 0)],
                              recess_size=recess_size,
                              recess_h=recess_h,
                              h=thickness,
                              r=corner_rad,
                              recess_corner_r=recess_corner_rad,
                              r_factor=corner_factor,
                              side=round_side,
                              reverse=reverse,
                              center=true);
                  }
                } else if (spec_type == "four_corner_holes") {
                  let (d = plist_get("d", spec, 0),
                       bore_h = plist_get("bore_h", spec, 0),
                       bore_d = plist_get("bore_d", spec, 0),
                       sink = plist_get("sink", spec, false),
                       reverse = plist_get("bore_reverse", spec, false)) {
                    four_corner_children(size=[with_default(slot_size[0], 0),
                                               with_default(slot_size[1], 0)],
                                         center=true) {
                      counterbore(d=d,
                                  bore_d=bore_d,
                                  h=thickness,
                                  sink=sink,
                                  bore_h=bore_h,
                                  reverse=reverse);
                    }
                  }
                } else if (spec_type == "counterbore") {
                  let (d = plist_get("d", spec, 0),
                       bore_h = plist_get("bore_h", spec, 0),
                       bore_d = plist_get("bore_d", spec, 0),
                       sink = plist_get("sink", spec, false),
                       reverse = plist_get("bore_reverse", spec, false)) {
                    counterbore(d=d,
                                bore_d=bore_d,
                                sink=sink,
                                h=thickness,
                                bore_h=bore_h,
                                reverse=reverse);
                  }
                } else if ($custom) {
                  children();
                }
              }
            }
          }
        }
      }
    }
  }
}

module slot_grid_rows(nested_specs,
                      center = false,
                      align_to_axle = 1,
                      use_children=false,
                      show_borders=false,
                      direction = "btt", // "btt" (bottom to top, default) or "ttb" (top to bottom)
                      cols_direction = "ltr", // | "ltr" | "rtl",
                      debug = false,
                      align = 1,
                      thickness=3) {
  row_sizes = [for (v = nested_specs)
      get_total_size(v, direction=cols_direction)[1]];

  translate([0, 0, 0]) {
    for (i = [0 : len(nested_specs) - 1]) {
      let (specs = nested_specs[i],
           curr_offset = row_sizes[i],
           y_offset = i > 0 ? sum(row_sizes, i) : 0) {
        translate([0,
                   y_offset * (direction == "btt" ? 1 : -1)
                   + curr_offset * (direction == "btt" ? 1 : -1),
                   0]) {
          slot_layout(specs=specs,
                      direction=cols_direction,
                      debug=debug,
                      align=align,
                      thickness=thickness,
                      center=center,
                      align_to_axle=align_to_axle,
                      use_children=use_children,
                      show_borders=show_borders) {
            children();
          };
        }
      }
    }
  }
}

module slot_grid_cols(nested_specs,
                      center = false,
                      align_to_axle = 1,
                      use_children=false,
                      show_borders=false,
                      direction = "ltr", // "btt" (bottom to top, default) or "ttb" (top to bottom)
                      cols_direction = "btt", // | "ltr" | "rtl",
                      debug = false,
                      align = 1,
                      thickness=3) {
  row_sizes = [for (v = nested_specs)
      get_total_size(v, direction=cols_direction)[0]];

  translate([0, 0, 0]) {
    for (i = [0 : len(nested_specs) - 1]) {
      let (specs = nested_specs[i],
           curr_offset = row_sizes[i],
           x_offset = i > 0 ? sum(row_sizes, i) : 0) {
        translate([x_offset * (direction == "ltr" ? 1 : -1)
                   + curr_offset * (direction == "ltr" ? 1 : -1),
                   0,
                   0]) {
          slot_layout(specs=specs,
                      direction=cols_direction,
                      debug=debug,
                      align=align,
                      thickness=thickness,
                      center=center,
                      align_to_axle=align_to_axle,
                      use_children=use_children,
                      show_borders=show_borders) {
            children();
          }
        }
      }
    }
  }
}

rect_spec_example              = ["type", "rect",
                                  "gap_before", 0,
                                  "gap_after", 0,
                                  "slot_size", [10, 20],
                                  "corner_rad", 0,
                                  "corner_factor", 0.3,
                                  "round_side", "all",
                                  "placeholder_size", [10, 20],
                                  "recess_h", 0.5,
                                  "recess_reverse", false,
                                  "recess_size", [],
                                  "x_offset", 0,
                                  "y_offset", 0];

four_corner_holes_spec_example = ["type", "four_corner_holes",
                                  "gap_before", 0,
                                  "gap_after", 0,
                                  "slot_size", [10, 20],
                                  "d", 3,
                                  "bore_d", 5,
                                  "bore_h", 2,
                                  "sink", false,
                                  "placeholder_size", [10, 20],
                                  "bore_reverse", false,
                                  "x_offset", 0,
                                  "y_offset", 0,];

my_specs = [["type", "rect",
             "gap_before", 0,
             "rotation", 0,
             "slot_size", [10, 20],
             "corner_rad", 0,
             "gap_after", 1,
             "x_offset", 0,
             "y_offset", 0],
            ["specs", [["type", "counterbore",
                        "gap_before", 0,
                        "rotation", 0,
                        "d", 9,
                        "corner_factor", 0.5,
                        "round_side", "all",
                        "x_offset", 0,
                        "y_offset", 0],
                       ["specs",
                        [["type", "rect",
                          "gap_before", 0,
                          "rotation", 0,
                          "slot_size", [20, 5],
                          "corner_factor", 0.5,
                          "round_side", "all",
                          "x_offset", 0,
                          "y_offset", 0],
                         ["type", "rect",
                          "gap_before", 0,
                          "rotation", 0,
                          "slot_size", [20, 5],
                          "corner_factor", 0.5,
                          "round_side", "all",
                          "x_offset", 0,
                          "y_offset", 0]],
                        "direction", "ttb",]],
             "direction", "ltr",
             "align_to_axle", 0,
             "align_on_primary_axle", 0,
             "center",  false,
             "gap_before", 0,
             "gap_after", 0,
             "rotation", 0,
             "x_offset", 0,
             "y_offset", 0]];

slot_layout(my_specs,
            direction="ttb",
            align_on_primary_axle=1);