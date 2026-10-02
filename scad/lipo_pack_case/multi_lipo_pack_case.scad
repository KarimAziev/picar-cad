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
include <../rc_params.scad>

use <../lib/debug.scad>
use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/polygon_util.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../lib/trapezoids.scad>
use <../placeholders/bolt.scad>
use <../placeholders/lipo_pack.scad>
use <../placeholders/nut.scad>
use <../placeholders/standoff.scad>
use <multi_lipo_pack_rail.scad>

show_packs      = true;
show_standoffs  = true;
show_rail_bolts = true;
show_rail_nuts  = true;

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

// Match rounded_rect's percentage basis and clamp while rejecting negative radii.
function _multi_lipo_pack_corner_r(spec, length, height) =
  let (r = maybe_percent_string_to_num(spec, min(length, height)))
  assert(is_num(r) && r >= 0,
         "corner_r must be a nonnegative number or percentage")
  calc_corner_rad([length, height], r);

// Freeze pair radii against the intended profile, before cutter overshoot.
function _multi_lipo_pack_sides(spec, size, r, fallback) =
  let (side = plist_get("side", spec, plist_get("sides", spec, fallback)),
       radii = rounded_rect_corner_radii(size,
                                         is_string(side) ? [side] : side,
                                         r),
       names = ["bottom_left", "bottom_right",
                "top_right", "top_left"])
  [for (i = [0 : 3]) [names[i], radii[i]]];

function _multi_lipo_pack_slots(slots, size) =
  assert(is_list(slots), "slots must be a list of plists")
  [for (slot = slots)
      assert(plist_is(slot), "each slot must be a plist")
        let (pos_spec = plist_get("pos", slot, [0, 0]),
             size_spec = plist_get("size", slot),
             d_spec = plist_get("d", slot))
        assert(is_list(pos_spec) && len(pos_spec) == 2,
               "slot pos must be [x, z]")
        assert(is_undef(d_spec) != is_undef(size_spec),
               "slot needs either d or size")
        assert(is_undef(size_spec) || is_list(size_spec) && len(size_spec) == 2,
               "slot size must be [length, height]")
        let (d = is_undef(d_spec) ? 0 : maybe_percent_string_to_num(d_spec, min(size)),
             dims = is_undef(size_spec) ? [d, d]
             : [for (i = [0 : 1]) maybe_percent_string_to_num(size_spec[i], size[i])],
             pos = [for (i = [0 : 1]) maybe_percent_string_to_num(pos_spec[i], size[i])])
        assert(is_num(d) && d >= 0 && is_num(dims[0]) && is_num(dims[1])
               && min(dims) > 0,
               "slot dimensions must be positive")
        assert(is_num(pos[0]) && is_num(pos[1]) && min(pos) >= 0
               && pos[0] + dims[0] <= size[0] && pos[1] + dims[1] <= size[1],
               "slot must fit its wall/profile reference box")
        let (r = _multi_lipo_pack_corner_r(plist_get("corner_r", slot, 0), dims[0], dims[1]))
        ["pos", pos,
         "size", dims,
         "d", d,
         "corner_r", r,
         "side", _multi_lipo_pack_sides(slot, dims, r, "all")]];

