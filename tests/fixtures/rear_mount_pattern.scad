/**
  * Module: Rear plate bolt passages and material support mesh probes.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/rc_params.scad>
include <../../scad/suspension/rear_suspension/rear_suspension_params.scad>

use <../../scad/suspension/rear_chassis/computed_params.scad>
use <../../scad/suspension/rear_suspension/rear_suspension_mount.scad>
use <../../scad/suspension/rear_suspension/rear_suspension_slots.scad>

part = "plate";
radial_land = 1;
top_land_h = 1;
probe_clearance = 0.01;
layout = rear_chassis_layout();
mounts = rear_suspension_bulkhead_mount_positions(layout);
$fn = 64;

module plate() {
  rear_suspension_mount(layout=layout, debug=false, slot_mode=false, joint=true);
}

if (part == "plate") {
  plate();
}
if (part == "blocked_passages") {
  intersection() {
    plate();
    for (p = mounts) {
      translate(p) {
        cylinder(d=rear_suspension_chassis_bolt_d - probe_clearance,
                 h=suspension_chassis_mount_h);
      }
    }
  }
}
if (part == "missing_top_lands") {
  difference() {
    for (p = mounts) {
      translate(p + [0, 0, suspension_chassis_mount_h - top_land_h]) {
        difference() {
          cylinder(d=rear_suspension_chassis_bolt_d + radial_land * 2,
                   h=top_land_h);
          cylinder(d=rear_suspension_chassis_bolt_d + probe_clearance,
                   h=top_land_h);
        }
      }
    }
    plate();
  }
}
if (part == "outside_head_support") {
  linear_extrude(height=top_land_h) {
    difference() {
      for (p = mounts) {
        translate([p[0], p[1]]) {
          circle(d=rear_suspension_chassis_bolt_bore_d + radial_land * 2);
        }
      }
      rear_suspension_mount_outline(layout);
    }
  }
}
