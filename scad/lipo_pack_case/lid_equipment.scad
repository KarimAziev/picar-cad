/**
  * Module: Geometric equipment layout for the standalone power-case lid.
  *
  * Roof-center XY coordinates; the exterior roof surface is Z=0.
  * Switch levers may overhang an edge; all mounting and wiring lands stay on it.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../components/button_bracket/button_bracket.scad>
use <../lib/plist.scad>
use <../lib/functions.scad>
use <../lib/slots.scad>
use <../placeholders/bolt.scad>
use <../placeholders/voltmeter.scad>
use <../wago/wago_bracket.scad>
use <../wago/wago_pair.scad>
use <../wago/wago_mounts.scad>

// Rear-ear brackets leave a free wiring land between the mounting ears.
// Side-ear brackets leave a free land ahead of either ear.
function _lid_wago_wire(p) =
  let (s = plist_get("size", p), e = plist_get("ear_d", p))
  plist_get("mount_side", p) == "rear" ? [0, s[1] / 2 - e / 2]
  : [s[0] / 2 - e / 2, -s[1] / 2 + 2];

function _lid_rotate(p, a) =
  [p[0] * cos(a) - p[1] * sin(a), p[0] * sin(a) + p[1] * cos(a)];

function _lid_rotate_bounds(b, a) =
  let (pts = [for (x = [b[0][0], b[1][0]], y = [b[0][1], b[1][1]])
                _lid_rotate([x, y], a)])
  [[min([for (p = pts) p[0]]), min([for (p = pts) p[1]]), b[0][2]],
   [max([for (p = pts) p[0]]), max([for (p = pts) p[1]]), b[1][2]]];

function _lid_union_bounds(boxes) =
  [[for (i = [0:2]) min([for (b = boxes) b[0][i]])],
   [for (i = [0:2]) max([for (b = boxes) b[1][i]])]];

function _lid_move_bounds(b, p, gap=0) =
  [b[0] + [p[0] - gap, p[1] - gap, 0],
   b[1] + [p[0] + gap, p[1] + gap, 0]];

function _lid_roof_contains(b, size, r) =
  len([for (x = [b[0][0], b[1][0]], y = [b[0][1], b[1][1]])
         if (abs(x) > size[0] / 2 + 0.000001 || abs(y) > size[1] / 2 + 0.000001
             || norm([max(0, abs(x) - size[0] / 2 + r),
                      max(0, abs(y) - size[1] / 2 + r)]) > r + 0.000001) 1]) == 0;

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_equipment_props
  ─────────────────────────────────────────────────────────────────────────────
  Return rotated equipment bounds and shared mounting information.
  **Parameters:**
  - `spec`: `kind` is "button", "wago", "wago_pair" or "voltmeter"; `component` holds
    that component's plist. `rotation` rotates its local frame about Z.
  **Returns:**
  `bounds` includes installed hardware; `roof_bounds` includes mounting and
  wire openings. Switch levers and a Wago pair's explicitly allowed cradle
  overhang may extend past the roof edge; their full bounds exclude neighbors.
 */
function lid_equipment_props(spec) =
  let (kind = plist_get("kind", spec),
       pl = plist_get("component", spec, []),
       a = plist_get("rotation", spec, 0))
  assert(kind == "button" || kind == "wago" || kind == "wago_pair"
         || kind == "voltmeter",
         str("Unknown lid equipment: ", kind))
  assert(is_num(a), "Equipment rotation must be numeric")
  let (p = kind == "button" ? button_bracket_props(pl)
           : kind == "wago" ? wago_bracket_props(pl)
           : kind == "wago_pair" ? wago_pair_props(pl) : voltmeter_mount_props(pl),
       size = plist_get("size", p),
       b = kind == "button" ? plist_get("bounds", p)
           : _wago_bounds([0, 0, 0], size),
       roof = kind == "button"
           ? [[b[0][0], b[0][1], 0], [b[1][0], size[1] / 2, size[2]]]
           : kind == "wago_pair" ? plist_get("roof_bounds", p) : b,
       result = plist_merge(spec, ["bounds", _lid_rotate_bounds(b, a),
                                   "roof_bounds", _lid_rotate_bounds(roof, a),
                                   "props", p]),
       cuts = _lid_equipment_cuts(result))
  plist_merge(result,
    ["roof_bounds", _lid_union_bounds(concat([plist_get("roof_bounds", result)], cuts)),
     "bounds", _lid_union_bounds(concat([plist_get("bounds", result)], cuts))]);

