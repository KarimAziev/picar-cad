/**
 * Module: A “rail” that secures enclosure for Infrared LED Light Board Module with two M2 bolts
 *
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../parameters.scad>

use <../head/ir_case.scad>

module ir_case_rail_printable(color="white") {
  translate([-ir_case_width / 2,
             (ir_case_rail_y_pos()
              + ir_case_carriage_wall_thickness),
             0]) {

    ir_case_printable(show_rail=true,
                      show_case=false,
                      rail_color=color,
                      spacing=0);
  }
}

ir_case_rail_printable();
