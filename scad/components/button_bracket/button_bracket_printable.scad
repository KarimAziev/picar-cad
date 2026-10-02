/**
  * Module: Toggle-switch bracket, base-down without hardware.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>

use <button_bracket.scad>

module button_bracket_printable(plist=toggle_switch_bracket_plist) {
  button_bracket(plist,
                 show_bracket=true,
                 show_button=false,
                 slot_mode=false,
                 show_crimp_terminal=false);
}

button_bracket_printable(toggle_switch_bracket_plist);
