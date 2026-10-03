/**
 * Module: LiPo Battery Pack placeholder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/placement.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/text.scad>
use <../lib/transforms.scad>
use <t_plug.scad>
use <lipo_pack_wiring.scad>

lipo_power_wiring_size    = [9.6, 8, 16.5];
lipo_wiring_balancer_size = [8.75, 8, 11.3];

module lipo_wiring_slot(size=lipo_power_wiring_size) {
  translate([size[0] / 2, size[1] / 2, size[2] / 2]) {
    difference() {
      cube(size, center=true);
      cube(size=[size[0] * 0.8, size[1] + 1, size[2] * 0.8], center=true);
    }
  }
}

module lipo_text_rows(texts = [["TURNIGY",
                                11,
                                black_1,
                                [0, -25, 0],
                                1.32,
                                "Liberation Sans:style=Bold Italic"]],
                      margin=2) {
  rows = reverse(texts);
  text_sizes = map_idx(rows, idx=1, def_val=10);
  for (i = [0 : len(rows) - 1]) {
    let (spec = rows[i],
         txt = spec[0],
         size = spec[1],
         colr = spec[2],
         trsnslate_spec=spec[3],
         spacing=spec[4],
         font=spec[5],
         offst = i > 0 ? sum(text_sizes, i) + margin : 0) {
      translate(trsnslate_spec) {
        translate([0, offst, 0]) {
          color(colr, alpha=1) {
            linear_extrude(height=0.04, center=false) {
              text(txt,
                   size=size,
                   halign="left",
                   spacing=is_undef(spacing) ? 1 : spacing,
                   font=font);
            }
          }
        }
      }
    }
  }
}

module lipo_pack_side_text(texts=[["5.5   RAPID", 10,
                                   metallic_silver_1,
                                   [0, 19, -2]]],
                           direction="ltr") {
  for (spec = texts) {
    let (txt = spec[0],
         size = spec[1],
         colr = spec[2],
         spacing=spec[4],
         font=spec[5],
         trsnslate_spec=spec[3]) {
      translate(trsnslate_spec) {
        translate([lipo_pack_width, 0, lipo_pack_height - size]) {
          rotate([90, 0, 90]) {
            color(colr, alpha=1) {
              linear_extrude(height=0.04, center=false, convexity=2) {
                text(txt,
                     size=size,
                     halign="left",
                     direction=direction,
                     spacing=spacing,
                     font=font);
              }
            }
          }
        }
      }
    }
  }
}

module lipo_pack(center=true,
                 side_texts=[["5.5",
                              10,
                              metallic_silver_1,
                              [0, 19, -2],
                              1,
                              "Liberation Sans:style=Bold"],
                             ["RAPID",
                              10,
                              metallic_silver_1,
                              [0, 60, -2],
                              1,
                              "Nimbus Mono PS:style=Bold Italic"],
                             ["VOLTAGE: 4S2P 14.8V",
                              1.5,
                              metallic_silver_1,
                              [0, 105, -7],
                              0.8,
                              "Nimbus Mono PS:style=Bold Italic"],
                             ["140C DISCHARGE 81.4Wh",
                              1.5,
                              metallic_silver_1,
                              [0, 104, -9],
                              0.8,
                              "Nimbus Mono PS:style=Bold Italic"],
                             ["TURNIGY",
                              1.5,
                              metallic_silver_1,
                              [0, 118, -18],
                              0.8,
                              "Liberation Sans:style=Bold Italic"]],
                 top_center_spec=[["TURNIGY",
                                   11,
                                   onyx,
                                   [21, 0, 0],
                                   1.32,
                                   "Liberation Sans:style=Bold Italic"]],
                 top_left_texts=[["RAPID",
                                  8,
                                  red_1,
                                  [20, 0, 0],
                                  1.0,
                                  "Nimbus Mono PS:style=Bold Italic"],
                                 ["4S2P 140C HARDCASE LIPO PACK",
                                  1.4,
                                  metallic_silver_1,
                                  [32, 0, 0],
                                  0.8,]],
                 top_right_texts=[["5500",
                                   8,
                                   metallic_silver_1,
                                   [20, 0, 0],
                                   1.0,
                                   "Liberation Sans:style=Bold Italic"],
                                  ["Voltage: 4S2P 14.8V    140C DISCHARGE 81.4Wh                                        TURNIGY",
                                   1.4,
                                   metallic_silver_1,
                                   [20, 0, 0],
                                   0.8,]]) {

  translate([center ? -lipo_pack_width / 2 : 0,
             center ? -lipo_pack_length / 2 : 0,
             0]) {
    union() {
      union() {
        color(black_1) {
          cube([lipo_pack_width,
                lipo_pack_length,
                lipo_pack_height],
               center=false);
        }
        color(matte_black, alpha=1) {
          translate([0,
                     -lipo_power_wiring_size[1]  * 0.3,
                     lipo_pack_height - lipo_power_wiring_size[2]  + 2]) {
            lipo_wiring_slot(size=lipo_power_wiring_size);
          }
          translate([lipo_pack_width - lipo_power_wiring_size[0],
                     -lipo_wiring_balancer_size[1] * 0.3,
                     lipo_pack_height - lipo_wiring_balancer_size[2] + 2]) {
            lipo_wiring_slot(size=lipo_wiring_balancer_size);
          }
        }
        color(red_1, alpha=1) {
          let (colored_len = lipo_pack_length * 0.3,
               color_h = lipo_pack_height * 0.15) {
            translate([-0.01,
                       lipo_pack_length
                       - colored_len
                       - lipo_pack_length * 0.05,
                       lipo_pack_height
                       - color_h
                       - lipo_pack_height * 0.3]) {
              cube([lipo_pack_width + 0.02,
                    colored_len,
                    color_h],
                   center=false);
            }
          }
        }

        color(red_1, alpha=1) {
          let (colored_len = lipo_pack_length * 0.15,
               color_h = lipo_pack_height * 0.15) {
            translate([-0.01,
                       lipo_pack_length * 0.15,
                       lipo_pack_height
                       - color_h
                       - lipo_pack_height * 0.3]) {
              cube([lipo_pack_width + 0.02,
                    colored_len,
                    color_h],
                   center=false);
            }
          }
        }
      }

      if (!is_undef(top_center_spec)) {
        let (sizes=map_idx(top_center_spec, idx=1, def_val=10),
             total_h=sum(sizes)) {
          translate([lipo_pack_width / 2 - total_h / 2,
                     lipo_pack_length,
                     lipo_pack_height]) {
            rotate([0, 0, -90]) {
              lipo_text_rows(top_center_spec);
            }
          }
        }
      }

      translate([0,
                 lipo_pack_length,
                 lipo_pack_height]) {
        rotate([0, 0, -90]) {
          if (!is_undef(top_left_texts) && !is_undef(top_left_texts[0])) {
            lipo_text_rows(texts=top_left_texts);
          }

          if (!is_undef(top_right_texts) && !is_undef(top_right_texts[0])) {
            translate([lipo_pack_width, 0, 0]) {
              lipo_text_rows(texts=top_right_texts);
            }
          }
        }
      }

      translate([lipo_pack_width, 0, lipo_pack_height]) {
        rotate([0, 0, 180]) {
          rotate([0, 0, -90]) {
            if (!is_undef(top_left_texts) && !is_undef(top_left_texts[0])) {
              lipo_text_rows(texts=top_left_texts);
            }

            translate([lipo_pack_width, 0, 0]) {
              if (!is_undef(top_right_texts) && !is_undef(top_right_texts[0])) {
                lipo_text_rows(texts=top_right_texts);
              }
            }
          }
        }
      }

      if (!is_undef(side_texts) && !is_undef(side_texts[0])) {
        lipo_pack_side_text(side_texts);

        translate([lipo_pack_width,
                   lipo_pack_length,
                   0]) {
          rotate([0, 0, 180]) {
            lipo_pack_side_text(side_texts);
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  lipo_pack_oriented_size
  ────────────────────────────────────────────────────────────────────────────

  Return a LiPo pack plist's XYZ size after applying its orientation.

  **Parameters:**

  `plist`: LiPo pack properties containing logical `size=[width, length,
  height]` and optional `orientation`.

  **Returns:**

  The oriented XYZ bounding-box size.
 */
