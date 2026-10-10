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

// Terminal access follows hardware independently of vent and label settings.
footprints = plist_get("terminal_footprints", p);
assert(len(footprints) == 3);
assert(norm(footprints[0][1] - [5.8, 9.6]) < 1e-6);
assert(norm(footprints[1][1] - [5.8, 9.6]) < 1e-6);
assert(norm(footprints[2][1] - [5.8, 10.1]) < 1e-6);
access = step_down_enclosure_props([
  "lid", ["slots", [], "texts", [], "vents", ["enabled", false]],
  "header_slot", ["enabled", false]]);
access_openings = plist_get("openings", plist_get("lid_panel", access));
assert(len(access_openings) == 3 + len(plist_get("component_footprints", p)));
for (i = [0 : 2]) {
  opening = access_openings[i];
  size = plist_get("size", opening);
  pos = plist_get("pos", opening);
  assert(norm(size - footprints[i][1] - [2, 2]) < 1e-6);
  assert(norm(pos + size / 2 - [s[0], s[1]] / 2 - footprints[i][0]) < 1e-6);
}
shifted = step_down_enclosure_props([
  "inner_size", ["120%", "150%", "100%"], "board_pos", ["60%", "40%"],
  "cable_tie", ["enabled", false],
  "walls", ["left", ["t", 6], "right", ["t", 3],
            "rear", ["t", 4], "front", ["t", 5]]]);
shift = plist_get("regulator_pos", shifted) - plist_get("regulator_pos", p);
for (i = [0 : 2]) {
  fp = plist_get("terminal_footprints", shifted)[i];
  assert(norm(fp[0] - footprints[i][0] - [shift[0], shift[1]]) < 1e-6);
  assert(fp[1] == footprints[i][1]);
}
custom_terminals = step_down_enclosure_props([
  "step_down_voltage", plist_merge(step_down_voltage_plist,
    ["vin", ["rotation_z", 0, "base_w", 12, "thickness", 7,
             "x_offset", 1, "y_offset", 2],
     "vout", ["rotation_z", 45, "base_w", 10, "thickness", 6,
              "x_offset", 2, "y_offset", 3]]),
  "sensor_current", plist_merge(ina_plist,
    ["screw_terminal", ["base_w", 12, "thickness", 7, "y_offset", 1]])]);
custom_fp = plist_get("terminal_footprints", custom_terminals);
assert(norm(custom_fp[0][1] - [12, 7]) < 1e-6);
assert(norm(custom_fp[1][1] - [16 / sqrt(2), 16 / sqrt(2)]) < 1e-6);
assert(norm(custom_fp[2][1] - [7, 12]) < 1e-6);
regulator_pos = plist_get("regulator_pos", custom_terminals);
board = plist_get("placeholder_size", step_down_voltage_plist);
assert(norm(custom_fp[0][0] - [regulator_pos[0] - board[0] / 2 + 7,
                               regulator_pos[1] + board[1] / 2 - 5.5]) < 1e-6);
percent_access = step_down_enclosure_props([
  "lid", ["terminal_clearance", ["10%", "20%"]]]);
percent_openings = plist_get("openings", plist_get("lid_panel", percent_access));
for (i = [0 : 2]) {
  assert(norm(plist_get("size", percent_openings[i])
              - [footprints[i][1][0] * 1.2, footprints[i][1][1] * 1.4]) < 1e-6);
}
no_sensor_terminal = step_down_enclosure_props([
  "sensor_current", plist_merge(ina_plist, ["screw_terminal", []])]);
assert(len(plist_get("terminal_footprints", no_sensor_terminal)) == 2);
echo("PASS terminal openings track board placement, terminal dimensions and rotations");

components = plist_get("component_footprints", p);
assert(len(components) == 7);
rpos = plist_get("regulator_pos", p);
assert(norm(components[0][0] - [rpos[0] + 6.875, rpos[1] - 4.8]) < 1e-6);
assert(norm(components[0][1] - [7.15, 7.4]) < 1e-6);
assert(components[1][1] == [7, 7] && components[2][1] == [7, 7]);
assert(norm(components[4][1] - [4.6, 3.2]) < 1e-6);
for (i = [0 : len(components) - 1]) {
  opening = access_openings[i + 3];
  size = plist_get("size", opening);
  assert(norm(size - components[i][1] - [1, 1]) < 1e-6);
  moved = plist_get("component_footprints", shifted)[i];
  assert(norm(moved[0] - components[i][0] - [shift[0], shift[1]]) < 1e-6);
}
changed_components = step_down_enclosure_props([
  "step_down_voltage", plist_merge(step_down_voltage_plist,
    ["inductor", ["size", [8, 6, 4], "offsets", [2, 2]],
     "can_capacitors", [["d", 8, "h", 7, "base_h", 2,
                         "position", [-10, 4, 0]]],
     "smd_chip_specs", [[4, 3, 1.5, 0.8, [-1, -7, 0], [0, 0, 30]]]])]);
changed_fp = plist_get("component_footprints", changed_components);
assert(len(changed_fp) == 3);
assert(changed_fp[0][1] == [8, 6]);
assert(changed_fp[1][1] == [8, 8]);
assert(norm(changed_fp[2][1] - [3 * cos(30) + 4 * sin(30),
                               3 * sin(30) + 4 * cos(30)]) < 1e-6);
raised = step_down_enclosure_props(["lid", ["text_mode", "raised",
                                           "text_height", "25%"]]);
assert(abs(plist_get("lid_h", raised) - 3) < 1e-6);
assert(plist_get("size", raised) == s);
for (text = plist_get("texts", raised)) {
  assert(abs(plist_get("translation", text)[2] - 2.39) < 1e-6);
  assert(abs(plist_get("height", text) - 0.61) < 1e-6);
}
tall_text = step_down_enclosure_props(["lid", ["text_mode", "raised",
                                             "text_height", 4]]);
assert(abs(plist_get("size", tall_text)[2]
           - plist_get("body_size", p)[2] - 6.4) < 1e-6);
echo("PASS power-component windows and engraved/raised text dimensions");

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
