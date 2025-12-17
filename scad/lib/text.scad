/**
 * Module: Text utilities
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <functions.scad>
use <transforms.scad>
use <debug.scad>

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
