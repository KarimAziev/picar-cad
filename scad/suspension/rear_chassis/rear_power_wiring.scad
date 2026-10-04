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
use <../../lib/shapes2d.scad>
use <../../lib/wire.scad>
use <../../lipo_pack_case/lid_equipment.scad>
use <../../lipo_pack_case/multi_lipo_pack_lid.scad>
use <../../panel_stack/fuse_panel.scad>
use <../../placeholders/crimp_terminals/ring_terminal.scad>
use <../../placeholders/step-down-voltage-d24vxf5.scad>
use <../../wago/wago_pair.scad>
use <../front_chassis/front_chassis_joint.scad>
use <rear_equipment.scad>

function _rear_wire_opening_fits(pos, size, layout, obstacles, gap) =
  abs(pos[0]) + size[0] / 2 + gap <= plist_get("join_w", layout) / 2
  && pos[1] - size[1] / 2 >= plist_get("min_y", layout) + gap
  && pos[1] + size[1] / 2 <= plist_get("transition_y_end", layout) - gap
  && len([for (b = obstacles)
      if (_deck_overlap(_deck_bounds(pos, size), b, gap)) 1]) == 0;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_fuse_wire_passages
  ─────────────────────────────────────────────────────────────────────────────
  Size chassis wire passages on either side of the fuse panel.
  **Parameters:**
  - `layout`: Rear layout in native holder-row coordinates.
  - `panel`: Resolved fuse panel from the layout.
  - `holes`: Converter passage centers; the first is beside the fuse outlets.
  - `hole_d`: Shared round passage diameter in millimeters.
  - `obstacles`: Occupied hardware footprints in chassis coordinates.
  - `config`: Harness settings. fuse_hole_columns is 0, 1 or 2; two columns
    fall back to one if space is limited. fuse_outlet enables the RPi passage.
    hole_gap separates round holes; terminal_clearance preserves solid lands.
    fuse_outlet_edge_margin reserves material along the chassis side (12 mm).
  **Returns:** A plist with round `holes`, `outlet_pos`, `outlet_size` and
  `outlet_r`. The outlet sits toward native -Y (vehicle front), outside the
  chassis joint's reinforcing pin. Disabled outlets have size [0, 0, 0].
 */
function rear_fuse_wire_passages(layout,
                                 panel,
                                 holes,
                                 hole_d,
                                 obstacles,
                                 config=rear_power_wiring) =
  let (columns = plist_get("fuse_hole_columns", config, 2),
       gap = plist_get("terminal_clearance", config, 2),
       edge_margin = plist_get("fuse_outlet_edge_margin", config, 12),
       pitch = hole_d + plist_get("hole_gap", config, 3),
       side = sign(plist_get("pos", panel)[0]),
       candidates = [for (column = [1:1:columns])
           [for (row = [0, 1])
               holes[0] + [side * column * pitch, row * pitch, 0]]],
       round_obstacles = concat(obstacles,
                                 [for (h = holes)
                                     _deck_bounds(h, [hole_d, hole_d, 0])]),
       fits = [for (pair = candidates)
           len([for (h = pair)
               if (!_rear_wire_opening_fits(h, [hole_d, hole_d, 0], layout,
                                            round_obstacles, gap)) 1]) == 0],
       count = columns == 0
           ? 0
           : columns == 2 && fits[0] && fits[1]
             ? 2
             : fits[0] ? 1 : 0,
       bounds = plist_get("bounds", panel),
       pin_spacing = front_chassis_body_joint_pin_spacing(plist_get("join_w", layout)),
       inner_x = pin_spacing / 2 + front_chassis_joint_pin_d / 2 + gap,
       outer_x = plist_get("join_w", layout) / 2 - edge_margin,
       y0 = plist_get("min_y", layout) + gap,
       y1 = bounds[0][1] - gap,
       outlet = plist_get("fuse_outlet", config, true),
       outlet_size = outlet
           ? [outer_x - inner_x, y1 - y0, 0]
           : [0, 0, 0],
       outlet_pos = [side * (inner_x + outer_x) / 2, (y0 + y1) / 2, 0])
  assert(columns == 0 || columns == 1 || columns == 2,
         "Fuse wire passages need zero, one or two columns")
  assert(gap >= 2, "Fuse wire passages need at least 2 mm of solid land")
  assert(edge_margin >= gap,
         "Fuse outlet edge margin must cover the terminal clearance")
  assert(columns == 0 || count > 0,
         "Two fuse wire holes do not fit the existing chassis")
  assert(!outlet || (min(outlet_size[0], outlet_size[1]) >= gap * 2
                    && _rear_wire_opening_fits(outlet_pos, outlet_size,
                                               layout, obstacles, gap)),
         "Fuse outlet does not fit between the panel, joint pin and chassis edge")
  ["holes", [for (i = [0:1:count - 1]) each candidates[i]],
   "outlet_pos", outlet_pos,
   "outlet_size", outlet_size,
   "outlet_r", min(3, min(outlet_size[0], outlet_size[1]) / 2)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_power_wiring_props
  ─────────────────────────────────────────────────────────────────────────────
  Resolve the fuse distribution leads, converter supply and service holes.
  **Parameters:**
  - `layout`: Resolved rear layout in native holder-row coordinates.
  - `config`: Harness plist: enabled, d, hole_d, terminal_clearance, converter_run,
    under_z and ring_terminal. black_holes adds adjacent return passages;
    hole_gap is their edge-to-edge separation. fuse_hole_columns and fuse_outlet
    configure rear_fuse_wire_passages. Defaults are in rc_params.scad.
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
                              plist_get("bounds", e)]),
       fuse_passages = rear_fuse_wire_passages(layout, panel, holes, hole_d,
                                               obstacles, config))
                              assert(plist_get("hole_gap", config, 3) >= 2,
                                     "Adjacent wiring holes need at least 2 mm of material between them")
                              assert(len(ports) > len(feeds),
                                     "Reserve one positive Wago port for the switch")
                              assert(under_z + d / 2 < -3,
                                     "Under-deck wiring must clear mounting screw heads")
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
                              ["enabled", true,
                               "holes", holes,
                               "fuse_passages", fuse_passages,
                               "hole_d", hole_d,
                               "parent_t", parent_t,
                               "black_holes", black_holes,
                               "d", d,
                               "feeds", feed_paths,
                               "converter_path", route,
                               "ring_terminal", ring,
                               "ring_bore", bore,
                               "ring_mouth", mouth,
                               "ring_rotation", board_angle + 90,
                               "input_ports", input];

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
      passages = plist_get("fuse_passages", p);
      for (h = concat(plist_get("holes", p), plist_get("holes", passages))) {
        translate(h - [0, 0, 0.1]) {
          cylinder(d=plist_get("hole_d", p),
                   h=plist_get("parent_t", p) + 0.2,
                   $fn=64);
        }
      }
      outlet_size = plist_get("outlet_size", passages);
      if (outlet_size[0] > 0 && outlet_size[1] > 0) {
        translate(plist_get("outlet_pos", passages) - [0, 0, 0.1]) {
          linear_extrude(height=plist_get("parent_t", p) + 0.2) {
            rounded_rect([outlet_size[0], outlet_size[1]],
                          r=plist_get("outlet_r", passages),
                          center=true,
                          fn=64);
          }
        }
      }
    } else if (show_wiring) {
      for (path = concat(plist_get("feeds", p), [plist_get("converter_path", p)])) {
        wire_path(path,
                  d=plist_get("d", p),
                  colr="#d92727",
                  mode="none",
                  cut_len=undef);
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