function _multi_lipo_pack_shape_props(wall, length, base_h) =
  let (kind = plist_get("shape", wall),
       spec = plist_get("shape_props", wall, []))
  assert(is_undef(kind) || in_list(kind, ["rect", "trapezoid",
                                          "trapezoid_rounded_top", "custom"]),
         "wall shape must be rect, trapezoid, trapezoid_rounded_top, or custom")
  assert(plist_is(spec), "shape_props must be a plist")
  is_undef(kind) ? ["h", 0] :
  let (h = maybe_percent_string_to_num(plist_get("h", spec, "100%"), base_h),
       top = maybe_percent_string_to_num(plist_get("t", spec, "50%"), length),
       points = plist_get("points", spec, []))
  assert(is_num(h) && h >= 0, "shape h must be nonnegative")
  assert(is_num(top) && top >= 0 && top <= length,
         "shape t must fit wall length")
  assert(kind != "trapezoid_rounded_top" || length == 0 || h == 0 || top > 0,
         "rounded-top trapezoid needs positive t")
  assert(is_list(points) && (kind != "custom" || len(points) >= 3),
         "custom shape needs at least three points")
  let (pts = kind != "custom" ? [] : [for (p = points)
           assert(is_list(p) && len(p) >= 2 && len(p) <= 4,
                  "shape points must be [x, z] with optional debug annotations")
             let (x = maybe_percent_string_to_num(p[0], length),
                  z = maybe_percent_string_to_num(p[1], h))
             assert(is_num(x) && is_num(z) && x >= 0 && x <= length && z >= 0 && z <= h,
                    "shape points must fit its length/height reference box")
             concat([x, z], len(p) > 2 ? [for (i = [2 : len(p) - 1]) p[i]] : [])],
       requested_r = _multi_lipo_pack_corner_r(plist_get("corner_r", spec,
                                                         plist_get("corner_r", wall, 0)), length, h),
       r = kind == "trapezoid_rounded_top"
       ? (length == 0 ? 0 : min(requested_r, top / 2, top * h / (top + length)))
       : requested_r,
       vents = plist_get("vent_props", spec, []),
       debug = plist_get("debug", spec, false),
       round_bottom = plist_get("round_bottom", spec, true),
       radius_specs = plist_get("corner_radii", spec,
                                [for (p = pts) undef]))
  assert(is_bool(debug) && is_bool(round_bottom),
         "shape debug and round_bottom must be booleans")
  assert(kind != "custom" || is_list(radius_specs) && len(radius_specs) == len(pts),
         "custom corner_radii must have one entry per point")
  assert(kind != "custom" || h == 0 || length == 0 || abs(polygon_signed_area(pts)) > 0,
         "custom shape must have nonzero area")
  assert(plist_is(vents), "shape vent_props must be a plist")
  let (radii = kind != "custom" ? [] : [for (i = [0 : len(pts) - 1])
           let (radius = maybe_percent_string_to_num(is_undef(radius_specs[i]) ? requested_r : radius_specs[i],
                                                     min(length, h)))
             assert(is_num(radius) && radius >= 0,
                    "custom corner radii must be nonnegative numbers or percentages")
             !round_bottom && abs(pts[i][1] - polygon_min_y(pts)) < 0.000001
             ? 0 : radius])
  ["kind", kind,
   "h", h,
   "t", top,
   "points", pts,
   "corner_r", r,
   "corner_radii", radii,
   "debug", debug,
   "side", _multi_lipo_pack_sides(spec,
                                  [length, h],
                                  r,
                                  plist_get("side", wall, plist_get("sides", wall, "top"))),
   "vent_props", vents,
   "slots", _multi_lipo_pack_slots(plist_get("slots", spec, []), [length, h])];

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_wall_props
  ─────────────────────────────────────────────────────────────────────────────

  Resolve a wall's bottom band, upper profile, and openings.

  **Parameters:**

  `wall`: Wall plist. With no `shape`, `h` defaults to "100%" of `base_h`.
  With `shape`, `h` is the full-width bottom band's height (default zero),
  and `shape_props.h` adds profile height (default "100%" of `base_h`).
  `l` defaults to "100%" of `span`; `offset` defaults to centering the wall.
  Length and offset percentages use `span`. All dimensions accept mm.

  `corner_r` rounds the bottom band (or the entire unshaped wall), default
  zero. `side` (alias `sides`) accepts rounded_rect side names, lists, and
  `[name, radius]` pairs; default "top". Radius percentages use min(l, h).
  Side names refer to the local span/Z plane: right increases span, top is +Z.

  `shape` accepts "rect", "trapezoid", "trapezoid_rounded_top", or "custom".
  `shape_props` accepts `h`, `corner_r` (inherits wall radius), and:
  - `t`: Trapezoid top width, default "50%" of retained wall length. The
    bottom width is the full retained length. Plain trapezoids stay sharp.
  - `side`/`sides`: Rectangle rounding, inheriting the wall selection.
  - `corner_radii`: Custom-polygon radii in original vertex order. Each entry
    is mm, a percentage of min(retained length, profile height), or `undef`
    to inherit `corner_r`. Zero keeps that vertex sharp. Adjacent fillets
    shrink locally to fit their common edges.
  - `round_bottom`: For custom polygons, false forces the lowest vertices to
    radius zero; default true. This keeps the mounting edge square without
    adding patches. Other vertices still follow corner_r/corner_radii.
  - `debug`: For custom polygons, true overlays original vertex indices using
    debug_polygon_text. Default false. Markers are preview-only background
    geometry, outside wall booleans, and never enter STL/3MF or slot mode.
  - `points`: Custom polygon [span, height] coordinates, numbers or percentages
    of retained length/profile height. Points must fit that reference box.
    Optional third/fourth point fields carry debug_polygon_text annotations.
    Selected corners use tangent arcs, including concave corners, in either
    winding order. Choose radii that clear nonadjacent edges in narrow shapes.
  - `vent_props`: Independent vent grid using the existing vent_* properties,
    measured within the profile box above the band. Default [] disables it.
  - `slots`: Profile-local openings. Wall-level slots use the whole wall box.

  Each slot has `pos=[span, height]` at its bounding-box minimum (default [0,0]),
  and either `size=[length, height]` or circular `d`. Percentages use the
  corresponding reference-box axis; diameter uses its smaller dimension.
  Rectangles accept `corner_r` and `side`/`sides` (default "all"). Slots must
  fit the reference box; their intersection with the wall is removed.

  `cutouts` contains plists with required `l`, optional `h` (depth down from
  the total wall top, default "100%"), and `offset` (default zero). Lengths
  and offsets use retained wall length; depths use total wall height.
  Each cutout accepts `corner_r` (default zero) and `side`/`sides` (default
  "bottom"). Radius percentages use its own min(length, depth), including
  per-side overrides. Wall-level vent properties retain their existing
  whole-wall reference. Openings never cut the floor.

  `edge_r` rounds the finished wall rim through its thickness, after its
  profile, slots, cutouts, and vents are combined, preserving its floor
  attachment outline. Default zero; positive mm
  must be smaller than half the extrusion depth. It removes material and can
  erase features narrower than twice the radius. This is independent of the
  polygon's in-plane corner radii. The case footprint still clips the wall;
  keep a rounded free end clear of shared/case corners if it must remain round.

  `span`: Full available wall length, including outer corner regions.
  `base_h`: Tallest oriented pack height plus the case's `top_clearance`.

  **Returns:**

  A resolved plist with total `h`, `band_h`, `l`, `offset`, `corner_r`, `side`,
  `shape_props`, `slots`, and `cutouts`. Zero total height or length disables
  the wall. The same interface applies to internal dividers. Case envelopes
  use the profile reference box, even when a polygon or rounding occupies less
  of it. Lid rails require rectangular upper profiles on their supporting walls.

  **Examples:**
  ```scad
  multi_lipo_pack_wall_props(
    ["h", "20%", "shape", "trapezoid_rounded_top",
     "shape_props", ["h", "50%", "t", "60%", "corner_r", 2,
                     "slots", [["pos", ["45%", "20%"], "d", 3]]]], 80, 30);
  ```
 */
