/**
 * Module: Text utilities
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../steering_params.scad>

use <debug.scad>
use <functions.scad>
use <placement.scad>
use <plist.scad>
use <transforms.scad>

/**
   ─────────────────────────────────────────────────────────────────────────────
   text_from_spec
   ─────────────────────────────────────────────────────────────────────────────

   Render extruded text from a positional specification vector.

   `spec` may be a plain string or a list whose items are interpreted in this
   order:
   `[text, size, color, rotation, translation, spacing, font, halign, valign, height]`.

   **Parameters:**
   - `spec`: Positional text specification or plain string.
   - `default_font`: Font used when `spec[6]` is missing.
   - `default_height`: Extrusion height used when `spec[9]` is missing.
   - `default_size`: Text size used when `spec[1]` is missing.
   - `default_spacing`: Character spacing used when `spec[5]` is missing.
   - `default_halign`: Horizontal alignment fallback.
   - `default_valign`: Vertical alignment fallback.
   - `default_color`: Color fallback.

   **Example:**
   ```scad
   text_from_spec(["Hello world", 8, "white", [0, 0, 90], [0, -10, 0], 1.1]);
   ```
 */

module text_from_spec(spec,
                      default_font,
                      default_height = 0.1,
                      default_size = 4,
                      default_spacing = 1,
                      default_halign = "center",
                      default_valign = "baseline",
                      default_color) {
  if (!is_undef(spec)) {
    if (is_string(spec)) {
      spec = [spec];
    }

    let (txt = spec[0],
         size = (with_default(spec[1], default_size)),
         colr = (with_default(spec[2], default_color)),
         rotation = spec[3],
         translation = spec[4],
         spacing = with_default(spec[5], default_spacing),
         font = with_default(spec[6], default_font),
         halign = with_default(spec[7], default_halign),
         valign = with_default(spec[8], default_valign),
         height = with_default(spec[9], default_height, "number")) {

      if (!is_undef(colr)) {
        color(colr) {
          maybe_translate(translation) {
            maybe_rotate(rotation) {
              linear_extrude(height=height, center=false) {
                text(text=txt,
                     size=size,
                     spacing=spacing,
                     font=font,
                     halign=halign,
                     valign=valign);
              }
            }
          }
        }
      } else {
        maybe_translate(translation) {
          maybe_rotate(rotation) {
            linear_extrude(height=height, center=false) {
              text(text=txt,
                   size=size,
                   spacing=spacing,
                   font=font,
                   halign=halign,
                   valign=valign);
            }
          }
        }
      }
    }
  }
}

/**
   ─────────────────────────────────────────────────────────────────────────────
   text_from_plist
   ─────────────────────────────────────────────────────────────────────────────

   Render extruded text from a property list.

   Supported plist keys include `text`, `size`, `color`, `rotation`,
   `translation`, `spacing`, `font`, `halign`, `valign`, and `height`.

   **Parameters:**
   - `txt`: Explicit text override. When provided, it wins over `plist["text"]`.
   - `plist`: Property list describing the text.
   - `default_font`: Font fallback.
   - `default_height`: Extrusion height fallback.
   - `default_size`: Text size fallback.
   - `default_spacing`: Character spacing fallback.
   - `default_halign`: Horizontal alignment fallback.
   - `default_valign`: Vertical alignment fallback.
   - `default_rotation`: Rotation fallback.
   - `default_translation`: Translation fallback.
   - `default_color`: Color fallback.

   **Example:**
   ```scad
   text_from_plist("My text", ["size", 8, "color", "red", "rotation", [0, 0, 90]]);
   ```
 */

