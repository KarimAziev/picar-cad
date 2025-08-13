
/**
 * Module: Placeholder model for the Raspberry Camera Module 3
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <../util.scad>

module camera_module() {
  max_lens_y = max([for (i = [0 : len(camera_lens_items) - 1])
                       camera_lens_items[i][4] == "circle" ?
                         camera_lens_items[i][0] :
                         camera_lens_items[i][1]]);

  union() {
    color("green", alpha=1) {
      linear_extrude(height=camera_thickness, center=false) {
        difference() {
          rounded_rect([camera_w, camera_h], center=true, r=camera_offset_rad);
          translate([0, camera_h / 2
                     - camera_holes_size[1] / 2
                     - camera_screw_hole_dia / 2
                     - camera_holes_distance_from_top,
                     0]) {
            four_corner_holes_2d(size=camera_holes_size,
                                 center=true,
                                 hole_dia=camera_screw_hole_dia,
                                 fn_val=60);
          }
        }
      }
    }

    color("darkgoldenrod", alpha=1) {
      translate([0, 0, camera_thickness]) {
        linear_extrude(height=0.1, center=false) {
          translate([0, camera_h / 2
                     - camera_holes_size[1] / 2
                     - camera_screw_hole_dia / 2
                     - camera_holes_distance_from_top,
                     0]) {
            size = camera_holes_size;
            border_w = (camera_w - camera_holes_size[0] -
                        camera_screw_hole_dia) / 2;

            for (x_ind = [0, 1]) {
              for (y_ind = [0, 1]) {
                x_pos = -size[0] / 2 + x_ind * size[0];
                y_pos = -size[1] / 2 + y_ind * size[1];
                translate([x_pos, y_pos]) {
                  ring_2d(d=camera_screw_hole_dia,
                          w=border_w,
                          fn=30,
                          outer=true);
                }
              }
            }
          }
        }
      }
    }

    translate([0, camera_h / 2 - max_lens_y / 2
               - camera_lens_distance_from_top,
               camera_thickness]) {
      for (i = [0 : len(camera_lens_items) - 1]) {
        let (spec = camera_lens_items[i],
             w = spec[0],
             h = spec[1],
             z = spec[2],
             col = spec[3],
             type = spec[4],
             fn = spec[5],
             prev_heights = [for (i = [0 : i - 1]) camera_lens_items[i][2]],
             offst = i == 0 ? 0 : sum(prev_heights)) {

          translate([0, 0, z / 2 + offst]) {
            color(col, alpha=1) {
              if (type == "cube") {
                cube([w, h, z], center=true);
              } else if (type == "circle") {
                cylinder(h=z, r=w / 2, center=true, $fn=fn);
              }
            }
          }
        }
      }
    };

    translate([0, camera_h / 2 - camera_lens_distance_from_top,
               camera_thickness]) {
      for (i = [0 : len(camera_lens_connectors) - 1]) {
        let (spec = camera_lens_connectors[i],
             w = spec[0],
             h = spec[1],
             y = spec[2],
             col = spec[3],
             type = spec[4],
             fn_or_x = spec[5],
             prev_heights = [for (i = [0 : i - 1])
                 camera_lens_connectors[i][1]],
             offst = i == 0 ? 0 : sum(prev_heights)) {

          if (is_num(w)) {
            translate([-w / 2, offst, 0]) {
              color(col, alpha=1) {
                if (type == "cube") {
                  translate([is_undef(fn_or_x)
                             ? 0
                             : fn_or_x,
                             0,
                             0]) {
                    cube([w, h, y], center=false);
                  }
                } else if (type == "circle") {
                  cylinder(h=y, r=w / 2, center=false, $fn=fn_or_x);
                }
              }
            }
          }
        }
      }
    }
  }
}
camera_module();
