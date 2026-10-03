/**
  * Module: Placeholder for the suspension arm pin
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../colors.scad>

use <../lib/functions.scad>
use <../lib/shapes3d.scad>
use <e_clip.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  suspension_arm_pin
  ─────────────────────────────────────────────────────────────────────────────

  Model a cylindrical pin with optional end flats and retaining-clip grooves.

  **Parameters:**
  - `d`, `l`: Full pin diameter and length, with the axis at X=Y=0 and Z=0..l.
  - `fn`: Fragment count; defaults to 30.
  - `color`: Hardware color.
  - `show_e_clip`: Display retaining clips at the selected groove positions.
  - `e_clip_thickness`: Clip thickness used to center clips within the grooves.
  - `groove_d`: Groove root diameter; defaults to `d - 0.4`.
  - `groove_side`: `"top"`, `"bottom"`, or `"all"` selects grooved ends.
  - `pad_side`: `"top"`, `"bottom"`, or `"all"` selects flattened ends;
    other values omit flats.
  - `pad_horizontal_one_side`: Cut only +Y when true; otherwise cut opposing flats.
  - `pad_l`: Flat length at each selected end; zero or `undef` omits flats.
  - `pad_w`: Remaining Y thickness of the flattened profile; zero or `undef`
    omits flats. A single flat is measured from the original -Y tangent.
  - `groove_w`: Groove axial width; defaults to 0.4.
  - `groove_offset`: End-to-groove edge distance; zero or `undef` omits grooves.

  Flats preserve the full pin length and do not fill grooves that cross them.
 */
module suspension_arm_pin(d,
                          l,
                          fn,
                          color=metallic_silver_1,
                          show_e_clip=false,
                          e_clip_thickness=0.4,
                          groove_d,
                          groove_side="all", // "top" | "bottom" | "all"
                          pad_side="all",    // "top" | "bottom" | "all"
                          pad_horizontal_one_side=false,
                          pad_l,
                          pad_w,
                          groove_w,
                          groove_offset) {
  fn = is_undef(fn) ? 30 : fn;
  pad_l = with_default(pad_l, 0);
  pad_w = with_default(pad_w, 0);

  is_all = groove_side == "all";
  is_bottom = groove_side == "bottom";

  pad_is_all = pad_side == "all";
  pad_is_bottom = pad_side == "bottom";
  pad_is_top = pad_side == "top";

  groove_d = with_default(groove_d, d - 0.4);
  groove_w = with_default(groove_w, 0.4);

  // Cut the flats from the complete pin so single-end and disabled pads
  // retain the full length, and grooves remain present inside the pads.
  module _with_pad() {
    difference() {
      children();
      if (pad_l > 0 && pad_w > 0) {
        for (bottom = [true, false]) {
          if (pad_is_all || (bottom ? pad_is_bottom : pad_is_top)) {
            translate([0, 0, bottom ? 0 : l - pad_l]) {
              difference() {
                translate([-d, -d, -0.01]) {
                  cube([2 * d, 2 * d, pad_l + 0.02]);
                }
                translate([0, 0, -0.02]) {
                  flatted_cyl(d=d,
                              h=pad_l + 0.04,
                              flat_d=pad_w,
                              both_sides=!pad_horizontal_one_side,
                              $fn=fn,
                              color=color);
                }
              }
            }
          }
        }
      }
    }
  }

  module _main() {
    color(color, alpha=1) {
      cylinder(d=d, h=l, $fn=fn);
    }
  }

  if (is_undef(groove_offset) || groove_offset == 0) {
    _with_pad() {
      _main();
    }
  } else {
    z_top = l - groove_offset - groove_w;
    z = (is_all || is_bottom) ? groove_offset : z_top;
    union() {
      _with_pad() {
        difference() {
          _main();

          translate([0, 0, z]) {
            ring(od=d + 1, d=groove_d, h=groove_w);
          }
          if (is_all) {
            translate([0, 0, z_top]) {
              ring(od=d + 1, d=groove_d, h=groove_w);
            }
          }
        }
      }

      if (show_e_clip) {
        if (is_all || is_bottom) {
          translate([0,
                     0,
                     groove_offset + (groove_w - e_clip_thickness) / 2]) {
            e_clip(d, thickness=e_clip_thickness);
          }
        }
        if (is_all || !is_bottom) {
          translate([0,
                     0,
                     l - groove_offset - (groove_w + e_clip_thickness) / 2]) {
            e_clip(d, thickness=e_clip_thickness);
          }
        }
      }
    }
  }
}

suspension_arm_pin(d=4,
                   l=39.5,
                   pad_l=5.5,
                   pad_w=3.0,
                   pad_side="all",
                   color=undef,
                   groove_side="all",
                   show_e_clip=false);
