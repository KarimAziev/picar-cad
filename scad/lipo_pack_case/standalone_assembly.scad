/**
  * Module: Complete standalone LiPo case with concealed fuse and roof equipment.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <standalone_parameters.scad>

use <multi_lipo_pack_case_assembly.scad>

multi_lipo_pack_case_assembly(standalone_lipo_case);