module text_from_plist(txt,
                       plist = [],
                       default_font,
                       default_height = 0.1,
                       default_size = 4,
                       default_spacing = 1,
                       default_halign = "center",
                       default_valign = "baseline",
                       default_rotation= [0, 0, 0],
                       default_translation= [0, 0, 0],
                       default_color) {
  if ((!is_undef(plist) && plist_get("text", plist)) || !is_undef(txt)) {
    let (plist = with_default(plist, []),
         txt_raw = is_undef(txt) ? plist_get("text", plist, txt) : txt,
         txt = is_num(txt_raw) ? str(txt_raw) : txt_raw,
         size = plist_get("size", plist, default_size),
         colr = plist_get("color", plist, default_color),
         rotation = plist_get("rotation", plist, default_rotation),
         translation = plist_get("translation", plist, default_translation),
         spacing = plist_get("spacing", plist, default_spacing),
         font = with_default(plist_get("font", plist, default_font)),
         halign = with_default(plist_get("halign", plist), default_halign),
         valign = with_default(plist_get("valign", plist), default_valign),
         height = with_default(plist_get("height", plist), default_height)) {

      if (!is_undef(colr)) {
        color(colr) {
          maybe_translate(translation) {
            maybe_rotate(rotation) {
              linear_extrude(height=height, center=false) {
                text(text=txt,
                     size=size,
                     spacing=spacing,
                     font=font,
                     halign=halign,
                     valign=valign);
              }
            }
          }
        }
      } else {
        maybe_translate(translation) {
          maybe_rotate(rotation) {
            linear_extrude(height=height, center=false) {
              text(text=txt,
                   size=size,
                   spacing=spacing,
                   font=font,
                   halign=halign,
                   valign=valign);
            }
          }
        }
      }
    }
  }
}

/**
   ─────────────────────────────────────────────────────────────────────────────
   get_z_rotation
   ─────────────────────────────────────────────────────────────────────────────

   Extract the Z rotation from a text spec plist.

   **Parameters:**
   - `spec`: Property list that may contain `rotation`.

   **Returns:**
   The Z rotation component or the raw scalar rotation value.
 */
function get_z_rotation(spec) =
  let (rotation = plist_get("rotation", spec),
       z_rotation = is_list(rotation) ? rotation[2] : rotation)
  z_rotation;

/**
   ─────────────────────────────────────────────────────────────────────────────
   get_rotation
   ─────────────────────────────────────────────────────────────────────────────

   Normalize the `rotation` entry of a text spec plist into a 3-element vector
   when possible.

   **Parameters:**
   - `spec`: Property list that may contain `rotation`.

   **Returns:**
   `[x, y, z]`, a scalar Z rotation promoted to `[0, 0, z]`, or the original
   value when it is neither a list nor a number.
 */
function get_rotation(spec) =
  let (rotation = plist_get("rotation", spec))
  is_list(rotation)
  ? [for (v = [rotation[0],
               rotation[1],
               rotation[2]])
    with_default(v, 0, "number")]
  : is_num(rotation) ? [0, 0, rotation] : rotation;

/**
   ─────────────────────────────────────────────────────────────────────────────
   should_swap_size
   ─────────────────────────────────────────────────────────────────────────────

   Decide whether width and height should be swapped for text metrics.

   **Parameters:**
   - `spec`: Property list that may contain `rotation`.

   **Returns:**
   `true` when the Z rotation is exactly `90` or `-90` degrees.
 */
function should_swap_size(spec) =
  let (z_rotation = get_z_rotation(spec))
  is_num(z_rotation) && abs(z_rotation) == 90;

/**
   ─────────────────────────────────────────────────────────────────────────────
   get_text_size
   ─────────────────────────────────────────────────────────────────────────────

   Measure the 2D size of a text spec using `textmetrics()`.

   **Parameters:**
   - `txt`: Text string to measure.
   - `plist`: Property list supplying size, font, spacing, alignment, and
     rotation.

   **Returns:**
   `[width, height]` of the measured text. Width and height are swapped for
   quarter-turn rotations.
 */
function get_text_size(txt, plist) =
  let (tm = textmetrics(text=txt,
                        size=plist_get("size", plist),
                        font=plist_get("font", plist),
                        spacing=plist_get("spacing", plist),
                        halign=plist_get("halign", plist),
                        valign=plist_get("valign", plist)),
       should_swap = should_swap_size(plist))
  should_swap ? [tm.size[1], tm.size[0]] : tm.size;

/**
   ─────────────────────────────────────────────────────────────────────────────
   get_y_size
   ─────────────────────────────────────────────────────────────────────────────

   Return the Y component of a size-like spec.

   **Parameters:**
   - `spec`: Value accepted by `get_size_at()`.

   **Returns:**
   The element at index `1`.
 */
function get_y_size(spec) =
  get_size_at(1, spec);

