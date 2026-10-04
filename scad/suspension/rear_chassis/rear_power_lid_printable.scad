/**
  * Module: Sliding rear payload lid, exterior roof face on the print bed.
  */
include <computed_params.scad>

use <../../lib/plist.scad>
use <../../lipo_pack_case/multi_lipo_pack_lid.scad>
use <rear_payload.scad>

payload = plist_get("power_case", rear_chassis_layout());
if (!is_undef(payload) && plist_get("lid_size", payload)[2] > 0) {
  multi_lipo_pack_lid_printable(rear_power_lid_plist(plist_get("plist", payload),
                                                     plist_get("lidar", payload)));
}
