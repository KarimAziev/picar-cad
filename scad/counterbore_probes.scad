/**
  * Module: Counterbore and countersink calibration plate.
  *
  * Each row varies recess diameter; row labels give the through-hole diameter
  * and recess depth in millimeters. CB denotes counterbore, CS countersink.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <bolt_parameters.scad>

use <lib/functions.scad>
use <lib/plist.scad>
use <lib/shapes3d.scad>
use <lib/slots.scad>
use <lib/transforms.scad>

probes_specs = [["bore_d", [for (i = [0 : 9]) m3_socket_counterbore_d + i * 0.1],
                 "d", m3_hole_dia,
                 "bore_h", [m3_socket_counterbore_h,
                            m3_socket_counterbore_h + 0.1,
                            m3_socket_counterbore_h + 0.2]],
                ["bore_d", [for (i = [0 : 4]) m3_countersunk_bore_d + i * 0.1],
                 "d", m3_hole_dia,
                 "bore_h", [m3_countersunk_bore_h, 2],
                 "sink", true],
                ["bore_d", [for (i = [0 : 5]) m2_pan_counterbore_d + i * 0.1],
                 "d", [m2_hole_dia, m2_hole_dia_tight],
                 "bore_h", [m2_pan_counterbore_h,
                            m2_pan_counterbore_h + 0.1,
                            m2_pan_counterbore_h + 0.2]]];

label_mode   = "raised"; // "raised", "engraved", "none"
text_h       = 0.2; // One printing layer; set to the chosen slicer layer height.
part         = "all"; // "all", "body", "labels" (separate material export)

function _probe_values(value, name) =
  let (values = is_list(value) ? value : [value])
  assert(len(values) > 0, str(name, " must not be empty"))
  assert(len([for (v = values) if (!is_num(v) || v <= 0) v]) == 0,
         str(name, " must contain positive numbers"))
  values;

/**
  ─────────────────────────────────────────────────────────────────────────────
  hole_probe_rows
  ─────────────────────────────────────────────────────────────────────────────

  Expand probe families into ordered rows of recess diameters.

  **Parameters:**
  - `specs`: Nonempty list of plists. `d`, `bore_h`, and `bore_d` each accept a
    positive number or nonempty list of positive numbers. `sink` defaults to
    false. Optional `gap` overrides the horizontal edge-to-edge cell gap.
  - `gap`: Positive default cell gap in millimeters.

  **Returns:**
  Row plists with scalar `d`, `bore_h`, `sink`, `gap`, and a `bore_d` list.
  Families retain input order, then expand `d`, then `bore_h`. Recess diameters
  retain list order from left to right. Supply ascending lists for size sweeps.
  Separate families can describe selected combinations instead of a full grid.
 */
function hole_probe_rows(specs, gap=1) =
  assert(is_list(specs) && len(specs) > 0, "specs must not be empty")
  assert(is_num(gap) && gap > 0, "gap must be positive")
  [for (spec = specs)
    let (ds = _probe_values(plist_get("d", spec), "d"),
         depths = _probe_values(plist_get("bore_h", spec), "bore_h"),
         dias = _probe_values(plist_get("bore_d", spec), "bore_d"),
         sink = plist_get("sink", spec, false),
         row_gap = plist_get("gap", spec, gap))
      for (d = ds, depth = depths)
      assert(is_bool(sink), "sink must be boolean")
      assert(is_num(row_gap) && row_gap > 0, "gap must be positive")
      assert(min(dias) > d, "bore_d must be larger than d")
      ["d", d,
       "bore_h", depth,
       "bore_d", dias,
       "sink", sink,
       "gap", row_gap]];

function _probe_text(txt, text_size, font) =
  [txt, textmetrics(txt, size=text_size, font=font)];

