/**
  * Module: Gearmotor base, encoder bracket, magnet sleeve and two bosses.
  * All five separate parts sit on Z=0 without hardware placeholders.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../../lib/plist.scad>
use <driveshaft_magnet_sleeve.scad>
use <gearbox_boss.scad>
use <gearbox_bracket.scad>
use <gearmotor_encoder_bracket.scad>
use <util.scad>

p             = gearmotor_bracket_compute_params();
encoder_mount = plist_get("encoder_mount", p);
gap           = 5;
base_right    = plist_get("bounds", p)[1][0];
encoder_w     = is_undef(encoder_mount) ? 0 : plist_get("size", encoder_mount)[0];
sleeve        = is_undef(encoder_mount) ? undef : plist_get("sleeve",
                                                            encoder_mount);
sleeve_d      = is_undef(sleeve) ? 0 : plist_get("size", sleeve)[0];
boss_d        = plist_get("boss_od", p);

gearmotor_bracket(params=p,
                  anchor=[0, 0, 1],
                  show_gearbox=false,
                  show_motor=false,
                  show_bearing=false,
                  show_drive_shaft=false,
                  show_mount_bolts=false,
                  show_nuts=false,
                  show_shaft_seeve=false,
                  show_extra_drive_shaft=false,
                  show_encoder_bracket=false,
                  show_encoder=false,
                  show_encoder_magnet=false,
                  show_encoder_sleeve=false,
                  show_gearbox_bosses=false);
if (!is_undef(encoder_mount)) {
  translate([base_right + gap + encoder_w / 2, 0, 0]) {
    gearmotor_encoder_bracket(encoder_mount, anchor=[0, 0, 1]);
  }
  translate([base_right + 2 * gap + encoder_w + sleeve_d / 2, 0, 0]) {
    driveshaft_magnet_sleeve(params=sleeve);
  }
}
for (i = [0:1]) {
  translate([base_right + encoder_w + sleeve_d + 3 * gap + boss_d / 2
             + i * (boss_d + gap),
             0,
             0]) {
    gearbox_boss(type=i == 0 ? "front" : "rear", params=p, anchor=[0, 0, 1]);
  }
}
