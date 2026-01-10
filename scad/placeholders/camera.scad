
/**
 * Module: Placeholder model for the Raspberry Camera Module 3
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/holes.scad>
use <../lib/shapes2d.scad>
use <../lib/transforms.scad>
use <bolt.scad>

module camera_module_with_holes_positions() {
  translate([0,
             camera_h / 2
             - camera_holes_size[1] / 2
             - camera_bolt_hole_dia / 2
             - camera_holes_distance_from_top,
             0]) {
    children();
  }
}

module camera_module(board_color=green_2,
                     opened=true,
                     left_text="Raspberry Pi",
                     right_text="Camera Module 3",
                     left_text_size=1.2,
                     right_text_size=1.2,
                     left_text_y_offset=2.4,
                     right_text_y_offset=2.4,
                     left_text_x_offset=0,
                     right_text_x_offset=1,
                     left_text_spacing=1.3,
                     right_text_spacing=1.1,
                     show_bolt=true,
                     bolt_h=4) {
  max_lens_y = max([for (i = [0 : len(camera_lens_items) - 1])
                       camera_lens_items[i][4] == "circle" ?
                         camera_lens_items[i][0] :
                         camera_lens_items[i][1]]);

  max_lens_x = max([for (i = [0 : len(camera_lens_items) - 1])
                       camera_lens_items[i][0]]);

  union() {
    color(board_color, alpha=1) {
      linear_extrude(height=camera_thickness, center=false) {
        difference() {
          rounded_rect([camera_w, camera_h],
                       center=true,
                       r=camera_offset_rad,
                       fn=40);
          camera_module_with_holes_positions() {
            four_corner_holes_2d(size=camera_holes_size,
                                 center=true,
                                 d=camera_bolt_hole_dia,
                                 fn=60);
          }
        }
      }
    }

    color(yellow_2, alpha=1) {
      translate([0, 0, -0.05]) {
        linear_extrude(height=camera_thickness + 0.1, center=false) {
          translate([0,
                     camera_h / 2
                     - camera_holes_size[1] / 2
                     - camera_bolt_hole_dia / 2
                     - camera_holes_distance_from_top,
                     0]) {
            size = camera_holes_size;
            border_w = (camera_w - camera_holes_size[0] -
                        camera_bolt_hole_dia) / 2;

            for (x_ind = [0, 1]) {
              for (y_ind = [0, 1]) {
                x_pos = -size[0] / 2 + x_ind * size[0];
                y_pos = -size[1] / 2 + y_ind * size[1];
                translate([x_pos, y_pos]) {
                  ring_2d(d=camera_bolt_hole_dia,
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

    translate([0,
               camera_h / 2
               - max_lens_y / 2
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
              } else if (type == "octagon") {
                linear_extrude(height=z, center=true) {
                  chamfered_square(size=w);
                }
              }
            }
          }
        }
      }
    };

    if (!is_undef(left_text)) {
      translate([-max_lens_x / 2
                 - left_text_size
                 - left_text_x_offset,
                 -camera_h / 2
                 + left_text_y_offset,
                 camera_thickness]) {
        rotate([0, 0, 90]) {
          color("white", alpha=1) {
            linear_extrude(height=0.1, center=false) {
              text(left_text,
                   size=left_text_size,
                   spacing=left_text_spacing,
                   halign="left");
            }
          }
        }
      }
    }

    if (!is_undef(right_text)) {
      translate([max_lens_x / 2
                 + right_text_size
                 + right_text_x_offset,
                 -camera_h / 2
                 + right_text_y_offset,
                 camera_thickness]) {
        color("white", alpha=1) {
          rotate([0, 0, 90]) {
            linear_extrude(height=0.1, center=false) {
              text(right_text,
                   size=right_text_size,
                   spacing=right_text_spacing);
            }
          }
        }
      }
    }

    translate([0,
               camera_h / 2 - camera_lens_distance_from_top,
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
    translate([0,
               -camera_h / 2
               + camera_module_socket_y_offset,
               - camera_module_socket_thickness]) {
      camera_ffc_connector(opened=opened);
    }
  }
}

module camera_ffc_connector(opened=false) {
  x1 = camera_module_ffc_zif_inner_len / 2;
  x2 = x1 * 0.91;
  y1 = camera_module_socket_base_h;
  y2 = camera_module_socket_upper_h + y1;
  cutout_z_pos = (camera_module_socket_thickness
                  -
                  camera_module_ffc_inner_thickness) / 2;

  wall_thickness =
    (camera_module_socket_thickness
     - camera_module_ffc_inner_thickness) / 2;

  latch_y = opened ?
    -camera_module_ffc_zif_h
    : -camera_module_ffc_zif_base_h;

  union() {
    color(brown_1, alpha=1) {
      difference() {
        linear_extrude(height=camera_module_socket_thickness,
                       center=false) {
          polygon([[-x1, 0],
                   [-x1, y1],
                   [-x2, y2],
                   [x2, y2],
                   [x1, y1],
                   [x1, 0]]);
        }
        translate([-camera_module_ffc_zif_len / 2,
                   -0.2,
                   cutout_z_pos]) {
          cube([camera_module_ffc_zif_len,
                y2,
                camera_module_ffc_inner_thickness]);
        }
      }
    }
    translate([0,
               latch_y,
               wall_thickness]) {
      camera_module_ffc_latch();
    }
  }
}

module camera_module_ffc_latch() {
  length = camera_module_ffc_zif_len / 2;
  cut_length = length * 0.16;
  thickness = camera_module_ffc_zif_thickness;
  half_of_thickness = thickness / 2;
  x2 = length - cut_length;

  color(onyx, alpha=1) {
    translate([0, 0, thickness]) {
      rotate([-90, 0, 0]) {
        union() {
          linear_extrude(height=camera_module_ffc_zif_base_h,
                         center=false) {
            polygon([[-length, thickness],
                     [length, thickness],
                     [length, 0],
                     [x2, 0],
                     [x2, half_of_thickness],
                     [-x2, half_of_thickness],
                     [-x2, 0],
                     [-length, 0]]);
          }
          translate([-(camera_module_ffc_zif_len * 0.9) / 2,
                     -(camera_module_ffc_inner_thickness - thickness) / 2,
                     camera_module_ffc_zif_base_h]) {
            cube([camera_module_ffc_zif_len * 0.9,
                  camera_module_ffc_inner_thickness,
                  camera_module_ffc_zif_h]);
          }
        }
      }
    }
  }
}

camera_module();
