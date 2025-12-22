/**
 * Module: Connectors and slot for connector.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../parameters.scad>
include <../../colors.scad>

use <../../lib/functions.scad>
use <../../lib/shapes2d.scad>
use <../../lib/holes.scad>
use <../../lib/transforms.scad>
use <../../lib/shapes3d.scad>

module chassis_connector_tongue() {
  translate([0, 0, chassis_connector_height]) {
    translate([0, -chassis_connector_len / 2, 0]) {
      difference() {

        cube_3d(size=[chassis_connector_w,
                      chassis_connector_len,
                      chassis_connector_height]);
        mirror_copy([1, 0, 0]) {

          for (x = chassis_connector_screw_positions) {
            translate([x,
                       -chassis_connector_len / 2 + chassis_connector_dia / 2
                       + chassis_connector_edge_distance,
                       0]) {
              counterbore(d=chassis_connector_dia,
                          h=chassis_connector_height,
                          bore_h=0,
                          bore_d=0,
                          reverse=false,
                          sink=true);
            }
          }
        }
      }
    }
  }
}

module chassis_connector_groove() {
  let (out_clearance = 0.4,
       length = chassis_connector_len + chassis_connector_len_clearance
       + out_clearance) {
    translate([0, -length / 2 + out_clearance, chassis_connector_height]) {
      cube_3d(size=[chassis_connector_w + chassis_connector_w_clearance,
                    length,
                    chassis_connector_height]);
    }
  }

  mirror_copy([1, 0, 0]) {
    for (x = chassis_connector_screw_positions) {
      translate([x,
                 -chassis_connector_len + chassis_connector_dia / 2
                 + chassis_connector_edge_distance,
                 0]) {
        counterbore(d=chassis_connector_dia,
                    h=chassis_thickness,
                    bore_h=0,
                    bore_d=0,
                    reverse=false,
                    sink=true);
      }
    }
  }
}

chassis_connector_tongue();
chassis_connector_groove();