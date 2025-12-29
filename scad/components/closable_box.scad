/**
 * Module: Sliding closable box with support for custom cell grids
 *
 * Features: configurable rim/rails, lid hooks/latches, and optional inner cell grids.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <../lib/functions.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>
use <../lib/debug.scad>

function cumsums(a) = [for (i =
                              [0 : len(a) - 1]) sum([for (j = [0 : i]) a[j]])];
function spec_to_mm(spec, span) = spec > 1 ? spec : spec * span;

module box_rim(h1, h2, size_1, size_2, corner_rad, fn) {
  hull() {
    linear_extrude(height=h1, center=false, convexity=2) {
      rounded_rect(size_1, center=true, r=corner_rad, fn=fn);
    }
    translate([0, 0, h1]) {
      linear_extrude(height=h2, center=false, convexity=2) {
        rounded_rect(size_2, center=true, r=corner_rad, fn=fn);
      }
    }
  }
}

function max_corner_rad(size=[w, l, h],
                        side_thickness=2,
                        front_thickness=2,
                        rim_h=0,
                        rim_w=0,
                        rim_front_w=0,
                        include_rim_sizing=false,
                        use_inner_round=false,
                        fudge = 0.4) =
  let (w0 = size[0],
       l0 = size[1],
       h0 = size[2],
       rim_enabled = (rim_h > 0) && (rim_w > 0 || rim_front_w > 0),
       rim_should_subtract = rim_enabled && include_rim_sizing,
       w = w0 - (rim_should_subtract ? rim_w * 2 : 0),
       l = l0 - (rim_should_subtract ? rim_front_w * 2 : 0),
       h = h0 - (rim_should_subtract ? rim_h : 0),
       h_eff = use_inner_round ? (h - fudge) : h,
       inner_x = w - side_thickness * 2,
       inner_y = l - front_thickness * 2,
       limits2d = [w / 2, l / 2, inner_x / 2, inner_y / 2],
       all_limits = use_inner_round ? concat(limits2d, [h_eff]) : limits2d,
       positive_limits = [for (t = all_limits) (t < 0 ? 0 : t)])
  min(positive_limits);

module text_rows(texts = [["M3 BOLTS", // text
                           11, // text_size
                           0.4, // depth
                           "#191919", // text_color
                           [0, 0, 0], // additional_translate_spec
                           1.0, // text gap
                           "Liberation Sans:style=Bold Italic", // font
                           "center", // halign: "left", "center" or "right"
                           "center" // valign: "center", "baseline" and "bottom"
                          ]],
                 margin=2) {
  rows = texts;
  text_sizes = map_idx(rows, 1, 10);

  for (i = [0 : len(rows) - 1]) {
    let (spec = rows[i],
         txt = spec[0],
         size = spec[1],
         depth=spec[2],
         trsnslate_spec=spec[4],
         spacing=spec[5],
         font=spec[6],
         halign=is_undef(spec[7]) ? "center"
         : spec[7] == "left" ? "right"
         : spec[7] == "right" ? "left"
         : spec[7],
         valign=spec[8],
         offst = i > 0 ? sum(text_sizes, i) + margin : 0) {
      translate(trsnslate_spec) {
        translate([offst, 0, -0.1]) {
          linear_extrude(height=depth + 0.1, center=false) {
            rotate([180, 0, 0]) {
              rotate([0, 0, 90]) {
                text(text=txt,
                     size=size,
                     halign=halign,
                     valign=valign,
                     font=font,
                     spacing=spacing);
              }
            }
          }
        }
      }
    }
  }
}

module box_lid(size=[86, 90, 35],
               debug=false,
               thickness=2.5,
               rail_thickness=2,
               rail_tolerance=0.4,
               rail_top_thickness=1,
               front_thickness=2,
               hook_distance=1,
               corner_rad=15,
               include_rim_sizing=false,
               side_thickness,
               use_inner_round,
               rim_h=4,
               rim_w=3,
               rim_front_w=2,
               hook_h=0.32,
               hook_l,
               fn=100,
               lid_texts, // [[text, text_size, depth, text_color, additional_translate_spec, text_spacing, text_font, halign, valign]...]
               rail_cutout_extra_len,
               lid_color="#1da760",
               hook_color="#f7d7ff") {
  corner_rad = min(corner_rad,
                   max_corner_rad(size=size,
                                  side_thickness=side_thickness,
                                  front_thickness=front_thickness,
                                  rim_h=rim_h,
                                  rim_w=rim_w,
                                  rim_front_w=rim_front_w,
                                  include_rim_sizing=include_rim_sizing,
                                  use_inner_round=use_inner_round));
  rim_w = is_undef(rim_w) ? 0 : rim_w;
  rim_h = is_undef(rim_h) ? 0 : rim_h;
  rim_front_w = is_undef(rim_front_w) ? 0 : rim_front_w;

  rim_enabled = rim_h > 0 && (rim_w > 0 || rim_front_w > 0);

  rim_should_subtract = rim_enabled && include_rim_sizing;

  w = size[0] - (rim_should_subtract ? rim_w * 2 : 0);
  l = size[1] - (rim_should_subtract ? rim_front_w * 2 : 0);
  inner_y = l - front_thickness * 2;
  lid_w = w + rim_w * 2 + rail_thickness * 3;
  lid_l = l + rim_front_w * 2 + rail_thickness * 3;
  rim_h1 = rim_h / 2;
  rim_h2 = rim_h / 2;
  rim_size1 = [w, l];
  rim_size2 = [w + rim_w * 2, l + rim_front_w * 2];
  diff_l = max(0, rim_size2[1] - rim_size1[1]);
  scale_x = (rim_size2[0] + rail_tolerance * 2) / rim_size2[0];
  rail_cutout_len = corner_rad + diff_l / 2
    + (is_undef(rail_cutout_extra_len) ? l * 0.2 : rail_cutout_extra_len);

  union() {
    difference() {
      color(lid_color, alpha=1) {
        union() {
          linear_extrude(height=thickness
                         + rim_h
                         + rail_top_thickness,
                         center=false) {
            rounded_rect([lid_w, lid_l],
                         center=true,
                         r=corner_rad,
                         fn=fn);
          }
        }
      }
      translate([0, lid_l / 2 - rail_cutout_len / 2 + 0.1, thickness]) {
        cube_3d(size=[lid_w + 1,
                      rail_cutout_len + 0.1,
                      thickness
                      + rail_top_thickness
                      + rim_h + 0.1],
                center=true);
      }
      translate([0, 0, thickness + rail_top_thickness]) {
        linear_extrude(height=thickness
                       + rail_top_thickness
                       + rim_h + 0.1,
                       center=false) {
          rounded_rect([rim_size1[0],
                        rim_size1[1]],
                       center=true,
                       r=corner_rad,
                       fn=fn);
        }
      }
      translate([0, 0, thickness]) {
        scale([scale_x, 1, 1]) {
          box_rim(h1=rim_h2 + 0.0,
                  h2=rim_h1,
                  size_1=rim_size2,
                  size_2=rim_size1,
                  corner_rad=corner_rad,
                  fn=fn);
        }
      }
      if (!is_undef(lid_texts)) {
        if (l < w) {
          rotate([0, 0, 90]) {
            text_rows(lid_texts);
          }
        } else {
          text_rows(lid_texts);
        }
      }
    }
    translate([0,
               -inner_y / 2 + hook_h / 2 + hook_distance,
               thickness]) {
      rotate([90, 0, 90]) {
        debug_highlight(debug=debug) {
          color(hook_color, alpha=1) {
            cylinder(h=is_undef(hook_l)
                     ? min(w / 2, 4)
                     : hook_l,
                     r=hook_h,
                     center=true,
                     $fn=18);
          }
        }
      }
    }
  }
}

module box(size=[86, 90, 35],
           side_thickness=2,
           front_thickness=2,
           bottom_thickness=2,
           corner_rad=15,
           include_rim_sizing=false,
           use_inner_round=false,
           rim_h=4,
           rim_w=3,
           rim_front_w=2,
           latch_h=1.4,
           latch_l=10,
           fn=100,
           inner_wall_thickness = [0.05, 0.02],
           grid_spec) {
  max_corner_r = max_corner_rad(size=size,
                                side_thickness=side_thickness,
                                front_thickness=front_thickness,
                                rim_h=rim_h,
                                rim_w=rim_w,
                                rim_front_w=rim_front_w,
                                include_rim_sizing=include_rim_sizing,
                                use_inner_round=use_inner_round);
  corner_rad = min(corner_rad, max_corner_r);

  rim_w = is_undef(rim_w) ? 0 : rim_w;
  rim_h = is_undef(rim_h) ? 0 : rim_h;
  rim_front_w = is_undef(rim_front_w) ? 0 : rim_front_w;

  rim_enabled = rim_h > 0 && (rim_w > 0 || rim_front_w > 0);

  rim_should_subtract = rim_enabled && include_rim_sizing;

  w = size[0] - (rim_should_subtract ? rim_w * 2 : 0);
  l = size[1] - (rim_should_subtract ? rim_front_w * 2 : 0);
  h = size[2]  - (rim_should_subtract ? rim_h : 0);

  inner_x = w - side_thickness * 2;
  inner_y = l - front_thickness * 2;

  latch_depth = latch_h;

  module base_box() {
    if (use_inner_round) {
      rounded_cube([w,
                    l,
                    h + corner_rad],
                   center=true,
                   r=corner_rad);
    } else {
      linear_extrude(height=h, center=false, convexity=2) {
        rounded_rect([w, l], center=true, r=corner_rad, fn=fn);
      }
    }
  }

  intersection() {
    union() {
      difference() {
        union() {
          base_box();

          rim_h1 = rim_h / 2;
          rim_h2 = rim_h / 2;
          rim_size1 = [w, l];
          rim_size2 = [w + rim_w * 2, l + rim_front_w * 2];

          translate([0, 0, h]) {
            box_rim(h1=rim_h1,
                    h2=rim_h2,
                    size_1=rim_size1,
                    size_2=rim_size2,
                    corner_rad=corner_rad,
                    fn=fn);
          }
        }

        translate([0, 0, bottom_thickness]) {
          if (use_inner_round) {
            rounded_cube([inner_x,
                          inner_y,
                          h + corner_rad + rim_h + 0.1],
                         r=corner_rad,
                         center=true);
          } else {
            linear_extrude(height=h + rim_h + 0.1, center=false, convexity=2) {
              rounded_rect(size=[inner_x, inner_y],
                           center=true,
                           r=corner_rad,
                           fn=fn);
            }
          }
        }

        mirror_copy([0, 1, 0]) {
          translate([0,
                     l / 2 + rim_front_w - latch_h / 2,
                     h + rim_h - latch_h]) {
            cube_3d([latch_l, latch_depth + 0.1, latch_h + 0.1],
                    center=true);
          }
        }
      }
      mirror_copy([0, 1, 0]) {
        translate([0,
                   l / 2 + rim_front_w - latch_h,
                   h + rim_h - latch_h]) {
          rotate([90, 0, 90]) {
            cylinder(h=latch_l, r=latch_h, center=true, $fn=18);
          }
        }
      }

      if (!is_undef(grid_spec) && len(grid_spec) > 0) {
        row_pcts = [for (r = grid_spec) r[0]];
        row_total = sum(row_pcts);
        row_heights = [for (rp = row_pcts) inner_y * rp / row_total];

        cell_pct_lists = [for (r = grid_spec) r[1]];
        cell_widths_per_row = [for (cl = cell_pct_lists)
            let (tot = sum(cl)) [for (c = cl) inner_x * c / tot]];

        is_pair = (len(inner_wall_thickness) == 2);
        row_wall_spec = is_pair
          ? inner_wall_thickness[0]
          : inner_wall_thickness;
        col_wall_spec = is_pair
          ? inner_wall_thickness[1]
          : inner_wall_thickness;

        row_prefix = cumsums(row_heights);
        row_bottoms = [for (i = [0 : len(row_heights) - 1])
            -inner_y/2 + (i == 0 ? 0 : sum([for (j=[0:i-1])
                                               row_heights[j]]))];

        eps = 0.02;

        intersection() {
          linear_extrude(height = h +
                         (include_rim_sizing ? rim_h : 0) - latch_depth
                         - 0.3,
                         center=false,
                         convexity = 2) {
            union() {
              // horizontal walls (between rows)
              for (i = [0 : len(row_heights) - 2]) {
                let (y_border = -inner_y/2 + row_prefix[i],
                     t = spec_to_mm(row_wall_spec, (row_heights[i]
                                                    + row_heights[i + 1])
                                    / 2))
                  translate([0, y_border, 0]) {

                  square([inner_x + eps, t + eps], center=true);
                }
              }

              for (ri = [0 : len(cell_widths_per_row) - 1]) {
                let (cw = cell_widths_per_row[ri],
                     cw_prefix = cumsums(cw),
                     row_bot = row_bottoms[ri],
                     row_h = row_heights[ri],
                     y_center = row_bot + row_h / 2)
                  for (ci = [0 : len(cw) - 2]) {
                    let (x_border = -inner_x/2 + cw_prefix[ci],
                         tcol = spec_to_mm(col_wall_spec,
                                           (cw[ci] + cw[ci + 1]) / 2))
                      translate([x_border, y_center]) {
                      square([tcol + eps, row_h + eps], center=true);
                    }
                  }
              }
            }
          }
          base_box();
        }
      }
    }
    cube_3d(size=[size[0] + rim_w, size[1] + rim_front_w, size[2] + rim_h],
            center=true);
  }
}

module closable_box_and_lid(w=40,
                            l=60,
                            h=20,
                            rim_h=3,
                            rim_w=2,
                            rim_front_w=1,
                            include_rim_sizing=true,
                            corner_rad=5,
                            rail_thickness=1,
                            rail_tolerance=0.4,
                            rail_top_thickness=1,
                            front_thickness=1,
                            lid_thickness=1,
                            latch_h=0.5,
                            latch_l=10,
                            hook_h=0.32,
                            hook_l=5,
                            side_thickness=1,
                            bottom_thickness=1.5,
                            lid_color="#1da760",
                            box_color="#1da760",
                            lid_texts, // [[text, text_size, depth, text_color, additional_translate_spec, text_spacing, text_font, halign, valign]...]
                            grid_spec,
                            use_inner_round=false,
                            assembly=false,
                            show_lid=true,
                            show_box=true,
                            fn=100,
                            assembly_debug=false,
                            spacing=10) {
  size = [w, l, h];

  if (show_box) {
    color(box_color, alpha=1) {
      box(size=size,
          side_thickness=side_thickness,
          bottom_thickness=bottom_thickness,
          corner_rad=corner_rad,
          use_inner_round=use_inner_round,
          rim_h=rim_h,
          fn=fn,
          include_rim_sizing=include_rim_sizing,
          front_thickness=front_thickness,
          rim_w=rim_w,
          rim_front_w=rim_front_w,
          latch_h=latch_h,
          latch_l=latch_l,
          grid_spec=grid_spec);
    }
  }
  module lid_box() {
    box_lid(size=size,
            fn=fn,
            corner_rad=corner_rad,
            front_thickness=front_thickness,
            rim_h=rim_h,
            thickness=lid_thickness,
            side_thickness=side_thickness,
            use_inner_round=use_inner_round,
            include_rim_sizing=include_rim_sizing,
            rail_thickness=rail_thickness,
            rail_tolerance=rail_tolerance,
            rail_top_thickness=rail_top_thickness,
            rim_w=rim_w,
            rim_front_w=rim_front_w,
            hook_h=hook_h,
            hook_l=hook_l,
            lid_texts=lid_texts,
            lid_color=lid_color);
  }

  if (assembly) {
    let (t = $t,
         pulse = 1 - abs(1 - 2*t),
         ax = assembly ? (l < w ? -w : 0) : 0,
         ay = assembly ? (l >= w ? -l : 0) : 0,
         tx = ax * pulse,
         ty = ay * pulse) {
      translate([$t > 0 ? tx : 0,
                 $t > 0 ? ty : 0,
                 h + lid_thickness +
                 (is_undef(rim_h) ? 0 : rim_h)]) {
        rotate([0, 180, 0]) {
          debug_highlight(debug=assembly_debug) {
            lid_box();
          }
        }
      }
    }
  }

  if (show_lid) {
    translate([show_box ? w + spacing : 0, 0, 0]) {
      lid_box();
    }
  }
}

closable_box_and_lid(w=25,
                     l=40,
                     h=10,
                     corner_rad=1.0,
                     use_inner_round=true,
                     rim_h=3,
                     rim_w=2,
                     rim_front_w=1,
                     include_rim_sizing=true,
                     rail_thickness=1,
                     rail_tolerance=0.4,
                     rail_top_thickness=1,
                     front_thickness=1,
                     lid_thickness=1,
                     latch_h=1,
                     latch_l=0.5,
                     hook_h=0.32,
                     hook_l=5,
                     lid_texts=[],
                     side_thickness=1,
                     bottom_thickness=1.5,
                     assembly=true,
                     assembly_debug=true,
                     show_lid=true,
                     show_box=true,
                     grid_spec=[[30, [20, 50]],
                                [30, [30, 30, 30, 30]],
                                [50, [80]],
                                [20, [30, 30]]]);