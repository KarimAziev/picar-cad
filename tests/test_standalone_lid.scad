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

assert(standalone_lipo_case == multi_lipo_packs_case);
assert(standalone_lid_equipment == plist_get("equipment", plist_get("lid", multi_lipo_packs_case)));
lid = multi_lipo_pack_lid_props(standalone_lipo_case);
spec = plist_get("lid", standalone_lipo_case);
mounts = lid_equipment_layout(plist_get("equipment", spec), lid);
assert(len(mounts) == 2);
assert(plist_get("pos", mounts[0])[0] < 0);
assert(plist_get("pos", mounts[1])[0] > 0);
assert(plist_get("kind", mounts[1]) == "wago_pair");
assert(plist_get("canonical_size", lid)
       == plist_get("canonical_size", multi_lipo_pack_lid_props(multi_lipo_packs_case)));
assert(plist_get("adapter_gap", lid) == 4);
assert(plist_get("bolt_l", plist_get("adapter_props", lid)) == 12);
assert(plist_get("lidar_offset", lid) == [0, 0]);
fuse = lid_fuse_validate(lid_fuse_props(plist_get("fuse", spec), lid), lid, mounts);
assert(plist_get("enabled", fuse));
assert(len(plist_get("slots", fuse)) == 4);
echo("PASS: standalone equipment fits the unchanged roof with centered raised adapter");

// Swapping sides changes component placement without moving mechanical datums.
swapped = [plist_merge(standalone_lid_equipment[0],
                       ["placement", "right", "rotation", 180]),
           plist_merge(standalone_lid_equipment[1],
                       ["placement", "left", "rotation", 0])];
mirrored = lid_equipment_layout(swapped, lid);
assert(len(mirrored) == 2);
assert(plist_get("pos", mirrored[0])[0] > 0);
assert(plist_get("pos", mirrored[1])[0] < 0);
fixed = lid_equipment_layout([for (m = mounts)
  plist_merge(m, ["pos", plist_get("pos", m), "count", 1])], lid);
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

// The terminal attachments move the bracket, while the existing roof slot stays put.
button_mount = mounts[0];
button_pl = plist_get("component", button_mount);
original_button_pl = plist_merge(button_pl, ["terminal_extension", 0]);
original_mounts = lid_equipment_layout(
  [for (i = [0:len(standalone_lid_equipment) - 1])
      i == 0 ? plist_merge(standalone_lid_equipment[i],
                            ["component", original_button_pl])
      : standalone_lid_equipment[i]], lid);
original_button = original_mounts[0];
button_props = plist_get("props", button_mount);
original_props = plist_get("props", original_button);
angle = plist_get("rotation", button_mount);
terminal_h = plist_get("terminal_size", plist_get("button", button_pl))[2];
assert(plist_get("terminal_extension", button_pl) == terminal_h);
assert(norm(plist_get("pos", button_mount) - plist_get("pos", original_button)
            - _lid_rotate([0, terminal_h], angle)) < 0.000001);
assert(norm(plist_get("pos", button_mount)
            + _lid_rotate(plist_get("wire_pos", button_props), angle)
            - plist_get("pos", original_button)
            - _lid_rotate(plist_get("wire_pos", original_props), angle)) < 0.000001);
assert(plist_get("wire_size", button_props) == plist_get("wire_size", original_props));
assert(plist_get("size", button_props) == plist_get("size", original_props));
echo("PASS: doubled terminal allowance shifts the button by one terminal length and preserves the roof wire slot");

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
