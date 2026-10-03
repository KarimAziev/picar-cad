
/**
  * Module: Encoder connector dimensions and mounting datums.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/rc_params.scad>

use <../scad/lib/plist.scad>
use <../scad/motor_brackets/rc/gearmotor_encoder_bracket.scad>
use <../scad/placeholders/rotary_encoder.scad>

module near(a, b) {
  assert(norm(a - b) < 0.000001, str(a, " != ", b));
}

plain  = plist_merge(as5048A_encoder_plist,
                    ["show_jst_shr", false,
                     "show_pins", false]);
assert(!encoder_has_connectors(plain));
jst    = encoder_connector_spec(as5048A_encoder_plist, "jst_shr");
pins   = encoder_connector_spec(as5048A_encoder_plist, "pins");
near(plist_get("size", jst), [9.7, 4.83, 3.4]);
near(plist_get("position", jst), [0, 4.65, 0]);
near([plist_get("contacts", jst), plist_get("pitch", jst)], [6, 1]);
near(plist_get("size", pins), [8.1, 2.7, 4.56]);
near(plist_get("position", pins), [0, -5.145, 0]);
near(plist_get("rotation", pins), [0, 0, 180]);

custom = plist_merge(as5048A_encoder_plist,
                     ["jst_shr", ["contacts", 8,
                                  "pitch", 1],
                      "wire_pads", ["cols", 4,
                                    "w", 1.74,
                                    "gap", 0.8,
                                    "l", 2.71,
                                    "side", "bottom",
                                    "padding", 0.7]]);
near(plist_get("size", encoder_connector_spec(custom, "jst_shr")),
     [11.7, 4.83, 3.4]);
near(plist_get("size", encoder_connector_spec(custom, "pins")),
     [10.16, 2.54, 4.56]);

base   = gearmotor_encoder_params(motor_plist, gearbox_bracket_thickness);
for (flags = [[true, false], [false, true], [true, true]]) {
  pl = plist_merge(as5048A_encoder_plist,
                   ["show_jst_shr", flags[0],
                    "show_pins", flags[1]]);
  mount = gearmotor_encoder_params(motor_plist,
                                   gearbox_bracket_thickness,
                                   encoder_plist=pl);
  assert(encoder_has_connectors(pl));
  for (key = ["pcb_back", "sensor_face",
              "magnet_face", "size"]) {
    near(plist_get(key, mount), plist_get(key, base));
  }
  assert(plist_get("mount_holes", mount) == plist_get("mount_holes", base));
  near([encoder_total_thickness(pl)],
       [encoder_total_thickness(as5048A_encoder_plist)]);
 }
echo("PASS: encoder connectors follow pad rows and preserve sensor/mount datums");
