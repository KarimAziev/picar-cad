/**
  * Module: Concealed ATM fuse-holder retention beneath a sliding lid.
  *
  * Two cable ties secure the holder flat against the roof underside.
  * Coordinates are centered on its installed envelope, with its top at Z=0.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../parameters.scad>
use <../lib/plist.scad>
use <../lib/functions.scad>
use <../lib/shapes3d.scad>
use <../placeholders/atm_fuse_holder/atm_fuse_holder.scad>
use <lid_equipment.scad>
use <../wago/wago_mounts.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_fuse_props
  ─────────────────────────────────────────────────────────────────────────────
  Resolve a flat ATM holder, tie slots and clearance from the batteries.
  **Parameters:**
  - `spec`: Undef disables the holder. `holder` is its hardware plist;
    `pos` is roof-center XY, `rotation` is a Z angle. `clearance` defaults
    to 1 mm above/below the holder. `tie_size` is [width, thickness] in mm.
  - `lid`: Resolved lid properties, including the case and rail references.
  **Returns:** Installed `size`, local tie-slot centers, and placement values.
 */
function lid_fuse_props(spec, lid) =
  is_undef(spec) || !plist_get("enabled", spec, true) ? ["enabled", false] :
  let (holder = plist_get("holder", spec, atm_fuse_default_plist),
       body = plist_get("size", plist_get("body", holder)),
       upright = atm_fuse_holder_size(holder),
       size = [upright[0], upright[2], upright[1]],
       c = plist_get("clearance", spec, 1),
       tie = plist_get("tie_size", spec, [3, 1.2]),
       pos = plist_get("pos", spec, [0, 0]),
       a = plist_get("rotation", spec, 0),
       adapter = plist_get("adapter_props", lid),
       adapter_size = plist_get("size", adapter, [0, 0, 0]),
       adapter_box = _wago_bounds(concat(plist_get("lidar_offset", lid), [0]), adapter_size),
       // Tie the lower body, leaving the removable cap and wire sockets free.
       tie_x = max(body[0], body[3]) / 2 + tie[1] / 2 + 0.5,
       slots = [for (x = [-tie_x, tie_x], f = [0.5, 0.8])
                  [x, -size[1] / 2 + f * body[2]]],
       case_p = plist_get("case_props", lid),
       case_size = plist_get("body_size", case_p),
       packs = plist_get("pack_sizes", case_p),
       positions = plist_get("pack_positions", case_p),
       pack_top = max([for (i = [0:len(packs) - 1]) positions[i][2] + packs[i][2]]),
       free_h = plist_get("mount_z", lid) + plist_get("roof_z", lid) - pack_top,
       rails = plist_get("rail_props", lid),
       cross = plist_get("axis", rails) == "x" ? 1 : 0,
       inner = [for (i = [0:1])
           let (r = plist_get("rails", rails)[i])
           plist_get("cross", r) - case_size[cross] / 2
           + (i == 0 ? 1 : -1) * plist_get("locking_depth", r) / 2],
       b = _lid_move_bounds(_lid_rotate_bounds(
             [[-size[0] / 2, -size[1] / 2, -size[2]],
              [size[0] / 2, size[1] / 2, 0]], a), pos, c))
  assert(is_list(pos) && len(pos) == 2 && is_num(pos[0]) && is_num(pos[1])
         && is_num(a), "Fuse placement requires numeric XY pos and Z rotation")
  assert(!plist_get("enabled", adapter, false) || !_wago_overlap(b, adapter_box)
         || plist_get("standoff_h", adapter, 0) >= tie[1] + 0.4,
         "Raise the adapter to clear the fuse retaining ties")
  assert(min(size) > 0 && c >= 0 && min(tie) > 0,
         "Fuse-holder and tie dimensions must be positive")
  assert(size[2] + 2 * c <= free_h,
         "Fuse holder does not fit above the battery; change its orientation or lid headroom")
  assert(b[0][cross] >= inner[0] && b[1][cross] <= inner[1]
         && _lid_roof_contains(b, plist_get("canonical_size", lid), plist_get("corner_r", lid)),
         "Fuse holder must fit between the lid skirts")
  plist_merge(spec, ["enabled", true, "holder", holder, "size", size,
                     "clearance", c, "tie_size", tie, "slots", slots,
                     "pos", pos, "rotation", a, "free_h", free_h]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_fuse
  ─────────────────────────────────────────────────────────────────────────────
  Render the concealed fuse holder or the cable-tie slots through its roof.
  **Parameters:**
  - `props`: Result of lid_fuse_props.
  - `roof_t`: Thickness above Z=0, the roof's interior face.
  - `slot_mode`: Emit four tie slots; hardware mode includes no printed parts.
 */
module lid_fuse(props, roof_t, slot_mode=false) {
  if (plist_get("enabled", props, false)) {
    size = plist_get("size", props);
    tie = plist_get("tie_size", props);
    holder = plist_get("holder", props);
    translate(concat(plist_get("pos", props), [0])) {
      rotate([0, 0, plist_get("rotation", props)]) {
        if (slot_mode) {
          for (p = plist_get("slots", props)) {
            translate(concat(p, [-0.01])) {
              cuboid([tie[1] + 0.4, tie[0] + 0.4, roof_t + 0.02],
                     anchor=[0, 0, 1], r=0.5);
            }
          }
        } else {
          translate([0, -size[1] / 2,
                     -size[2] / 2 - plist_get("clearance", props)]) {
            rotate([-90, 0, 0]) {
              atm_fuse_holder_from_spec(plist_merge(holder,
                ["wiring", plist_merge(plist_get("wiring", holder),
                                        ["left_pts", [], "right_pts", []])]));
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_fuse_supports
  ─────────────────────────────────────────────────────────────────────────────
  Add two shallow bearing pads beneath the roof for the tied fuse holder.
  **Parameters:**
  - `props`: Resolved fuse properties. Pads extend down from the interior face
    at Z=0 and keep the holder at the specified clearance from that face.
 */
module lid_fuse_supports(props) {
  c = plist_get("clearance", props, 0);
  if (plist_get("enabled", props, false) && c > 0) {
    holder = plist_get("holder", props);
    rib = plist_get("rib", plist_get("body", holder));
    tie = plist_get("tie_size", props);
    translate(concat(plist_get("pos", props), [0])) {
      rotate([0, 0, plist_get("rotation", props)]) {
        for (p = plist_get("slots", props)) {
          if (p[0] < 0) {
            translate([0, p[1], -c]) {
              cuboid([plist_get("l", rib), tie[0], c + 0.01],
                     anchor=[0, 0, 1], r=0.5);
            }
          }
        }
      }
    }
  }
}

function _lid_fuse_tie_bounds(props) =
  !plist_get("enabled", props, false) ? [] :
  let (tie = plist_get("tie_size", props))
  [for (xy = plist_get("slots", props)) if (xy[0] < 0)
      _lid_move_bounds(_lid_rotate_bounds(
        _wago_bounds([0, xy[1], 0], [2 * abs(xy[0]), tie[0] + 0.4, 0]),
        plist_get("rotation", props)), plist_get("pos", props))];

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_fuse_validate
  ─────────────────────────────────────────────────────────────────────────────
  Check tie access against roof equipment and mounting cutouts.
  **Parameters:**
  - `props`: Resolved fuse properties, or disabled properties.
  - `lid`: Resolved lid properties.
  - `equipment`: Resolved equipment layout.
  - `obstacles`: Additional roof footprints, such as legacy Wago mounts.
  **Returns:** Unchanged fuse properties after validating the retaining ties.
 */
function lid_fuse_validate(props, lid, equipment, obstacles=[]) =
  !plist_get("enabled", props, false) ? props :
  let (tie = plist_get("tie_size", props),
       pos = plist_get("pos", props),
       a = plist_get("rotation", props),
       slots = [for (xy = plist_get("slots", props))
           _lid_move_bounds(_lid_rotate_bounds(
             _wago_bounds(concat(xy, [0]), [tie[1] + 0.4, tie[0] + 0.4, 0]), a), pos)],
       bands = _lid_fuse_tie_bounds(props),
       adapter = plist_get("adapter_props", lid),
       adapter_cuts = !plist_get("enabled", adapter, false) ? []
           : [for (xy = plist_get("holes", adapter))
               _wago_bounds(concat(xy + plist_get("lidar_offset", lid), [0]),
                            [plist_get("access_d", adapter),
                             plist_get("access_d", adapter), 0], 0.8)],
       cuts = concat(adapter_cuts, [for (m = equipment, b = _lid_equipment_cuts(m))
                                    _lid_move_bounds(b, plist_get("pos", m), 0.8)]),
       occupied = concat(obstacles, [for (m = equipment) plist_get("bounds", m)]))
  assert(_lid_cut_access(slots, [0, 0], lid), "Fuse tie slots overlap a lid skirt")
  assert(len([for (b = bands) if (!_wago_clear(b, occupied)) 1]) == 0,
         "Fuse retaining ties overlap roof equipment; move the fuse or equipment")
  assert(len([for (b = slots) if (!_wago_clear(b, cuts)) 1]) == 0,
         "Fuse tie slots overlap mounting holes; move or rotate the fuse")
  props;

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_fuse_wire_ports
  ─────────────────────────────────────────────────────────────────────────────
  Return the socket tips of the installed flat holder.
  **Parameters:**
  - `props`: lid_fuse_props result.
  **Returns:** Two XYZ points relative to the interior roof face, in local
  +X, -X socket order before the configured fuse rotation.
 */
function lid_fuse_wire_ports(props) =
  let (holder = plist_get("holder", props), body = plist_get("size", plist_get("body", holder)),
       wiring = plist_get("wiring", holder), size = plist_get("size", props),
       x = body[0] / 2 + plist_get("socket_type_len", wiring, 4))
  [for (side = [1, -1])
      concat(plist_get("pos", props), [0])
      + rotZ([side * x, -size[1] / 2 + body[2] / 2,
              -size[2] / 2 - plist_get("clearance", props)], plist_get("rotation", props))];
