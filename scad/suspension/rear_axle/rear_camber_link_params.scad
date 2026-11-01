/**
  * Module: Rear camber-link hardware settings.
  *
  * The rod ends and threaded shaft share the steering-link hardware dimensions.
  * Eye-center spacing follows the installed shaft body and both rod-end shanks.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>

rear_camber_link_spec = [
  "eye_od", knuckle_tie_rod_eye_od,
  "eye_h", knuckle_tie_rod_eye_h,
  "eye_flat_d", 0,
  "shank_od", knuckle_tie_rod_shank_od,
  "shank_bolt_d", knuckle_tie_rod_shank_bolt_d,
  "neck_len", knuckle_tie_rod_neck_len,
  "neck_h", knuckle_tie_rod_eye_h,
  "shank_len", knuckle_tie_rod_shank_len,
  "bushing_od", knuckle_tie_rod_bushing_od,
  "bushing_d", knuckle_tie_rod_bushing_d,
  "bushing_h", knuckle_tie_rod_bushing_h,
  "bushing_flat_d", knuckle_tie_rod_bushing_flat_d,
  "bushing_cap_h", knuckle_tie_rod_bushing_cap_h,
  "bushing_cap_d", knuckle_tie_rod_bushing_cap_d,
  "bushing_color", knuckle_tie_rod_bushing_color,
  "end_color", knuckle_tie_rod_color,
  "eye_bolt_head_d", knuckle_tie_rod_bushing_bolt_head_d,
  "eye_bolt_color", knuckle_tie_rod_bushing_bolt_color,
  "eye_bolt_h", knuckle_tie_rod_bushing_h,
  "eye_bolt_through_h", 0,
  "center_link_len", knuckle_tie_rod_link_len,
  "center_link_end_len", knuckle_tie_rod_link_end_len,
  "center_link_od", knuckle_tie_rod_link_od,
  "center_link_thread_l", knuckle_tie_rod_link_thread_l,
  "center_link_thread_d", knuckle_tie_rod_link_thread_d,
  "center_link_color", knuckle_tie_rod_link_color,
  "shaft_nut_h", m3_nut_h,
  "show_shaft_nuts", true,
  "shaft_fn", 6,
  "end_fn", 100,
  "show_shaft_text", false,
  "shaft_extra_text", "",
  "shaft_text_color", pink_1
];
