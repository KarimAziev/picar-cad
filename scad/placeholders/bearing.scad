/**
 * Module: Bearing (Placeholder / Visual Mock-up)
 *
 * This module provides a non-functional, non-printable visual representation of a ball bearing
 * (e.g. flanged 685-Z bearing) for use in exploded views, assemblies, and animations. It is
 * intended purely as a decorative placeholder to visually indicate bearing placement within
 * mechanical systems such as rack-and-pinion steering setups.
 *
 * NOTE: This model is not dimensionally accurate for mechanical simulation and is NOT
 * meant for 3D printing or physical prototyping.
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>
include <../colors.scad>

use <../lib/shapes2d.scad>

bearing_shaft_d        = 8;
bearing_section_height = 7;
outer_ring_w           = 2;
shaft_ring_w           = 2;
outer_bearing_d        = 22;
rings                  = [[2, metallic_yellow_silver],
                          [1, onyx]];

module bearing(rings = [[0]],
               d = outer_bearing_d,
               outer_ring_w = outer_ring_w,
               outer_col = metallic_grey,
               shaft_d = bearing_shaft_d,
               shaft_ring_w = shaft_ring_w,
               shaft_ring_col = metallic_silver_2,
               h = bearing_section_height,
               flanged_h=0,
               flanged_w=0,
               fn=100) {
  ring_widths = [for (x = rings) x[0]];
  ring_colors = [for (x = rings) x[1]];
  num_rings = len(rings);

  d_first = shaft_d + 2 * shaft_ring_w;

  ring_width_last = ring_widths[num_rings - 1];
  d_last = d - 2 * outer_ring_w - 2 * ring_width_last;

  union() {

    color(outer_col) {
      linear_extrude(height = h) {
        ring_2d(w = outer_ring_w, d = d, outer = false, fn=fn);
      }

      if (flanged_w > 0 && flanged_h > 0) {
        linear_extrude(height = flanged_h) {
          ring_2d(w = flanged_w, d = d, outer = true, fn=fn);
        }
      }
    }

    color(shaft_ring_col)
      linear_extrude(height = h) {
      ring_2d(w=shaft_ring_w, d=shaft_d, outer = true, fn=fn);
    }

    for (i = [1 : num_rings]) {

      d_ring = (num_rings > 1)
        ? d_first + (d_last - d_first) * ((i - 1) / (num_rings - 1))
        : d_first;

      col_ring = ring_colors[i - 1];
      w_ring   = ring_widths[i - 1];

      color(col_ring) {
        linear_extrude(height = h) {
          ring_2d(w = w_ring, d = d_ring, outer = true, fn=40);
        }
      }
    }
  }
}

bearing();