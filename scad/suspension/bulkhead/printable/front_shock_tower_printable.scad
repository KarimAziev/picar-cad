/**
  * Module: Printable front shock tower
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../../colors.scad>

use <../front_shock_tower.scad>

module front_shock_tower_printable(color=cobalt_blue_metallic) {
  front_shock_tower(debug=false, color=color);
}

front_shock_tower_printable();