function multi_lipo_pack_wall_props(wall, span, base_h) =
  let (band_h = maybe_percent_string_to_num(plist_get("h", wall,
                                                      is_undef(plist_get("shape", wall)) ? "100%" : 0), base_h),
       length = maybe_percent_string_to_num(plist_get("l", wall, "100%"), span))
  assert(is_num(band_h) && band_h >= 0,
         "wall h must be a nonnegative number or percentage")
  assert(is_num(length) && length >= 0 && length <= span + 0.000001,
         "wall l must fit its available span")
  let (l = min(length, span),
       shape = _multi_lipo_pack_shape_props(wall, l, base_h),
       h = band_h + plist_get("h", shape),
       r = _multi_lipo_pack_corner_r(plist_get("corner_r", wall, 0), l, band_h),
       offset = maybe_percent_string_to_num(plist_get("offset", wall, (span - l) / 2), span),
       cutouts = plist_get("cutouts", wall, []),
       edge_r = plist_get("edge_r", wall, 0))
  assert(is_num(offset) && offset >= 0 && offset + l <= span + 0.000001,
         "wall offset and l must fit its available span")
  assert(is_list(cutouts), "wall cutouts must be a list of plists")
  assert(is_num(edge_r) && edge_r >= 0, "wall edge_r must be nonnegative mm")
  ["h", h,
   "l", l,
   "offset", offset,
   "band_h", band_h,
   "shape_props", shape,
   "corner_r", r,
   "edge_r", edge_r,
   "side", _multi_lipo_pack_sides(wall, [l, band_h], r, "top"),
   "slots", _multi_lipo_pack_slots(plist_get("slots", wall, []), [l, h]),
   "cutouts", [for (cutout = cutouts)
        let (cut_l = maybe_percent_string_to_num(plist_get("l", cutout), l),
             cut_h = maybe_percent_string_to_num(plist_get("h", cutout, "100%"), h),
             cut_offset = maybe_percent_string_to_num(plist_get("offset", cutout, 0), l))
          assert(is_num(cut_l) && cut_l > 0, "cutout l must be positive")
          assert(is_num(cut_h) && cut_h >= 0 && cut_h <= h,
                 "cutout h must be between zero and wall height")
          assert(is_num(cut_offset) && cut_offset >= 0 && cut_offset + cut_l <= l + 0.000001,
                 "cutout offset and l must fit the retained wall length")
          ["l", cut_l,
           "h", cut_h,
           "offset", cut_offset,
           "corner_r", _multi_lipo_pack_corner_r(plist_get("corner_r", cutout, 0),
                                                 cut_l,
                                                 cut_h),
           "side", _multi_lipo_pack_sides(cutout,
                                          [cut_l, cut_h],
                                          _multi_lipo_pack_corner_r(plist_get("corner_r", cutout, 0), cut_l, cut_h),
                                          "bottom")]]];

