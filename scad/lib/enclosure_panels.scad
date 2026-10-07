/**
  * Module: Dimensioned enclosure panel openings and vent grids.
  *
  * Panel coordinates start at the lower left in the local span/height plane.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <functions.scad>
use <plist.scad>
use <shapes2d.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  enclosure_dimension / enclosure_dimensions
  ─────────────────────────────────────────────────────────────────────────────

  Resolve nonnegative millimeters or percentage strings against a reference
  length, or against corresponding axes of a reference vector.
 */
function enclosure_dimension(value, total) =
  let (n = maybe_percent_string_to_num(value, total))
  assert(is_num(n) && n >= 0, "Dimension must be nonnegative mm or a percentage")
  n;

function enclosure_dimensions(spec, size) =
  assert(is_list(spec) && len(spec) == len(size), "Dimension vector has wrong length")
  [for (i = [0 : len(size) - 1]) enclosure_dimension(spec[i], size[i])];

function _enclosure_overlap(a, b, gap=0) =
  a[0][0] < b[0][0] + b[1][0] + gap
  && a[0][0] + a[1][0] > b[0][0] - gap
  && a[0][1] < b[0][1] + b[1][1] + gap
  && a[0][1] + a[1][1] > b[0][1] - gap;

function _enclosure_opening(spec, size, references, top) =
  let (dims = top
              ? [enclosure_dimension(plist_get("l", spec), size[0]),
                 enclosure_dimension(plist_get("h", spec,
                    size[1] - enclosure_dimension(plist_get("bottom", spec, 0), size[1])), size[1])]
              : enclosure_dimensions(plist_get("size", spec), size),
       at = plist_get("at", spec),
       ref = is_undef(at) ? undef : plist_get(at, references),
       pos = top
             ? [is_undef(at)
                 ? enclosure_dimension(plist_get("offset", spec, (size[0] - dims[0]) / 2), size[0])
                 : ref[0] - dims[0] / 2,
                size[1] - dims[1]]
             : is_undef(at)
               ? enclosure_dimensions(plist_get("pos", spec, [0, 0]), size)
               : ref - dims / 2,
       r = enclosure_dimension(plist_get("corner_r", spec, 0), min(dims)))
  assert(is_undef(at) || !is_undef(ref), str("Unknown panel reference: ", at))
  assert(min(dims) > 0 && min(pos) >= -0.000001
         && pos[0] + dims[0] <= size[0] + 0.000001
         && pos[1] + dims[1] <= size[1] + 0.000001,
         "Panel opening must fit its reference box")
  plist_merge(spec, concat(["pos", pos, "size", dims,
                      "corner_r", min(r, min(dims) / 2),
                      "side", plist_get("side", spec, top ? "bottom" : "all"),
                      "top", top,
                      "rim_chamfer", enclosure_dimension(plist_get("rim_chamfer", spec, 0), min(dims))],
                           plist_has("vent_gap", spec)
                             ? ["vent_gap", enclosure_dimension(plist_get("vent_gap", spec), min(size))] : []));

function _enclosure_vent_rect(rect, openings, gap, mode) =
  let (hits = [for (o = openings)
         let (chamfer = plist_get("rim_chamfer", o, 0))
         if (_enclosure_overlap(rect, [plist_get("pos", o) - [chamfer, 0],
                                       plist_get("size", o) + [2 * chamfer, chamfer]],
                                plist_get("vent_gap", o, gap))) o],
       stop = min(concat([rect[0][1] + rect[1][1]],
                        [for (o = hits) plist_get("pos", o)[1] - plist_get("vent_gap", o, gap)])),
       h = max(0, stop - rect[0][1]))
  len(hits) == 0 || mode == "clip"
  ? rect
  : mode == "shorten" && h >= rect[1][0]
    ? [rect[0], [rect[1][0], h]]
    : undef;

/**
  ─────────────────────────────────────────────────────────────────────────────
  enclosure_panel_props
  ─────────────────────────────────────────────────────────────────────────────

  Resolve a rectangular panel's cutouts, slots and independent vent grid.

  **Parameters:**
  - `pl`: `cutouts` are open-top plists with `l`, `h` (depth from the top),
    or `bottom` (height above the floor), and `offset` along the panel.
    `slots` contain `pos` at their lower left and `size`. Both accept
    `corner_r`, rounded_rect `side`, and optional `at` reference names.
    Cutouts also accept `rim_chamfer`. All dimensions accept mm or percentages.
  - `size`: [span, height] of the panel's inner reference box.
  - `references`: Named [span, height] points; `at` centers a slot on a point,
    or centers a cutout horizontally on it. Offsets otherwise start at zero.
  - `keepouts`: Additional [position, size] rectangles excluded from vents.

  `vents` accepts `enabled`, `size`, `gap`, `margin` [left, right, bottom, top],
  `corner_r`, `opening_gap` and `opening_mode` (shorten, omit, clip).
  Sizes/gaps use the panel axes; radii use the smaller opening dimension.
  Vents are centered in the area remaining after margins. `shorten` retains
  material below open-top cutouts; `omit` drops intersecting vents; `clip`
  subtracts expanded opening profiles. Empty vents disable the grid.

  **Returns:** Resolved `size`, `openings`, `vents`, and `vent_rects`.
 */
