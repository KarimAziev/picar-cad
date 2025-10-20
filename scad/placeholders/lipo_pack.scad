/**
 * Module: LiPo Battery Pack placeholder
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>;

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
              text(txt, size=size,
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
                text(txt, size=size,
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

lipo_pack();
