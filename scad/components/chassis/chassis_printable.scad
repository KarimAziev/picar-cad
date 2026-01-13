/**
 * A robot chassis (printable)
 *
 * It can be printed either split into a body and an upper part and then fastened with a connector, or as a single part.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../../colors.scad>
include <../../parameters.scad>

use <chassis_body.scad>
use <upper_chassis.scad>

panel_color   = "white";
use_connector = chassis_use_connector;

module chassis_printable(panel_color=panel_color,
                         chassis_use_connector=use_connector) {
  color(panel_color, alpha=1) {
    union() {
      translate([0,
                 (chassis_use_connector ? chassis_connector_len + 4 : 0),
                 0]) {
        chassis_upper_printable();
      }
      chassis_body_printable();
    }
  }
}

chassis_printable();
