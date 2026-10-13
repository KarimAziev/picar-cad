/**
  * Module: Chassis group selection and reference dimension assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../scad/lib/plist.scad>
use <../scad/suspension/chassis_printable.scad>
use <../scad/suspension/chassis_dimensions.scad>

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
d = chassis_dimensions();
assert(plist_get("wheelbase", d) > 0);
assert(plist_get("wheelbase", d)
       == plist_get("front_axle_y", d) - plist_get("rear_axle_y", d));
assert(plist_get("ground_clearance", d) == -plist_get("ground_z", d));
assert(plist_get("overall_length", d) >= plist_get("chassis_length", d));
assert(plist_get("overall_width", d) >= plist_get("chassis_width", d));
echo("PASS: all 16 split configurations and reference measurement datums");
