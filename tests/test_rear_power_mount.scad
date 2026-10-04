/**
  * Module: Rear battery mounting-center invariants.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/suspension/rear_chassis/computed_params.scad>


reference        = plist_get("power_case", rear_chassis_layout(equipment=[]));
expected_spacing = [138.450853, 34.6];
assert(norm(plist_get("bolt_spacing", reference) - expected_spacing) < 0.000001);

for (bore_d = [6, 6.1, 7], bore_h = [1.95, 3.3], sink = [false, true]) {
  case_pl = plist_merge(rear_power_case_plist,
                        ["bore_d", bore_d,
                         "bore_h", bore_h,
                         "sink", sink]);
  payload = plist_get("power_case",
                      rear_chassis_layout(power_case=case_pl, equipment=[]));
  assert(plist_get("mount_holes", payload) == plist_get("mount_holes", reference),
         "Screw recess dimensions must preserve the fixed rear mounting centers");
  resolved = plist_get("plist", payload);
  props = multi_lipo_pack_props(resolved);
  assert(plist_get("bolt_spacing", props) == expected_spacing);
  assert(plist_get("bore_d", resolved) == bore_d);
  assert(plist_get("bore_h", resolved) == bore_h);
  assert(plist_get("sink", resolved) == sink);
}

// Explicit canonical centers follow the case orientation.
for (orientation = ["wlh", "lwh"]) {
  pl = plist_merge(multi_lipo_packs_case,
                   ["orientation", orientation,
                    "bolt_spacing", [120, 40]]);
  mount = rear_power_case_mount(pl, [[-20, -30, 0], [20, 30, 20]]);
  expected = orientation == "wlh" ? [120, 40] : [40, 120];
  assert(plist_get("bolt_spacing", mount) == expected);
  assert(plist_get("bolt_spacing", plist_get("plist", mount)) == [120, 40]);
}

echo("PASS: fixed rear battery mounting centers, recess settings and case orientation");
