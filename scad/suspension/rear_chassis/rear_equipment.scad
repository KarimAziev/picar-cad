/**
  * Module: Fixed-deck equipment zones, placement and matching mounting slots.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../../components/deck_component.scad>
use <../../lib/functions.scad>
use <../../lib/plist.scad>

function _deck_overlap(a, b, gap=0) =
  a[0][0] < b[1][0] + gap - 0.000001
  && a[1][0] > b[0][0] - gap + 0.000001
  && a[0][1] < b[1][1] + gap - 0.000001
  && a[1][1] > b[0][1] - gap + 0.000001;

function _deck_bounds(pos, size) =
  [pos - [size[0] / 2, size[1] / 2, 0],
   pos + [size[0] / 2, size[1] / 2, size[2]]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_equipment_zones
  ─────────────────────────────────────────────────────────────────────────────
  Derive two side corridors from the existing full-width deck and motor bounds.
  **Parameters:**
  - `layout`: Rear layout before adding equipment; native holder-row coordinates.
  - `edge_margin`: Inset from the deck edge and start of its suspension taper.
  - `gap`: Clearance from the motor footprint.
  **Returns:** Zone plists with name and bounds. Left is -X, right is +X.
  Existing panels/supports remain obstacles within these corridors.
 */
function rear_equipment_zones(layout, edge_margin=3, gap=3) =
  assert(edge_margin >= 0 && gap >= 0, "Deck margins must be nonnegative")
  let (motor = plist_get("motor_bounds", layout),
       half_w = plist_get("join_w", layout) / 2,
       y0 = plist_get("min_y", layout) + edge_margin,
       y1 = plist_get("transition_y_end", layout) - edge_margin)
  [for (side = ["left", "right"])
      let (x0 = side == "left" ? -half_w + edge_margin : motor[1][0] + gap,
           x1 = side == "left" ? motor[0][0] - gap : half_w - edge_margin)
        ["name", side,
         "bounds", [[x0, y0, 0], [x1, y1, 0]]]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_equipment_obstacles
  ─────────────────────────────────────────────────────────────────────────────
  Collect occupied deck footprints, including the four battery support screws.
  **Parameters:**
  - `layout`: Resolved rear layout in native coordinates.
  **Returns:** XY exclusion boxes used by placement and zone previews.
 */
function rear_equipment_obstacles(layout) =
  let (payload = plist_get("power_case", layout),
       radius = is_undef(payload) ? 0 : plist_get("radius", payload))
  concat([plist_get("motor_bounds", layout)],
         [for (panel = plist_get("panels", layout, []))
             plist_get("bounds", panel)],
         [for (wago = plist_get("wago_mounts", layout, []))
             plist_get("bounds", wago)],
         is_undef(payload) ? [] :
         [for (p = plist_get("mount_holes", payload))
             [[p[0] - radius, p[1] - radius, 0],
              [p[0] + radius, p[1] + radius, 0]]]);

function _deck_fits(bounds, zone, obstacles, gap, payload, parent_t) =
  bounds[0][0] >= zone[0][0] - 0.000001
  && bounds[1][0] <= zone[1][0] + 0.000001
  && bounds[0][1] >= zone[0][1] - 0.000001
  && bounds[1][1] <= zone[1][1] + 0.000001
  && len([for (b = obstacles) if (_deck_overlap(bounds, b, gap)) 1]) == 0
  && (is_undef(payload)
      || !_deck_overlap(bounds, plist_get("bounds", payload), gap)
      || bounds[1][2] + parent_t + gap <= plist_get("mount_z", payload));

// Search edge-aligned placements in stable Y/X order, without rounding to a grid.
// The caller controls list order; this is first-fit packing, not an optimizer.
function _deck_candidates(size, zone, obstacles, gap, position) =
  !is_undef(position)
  ? [[for (axis = [0, 1])
      zone[0][axis] + size[axis] / 2
        + position[axis] * (zone[1][axis] - zone[0][axis] - size[axis])]]
  : let (xs = qsort(concat([zone[0][0] + size[0] / 2,
                            zone[1][0] - size[0] / 2],
                           [for (b = obstacles) b[1][0] + gap + size[0] / 2],
                           [for (b = obstacles) b[0][0] - gap - size[0] / 2])),
         ys = qsort(concat([zone[0][1] + size[1] / 2,
                            zone[1][1] - size[1] / 2],
                           [for (b = obstacles) b[1][1] + gap + size[1] / 2],
                           [for (b = obstacles) b[0][1] - gap - size[1] / 2])))
  [for (y = ys, x = xs) [x, y]];

function _rear_equipment_place(specs,
                               layout,
                               zones,
                               obstacles,
                               gap,
                               i=0,
                               placed=[]) =
  i >= len(specs) ? placed :
  let (spec = specs[i],
       kind = plist_get("kind", spec),
       component = plist_get("component", spec, []),
       props = deck_component_props(kind, component),
       base = plist_get("size", props),
       rotation = plist_get("rotation", spec, 0),
       side = plist_get("zone", spec, "auto"),
       position = plist_get("position", spec),
       size = [abs(cos(rotation)) * base[0] + abs(sin(rotation)) * base[1],
               abs(sin(rotation)) * base[0] + abs(cos(rotation)) * base[1],
               base[2]],
       occupied = concat(obstacles, [for (p = placed) plist_get("bounds", p)]))
  assert(is_num(rotation), "Equipment rotation must be degrees about Z")
  assert(side == "left" || side == "right" || side == "auto",
         "Equipment zone must be left, right or auto")
  assert(is_undef(position) || (is_list(position) && len(position) == 2
                                && min(position) >= 0 && max(position) <= 1),
         "Equipment position must be [x,y] fractions between 0 and 1")
  let (candidates = [for (zone = zones)
           if (side == "auto" || side == plist_get("name", zone))
             let (bounds = plist_get("bounds", zone))
               for (xy = _deck_candidates(size, bounds, occupied, gap, position))
                 let (pos = [xy[0], xy[1], 0], b = _deck_bounds(pos, size))
                   if (_deck_fits(b, bounds, occupied, gap,
                                  plist_get("power_case", layout),
                                  plist_get("size", layout)[2]))
                     ["kind", kind,
                      "component", component,
                      "props", props,
                      "zone", plist_get("name", zone),
                      "rotation", rotation,
                      "pos", pos,
                      "size", size,
                      "bounds", b]])
  assert(len(candidates) > 0,
         str("Rear equipment #", i + 1, " (", kind, ") does not fit zone ", side,
             " at rotation ", rotation, "; envelope ", size,
             ". Change order, zone, rotation, position or hardware; chassis is fixed."))
  _rear_equipment_place(specs,
                        layout,
                        zones,
                        obstacles,
                        gap,
                        i + 1,
                        concat(placed, [candidates[0]]));

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_equipment_layout
  ─────────────────────────────────────────────────────────────────────────────
  Place a list of electronics without changing the chassis or battery height.
  **Parameters:**
  - `specs`: Plists with kind, component, zone, rotation, count and position.
    Position is optional [0..1, 0..1] alignment within the selected zone; omitted
    positions use automatic first-fit placement. Rotation is degrees about Z.
  - `layout`: Existing rear layout, with motor, panels and battery supports.
  - `edge_margin`: Deck boundary inset (at least its outline corner radius).
  - `gap`: Minimum separation and overhead clearance in millimeters.
  **Returns:** Resolved equipment plists with pos, rotation, size and bounds.
  Repeated types are independent. Oversized/overlapping entries assert clearly.
 */
function rear_equipment_layout(specs, layout, edge_margin=3, gap=3) =
  assert(is_list(specs), "Rear equipment must be a list")
  let (expanded = [for (spec = specs)
           let (count = plist_get("count", spec, 1))
             each assert(is_num(count) && count >= 1 && floor(count) == count,
                         "Equipment count must be a positive integer")
             repeat(spec, count)])
  _rear_equipment_place(expanded,
                        layout,
                        rear_equipment_zones(layout, edge_margin, gap),
                        rear_equipment_obstacles(layout),
                        gap);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_equipment
  ─────────────────────────────────────────────────────────────────────────────
  Display resolved equipment or cut its matching holes in the deck.
  **Parameters:**
  - `layout`: Rear layout containing resolved equipment and equipment_zones.
  - `slot_mode`: Emit parent cutters; geometry visibility does not affect holes.
  - `show_hardware`: Display boards and mounting hardware.
  - `show_zones`: Preview free corridors with occupied areas removed.
  Native origin is the holder row, Z=0 at the bottom of the chassis plate.
 */
module rear_equipment(layout,
                      slot_mode=false,
                      show_hardware=true,
                      show_zones=false) {
  parent_t = plist_get("size", layout)[2];
  translate([0, 0, parent_t]) {
    for (p = plist_get("equipment", layout, [])) {
      translate(plist_get("pos", p)) {
        rotate([0, 0, plist_get("rotation", p)]) {
          deck_component(plist_get("kind", p),
                         plist_get("component", p),

                         parent_t=parent_t,
                         slot_mode=slot_mode,
                         show_hardware=show_hardware);
        }
      }
    }
    if (show_zones && !slot_mode) {
      gap = plist_get("equipment_gap", layout, 3);
      for (zone = plist_get("equipment_zones", layout, [])) {
        b = plist_get("bounds", zone);
        if (b[1][0] > b[0][0] && b[1][1] > b[0][1]) {
          color(plist_get("name", zone) == "left"
                ? [0.1, 0.7, 1, 0.35] : [1, 0.4, 0.7, 0.35]) {
            linear_extrude(height=0.2) {
              difference() {
                translate([b[0][0], b[0][1]]) {
                  square([b[1][0] - b[0][0], b[1][1] - b[0][1]]);
                }
                for (o = rear_equipment_obstacles(layout)) {
                  translate([o[0][0] - gap, o[0][1] - gap]) {
                    square([o[1][0] - o[0][0] + 2 * gap,
                            o[1][1] - o[0][1] + 2 * gap]);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
