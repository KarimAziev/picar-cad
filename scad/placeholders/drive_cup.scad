/**
  * Module: Drive Cup.
  * A drive cup is a mechanical part used to connect the driveshaft or universal
  * joints to the differential or wheel axles.
  *
  * Current supported type is dogbone drive cup that holds the ball of a dogbone
  * drive shaft to transfer power to the wheels.
  *
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>

drive_cup_base_plist = ["od", 11,
                        "h", 6.5,
                        "d", 5.8,
                        "bolt_d", m3_hole_dia,
                        "bolt_n", 1,
                        "bore_d", 4.5,
                        "bore_h", 1,
                        "sink", true,
                        "bolt_distance", "50%", // either "number", either numeric string-percent, e.g. "90%" from `h`,
                        ];

dogbone_cup_plist    = ["od", 10,
                        "d", plist_get("d", drive_cup_base_plist),
                        "wall", 2,
                        "h", 9.5,
                        "cutout_h", "98%", // either "number", either numeric string-percent, e.g. "90%" from `h`
                        "cutout_w", 2.2,
                        "upper_hole_d", "99%",
                        "upper_hole_h", 2];

drive_cup_plist      = ["dogbone_cup", dogbone_cup_plist,
                        "base_cup", drive_cup_base_plist,
                        "color", metallic_silver_3];

module drive_cup_base(plist, color) {
  od = plist_get("od", plist);
  h = plist_get("h", plist);
  d = plist_get("d", plist);

  thickness = plist_get("bolt_depth", plist, d ? (od - d) : od);

  bolt_d = plist_get("bolt_d", plist);
  bore_d = plist_get("bore_d", plist);
  sink = plist_get("sink", plist);
  bore_h = plist_get("bore_h", plist);
  bolt_n = plist_get("bolt_n", plist, bolt_d ? 1 : 0);
  bolt_distance = plist_maybe_from_percent(prop="bolt_distance",
                                           plist=plist,
                                           default="50%",
                                           total=h);

  module _bolt_hole() {
    translate([-od / 2 + 0.1, 0, bolt_distance]) {
      rotate([0, 90, 0]) {
        counterbore(h=thickness,
                    d=bolt_d,
                    bore_h=bore_h,
                    bore_d=bore_d,
                    sink=sink,
                    reverse=true);
      }
    }
  }

  render() {
    difference() {
      ring(outer_d=od, d=d, h=h, color=color);

      if (bolt_d && bolt_n > 0) {
        for (i = [0 : bolt_n - 1]) {

          let (angle = i * 360 / bolt_n) {
            rotate([0, 0, angle]) {
              _bolt_hole();
            }
          }
        }
      }
    }
  }
}

module drive_cup_dogbone_cup(plist, color) {

  od = plist_get("od", plist);
  wall = plist_get("wall", plist);
  hole_d = od - wall * 2;
  h = plist_get("h", plist);
  cutout_w = plist_get("cutout_w", plist);
  cutout_h = plist_maybe_from_percent(prop="cutout_h",
                                      plist=plist,
                                      default="99%",
                                      total=h);

  upper_hole_h = plist_maybe_from_percent(prop="upper_hole_h",
                                          plist=plist,
                                          total=h);
  upper_hole_d = plist_maybe_from_percent(prop="upper_hole_d",
                                          plist=plist,
                                          total=od - 0.1);

  difference() {
    ring(outer_d=od, d=hole_d, h=h, color=color);
    if (cutout_w && cutout_h) {
      translate([0, 0, cutout_h / 2 + h - cutout_h]) {
        cube([cutout_w, od, cutout_h + 0.1], center=true);
      }
    }
    if (upper_hole_h && upper_hole_d) {
      translate([0, 0, h - upper_hole_h + 0.1]) {
        cylinder(d2=upper_hole_d, d1=hole_d, h=upper_hole_h + 0.1, $fn=30);
      }
    }
  }
}

module drive_cup(plist) {
  dogbone_cup = plist_get("dogbone_cup", plist);
  base_cup = plist_get("base_cup", plist);
  color = plist_get("color", plist);
  base_cup_h = base_cup ? plist_get("h", base_cup) : undef;
  union() {
    if (base_cup) {
      drive_cup_base(plist=base_cup, color=color);
    }

    if (dogbone_cup) {
      maybe_translate([0, 0, base_cup_h]) {
        drive_cup_dogbone_cup(plist=dogbone_cup, color=color);
      }
    }
  }
}

drive_cup(plist=drive_cup_plist);