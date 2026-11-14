/**
  * Module: Explicit hardware preset customization assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/placeholders/presets.scad>

use <../scad/lib/plist.scad>
use <../scad/placeholders/battery_holder/util.scad>
use <../scad/placeholders/pcb/pcb_button.scad>
use <../scad/placeholders/pcb/pci_connector.scad>
use <../scad/placeholders/rc_touring_wheel.scad>
use <../scad/placeholders/step-down-voltage-d24vxf5.scad>
use <../scad/placeholders/wago/wago_221.scad>

wheel          = plist_merge(rc_touring_wheel_plist, ["tire_d", 70,
                                                      "width", 28]);
assert(rc_touring_wheel_size(wheel) == [70, 70, 28]);
assert(rc_touring_wheel_size() == rc_touring_wheel_size(rc_touring_wheel_plist));

button         = plist_merge(pcb_button_plist,
                     ["size", [6, 4, 2],
                      "orientation", "lwh"]);
assert(pcb_button_size_from_plist(button) == [4, 6, 2]);
assert(pcb_button_size_from_plist(button, "wlh") == [6, 4, 2]);

connector      = plist_merge(pci_connector_plist, ["size", [20, 3, 4]]);
assert(pci_connector_oriented_size(connector) == [3, 20, 4]);
assert(pci_connector_oriented_size(connector, "wlh") == [20, 3, 4]);

board_size     = plist_get("placeholder_size", step_down_voltage_plist);
terminal       = plist_merge(plist_get("vin", step_down_voltage_plist),
                       ["base_w", 13,
                        "rotation_z", 0]);
regulator      = plist_merge(step_down_voltage_plist, ["vin", terminal]);
terminal_props = step_down_terminal_props(plist_get("vin", regulator),
                                          board_size,
                                          input=true);
assert(plist_get("size", terminal_props)[0] == 13);
assert(plist_get("rotation", terminal_props) == 0);

holder         = battery_holder_full_size_from_plist(battery_holder_plist);
more_cells     = battery_holder_full_size_from_plist(plist_merge(battery_holder_plist, ["count", 3]));
assert(more_cells[0] > holder[0] && more_cells[1] == holder[1]);

wago           = plist_merge(wago_plist, ["n", 3,
                                          "total_w", undef]);
ports          = wago_wire_ports(wago);
assert(len(ports) == 3 && ports[1][0] == 0);
assert(ports[0][1] == ports[2][1] && ports[0][0] == -ports[2][0]);

echo("PASS: named hardware presets propagate component and nested overrides");
