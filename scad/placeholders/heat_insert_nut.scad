/**
 * Module: Placeholder for heat insert nut
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <bolt.scad>

heat_insert_plist_example = ["h", 5,
                             "d", 3.2,
                             "flang_d", 4,
                             "flang_h", 1.6,
                             "top_flang_h", 1.3,
                             "bottom_flat_h", 1.6,
                             "hole_d", 2];

/**
  ─────────────────────────────────────────────────────────────────────────────
  heat_insert_nut_props
  ─────────────────────────────────────────────────────────────────────────────

  Resolve insert dimensions and the maximum diameter of its mounting cutter.

  **Parameters:**
  - `plist`: Physical dimensions in mm, as accepted by heat_insert_nut_from_plist.

  **Returns:**
  The plist with optional dimensions/defaults resolved, plus outer_d, inner_h,
  slot_d, bore_d, bore_h, slot_bottom and slot_top. Unreversed cutter Z bounds
  include its boolean overshoot; the hardware occupies Z=0..h. slot_d includes both shaft
  and knurl clearances. The lower flange can interfere with the printed pocket
  before heat insertion; the cutter is not a clearance envelope of the hardware.
 */
function heat_insert_nut_props(plist) =
  let (h = plist_get("h", plist),
       d = plist_get("d", plist),
       hole_d = plist_get("hole_d", plist),
       flang_d = with_default(plist_get("flang_d", plist), d),
       flang_h = with_default(plist_get("flang_h", plist), 0),
       top_h = with_default(plist_get("top_flang_h", plist), flang_h),
       flat_h = with_default(plist_get("bottom_flat_h", plist), 0),
       clearance = with_default(plist_get("clearance", plist), 0.2),
       knurl_clearance = with_default(plist_get("knurl_clearance", plist), 0.6),
       taper = with_default(plist_get("use_taper", plist), false),
       bore_h = flat_h + flang_h / 2,
       bore_d = max(flang_d, d) + knurl_clearance,
       inner_h = h - flang_h - top_h - flat_h,
       slot_offset = 0.1,
       overshoot = 0.2)
  assert(is_num(h) && h > 0 && is_num(d) && d > 0
         && is_num(hole_d) && hole_d > 0 && hole_d < min(d, flang_d),
         "Insert height/diameters must be positive, with material around its thread")
  assert(min([flang_h, top_h, flat_h, inner_h, clearance, knurl_clearance]) >= 0,
         "Insert segments must fit h and clearances must be nonnegative")
  assert(!taper || h > bore_h + flat_h, "Insert taper needs positive height")
  plist_merge(plist, ["h", h, "d", d, "hole_d", hole_d,
                      "flang_d", flang_d, "flang_h", flang_h,
                      "top_flang_h", top_h, "bottom_flat_h", flat_h,
                      "clearance", clearance, "knurl_clearance", knurl_clearance,
                      "use_taper", taper,
                      "bolt_head_type", with_default(plist_get("bolt_head_type", plist), "pan"),
                      "outer_d", max(d, flang_d), "inner_h", inner_h,
                      "slot_d", max(d + clearance, bore_h > 0 || taper ? bore_d : 0),
                      "bore_d", bore_d, "bore_h", bore_h,
                      "slot_offset", slot_offset, "slot_overshoot", overshoot,
                      "slot_bottom", slot_offset - overshoot,
                      "slot_top", h + slot_offset + overshoot]);

