/**
 * Module: Bearing Shaft
 *
 * This module defines shaft-like components intended to fit into rotary bearings (such as
 * 685-Z flanged ball bearings). These shafts serve as the rotating or mounting interface
 * within the bracket-based steering system, interfacing between moving parts.
 *
 *
 * - bearing_shaft():
 *     Generates a vertically extruded cylinder with an optional stopper lip and chamfered tip.
 *     Chamfer taper ensures smoother insertion into bearings and improved 3D-print quality.
 *
 * - bearing_shaft_connector():
 *     Combines a base disc (lower_d) with an upper shaft for insertion into a bearing. Used
 *     widely in steering knuckles or rack mount components.
 *
 * - bearing_shaft_probes():
 *     Utility probe plates containing a set of shafts incrementally varying in diameters, for
 *     tolerance testing and calibration when fitting printed parts to actual bearings.
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

use <../util.scad>

module bearing_shaft(d,
                     h,
                     stopper_h = 1,
                     stopper_extra_r = 0.8,
                     chamfer_h) {

  chamfer_height = is_undef(chamfer_h) ? h * 0.2 : chamfer_h;

  h1 = h - chamfer_height - (is_undef(stopper_h) ? 0 : stopper_h);
  scale_factor = ((d / 2) - chamfer_height) / (d / 2);

  union() {
    if (!is_undef(stopper_h)) {
      linear_extrude(height=stopper_h, center=false) {
        circle(r=d / 2 + stopper_extra_r, $fn=360);
      }
    }

    translate([0, 0, is_undef(stopper_h) ? 0 : stopper_h]) {
      linear_extrude(height=h1, center=false) {
        circle(r=d / 2, $fn=360);
      }

      translate([0, 0, h1]) {
        linear_extrude(height = chamfer_height,
                       center=false,
                       scale=scale_factor) {
          circle(r=d / 2, $fn=360);
        }
      }
    }
  }
}

module bearing_shaft_connector(lower_d,
                               lower_h,
                               shaft_h,
                               shaft_d,
                               chamfer_h,
                               stopper_h) {

  upper_rad = lower_d / 2;

  union() {
    linear_extrude(height=lower_h, center=false) {
      circle(r=lower_d / 2, $fn=360);
    }

    translate([0, 0, lower_h]) {
      bearing_shaft(d=shaft_d,
                    h=shaft_h,
                    chamfer_h=chamfer_h,
                    stopper_h=stopper_h);
    }
  }
}

module bearing_shaft_probes(from=4.0,
                            to=4.4,
                            step=0.1,
                            h=8.0,
                            chamfer_h=undef) {
  vals = number_sequence(from, to, step);
  offst = to * 3;
  plate_height = 2;

  union() {
    for (i = [0:len(vals) - 1]) {
      translate([i * offst, 0, 0]) {
        bearing_shaft(h=h, d=vals[i], chamfer_h=chamfer_h);
      }
    }
  }

  translate([-offst / 2, -(to + 2) / 2, -plate_height]) {
    linear_extrude(height = plate_height, center=false) {
      square([offst * len(vals), to + 2]);
    }
  }
}

bearing_shaft_probes();