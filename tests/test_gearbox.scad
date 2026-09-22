include <../scad/steering_params.scad>

use <../scad/lib/plist.scad>
use <../scad/placeholders/motors/rc/gearbox.scad>

module near(actual, expected) {
  delta = actual - expected;
  assert(!is_undef(actual)
         && (is_list(delta) ? norm(delta) : abs(delta)) < 0.000001,
         str(actual, " != ", expected));
}

params = gearbox_compute_params(motor_plist);
holes = plist_get("mount_hole_positions", params);

// Measured preset: rear first, front second, in the unrotated gearbox frame.
near(holes[0], [-13.025, 0, 22.4]);
near(holes[1], [6.775, 0, -3.2]);
near(plist_get("rear_mount_ear_y_min", params), 10.73);
near(plist_get("rear_mount_ear_y_max", params), 13.97);
near(plist_get("front_mount_ear_y_min", params), 9.03);
near(plist_get("front_mount_ear_y_max", params), 12.27);
near(plist_get("gearbox_shaft_boss_d", params), 9.1);

gearbox_plist = plist_get("gearbox", motor_plist);
mount_ears = plist_get("mount_ears", gearbox_plist);
drive_shaft = plist_get("drive_shaft", motor_plist);

// Change the mechanical interface independently of the bracket's padding.
changed_gearbox = plist_merge(gearbox_plist,
                              ["mount_bolt_d", 4,
                               "mount_ear_x_dist", 4,
                               "mount_ear_x_spacing", 23,
                               "mount_ear_y_spacing", 30,
                               "mount_ear_y_shift", 2,
                               "rear_mount_ear_y_center", 15,
                               "front_mount_ear_y_center", 11,
                               "bearing_boss_wall", 1.5,
                               "mount_ears", plist_put("ear_thickness", 4,
                                                       mount_ears)]);
changed_shaft = plist_merge(drive_shaft,
                            ["d", 5,
                             "bearing", ["od", 9, "w", 2]]);
changed_motor = plist_merge(motor_plist,
                            ["gearbox", changed_gearbox,
                             "drive_shaft", changed_shaft]);
changed = gearbox_compute_params(changed_motor);
changed_holes = plist_get("mount_hole_positions", changed);
near(changed_holes[0], [-14.5, 0, 26]);
near(changed_holes[1], [8.5, 0, -4]);
near(plist_get("mount_bolt_spacing", changed), [23, 30]);
near(plist_get("gearbox_shaft_boss_d", changed), 12);
near(plist_get("rear_mount_ear_y_min", changed), 13);
near(plist_get("rear_mount_ear_y_max", changed), 17);
near(plist_get("front_mount_ear_y_min", changed), 9);
near(plist_get("front_mount_ear_y_max", changed), 13);

// Ear heights and the bearing boss do not move mounting-hole axes.
raised = gearbox_compute_params(
  plist_put("gearbox", plist_put("rear_mount_ear_y_center", 20, gearbox_plist),
            motor_plist));
near(plist_get("mount_hole_positions", raised)[0], holes[0]);
near(plist_get("mount_hole_positions", raised)[1], holes[1]);
near(plist_get("rear_mount_ear_y_min", raised), 18.38);
near(plist_get("front_mount_ear_y_min", raised), 9.03);

// Omitted optional gearbox dimensions resolve to the placeholder defaults.
default_gearbox = plist_remove_by_keys(
  ["motor_pad", "thickness", "bottom_straight_w", "motor_shaft_y",
   "motor_x_shift", "outer_shaft_y_center", "rear_mount_ear_y_center",
   "front_mount_ear_y_center", "mount_bolt_d", "mount_cbore_d"],
  plist_put("mount_ears", plist_remove("ear_thickness", mount_ears),
            gearbox_plist));
defaults = gearbox_compute_params(plist_put("gearbox", default_gearbox,
                                            motor_plist));
for (pair = [["motor_pad", 1.2],
             ["thickness", 18],
             ["bottom_straight_w", 15.34],
             ["motor_shaft_y", 18.8],
             ["motor_outer_shaft_x_spacing", 16],
             ["mount_bolt_d", 3.2],
             ["mount_cbore_d", 6.6],
             ["rear_mount_ear_y_min", 9.03],
             ["front_mount_ear_y_min", 9.03]]) {
  near(plist_get(pair[0], defaults), pair[1]);
}

echo("PASS: gearbox mounting datums, changed hardware and shared defaults");