/**
  ──────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_vent_props
  ─────────────────────────────────────────────────────────────────────────────

  Resolve one wall's vent dimensions, edge padding, and centered grid.

  `vent_pad` supplies the fallback for all four edges. The optional
  `vent_pad_left`, `vent_pad_right`, `vent_pad_bottom`, and `vent_pad_top`
  values override their respective edges. Horizontal percentages use `span`;
  vertical percentages use `wall_h`. `vent_corner_r` rounds all four corners
  of each opening (default zero). It accepts mm or a percentage of the smaller
  resolved slot dimension and is capped at half that dimension.

  **Parameters:**

  `wall`: Wall plist containing the vent properties.
  `span`: Usable panel direction before vent padding.
  `wall_h`: Wall height before vent padding.

  **Returns:**

  A plist with `enabled`, `slot_size`, `corner_r`, `gap`, `padding`, `count`, and `start`.
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
                                                               "corner_r", _multi_lipo_pack_corner_r(plist_get("vent_corner_r", wall, 0),
                                                                                                     vent_w,
                                                                                                     vent_h),
                                                               "gap", [col_gap, row_gap],
                                                               "padding", [left_pad, right_pad, bottom_pad, top_pad],
                                                               "available_size", [available_span, available_h],
                                                               "count", [cols, rows],
                                                               "start", [span_start, z_start]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_vents
  ─────────────────────────────────────────────────────────────────────────────

  Emit a grid of vent cutters with optional rounding on all four corners.

  **Parameters:**

  `vent`: Resolved properties from `multi_lipo_pack_vent_props()`.
  `depth`: Positive cutter depth through the wall or lid skirt.
  `axis`: Direction of the vent rows, "x" or "y" (default "x").

  **Notes:**

  The grid starts at the origin plus its resolved `start` offset along the
  row axis and Z. Cutter depth extends positively on the other horizontal
  axis. The caller supplies any overshoot needed for through cuts.
 */
