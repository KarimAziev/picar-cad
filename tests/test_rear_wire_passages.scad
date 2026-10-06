/**
  * Module: Rear fuse wire passage sizing and fixed chassis contracts.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/suspension/rear_chassis/computed_params.scad>

use <../scad/suspension/rear_chassis/rear_power_wiring.scad>
use <../scad/suspension/front_chassis/front_chassis_joint.scad>

layout      = rear_chassis_layout();
config      = plist_merge(rear_power_wiring, ["enabled", true, "fuse_outlet", false]);
assert(!plist_get("enabled", rear_power_wiring_props(layout)));
wiring      = rear_power_wiring_props(layout, config);
// Check outlet sizing on an obstacle-free deck footprint.
passages    = rear_fuse_wire_passages(
  layout, plist_get("panels", layout)[0], plist_get("holes", wiring),
  plist_get("hole_d", wiring), [], plist_put("fuse_outlet", true, config));
holes       = plist_get("holes", passages);
assert(norm(plist_get("size", layout) - [160.4, 153.49, 6]) < 1e-6);
assert(len(holes) == 4);
assert(plist_get("hole_d", wiring) == 12);
assert(norm(holes[0] - [-46.0254, -72.94, 0]) < 0.0001);
assert(norm(holes[3] - [-61.0254, -57.94, 0]) < 0.0001);
assert(abs(norm(holes[1] - holes[0]) - 15) < 1e-6);
assert(abs(norm(holes[2] - holes[0]) - 15) < 1e-6);
assert(norm(plist_get("outlet_size", passages) - [58.65, 7.5, 0]) < 0.0001);
assert(plist_get("outlet_r", passages) == 3);
outlet_pos  = plist_get("outlet_pos", passages);
outlet_size = plist_get("outlet_size", passages);
assert(abs(plist_get("join_w", layout) / 2
           - abs(outlet_pos[0]) - outlet_size[0] / 2 - 12) < 1e-6);
assert(abs(abs(outlet_pos[0]) - outlet_size[0] / 2
           - front_chassis_body_joint_pin_spacing(plist_get("join_w", layout)) / 2
           - front_chassis_joint_pin_d / 2 - 2) < 1e-6);

panel       = plist_get("panels", layout)[0];
assert(plist_get("outlet_pos", passages)[1] < plist_get("bounds", panel)[0][1]);
assert(holes[0][1] > plist_get("bounds", panel)[1][1]);
assert(norm(plist_get("bolt_spacing", panel) - [39.2, 41.7, 0]) < 1e-6);
mounts      = plist_get("mount_holes", plist_get("power_case", layout));
assert(norm(mounts[0] - [-69.2254, -132.49]) < 0.0001);
assert(norm(mounts[3] - [69.2254, -97.89]) < 0.0001);

disabled    = rear_power_wiring_props(layout,
                                   plist_merge(config, ["fuse_hole_columns", 0,
                                                                   "fuse_outlet", false]));
assert(plist_get("holes", disabled) == plist_get("holes", wiring));
assert(plist_get("converter_path", disabled) == plist_get("converter_path", wiring));
assert(plist_get("holes", plist_get("fuse_passages", disabled)) == []);
assert(plist_get("outlet_size", plist_get("fuse_passages", disabled)) == [0, 0, 0]);

// An occupied outer column retains the inner pair of wire passages.
obstacle    = [holes[2] - [6, 6, 0], holes[3] + [6, 6, 0]];
limited     = rear_fuse_wire_passages(layout,
                                  panel,
                                  plist_get("holes", wiring),
                                  plist_get("hole_d", wiring),
                                  [obstacle]);
assert(plist_get("holes", limited) == [holes[0], holes[1]]);
echo("PASS four 12 mm passages, two-hole fallback, rounded outlet and fixed mount datums");
