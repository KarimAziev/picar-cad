include <../../scad/parameters.scad>

use <../../scad/lib/plist.scad>
use <../../scad/placeholders/motors/rc/rc_gearbox.scad>
use <../../scad/placeholders/motors/rc/rc_gearmotor.scad>

part = "housing";
$fn = 128;
if (part == "housing") {
  gearbox(anchor=[0, 0, 1]);
 }
if (part == "housing_centered") {
  gearbox(anchor=[0, 0, 0]);
 }
if (part == "motor_only") {
  rc_motor(show_gearbox=false, show_rear_shaft=false, show_front_shaft=false);
 }
module inverse_adapter() {
  size = rc_gearmotor_size();
  center = plist_get("center", rc_gearbox_layout());
  rotate([90, 0, 0]) {
    translate([center[0], size[1] / 2, -size[2] / 2]) {
      rc_gearmotor();
    }
  }
}
if (part == "native") {
  rc_motor();
 }
if (part == "adapter_native") {
  inverse_adapter();
 }
