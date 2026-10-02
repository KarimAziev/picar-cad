/**
  * Module: Rear Wago distribution and removable converter supply harness.
  *
  * Native rear-chassis coordinates, Z=0 at the underside of the plate.
  * Holes and wires share datums; changing visibility never removes the holes.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../rc_params.scad>
use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/wire.scad>
use <../../lipo_pack_case/lid_equipment.scad>
use <../../lipo_pack_case/multi_lipo_pack_lid.scad>
use <../../panel_stack/fuse_panel.scad>
use <../../placeholders/crimp_terminals/ring_terminal.scad>
use <../../placeholders/step-down-voltage-d24vxf5.scad>
use <../../wago/wago_pair.scad>
use <rear_equipment.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_power_wiring_props
  ─────────────────────────────────────────────────────────────────────────────
  Resolve the fuse distribution leads, converter supply and service holes.
  **Parameters:**
  - `layout`: Resolved rear layout in native holder-row coordinates.
  - `config`: Harness plist: enabled, d, hole_d, terminal_clearance, converter_run,
    under_z and ring_terminal. black_holes adds adjacent return passages;
    hole_gap is their edge-to-edge separation. Defaults are in rc_params.scad.
  **Returns:** Routes and terminal/hole datums. Missing case, Wago pair, single fuse
  panel or single converter disables this harness. Unsupported clearances assert;
  the chassis is never enlarged. The positive Wago feed port stays reserved.
  The red supply uses the innermost fuse; the black return is deferred.
 */
