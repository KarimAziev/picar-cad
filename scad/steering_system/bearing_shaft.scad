/**
 * Module: Bearing Shaft
 * This file contains modules for creating shafts that are inserted into the bearings.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

use <../util.scad>

module bearing_shaft(d,
                     h,
                     chamfer_h) {

  chamfer_height = is_undef(chamfer_h) ? h * 0.2 : chamfer_h;

  h1 = h - chamfer_height;
  scale_factor = ((d / 2) - chamfer_height) / (d / 2);

  union() {
    linear_extrude(height=h1, center=false) {
      circle(r=d / 2, $fn=360);
    }

    translate([0, 0, h - chamfer_height]) {
      linear_extrude(height = chamfer_height,
                     center=false,
                     scale=scale_factor) {
        circle(r=d / 2, $fn=360);
      }
    }
  }
}

module bearing_shaft_probes(from=4.0, to=4.4, step=0.1, h=8.0, chamfer_h=undef) {
  vals = number_sequence(from, to, step);
  offst = to * 3;

  union() {
    for (i = [0:len(vals) - 1]) {
      translate([i * offst, 0, 0]) {
        bearing_shaft(h=h, d=vals[i], chamfer_h=chamfer_h);
      }
    }
  }
  translate([-offst / 2, -(to + 2) / 2, 0]) {
    linear_extrude(height = 2, center=true) {
      square([offst * len(vals), to + 2]);
    }
  }
}

bearing_shaft_probes();