// Parent cutters must retain tool access between the two rail skirts.
function _lid_equipment_cuts(p) =
  let (kind = plist_get("kind", p),
       props = plist_get("props", p),
       size = plist_get("size", props),
       pl = plist_get("component", p, []),
       holes = kind == "button" || kind == "wago_pair"
           ? plist_get("mount_holes", props)
           : kind == "wago" ? [for (xy = plist_get("mount_holes", props))
                                  xy - [size[0] / 2, size[1] / 2]]
           : [for (x = [-1, 1], y = [-1, 1])
                 [x * plist_get("bolt_spacing", props)[0] / 2,
                  y * plist_get("bolt_spacing", props)[1] / 2]],
       d = kind == "button" ? plist_get("bore_d", pl, 6.4)
           : kind == "wago_pair" ? plist_get("bore_d", props)
           : kind == "wago" ? find_bolt_head_d(plist_get("bolt_d", props), "countersunk") + 0.3
           : plist_get("bolt_d", props) * 2,
       wire_d = plist_get("wire_d", kind == "wago" ? p : pl, 4),
       wire_pos = kind == "button" ? plist_get("wire_pos", props)
           : kind == "wago" ? _lid_wago_wire(props) : [0, 0],
       wire_size = kind == "button" || kind == "wago_pair"
           ? concat(plist_get("wire_size", props), [0])
           : [wire_d, wire_d, 0],
       cuts = concat([for (xy = holes) _wago_bounds(concat(xy, [0]), [d, d, 0])],
                     [_wago_bounds(concat(wire_pos, [0]), wire_size)]))
  [for (b = cuts) _lid_rotate_bounds(b, plist_get("rotation", p, 0))];

function _lid_access_limits(lid) =
  let (rails = plist_get("rail_props", lid),
       body = plist_get("body_size", plist_get("case_props", lid)),
       cross = plist_get("axis", rails) == "x" ? 1 : 0,
       inner = [for (i = [0:1])
           let (r = plist_get("rails", rails)[i])
           plist_get("cross", r) - body[cross] / 2
           + (i == 0 ? 1 : -1) * plist_get("locking_depth", r) / 2])
  [cross, inner[0] + 0.8, inner[1] - 0.8];

function _lid_cut_access(cuts, pos, lid) =
  let (limits = _lid_access_limits(lid), cross = limits[0])
  len([for (b = cuts)
         if (b[0][cross] + pos[cross] < limits[1] - 0.000001
             || b[1][cross] + pos[cross] > limits[2] + 0.000001) 1]) == 0;

// Available edge at both corners of a rectangular footprint on a rounded roof.
function _lid_edge_limit(cross_min, cross_max, span, cross_span, r) =
  let (d = max(0, max(abs(cross_min), abs(cross_max)) - cross_span / 2 + r))
  span / 2 - r + sqrt(max(0, r * r - d * d));

function _lid_equipment_roof_contains(p, pos, lid, gap) =
  let (size = plist_get("canonical_size", lid),
       r = plist_get("corner_r", lid),
       angle = plist_get("rotation", p, 0))
  plist_get("kind", p) != "button"
      ? _lid_roof_contains(_lid_move_bounds(plist_get("roof_bounds", p), pos, gap), size, r)
      : len([for (v = plist_get("footprint", plist_get("props", p)))
                 let (point = concat(_lid_rotate(v, angle), [0]))
                 if (!_lid_roof_contains(_lid_move_bounds([point, point], pos, gap), size, r)) 1]) == 0
      && len([for (cut = _lid_equipment_cuts(p))
                 if (!_lid_roof_contains(_lid_move_bounds(cut, pos, gap), size, r)) 1]) == 0;

