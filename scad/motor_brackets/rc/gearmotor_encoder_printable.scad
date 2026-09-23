/**
  * Module: Removable motor encoder bracket, feet flat on the print bed.
  */
use <../../lib/plist.scad>
use <gearbox_bracket.scad>
use <gearmotor_encoder_bracket.scad>

params = gearmotor_bracket_compute_params();
encoder_mount = plist_get("encoder_mount", params);
if (!is_undef(encoder_mount)) {
  gearmotor_encoder_bracket(encoder_mount, anchor=[0, 0, 1]);
}
