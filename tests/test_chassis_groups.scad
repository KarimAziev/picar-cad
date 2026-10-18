/**
  * Module: Chassis group selection and reference dimension assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/rc_params.scad>

use <../scad/lib/plist.scad>
use <../scad/suspension/chassis_dimensions.scad>
use <../scad/suspension/chassis_printable.scad>
use <../scad/suspension/computed.scad>
use <../scad/suspension/front_bumper/common.scad>
use <../scad/suspension/rear_chassis/computed_params.scad>

for (mask = [0:15]) {
  splits = [for (i = [0:3]) floor(mask / pow(2, i)) % 2 == 1];
  for (section = [0:4]) {
    group = chassis_group_sections(section, splits);
    assert(group[0] <= section && group[1] >= section);
    assert(group[0] == 0 || splits[group[0] - 1]);
    assert(group[1] == 4 || splits[group[1]]);
    if (group[0] < group[1]) {
      for (i = [group[0]:group[1] - 1]) {
        assert(!splits[i]);
        assert(chassis_group_sections(i, splits) == group);
      }
    }
  }
}
assert(chassis_group_sections(1, [true, false, true, true]) == [1, 2]);
assert(chassis_group_sections(2, [true, false, false, true]) == [1, 3]);
layout = rear_chassis_layout(min_width=suspension_chassis_width());
d = chassis_dimensions(layout=layout);
assert(plist_get("wheelbase", d) > 0);
assert(plist_get("wheelbase", d)
       == plist_get("front_axle_y", d) - plist_get("rear_axle_y", d));
assert(plist_get("ground_clearance", d) == -plist_get("ground_z", d));
assert(plist_get("overall_length", d) >= plist_get("chassis_length", d));
assert(plist_get("overall_width", d) >= plist_get("chassis_width", d));
echo("PASS: all 16 split configurations and reference measurement datums");

assert(abs(plist_get("chassis_front_y", d)
           - (115.825 + front_chassis_bumper_extension)) < 1e-6);
for (plate = [false, true], foam = [false, true]) {
  for (pl = [[], ["foam_w", 210,
                  "foam_l", 48]]) {
    measured = chassis_dimensions(layout=layout,
                                  bumper_top_plate=plate,
                                  bumper_foam=foam,
                                  bumper_pl=pl);
    parts = concat(plate ? ["plate"] : [], foam ? ["foam"] : []);
    expected_front = max(concat([plist_get("front_y", d)],
                                [for (part = parts) front_bumper_position(pl, part)[1]
                                                    + front_bumper_size(pl, part)[1]]));
    expected_width = max(concat([plist_get("overall_width", d)],
                                [for (part = parts) front_bumper_size(pl, part)[0]]));
    assert(plist_get("front_y", measured) == expected_front);
    assert(plist_get("overall_length", measured)
           == expected_front - plist_get("rear_y", d));
    assert(plist_get("overall_width", measured) == expected_width);
    for (key = ["chassis_length", "chassis_width",
                "wheelbase", "ground_z"]) {
      assert(plist_get(key, measured) == plist_get(key, d));
    }
  }
}
echo("PASS: head extension and visible bumper measurement envelopes");
