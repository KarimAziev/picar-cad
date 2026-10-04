/**
  * Module: Opposing Wago cradles with a shared parent wiring opening.
  *
  * The pair is centered on XY, with both bases at Z=0. Rear mounting ears
  * face inward; connector wire faces point outward along -Y and +Y.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/wago/wago_221.scad>
use <wago_bracket.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  wago_pair_wire_ports
  ─────────────────────────────────────────────────────────────────────────────
  Return the conductor mouths in the centered pair mounting frame.
  **Parameters:**
  - `pl`: Pair specification accepted by wago_pair_props.
  - `side`: +1 selects the positive lid connector; -1 selects GND.
  **Returns:** XYZ points in the connector's local conductor order.
 */
function wago_pair_wire_ports(pl=[], side=1) =
  let (p = wago_pair_props(pl),
       b = plist_get("bracket_props", p),
       bs = plist_get("size", b),
       ws = plist_get("wago_size", b),
       wp = plist_get("wago_pos", b) - [bs[0] / 2, bs[1] / 2, 0]
            + [ws[0] / 2, ws[1] / 2, 0])
  assert(side == -1 || side == 1, "Wago side must be -1 or 1")
  [for (pt = wago_wire_ports(plist_get("wago", b)))
    rotZ(wp + pt, side == 1 ? 180 : 0)
    + [0, side * plist_get("offset", p), 0]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  wago_pair_props
  ─────────────────────────────────────────────────────────────────────────────
  Resolve two opposing cradles and the available wiring space between them.
  **Parameters:**
  - `pl`: `bracket` is a wago_bracket_props plist with rear ears. `spacing`
    is the gap between opposing ear tips (default 2 mm). `wire_pad` preserves
    material beside the ears and trays (default 1.5 mm). Optional `wire_size`
    reduces the derived maximum opening; `wire_r` defaults to up to 3 mm.
    `overhang` permits that much unsupported cradle length at each outer Y end
    (default zero), capped at one third of the tray length.
  **Returns:**
  `size` includes both complete cradles; `roof_bounds` is the required parent
  bearing envelope. `mount_holes`, `wire_pos`, and `wire_size` share the pair's
  centered mounting frame, independent of its parent placement or rotation.
 */
function wago_pair_props(pl=[]) =
  let (bracket = plist_get("bracket", pl, []),
       p = wago_bracket_props(bracket),
       s = plist_get("size", p),
       e = plist_get("ear_d", p),
       spacing = plist_get("spacing", pl, 2),
       pad = plist_get("wire_pad", pl, 1.5),
       overhang = plist_get("overhang", pl, 0),
       offset = (s[1] + spacing) / 2,
       size = [s[0], 2 * s[1] + spacing, s[2]],
       max_wire = [s[0] - 2 * e - 2 * pad, 2 * e + spacing - 2 * pad],
       wire = plist_get("wire_size", pl, max_wire),
       r = plist_get("wire_r", pl, min(3, min(wire) / 2)),
       d = plist_get("bolt_d", p),
       bore_d = find_bolt_head_d(d, "countersunk") + 0.3,
       bore_h = find_bolt_head_h(d, "countersunk") + 0.15,
       holes = [for (side = [-1, 1], xy = plist_get("mount_holes", p))
         [-side * (xy[0] - s[0] / 2),
          side * (offset - xy[1] + s[1] / 2)]])
  assert(plist_get("mount_side", p) == "rear",
         "Opposing Wago pairs require rear mounting ears")
  assert(is_num(spacing) && spacing >= 0 && is_num(pad) && pad > 0,
         "Wago pair spacing must be nonnegative and wire_pad positive")
  assert(is_num(overhang) && overhang >= 0
         && overhang <= plist_get("tray_l", p) / 3,
         "Wago pair overhang must leave at least two thirds of each tray supported")
  assert(is_list(wire) && len(wire) == 2 && min(wire) > 0
         && wire[0] <= max_wire[0] && wire[1] <= max_wire[1],
         "Shared Wago wiring opening must clear the mounting ears and trays")
  assert(is_num(r) && r >= 0 && r <= min(wire) / 2,
         "Wago pair wire_r must fit the wiring opening")
  ["size", size,
   "bracket", bracket,
   "bracket_props", p,
   "offset", offset,
   "mount_holes", holes,
   "wire_pos", [0, 0],
   "wire_size", wire,
   "wire_r", r,
   "max_wire_size", max_wire,
   "overhang", overhang,
   "hole_d", plist_get("hole_d", p),
   "bore_d", bore_d,
   "bore_h", bore_h,
   "roof_bounds", [[-size[0] / 2, -size[1] / 2 + overhang, 0],
                   [size[0] / 2, size[1] / 2 - overhang, size[2]]]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  wago_pair
  ─────────────────────────────────────────────────────────────────────────────
  Render two separate cradles, or their parent mounting and wiring cutters.
  **Parameters:**
  - `pl`: Pair parameters accepted by wago_pair_props.
  - `anchor`: Anchor on the complete pair envelope, shared by both modes.
  - `parent_t`: Parent thickness below Z=0; used for slot mode.
  - `slot_mode`: Emit four underside countersinks and the shared wire opening.
  - `show_wago`: Include connectors in solid mode (default false for printing).
  **Behavior:**
  Both cradles print base-down. The wire opening passes 0.01 mm beyond both
  parent faces, avoiding coincident surfaces in preview and Boolean cuts.
 */
module wago_pair(pl=[],
                 anchor=[0, 0, 1],
                 parent_t=3,
                 slot_mode=false,
                 show_wago=false) {
  p = wago_pair_props(pl);
  eps = 0.1;
  with_anchor(anchor, plist_get("size", p), centered=true) {
    if (slot_mode) {
      assert(parent_t >= plist_get("bore_h", p) + 0.4,
             "Wago countersinks need material above their heads");
      for (xy = plist_get("mount_holes", p)) {
        translate(concat(xy, [-parent_t])) {
          counterbore(h=parent_t,
                      d=plist_get("hole_d", p),
                      bore_d=plist_get("bore_d", p),
                      bore_h=plist_get("bore_h", p),
                      sink=true,
                      reverse=true);
        }
      }
      wire = plist_get("wire_size", p);
      translate([0, 0, -parent_t - eps]) {
        cuboid([wire[0], wire[1], parent_t + 2 * eps],
               anchor=[0, 0, 1],
               r=plist_get("wire_r", p));
      }
    } else {
      for (side = [-1, 1]) {
        translate([0, side * plist_get("offset", p), 0]) {
          rotate([0, 0, side == 1 ? 180 : 0]) {
            wago_bracket(plist_get("bracket", p),
                         anchor=[0, 0, 1],
                         show_wago=show_wago);
          }
        }
      }
    }
  }
}
