include <../scad/suspension/computed.scad>

use <../scad/suspension/rear_chassis/computed_params.scad>

rear        = rear_chassis_layout();
width       = suspension_chassis_width();
assert(width == front_chassis_rear_frame_w);
assert(width == plist_get("join_w", rear));
assert(width >= front_chassis_required_width());
assert(width >= plist_get("join_w", rear_chassis_layout(min_width=0)));

// A larger middle payload contributes only when that section is present.
wide_middle = plist_merge(multi_lipo_packs_case,
                          ["mount_ear_d", 10,
                           "bolt_spacing", [400, 400]]);
assert(suspension_chassis_width(include_middle=false, middle_case=wide_middle) == width);
wide        = suspension_chassis_width(include_middle=true, middle_case=wide_middle);
assert(wide == 410);
assert(plist_get("join_w", rear_chassis_layout(min_width=wide)) == wide);
assert(suspension_chassis_width(front_width=500) == 500);
echo("PASS: front/rear common width, optional middle candidate, and wider front hardware");

// Default chassis matches the raised case without changing its length.
assert(abs(width - lipo_pack_case_w) < 0.000001);
assert(abs(plist_get("size", rear)[1] - 153.49) < 0.000001);
assert(front_rpi_bounds[1][0] > width / 2);
assert(front_rpi_mount_bounds[1][0] < width / 2);

// Deck padding is independent of the suspension mount and its mating joint.
use <../scad/suspension/rear_suspension/util.scad>
for (pad = [1, 2.75, 4]) {
  changed = rear_chassis_layout(edge_pad=pad, equipment=[]);
  assert(rear_suspension_outline(changed) == rear_suspension_outline(rear));
  for (key = ["suspension_w", "transition_y_start", "transition_y_end",
               "bulkhead_1_y", "bulkhead_2_y", "rect_y", "maintenance_y"]) {
    assert(plist_get(key, changed) == plist_get(key, rear), key);
  }
}
// Directly mounted hardware still receives the deck's own edge margin.
for (pad = [1, 4, 8]) {
  bare = rear_chassis_layout(min_width=0, power_case=undef,
                              edge_pad=pad, equipment=[]);
  panel = plist_get("panel_bounds", bare);
  assert(abs(plist_get("join_w", bare) / 2 - abs(panel[0][0]) - pad) < 0.000001);
}
echo("PASS: case-width chassis, connector overhang, independent deck padding and unchanged suspension joint");
