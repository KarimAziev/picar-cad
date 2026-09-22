include <../scad/steering_params.scad>
use <../scad/lib/plist.scad>
use <../scad/suspension/steering_characterization/datums.scad>

d = steering_audit_datums();
pivots = plist_get("bellcrank_pivots", d);
mounts = plist_get("center_mounts", d);
plate = plist_get("center_plate_holes", d);
a = plist_get("wheel_rod_a", d);
b = plist_get("wheel_rod_b", d);

assert(abs(norm(pivots[1] - pivots[0]) - chassis_bellcrank_spacing) < 1e-8);
assert(abs(norm(plate[1] - plate[0]) - plist_get("center_link_l", d)) < 1e-8);
assert(abs(mounts[0][1] - 12.15) < 1e-8);
assert(abs(plate[0][1] - 12.30) < 1e-8);
assert(abs(plist_get("wheel_rod_l", d) - 39.7) < 1e-8);
for (i = [0:1]) {
  assert(abs(norm(b[i] - a[i]) - plist_get("wheel_rod_l", d)) < 1e-8);
}
assert(a[0][0] == -a[1][0] && a[0][1] == a[1][1] && a[0][2] == a[1][2]);
assert(abs(norm(plist_get("servo_rod_b", d) - plist_get("servo_rod_a", d))
           - plist_get("servo_rod_l", d)) < 1e-8);
// Nominal mismatches are deliberately recorded, not silently repaired.
assert(abs(norm(pivots[1] - pivots[0]) - plist_get("center_link_l", d) - 0.1) < 1e-8);
