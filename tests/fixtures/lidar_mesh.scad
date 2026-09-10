include <../../scad/parameters.scad>
use <../../scad/placeholders/lidar.scad>
use <../../scad/lib/plist.scad>
use <../../scad/lib/shapes3d.scad>

part = "body";
if (part == "body") lidar();
if (part == "holes") lidar_mount_slots();
if (part == "anchor") lidar(anchor=[-1, -1, 0]);
if (part == "solid") lidar(show_mount_holes=false);
if (part == "blind_end") intersection() {
  lidar();
  translate([0, 0, plist_get("bolt_depth", rplidar_c1_plist)])
    lidar_mount_slots(h=0.2);
}
