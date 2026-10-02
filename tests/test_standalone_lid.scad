/**
  * Module: Standalone lid placement and mounting contracts.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/lipo_pack_case/standalone_parameters.scad>
use <../scad/lib/plist.scad>
use <../scad/lipo_pack_case/lid_equipment.scad>
use <../scad/lipo_pack_case/lid_fuse.scad>
use <../scad/lipo_pack_case/multi_lipo_pack_lid.scad>
use <../scad/components/button_bracket/button_bracket.scad>
use <../scad/wago/wago_pair.scad>
use <../scad/suspension/rear_chassis/computed_params.scad>
use <../scad/suspension/rear_chassis/rear_payload.scad>

assert(standalone_lipo_case == multi_lipo_packs_case);
assert(standalone_lid_equipment == plist_get("equipment", plist_get("lid", multi_lipo_packs_case)));
lid = multi_lipo_pack_lid_props(standalone_lipo_case);
spec = plist_get("lid", standalone_lipo_case);
mounts = lid_equipment_layout(plist_get("equipment", spec), lid);
assert(len(mounts) == 2);
assert(plist_get("pos", mounts[0])[0] > 0);
assert(plist_get("pos", mounts[1])[0] < 0);
assert(plist_get("kind", mounts[1]) == "wago_pair");
assert(plist_get("canonical_size", lid)
       == plist_get("canonical_size", multi_lipo_pack_lid_props(multi_lipo_packs_case)));
assert(plist_get("adapter_gap", lid) == 0);
assert(plist_get("bolt_l", plist_get("adapter_props", lid)) == 8);
assert(plist_get("lidar_offset", lid) == [0, 0]);
fuse = lid_fuse_validate(lid_fuse_props(plist_get("fuse", spec), lid), lid, mounts);
assert(plist_get("enabled", fuse));
assert(len(plist_get("slots", fuse)) == 4);
echo("PASS: standalone equipment fits the unchanged roof with centered flush adapter");

// Swapping sides changes component placement without moving mechanical datums.
swapped = [plist_merge(standalone_lid_equipment[0],
                       ["placement", "right", "rotation", 180]),
           plist_merge(standalone_lid_equipment[1],
                       ["placement", "left", "rotation", 0])];
mirrored = lid_equipment_layout(swapped, lid);
assert(len(mirrored) == 2);
assert(plist_get("pos", mirrored[0])[0] < 0);
assert(plist_get("pos", mirrored[1])[0] > 0);
fixed = lid_equipment_layout([for (m = mounts)
  plist_merge(m, ["pos", _lid_rotate(plist_get("pos", m),
                                     -plist_get("power_rotation", lid, 0)),
                  "rotation", plist_get("rotation", m)
                              - plist_get("power_rotation", lid, 0),
                  "count", 1])], lid);
assert([for (m = fixed) plist_get("pos", m)] == [for (m = mounts) plist_get("pos", m)]);
echo("PASS: swapped sides and explicit XY placements use shared geometry");

// With no lidar, fill more of the available roof with meters.
plain = plist_merge(standalone_lipo_case,
  ["lid", plist_merge(spec, ["lidar", undef, "fuse", undef])]);
plain_props = multi_lipo_pack_lid_props(plain);
meter_specs = plist_get("meter", multi_lipo_lid_equipment_presets);
meter_mounts = lid_equipment_layout(meter_specs, lid);
assert(len(meter_mounts) == 3);
more = lid_equipment_layout(meter_specs, plain_props);
assert(len(more) > len(meter_mounts));
assert(!plist_get("enabled", plist_get("adapter_props", plain_props)));
assert(len(lid_equipment_layout([["kind", "wago", "enabled", false]], lid)) == 0);
echo("PASS: optional lidar, disabled equipment and fill-to-fit meters");

for (edge = ["left", "right", "front", "rear"]) {
  edge_mount = lid_equipment_layout(
    [["kind", "voltmeter", "component", voltmeter_default_spec,
      "placement", edge]], plain_props);
  assert(len(edge_mount) == 1);
}
changed_wago = lid_equipment_layout(
  [["kind", "wago", "rotation", 90,
    "component", ["wago", ["n", 3, "total_w", 22.7]]]], plain_props);
assert(len(changed_wago) == 1);
echo("PASS: all four named edges respect tool access and changed Wago dimensions");

// Advancing the switch preserves its exact roof wire position and opening.
button_mount = mounts[0];
button_props = plist_get("props", button_mount);
baseline_specs = [plist_merge(standalone_lid_equipment[0],
                              ["advance_to_rail", false]),
                  standalone_lid_equipment[1]];
baseline = lid_equipment_layout(baseline_specs, lid)[0];
assert(plist_get("advance", button_mount) > 6);
assert(norm(plist_get("pos", button_mount)
            + _lid_rotate(plist_get("wire_pos", button_props), 0)
            - plist_get("pos", baseline)
            - plist_get("wire_pos", plist_get("props", baseline))) < 0.000001);
assert(plist_get("wire_size", button_props)
       == plist_get("wire_size", plist_get("props", baseline)));
assert(_lid_cut_access(_lid_equipment_cuts(button_mount),
                       plist_get("pos", button_mount), lid));
assert(abs(plist_get("headroom", lid) - 11) < 0.000001);
assert(abs(plist_get("free_h", fuse) - plist_get("size", fuse)[2]
           - plist_get("clearance", fuse)) < 0.000001);
assert(plist_get("tie_recess", fuse) >= plist_get("tie_size", fuse)[1] + 0.4);
assert(plist_get("t", lid) - plist_get("tie_recess", fuse) >= 1.2);
for (clearance = [0.8, 1, 2]) {
  changed_spec = plist_merge(spec, ["fuse", plist_merge(plist_get("fuse", spec),
                                                        ["clearance", clearance])]);
  changed = multi_lipo_pack_lid_props(plist_merge(standalone_lipo_case,
                                                   ["lid", changed_spec]));
  assert(abs(plist_get("headroom", changed) - max(10 + clearance, 10.9)) < 0.000001);
}
meters = lid_voltmeter_layout(plist_get("voltmeters", spec), lid);
assert(len(meters) == 2);
assert(plist_get("pos", meters[0])[0] == -plist_get("pos", meters[1])[0]);
assert(plist_get("pos", meters[0])[1] == plist_get("pos", meters[1])[1]);
assert(lid_voltmeter_layout([], lid) == []);
assert(lid_voltmeter_layout([["enabled", false]], lid) == []);
meter = meters[0];
assert(norm(plist_get("pos", meter) - [30, 10.7]) < 0.000001);
assert(plist_get("enabled", meter));
assert(plist_get("standoff_h", plist_get("props", meter))
       - plist_get("pin_h", plist_get("props", meter))
       >= plist_get("canonical_size", lid)[1] / 2 - plist_get("outer", meter) + 0.5);
changed_holder = plist_merge(atm_fuse_default_plist,
  ["body", plist_merge(plist_get("body", atm_fuse_default_plist),
                       ["size", [28.5, 14.2, 15.07, 28.9]])]);
changed_lid = multi_lipo_pack_lid_props(plist_merge(standalone_lipo_case,
  ["lid", plist_merge(spec,
    ["fuse", plist_merge(plist_get("fuse", spec), ["holder", changed_holder])])]));
assert(abs(plist_get("headroom", changed_lid) - plist_get("headroom", lid) - 2) < 0.000001);
assert(!plist_get("enabled", lid_voltmeter_props(undef, lid)));
echo("PASS: switch travel retains wire opening, automatic fuse clearance and side meter fit");

// Pair spacing and opening dimensions follow the selected connector and ears.
pair = plist_get("props", mounts[1]);
assert(norm(plist_get("wire_size", pair) - [16.7, 19]) < 0.000001);
assert(len(plist_get("mount_holes", pair)) == 4);
wide_pair = wago_pair_props(["spacing", 4]);
assert(plist_get("wire_size", wide_pair)[1] == plist_get("wire_size", pair)[1] + 2);
small_pair = wago_pair_props(["bracket", ["wago", ["n", 3, "total_w", 22.7]]]);
assert(plist_get("wire_size", small_pair)[0] < plist_get("wire_size", pair)[0]);
assert(plist_get("wire_r", small_pair) <= min(plist_get("wire_size", small_pair)) / 2);
assert(_lid_roof_contains(plist_get("roof_bounds", mounts[1]),
                         plist_get("canonical_size", lid), plist_get("corner_r", lid)));
assert(!_lid_roof_contains(plist_get("bounds", mounts[1]),
                          plist_get("canonical_size", lid), plist_get("corner_r", lid)));
echo("PASS: opposing Wagos reserve supported lands and derive their shared opening from hardware");

// Raising case rails above the battery must not shrink the meter mounting lands.
for (top_clearance = [0, 2, 5]) {
  raised = multi_lipo_pack_lid_props(plist_merge(standalone_lipo_case,
                                                ["top_clearance", top_clearance]));
  assert(abs(plist_get("headroom", raised)
             - max(11 - top_clearance, 10.9)) < 0.000001);
  assert(len(lid_voltmeter_layout(plist_get("voltmeters", spec), raised)) == 2);
}
explicit_meter = ["component", voltmeter_default_spec,
                  "edge_pad", 1.25, "pos", [30, 12]];
explicit_lid = multi_lipo_pack_lid_props(plist_merge(standalone_lipo_case,
  ["lid", plist_merge(spec, ["voltmeters", [explicit_meter]])]));
assert(len(lid_voltmeter_layout([explicit_meter], explicit_lid)) == 1);
assert(lid_voltmeter_headroom([], plist_get("rail_props", lid), 2, 3) == 2);
assert(lid_voltmeter_headroom([["enabled", false]],
                              plist_get("rail_props", lid), 2, 3) == 2);
echo("PASS: automatic height fits side meters with raised case rails and explicit mounting heights");

// Rear mounting must inherit the selected enclosure, including custom lid settings.
for (shared = [standalone_lipo_case,
                plist_merge(standalone_lipo_case,
                  ["top_clearance", 3,
                   "lid", plist_merge(spec, ["t", 4, "headroom", 14,
                                              "lidar_target_h", 21])])]) {
  payload = plist_get("power_case", rear_chassis_layout(power_case=shared, equipment=[]));
  mounted = plist_get("plist", payload);
  rear = rear_power_lid_plist(mounted, plist_get("lidar", payload));
  assert(plist_get("top_clearance", mounted, 0) == plist_get("top_clearance", shared, 0));
  assert(plist_get("lid", rear) == plist_get("lid", shared));
  a = multi_lipo_pack_lid_props(shared);
  b = multi_lipo_pack_lid_props(rear);
  for (key = ["canonical_size", "roof_z", "headroom", "lidar_base_z", "adapter_props"]) {
    assert(plist_get(key, a) == plist_get(key, b));
  }
}
no_sensor_case = plist_merge(standalone_lipo_case,
  ["lid", plist_merge(spec, ["lidar", undef])]);
assert(is_undef(plist_get("lidar", plist_get("power_case",
  rear_chassis_layout(power_case=no_sensor_case, equipment=[])))));
assert(is_undef(plist_get("lidar", plist_get("power_case",
  rear_chassis_layout(lidar_plist=undef, equipment=[])))));
echo("PASS: rear mounting preserves shared enclosure and lidar settings, including custom cases");
