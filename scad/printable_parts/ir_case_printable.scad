/**
 * Module: A printable enclosure for Infrared LED Light Board Module.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

use <../head/ir_case.scad>

module ir_case_enclosure_printable(color="white", center=true) {
  ir_case(show_bolts=false,
          show_nuts=false,
          echo_bolts_info=false,
          center=center,
          color=color);
}

ir_case_enclosure_printable();