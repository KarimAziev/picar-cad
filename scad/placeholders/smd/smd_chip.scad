/**
 * Module: Placeholder for SMD chip (Surface Mount Device chip).
 *
 * An SMD chip is
 * an electronic component that is mounted directly onto the surface of a
 * printed circuit board (PC
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../parameters.scad>
include <../../colors.scad>

use <../../lib/l_bracket.scad>
use <../pins.scad>
use <../../lib/shapes2d.scad>
use <../../lib/transforms.scad>
use <../../lib/plist.scad>
use <../../lib/functions.scad>
use <../../lib/text.scad>

module smd_chip_2d(length,
                   w,
                   r=0.2,
                   fn=20,
                   center=false) {
  rounded_rect([length, w],
               center=center,
               fn=fn,
               r=r);
}

module smd_chip_slot_2d(length,
                        total_w,
                        r=0.2,
                        fn=20,
                        center=false) {
  rounded_rect([length, total_w],
               center=center,
               fn=fn,
               r=r);
}

module smd_chip(length,
                total_w,
                w,
                h,
                r=0.2,
                fn=20,
                smd_color=black_1,
                j_lead_n,
                j_lead_thickness=0.5,
                j_lead_color=metallic_yellow_silver,
                lower_lead_fraction=0.7,
                center=true) {

  let (thickness = j_lead_thickness,
       amount = j_lead_n,

       available_w = (total_w - w) / 2 - (thickness * 2),
       upper_len = available_w * (1 - lower_lead_fraction),
       lower_len = available_w * lower_lead_fraction,
       base_h = h * 0.9,
       full_len = j_lead_full_len(lower_len=lower_len,
                                  upper_len=upper_len,
                                  thickness=thickness),
       pitch = pin_pitch_edge_aligned(total_len=length,
                                      pin_w=thickness,
                                      count=amount),
       y = w / 2 - full_len / 2 + full_len) {

    translate([center ? 0 : length / 2, center ? 0 : total_w / 2, 0]) {

      union() {
        color(smd_color, alpha=1) {
          linear_extrude(height=h,
                         center=false) {
            smd_chip_2d(length=length,
                        w=w,
                        r=r,
                        fn=fn,
                        center=true);
          }
        }

        if (!is_undef(j_lead_n) && j_lead_n > 0) {
          mirror_copy([0, 1, 0]) {
            translate([0, y, 0]) {
              color(j_lead_color, alpha=1) {
                j_leads_centered(base_h=base_h,
                                 lower_len=lower_len,
                                 upper_len=upper_len,
                                 count=amount,
                                 thickness=thickness,
                                 pitch=pitch);
              }
            }
          }
        }
      }
    }
  }
}

function expand_j_leads(input_data) =
  flatten_pairs([for (rec = input_data)
                    let (sides = with_default(plist_get("sides", rec, []), [], "list"),
                         props = plist_remove("sides", rec))
                      for (s = sides) [s, props]]);

function normalize_j_leads(j_lead_plists) =
  let (sides = [for (pl = j_lead_plists)
           [for (side = plist_get("sides", pl, []))
               plist_merge(plist_remove_by_keys(["sides"], pl),
                           ["side", side])]],
       flatten = flatten_pairs(sides))
  flatten;

module smd_chip_from_plist(plist,
                           center=true) {
  plist = with_default(plist, []);
  placeholder_size = plist_get("placeholder_size", plist, []);
  chip_color = plist_get("color", plist, black_1);
  chip_size = plist_get("chip_size", plist, []);
  text_pl = plist_get("text_props", plist, []);
  text_gap = plist_get("gap", text_pl, 2);
  txt = plist_get("text", plist, plist_get("text", text_pl));
  txt_rows = plist_get("text_rows", plist, plist_get("text", text_pl));

  j_leads = with_default(plist_get("j_lead", plist), [], "list");
  r = plist_get("corner_rad", plist, 0.2);

  total_x = placeholder_size[0];
  total_y = placeholder_size[1];

  chip_x = chip_size[0];
  chip_y = chip_size[1];
  chip_z = chip_size[2];

  translate([center ? 0 : total_x / 2, center ? 0 : total_y / 2, 0]) {
    union() {
      color(chip_color, alpha=1) {
        linear_extrude(height=chip_z, center=false) {
          rounded_rect([chip_x, chip_y],
                       r=r,
                       center=true);
        }
      }

      if (!is_undef(txt) && txt != "") {
        translate([0, 0, chip_z]) {
          text_from_plist(txt, plist=text_pl);
        }
      }

      if (!is_undef(txt_rows)) {
        translate([0, 0, chip_z]) {
          text_rows(txt_rows, plist=text_pl, gap=text_gap);
        }
      }

      if (len(j_leads) > 0) {
        let (j_leads_by_side = expand_j_leads(j_leads),
             j_leads_list = normalize_j_leads(j_leads)) {

          for (pl = j_leads_list) {
            let (count = plist_get("count", pl, 0),
                 thickness = plist_get("thickness", pl, 0.0),
                 side = plist_get("side", pl),
                 lower_lead_fraction = plist_get("lower_fraction", pl, 0.7)) {
              assert(member(side, ["top", "left", "bottom", "right"]),
                     "Invalid side was passed to smd_chip");
              if (count > 0 && thickness > 0) {
                let (y_axle = member(side, ["top", "bottom"]),
                     pair_side = y_axle
                     ? (side == "top" ? "bottom" : "top")
                     : (side == "left" ? "right" : "left"),
                     pair = plist_get(pair_side, j_leads_by_side, []),
                     pair_thickness = plist_get("thickness", pair, 0),
                     pair_count = plist_get("count", pair, 0),
                     has_pair = pair_count > 0 && pair_thickness > 0,
                     total_val = y_axle ? total_y : total_x,
                     total_len = y_axle ? chip_x : chip_y,
                     chip_val = y_axle ? chip_y : chip_x,
                     available_w = (total_val - chip_val) / (has_pair ? 2 : 1)
                     - (thickness + pair_thickness),
                     upper_len = available_w * (1 - lower_lead_fraction),
                     lower_len = available_w * lower_lead_fraction,
                     base_h = chip_z * 0.9,
                     full_len = j_lead_full_len(lower_len=lower_len,
                                                upper_len=upper_len,
                                                thickness=thickness),
                     pitch = pin_pitch_edge_aligned(total_len=total_len,
                                                    pin_w=thickness,
                                                    count=count),
                     factor = y_axle
                     ? (side == "top" ? 1 : -1)
                     : (side == "left" ? 1 : -1),
                     pos = y_axle
                     ? (factor * (chip_val / 2))
                     : (factor * -(chip_val / 2 - full_len / 2 + full_len))) {
                  translate([y_axle ? 0 : pos,
                             y_axle ? pos + (factor * full_len / 2) : 0,
                             0]) {
                    color(plist_get("color", pl, metallic_silver_1),
                          alpha=1) {
                      rotate([0, 0, y_axle
                              ? (side == "top" ? 0 : 180)
                              : factor * 90]) {
                        j_leads_centered(base_h=base_h,
                                         lower_len=lower_len,
                                         upper_len=upper_len,
                                         count=count,
                                         thickness=thickness,
                                         pitch=pitch);
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
}

smd_chip_from_plist(["placeholder", "smd_chip",
                     "type", "rect",
                     "placeholder_size", [15,
                                          17],
                     "corner_rad", 0.0,
                     "chip_size", [15, 10, 1.65],
                     "text_rows", ["MC33886VW",
                                   "KDA2322"],
                     "text_props", ["size", 1.0,
                                    "gap", 3,
                                    "color", "red",
                                    "spacing", 0.9,
                                    "height", 0.1,
                                    "valign", "center",
                                    "halign", "center"],
                     "j_lead", [["count", 11,
                                 "thickness", 0.4,
                                 "sides", ["top", "bottom"]]]],
                    center=false);
