/**
  * Module: Battery lead lengths and standalone harness connection contracts.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/lipo_pack_case/standalone_parameters.scad>
use <../scad/lib/plist.scad>
use <../scad/lib/wire.scad>
use <../scad/placeholders/lipo_pack_wiring.scad>
use <../scad/placeholders/t_plug.scad>
use <../scad/lipo_pack_case/lid_wiring.scad>

pack = plist_get("lipo_packs", standalone_lipo_case)[0];
for (key = ["power_lead", "balance_lead"]) {
  lead = plist_get(key, pack);
  p = lipo_pack_top_wiring_props(pack, key);
  paths = plist_get("paths", p);
  for (i = [0:len(paths) - 1]) {
    assert(norm(paths[i][0] - lipo_pack_lead_exit(pack, lead, i)) < 0.000001);
    assert(abs(total_wire_length(paths[i]) - plist_get("l", lead)) < 0.001);
  }
}
assert(plist_get("l", plist_get("power_lead", pack)) == 80);
// Preserve the original measured default exit locations, not just two linked helpers.
assert(norm(lipo_pack_lead_exit(pack, plist_get("power_lead", pack), 0)
            - [-25.875, -75.53, 10.9]) < 0.000001);
assert(norm(lipo_pack_lead_exit(pack, plist_get("power_lead", pack), 1)
            - [-25.875, -75.53, 15.25]) < 0.000001);
echo("PASS fixed exits and measured 80 mm power / 40 mm balance lead lengths");

p = lid_wiring_props(standalone_lipo_case);
routes = plist_get("routes", p);
assert(len(routes) == 4);
assert(plist_get("color", routes[0]) == "#202020");
for (r = routes) {
  assert(plist_get("length", r) > 0);
  assert(plist_get("length", r) == total_wire_length(plist_get("path", r)));
}
plug = t_plug_mated_props();
assert([for (p = plist_get("female_ports", plug)) p[0]]
       == [for (p = plist_get("male_ports", plug)) p[0]]);
echo("PASS four harness legs, common connector polarity and sampled length reporting");

corner = rounded_wire_points([[0,0,0], [20,0,0], [20,20,0]], trim=6);
assert(corner[0] == [0,0,0] && corner[len(corner) - 1] == [20,20,0]);
assert(min([for (p = corner) p[0]]) >= 0 && max([for (p = corner) p[0]]) <= 20);
assert(min([for (p = corner) p[1]]) >= 0 && max([for (p = corner) p[1]]) <= 20);
assert(total_wire_length(corner) < 40);
echo("PASS rounded paths preserve endpoints and stay inside routing corridors");
