include <../scad/parameters.scad>
use <../scad/lib/plist.scad>
use <../scad/placeholders/rc_driveshaft.scad>

module near(actual, expected) {
  assert(abs(actual - expected) < 0.000001, str(actual, " != ", expected));
}

near(rc_driveshaft_min_l(), 43.4);
near(rc_driveshaft_max_l(), 67.8);
near(plist_get("pivot_l", rc_driveshaft_plist) - rc_driveshaft_min_l(), 16.6);
near(rc_driveshaft_rod_l() - plist_get("rod_max_exposed_l", rc_driveshaft_plist), 6.4);
near(rc_driveshaft_hub_l(), 7.33);
near(plist_get("socket_l", rc_driveshaft_plist)
     - plist_get("socket_pivot_l", rc_driveshaft_plist), 2);
near(plist_get("tube_total_l", rc_driveshaft_plist)
     - plist_get("tube_pivot_l", rc_driveshaft_plist), 2.4);
near(plist_get("rod_yoke_l", rc_driveshaft_plist)
     - plist_get("rod_yoke_pivot_l", rc_driveshaft_plist), 2.8);
near(plist_get("dogbone_outer_l", rc_driveshaft_plist), 12.5);

// Each datum changes only the geometric relationship that consumes it.
near(rc_driveshaft_min_l(plist_put("tube_pivot_l", 36.6, rc_driveshaft_plist)), 44.4);
near(rc_driveshaft_max_l(plist_put("rod_max_exposed_l", 20, rc_driveshaft_plist)), 63.4);
near(rc_driveshaft_rod_l(plist_put("tube_l", 32, rc_driveshaft_plist)), 32);
near(rc_driveshaft_rod_l(plist_put("rod_l", 29, rc_driveshaft_plist)), 29);
near(rc_driveshaft_min_l(plist_put("socket_pivot_l", 13, rc_driveshaft_plist)), 43.4);
echo("PASS: measured shaft datums, derived travel and provisional hidden rod length");
