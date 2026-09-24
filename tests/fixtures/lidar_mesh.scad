include <../../scad/parameters.scad>
use <../../scad/placeholders/lidar.scad>
use <../../scad/lib/plist.scad>
use <../../scad/lib/shapes3d.scad>

part = "body";
// Housing checks exclude the optional cable and cosmetic lettering.
body_plist = plist_merge(rplidar_c1_plist,
                        ["texts", [],
                         "cable_exit", ["socket_d", 0]]);
if (part == "body") {
  lidar(plist=body_plist);
}
if (part == "holes") {
  lidar_mount_slots(plist=body_plist);
}
if (part == "anchor") {
  lidar(plist=body_plist, anchor=[-1, -1, 0], anchor_z_to_base_height=false);
}
if (part == "base_anchor") {
  lidar(plist=body_plist, anchor=[-1, -1, 0]);
}
if (part == "solid") {
  lidar(plist=body_plist, show_mount_holes=false);
}
if (part == "blind_end") {
  intersection() {
    lidar(plist=body_plist);
    translate([0, 0, plist_get("bolt_depth", body_plist)]) {
      lidar_mount_slots(plist=body_plist, h=0.2);
    }
  }
}
