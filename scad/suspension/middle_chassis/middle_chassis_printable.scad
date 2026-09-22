/**
  * Module: Printable suspension middle chassis.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../steering_params.scad>

use <middle_chassis.scad>

module middle_chassis_printable() {
  middle_chassis(anchor=[0, 0, 1]);
}

middle_chassis_printable();