function enclosure_panel_props(pl,
                                size,
                                references=[],
                                keepouts=[]) =
  let (openings = concat(
         [for (c = plist_get("cutouts", pl, [])) _enclosure_opening(c, size, references, true)],
         [for (s = plist_get("slots", pl, [])) _enclosure_opening(s, size, references, false)]),
       v = plist_get("vents", pl, []),
       enabled = len(v) > 0 && plist_get("enabled", v, true),
       margin = enclosure_dimensions(plist_get("margin", v, [0, 0, 0, 0]),
                                      [size[0], size[0], size[1], size[1]]),
       available = size - [margin[0] + margin[1], margin[2] + margin[3]],
       slot = enclosure_dimensions(plist_get("size", v, [0, 0]), size),
       gap = enclosure_dimensions(plist_get("gap", v, [0, 0]), size),
       count = [for (i = [0, 1]) !enabled || slot[i] <= 0 || available[i] < slot[i]
                  ? 0 : floor((available[i] + gap[i]) / (slot[i] + gap[i]))],
       start = [margin[0], margin[2]]
                + (available - [for (i = [0, 1]) count[i] * (slot[i] + gap[i]) - gap[i]]) / 2,
       opening_gap = enclosure_dimension(plist_get("opening_gap", v, 0), min(size)),
       mode = plist_get("opening_mode", v, "shorten"),
       obstacles = concat(openings, [for (k = keepouts)
          ["pos", k[0], "size", k[1], "corner_r", 0, "side", "all", "top", false,
           "rim_chamfer", 0]]))
  assert(member(mode, ["shorten", "omit", "clip"]), "Invalid vent opening_mode")
  ["size", size,
   "openings", openings,
   "vent_obstacles", obstacles,
   "vents", plist_merge(v, ["opening_gap", opening_gap, "opening_mode", mode,
                              "corner_r", enclosure_dimension(plist_get("corner_r", v, 0), min(slot))]),
   "vent_rects", [for (x = [0 : 1 : count[0] - 1], y = [0 : 1 : count[1] - 1])
     let (rect = [start + [x * (slot[0] + gap[0]), y * (slot[1] + gap[1])], slot],
          trimmed = _enclosure_vent_rect(rect, obstacles, opening_gap, mode))
     if (!is_undef(trimmed)) trimmed]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  enclosure_panel_openings / enclosure_panel_vents
  ─────────────────────────────────────────────────────────────────────────────

  Emit 2D cutters from enclosure_panel_props in its local reference plane.
  `top_only` selects open-top cutouts for lid lip reliefs.
  Vent `keepouts` adds [position, size] rectangles resolved at render time,
  for example measured label bounds.
 */
module enclosure_panel_openings(p, top_only=false) {
  for (o = plist_get("openings", p)) {
    if (!top_only || plist_get("top", o)) {
      translate(plist_get("pos", o)) {
        _enclosure_opening_shape(o);
      }
    }
  }
}

module _enclosure_opening_shape(o) {
  s = plist_get("size", o);
  chamfer = plist_get("rim_chamfer", o);
  rounded_rect(s, r=plist_get("corner_r", o), side=plist_get("side", o), fn=32);
  if (plist_get("top", o)) {
    translate([0, s[1] - 0.01]) {
      square([s[0], 0.02]);
    }
    if (chamfer > 0) {
      for (x = [0, s[0]]) {
        translate([x, s[1]]) {
          circle(r=chamfer, $fn=4);
        }
      }
    }
  }
}

module enclosure_panel_vents(p, keepouts=[]) {
  v = plist_get("vents", p);
  obstacles = [for (k = keepouts)
    ["pos", k[0], "size", k[1], "corner_r", 0, "side", "all",
     "top", false, "rim_chamfer", 0]];
  difference() {
    for (rect = plist_get("vent_rects", p)) {
      trimmed = _enclosure_vent_rect(rect, obstacles, plist_get("opening_gap", v),
                                     plist_get("opening_mode", v));
      if (!is_undef(trimmed)) {
        translate(trimmed[0]) {
          rounded_rect(trimmed[1], r=min(plist_get("corner_r", v), min(trimmed[1]) / 2), fn=24);
        }
      }
    }
    if (plist_get("opening_mode", v) == "clip") {
      for (o = concat(plist_get("vent_obstacles", p), obstacles)) {
        translate(plist_get("pos", o)) {
          offset(delta=plist_get("vent_gap", o, plist_get("opening_gap", v))) {
            _enclosure_opening_shape(o);
          }
        }
      }
    }
  }
}