/**
   ─────────────────────────────────────────────────────────────────────────────
   get_gap_before
   ─────────────────────────────────────────────────────────────────────────────

   Read the extra gap inserted before a text row.

   **Parameters:**
   - `spec`: Property list that may contain `gap_before`.

   **Returns:**
   The `gap_before` value, or `0`.
 */
function get_gap_before(spec) =
  plist_get("gap_before", spec, 0);

/**
   ─────────────────────────────────────────────────────────────────────────────
   get_gap_after
   ─────────────────────────────────────────────────────────────────────────────

   Read the extra gap inserted after a text row.

   **Parameters:**
   - `spec`: Property list that may contain `gap_after`.

   **Returns:**
   The `gap_after` value, or `0`.
 */
function get_gap_after(spec) =
  plist_get("gap_after", spec, 0);

/**
   ─────────────────────────────────────────────────────────────────────────────
   get_gap_x_offset
   ─────────────────────────────────────────────────────────────────────────────

   Extract the X translation component from a text spec.

   **Parameters:**
   - `spec`: Property list that may contain `translation`.

   **Returns:**
   The X component of `translation`, or `0`.
 */
function get_gap_x_offset(spec) =
  let (tr = plist_get("translation", spec))
  is_list(tr) ? tr[0] : 0;

/**
   ─────────────────────────────────────────────────────────────────────────────
   get_gap_y_offset
   ─────────────────────────────────────────────────────────────────────────────

   Extract the Y translation component from a text spec.

   **Parameters:**
   - `spec`: Property list that may contain `translation`.
   - `default_gap`: Fallback value when no Y translation is defined.

   **Returns:**
   The Y component of `translation`, or `default_gap`.
 */
function get_gap_y_offset(spec, default_gap = 0) =
  let (tr = plist_get("translation", spec))
  is_list(tr) ? tr[1] : default_gap;

/**
   ─────────────────────────────────────────────────────────────────────────────
   normalize_texts
   ─────────────────────────────────────────────────────────────────────────────

   Normalize a mixed collection of text inputs into a list of plists plus
   measured layout metadata.

   **Parameters:**
   - `texts`: A string, number, plist, or list mixing those representations.
   - `plist`: Default plist merged into each row spec.
   - `gap`: Default gap inserted between rows.
   - `default_font`: Font fallback.
   - `default_height`: Extrusion height fallback.
   - `default_size`: Text size fallback.
   - `default_spacing`: Character spacing fallback.
   - `default_halign`: Horizontal alignment fallback.
   - `default_valign`: Vertical alignment fallback.
   - `default_rotation`: Rotation fallback.
   - `default_translation`: Translation fallback.
   - `default_color`: Color fallback.

   **Returns:**
   A plist-like vector containing normalized row plists, measured sizes, gaps,
   and total stacked size.
 */
