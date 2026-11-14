/**
  * Module: Rear hub bearing, socket and camber-arm clearance probes.
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/suspension/rear_axle/arm_hub_params.scad>

use <../../scad/lib/plist.scad>
use <../../scad/lib/transforms.scad>
use <../../scad/suspension/rear_axle/rear_hub.scad>

part   = "hub";
anchor = [1, 1, 1];
pl     = rear_hub_spec;
eps    = 0.05;

module hub() {
  rear_hub(pl, anchor=anchor);
}

module link_bores(d, inset=0) {
  for (p = rear_hub_link_positions(pl)) {
    translate(p - [0, plist_get("link_l", pl) / 2 - inset, 0]) {
      rotate([-90, 0, 0]) {
        cylinder(d=d, h=plist_get("link_l", pl) - 2 * inset, $fn=96);
      }
    }
  }
}

if (part == "hub") {
  hub();
} else if (part == "slot_collision") {
  intersection() {
    hub();
    rear_hub(pl, anchor=anchor, slot_mode=true);
  }
} else if (part == "blocked_bores") {
  intersection() {
    hub();
    with_anchor(size=rear_hub_size(pl), anchor=anchor) {
      union() {
        link_bores(plist_get("link_bolt_d", pl));
        for (p = rear_hub_ball_positions(pl)) {
          translate(p) {
            sphere(d=plist_get("ball_d", pl), $fn=96);
          }
        }
        bearings = rear_hub_bearing_positions(pl);
        for (i = [0, 1]) {
          prefix = i == 0 ? "inner" : "outer";
          translate(bearings[i] + [eps, 0, 0]) {
            rotate([0, 90, 0]) {
              cylinder(d=plist_get(str(prefix, "_bearing_od"), pl),
                       h=plist_get(str(prefix, "_bearing_w"), pl) - 2 * eps,
                       $fn=96);
            }
          }
        }
      }
    }
  }
} else if (part == "missing_link_walls") {
  difference() {
    with_anchor(size=rear_hub_size(pl), anchor=anchor) {
      difference() {
        link_bores(5.2, inset=eps);
        link_bores(3.4);
      }
    }
    hub();
  }
} else {
  assert(false, str("Unknown rear hub probe: ", part));
}
