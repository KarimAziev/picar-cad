/**
  * Module: Rear power swap, fixed lid hardware and terminal clearance contracts.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/suspension/rear_chassis/computed_params.scad>

use <../scad/lib/functions.scad>
use <../scad/lipo_pack_case/lid_equipment.scad>
use <../scad/lipo_pack_case/lid_wiring.scad>
use <../scad/lipo_pack_case/multi_lipo_pack_lid.scad>
use <../scad/placeholders/crimp_terminals/ring_terminal.scad>
use <../scad/suspension/rear_chassis/rear_power_wiring.scad>

layout        = rear_chassis_layout();
payload       = plist_get("power_case", layout);
pl            = plist_get("plist", payload);
original      = plist_put("power_rotation", 0, pl);
lid           = multi_lipo_pack_lid_props(pl);
old_lid       = multi_lipo_pack_lid_props(original);
spec          = plist_get("lid", pl);
assert(norm(plist_get("size", layout) - [159.81, 153.49, 6]) < 1e-5);
assert(plist_get("power_rotation", pl) == 180);
for (key = ["lidar_offset", "lidar_orientation",
            "lidar_base_z", "canonical_size"]) {
  assert(plist_get(key, lid) == plist_get(key, old_lid));
}
assert(lid_voltmeter_layout(plist_get("voltmeters", spec), lid)
       == lid_voltmeter_layout(plist_get("voltmeters", spec), old_lid));
old_equipment = lid_equipment_layout(plist_get("equipment", spec), old_lid);
equipment     = lid_equipment_layout(plist_get("equipment", spec), lid);
for (i = [0:len(equipment) - 1]) {
  assert(norm(plist_get("pos", equipment[i]) + plist_get("pos", old_equipment[i])) < 1e-6);
}
// The switch faces +Y, toward the side meters, with its wire slot behind it.
button        = equipment[0];
assert(norm(rotZ([0, 1, 0], plist_get("rotation", button)) - [0, 1, 0]) < 1e-6);
assert(plist_get("pos", button)[1] > 0);
wire_slot     = concat(plist_get("pos", button), [0])
                 + rotZ(concat(plist_get("wire_pos", plist_get("props", button)), [0]),
                   plist_get("rotation", button));
assert(wire_slot[1] < 0);
old_routes    = plist_get("routes", lid_wiring_props(original));
routes        = plist_get("routes", lid_wiring_props(pl));
for (i = [0:len(routes) - 1]) {
  path = plist_get("path", routes[i]);
  before = plist_get("path", old_routes[i]);
  for (j = [0:len(path) - 1]) {
    assert(norm(path[j] - rotZ(before[j], 180)) < 1e-6);
  }
}
p = rear_power_wiring_props(layout);
assert(plist_get("enabled", p));
assert(len(plist_get("feeds", p)) == 3);
assert(plist_get("hole_d", p) == 12);
assert(len(plist_get("holes", p)) == 4);
assert(len(plist_get("black_holes", p)) == 2);
assert(len(plist_get("holes", rear_power_wiring_props(layout,
                                                      plist_put("black_holes", false, rear_power_wiring)))) == 2);
ring = ring_terminal_props(plist_get("ring_terminal", p));
assert(plist_get("hole_d", p) > max(plist_get("od", ring), plist_get("max_w", ring)) + 4);
assert(abs(norm(plist_get("ring_bore", p) - plist_get("input_ports", p)[0])
           - plist_get("t", ring) / 2) < 1e-6);
assert(min([for (pt = plist_get("converter_path", p)) pt[2]]) == -8);
assert(!plist_get("enabled", rear_power_wiring_props(layout, ["enabled", false])));
assert(!plist_get("enabled", rear_power_wiring_props(plist_put("power_case", undef, layout))));
echo("PASS fixed chassis, unchanged lid meters/lidar, rotated power circuit and terminal-sized passages");
