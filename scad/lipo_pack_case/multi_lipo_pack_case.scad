/**
  * Module: Multi LiPo pack case.
  *
  * This file sizes and renders an orientation-aware case for one or more LiPo
  * pack placeholders.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../bolt_parameters.scad>
include <../colors.scad>
include <../steering_params.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/lipo_pack.scad>
use <../placeholders/nut.scad>
use <../placeholders/standoff.scad>

function _multi_lipo_pack_sum_before(values, index) =
  index <= 0 ? 0 : sum([for (i = [0 : index - 1]) values[i]]);

function _multi_lipo_pack_inner_size(pack_sizes,
                                     layout_axis,
                                     inner_t,
                                     l_clearance,
                                     w_clearance) =
  let (pack_n = len(pack_sizes),
       widths = map_idx(pack_sizes, 0),
       lengths = map_idx(pack_sizes, 1),
       dividers = inner_t * max(0, pack_n - 1))
  layout_axis == "x"
  ? [sum(widths) + w_clearance * pack_n + dividers,
     max(lengths) + l_clearance]
  : [max(widths) + w_clearance,
     sum(lengths) + l_clearance * pack_n + dividers];

function _multi_lipo_pack_layout_score(size) =
  min(size) <= 0 ? 1e12 : max(size) / min(size);

function _multi_lipo_pack_positions(pack_sizes,
                                    layout_axis,
                                    inner_size,
                                    left_t,
                                    rear_t,
                                    bottom_t,
                                    inner_t,
                                    l_clearance,
                                    w_clearance) =
  let (widths = map_idx(pack_sizes, 0),
       lengths = map_idx(pack_sizes, 1),
       x_steps = [for (size = pack_sizes) size[0] + w_clearance + inner_t],
       y_steps = [for (size = pack_sizes) size[1] + l_clearance + inner_t])
  [for (i = [0 : len(pack_sizes) - 1])
      layout_axis == "x"
        ? [left_t + w_clearance / 2 + _multi_lipo_pack_sum_before(x_steps, i),
           rear_t + (inner_size[1] - lengths[i]) / 2,
           bottom_t]
        : [left_t + (inner_size[0] - widths[i]) / 2,
           rear_t + l_clearance / 2 + _multi_lipo_pack_sum_before(y_steps, i),
           bottom_t]];

/**
  ──────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_vent_props
  ─────────────────────────────────────────────────────────────────────────────

  Resolve one wall's vent dimensions, edge padding, and centered grid.

  `vent_pad` supplies the fallback for all four edges. The optional
  `vent_pad_left`, `vent_pad_right`, `vent_pad_bottom`, and `vent_pad_top`
  values override their respective edges. Horizontal percentages use `span`;
  vertical percentages use `wall_h`.

  **Parameters:**

  `wall`: Wall plist containing the vent properties.
  `span`: Usable panel direction before vent padding.
  `wall_h`: Wall height before vent padding.

  **Returns:**

  A plist with `enabled`, `slot_size`, `gap`, `padding`, `count`, and `start`.
  `padding` is `[left, right, bottom, top]`, `count` is `[columns, rows]`, and
  `start` is the first slot's span/Z position relative to the panel origin.
 */
