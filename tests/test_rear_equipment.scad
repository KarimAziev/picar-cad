/**
  * Module: Fixed-deck equipment layout assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/suspension/rear_chassis/computed_params.scad>

use <../scad/components/deck_component.scad>
use <../scad/suspension/rear_chassis/rear_equipment.scad>

function overlap(a, b, gap=0) =
  a[0][0] < b[1][0] + gap - 0.00001
  && a[1][0] > b[0][0] - gap + 0.00001
  && a[0][1] < b[1][1] + gap - 0.00001
  && a[1][1] > b[0][1] - gap + 0.00001;

module check_equipment(specs,
                       panels=rear_panel_specs,
                       power_case=rear_power_case_plist) {
  base = rear_chassis_layout(equipment=[],
                             panels=panels,
                             power_case=power_case);
  layout = rear_chassis_layout(equipment=specs,
                               panels=panels,
                               power_case=power_case);
  for (key = ["size", "bounds",
              "min_y", "max_y",
              "transition_y_end", "power_case"]) {
    assert(plist_get(key, layout) == plist_get(key, base),
           str("Equipment changed the fixed chassis/payload: ", key));
  }
  parts = plist_get("equipment", layout);
  expanded = [for (s = specs) each repeat(s, plist_get("count", s, 1))];
  assert(len(parts) == len(expanded));
  for (i = [0:1:len(parts) - 1]) {
    p = parts[i];
    assert(plist_get("component", p) == plist_get("component", expanded[i]),
           "Equipment must retain the selected component preset");
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
check_equipment(rear_equipment_specs);

// Upright display labels contribute their rendered height to the envelope.
plain_meter = deck_component_props("voltmeter",
                                   plist_merge(voltmeter_default_spec, ["text", undef]));
plain_meter_h = plist_get("size", plain_meter)[2];
default_meter = deck_component_props("voltmeter", voltmeter_default_spec);
assert(abs(plist_get("size", default_meter)[2] - plain_meter_h - 0.1) < 0.000001);
for (override = [["text", ""], ["hide_display", true]]) {
  hidden_label = deck_component_props("voltmeter",
                                      plist_merge(voltmeter_default_spec, override));
  assert(plist_get("size", hidden_label)[2] == plain_meter_h);
}
for (translation_z = [0, 0.2]) {
  raised_meter = deck_component_props("voltmeter",
                                      plist_merge(voltmeter_default_spec,
                                                  ["text_props", plist_merge(plist_get("text_props", voltmeter_default_spec),
                                                                             ["height", 0.35,
                                                                              "translation", [0, 0, translation_z]])]));
  assert(abs(plist_get("size", raised_meter)[2] - plain_meter_h
             - 0.35 - 2 * translation_z) < 0.000001);
}

// Alternate electronics layouts use a deck without panels or a raised payload.
variants = [rear_equipment_mixed, rear_equipment_meters,
            [["kind", "voltmeter",
              "component", voltmeter_default_spec,
              "zone", "left",
              "rotation", 37,
              "count", 1,
              "position", undef],
             ["kind", "voltmeter",
              "component", voltmeter_default_spec,
              "zone", "right",
              "rotation", 270,
              "count", 1,
              "position", undef]],
            [["kind", "step_down",
              "component", step_down_voltage_plist,
              "zone", "left",
              "rotation", 0,
              "count", 1,
              "position", [0.5, 1]]],
            [["kind", "perf_board",
              "component", perfboard_default_plist,
              "zone", "auto",
              "rotation", 0,
              "position", undef,
              "count", 2]], []];

for (specs = variants) {
  check_equipment(specs, panels=[], power_case=undef);
}

// Hardware modifications flow into the layout; taller populated boards reserve Z.
custom = deck_component_props("perf_board",
                              plist_merge(perfboard_default_plist,
                                          ["size", [30, 50, 1.6],
                                           "bolt_spacing", [26, 46],
                                           "rows", 16,
                                           "cols", 10,
                                           "component_h", 12]));
assert(plist_get("board_size", custom) == [30, 50, 1.6]);
assert(plist_get("size", custom)[0] >= 30);
assert(plist_get("size", custom)[1] >= 50);
assert(plist_get("size", custom)[2] > 18);
// No battery and no panels are valid, independently of the shared preset.
plain = rear_chassis_layout(power_case=undef, panels=[], equipment=[]);
single_meter = ["kind", "voltmeter",
                "component", voltmeter_default_spec,
                "zone", "auto",
                "rotation", 0,
                "position", undef,
                "count", 1];
assert(len(rear_equipment_layout([single_meter], plain)) == 1);
echo("PASS: rear equipment counts, rotations, placement, obstacles and fixed dimensions");
