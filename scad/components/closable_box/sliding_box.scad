/**
 * Module: Sliding closable box with support for custom cell grids
 *
 * Features: configurable rim/rails, lid hooks/latches, and optional inner cell grids.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../../colors.scad>

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/text.scad>
use <../../lib/transforms.scad>
use <grid.scad>
use <rim.scad>
use <sliding_lid.scad>
use <util.scad>

function sliding_box_full_height(size, lid_thickness, rim_h) =
  let (box_h = size[2])
  box_h + lid_thickness + rim_h;

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
            rim(h1=rim_h1,
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
            cube_3d([latch_l, latch_h + 0.1, latch_h + 0.1],
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
        intersection() {
          linear_extrude(height = h +
                         (include_rim_sizing ? rim_h : 0) - latch_h
                         - 0.3,
                         center=false,
                         convexity = 2) {

            union() {
              grid(grid_spec=grid_spec,
                   inner_wall_thickness=inner_wall_thickness,
                   parent_size=[inner_x, inner_y]);
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
                            lid_color=green_2,
                            box_color=green_2,
                            lid_texts,
                            text_props,
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
    sliding_lid(size=size,
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
                text_props=text_props,
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

box_size = [25, 40, 10];
lid_thickness = 2;
rim_h = 3;

closable_box_and_lid(w=25,
                     l=40,
                     h=10,
                     corner_rad=1.0,
                     use_inner_round=true,
                     rim_h=rim_h,
                     rim_w=2,
                     rim_front_w=1,
                     include_rim_sizing=true,
                     rail_thickness=1,
                     rail_tolerance=0.4,
                     rail_top_thickness=1,
                     front_thickness=1,
                     lid_thickness=lid_thickness,
                     latch_h=1,
                     latch_l=0.5,
                     hook_h=0.32,
                     hook_l=5,
                     lid_texts=["M3 Bolts", "Bolts"],
                     text_props=["size", 8,
                                 "color", "red",
                                 "spacing", 0.9],
                     side_thickness=1,
                     bottom_thickness=1.5,
                     assembly=true,
                     assembly_debug=false,
                     show_lid=true,
                     show_box=true,
                     grid_spec=[[30, [50, 20]],
                                [30, [30, 30, 30, 30]],
                                [50, [80]],
                                [20, [30, 30]]]);

translate([-box_size[0] / 2, 0, 0]) {

  #cube_3d([box_size[0], box_size[1],
            sliding_box_full_height(size=box_size,
                                    rim_h=rim_h,
                                    lid_thickness=lid_thickness)]);
}