module multi_lipo_pack_vents(vent, depth, axis="x") {
  assert(in_list(axis, ["x", "y"]) && is_num(depth) && depth > 0,
         "Vent cutters require axis x/y and positive depth");
  translate([0, axis == "x" ? depth : 0, 0]) {
    rotate([90, 0, axis == "x" ? 0 : 90]) {
      linear_extrude(height=depth) {
        _multi_lipo_pack_vents_2d(vent);
      }
    }
  }
}

module _multi_lipo_pack_vents_2d(vent) {
  if (plist_get("enabled", vent, false)) {
    count = plist_get("count", vent);
    start = plist_get("start", vent);
    gap = plist_get("gap", vent);
    slot = plist_get("slot_size", vent);
    if (count[0] > 0 && count[1] > 0) {
      for (col = [0 : count[0] - 1], row = [0 : count[1] - 1]) {
        translate(start + [col * (slot[0] + gap[0]), row * (slot[1] + gap[1])]) {
          rounded_rect(slot,
                       r=plist_get("corner_r", vent, 0),
                       fn=40,
                       anchor=[1, 1, 1]);
        }
      }
    }
  }
}

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
  sets the reference height above the tallest oriented pack (default zero).
  Wall dimensions, profiles, slots, and cutouts are resolved by
  `multi_lipo_pack_wall_props()`. Wall heights start at the floor's top.
  `front` is maximum Y, `rear` minimum Y, `left` minimum X, and `right`
  maximum X, before case orientation. End-wall lengths run along X; side
  lengths run along Y. Adjacent walls share corner material; cutouts remove
  the shared material too. The `inner` spec applies to every divider.
  Optional `rail` properties enable matching lid rails; see
  `multi_lipo_pack_rail_props()` for the shared dovetail interface.
  `inner_corner_r` optionally overrides the cavity corner radius; zero leaves
  room for square pack corners even when the case exterior is rounded.
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
  canonical `bolt_spacing`, `max_bolt_spacing`, resolved `wall_props`,
  `wall_size` (shell before rails), and `rail_props`. Case envelopes include
  enabled rails; mounting ears still affect only the outer envelope.
  `inner_size[2]` is the reference pack height plus clearance; the case
  shell height follows the tallest enabled wall (including dividers only
  when present), independently of visible pack placeholders.
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
       body_w = left_t + inner_size[0] + right_t,
       body_l = rear_t + inner_size[1] + front_t,
       wall_props = [for (entry = [["front", front, body_w],
                                   ["rear", rear, body_w],
                                   ["left", left, body_l],
                                   ["right", right, body_l],
                                   ["inner", inner, inner_size[layout_axis == "x" ? 1 : 0]]])
           each [entry[0], multi_lipo_pack_wall_props(entry[1], entry[2], base_h)]],
       wall_h = max([for (name = ["front", "rear", "left", "right", "inner"])
                        let (wall = plist_get(name, wall_props))
                          (name != "inner" || pack_n > 1) && plist_get("l", wall) > 0
                          ? plist_get("h", wall) : 0]),
       wall_size = [body_w, body_l, bottom_t + wall_h],
       rail_props = multi_lipo_pack_rail_props(plist, wall_size, wall_props),
       canonical_size = [body_w, body_l,
                         plist_get("enabled", rail_props)
                         ? max(wall_size[2], plist_get("z", rail_props) + plist_get("h", rail_props))
                         : wall_size[2]],
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
   "wall_size", wall_size,
   "rail_props", rail_props,
   "inner_size", inner_size,
   "wall_props", wall_props,
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
  `show_rail_bolts`: Display rail-locking bolts sized for the matching lid.
  `show_rail_nuts`: Include exterior nuts when `show_rail_bolts` is true.
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
                            show_standoffs=show_standoffs,
                            show_rail_bolts=show_rail_bolts,
                            show_packs=show_packs,
                            show_rail_nuts=show_rail_nuts,
                            thread_at_top=true,
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
  wall_props = plist_get("wall_props", props);

  wall_h = plist_get("wall_size", props)[2] - bottom_t;
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

  inner_corner_r = plist_get("inner_corner_r",
                             pl,
                             max(0, corner_r - max([front_t, rear_t, left_t, right_t])));
  assert(is_num(inner_corner_r) && inner_corner_r >= 0,
         "inner_corner_r must be nonnegative");

  // Each panel's local span increases along canonical X (ends) or Y (sides).
  panels = [["rear", rear_t + inner_corner_r, "x", 0, 0, left_t, w - right_t],
            ["front", front_t + inner_corner_r, "x", 0, l - front_t - inner_corner_r, left_t, w - right_t],
            ["left", left_t + inner_corner_r, "y", 0, 0, rear_t, l - front_t],
            ["right", right_t + inner_corner_r, "y", w - right_t - inner_corner_r, 0, rear_t, l - front_t]];

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
    translate([x, y, 0]) {
      multi_lipo_pack_vents(vent, depth, axis=span_axis);
    }
  }

  // Work in a span/Z plane before applying the same X/Y wall placement.
  module _wall_plane(wall,
                     depth,
                     axis,
                     x,
                     y,
                     z=0,
                     overshoot=0,
                     edge_r=0) {
    along = plist_get("offset", wall);
    assert(edge_r == 0 || 2 * edge_r < depth,
           "wall edge_r must be smaller than half the profile extrusion depth");
    translate([x + (axis == "x" ? along : -overshoot),
               y + (axis == "y" ? along : depth + overshoot),
               z]) {
      rotate([90, 0, axis == "x" ? 0 : 90]) {
        if (edge_r > 0) {
          // Erode the finished outline before adding the round cross-section.
          // This removes material at rims without growing into the pack space.
          intersection() {
            linear_extrude(height=depth) {
              children();
            }
            translate([0, 0, edge_r]) {
              minkowski() {
                linear_extrude(height=depth - 2 * edge_r) {
                  offset(delta=-edge_r) {
                    union() {
                      children();
                      // Carry the floor attachment below Z=0 while rounding;
                      // the outer intersection restores the exact base outline.
                      translate([0, -2 * edge_r]) {
                        square([plist_get("l", wall), 2 * edge_r]);
                      }
                    }
                  }
                }
                // OpenSCAD's sampled sphere falls short on every cardinal axis.
                // Compensate that chord error so the wall meets the floor.
                sphere(r=edge_r / cos(180 / 32), $fn=32);
              }
            }
          }
        } else {
          linear_extrude(height=depth + 2 * overshoot) {
            children();
          }
        }
      }
    }
  }

  module _wall_solid(wall,
                     depth,
                     axis,
                     x,
                     y,
                     vent=[],
                     vent_offset=0) {
    length = plist_get("l", wall);
    band_h = plist_get("band_h", wall);
    shape = plist_get("shape_props", wall);
    h = plist_get("h", shape);
    kind = plist_get("kind", shape);
    r = plist_get("corner_r", shape, 0);
    _wall_plane(wall, depth, axis, x, y, edge_r=plist_get("edge_r", wall)) {
      difference() {
        union() {
          if (band_h > 0) {
            rounded_rect([length, band_h],
                         r=plist_get("corner_r", wall),
                         side=plist_get("side", wall),
                         anchor=[1, 1, 1]);
          }
          if (h > 0) {
            translate([0, band_h]) {
              if (kind == "rect") {
                rounded_rect([length, h], r=r, side=plist_get("side", shape));
              } else if (kind == "trapezoid") {
                trapezoid(b=length, t=plist_get("t", shape), h=h);
              } else if (kind == "trapezoid_rounded_top") {
                // The helper centers its bottom around half the top width.
                translate([length / 2, h / 2]) {
                  trapezoid_rounded_top(b=length,
                                        t=plist_get("t", shape),
                                        h=h,
                                        r=r,
                                        center=true,
                                        $fn=40);
                }
              } else if (kind == "custom") {
                polygon(rounded_polygon_points(plist_get("points", shape),
                                               plist_get("corner_radii", shape),
                                               segments=16));
              }
            }
          }
        }
        _wall_cutouts_2d(wall);
        _wall_openings_2d(wall);
        translate([vent_offset, 0]) {
          _multi_lipo_pack_vents_2d(vent);
        }
      }
    }
  }

  module _wall_debug(wall, depth, axis, x, y, opposite=false) {
    shape = plist_get("shape_props", wall);
    if ($preview && plist_get("debug", shape, false)
        && plist_get("kind", shape) == "custom") {
      along = plist_get("offset", wall);
      length = plist_get("l", wall);
      points = plist_get("points", shape);
      labels = opposite ? [for (p = points)
          concat([length - p[0], p[1]],
                 len(p) > 2 ? [for (i = [2 : len(p) - 1]) p[i]] : [])] : points;
      // Background annotations sit outside the wall face and outside all CSG.
      translate([x + (axis == "x" ? along : opposite ? -0.05 : depth + 0.05),
                 y + (axis == "y" ? along : opposite ? depth + 0.05 : -0.05),
                 bottom_t + plist_get("band_h", wall)]) {
        rotate([90, 0, axis == "x" ? 0 : 90]) {
          translate([opposite ? length : 0, 0, 0]) {
            rotate([0, opposite ? 180 : 0, 0]) {
              %debug_polygon_text(labels,
                                  font_size=2,
                                  offset_x=2,
                                  offset_y=2,
                                  h=0.4);
            }
          }
        }
      }
    }
  }

  module _wall_openings_2d(wall) {
    shape = plist_get("shape_props", wall);
    band_h = plist_get("band_h", wall);
    for (entry = [[wall, 0], [shape, band_h]]) {
      translate([0, entry[1]]) {
        for (slot = plist_get("slots", entry[0], [])) {
          pos = plist_get("pos", slot);
          size = plist_get("size", slot);
          translate(pos) {
            if (plist_get("d", slot) > 0) {
              translate(size / 2) {
                circle(d=plist_get("d", slot), $fn=40);
              }
            } else {
              rounded_rect(size,
                           r=plist_get("corner_r", slot),
                           side=plist_get("side", slot));
            }
          }
        }
      }
    }
    if (plist_get("h", shape) > 0) {
      translate([0, band_h]) {
        _multi_lipo_pack_vents_2d(multi_lipo_pack_vent_props(plist_get("vent_props", shape), plist_get("l", wall),
                                                             plist_get("h", shape)));
      }
    }
  }

  module _wall_openings(wall, depth, axis, x, y) {
    _wall_plane(wall, depth, axis, x, y, overshoot=0.1) {
      _wall_openings_2d(wall);
    }
  }

  module _wall_cutouts_2d(wall) {
    for (cutout = plist_get("cutouts", wall)) {
      cut_h = plist_get("h", cutout);
      if (cut_h > 0) {
        translate([plist_get("offset", cutout) - 0.001,
                   plist_get("h", wall) - cut_h]) {
          rounded_rect([plist_get("l", cutout) + 0.002, cut_h + 0.001],
                       r=plist_get("corner_r", cutout),
                       side=plist_get("side", cutout),
                       anchor=[1, 1, 1]);
        }
      }
    }
  }

  module _wall_cutouts(wall, depth, axis, x=0, y=0) {
    _wall_plane(wall, depth, axis, x, y, overshoot=0.1) {
      _wall_cutouts_2d(wall);
    }
  }

  module _solid_case() {
    union() {
      multi_lipo_pack_rails(plist_get("rail_props", props),
                            color=case_color,
                            show_bolts=show_rail_bolts,
                            show_nuts=show_rail_nuts);

      difference() {
        color(case_color, alpha=1) {
          union() {
            cuboid(size=[w, l, bottom_t], r=corner_r, anchor=[1, 1, 1]);
            if (ear_d > 0) {
              for (x = [-1, 1], y = [-1, 1]) {
                hull() {
                  translate([w / 2 + x * bolt_spacing[0] / 2,
                             l / 2 + y * bolt_spacing[1] / 2,
                             0]) {
                    cylinder(d=ear_d, h=bottom_t);
                  }
                  translate([constraint(w / 2 + x * bolt_spacing[0] / 2,
                                        ear_d / 2,
                                        w - ear_d / 2),
                             constraint(l/2 + y * bolt_spacing[1] / 2,
                                        ear_d / 2 ,
                                        l - ear_d / 2),
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
            let (pocket_h = bottom_t - nut_z + 0.2) {
              four_corner_children(size=bolt_spacing, center=true) {
                translate([0, 0, nut_z]) {
                  cylinder(d=nut_d + 0.3, h=pocket_h, $fn=6);
                }
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
          if (wall_h > 0) {
            difference() {
              intersection() {
                difference() {
                  cuboid(size=[w, l, wall_h], r=corner_r, anchor=[1, 1, 1]);
                  translate([left_t, rear_t, -0.01]) {
                    cuboid(size=[inner_size[0], inner_size[1], wall_h + 0.02],
                           r=inner_corner_r,
                           anchor=[1, 1, 1]);
                  }
                }
                union() {
                  for (panel = panels) {
                    wall = plist_get(panel[0], wall_props);
                    if (plist_get("h", wall) > 0 && plist_get("l", wall) > 0) {
                      start = max(panel[5], plist_get("offset", wall));
                      end = min(panel[6],
                                plist_get("offset", wall) + plist_get("l", wall));
                      vent = multi_lipo_pack_vent_props(plist_get(panel[0], walls),
                                                        max(0, end - start),
                                                        plist_get("h", wall));
                      _wall_solid(wall,
                                  panel[1],
                                  panel[2],
                                  panel[3],
                                  panel[4],
                                  vent=vent,
                                  vent_offset=start - plist_get("offset", wall));
                    }
                  }
                }
              }
              for (panel = panels) {
                wall = plist_get(panel[0], wall_props);
                start = max(panel[5], plist_get("offset", wall));
                end = min(panel[6],
                          plist_get("offset", wall) + plist_get("l", wall));
                if (end > start && plist_get("h", wall) > 0) {
                  _wall_vents(plist_get(panel[0], walls),
                              span=end - start,
                              wall_h=plist_get("h", wall),
                              depth=panel[1] + 0.2,
                              span_axis=panel[2],
                              x=panel[3] + (panel[2] == "x" ? start : -0.1),
                              y=panel[4] + (panel[2] == "y" ? start : -0.1));
                }
                _wall_cutouts(wall, panel[1], panel[2], panel[3], panel[4]);
                _wall_openings(wall, panel[1], panel[2], panel[3], panel[4]);
              }
            }
          }
        }
      }

      for (panel = panels) {
        _wall_debug(plist_get(panel[0], wall_props),
                    panel[1],
                    panel[2],
                    panel[3],
                    panel[4],
                    opposite=in_list(panel[0], ["front", "left"]));
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
          wall = plist_get("inner", wall_props);
          axis = layout_axis == "x" ? "y" : "x";
          x = layout_axis == "x"
            ? pack_position[0] + pack_size[0] + w_clearance / 2 : left_t;
          y = layout_axis == "y"
            ? pack_position[1] + pack_size[1] + l_clearance / 2 : rear_t;
          _wall_debug(wall, inner_t, axis, x, y);
          if (plist_get("h", wall) > 0 && plist_get("l", wall) > 0) {
            color(case_color, alpha=1) {
              translate([0, 0, bottom_t]) {
                difference() {
                  _wall_solid(wall, inner_t, axis, x, y);
                  _wall_cutouts(wall, inner_t, axis, x, y);
                  _wall_openings(wall, inner_t, axis, x, y);
                }
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

multi_lipo_pack_case(multi_lipo_packs_case,
                     target_h=30,
                     show_packs=true,
                     show_standoffs=false);