function normalize_texts(texts = [],
                         plist,
                         gap = 0,
                         default_font,
                         default_height = 0.1,
                         default_size = 4,
                         default_spacing = 1,
                         default_halign = "center",
                         default_valign = "center",
                         default_rotation,
                         default_translation,
                         default_color) =
  let (texts = is_string(texts) || is_num(texts)
       ? [is_num(texts) ? str(texts) : texts]
       : [for (v = with_default(texts, []))
           if (!is_undef(v) &&
               (is_string(v) || is_num(v) ||
                is_list(v) && !plist_is(v) && is_string(v[1])
                || is_num(v[1]) ||
                (is_list(v) &&

                 is_string(plist_get("text", v))
                 || is_num(plist_get("text", v)))))
             (is_list(v) && !plist_is(v)) ? concat(["text"], v) : v],
       gap = with_default(gap, 0),
       default_plist = plist_merge(["font", default_font,
                                    "height",  default_height,
                                    "size",  default_size,
                                    "spacing",  default_spacing,
                                    "halign",  default_halign,
                                    "valign",  default_valign,
                                    "rotation",  default_rotation,
                                    "translation",  default_translation,
                                    "color", default_color],
                                   with_default(plist, [])),
       text_strings = [for (v = texts) let (txt = is_string(v) || is_num(v)
                                            ? v : plist_get("text", v, ""))
                                         is_num(txt) ? str(txt) : txt],
       text_plists = [for (v = texts) is_string(v) || is_num(v)
                                        ?
                                        plist_merge(default_plist,
                                                    ["text", is_num(v)
                                                     ? str(v)
                                                     : v])
                                        : plist_merge(should_swap_size(v)
                                                      ? plist_merge(default_plist,
                                                                    ["valign", "center",
                                                                     "halign", "center",])
                                                      : default_plist, v)],

       text_sizes = [for (v = text_plists) get_text_size(plist_get("text", v),
                                                         v)],

       x_sizes = [for (v = text_sizes) v[0]],
       y_sizes = [for (v = text_sizes) v[1]],

       gaps_before = [for (v = text_plists) get_gap_before(v)],
       gaps_after = [for (v = text_plists) get_gap_after(v)],

       max_x_size = max(x_sizes),
       gaps = repeat(gap, len(gaps_after)),
       total_size = [max_x_size,
                     sum(concat(y_sizes,
                                gaps_before,
                                drop_last(gaps_after, 1),
                                drop_last(gaps, 1)))])
  ["plists", text_plists,
   "text_strings", text_strings,
   "text_sizes", text_sizes,
   "x_sizes", x_sizes,
   "y_sizes", y_sizes,
   "max_x_size", max_x_size,
   "gaps_before", gaps_before,
   "gaps_after", gaps_after,
   "total_size", total_size,
   "gaps", gaps];

/**
   ─────────────────────────────────────────────────────────────────────────────
   text_rows
   ─────────────────────────────────────────────────────────────────────────────

   Render one or more text rows stacked vertically.

   Each row may be a string, a number, or a plist containing keys such as
   `text`, `size`, `color`, `rotation`, `translation`, `spacing`, `font`,
   `halign`, `valign`, `height`, `y_offset`, `gap_before`, `gap_after`, and the
   optional background keys `bg_color`, `bg_pad_*`, and `bg_h`.

   **Parameters:**
   - `texts`: Row definitions to normalize and render.
   - `plist`: Default plist merged into each row.
   - `gap`: Default gap inserted between rows.
   - `default_font`: Font fallback.
   - `default_height`: Extrusion height fallback.
   - `default_size`: Text size fallback.
   - `default_spacing`: Character spacing fallback.
   - `default_halign`: Horizontal alignment fallback.
   - `default_valign`: Vertical alignment fallback.
   - `default_rotation`: Rotation fallback applied per row.
   - `default_translation`: Translation fallback applied per row.
   - `default_color`: Color fallback applied per row.
   - `center_x`: If `true`, center the full text block on X.
   - `center_y`: If `true`, center the full text block on Y.
   - `rotation`: Currently unused.

   **Examples:**
   ```scad
   text_rows(["Top", ["text", "Bottom", "gap_before", 1]], center_x=true);
   ```
 */