function lipo_pack_oriented_size(plist) =
  orientation_size(plist_get("orientation", plist, "wlh"),
                   plist_get("size", plist));

module lipo_pack_bent(angle, r, fn=100) {
  rotate_extrude(angle=angle) {
    translate([r, 0, 0]) {
      circle(r=r, $fn=fn);
    }
  }
}

function lipo_pack_has_side_wiring(plist) =
  in_list(plist_get("lead_exit", plist),
          ["rear_side",
           "front_side"]);

/**
  ────────────────────────────────────────────────────────────────────────────
  lipo_pack_from_pl
  ──────────────────────────────────────────────────────────────────────────────

  Render a plist-defined LiPo pack in its requested orientation.

  **Parameters:**

  `plist`: Pack properties. `size` is logical `[width, length, height]` and
  `orientation` defaults to `"wlh"`.
  `anchor`: Anchor of the final oriented bounding box.
  `show_wiring`: Include leads and their connector. Each lead accepts
  `routing="top"` to fold its measured `l` back over the pack, without moving
  its exit. Omitted routing preserves the original straight preview.
 */
module lipo_pack_from_pl(plist, anchor=[0, 1, 1], show_wiring=true) {
  size = plist_get("size", plist);
  w = size[0];
  l = size[1];
  h = size[2];
  front_end_corner_r = plist_get("front_end_corner_r", plist);
  rear_end_corner_r = plist_get("rear_end_corner_r", plist);

