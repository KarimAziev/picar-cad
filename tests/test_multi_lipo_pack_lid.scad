include <../scad/steering_params.scad>
use <../scad/lib/functions.scad>
use <../scad/lib/plist.scad>
use <../scad/lipo_pack_case/multi_lipo_pack_case.scad>
use <../scad/lipo_pack_case/multi_lipo_pack_lid.scad>
use <../scad/lipo_pack_case/multi_lipo_pack_rail.scad>
use <../scad/suspension/rear_suspension/computed_params.scad>

props = multi_lipo_pack_props(multi_lipo_packs_case);
rails = plist_get("rail_props", props);
lid = multi_lipo_pack_lid_props(multi_lipo_packs_case);
assert(plist_get("axis", rails) == "x");
assert(plist_get("z", rails) == plist_get("wall_size", props)[2]);
assert(plist_get("body_size", props)[2] == plist_get("z", rails) + plist_get("h", rails));
assert(plist_get("mount_z", lid) == plist_get("z", rails));
assert(plist_get("canonical_size", lid)[1] >= plist_get("size", rplidar_c1_plist)[1] + 4);
assert(plist_get("roof_z", lid) > plist_get("h", rails) + plist_get("clearance", rails));
for (rail = plist_get("rails", rails)) {
  wall = plist_get(plist_get("wall", rail), plist_get("wall_props", props));
  assert(plist_get("start", rail) >= plist_get("offset", wall));
  assert(plist_get("start", rail) + plist_get("l", rail)
         <= plist_get("offset", wall) + plist_get("l", wall));
  assert(len(plist_get("bolts", rail)) == 2);
}

plain = plist_merge(multi_lipo_packs_case, ["rail", ["enabled", false]]);
plain_props = multi_lipo_pack_props(plain);
assert(plist_get("body_size", plain_props) == plist_get("wall_size", props));
assert(plist_get("pack_positions", plain_props) == plist_get("pack_positions", props));
assert(plist_get("bolt_spacing", plain_props) == plist_get("bolt_spacing", props));

// Split rails follow cutouts, including overlapping and unordered cutouts.
assert(_lipo_rail_segments([[0, 100]], [[70, 80], [20, 40], [30, 50]])
       == [[0, 20], [50, 70], [80, 100]]);
changed_walls = plist_merge(plist_get("walls", multi_lipo_packs_case),
  ["front", ["t", 3, "h", 20], "rear", ["t", 3, "h", 20],
   "left", ["t", 3, "h", 30, "cutouts", [["offset", "45%", "l", "10%", "h", 5]]],
   "right", ["t", 3, "h", 30]]);
changed = plist_merge(multi_lipo_packs_case, ["walls", changed_walls]);
changed_props = multi_lipo_pack_props(changed);
assert(plist_get("axis", plist_get("rail_props", changed_props)) == "y");
assert(len(plist_get("segments", plist_get("rails", plist_get("rail_props", changed_props))[0])) == 2);
for (orientation = ["wlh", "lwh", "whl", "lhw", "hlw", "hwl"]) {
  oriented = plist_merge(changed, ["orientation", orientation]);
  oriented_case = multi_lipo_pack_props(oriented);
  oriented_lid = multi_lipo_pack_lid_props(oriented);
  assert(plist_get("size", oriented_case) == orientation_size(orientation, plist_get("canonical_size", changed_props)));
  assert(plist_get("size", oriented_lid) == orientation_size(orientation, plist_get("canonical_size", oriented_lid)));
}
echo("PASS: rail selection, supported spans, shared lid references, disabled rails, and orientations");

// Legacy/custom cases without rails remain usable in the rear assembly.
rail_free_layout = rear_suspension_layout(power_case=plain);
assert(plist_get("lid_size", plist_get("power_case", rail_free_layout)) == [0, 0, 0]);
echo("PASS: disabling rails keeps the rear case and omits the sliding lid");