function _lid_equipment_place(spec, lid, obstacles) =
  let (p = lid_equipment_props(spec),
       b = plist_get("bounds", p),
       roof = plist_get("roof_bounds", p),
       size = plist_get("canonical_size", lid),
       gap = plist_get("gap", spec, 1),
       cuts = _lid_equipment_cuts(p),
       cut_bounds = _lid_union_bounds(cuts),
       limits = _lid_access_limits(lid),
       r = plist_get("corner_r", lid),
       mode = plist_get("placement", spec, "auto"),
       pos = plist_get("pos", spec),
       lo = [for (i = [0:1]) max(-size[i] / 2 - roof[0][i] + gap,
                                  i == limits[0] ? limits[1] - cut_bounds[0][i] : -size[i])],
       hi = [for (i = [0:1]) min(size[i] / 2 - roof[1][i] - gap,
                                  i == limits[0] ? limits[2] - cut_bounds[1][i] : size[i])],
       xs = concat([max(lo[0], min(0, hi[0])), lo[0], hi[0], lo[0] + r, hi[0] - r],
                   [for (o = obstacles) each [o[0][0] - b[1][0] - gap,
                                               o[1][0] - b[0][0] + gap]]),
       ys = concat([max(lo[1], min(0, hi[1])), lo[1], hi[1], lo[1] + r, hi[1] - r],
                   [for (o = obstacles) each [o[0][1] - b[1][1] - gap,
                                               o[1][1] - b[0][1] + gap]]),
       candidates = !is_undef(pos) ? [pos]
           : mode == "left" || mode == "right"
           ? [for (y = ys)
                let (edge = _lid_edge_limit(y + roof[0][1] - gap,
                                           y + roof[1][1] + gap, size[0], size[1], r))
                [mode == "left" ? max(lo[0], -edge - roof[0][0] + gap)
                 : min(hi[0], edge - roof[1][0] - gap), y]]
           : mode == "front" || mode == "rear"
           ? [for (x = xs)
                let (edge = _lid_edge_limit(x + roof[0][0] - gap,
                                           x + roof[1][0] + gap, size[1], size[0], r))
                [x, mode == "front" ? min(hi[1], edge - roof[1][1] - gap)
                 : max(lo[1], -edge - roof[0][1] + gap)]]
           : [for (x = xs, y = ys) [x, y]],
       fits = [for (xy = candidates)
           if (_lid_equipment_roof_contains(p, xy, lid, gap)
               && _lid_cut_access(cuts, xy, lid)
               && _wago_clear(_lid_move_bounds(b, xy, gap), obstacles)) xy])
  assert(is_num(gap) && gap >= 0, "Equipment gap must be nonnegative")
  assert(mode == "auto" || mode == "left" || mode == "right"
         || mode == "front" || mode == "rear", "Invalid equipment placement")
  assert(is_undef(pos) || (is_list(pos) && len(pos) == 2
                          && is_num(pos[0]) && is_num(pos[1])),
         "Equipment pos must be a numeric roof-center XY vector")
  assert(len(fits) > 0 || plist_get("count", spec, 1) == "fit", str("No room for lid ", plist_get("kind", spec),
                            " at ", mode, "; change placement, rotation or equipment"))
  len(fits) == 0 ? undef :
  plist_merge(p, ["pos", fits[0], "bounds", _lid_move_bounds(b, fits[0]),
                 "roof_bounds", _lid_move_bounds(roof, fits[0])]);

// Advance a switch toward its lever, retaining the original roof wire opening.
// Only axis-aligned lever directions across the rails are accepted.
function _lid_button_advance(m, lid, obstacles) =
  let (angle = plist_get("rotation", m, 0),
       dir = _lid_rotate([0, 1], angle),
       limits = _lid_access_limits(lid),
       cross = limits[0],
       sign = dir[cross],
       pos = plist_get("pos", m),
       p = plist_get("props", m),
       roof = plist_get("roof_bounds", m),
       size = plist_get("canonical_size", lid),
       gap = plist_get("gap", m, 1),
       cuts = _lid_equipment_cuts(m),
       mount_bounds = _lid_union_bounds([for (i = [0:len(cuts) - 2]) cuts[i]]),
       advance = max(0, min(
         sign > 0 ? limits[2] - pos[cross] - mount_bounds[1][cross]
                  : pos[cross] + mount_bounds[0][cross] - limits[1],
         sign > 0 ? size[cross] / 2 - gap - roof[1][cross]
                  : roof[0][cross] + size[cross] / 2 - gap)),
       component = plist_merge(plist_get("component", m),
         ["wire_pos", plist_get("wire_pos", p) - [0, advance]]),
       moved = lid_equipment_props(plist_merge(m, ["component", component])),
       xy = pos + dir * advance,
       b = _lid_move_bounds(plist_get("bounds", moved), xy),
       rb = _lid_move_bounds(plist_get("roof_bounds", moved), xy))
  assert(abs(abs(sign) - 1) < 0.000001,
         "advance_to_rail requires the switch lever perpendicular to the rails")
  assert(_lid_equipment_roof_contains(moved, xy, lid, gap)
         && _lid_cut_access(_lid_equipment_cuts(moved), xy, lid)
         && _wago_clear(_lid_move_bounds(plist_get("bounds", moved), xy, gap), obstacles),
         "Advanced switch overlaps equipment or the roof edge")
  plist_merge(moved, ["pos", xy, "bounds", b, "roof_bounds", rb,
                      "advance", advance]);