module heat_insert_nut(h,
                       d,
                       hole_d,
                       flang_d,
                       flang_h,
                       top_flang_h,
                       bottom_flat_h,
                       fn1=60,
                       fn2=20,
                       color=metallic_gold_2,
                       clearance=0.2,
                       knurl_clearance=0.6,
                       use_taper=false,
                       bolt_head_type="pan",
                       show_bolt=false,
                       reverse=false,
                       slot_mode=false,
                       anchor=[0, 0, 1],
                       bolt_l,
                       bolt_head_offset=0) {
  props = heat_insert_nut_props(["h", h, "d", d, "hole_d", hole_d,
                                 "flang_d", flang_d, "flang_h", flang_h,
                                 "top_flang_h", top_flang_h,
                                 "bottom_flat_h", bottom_flat_h,
                                 "clearance", clearance, "knurl_clearance", knurl_clearance,
                                 "use_taper", use_taper, "bolt_head_type", bolt_head_type]);
  bottom_flat_h = plist_get("bottom_flat_h", props);
  flang_d = plist_get("flang_d", props);
  flang_h = plist_get("flang_h", props);
  top_flang_h = plist_get("top_flang_h", props);
  inner_h = plist_get("inner_h", props);
  clearance = plist_get("clearance", props);
  use_taper = plist_get("use_taper", props);
  bolt_head_type = plist_get("bolt_head_type", props);
  bolt_l = with_default(bolt_l, h);
  fn1 = with_default(fn1, 60);
  fn2 = with_default(fn2, 20);
  color = with_default(color, metallic_gold_2);

  module _slot() {
    cbore_d = plist_get("bore_d", props);
    cbore_h = plist_get("bore_h", props);
    insert_d = d + clearance;
    translate([0, 0, plist_get("slot_offset", props)]) {
      counterbore(h=h,
                  d=insert_d,
                  bore_d=cbore_d,
                  bore_h=cbore_h,
                  sink=false,
                  fn=50,
                  autoscale_step=plist_get("slot_overshoot", props),
                  reverse=false);
    }
    if (use_taper) {
      translate([0, 0, bottom_flat_h]) {
        cylinder(d1=insert_d,
                 d2=cbore_d,
                 h=h - cbore_h - bottom_flat_h,
                 $fn=50);
      }
    }
  }

  with_anchor(anchor=anchor, size=[d, d, h], centered=true) {
    translate([0, 0, reverse ? h : 0]) {
      maybe_rotate([reverse ? 180 : 0, 0, 0]) {
        if (slot_mode) {
          _slot();
        } else  {
          color(color, alpha=1) {
            difference() {
              union() {
                cylinder(d=d, h=bottom_flat_h, $fn=fn1);
                translate([0, 0, bottom_flat_h]) {
                  cylinder(d=flang_d, h=flang_h, $fn=fn2);
                  translate([0, 0, flang_h]) {
                    cylinder(d=d, h=inner_h, $fn=fn1);
                    translate([0, 0, inner_h]) {
                      cylinder(d=flang_d, h=top_flang_h, $fn=fn2);
                    }
                  }
                }
              }
              translate([0, 0, -0.5]) {
                cylinder(d=hole_d, h=h + 1, $fn=fn1);
              }
            }
          }
          if (show_bolt) {
            translate([0, 0, h + bolt_head_offset - bolt_l]) {
              bolt(d=hole_d, h=bolt_l, head_type=bolt_head_type);
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  heat_insert_nut_from_plist
  ─────────────────────────────────────────────────────────────────────────────

  Render a heat insert, its mounting cutter, or a cutter/hardware debug overlay.

  **Parameters:**
  - `plist`: Insert dimensions, clearances, taper, color and facet counts.
  - `show_bolt`: Show a screw entering the top of the insert in solid mode.
  - `reverse`: Reverse hardware and cutters together along Z.
  - `slot_mode`: Emit the mounting cutter instead of hardware.
  - `debug`: Overlay the cutter as background geometry on the hardware.
  - `anchor`: Shared reference anchor, centered on the body diameter in XY.
  - `bolt_l`: Screw length; defaults to plist bolt_l or insert height.
  - `bolt_head_offset`: Distance from the insert top to the screw head's
    underside, along local +Z before reversal; useful for lids/exploded views.
 */
module heat_insert_nut_from_plist(plist,
                                  show_bolt=false,
                                  reverse=false,
                                  slot_mode=false,
                                  debug=false,
                                  anchor=[0, 0, 1],
                                  bolt_l,
                                  bolt_head_offset=0) {
  h = plist_get("h", plist);
  d = plist_get("d", plist);
  hole_d = plist_get("hole_d", plist);
  flang_d = plist_get("flang_d", plist);
  flang_h = plist_get("flang_h", plist);
  top_flang_h = plist_get("top_flang_h", plist);
  bottom_flat_h = plist_get("bottom_flat_h", plist);
  fn1 = plist_get("fn1", plist);
  fn2 = plist_get("fn2", plist);
  color = plist_get("color", plist);
  clearance = plist_get("clearance", plist);
  knurl_clearance = plist_get("knurl_clearance", plist);
  use_taper = plist_get("use_taper", plist);
  bolt_head_type = plist_get("bolt_head_type", plist);
  module _heat_insert_nut(slot_mode=slot_mode) {
    heat_insert_nut(h=h,
                    d=d,
                    hole_d=hole_d,
                    flang_d=flang_d,
                    flang_h=flang_h,
                    top_flang_h=top_flang_h,
                    bottom_flat_h=bottom_flat_h,
                    fn1=fn1,
                    fn2=fn2,
                    color=color,
                    clearance=clearance,
                    knurl_clearance=knurl_clearance,
                    bolt_head_type=bolt_head_type,
                    use_taper=use_taper,
                    show_bolt=show_bolt,
                    bolt_l=with_default(bolt_l, plist_get("bolt_l", plist)),
                    bolt_head_offset=bolt_head_offset,
                    reverse=reverse,
                    slot_mode=slot_mode,
                    anchor=anchor);
  }
  if (debug) {
    %_heat_insert_nut(slot_mode=true);
    _heat_insert_nut(slot_mode=false);
  } else {
    _heat_insert_nut();
  }
}

heat_insert_nut_from_plist(heat_insert_plist_example);
