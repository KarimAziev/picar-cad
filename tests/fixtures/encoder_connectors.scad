/**
  * Module: Encoder connector and support-wall clearance fixtures.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../scad/rc_params.scad>

use <../../scad/components/encoder_l_bracket.scad>
use <../../scad/lib/plist.scad>
use <../../scad/motor_brackets/rc/gearmotor_encoder_bracket.scad>
use <../../scad/placeholders/rotary_encoder.scad>

jst          = false;
pins         = false;
part         = "l";
mode         = "solid";
target_h     = 10;
extra_left_w = 10;
top_corner_r = 1;
pl           = plist_merge(as5048A_encoder_plist,
                 ["show_jst_shr", jst,
                  "show_pins", pins]);
params = gearmotor_encoder_params(motor_plist,
                                  gearbox_bracket_thickness,
                                  encoder_plist=pl);

module bracket() {
  if (part == "l") {
    encoder_l_bracket(pl,
                      target_h,
                      extra_left_w=extra_left_w,
                      top_corner_r=top_corner_r);
  } else {
    gearmotor_encoder_bracket(params);
  }
}

module electronics() {
  if (part == "l") {
    rotate([90, 0, 0]) {
      translate([0, target_h, 3]) {
        rotate([0, 0, encoder_should_rotate(pl, target_h, 1.6, 1.5, 0) ? 90 : 0]) {
          encoder(pl, show_bolt=false, show_nut=false);
        }
      }
    }
  } else {
    gearmotor_encoder_bracket(params, show_bracket=false, show_encoder=true);
  }
}

if (mode == "foot_gaps") {
  foot_w = plist_get("size", pl)[encoder_should_rotate(pl,
                                                       target_h,
                                                       1.6,
                                                       1.5,
                                                       0)
                                ? 1 : 0];
  difference() {
    translate([-foot_w / 2 + 0.01, -2.99, 0.01]) {
      cube([foot_w - 0.02, 2.98, 1.58]);
    }
    bracket();
  }
} else if (mode == "collision") {
  intersection() {
    bracket();
    electronics();
  }
} else if (mode == "connectors") {
  difference() {
    encoder(pl, show_bolt=false, show_nut=false);
    translate([-30, -30, 0]) {
      cube([60, 60, 10]);
    }
  }
} else {
  bracket();
}
