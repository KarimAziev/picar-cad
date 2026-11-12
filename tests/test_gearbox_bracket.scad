/**
  * Module: Gearbox bracket mounting datums and boss seating assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/rc_params.scad>

use <../scad/lib/plist.scad>
use <../scad/motor_brackets/rc/util.scad>

module near(actual, expected) {
  delta = actual - expected;
  assert((is_list(delta) ? norm(delta) : abs(delta)) < 0.000001,
         str(actual, " != ", expected));
}

p = gearmotor_bracket_compute_params();
holes = plist_get("mount_hole_positions", p);
gearbox_holes = plist_get("gearbox_hole_positions", p);
origin = [plist_get("min_hole_x", p), plist_get("min_hole_y", p)];

// Chassis pattern, expressed at anchor=[-1, -1, 1].
for (i = [0:2]) {
  near(holes[i] - origin, [[30.625, 37.0], [0, 0], [0, 56.1]][i]);
  assert(norm(holes[i] - origin - [[30.6, 37.0], [0, 0], [0, 56.1]][i]) < 0.03,
         "Chassis holes must align with the measured slot pattern within 0.03 mm");
}
near(gearbox_holes[0] - origin, [9.425, -1.6]);
near(gearbox_holes[1] - origin, [30.625, 26.0]);
near(plist_get("base_bounds", p)[0], [-28.65, -29, 0]);

// Hardware spacing and chassis offset are independent dimensions.
g = plist_get("gearbox", motor_plist);
aligned_motor = plist_put("gearbox",
                          plist_put("mount_ear_y_spacing",
                                    plist_get("mount_ear_y_spacing", g)
                                    - gearbox_bracket_rear_mount_hole_y_offset, g),
                          motor_plist);
aligned = gearmotor_bracket_compute_params(plist=aligned_motor,
                                           rear_mount_hole_y_offset=0);
for (key = ["pts", "pts_2",
            "bounds", "mount_hole_positions"]) {
  assert(plist_get(key, p) == plist_get(key, aligned),
         str("Rear bolt adjustment must preserve ", key));
}
for (delta = [-2, 0, 3]) {
  motor = plist_put("gearbox",
                    plist_put("mount_ear_y_spacing",
                              plist_get("mount_ear_y_spacing", g) + delta, g),
                    motor_plist);
  changed = gearmotor_bracket_compute_params(plist=motor,
                                             rear_mount_hole_y_offset=gearbox_bracket_rear_mount_hole_y_offset + delta);
  for (i = [0:2]) {
    near(plist_get("mount_hole_positions", changed)[i], holes[i]);
  }
  near(plist_get("gearbox_hole_positions", changed)[0],
       gearbox_holes[0] - [0, delta]);
  near(plist_get("gearbox_hole_positions", changed)[1], gearbox_holes[1]);
  for (key = ["min_hole_x", "max_hole_x",
              "min_hole_y", "max_hole_y"]) {
    near(plist_get(key, changed), plist_get(key, p));
  }
}

flat = gearmotor_bracket_compute_params(use_boss_pockets=false);
near(plist_get("boss_pocket_depth", flat), 0);
for (type = ["front", "rear"]) {
  near(plist_get(type, plist_get("boss_heights", flat)),
       plist_get(type, plist_get("boss_heights", p)) - plist_get("boss_pocket_depth", p));
}
for (key = ["mount_hole_positions", "gearbox_hole_positions", "bounds"]) {
  assert(plist_get(key, flat) == plist_get(key, p),
         str("Boss seating must preserve ", key));
}
echo("PASS: chassis mounting pattern, independent rear bolt adjustment and boss seating");