function _lid_equipment_layout(specs, lid, obstacles, i=0, placed=[]) =
  i >= len(specs) ? placed :
  let (spec = specs[i],
       count = plist_get("count", spec, 1),
       initial = _lid_equipment_place(spec, lid, obstacles),
       p = !is_undef(initial) && plist_get("kind", spec) == "button"
           && plist_get("advance_to_rail", spec, false)
           && is_undef(plist_get("pos", spec))
           ? _lid_button_advance(initial, lid, obstacles)
           : initial)
  assert(count == 1 || count == "fit", "Equipment count must be 1 or fit")
  is_undef(p) ? _lid_equipment_layout(specs, lid, obstacles, i + 1, placed)
  : _lid_equipment_layout(specs, lid,
                           concat(obstacles, [plist_get("bounds", p)]),
                           count == "fit" ? i : i + 1, concat(placed, [p]));

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_equipment_layout
  ─────────────────────────────────────────────────────────────────────────────
  Place enabled equipment without resizing the roof or moving the lidar.
  **Parameters:**
  - `specs`: Ordered equipment plists. Optional `enabled=false` omits one.
    `placement` is auto/left/right/front/rear in canonical lid axes; `pos`
    overrides automatic placement. `gap` defaults to 1 mm edge-to-edge.
    `count="fit"` fills remaining space, stopping when no further copy fits.
    Buttons may set `advance_to_rail=true` to advance toward the lever until
    the roof margin or rail tool clearance limits travel, preserving their
    original wiring opening. Explicit `pos` bypasses that automatic advance.
  - `lid`: Resolved lid properties.
  - `obstacles`: Additional roof XY exclusion boxes, such as legacy Wago mounts.
  **Returns:** Resolved equipment list, with component-frame XY `pos` values.
 */
function lid_equipment_layout(specs, lid, obstacles=[]) =
  assert(is_list(specs), "lid.equipment must be a list")
  let (sensor = plist_get("lidar", lid),
       adapter = plist_get("adapter_props", lid),
       sensor_size = is_undef(sensor) ? [0, 0, 0]
           : orientation_size(plist_get("lidar_orientation", lid),
                              concat(plist_get("size", sensor), [0])),
       plate_size = plist_get("size", adapter, [0, 0, 0]),
       occupied = [for (i = [0:2]) max(sensor_size[i], plate_size[i])],
       sensor_boxes = occupied[0] == 0 ? []
           : [_wago_bounds(concat(plist_get("lidar_offset", lid), [0]), occupied)])
  let (a = plist_get("power_rotation", lid, 0),
       local_obstacles = [for (b = concat(obstacles, sensor_boxes))
           _lid_rotate_bounds(b, -a)],
       placed = _lid_equipment_layout(
         [for (s = specs) if (plist_get("enabled", s, true)) s],
         lid, local_obstacles))
  [for (m = placed) plist_merge(m,
    ["pos", _lid_rotate(plist_get("pos", m), a),
     "rotation", plist_get("rotation", m, 0) + a,
     "bounds", _lid_rotate_bounds(plist_get("bounds", m), a),
     "roof_bounds", _lid_rotate_bounds(plist_get("roof_bounds", m), a)])];

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_equipment
  ─────────────────────────────────────────────────────────────────────────────
  Render resolved equipment or matching roof holes at the exterior surface.
  **Parameters:**
  - `mounts`: Result of lid_equipment_layout.
  - `parent_t`: Roof thickness below Z=0.
  - `slot_mode`: Emit mounting holes, underside countersinks and wire passages.
  - `show_hardware`: Display switches, connectors and meters.
 */
