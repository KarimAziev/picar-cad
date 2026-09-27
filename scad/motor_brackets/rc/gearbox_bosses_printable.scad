/**
  * Module: Front and rear gearbox supports, socket ends on the print bed.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../../lib/plist.scad>
use <gearbox_boss.scad>
use <util.scad>

p = gearmotor_bracket_compute_params();
for (i = [0:1]) {
  translate([i * (plist_get("boss_od", p) + 5), 0, 0]) {
    gearbox_boss(type=i == 0 ? "front" : "rear", params=p, anchor=[0, 0, 1]);
  }
 }
