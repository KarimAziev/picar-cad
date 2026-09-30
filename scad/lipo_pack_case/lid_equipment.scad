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
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/voltmeter.scad>
use <../wago/wago_bracket.scad>
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
         if (abs(x) > size[0] / 2 || abs(y) > size[1] / 2
             || norm([max(0, abs(x) - size[0] / 2 + r),
                      max(0, abs(y) - size[1] / 2 + r)]) > r + 0.000001) 1]) == 0;

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_equipment_props
  ─────────────────────────────────────────────────────────────────────────────
  Return rotated equipment bounds and shared mounting information.
  **Parameters:**
  - `spec`: `kind` is "button", "wago" or "voltmeter"; `component` holds
    that component's plist. `rotation` rotates its local frame about Z.
  **Returns:**
  `bounds` includes installed hardware; `roof_bounds` includes mounting and
  wire openings. The switch lever alone may extend past the roof edge.
 */
function lid_equipment_props(spec) =
  let (kind = plist_get("kind", spec),
       pl = plist_get("component", spec, []),
       a = plist_get("rotation", spec, 0))
  assert(kind == "button" || kind == "wago" || kind == "voltmeter",
         str("Unknown lid equipment: ", kind))
  assert(is_num(a), "Equipment rotation must be numeric")
  let (p = kind == "button" ? button_bracket_props(pl)
           : kind == "wago" ? wago_bracket_props(pl) : voltmeter_mount_props(pl),
       size = plist_get("size", p),
       b = kind == "button" ? plist_get("bounds", p)
           : _wago_bounds([0, 0, 0], size),
       roof = kind == "button"
           ? [[b[0][0], b[0][1], 0], [b[1][0], size[1] / 2, size[2]]] : b,
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
       holes = kind == "button" ? plist_get("mount_holes", props)
           : kind == "wago" ? [for (xy = plist_get("mount_holes", props))
                                  xy - [size[0] / 2, size[1] / 2]]
           : [for (x = [-1, 1], y = [-1, 1])
                 [x * plist_get("bolt_spacing", props)[0] / 2,
                  y * plist_get("bolt_spacing", props)[1] / 2]],
       d = kind == "button" ? plist_get("bore_d", pl, 6.4)
           : kind == "wago" ? find_bolt_head_d(plist_get("bolt_d", props), "countersunk") + 0.3
           : plist_get("bolt_d", props) * 2,
       wire_d = plist_get("wire_d", kind == "wago" ? p : pl, 4),
       wire_pos = kind == "button" ? plist_get("wire_pos", props)
           : kind == "wago" ? _lid_wago_wire(props) : [0, 0],
       wire_size = kind == "button" ? concat(plist_get("wire_size", props), [0])
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
           ? [for (y = ys) [mode == "left" ? lo[0] : hi[0], y]]
           : mode == "front" || mode == "rear"
           ? [for (x = xs) [x, mode == "front" ? hi[1] : lo[1]]]
           : [for (x = xs, y = ys) [x, y]],
       fits = [for (xy = candidates)
           if (_lid_roof_contains(_lid_move_bounds(roof, xy, gap), size,
                                  plist_get("corner_r", lid))
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

function _lid_equipment_layout(specs, lid, obstacles, i=0, placed=[]) =
  i >= len(specs) ? placed :
  let (spec = specs[i],
       count = plist_get("count", spec, 1),
       p = _lid_equipment_place(spec, lid, obstacles))
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
  _lid_equipment_layout([for (s = specs) if (plist_get("enabled", s, true)) s],
                          lid, concat(obstacles, sensor_boxes));

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
          translate(concat(_lid_wago_wire(p), [-parent_t])) {
            cylinder(d=plist_get("wire_d", m, 4), h=parent_t + 0.1, $fn=32);
          }
        } else {
          wago_bracket(pl, anchor=[0, 0, 1], show_wago=show_hardware);
        }
      }
    }
  }
}
