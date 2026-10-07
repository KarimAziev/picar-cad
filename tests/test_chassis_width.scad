include <../scad/suspension/computed.scad>

use <../scad/suspension/rear_chassis/computed_params.scad>

rear        = rear_chassis_layout();
width       = suspension_chassis_width();
assert(width == front_chassis_rear_frame_w);
assert(width == plist_get("join_w", rear));
assert(width >= front_chassis_required_width());
assert(width >= plist_get("join_w", rear_chassis_layout(min_width=0)));

assert(suspension_chassis_width(front_width=500) == 500);
assert(suspension_chassis_width(rear_layout=rear_chassis_layout(min_width=500)) == 500);
echo("PASS: front/rear common width and wider hardware requirements");

// Front hardware sets the width while the battery case overhangs its supports.
assert(abs(width - front_chassis_required_width()) < 0.000001);
assert(width < plist_get("size", plist_get("power_case", rear))[0]);
assert(abs(plist_get("size", rear)[1] - 153.49) < 0.000001);
assert(front_rpi_bounds[1][0] > width / 2);
assert(front_rpi_mount_bounds[1][0] < width / 2);

// Deck padding preserves suspension mounting datums and joint Y placement.
use <../scad/suspension/rear_suspension/util.scad>
for (pad = [1, 2.75, 4]) {
  changed = rear_chassis_layout(edge_pad=pad, equipment=[]);
  assert(rear_suspension_joint_y_bounds(changed)
         == rear_suspension_joint_y_bounds(rear));
  outline = rear_suspension_outline(changed);
  reference = rear_suspension_outline(rear);
  for (i = [0:7]) {
    assert(outline[i] == reference[i]);
  }
  for (key = ["suspension_w", "transition_y_start", "transition_y_end",
              "bulkhead_1_y", "bulkhead_2_y", "rect_y", "maintenance_y"]) {
    assert(plist_get(key, changed) == plist_get(key, rear), key);
  }
}
// Directly mounted hardware still receives the deck's own edge margin.
for (pad = [1, 4, 8]) {
  bare = rear_chassis_layout(min_width=0,
                             power_case=undef,
                             edge_pad=pad,
                             equipment=[]);
  panel = plist_get("panel_bounds", bare);
  assert(abs(plist_get("join_w", bare) / 2 - abs(panel[0][0]) - pad) < 0.000001);
}
echo("PASS: mounting-width chassis, connector overhang, independent deck padding and suspension joint");
