/**
  * Module: Rear deck mounting-hole bounds and component transforms.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/suspension/rear_chassis/computed_params.scad>

function contains_point(points, p) =
  len([for (q = points) if (norm(q - p) < 0.000001) q]) > 0;

for (panels = [[], rear_panel_specs],
     power_case = [undef, rear_power_case_plist]) {
  layout = rear_chassis_layout(panels=panels,
                               power_case=power_case,
                               equipment=[]);
  holes = rear_chassis_mount_holes(layout);
  expected_count = 5 + 4 * len(panels) + (is_undef(power_case) ? 0 : 4);
  assert(len(holes) == expected_count);
  for (pad = [0, 2.75]) {
    bounds = rear_chassis_holes_bounds(layout, pad);
    assert(len(bounds) == 4 * len(holes));
    for (i = [1:len(bounds) - 1]) {
      a = bounds[i - 1];
      b = bounds[i];
      assert(a[1] < b[1] || (a[1] == b[1] && a[0] <= b[0]));
    }
    for (hole = holes, x = [-1, 1], y = [-1, 1]) {
      r = hole[2] / 2 + pad;
      assert(contains_point(bounds, [hole[0] + x * r,
                                     hole[1] + y * r, hole[2]]));
    }
  }
  if (!is_undef(power_case)) {
    payload = plist_get("power_case", layout);
    for (p = plist_get("mount_holes", payload)) {
      assert(contains_point(holes, concat(p, [plist_get("bore_d", power_case)])));
    }
  }
}

// Wago canonical centers are centered on the bracket before assembly rotation.
for (angle = [0, 90, 37]) {
  layout = rear_chassis_layout(equipment=[],
                               wago_mounts=[["rotation", angle]]);
  holes = rear_chassis_mount_holes(layout);
  mount = plist_get("wago_mounts", layout)[0];
  props = wago_bracket_props([]);
  size = plist_get("size", props);
  pos = plist_get("pos", mount);
  for (p = plist_get("mount_holes", props)) {
    x = p[0] - size[0] / 2;
    y = p[1] - size[1] / 2;
    assert(contains_point(holes,
                          [pos[0] + x * cos(angle) - y * sin(angle),
                           pos[1] + x * sin(angle) + y * cos(angle),
                           plist_get("hole_d", props)]));
  }
}

// A selected perfboard corner follows the board's assembly rotation.
layout = rear_chassis_layout(panels=[],
                             equipment=[["kind", "perf_board",
                                         "rotation", 90,
                                         "component", ["size", [16, 20, 1.6],
                                                       "bolt_spacing", [10, 14],
                                                       "bolt_idxes", [[0, 1]],
                                                       "slot_bore_d", 8]]]);
item = plist_get("equipment", layout)[0];
pos = plist_get("pos", item);
assert(contains_point(rear_chassis_mount_holes(layout),
                      [pos[0] - 7, pos[1] - 5, 8]));
echo("PASS: mounting-hole diameters, sorted padded bounds and component transforms");
