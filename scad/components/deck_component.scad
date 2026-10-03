/**
  * Module: Surface-mounted electronics and their shared parent cutters.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../lib/plist.scad>
use <../lib/transforms.scad>
use <../placeholders/perf_board.scad>
use <../placeholders/step-down-voltage-d24vxf5.scad>
use <../placeholders/voltmeter.scad>

function _deck_component_props(kind, pl=[]) =
  kind == "voltmeter" ? voltmeter_mount_props(pl) :
  kind == "step_down" ? step_down_mount_props(pl) :
  kind == "perf_board" ? perf_board_mount_props(pl) :
  assert(false, str("Unknown deck component kind: ", kind)) [];

/**
  ─────────────────────────────────────────────────────────────────────────────
  deck_component_props
  ─────────────────────────────────────────────────────────────────────────────
  Resolve a component's envelope and mounting interface.
  **Parameters:**
  - `kind`: voltmeter | step_down | perf_board.
  - `pl`: Hardware-specific plist, passed unchanged to its mounting interface.
  **Returns:** Component props including `size`, centered on XY above Z=0.
  Add future types here and in deck_component; placement needs no type branches.
 */
// Include underside screw heads even when the hardware's PCB ears are smaller.
function deck_component_props(kind, pl=[]) =
  let (p = _deck_component_props(kind, pl),
       s = plist_get("size", p),
       pitch = plist_get("bolt_spacing", p),
       d = plist_get("bolt_d", p),
       wire_d = plist_get("wire_d", pl, kind == "voltmeter" ? 4 : 0))
  assert(wire_d >= 0, "Wire passage diameter must be nonnegative")
  assert(wire_d == 0 || wire_d / 2 + d + 1 <= norm(pitch) / 2,
         "Center wire passage must leave material around mounting screws")
  plist_merge(p,
              ["size", [max(s[0], pitch[0] + 2 * d, wire_d),
                        max(s[1], pitch[1] + 2 * d, wire_d), s[2]]]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  deck_component
  ─────────────────────────────────────────────────────────────────────────────
  Render mounted electronics or the matching parent cutouts.
  **Parameters:**
  - `kind`: Registered component kind.
  - `pl`: Hardware-specific plist.
  - `parent_t`: Thickness below the Z=0 mounting plane.
  - `anchor`: Envelope anchor; XY-centered by default for assembly placement.
  - `slot_mode`: Cut mounting passages into the parent below Z=0.
  - `show_hardware`: Display component and its mounting hardware in solid mode.
 */
module deck_component(kind,
                      pl=[],
                      parent_t=3,
                      anchor=[0, 0, 1],
                      slot_mode=false,
                      show_hardware=true) {
  props = deck_component_props(kind, pl);
  with_anchor(anchor, plist_get("size", props), centered=true) {
    if (kind == "voltmeter") {
      voltmeter_mount(pl, parent_t, [0, 0, 1], slot_mode, show_hardware);
    } else if (kind == "step_down") {
      step_down_mount(pl, parent_t, [0, 0, 1], slot_mode, show_hardware);
    } else if (kind == "perf_board") {
      perf_board_mount(pl, parent_t, [0, 0, 1], slot_mode, show_hardware);
    }
  }
}
