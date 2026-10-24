/**
  * Module: Printable encoder bracket
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../../lib/plist.scad>
use <gearmotor_encoder_bracket.scad>
use <util.scad>

module encoder_bracket_printable() {
  params = gearmotor_bracket_compute_params();
  encoder_mount = plist_get("encoder_mount", params);

  if (!is_undef(encoder_mount)) {
    rotate([-90, 0, 0]) {
      gearmotor_encoder_bracket(encoder_mount, anchor=[0, 0, 1]);
    }
  }
}

encoder_bracket_printable();