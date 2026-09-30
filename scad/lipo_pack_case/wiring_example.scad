/**
  * Module: Standalone power harness with the roof hidden for inspection.
  *
  * Wire lengths are echoed in millimeters. Set show_roof=true for the closed
  * case, or use standalone_assembly.scad for the complete lidar assembly.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <standalone_parameters.scad>

use <multi_lipo_pack_case_assembly.scad>

show_roof = true;
multi_lipo_pack_case_assembly(standalone_lipo_case,
                              show_lid=show_roof,
                              show_lidar=false,
                              show_adapter=false,
                              report_wire_lengths=true);
