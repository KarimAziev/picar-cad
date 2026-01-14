/**
 * Module: A printable panel for switch buttons. Assumes standoffs.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <../panel_stack/panel_stack.scad>

module button_panel_printable() {
  panel_stack_print_plate(show_buttons_panel=false,
                          show_fuse_panel=true);
}

button_panel_printable();