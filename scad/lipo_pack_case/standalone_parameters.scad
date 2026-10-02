/**
  * Module: Standalone power-case equipment preset.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../rc_params.scad>

use <../lib/plist.scad>

// Keep the example entry points on the same configuration as the main case.
standalone_lipo_case     = multi_lipo_packs_case;
standalone_lid_equipment = plist_get("equipment",
                                     plist_get("lid", multi_lipo_packs_case));
