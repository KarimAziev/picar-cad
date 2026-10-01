/**
  * Module: Sensor adapter matching the rear payload's sliding lid.
  */
include <../rear_suspension/computed_params.scad>

use <../../lib/plist.scad>
use <../../lipo_pack_case/multi_lipo_pack_adapter.scad>
use <../../lipo_pack_case/multi_lipo_pack_lid.scad>
use <rear_payload.scad>

module rear_power_lidar_adapter_printable() {
  payload = plist_get("power_case", rear_suspension_layout());
  if (!is_undef(payload) && plist_get("lid_size", payload)[2] > 0) {
    props = multi_lipo_pack_lid_props(rear_power_lid_plist(plist_get("plist", payload),
                                                           plist_get("lidar", payload)));
    adapter_props = plist_get("adapter_props", props);
    multi_lipo_pack_adapter_printable(adapter_props);
  }
}

rear_power_lidar_adapter_printable();