include <../scad/parameters.scad>
use <../scad/lib/plist.scad>
use <../scad/placeholders/lidar.scad>

size = lidar_size();
assert(size == [55.6, 55.6, 41.3]);
assert(plist_get("bolt_spacing", rplidar_c1_plist) == [43, 43]);
assert(plist_get("bolt_d", rplidar_c1_plist) == 2.5);
assert(plist_get("bolt_depth", rplidar_c1_plist) == 4);
assert(plist_get("laser_transceiver_h", rplidar_c1_plist) == 29.8);

for (obstacle_z = [80, 120, 160], payload_z = [50, 90]) {
  z = lidar_min_mount_z(obstacle_z, 8, payload_z, 10);
  assert(z + plist_get("base_h", rplidar_c1_plist) >= obstacle_z + 8);
  assert(z >= payload_z + 10);
}
assert(lidar_size(plist_put("top_h", 20, rplidar_c1_plist))[2] == 43.1);
echo("PASS: C1 envelope, underside mount specification and optical clearance rule");
