/**
 * Module: Text utilities
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <functions.scad>
use <transforms.scad>
use <debug.scad>
use <plist.scad>
use <placement.scad>

/**
   Render text from the given specification or defaults.
   `spec` may contain:
   0. `text`: The text to generate. Only text is required.
   1. `size`: The size of the text. Default is 4.
   2. `color`: The optional color to use.
   3. `rotation`: Optional value for `rotate`.
   4. `translation`: Optional value for `translate`. Applies after rotation.a
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
  if (!is_undef(plist)) {
    let (txt_raw = is_undef(txt) ? plist_get("text", plist, txt) : txt,
         txt = is_num(txt_raw) ? str(txt_raw) : txt_raw,
         size = (with_default(plist_get("size", plist), default_size)),
         colr = (with_default(plist_get("color", plist), default_color)),
         rotation = (with_default(plist_get("rotation", plist),
                                  default_rotation)),
         translation = (with_default(plist_get("translation", plist),
                                     default_translation)),
         spacing = (with_default(plist_get("spacing", plist),
                                 default_spacing)),
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

module text_fit(x,
                y,
                size,
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
