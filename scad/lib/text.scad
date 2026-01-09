/**
 * Module: Text utilities
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <debug.scad>
use <functions.scad>
use <placement.scad>
use <plist.scad>
use <transforms.scad>

/**
   Render text from the given specification or defaults.
   `spec` may contain:
   0. `text`: The text to generate. Only text is required.
   1. `size`: The size of the text. Default is 4.
   2. `color`: The optional color to use.
   3. `rotation`: Optional value for `rotate`.
   4. `translation`: Optional value for `translate`. Applies after rotation.
   5. `spacing`: Factor to increase or decrease the character spacing. The default value of 1.
   6. `font`: The name of the font that should be used.
   7. `halign`: left, center (default) or right.
   8. `valign`: top, center, baseline (default) and bottom.
   9. `height`: Factor to increase or decrease the character spacing. The default value of 0.1.

   **Example:**

   ```scad
   text_from_spec(["Hello world",
                8, // size
                "white", // color
                [0, 0, 90], // rotation
                [0, -10, 0], // translation
                1.1, // spacing
                undef, // font
                "center", // halign
                "center" // valign
               ]);
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
   Render text or numbers from the given plist specification or defaults.

   `plist` may contain (all properties are optional):
   - `text`: The text to generate if `txt` argument is not provided.
   - `size`: The size of the text. Default is 4.
   - `color`: The optional color to use.
   - `rotation`: Optional value for `rotate`.
   - `translation`: Optional value for `translate`. Applies after rotation.
   - `spacing`: Factor to increase or decrease the character spacing. The default value of 1.
   - `font`: The name of the font that should be used.
   - `halign`: left, center (default) or right.
   - `valign`: top, center, baseline (default) and bottom.
   - `height`: Factor to increase or decrease the character spacing. The default value of 0.1.

   **Example:**

   ```scad
   text_from_plist("My text",
                ["size", 8,
                 "color", "red",
                 "spacing", 0.9,
                 "height", 6,
                 "rotation", [0, 0, 90],
                 "translation", [10, 0, 0],
                 "valign", "center",
                 "halign", "left",
                 "font", "DSEG14 Classic:style=Italic"]);
   ```

   ```scad
   text_from_plist("Hello world", ["text", "My text"]); // will display "Hello world"
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

function get_z_rotation(spec) =
  let (rotation = plist_get("rotation", spec),
       z_rotation = is_list(rotation) ? rotation[2] : rotation)
  z_rotation;

function get_rotation(spec) =
  let (rotation = plist_get("rotation", spec))
  is_list(rotation)
  ? [for (v = [rotation[0],
               rotation[1],
               rotation[2]])
    with_default(v, 0, "number")]
  : is_num(rotation) ? [0, 0, rotation] : rotation;

function should_swap_size(spec) =
  let (z_rotation = get_z_rotation(spec))
  is_num(z_rotation) && abs(z_rotation) == 90;

function get_text_size(txt, plist) =
  let (tm = textmetrics(text=txt,
                        size=plist_get("size", plist),
                        font=plist_get("font", plist),
                        spacing=plist_get("spacing", plist),
                        halign=plist_get("halign", plist),
                        valign=plist_get("valign", plist)),
       should_swap = should_swap_size(plist))
  should_swap ? [tm.size[1], tm.size[0]] : tm.size;

function get_y_size(spec) =
  get_size_at(1, spec);

function get_gap_before(spec) =
  plist_get("gap_before", spec, 0);

function get_gap_after(spec) =
  plist_get("gap_after", spec, 0);

function get_gap_x_offset(spec) =
  let (tr = plist_get("translation", spec))
  is_list(tr) ? tr[0] : 0;

function get_gap_y_offset(spec, default_gap = 0) =
  let (tr = plist_get("translation", spec))
  is_list(tr) ? tr[1] : default_gap;

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
                (is_list(v) &&
                 is_string(plist_get("text", v))
                 || is_num(plist_get("text", v))))) v],
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
   Render text row(s).

   Text row can be:
   - list of strings or numbers
   - the single string or number
   - list of text plists where each `plist` may contain:
   - `text` (string or number): The text to display.
   - `size`: The size of the text. Default is 4.
   - `color`: The optional color to use.
   - `rotation`: Optional value for `rotate`.
   - `translation`: Optional value for `translate`. Applies after rotation.
   - `spacing`: Factor to increase or decrease the character spacing. The default value of 1.
   - `font`: The name of the font that should be used.
   - `halign`: left, center (default) or right.
   - `valign`: top, center, baseline (default) and bottom.
   - `height`: Factor to increase or decrease the character spacing. The default value of 0.1.

   **Example:**

   ```scad
   text_rows("My text",
          ["size", 8,
           "color", "red",
           "spacing", 0.9,
           "height", 6,
           "rotation", [0, 0, 90],
           "translation", [10, 0, 0],
           "valign", "center",
           "halign", "left",
           "font", "DSEG14 Classic:style=Italic"]);
   ```

   ```scad
   text_rows("Hello world", ["text", "My text"]); // will display "Hello world"
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
                 align_to_bottom=true) {
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

  if (len(text_strings) > 0) {
    translate([center_x ? -max_x_size / 2 : 0,
               center_y ? total_size[1] / 2 : align_to_bottom ? total_size[1] : 0,
               0]) {
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
               final_y = y_acc + ratio * y_offset) {
            translate([0, final_y, 0]) {
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
            }
          }
        }
      }
    }
  }
}

module text_fit(x,
                y,
                h,
                txt="Dynamic Text",
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
