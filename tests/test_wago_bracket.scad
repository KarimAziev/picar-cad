/**
  * Module: Wago bracket dimensions and mounting-layout assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/steering_params.scad>
use <../scad/lib/plist.scad>
use <../scad/placeholders/wago/wago_221.scad>
use <../scad/wago/wago_bracket.scad>
use <../scad/wago/wago_mounts.scad>
use <../scad/suspension/rear_suspension/computed_params.scad>
use <../scad/lipo_pack_case/multi_lipo_pack_lid.scad>

assert(wago_size() == [36.5,21.1,9.8]);
p = wago_bracket_props();
assert(norm(plist_get("size",p)-[40.2,34.8,13.25]) < 0.00001);
assert(norm(plist_get("size",wago_bracket_props(["mount_side","sides"]))-[60.2,24.8,13.25]) < 0.00001);
assert(plist_get("wago_size",wago_bracket_props(["wago",["n",3,"total_w",22.7]]))[0] == 22.7);
assert(norm(wago_mount_size(["rotation",90])-[34.8,40.2,13.25]) < 0.00001);

// A roomy payload must accept a bracket without changing its datums.
payload = ["bounds", [[-70,-60,0],[70,60,20]], "mount_z", 50,
           "mount_holes", [[-60,-50],[60,-50],[-60,50],[60,50]], "radius", 3];
u = wago_chassis_mounts([["placement","under","pos",[0,0]]],payload,[],6);
assert(plist_get("placement",u[0]) == "under");
assert(plist_get("pos",u[0]) == [0,0,6]);
low = plist_merge(payload,["mount_z",10]);
a = wago_chassis_mounts([[],[]],low,[],6);
assert(plist_get("placement",a[0]) == "after");
assert(plist_get("bounds",a[1])[1][1] <= plist_get("bounds",a[0])[0][1]);

// Adding mounts must preserve every existing mechanical placement.
base = rear_suspension_layout(wago_mounts=[]);
changed = rear_suspension_layout(wago_mounts=[["placement","after","rotation",90]]);
for (key=["motor_pos","motor_rotation","panels","power_case","bulkhead_1_y","bulkhead_2_y","maintenance_y"]) {
  assert(plist_get(key,base) == plist_get(key,changed), str("Moved existing datum: ",key));
}
assert(plist_get("min_y",changed) < plist_get("min_y",base));
assert(plist_get("max_y",changed) == plist_get("max_y",base));

lid = plist_merge(plist_get("lid",multi_lipo_packs_case),
                  ["wago_mounts",[["pos",[-54,0]],["pos",[54,0],"rotation",180]]]);
lpl = plist_merge(multi_lipo_packs_case,["lid",lid]);
lprops = multi_lipo_pack_lid_props(lpl);
assert(len(multi_lipo_pack_lid_wago_mounts(lpl,lprops)) == 2);
assert(plist_get("canonical_size",lprops) == plist_get("canonical_size",multi_lipo_pack_lid_props(multi_lipo_packs_case)));
echo("PASS Wago measured dimensions, rotations, fallback, lid fit and unchanged mounting datums");
