/**
  * Module: Wago 221 five-conductor bracket, base-down without hardware.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

use <../wago/wago_bracket.scad>

module wago_bracket_printable() {
  wago_bracket(slot_mode=false,
               show_wago=false,
               show_bolts=false,
               show_bracket=true);
}

wago_bracket_printable();