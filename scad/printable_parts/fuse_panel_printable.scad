/**
 * Module: A printable fuse holder panel. Assumes standoffs to mount on the chassis.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
use <../panel_stack/panel_stack.scad>

module fuse_panel_printable() {
  panel_stack_print_plate(show_buttons_panel=false,
                          show_fuse_panel=true);
}

fuse_panel_printable();