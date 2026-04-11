/**
  * Module: E-clip placeholder
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../colors.scad>

use <../lib/debug.scad>
use <../lib/transforms.scad>

module e_clip(shaft_d,
              color=matte_black,
              clip_radial = undef,
              thickness=0.4,
              fn,
              debug=false) {

  fn = is_undef(fn) ? ($preview ? 20 : 30) : fn;

  tr = is_undef(clip_radial) ? shaft_d * 0.18 : clip_radial;

  outer_r = shaft_d / 2 + tr;

  d = outer_r * 2;
  r = d / 2;

  round_r = r * 0.06;

  x1 = r * 0.45;
  y1 = r * 0.27;

  pts = [[-r * 0.9, -r * 0.8],
         [-r * 0.52, -r * 0.6],
         [-x1, -y1],
         [-x1 - r * 0.1, -y1 + r * 0.1],
         [-x1 - r * 0.12, -y1 + r * 0.2],
         [-x1 - r * 0.1, r * 0.15],
         [-x1, r * 0.07],
         [-r * 0.75, r * 0.25],
         [-r * 0.69, r * 0.5],
         [-r * 0.55, r * 0.65],
         [-r * 0.15, r * 0.85],
         [-r * 0.25, r * 0.8],
         [-r * 0.15, r * 0.6],
         [round_r, r * 0.6],
         [0, -r * 1.1]];

  color(color) {
    linear_extrude(height=thickness, center=false) {
      difference() {
        circle(r=d / 2, $fn=fn);
        mirror_copy([1, 0, 0]) {
          offset_vertices_2d(r=round_r) {
            polygon(pts);
          }
        }
      }
    }
  }
  if (debug) {
    translate([0, 0, thickness]) {
      debug_polygon_text(pts, font_size=r * 0.1, circle_r=r * 0.02);
    }
  }
}

e_clip(shaft_d=10, debug=false);