function _probe_row_layout(row, labels, text_size, text_gap, font) =
  let (dias = plist_get("bore_d", row),
       captions = labels
       ? [for (d = dias) _probe_text(str(d), text_size, font)]
       : [],
       legend = labels
       ? [for (txt = [str(plist_get("sink", row) ? "CS" : "CB",
                          " d=", plist_get("d", row)),
                      str("h=", plist_get("bore_h", row))])
         _probe_text(txt, text_size, font)]
       : [],
       caption_h = labels ? max([for (t = captions) t[1].size[1]]) : 0,
       legend_h = labels
       ? sum([for (t = legend) t[1].size[1]]) + text_gap
       : 0,
       widths = [for (i = [0 : len(dias) - 1])
         max(dias[i], labels ? captions[i][1].size[0] : 0)],
       hole_y = labels ? caption_h + text_gap : 0,
       row_h = max(hole_y + max(dias), legend_h))
  concat(row,
         ["widths", widths,
          "w", sum(widths) + (len(dias) - 1) * plist_get("gap", row),
          "h", row_h,
          "hole_y", hole_y + max(dias) / 2,
          "captions", captions,
          "legend", legend,
          "legend_h", legend_h]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  hole_probes_layout
  ─────────────────────────────────────────────────────────────────────────────

  Calculate a tightly bounded rectangular plate and its hole and label positions.

  **Parameters:**
  - `specs`: Probe families accepted by `hole_probe_rows`.
  - `gap`: Positive horizontal cell gap and vertical row gap.
  - `pad`: Positive margin around all holes and text.
  - `thickness`: Plate height; `undef` uses the deepest recess plus `base_h`.
  - `base_h`: Positive minimum material below the deepest recess.
  - `label_mode`: `"raised"`, `"engraved"`, or `"none"`.
  - `text_size`: Positive text size in millimeters.
  - `text_gap`: Positive distance between text lines and between text and holes.
  - `font`: Font used for both measurement and rendering.

  **Returns:**
  Plist with `size` (plate bounds, excluding raised text), `holes` (plists with
  `pos`, `d`, `bore_d`, `bore_h`, `sink`), and `labels` (entries `[text,
  textmetrics_result, [x, y]]`, where `[x, y]` is the glyph bounding-box minimum).
  Rows read from top (+Y) to bottom; columns read left to right (+X).
 */
function hole_probes_layout(specs,
                            gap=1,
                            pad=2,
                            thickness=undef,
                            base_h=2,
                            label_mode="raised",
                            text_size=2.5,
                            text_gap=0.8,
                            font="Liberation Sans:style=Bold") =
  assert(member(label_mode, ["raised", "engraved", "none"]),
         "Invalid label_mode")
  assert(is_num(pad) && pad > 0, "pad must be positive")
  assert(is_num(base_h) && base_h > 0, "base_h must be positive")
  assert(is_num(text_size) && text_size > 0, "text_size must be positive")
  assert(is_num(text_gap) && text_gap > 0, "text_gap must be positive")
  let (labels = label_mode != "none",
       rows = [for (r = hole_probe_rows(specs, gap))
         _probe_row_layout(r, labels, text_size, text_gap, font)],
       min_h = max([for (r = rows) plist_get("bore_h", r)]) + base_h,
       h = is_undef(thickness) ? min_h : thickness,
       heights = [for (r = rows) plist_get("h", r)],
       inner_h = sum(heights) + gap * (len(rows) - 1),
       legend_w = labels
       ? max([for (r = rows, t = plist_get("legend", r)) t[1].size[0]])
       : 0,
       hole_x = pad + (labels ? legend_w + text_gap : 0),
       size = [hole_x + max([for (r = rows) plist_get("w", r)]) + pad,
               inner_h + 2 * pad, h],
       row_ys = [for (i = [0 : len(rows) - 1])
         pad + inner_h - sum(heights, i + 1) - i * gap])
  assert(is_num(h) && h >= min_h,
         str("thickness must be at least ", min_h, " mm"))
  ["size", size,
   "holes", [for (i = [0 : len(rows) - 1])
     let (r = rows[i],
          dias = plist_get("bore_d", r),
          widths = plist_get("widths", r))
       for (j = [0 : len(dias) - 1])
       ["pos", [hole_x + sum(widths, j)
                + j * plist_get("gap", r) + widths[j] / 2,
                row_ys[i] + plist_get("hole_y", r), 0],
        "d", plist_get("d", r),
        "bore_d", dias[j],
        "bore_h", plist_get("bore_h", r),
        "sink", plist_get("sink", r)]],
   "labels", labels
   ? [for (i = [0 : len(rows) - 1])
     let (r = rows[i],
          widths = plist_get("widths", r),
          legend = plist_get("legend", r),
          captions = plist_get("captions", r),
          legend_y = row_ys[i] + (heights[i] - plist_get("legend_h", r)) / 2)
       each concat([for (j = [0 : 1])
         concat(legend[j], [[pad, legend_y + (j == 0
                           ? legend[1][1].size[1] + text_gap : 0)]])],
                   [for (j = [0 : len(captions) - 1])
                     concat(captions[j],
                            [[hole_x + sum(widths, j)
                              + j * plist_get("gap", r)
                              + (widths[j] - captions[j][1].size[0]) / 2,
                              row_ys[i]]])])]
   : []];

/**
  ─────────────────────────────────────────────────────────────────────────────
  hole_probes
  ─────────────────────────────────────────────────────────────────────────────

  Create a printable calibration plate with top-facing recesses and labels.

  **Parameters:**
  - `specs`: Probe families accepted by `hole_probe_rows`.
  - `gap`: Positive cell and row gap, default 1 mm.
  - `thickness`: Plate height; `undef` derives it from recess depths and `base_h`.
  - `corner_r`: XY corner radius, from zero to `pad`.
  - `pad`: Positive outer margin, default 2 mm.
  - `base_h`: Minimum thickness below the deepest recess, default 2 mm.
  - `label_mode`: `"raised"` (colored), `"engraved"` (uncolored cutters), `"none"`.
  - `text_h`: Raised height or engraving depth, default 0.2 mm. Set raised height
    to one layer of the printing profile; there is no printer-independent minimum.
  - `text_size`: Label size, default 2.5 mm.
  - `text_gap`: Space between text lines and between text and holes, default 0.8 mm.
  - `font`: Font used to measure and render labels.
  - `text_color`: Raised-label color, default black.
  - `body_color`: Plate color, default white.
  - `part`: `"all"`, `"body"`, or `"labels"`. Separate body and raised-label exports
    share coordinates for material assignment. Engraved labels are cutters.
  - `slot_mode`: Emit uncolored holes and engraving cutters for `difference()`.
    Takes precedence over `part`.
  - `anchor`: Plate reference anchor, excluding raised text; default `[1, 1, 1]`.
  - `fn`: Circle resolution, default 100, integer at least 12.

  **Examples:**
  ```scad
  hole_probes([["d", [3.1, 3.2], "bore_h", [3.2, 3.3],
                "bore_d", [6.2, 6.3, 6.4]]], label_mode="engraved");
  ```
 */
module hole_probes(specs,
                   gap=1,
                   thickness=undef,
                   corner_r=1,
                   pad=2,
                   base_h=2,
                   label_mode="raised",
                   text_h=0.2,
                   text_size=2.5,
                   text_gap=0.8,
                   font="Liberation Sans:style=Bold",
                   text_color="black",
                   body_color="white",
                   part="all",
                   slot_mode=false,
                   anchor=[1, 1, 1],
                   fn=100) {
  layout = hole_probes_layout(specs,
                              gap,
                              pad,
                              thickness,
                              base_h,
                              label_mode,
                              text_size,
                              text_gap,
                              font);
  size = plist_get("size", layout);
  eps = 0.01;

  assert(is_num(corner_r) && corner_r >= 0 && corner_r <= pad,
         "corner_r must be between zero and pad");
  assert(member(part, ["all", "body", "labels"]), "Invalid part");
  assert(is_num(text_h) && text_h > 0 && text_h < size[2],
         "text_h must be positive and less than plate thickness");
  assert(is_num(fn) && fn >= 12 && floor(fn) == fn,
         "fn must be an integer of at least 12");

  module holes() {
    for (hole = plist_get("holes", layout)) {
      translate(plist_get("pos", hole)) {
        // Exact taper dimensions keep the surface diameter true to its label.
        counterbore(h=size[2],
                    d=plist_get("d", hole),
                    bore_d=plist_get("bore_d", hole),
                    bore_h=plist_get("bore_h", hole),
                    sink=plist_get("sink", hole),
                    autoscale_step=0,
                    reverse=false,
                    fn=fn);
        translate([0, 0, -eps]) {
          cylinder(d=plist_get("d", hole), h=size[2] + 2 * eps, $fn=fn);
        }
        translate([0, 0, size[2]]) {
          cylinder(d=plist_get("bore_d", hole), h=eps, $fn=fn);
        }
      }
    }
  }

  module labels() {
    z = label_mode == "engraved" ? size[2] - text_h : size[2];
    h = text_h + (label_mode == "engraved" ? eps : 0);
    for (label = plist_get("labels", layout)) {
      translate([label[2][0] - label[1].position[0],
                 label[2][1] - label[1].position[1],
                 z]) {
        linear_extrude(height=h) {
          text(label[0], size=text_size, font=font);
        }
      }
    }
  }

  with_anchor(size=size, anchor=anchor) {
    if (slot_mode) {
      holes();
      if (label_mode == "engraved") {
        labels();
      }
    } else {
      if (part != "labels") {
        color(body_color) {
          difference() {
            cuboid(size=size, anchor=[1, 1, 1], r=corner_r);
            holes();
            if (label_mode == "engraved") {
              labels();
            }
          }
        }
      }
      if (part != "body" && label_mode == "raised") {
        color(text_color) {
          labels();
        }
      } else if (part == "labels" && label_mode == "engraved") {
        labels();
      }
    }
  }
}

hole_probes(specs=probes_specs,
            label_mode=label_mode,
            text_h=text_h,
            thickness=6,
            part=part);
