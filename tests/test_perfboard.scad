/**
  * Module: Perfboard pad layout and fixed-lid mounting assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/lipo_pack_case/standalone_parameters.scad>

use <../scad/lipo_pack_case/lid_equipment.scad>
use <../scad/lipo_pack_case/multi_lipo_pack_case.scad>
use <../scad/lipo_pack_case/multi_lipo_pack_lid.scad>
use <../scad/placeholders/perfboard.scad>

minimal = ["size", [20, 80, 1.6],
           "bolt_spacing", [16, 76]];
p       = perfboard_props(minimal);
assert([plist_get("cols", p), plist_get("rows", p), plist_get("bus_pad_cols", p)]
       == [6, 28, 4]);
custom  = perfboard_props(plist_merge(minimal,
                                     ["rows", 0,
                                      "cols", 3,
                                      "bus_pad_cols", 0]));
assert(plist_get("rows", custom) == 0 && plist_get("cols", custom) == 3
       && plist_get("bus_pad_cols", custom) == 0);
wide    = perfboard_props(["size", [30, 100, 1.6],
                           "bolt_spacing", [26, 96]]);
assert(plist_get("cols", wide) > plist_get("cols", p)
       && plist_get("rows", wide) > plist_get("rows", p)
       && plist_get("bus_pad_cols", wide) > plist_get("bus_pad_cols", p));
assert(perfboard_bolt_positions(p, [[1, 0], [1, 1]]) == [[8, -38], [8, 38]]);
assert(perfboard_bolt_positions(p, []) == []);
assert(len(perfboard_bolt_positions(p)) == 4);

spec    = plist_get("lid", standalone_lipo_case);
for (orientation = ["wlh", "lwh"], turn = [0, 180]) {
  pl = plist_merge(standalone_lipo_case,
                   ["orientation", orientation,
                    "power_rotation", turn]);
  lid = multi_lipo_pack_lid_props(pl);
  absent = plist_merge(pl, ["lid", plist_merge(spec, ["perfboard", undef])]);
  assert(lid == multi_lipo_pack_lid_props(absent));
  assert(multi_lipo_pack_props(pl) == multi_lipo_pack_props(absent));
  board = lid_perfboard_props(plist_get("perfboard", spec), lid);
  assert(len(plist_get("holes", board)) == 2);
  assert(!plist_get("slot_bore_sink", plist_get("component", board)));
  assert(plist_get("outer", board) < 0);
}
// A shorter board fits the skirt of a case with rails along Y.
y_case = plist_merge(standalone_lipo_case,
                     ["walls", plist_merge(plist_get("walls", standalone_lipo_case),
                                           ["front", ["t", 3,
                                                      "h", 20],
                                            "rear", ["t", 3,
                                                     "h", 20],
                                            "left", ["t", 3,
                                                     "h", 30],
                                            "right", ["t", 3,
                                                      "h", 30]])]);
y_lid = multi_lipo_pack_lid_props(y_case);
y_spec = plist_merge(plist_get("perfboard", spec),
                     ["component", plist_merge(perfboard_default_plist,
                                               ["size", [20, 30, 1.6],
                                                "bolt_spacing", [16, 26],
                                                "bolt_idxes", [[1, 0], [1, 1]]])]);
y_board = lid_perfboard_props(y_spec, y_lid);
assert(plist_get("axis", y_board) == "y");
assert(len(plist_get("holes", y_board)) == 2);
assert(!plist_get("enabled", lid_perfboard_props(undef, y_lid)));
assert(!plist_get("enabled", lid_perfboard_props(["enabled", false], y_lid)));

echo("PASS: perfboard auto counts, selected corners and fixed case/lid envelopes");
