include <../rc_params.scad>
include <front_chassis/computed_params.scad>

use <../lib/plist.scad>
use <rear_chassis/computed_params.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  suspension_chassis_width
  ─────────────────────────────────────────────────────────────────────────────
  Return the widest required body width for the configured vehicle sections.
  **Parameters:**
  - `rear_layout`: Resolved rear component layout; its join width is a candidate.
  - `front_width`: Minimum required by the front hardware and configured floor.
  Pass the result to each frame when composing a custom vehicle configuration.
 */
function suspension_chassis_width(rear_layout=rear_chassis_layout(),
                                  front_width=front_chassis_required_width()) =
  max(front_width, plist_get("join_w", rear_layout));