module lid_equipment(mounts, parent_t, slot_mode=false, show_hardware=true) {
  for (m = mounts) {
    kind = plist_get("kind", m);
    pl = plist_get("component", m, []);
    p = plist_get("props", m);
    translate(concat(plist_get("pos", m), [0])) {
      rotate([0, 0, plist_get("rotation", m, 0)]) {
        if (kind == "button") {
          button_bracket(pl, parent_thickness=parent_t,
                         slot_mode=slot_mode, show_button=show_hardware);
        } else if (kind == "wago_pair") {
          wago_pair(pl, parent_t=parent_t, slot_mode=slot_mode,
                     show_wago=show_hardware);
        } else if (kind == "voltmeter") {
          voltmeter_mount(pl, parent_t=parent_t, slot_mode=slot_mode,
                          show_hardware=show_hardware);
        } else if (slot_mode) {
          size = plist_get("size", p);
          d = plist_get("bolt_d", p);
          for (xy = plist_get("mount_holes", p)) {
            translate([xy[0] - size[0] / 2, xy[1] - size[1] / 2, -parent_t]) {
              counterbore(h=parent_t, d=plist_get("hole_d", p),
                          bore_d=find_bolt_head_d(d, "countersunk") + 0.3,
                          bore_h=find_bolt_head_h(d, "countersunk") + 0.15,
                          sink=true, reverse=true);
            }
          }
          // Accessible wire passage beside the connector cradle.
          translate(concat(_lid_wago_wire(p), [-parent_t - 0.01])) {
            cylinder(d=plist_get("wire_d", m, 4), h=parent_t + 0.02, $fn=32);
          }
        } else {
          wago_bracket(pl, anchor=[0, 0, 1], show_wago=show_hardware);
        }
      }
    }
  }
}

function _lid_voltmeter_cut_h(pl, props) =
  max(plist_get("bolt_spacing", props)[0] + 2 * plist_get("bolt_d", props),
      plist_get("wire_d", pl, 4));

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_voltmeter_headroom
  ─────────────────────────────────────────────────────────────────────────────
  Calculate minimum skirt headroom for the side displays and their mounting lands.
  **Parameters:**
  - `specs`: Meter plists accepted by lid_voltmeter_props; disabled entries
    contribute no height. Undef mounting height centers each meter above the rail.
  - `rails`: Resolved case rail properties.
  - `side_t`: Solid material above the rail channel, in mm.
  - `roof_t`: Roof thickness, in mm.
  **Returns:** Minimum rail-top headroom, keeping holes within the skirt and
  displays below roof equipment. Explicit mounting heights use channel-bottom Z.
 */
function lid_voltmeter_headroom(specs, rails, side_t, roof_t) =
  assert(is_list(specs), "lid.voltmeters must be a list")
  max(concat([side_t], [for (s = specs)
    if (!is_undef(s) && plist_get("enabled", s, true))
      let (pl = plist_get("component", s, []),
           p = voltmeter_mount_props(pl),
           cut_h = _lid_voltmeter_cut_h(pl, p),
           edge = plist_get("edge_pad", s, 1.5),
           display_h = plist_get("size", p)[0],
           z = plist_get("pos", s, [0, undef])[1],
           rail_top = plist_get("h", rails) + plist_get("clearance", rails))
      is_undef(z)
          ? side_t + max(cut_h + 2 * edge, display_h - 2 * roof_t)
          : max(z + cut_h / 2 + edge, z + display_h / 2 - roof_t) - rail_top]));

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_voltmeter_props
  ─────────────────────────────────────────────────────────────────────────────
  Resolve a horizontal display on the exterior of the positive rail skirt.
  **Parameters:**
  - `spec`: Undef or `enabled=false` disables the meter. `component` is its
    hardware plist; `pos` is [along, height] from the lid center/channel bottom.
    Along is +X for X rails and -Y for Y rails. Undef height centers the holes
    above the channel. `edge_pad` (default 1.5) preserves material around cuts.
    Meter standoffs also clear the roof overhang and PCB pins by at least 0.5 mm.
  - `lid`: Resolved lid properties. The display faces +Y for X rails, +X for Y.
  **Returns:** Hardware properties, wall thickness, mounting position and the
  solid vent-exclusion width. The roof and case dimensions are unchanged.
 */
