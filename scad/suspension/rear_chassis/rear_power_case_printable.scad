/**
  * Module: Rear battery case with its layout-generated mounting pattern.
  */
include <computed_params.scad>

use <../../lib/plist.scad>
use <../../lipo_pack_case/multi_lipo_pack_case.scad>

payload = plist_get("power_case", rear_chassis_layout());

if (!is_undef(payload)) {
  multi_lipo_pack_case(plist_get("plist", payload),
                       anchor=[0, 0, 1],
                       target_h=0,
                       show_rail_bolts=false,
                       show_rail_nuts=false,
                       show_standoffs=false,
                       show_packs=false);
 }
