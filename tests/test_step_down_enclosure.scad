/**
  * Module: Power enclosure interfaces and fixed rear-chassis constraints.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/parameters.scad>

use <../scad/lib/functions.scad>
use <../scad/lib/plist.scad>
use <../scad/lib/enclosure_panels.scad>
use <../scad/placeholders/heat_insert_nut.scad>
use <../scad/components/step_down_enclosure/step_down_voltage_enclosure.scad>
use <../scad/suspension/rear_chassis/computed_params.scad>

p = step_down_enclosure_props();
s = plist_get("size", p);
assert(norm([s[0], s[1]] - [84.2, 29.3]) < 1e-6);
assert(len(plist_get("board_mounts", p)) == 6);
assert(plist_get("regulator_pos", p)[0] < plist_get("sensor_pos", p)[0]);
assert(plist_get("pcb_bore_h", p) < plist_get("bottom_thickness", step_down_enclosure_plist) - 1);
assert(len(plist_get("tie_positions", p)) == 3);
assert(norm(plist_get("tie_positions", p)[2] - [8.8, 0, 0]) < 1e-6);
assert(plist_get("tie_positions",
                 step_down_enclosure_props(["cable_tie", ["enabled", false]])) == []);
assert(len(plist_get("tie_positions",
                     step_down_enclosure_props(["cable_tie", ["middle", false]]))) == 2);
wide_ties = step_down_enclosure_props(["cable_tie", ["slot_size", [5.2, 2]]]);
assert(plist_get("size", wide_ties) == s);
assert(plist_get("bolt_spacing", wide_ties) == plist_get("bolt_spacing", p));
for (gap = [2, 6, 8]) {
  q = step_down_enclosure_props(["distance", gap, "cable_tie", ["middle", false]]);
  assert(abs(plist_get("size", q)[0] - s[0] - (gap - 6)) < 1e-6);
  assert(plist_get("size", q)[1] == s[1]);
  assert(plist_get("size", q)[2] == s[2]);
}

hardware = plist_get("insert", p);
assert(plist_get("h", hardware) == 5 && plist_get("d", hardware) == 3.2);
assert(plist_get("flang_d", hardware) == 4 && plist_get("hole_d", hardware) == 2);
assert(abs(plist_get("inner_h", hardware) - 0.5) < 1e-6);
assert(abs(plist_get("slot_d", hardware) - 4.6) < 1e-6);
assert(abs(plist_get("boss_d", p) - 7) < 1e-6);
assert(abs(plist_get("insert_depth", p) - 5.3) < 1e-6);
taper = heat_insert_nut_props(["h", 5, "d", 3.2, "hole_d", 2,
                              "use_taper", true]);
assert(abs(plist_get("slot_d", taper) - 3.8) < 1e-6);
assert(plist_get("bore_h", taper) == 0);
large_insert = step_down_enclosure_props([
  "inner_size", ["110%", "110%", "100%"],
  "insert", ["d", 4.6, "flang_d", 5.6, "h", 8, "hole_d", 3]]);
assert(abs(plist_get("boss_d", large_insert) - 8.6) < 1e-6);
assert(abs(plist_get("insert_depth", large_insert) - 8.3) < 1e-6);
assert(abs(plist_get("lid_bolt_d", large_insert) - 3.2) < 1e-6);
assert(plist_get("lid_bolt_l", large_insert) == 10.4);
tall_insert = step_down_enclosure_props(["insert", ["h", 24]]);
assert(plist_get("body_size", tall_insert)[2]
       >= 3.2 + 24 + 0.3 + 1.2 - 1e-6);

asymmetric = step_down_enclosure_props([
  "walls", ["left", ["t", 6], "right", ["t", 3],
            "rear", ["t", 4], "front", ["t", 5]]]);
assert(plist_get("inner_size", asymmetric) == plist_get("inner_size", p));
assert(norm(plist_get("inner_center", asymmetric) - [1.5, -0.5]) < 1e-6);
assert(norm(plist_get("regulator_pos", asymmetric)
            - plist_get("regulator_pos", p) - [1.5, -0.5, 0]) < 1e-6);

percent = step_down_enclosure_props([
  "inner_size", ["110%", "120%", "130%"],
  "board_pos", ["50%", "50%"],
  "lid", ["texts", [], "vents", ["enabled", false]],
  "cable_tie", ["slot_size", ["5%", "8%"]]]);
inside = plist_get("inner_size", p);
explicit = step_down_enclosure_props([
  "inner_size", [inside[0] * 1.1, inside[1] * 1.2, inside[2] * 1.3],
  "board_pos", ["50%", "50%"],
  "lid", ["texts", [], "vents", ["enabled", false]],
  "cable_tie", ["slot_size", [inside[0] * 1.1 * 0.05, inside[1] * 1.2 * 0.08]]]);
for (key = ["body_size", "regulator_pos", "sensor_pos"]) {
  assert(norm(plist_get(key, percent) - plist_get(key, explicit)) < 1e-6, key);
}
assert(norm(plist_get("slot_size", plist_get("cable_tie", percent))
            - plist_get("slot_size", plist_get("cable_tie", explicit))) < 1e-6);
assert(plist_get("texts", percent) == []);
assert(plist_get("vent_rects", plist_get("lid_panel", percent)) == []);
assert(len(plist_get("vent_rects", plist_get("rear", plist_get("panels", percent)))) > 0);
one_face = step_down_enclosure_props([
  "walls", ["front", ["cutouts", [], "vents", ["enabled", false]]]]);
assert(plist_get("openings", plist_get("front", plist_get("panels", one_face))) == []);
assert(plist_get("vent_rects", plist_get("front", plist_get("panels", one_face))) == []);
assert(plist_get("lid_panel", one_face) == plist_get("lid_panel", p));
assert(plist_get("rear", plist_get("panels", one_face))
       == plist_get("rear", plist_get("panels", p)));

panel = enclosure_panel_props([
  "cutouts", [["l", "20%", "bottom", "40%", "offset", "30%", "corner_r", "25%"]],
  "slots", [["pos", ["10%", "10%"], "size", ["10%", "20%"]]],
  "vents", ["size", ["10%", "60%"], "gap", ["5%", 0],
            "opening_gap", 2, "opening_mode", "shorten"]], [100, 50]);
opening = plist_get("openings", panel)[0];
assert(plist_get("pos", opening) == [30, 20]);
assert(plist_get("size", opening) == [20, 30]);
assert(plist_get("corner_r", opening) == 5);
echo("PASS insert dimensions, asymmetric walls, percentage dimensions and independent panels");

bare = [["kind", "step_down", "component", step_down_voltage_plist,
         "zone", "auto", "rotation", -90]];
reference = rear_chassis_layout(equipment=bare);
layout = rear_chassis_layout();
for (key = ["size", "bounds", "min_y", "max_y", "join_w",
            "transition_y_end", "power_case"]) {
  assert(plist_get(key, reference) == plist_get(key, layout),
         str("Enclosure changed fixed chassis or battery interface: ", key));
}
assert(norm(plist_get("size", layout) - [151.26, 153.49, 6]) < 1e-5);
case_mount = plist_get("power_case", layout);
assert(plist_get("mount_holes", case_mount)
       == plist_get("mount_holes", plist_get("power_case", reference)));
assert(plist_get("mount_z", case_mount) == 53);
e = plist_get("equipment", layout)[0];
assert(plist_get("kind", e) == "step_down_enclosure");
assert(plist_get("rotation", e) == -90);
assert(plist_get("zone", e) == "right");
assert(plist_get("rotation", e)
       == plist_get("rotation", plist_get("equipment", reference)[0]));
assert(plist_get("size", e)[2] + 6 + rear_equipment_gap
       <= plist_get("mount_z", case_mount));
echo("PASS shared PCB interfaces, enclosure fit, regulator orientation, fixed chassis and battery mounts");