function lid_voltmeter_props(spec, lid) =
  is_undef(spec) || !plist_get("enabled", spec, true) ? ["enabled", false] :
  let (input = plist_get("component", spec, []),
       hardware = voltmeter_mount_props(input),
       rails = plist_get("rail_props", lid),
       axis = plist_get("axis", rails),
       cross = axis == "x" ? 1 : 0,
       slide = 1 - cross,
       rail = plist_get("rails", rails)[1],
       depth = plist_get("locking_depth", rail),
       body = plist_get("body_size", plist_get("case_props", lid)),
       outer = plist_get("cross", rail) - body[cross] / 2 + depth / 2,
       roof = plist_get("canonical_size", lid),
       pl = plist_merge(input,
         ["standoff_body_h", max(plist_get("standoff_body_h", input, 0),
                                 roof[cross] / 2 - outer
                                 + plist_get("pin_h", hardware) + 0.5)]),
       p = voltmeter_mount_props(pl),
       size = plist_get("size", p),
       bottom = plist_get("h", rails) + plist_get("clearance", rails)
       + plist_get("side_t", lid),
       top = plist_get("roof_z", lid),
       requested = plist_get("pos", spec, [0, undef]),
       pos = [requested[0], with_default(requested[1], (bottom + top) / 2)],
       edge = plist_get("edge_pad", spec, 1.5),
       pitch = plist_get("bolt_spacing", p),
       cut_h = _lid_voltmeter_cut_h(pl, p),
       width = max(size[1], pitch[1] + 2 * plist_get("bolt_d", p)) + 2 * edge)
  assert(is_num(pos[0]) && is_num(pos[1]) && edge >= 0,
         "Lid voltmeter pos must contain numeric along/height or undef height")
  assert(pos[1] - cut_h / 2 - edge >= bottom - 0.000001
         && pos[1] + cut_h / 2 + edge <= top + 0.000001,
         "Voltmeter holes need solid material above the channel and below the roof")
  assert(abs(pos[0]) + width / 2 <= roof[slide] / 2 - plist_get("corner_r", lid),
         "Voltmeter mounting land must clear the rounded skirt ends")
  assert(pos[1] + size[0] / 2 <= roof[2],
         "Voltmeter must stay below the roof equipment")
  plist_merge(spec, ["enabled", true, "component", pl, "props", p,
                     "pos", pos, "outer", outer, "parent_t", depth,
                     "axis", axis, "width", width]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_voltmeter_layout
  ─────────────────────────────────────────────────────────────────────────────
  Resolve side meters and keep their solid mounting lands separate.
  **Parameters:**
  - `specs`: List of meter plists accepted by lid_voltmeter_props. Disabled
    entries are omitted. Each enabled meter reserves a full-height vent strip.
  - `lid`: Resolved lid properties.
  **Returns:** Validated list of enabled meter properties.
 */
function lid_voltmeter_layout(specs, lid) =
  assert(is_list(specs), "lid.voltmeters must be a list")
  let (meters = [for (s = specs)
                   let (p = lid_voltmeter_props(s, lid))
                   if (plist_get("enabled", p, false)) p])
  assert(len([for (i = [0:1:len(meters) - 1], j = [0:1:i - 1])
                if (abs(plist_get("pos", meters[i])[0]
                        - plist_get("pos", meters[j])[0])
                    < (plist_get("width", meters[i])
                       + plist_get("width", meters[j])) / 2) 1]) == 0,
         "Side voltmeter mounting lands overlap; separate their positions")
  meters;

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_voltmeter
  ─────────────────────────────────────────────────────────────────────────────
  Render the side meter, matching holes, or its solid ventilation land.
  **Parameters:**
  - `props`: Result of lid_voltmeter_props; coordinates use the lid center XY
    and channel-bottom Z, before the case's final orientation and anchor.
  - `slot_mode`: Emit wall mounting countersinks and a central wiring passage.
  - `reserve_mode`: Emit the wall region to exclude from ventilation cuts.
 */
module lid_voltmeter(props, slot_mode=false, reserve_mode=false) {
  if (plist_get("enabled", props, false)) {
    pos = plist_get("pos", props);
    depth = plist_get("parent_t", props);
    rotate([0, 0, plist_get("axis", props) == "x" ? 0 : -90]) {
      translate([pos[0], plist_get("outer", props), pos[1]]) {
        if (reserve_mode) {
          translate([0, -depth / 2, 0]) {
            cube([plist_get("width", props), depth + 0.4, 2 * pos[1] + 1],
                 center=true);
          }
        } else {
          rotate([-90, -90, 0]) {
            voltmeter_mount(plist_get("component", props),
                            parent_t=depth, slot_mode=slot_mode);
          }
        }
      }
    }
  }
}