module text_rows(texts = [],
                 plist,
                 gap = 0,
                 default_font,
                 default_height = 0.1,
                 default_size = 4,
                 default_spacing = 1,
                 default_halign = "center",
                 default_valign = "center",
                 default_rotation,
                 default_translation,
                 default_color,
                 center_x=false,
                 center_y=true,
                 rotation) {
  props = normalize_texts(texts,
                          plist=plist,
                          gap=gap,
                          default_font=default_font,
                          default_height=default_height,
                          default_size=default_size,
                          default_spacing=default_spacing,
                          default_halign=default_halign,
                          default_valign=default_valign,
                          default_rotation=default_rotation,
                          default_translation=default_translation,
                          default_color=default_color);

  text_strings = plist_get("text_strings", props);
  text_plists = plist_get("plists", props);
  y_sizes = plist_get("y_sizes", props);
  gaps_before = plist_get("gaps_before", props);
  gaps_after = plist_get("gaps_after", props);
  max_x_size = plist_get("max_x_size", props);
  total_size = plist_get("total_size", props);
  text_sizes = plist_get("text_sizes", props);

  module _main() {
    translate([0, total_size[1], 0]) {
      union() {
        for (i = [0 : len(text_plists) - 1]) {
          let (txt = text_strings[i],
               spec = text_plists[i],
               ratio = -1,
               prev_y_acc = sum(y_sizes, i),
               prev_gap_after = sum(gaps_after, i),
               prev_gap_before = sum(gaps_before, i),
               curr_gap_before = get_gap_before(spec),
               curr_y = y_sizes[i],
               gap_acc = sum([prev_gap_after,
                              prev_gap_before,
                              curr_gap_before,
                              gap * i]),
               translation = plist_get("translation", spec),
               rotation = get_rotation(spec),
               y_acc = ratio * sum([prev_y_acc, gap_acc, curr_y / 2]),
               height = plist_get("height", spec, 0.1),
               size = plist_get("size", spec),
               spacing = plist_get("spacing", spec),
               font = plist_get("font", spec),
               valign = plist_get("valign", spec),
               halign = plist_get("halign", spec),
               colr = plist_get("colr", spec, plist_get("color", spec)),
               y_offset = plist_get("y_offset", spec, 0),
               final_y = y_acc + ratio * y_offset,
               bg_color = plist_get("bg_color", spec),
               bg_pad_left = plist_get("bg_pad_left", spec, 0),
               bg_pad_right = plist_get("bg_pad_right", spec, 0),
               bg_pad_top = plist_get("bg_pad_top", spec, 0),
               bg_pad_bottom = plist_get("bg_pad_bottom", spec, 0),
               bg_h = plist_get("bg_h", spec, height - 0.01),
               text_size = text_sizes[i],
               x_size = text_size[0],
               y_size = text_size[1],
               x_offset = halign == "right"
               ? (max_x_size - x_size)
               : halign == "left"
               ? 0
               : halign == "center"
               ? (max_x_size / 2) - (x_size / 2)
               : 0) {

            translate([x_offset, final_y, 0]) {
              if (!is_undef(bg_color)) {
                let (h = y_size + bg_pad_top + bg_pad_bottom) {
                  color(bg_color, alpha=1) {
                    maybe_translate(translation) {
                      maybe_rotate(rotation) {
                        translate([-bg_pad_left,
                                   (valign == "center" ? -y_size / 2 : 0)
                                   - bg_pad_bottom,
                                   0]) {
                          cube([x_size + bg_pad_left + bg_pad_right, h, bg_h]);
                        }
                      }
                    }
                  }
                }
              }
              color(colr) {

                maybe_translate(translation) {
                  maybe_rotate(rotation) {
                    linear_extrude(height=height, center=false) {
                      text(text=txt,
                           size=size,
                           spacing=spacing,
                           font=font,
                           valign=valign);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  if (len(text_strings) > 0) {
    translate([center_x ? -max_x_size / 2 : 0,
               center_y ? -total_size[1] / 2 : 0]) {
      _main();
    }
  }
}

/**
   ─────────────────────────────────────────────────────────────────────────────
   text_fit
   ─────────────────────────────────────────────────────────────────────────────

   Scale text uniformly so it fits inside a target X/Y box, then extrude it.

   **Parameters:**
   - `txt`: Text to render.
   - `x`: Target width.
   - `y`: Target height.
   - `h`: Extrusion height.
   - `spacing`: Character spacing used for both measuring and rendering.
   - `font`: Optional font override.
 */
module text_fit(txt="Dynamic Text",
                x,
                y,
                h,
                spacing=1,
                font) {

  tf = textmetrics(txt,
                   spacing=spacing,
                   font=font,
                   valign="center",
                   halign="center");
  txs = tf.size.x;
  tys = tf.size.y;

  scx = x / txs;
  scy = y / tys;

  sc = min(scx, scy);

  scale([sc, sc, 1]) {
    linear_extrude(height=h) {
      text(txt,
           valign="center",
           halign="center",
           spacing=spacing,
           font=font);
    }
  }
}

angles=[90, 0, 180];

rotate(angles) {
  text_rows(texts=dsservo_text,
// rotation=angles,
            default_halign="left",
            center_x=true,
            center_y=true);
}

// text_rows(texts=dsservo_text,
// // rotation=angles,
//           default_halign="left",
//           center_x=true,
//           center_y=true);
size = [30.8733, 16.7648, 0.1];

// rotate(angles) {
//   #cube(size);
// }

// rotate_children_with_shift(size=size, angles=angles, show_bbox=true) {
//   cube(size);
// }
