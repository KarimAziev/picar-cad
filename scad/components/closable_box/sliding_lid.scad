/**
 * Module: Sliding closable box with support for custom cell grids
 *
 * Features: configurable rim/rails, lid hooks/latches, and optional inner cell grids.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/text.scad>
use <../../lib/transforms.scad>
use <grid.scad>
use <rim.scad>

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

module sliding_lid(size=[86, 90, 35],
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
                   lid_texts,
                   text_props,
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
          rim(h1=rim_h2 + 0.0,
              h2=rim_h1,
              size_1=rim_size2,
              size_2=rim_size1,
              corner_rad=corner_rad,
              fn=fn);
        }
      }
      if (!is_undef(lid_texts)) {

        props = normalize_texts(lid_texts,
                                plist=text_props,
                                default_valign="center",
                                default_halign="center",
                                default_height=thickness * 0.1);

        text_plists = plist_get("plists", props);

        plists = [for (pl = text_plists)
            let (th = plist_get("height", pl),
                 translation = plist_get("translation", pl),
                 updated_translation = is_list(translation)
                 ? [translation[0],
                    translation[1],
                    translation[2]
                    - th]
                 : [0, 0, -th],
                 merged = plist_merge(pl,
                                      ["translation", updated_translation,
                                       "height", th + 0.1]))
              merged];

        translate([0, 0, 0.01]) {
          rotate([180, 0, 0]) {
            rotate([0, 0, 90]) {
              text_rows(plists);
            }
          }
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

sliding_lid(size=[25, 40, 10],
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
            thickness=1,
            hook_h=0.32,
            hook_l=5,
            lid_texts=[["text", "M3 Bolts", "gap_after", 2], "Bolts"],
            text_props=["size", 6,
                        "color", "red",
                        "spacing", 0.9],
            side_thickness=1);