  orientation = plist_get("orientation", plist, "wlh");

  color = plist_get("color", plist, "#B51F2C");
  side_cover_box = plist_get("side_cover", plist);
  top_cover_box = plist_get("top_cover", plist, []);

  top_cover_box_bg = plist_get("bg", top_cover_box);

  corner_end_sides = [for (v = [(is_undef(front_end_corner_r) ? undef :
                                 ["top", front_end_corner_r]),
                                (is_undef(rear_end_corner_r) ? undef :
                                 ["bottom", rear_end_corner_r])])
      if (v) v];

  function _from_percent_val(val, total) = is_string(val)
    ? percent_to_mm(parse_percent(val),
                    total=total)
    : val;

  module _cube() {
    rotate([0, 90, 0]) {
      cuboid(size=[size[2], size[1], size[0]],
             r=front_end_corner_r,
             side=corner_end_sides,
             anchor=[-1, 0, 0]);
    }
  }

  module _cable_exit(color,
                     d,
                     wire_l,
                     exit_l) {
    let (r = d / 2,
         l = exit_l - r) {
      color(color, alpha=1) {
        union() {
          if (l > 0) {
            cyl(d=d, h=l, orientation="hlw");
          }

          translate([(l > 0 ? -l : 0), -r, r]) {
            rotate([0, 0, 90]) {
              lipo_pack_bent(angle=90, r=r);
            }
          }

          if (wire_l > 0) {
            translate([0, -r, 0]) {
              cyl(d=d,
                  h=wire_l,
                  orientation="whl",
                  anchor=[-1, -1, 1]);
            }
          }
        }
      }
    }
  }

  module _wire_lead(lead_side,
                    d,
                    wire_l,
                    exit_l,
                    connector,
                    cables) {
    let (r = d / 2) {
      mirror([lead_side == "left" ? 0 : 1, 0, 0]) {
        translate([0, -(size[1] / 2 - r), 0]) {
          translate([-(size[0] / 2),
                     0,
                     size[2] / 2 - r]) {

            rotate([0, -90, 0]) {
              columns_children(cols=len(cables), w=d, gap=0) {
                _cable_exit(d=d,
                            color=cables[$i],
                            wire_l=wire_l,
                            exit_l=exit_l);
              }
            }

            translate([0, -wire_l, 0]) {
              if (connector == "t-plug") {
                rotate([0, -90, 0]) {
                  t_plug_female(anchor=[1, -1, 1]);
                }
              } else if (connector == "xt-90") {
                // todo
              }
            }
          }
        }
      }
    }
  }

