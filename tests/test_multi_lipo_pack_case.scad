include <../scad/parameters.scad>

use <../scad/lib/functions.scad>
use <../scad/lib/plist.scad>
use <../scad/lipo_pack_case/multi_lipo_pack_case.scad>
use <../scad/placeholders/lipo_pack.scad>

logical_pack_size = [lipo_pack_width, lipo_pack_length, lipo_pack_height];
orientations = ["wlh", "whl", "lwh", "lhw", "hlw", "hwl"];
expected_layouts = ["x", "y", "y", "y", "x", "x"];

walls = ["front", ["t", 2,
                     "vent_h", "80%",
                     "vent_w", 3,
                     "vent_row_gap", 4,
                     "vent_col_gap", "5%",
                     "vent_pad", 0,
                     "vent_pad_left", "10%",
                     "vent_pad_right", "5%",
                     "vent_pad_bottom", 1,
                     "vent_pad_top", "10%"],
         "rear", ["t", 2],
         "bottom", ["t", 3],
         "left", ["t", 2,
                   "vent_h", "80%",
                   "vent_w", 3],
         "right", ["t", 2,
                    "vent_h", "80%",
                    "vent_w", 3],
         "inner", ["t", 2]];

function pack_plist(orientation="wlh", color="#B51F2C") =
  ["size", logical_pack_size,
   "orientation", orientation,
   "color", color,
   "corner_r", 2,
   "top_cover", ["bg", "gold"],
   "side_cover", ["bg", "silver"]];

function case_plist(pack_orientation="wlh",
                    case_orientation="wlh",
                    pack_layout="auto") =
  ["lipo_packs", [pack_plist(pack_orientation),
                    pack_plist(pack_orientation, "#315C8C")],
   "orientation", case_orientation,
   "pack_layout", pack_layout,
   "color", white_smoke_1,
   "corner_r", 4,
   "walls", walls,
   "bolt_pad_x", 10,
   "bolt_pad_y", 20,
   "bolt_d", m3_hole_dia,
   "bore_d", m3_countersunk_head_dia + 0.2,
   "bore_h", m3_countersunk_head_h + 0.15];

function vectors_close(a, b, epsilon=0.000001) =
  len(a) == len(b)
  && len([for (i = [0 : len(a) - 1]) if (abs(a[i] - b[i]) <= epsilon) i])
     == len(a);

vent_props = multi_lipo_pack_vent_props(
  ["vent_w", 5,
   "vent_h", "50%",
   "vent_pad", 0,
   "vent_pad_left", "10%",
   "vent_pad_right", 5,
   "vent_pad_bottom", 2,
   "vent_pad_top", "20%"],
  100,
  20);

assert(plist_get("enabled", vent_props));
assert(vectors_close(plist_get("padding", vent_props), [10, 5, 2, 4]));
assert(vectors_close(plist_get("available_size", vent_props), [85, 14]));
assert(vectors_close(plist_get("slot_size", vent_props), [5, 7]));
assert(plist_get("count", vent_props) == [9, 1]);
assert(vectors_close(plist_get("start", vent_props), [10, 5.5]));

assert(!plist_get("enabled",
                  multi_lipo_pack_vent_props(["vent_w", 5], 100, 20)));

wlh_case = case_plist("wlh");
wlh_props = multi_lipo_pack_props(wlh_case);
wlh_positions = plist_get("pack_positions", wlh_props);
max_bolt_spacing = plist_get("max_bolt_spacing", wlh_props);

assert(plist_get("pack_layout", wlh_props) == "x");
assert(wlh_positions[0][0] < wlh_positions[1][0]);
assert(wlh_positions[0][1] == wlh_positions[1][1]);

percent_bolt_props = multi_lipo_pack_props(
  plist_merge(wlh_case, ["bolt_spacing", ["50%", "75%"]]));
assert(vectors_close(plist_get("bolt_spacing", percent_bolt_props),
                     [max_bolt_spacing[0] * 0.5,
                      max_bolt_spacing[1] * 0.75]));

mixed_bolt_props = multi_lipo_pack_props(
  plist_merge(wlh_case,
              ["bolt_spacing", [30, "50%"],
               "bolt_spacing_x", "25%"]));
assert(vectors_close(plist_get("bolt_spacing", mixed_bolt_props),
                     [max_bolt_spacing[0] * 0.25,
                      max_bolt_spacing[1] * 0.5]));

lhw_case = case_plist("lhw");
lhw_props = multi_lipo_pack_props(lhw_case);
lhw_positions = plist_get("pack_positions", lhw_props);

assert(plist_get("pack_layout", lhw_props) == "y");
assert(lhw_positions[0][0] == lhw_positions[1][0]);
assert(lhw_positions[0][1] < lhw_positions[1][1]);

forced_x_props = multi_lipo_pack_props(case_plist("lhw", pack_layout="x"));
assert(plist_get("pack_layout", forced_x_props) == "x");

for (i = [0 : len(orientations) - 1]) {
  pack_orientation = orientations[i];
  pack = pack_plist(pack_orientation);
  props = multi_lipo_pack_props(case_plist(pack_orientation));
  pack_sizes = plist_get("pack_sizes", props);

  assert(lipo_pack_oriented_size(pack)
         == orientation_size(pack_orientation, logical_pack_size));
  assert(pack_sizes[0] == orientation_size(pack_orientation, logical_pack_size));
  assert(pack_sizes[0] == pack_sizes[1]);
  assert(plist_get("pack_layout", props) == expected_layouts[i]);
}

mixed_case = plist_merge(case_plist(),
                         ["lipo_packs", [pack_plist("wlh"),
                                         pack_plist("lhw")]]);
mixed_props = multi_lipo_pack_props(mixed_case);
assert(plist_get("pack_layout", mixed_props) == "y");

for (case_orientation = orientations) {
  props = multi_lipo_pack_props(case_plist("wlh", case_orientation));
  canonical_size = plist_get("canonical_size", props);
  final_size = plist_get("size", props);

  assert(vectors_close(final_size,
                       orientation_size(case_orientation, canonical_size)),
         str("Wrong outer size for case orientation ", case_orientation));
}

render_cases = [wlh_case,
                lhw_case,
                case_plist("wlh", "lwh"),
                case_plist("whl", "wlh")];

for (i = [0 : len(render_cases) - 1]) {
  translate([(i % 2) * 230, floor(i / 2) * 230, 0]) {
    multi_lipo_pack_case(pl=render_cases[i], anchor=[0, 0, 1]);
  }
}

translate([460, 230, 0]) {
  multi_lipo_pack_case(pl=case_plist("wlh", "lwh"),
                       anchor=[0, 0, 1],
                       slot_mode=true);
}

echo("PASS: smart pack layout and independent case orientation");
