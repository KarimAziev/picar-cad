/**
  * Module: Fixed-deck equipment layout assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/suspension/rear_chassis/computed_params.scad>

use <../scad/components/deck_component.scad>
use <../scad/suspension/rear_chassis/rear_equipment.scad>

base = rear_chassis_layout(equipment=[]);
function overlap(a, b, gap=0) =
  a[0][0] < b[1][0] + gap - 0.00001
  && a[1][0] > b[0][0] - gap + 0.00001
  && a[0][1] < b[1][1] + gap - 0.00001
  && a[1][1] > b[0][1] - gap + 0.00001;

for (specs = [rear_equipment_mixed, rear_equipment_meters,
              [["kind", "voltmeter",
                "zone", "left",
                "rotation", 37],
               ["kind", "voltmeter",
                "zone", "right",
                "rotation", 270]],
              [["kind", "step_down",
                "zone", "left",
                "position", [0.5, 1]]],
              [["kind", "perf_board",
                "zone", "auto",
                "count", 2]], []]) {
  layout = rear_chassis_layout(equipment=specs);
  for (key = ["size", "bounds",
              "min_y", "max_y",
              "transition_y_end", "power_case"]) {
    assert(plist_get(key, layout) == plist_get(key, base),
           str("Equipment changed the fixed chassis/payload: ", key));
  }
  parts = plist_get("equipment", layout);
  assert(len(parts) == sum([for (s = specs) plist_get("count", s, 1)]));
  for (i = [0:1:len(parts) - 1]) {
    p = parts[i];
    b = plist_get("bounds", p);
    zone = [for (z = plist_get("equipment_zones", layout))
        if (plist_get("name", z) == plist_get("zone", p))
          plist_get("bounds", z)][0];
    for (axis = [0, 1]) {
      assert(b[0][axis] >= zone[0][axis] - 0.00001);
      assert(b[1][axis] <= zone[1][axis] + 0.00001);
    }
    for (obstacle = rear_equipment_obstacles(base)) {
      assert(!overlap(b, obstacle, rear_equipment_gap));
    }
    for (j = [0:1:i - 1]) {
      assert(!overlap(b, plist_get("bounds", parts[j]), rear_equipment_gap));
    }
  }
 }
// Hardware modifications flow into the layout; taller populated boards reserve Z.
custom = deck_component_props("perf_board",
                              plist_merge(perfboard_default_plist,
                                ["size", [30, 50, 1.6],
                                 "bolt_spacing", [26, 46],
                                 "rows", 16,
                                 "cols", 10,
                                 "component_h", 12]));
assert(plist_get("size", custom)[0] == 30);
assert(plist_get("size", custom)[1] == 50);
assert(plist_get("size", custom)[2] > 18);
// No battery and no panels are valid, independently of the shared preset.
plain = rear_chassis_layout(power_case=undef, panels=[], equipment=[]);
assert(len(rear_equipment_layout([["kind", "voltmeter"]], plain)) == 1);
echo("PASS: rear equipment counts, rotations, placement, obstacles and fixed dimensions");
