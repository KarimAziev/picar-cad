/**
  * Module: Lidar adapter, flat underside on the print bed and nut pockets facing up.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../rc_params.scad>

use <../lib/plist.scad>
use <multi_lipo_pack_adapter.scad>
use <multi_lipo_pack_lid.scad>

module multi_lipo_pack_lidar_adapter_printable() {
  props = multi_lipo_pack_lid_props(multi_lipo_packs_case);
  multi_lipo_pack_adapter_printable(plist_get("adapter_props", props));
}

multi_lipo_pack_lidar_adapter_printable();