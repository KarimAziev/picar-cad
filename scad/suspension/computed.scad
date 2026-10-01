include <../steering_params.scad>
include <front_chassis/computed_params.scad>

use <rear_chassis/computed_params.scad>
use <../lib/plist.scad>
use <../lipo_pack_case/multi_lipo_pack_case.scad>

lipo_pack_case_plist       = multi_lipo_pack_props(plist=multi_lipo_packs_case);
lipo_pack_case_size        = plist_get("size", lipo_pack_case_plist);
lipo_pack_case_w           = lipo_pack_case_size[0];
front_middle_chassis_max_w = max(front_chassis_rear_frame_w, lipo_pack_case_w);

/**
  ─────────────────────────────────────────────────────────────────────────────
  suspension_chassis_width
  ─────────────────────────────────────────────────────────────────────────────
  Return the widest required body width for the configured vehicle sections.
  **Parameters:**
  - `include_middle`: Include the middle payload's width only when present.
  - `middle_case`: Battery specification used by the optional middle section.
  - `rear_layout`: Resolved rear component layout; its join width is a candidate.
  - `front_width`: Minimum required by the front hardware and configured floor.
  Pass the result to each frame when composing a custom vehicle configuration.
 */
function suspension_chassis_width(include_middle=false,
                                    middle_case=multi_lipo_packs_case,
                                    rear_layout=rear_chassis_layout(),
                                    front_width=front_chassis_required_width()) =
  max(front_width, plist_get("join_w", rear_layout),
      include_middle ? plist_get("size", multi_lipo_pack_props(middle_case))[0] : 0);
