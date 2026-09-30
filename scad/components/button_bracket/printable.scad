/**
  * Module: Toggle-switch bracket, base-down without hardware.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../steering_params.scad>
use <button_bracket.scad>

button_bracket(toggle_switch_bracket_plist, show_button=false);
