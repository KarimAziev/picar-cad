include <../steering_params.scad>
include <front_chassis/computed_params.scad>

use <../lib/plist.scad>
use <../lipo_pack_case/multi_lipo_pack_case.scad>

lipo_pack_case_plist       = multi_lipo_pack_props(plist=multi_lipo_packs_case);
lipo_pack_case_size        = plist_get("size", lipo_pack_case_plist);
lipo_pack_case_w           = lipo_pack_case_size[0];
front_middle_chassis_max_w = max(front_chassis_rear_frame_w, lipo_pack_case_w);
