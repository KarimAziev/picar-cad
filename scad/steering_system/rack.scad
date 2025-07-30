/**
 * File: rack.scad
 *
 * This file contains modules to generate a rack for a steering system. The rack
 * is designed with a toothed profile to mesh with a pinion and integrates the
 * appropriate mounting connectors both sides.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>
use <rack_connector.scad>
use <rack_util.scad>
use <bracket.scad>
use <../util.scad>
use <steering_pinion.scad>

module rack(size=[rack_len, rack_width, rack_base_h],
            pinion_d=pinion_d,
            tooth_pitch = steering_pinion_tooth_pitch(),
            tooth_height = steering_pinion_tooth_height(),
            r=rack_rad,
            show_brackets=false,
            bracket_color=blue_grey_carbon,
            rack_color=blue_grey_carbon) {
  rack_len = size[0];
  rack_teeth       = ceil(rack_len / tooth_pitch);
  rack_margin = rack_len - rack_teeth * tooth_pitch;

  h = size[1];
  base_h = size[2];

  function gen_tooth(i, pitch, base, tooth) =
    [[i * pitch + pitch/2, base + tooth],
     [(i + 1) * pitch,     base]];

  function gen_teeth(i, n, pitch, base, tooth) =
    i >= n ? [] : concat(gen_tooth(i, pitch, base, tooth),
                         gen_teeth(i + 1, n, pitch, base, tooth));

  pts = concat([[rack_margin, 0], [rack_margin, base_h]],
               gen_teeth(0, rack_teeth, tooth_pitch, base_h, tooth_height * 2.1),
               [[rack_margin + rack_teeth * tooth_pitch, 0]]);

  union() {
    color(rack_color) {
      linear_extrude(height=base_h, center=false) {
        square([rack_len + abs(rack_margin), h], center=true);
      }
    }

    translate([-rack_len * 0.5, 0, 0]) {
      fn = 7;
      rotate([90, 0, 0]) {
        color(rack_color) {
          linear_extrude(height=h, center=true) {
            offset_vertices_2d(r=r) {
              polygon(points = pts);
            }
          }
        }
      }
    }

    offst = [-rack_len / 2 + rack_margin / 2 - bracket_bearing_outer_d / 2 - 0.4,
             0,
             0];

    translate(offst) {
      if (show_brackets) {
        rack_connector_assembly(bracket_color=bracket_color);
      } else {
        color(rack_color) {
          rack_connector();
        }
      }
    }
    mirror([1, 0, 0]) {
      translate(offst) {
        if (show_brackets) {
          rack_connector_assembly(bracket_color=bracket_color);
        } else {
          color(rack_color) {
            rack_connector();
          }
        }
      }
    }
  }
}

module rack_mount(show_brackets=false, rack_color=blue_grey_carbon) {
  rotate([0, 0, 180]) {
    rack(tooth_pitch = steering_pinion_tooth_pitch(),
         tooth_height = steering_pinion_tooth_height(),
         r = rack_rad,
         show_brackets = show_brackets,
         rack_color = rack_color);
  }
}

module rack_assembly(show_brackets=true, rack_color=blue_grey_carbon) {
  rack_mount(show_brackets=show_brackets, rack_color=rack_color);
}

rack_mount(show_brackets=false);

// rotate([0, 0, 0]) {
//   translate([0, 0, steering_pinion_d - 5.9]) {
//     rotate([90, 32, 0]) {
//       steering_pinion();
//     }
//   }
// }