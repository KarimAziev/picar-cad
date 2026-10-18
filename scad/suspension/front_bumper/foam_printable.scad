/**
  * Module: TPU 95A front bumper with its bottom face on the print bed.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>

use <front_bumper_foam.scad>

bumper_pl = front_bumper_plist;
front_bumper_foam(bumper_pl);
