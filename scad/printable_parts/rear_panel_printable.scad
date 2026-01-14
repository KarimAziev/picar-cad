/**
 * Module: A printable plate with two 12-mm mounting holes for two switch buttons
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <../components/rear_panel/rear_panel.scad>

module rear_panel_printable(colr="white") {
  rear_panel(show_switch_button=false, colr=colr);
}

rear_panel_printable();