function multi_lipo_pack_vent_props(wall, span, wall_h) =
  let (vent_w_spec = plist_get("vent_w", wall),
       vent_h_spec = plist_get("vent_h", wall))
  is_undef(vent_w_spec) || is_undef(vent_h_spec)
  ? ["enabled", false]
  : let (common_pad = plist_get("vent_pad", wall, 0),
         left_pad = maybe_percent_string_to_num(plist_get("vent_pad_left",
                                                          wall,
                                                          common_pad),
                                                span),
         right_pad = maybe_percent_string_to_num(plist_get("vent_pad_right",
                                                           wall,
                                                           common_pad),
                                                 span),
         bottom_pad = maybe_percent_string_to_num(plist_get("vent_pad_bottom",
                                                            wall,
                                                            common_pad),
                                                  wall_h),
         top_pad = maybe_percent_string_to_num(plist_get("vent_pad_top",
                                                         wall,
                                                         common_pad),
                                               wall_h),
         available_span = max(0, span - left_pad - right_pad),
         available_h = max(0, wall_h - bottom_pad - top_pad),
         vent_w = maybe_percent_string_to_num(vent_w_spec, available_span),
         vent_h = maybe_percent_string_to_num(vent_h_spec, available_h),
         col_gap = maybe_percent_string_to_num(plist_get("vent_col_gap",
                                                         wall,
                                                         vent_w),
                                               available_span),
         row_gap = maybe_percent_string_to_num(plist_get("vent_row_gap",
                                                         wall,
                                                         vent_h), available_h))
                                                         assert(min([left_pad, right_pad, bottom_pad, top_pad]) >= 0,
                                                                "vent padding must not be negative")
                                                         assert(vent_w >= 0 && vent_h >= 0 && col_gap >= 0 && row_gap >= 0,
                                                                "vent sizes and gaps must not be negative")
                                                         let (cols = vent_w > 0 && vent_w <= available_span
                                                              ? max(1, floor((available_span + col_gap) / (vent_w + col_gap)))
                                                              : 0,
                                                              rows = vent_h > 0 && vent_h <= available_h
                                                              ? max(1, floor((available_h + row_gap) / (vent_h + row_gap)))
                                                              : 0,
                                                              used_span = cols > 0 ? cols * vent_w + (cols - 1) * col_gap : 0,
                                                              used_h = rows > 0 ? rows * vent_h + (rows - 1) * row_gap : 0,
                                                              span_start = left_pad + (available_span - used_span) / 2,
                                                              z_start = bottom_pad + (available_h - used_h) / 2)
                                                              ["enabled", true,
                                                               "slot_size", [vent_w, vent_h],
                                                               "gap", [col_gap, row_gap],
                                                               "padding", [left_pad, right_pad, bottom_pad, top_pad],
                                                               "available_size", [available_span, available_h],
                                                               "count", [cols, rows],
                                                               "start", [span_start, z_start]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_props
  ──────────────────────────────────────────────────────────────────────────────

  Compute the complete layout and oriented envelope of a multi-pack case.

  Each pack plist owns its logical `size` and `orientation`. The case plist may
  set `pack_layout` to `"x"`, `"y"`, or `"auto"` (default). Auto layout chooses
  the candidate footprint with the lower aspect ratio. The case's optional
  `orientation` is applied after its canonical layout has been computed.

  **Parameters:**

  `plist`: Case properties, including a non-empty `lipo_packs` list and `walls`.
  Optional `bolt_spacing=[x, y]` entries may be millimeters or percentage
  strings. Percentages use the maximum safe center spacing after the bolt
  diameter and per-axis bolt padding. `bolt_spacing_x` and `bolt_spacing_y`
  override the corresponding vector entries when present. `top_clearance`
  optionally raises the walls above the tallest pack (default zero).
  `mount_nut_pockets=true` seats retaining nuts below the floor's top surface
  for male-stud standoffs; the floor must be thicker than the stud length.
  `mount_ear_d`: Optional diameter of floor mounting ears (default zero).
  Ears connect outboard bolt centers to the case floor without widening the
  battery cavity. `size`/`canonical_size` include them; `body_size` does not.
  `l_clearance`: Total Y clearance assigned to each pack cell.
  `w_clearance`: Total X clearance assigned to each pack cell.

  **Returns:**

  A plist containing `size` (final oriented envelope), `canonical_size`,
  `body_size` (canonical case without ears), `inner_size`, `pack_sizes`,
  `pack_positions` (relative to the body minimum), `pack_layout`, `orientation`,
  canonical `bolt_spacing`, and `max_bolt_spacing`.
 */
function multi_lipo_pack_props(plist,
                               l_clearance=0.4,
                               w_clearance=0.4) =
  let (walls = plist_get("walls", plist),
       lipo_packs = plist_get("lipo_packs", plist, []))
  assert(is_list(lipo_packs) && len(lipo_packs) > 0,
         "lipo_packs must contain at least one pack plist")
  let (pack_sizes = [for (pack = lipo_packs) lipo_pack_oriented_size(pack)],
       pack_n = len(pack_sizes),
       front = plist_get("front", walls),
       rear = plist_get("rear", walls),
       bottom = plist_get("bottom", walls),
       left = plist_get("left", walls),
       right = plist_get("right", walls),
       inner = plist_get("inner", walls),
       front_t = plist_get("front_t", plist, plist_get("t", front)),
       rear_t = plist_get("rear_t", plist, plist_get("t", rear)),
       bottom_t = plist_get("bottom_t", plist, plist_get("t", bottom)),
       left_t = plist_get("left_t", plist, plist_get("t", left)),
       right_t = plist_get("right_t", plist, plist_get("t", right)),
       inner_t = plist_get("inner_t", plist, plist_get("t", inner)),
       x_inner_size = _multi_lipo_pack_inner_size(pack_sizes,
                                                  "x",
                                                  inner_t,
                                                  l_clearance,
                                                  w_clearance),
       y_inner_size = _multi_lipo_pack_inner_size(pack_sizes,
                                                  "y",
                                                  inner_t,
                                                  l_clearance,
                                                  w_clearance),
       requested_layout = plist_get("pack_layout", plist, "auto"))
       assert(in_list(requested_layout, ["auto", "x", "y"]),
              "pack_layout must be \"auto\", \"x\", or \"y\"")
       let (layout_axis = requested_layout == "auto"
            ? (_multi_lipo_pack_layout_score(x_inner_size)
               <= _multi_lipo_pack_layout_score(y_inner_size) ? "x" : "y")
            : requested_layout,
            inner_size_2d = layout_axis == "x" ? x_inner_size : y_inner_size,
            top_clearance = plist_get("top_clearance", plist, 0),
            base_h = assert(top_clearance >= 0, "top_clearance must be nonnegative")
            max(map_idx(pack_sizes, 2)) + top_clearance,
            inner_size = concat(inner_size_2d, [base_h]),
            canonical_size = [left_t + inner_size[0] + right_t,
                              rear_t + inner_size[1] + front_t,
                              bottom_t + base_h],
            case_orientation = assert_orientation(plist_get("orientation",
                                                            plist,
                                                            "wlh"),
                                                  "case orientation"),
            pack_positions = _multi_lipo_pack_positions(pack_sizes,
                                                        layout_axis,
                                                        inner_size,
                                                        left_t,
                                                        rear_t,
                                                        bottom_t,
                                                        inner_t,
                                                        l_clearance,
                                                        w_clearance),
            bolt_d = plist_get("bolt_d", plist, 0),
            bolt_pad_x = plist_get("bolt_pad_x", plist, 0),
            bolt_pad_y = plist_get("bolt_pad_y", plist, 0),
            max_bolt_spacing = [max(0,
                                    inner_size[0]
                                    - bolt_pad_x * 2
                                    - bolt_d),
                                max(0,
                                    inner_size[1]
                                    - bolt_pad_y * 2
                                    - bolt_d)],
            bolt_spacing_spec = plist_get("bolt_spacing", plist))
            assert(is_undef(bolt_spacing_spec)
                   || is_list(bolt_spacing_spec) && len(bolt_spacing_spec) == 2,
                   "bolt_spacing must be [x, y]")
            let (bolt_spacing_x = plist_get("bolt_spacing_x",
                                            plist,
                                            is_undef(bolt_spacing_spec)
                                            ? max_bolt_spacing[0]
                                            : bolt_spacing_spec[0]),
                 bolt_spacing_y = plist_get("bolt_spacing_y",
                                            plist,
                                            is_undef(bolt_spacing_spec)
                                            ? max_bolt_spacing[1]
                                            : bolt_spacing_spec[1]),
                 bolt_spacing = [maybe_percent_string_to_num(bolt_spacing_x,
                                                             max_bolt_spacing[0]),
                                 maybe_percent_string_to_num(bolt_spacing_y,
                                                             max_bolt_spacing[1])])
            let (ear_d = plist_get("mount_ear_d", plist, 0),
                 envelope = ear_d > 0
                 ? [max(canonical_size[0], bolt_spacing[0] + ear_d),
                    max(canonical_size[1], bolt_spacing[1] + ear_d), canonical_size[2]]
                 : canonical_size)
            assert(ear_d >= 0, "Mounting ear diameter must be nonnegative")
            ["size", orientation_size(case_orientation, envelope),
             "canonical_size", envelope,
             "body_size", canonical_size,
             "inner_size", inner_size,
             "pack_sizes", pack_sizes,
             "pack_positions", pack_positions,
             "pack_layout", layout_axis,
             "orientation", case_orientation,
             "bolt_spacing", bolt_spacing,
             "max_bolt_spacing", max_bolt_spacing,
             "pack_count", pack_n];

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_mount_height
  ─────────────────────────────────────────────────────────────────────────────
  Return the raised case-bottom Z above the chassis underside.
  **Parameters:**
  - `pl`: Case plist, supplying the mounting bolt diameter.
  - `target_h`: Minimum case-bottom Z, including the parent thickness; zero
    retains the unraised case placement.
  - `parent_thickness`: Chassis thickness below the standoff bodies.
  Standoff lengths are rounded up to available hardware combinations.
 */
function multi_lipo_pack_mount_height(pl, target_h=0, parent_thickness=6) =
  assert(target_h >= 0 && parent_thickness >= 0)
  target_h == 0 ? 0
  : parent_thickness + standoff_real_h(max(0, target_h - parent_thickness),
                                       plist_get("bolt_d", pl));

/**
  ────────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_case
  ────────────────────────────────────────────────────────────────────────────────

  Render an orientation-aware case and its optional LiPo placeholders.

  The case is built canonically with anchor `[0, 0, 1]`, then reoriented as a
  complete component. `slot_mode` emits the mounting cutters in the same final
  coordinate system and anchor as solid mode.

  **Parameters:**

  `pl`: Case plist accepted by `multi_lipo_pack_props()`.
  `anchor`: Anchor of the final oriented case envelope.
  `mount_ear_d`: Optional diameter of floor mounting ears (default zero).
  Ears connect outboard bolt centers to the case floor without widening the
  battery cavity. `size`/`canonical_size` include them; `body_size` does not.
  `l_clearance`: Total Y clearance assigned to each pack cell.
  `w_clearance`: Total X clearance assigned to each pack cell.
  `parent_thickness`: Parent material depth included in mounting cutters.
  `target_h`: Minimum case-bottom Z above the chassis underside, including
  `parent_thickness` for a bottom Z anchor; zero disables raising. Raised mounting
  requires wlh/lwh. Other Z anchors shift the case and parent reference together.
  `show_standoffs`: Display supporting hardware; does not alter case placement.
  `thread_at_top`: Standoff thread direction (raised mounting uses top studs).
  `show_packs`: Whether to render the pack placeholders.
  `slot_mode`: Whether to emit only mounting cutters.

  Outer wall plists may define `vent_w`, `vent_h`, `vent_col_gap`,
  `vent_row_gap`, and `vent_pad`. `vent_pad_left`, `vent_pad_right`,
  `vent_pad_bottom`, and `vent_pad_top` override the common padding for an
  individual edge. Numeric values are millimeters. Horizontal padding
  percentages use the wall span; vertical padding percentages use wall height.
  Vent sizes and gaps use the remaining span or height after padding. The vent
  grid is centered inside that padded area.
 */
module multi_lipo_pack_case(pl,
                            anchor=[0, -1, 0],
                            l_clearance=0.4,
                            w_clearance=0.4,
                            parent_thickness=6,
                            target_h=0,
                            show_standoffs=true,
                            thread_at_top=true,
                            show_packs=false,
                            slot_mode=false) {
  walls = plist_get("walls", pl);
  lipo_packs = plist_get("lipo_packs", pl);
  case_color = plist_get("color", pl);
  corner_r = plist_get("corner_r", pl, 0);

  front = plist_get("front", walls);
  rear = plist_get("rear", walls);
  bottom = plist_get("bottom", walls);
  left = plist_get("left", walls);
  right = plist_get("right", walls);
  inner = plist_get("inner", walls);

  front_t = plist_get("front_t", pl, plist_get("t", front));
  rear_t = plist_get("rear_t", pl, plist_get("t", rear));
  bottom_t = plist_get("bottom_t", pl, plist_get("t", bottom));
  left_t = plist_get("left_t", pl, plist_get("t", left));
  right_t = plist_get("right_t", pl, plist_get("t", right));
  inner_t = plist_get("inner_t", pl, plist_get("t", inner));

  props = multi_lipo_pack_props(pl,
                                l_clearance=l_clearance,
                                w_clearance=w_clearance);
  canonical_size = plist_get("canonical_size", props);
  inner_size = plist_get("inner_size", props);
  pack_sizes = plist_get("pack_sizes", props);
  pack_positions = plist_get("pack_positions", props);
  layout_axis = plist_get("pack_layout", props);
  case_orientation = plist_get("orientation", props);
  bolt_spacing = plist_get("bolt_spacing", props);

  body_size = plist_get("body_size", props);
  w = body_size[0];
  l = body_size[1];
  ear_d = plist_get("mount_ear_d", pl, 0);
  base_h = inner_size[2];
  pack_n = len(lipo_packs);

  bolt_d = plist_get("bolt_d", pl, 0);
  bore_d = plist_get("bore_d", pl);
  bore_h = plist_get("bore_h", pl);
  mount_nut_pockets = plist_get("mount_nut_pockets", pl, false);
  nut_h = mount_nut_pockets ? find_nut_prop("height", bolt_d) : 0;
  nut_d = mount_nut_pockets ? find_nut_prop("outer_dia", bolt_d) / cos(30) : 0;
  stud_h = mount_nut_pockets ? plist_get("thread_h",
                                         calc_standoff_params(bolt_d, 5)[0]) : 0;
  nut_z = stud_h - nut_h;
  assert(!mount_nut_pockets || (bottom_t > stud_h && nut_z > 0),
         "Nut pockets require a floor above the stud ends and solid material beneath the nuts");

  mount_z = multi_lipo_pack_mount_height(pl, target_h, parent_thickness);
  standoffs_real_h = target_h > 0 ? mount_z - parent_thickness : 0;
  assert(target_h == 0 || case_orientation == "wlh" || case_orientation == "lwh",
         "Raised LiPo mounting requires a horizontal case floor");

  inner_corner_r = max(0,
                       corner_r
                       - max([front_t, rear_t, left_t, right_t]));

  module _standoffs(z_anchor=-1, sink=true) {
    four_corner_standoffs(h=standoffs_real_h,
                          parent_thickness=parent_thickness,
                          cbore_d=bore_d,
                          cbore_h=bore_h,
                          z_anchor=z_anchor,
                          bolt_d=bolt_d,
                          thread_at_top=thread_at_top,
                          sink=sink,
                          bolt_spacing=bolt_spacing);
  }

  module _mounting_slots() {
    translate([w / 2, l / 2, parent_thickness]) {
      four_corner_counterbores(size=bolt_spacing,
                               center=true,
                               d=bolt_d,
                               h=parent_thickness + bottom_t,
                               bore_h=bore_h,
                               bore_d=bore_d);
    }
  }

  module _wall_vents(wall,
                     span,
                     wall_h,
                     depth,
                     span_axis="x",
                     x=0,
                     y=0) {
    vent = multi_lipo_pack_vent_props(wall, span, wall_h);

    if (plist_get("enabled", vent, false)) {
      slot_size = plist_get("slot_size", vent);
      gap = plist_get("gap", vent);
      count = plist_get("count", vent);
      start = plist_get("start", vent);
      vent_w = slot_size[0];
      vent_h = slot_size[1];
      col_gap = gap[0];
      row_gap = gap[1];
      cols = count[0];
      rows = count[1];
      span_start = start[0];
      z_start = start[1];

      if (cols > 0 && rows > 0) {
        for (column = [0 : cols - 1], row = [0 : rows - 1]) {
          along = span_start + column * (vent_w + col_gap);
          z = z_start + row * (vent_h + row_gap);

          translate([x + (span_axis == "x" ? along : 0),
                     y + (span_axis == "y" ? along : 0),
                     z]) {
            cube(span_axis == "x"
                 ? [vent_w, depth, vent_h]
                 : [depth, vent_w, vent_h]);
          }
        }
      }
    }
  }

  module _solid_case() {
    union() {
      difference() {
        color(case_color, alpha=1) {
          union() {
            cuboid(size=[w, l, bottom_t], r=corner_r, anchor=[1, 1, 1]);
            if (ear_d > 0) {
              for (x = [-1, 1], y = [-1, 1]) {
                hull() {
                  translate([w/2 + x*bolt_spacing[0]/2,
                             l/2 + y*bolt_spacing[1]/2,
                             0]) {
                    cylinder(d=ear_d, h=bottom_t);
                  }
                  translate([constraint(w/2 + x*bolt_spacing[0]/2, ear_d/2, w-ear_d/2),
                             constraint(l/2 + y*bolt_spacing[1]/2, ear_d/2, l-ear_d/2),
                             0]) {
                    cylinder(d=ear_d, h=bottom_t);
                  }
                }
              }
            }
          }
        }
        translate([w / 2, l / 2, 0]) {
          four_corner_counterbores(size=bolt_spacing,
                                   center=true,
                                   d=bolt_d,
                                   h=bottom_t,
                                   bore_h=bore_h,
                                   bore_d=bore_d,
                                   no_bore=mount_nut_pockets);
          if (mount_nut_pockets) {
            four_corner_children(size=bolt_spacing, center=true) {
              translate([0, 0, nut_z]) {
                cylinder(d=nut_d + 0.3, h=bottom_t - nut_z + 0.1, $fn=6);
              }
            }
          }
        }
      }
      if (mount_nut_pockets && show_standoffs && target_h > 0) {
        translate([w / 2, l / 2, nut_z]) {
          four_corner_children(size=bolt_spacing, center=true) {
            nut(d=bolt_d, outer_d=nut_d, h=nut_h, show_text=false);
          }
        }
      }

      translate([0, 0, bottom_t]) {
        color(case_color, alpha=1) {
          difference() {
            cuboid(size=[w, l, base_h],
                   r=corner_r,
                   anchor=[1, 1, 1]);
            translate([left_t, rear_t, -0.01]) {
              cuboid(size=[inner_size[0], inner_size[1], base_h + 0.02],
                     r=inner_corner_r,
                     anchor=[1, 1, 1]);
            }
            _wall_vents(rear,
                        span=inner_size[0],
                        wall_h=base_h,
                        depth=rear_t + 0.2,
                        span_axis="x",
                        x=left_t,
                        y=-0.1);
            _wall_vents(front,
                        span=inner_size[0],
                        wall_h=base_h,
                        depth=front_t + 0.2,
                        span_axis="x",
                        x=left_t,
                        y=l - front_t - 0.1);
            _wall_vents(left,
                        span=inner_size[1],
                        wall_h=base_h,
                        depth=left_t + 0.2,
                        span_axis="y",
                        x=-0.1,
                        y=rear_t);
            _wall_vents(right,
                        span=inner_size[1],
                        wall_h=base_h,
                        depth=right_t + 0.2,
                        span_axis="y",
                        x=w - right_t - 0.1,
                        y=rear_t);
          }
        }
      }

      for (i = [0 : pack_n - 1]) {
        pack_size = pack_sizes[i];
        pack_position = pack_positions[i];

        if (show_packs) {
          translate(pack_position) {
            lipo_pack_from_pl(lipo_packs[i], anchor=[1, 1, 1]);
          }
        }

        if (i < pack_n - 1) {
          color(case_color, alpha=1) {
            if (layout_axis == "x") {
              translate([pack_position[0] + pack_size[0] + w_clearance / 2,
                         rear_t,
                         bottom_t]) {
                cuboid(size=[inner_t, inner_size[1], base_h],
                       anchor=[1, 1, 1]);
              }
            } else {
              translate([left_t,
                         pack_position[1] + pack_size[1] + l_clearance / 2,
                         bottom_t]) {
                cuboid(size=[inner_size[0], inner_t, base_h],
                       anchor=[1, 1, 1]);
              }
            }
          }
        }
      }
    }
  }

  // The raised case and the chassis cutters share XY datums. The cutters
  // stay at the parent plane, regardless of case height or hardware visibility.
  translate([0, 0, slot_mode ? 0 : mount_z]) {
    with_orientation(from="wlh",
                     to=case_orientation,
                     size=canonical_size,
                     anchor=anchor) {
      if (show_standoffs && target_h > 0 && !slot_mode) {
        _standoffs(z_anchor=-1);
      }
      if (slot_mode && target_h > 0) {
        four_corner_children(size=bolt_spacing, center=true) {
          counterbore(h=parent_thickness,
                      d=bolt_d,
                      bore_d=bore_d,
                      bore_h=bore_h,
                      reverse=true,
                      sink=true);
        }
      } else {
        with_anchor(anchor=[0, 0, 1], size=body_size) {
          if (slot_mode) {
            _mounting_slots();
          } else {
            _solid_case();
          }
        }
      }
    }
  }
}

multi_lipo_pack_case(multi_lipo_packs_case, target_h=30);
