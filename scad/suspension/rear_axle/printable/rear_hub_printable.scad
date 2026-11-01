/**
  * Module: Printable rear hub, socket plugs and ball-seat bushings.
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../arm_hub_params.scad>
use <../../../lib/plist.scad>
use <../rear_hub.scad>

size = rear_hub_size(rear_hub_spec);
gap = plist_get("print_part_gap", rear_hub_spec);
plug_d = plist_get("socket_plug_d", rear_hub_spec);
bushing_d = plist_get("bushing_d", rear_hub_spec);

// Put the inboard face on the bed so bearing and socket axes print vertically.
translate([size[2], 0, 0]) {
  rotate([0, -90, 0]) {
    rear_hub(pl=rear_hub_spec,
              anchor=[1, 1, 1],
              slot_mode=false,
              show_bearings=false,
              show_socket_hardware=false);
  }
}
for (i = [0, 1]) {
  translate([size[2] + gap + plug_d / 2,
             gap + plug_d / 2 + i * (plug_d + gap), 0]) {
    rear_hub_socket_plug(rear_hub_spec);
  }
  translate([size[2] + 2 * gap + plug_d + bushing_d / 2,
             bushing_d / 2 + i * (bushing_d + gap), 0]) {
    rear_hub_socket_bushing(rear_hub_spec);
  }
}