function rear_power_wiring_props(layout, config=rear_power_wiring) =
  let (payload = plist_get("power_case", layout),
       panels = [for (p = plist_get("panels", layout, []))
           if (plist_get("type", p) == "fuse") p],
       converters = [for (p = plist_get("equipment", layout, []))
           if (plist_get("kind", p) == "step_down") p])
  !plist_get("enabled", config, true) || is_undef(payload)
      || len(panels) != 1 || len(converters) != 1
      ? ["enabled", false] :
  let (pl = plist_get("plist", payload),
       lid = multi_lipo_pack_lid_props(pl),
       equipment = lid_equipment_layout(plist_get("equipment", plist_get("lid", pl), []), lid),
       wagos = [for (m = equipment) if (plist_get("kind", m) == "wago_pair") m])
  len(wagos) != 1 ? ["enabled", false] :
  let (m = wagos[0],
       top = plist_get("mount_z", payload) + plist_get("mount_z", lid)
             + plist_get("roof_z", lid) + plist_get("t", lid),
       origin = plist_get("pos", payload) + [0, 0, top],
       angle = plist_get("rotation", m, 0),
       ports = [for (pt = wago_pair_wire_ports(plist_get("component", m), 1))
           origin + concat(plist_get("pos", m), [0]) + rotZ(pt, angle)],
       panel = panels[0],
       parent_t = plist_get("size", layout)[2],
       panel_origin = plist_get("pos", panel) + [0, 0, parent_t],
       ends = [for (side = [-1, 1])
           [for (pt = fuse_panel_wire_ports(side, plist_get("orientation", panel)))
               panel_origin + pt]],
       near = norm(ends[0][0] - ports[0]) < norm(ends[1][0] - ports[0]) ? 0 : 1,
       feeds = ends[near],
       outlets = ends[1 - near],
       board = converters[0],
       board_pos = plist_get("pos", board) + [0, 0, parent_t],
       board_angle = plist_get("rotation", board),
       input = [for (pt = step_down_input_ports(plist_get("component", board)))
           board_pos + rotZ(pt, board_angle)],
       outward = rotZ([-1, 0, 0], board_angle),
       ring = plist_get("ring_terminal", config),
       rp = ring_terminal_props(ring),
       ring_reach = plist_get("total_l", rp) - plist_get("od", rp) / 2,
       bore = input[0] + [0, 0, plist_get("t", rp) / 2],
       mouth = bore + outward * ring_reach,
       d = plist_get("d", config, 3.8),
       clearance = plist_get("terminal_clearance", config, 2),
       hole_d = max(plist_get("hole_d", config, 12),
                    max(plist_get("od", rp), plist_get("max_w", rp)) + 2 * clearance),
       // Use the innermost holder, leaving the outer deck voltmeter in place.
       source = outlets[len(outlets) - 1],
       entry = [source[0] + sign(source[0]) * d, source[1], 0],
       exit_pt = (input[0] + input[1]) / 2 + outward * plist_get("converter_run", config, 40),
       exit = [exit_pt[0], exit_pt[1], 0],
       hole_pitch = hole_d + plist_get("hole_gap", config, 3),
       black_holes = plist_get("black_holes", config, true)
           ? [entry + [0, hole_pitch, 0], exit + [hole_pitch, 0, 0]]
           : [],
       holes = concat([entry, exit], black_holes),
       under_z = plist_get("under_z", config, -8),
       dir = rotZ([0, 1, 0], angle),
       feed_paths = [for (i = [0:len(feeds) - 1])
           let (start = ports[i], end = feeds[i],
                outside = start + dir * (2 * d))
           rounded_wire_points([start, outside, end + dir * (2 * d), end],
                               trim=2 * d)],
       route = rounded_wire_points([source,
                 [entry[0], entry[1], source[2] - 8],
                 entry + [0, 0, parent_t + 7],
                 entry + [0, 0, under_z],
                 exit + [0, 0, under_z],
                 exit + [0, 0, mouth[2]],
                 mouth + outward * 6, mouth], trim=2 * d),
       obstacles = concat(rear_equipment_obstacles(layout),
                           [for (e = plist_get("equipment", layout, []))
                               plist_get("bounds", e)]))
  assert(plist_get("hole_gap", config, 3) >= 2,
         "Adjacent wiring holes need at least 2 mm of material between them")
  assert(len(ports) > len(feeds), "Reserve one positive Wago port for the switch")
  assert(under_z + d / 2 < -3, "Under-deck wiring must clear mounting screw heads")
  assert(plist_get("converter_run", config, 40) > ring_reach + hole_d / 2 + clearance,
         "Converter passage must leave room for the ring terminal and wire bend")
  assert(len([for (h = holes, b = obstacles)
      if (_deck_overlap(_deck_bounds(h, [hole_d, hole_d, 0]), b, clearance)) 1]) == 0,
      "Rear wiring hole overlaps hardware; adjust the equipment or harness")
  assert(len([for (h = holes)
      if (abs(h[0]) + hole_d / 2 + clearance > plist_get("join_w", layout) / 2
          || h[1] - hole_d / 2 < plist_get("min_y", layout) + clearance
          || h[1] + hole_d / 2 > plist_get("transition_y_end", layout) - clearance) 1]) == 0,
      "Rear wiring passages must fit the existing full-width deck")
  ["enabled", true, "holes", holes, "hole_d", hole_d, "parent_t", parent_t,
   "black_holes", black_holes,
   "d", d, "feeds", feed_paths, "converter_path", route,
   "ring_terminal", ring, "ring_bore", bore, "ring_mouth", mouth,
   "ring_rotation", board_angle + 90, "input_ports", input];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_power_harness
  ─────────────────────────────────────────────────────────────────────────────
  Render the rear harness and ring terminal, or its chassis passages.
  **Parameters:**
  - `layout`: Rear layout shared with the chassis plate.
  - `config`: Harness settings accepted by rear_power_wiring_props.
  - `slot_mode`: Emit through-hole cutters at Z=0; ignores show_wiring.
  - `show_wiring`: Display wires and the converter ring terminal.
 */
module rear_power_harness(layout,
                          config=rear_power_wiring,
                          slot_mode=false,
                          show_wiring=true) {
  p = rear_power_wiring_props(layout, config);
  if (plist_get("enabled", p, false)) {
    if (slot_mode) {
      for (h = plist_get("holes", p)) {
        translate(h - [0, 0, 0.1]) {
          cylinder(d=plist_get("hole_d", p),
                   h=plist_get("parent_t", p) + 0.2, $fn=64);
        }
      }
    } else if (show_wiring) {
      for (path = concat(plist_get("feeds", p), [plist_get("converter_path", p)])) {
        wire_path(path, d=plist_get("d", p), colr="#d92727", mode="none", cut_len=undef);
      }
      translate(plist_get("ring_mouth", p)) {
        rotate([0, 0, plist_get("ring_rotation", p)]) {
          rotate([90, 0, 0]) {
            ring_terminal(plist_get("ring_terminal", p));
          }
        }
      }
    }
  }
}