  module _cover(pl,
                total_w=w,
                total_l=l,
                w_def="90%",
                l_def="90%",
                is_side=false,
                anchor=[0, 0, 1]) {
    bg = plist_get("bg", pl);
    cover_size = plist_get("size", pl, []);
    corner_r = plist_get("corner_r", pl);
    texts = plist_get("texts", pl, []);
    let (params = [[total_w, w_def], [total_l, l_def]],
         xy = [for (i = [0:1]) let (v = cover_size[i],
                                    spec = params[i],
                                    total = spec[0],
                                    def = spec[1],
                                    val = with_default(v, def),)
                                 maybe_percent_string_to_num(val=val,
                                                             total=total)],
         cover_w = xy[0],
         cover_y = xy[1]) {
      color(bg, alpha=1) {
        cuboid(size=[cover_w, cover_y, 0.07],
               r=corner_r,
               anchor=anchor);
      }

      if (texts && len(texts) > 0) {
        text_texts_defaults = plist_get("props",
                                        pl,
                                        ["size",
                                         (cover_w * 0.9) / len(texts)]);
        final_pl = plist_merge(plist_merge(["halign", "center",
                                            "valign", "center"],
                                           text_texts_defaults),
                               ["rotation", [0, 0, 0]]);
        rotate([0, 0, 90]) {
          text_rows(texts, plist=final_pl);
        }
      }
    }
  }

  with_orientation(from="wlh",
                   to=orientation,
                   size=size,
                   anchor=anchor) {

    if (top_cover_box_bg) {
      translate([0, 0, h]) {
        _cover(top_cover_box);
      }
    }
    if (side_cover_box) {
      mirror_copy([1, 0, 0]) {
        translate([w / 2, 0, 0]) {
          rotate([0, 90, 0]) {
            intersection() {
              _cover(side_cover_box,
                     total_w=h,
                     l_def="100%",
                     anchor=[-1, 0, 1]);
              _cube();
            }
          }
        }
      }
    }

    for (lead_key = ["power_lead", "balance_lead"]) {
      power_lead = plist_get(lead_key, plist, []);
      let (power_lead_d=plist_get("d", power_lead),
           power_lead_exit_l=plist_get("exit_l", power_lead, 0),
           power_lead_l=plist_get("l", power_lead, 0),
           power_lead_side=plist_get("side", power_lead, "left"),
           power_lead_connector=plist_get("connector", power_lead),
           power_lead_colors=plist_get("colors", power_lead, ["red", "black"])) {
        if (show_wiring && power_lead_d) {
          if (plist_get("routing", power_lead) == "top") {
            lipo_pack_top_wiring(lipo_pack_top_wiring_props(plist, lead_key));
          } else if (lipo_pack_has_side_wiring(plist)) {
            _wire_lead(lead_side=power_lead_side,
                       d=power_lead_d,
                       wire_l=power_lead_l,
                       exit_l=power_lead_exit_l,
                       cables=power_lead_colors,
                       connector=power_lead_connector);
          } else {
            // TODO:
          }
        }
      }
    }

    color(color) {
      _cube();
    }
  }
}

lipo_pack_from_pl(plist=["size", [lipo_pack_width,
                                  lipo_pack_length,
                                  lipo_pack_height],
                         "rear_end_corner_r", "50%",
                         "lead_exit", "rear_side", // rear_side | front_side | front_end | rear_end
                         "power_lead", ["side", "left",
                                        "connector", "t-plug",
                                        "d", 4.35,
                                        "l", 80],
                         "balance_lead", ["side", "right",
                                          "d", 1.72,
                                          "colors", ["red", "white", "black"],
                                          "l", 40],
                         "rear_end_corner_r", "5%",
                         "orientation", "wlh", // wlh (default) | lwh | lhw | whl | hlw | hwl
                         "top_cover", ["bg", "gold",
                                       "texts", [["text", "3S",
                                                  "size", 10,
                                                  "halign", "center",
                                                  "gap_before", 4],
                                                 ["text", "5000MAH",
                                                  "size", 10,
                                                  "halign", "center",
                                                  "gap_before", 10]],
                                       "props", ["halign", "center", "color", "#28282B"]],
                         "side_cover", ["bg", "silver"]],
                  anchor=[0, 0, 1]);
