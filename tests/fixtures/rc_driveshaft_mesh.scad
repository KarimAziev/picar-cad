include <../../scad/parameters.scad>
use <../../scad/lib/plist.scad>
use <../../scad/placeholders/rc_driveshaft.scad>
use <../../scad/placeholders/rc_dogbone.scad>

part = "shaft";
l = 60;
drop = 0;
centered = false;
$fn = 64;

if (part == "tube") {
  _rc_driveshaft_tube(rc_driveshaft_plist);
}
if (part == "rod") {
  _rc_driveshaft_rod(rc_driveshaft_plist);
}
if (part == "hub") {
  _rc_driveshaft_hub(rc_driveshaft_plist);
}
if (part == "dogbone") {
  rc_dogbone();
}
if (part == "shaft") {
  rc_driveshaft(l=l, drop=drop, anchor=centered ? [0, 0, 0] : [0, 0, 1]);
}
if (part == "outside_slot") {
  difference() {
    rc_driveshaft(l=l, drop=drop);
    rc_driveshaft(l=l, drop=drop, slot_mode=true);
  }
}
