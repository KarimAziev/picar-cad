/**
  * Module: Chassis joint fasteners with material-limited screw-head recesses.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../rc_params.scad>

use <../components/plate_joint/plate_joint.scad>
use <../lib/plist.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  chassis_joint_recess
  ─────────────────────────────────────────────────────────────────────────────
  Select a supported screw-head recess for one joint bolt.
  **Parameters:**
  - `p`: Resolved plate joint parameters, including counterbore dimensions.
  - `x`: Bolt-center X coordinate.
  - `mode`: Joint half, `"male"` or `"female"`.
  - `countersink_fallback`: Use the shared chassis countersink dimensions when
    the full counterbore cannot fit; omit the recess if neither fits.
  **Returns:** `[diameter, depth, countersunk]`. Without fallback, counterbores
  may be shallow to retain the configured floor. Countersinks use their full
  configured depth and diameter.
 */
function chassis_joint_recess(p, x, mode, countersink_fallback=false) =
  let (depth = chassis_joint_bore_depth(p, x, mode),
       bore_d = plist_get("bolt_bore_d", p),
       bore_h = plist_get("bolt_bore_h", p))
  !countersink_fallback || depth >= bore_h
    ? [bore_d, depth, false]
    : let (sink_p = plist_merge(p,
                               ["bolt_bore_d", chassis_countersunk_bore_d,
                                "bolt_bore_h", chassis_countersunk_bore_h]),
           sink_depth = chassis_joint_bore_depth(sink_p, x, mode))
      sink_depth > 0 && sink_depth >= chassis_countersunk_bore_h
        ? [chassis_countersunk_bore_d, sink_depth, true]
        : [bore_d, 0, false];

/**
  ─────────────────────────────────────────────────────────────────────────────
  chassis_joint_bore_depth
  ─────────────────────────────────────────────────────────────────────────────
  Return the supported counterbore depth at a chassis joint bolt.
  **Parameters:**
  - `p`: Resolved `plate_joint_parameters()` plist, including pin placement.
  - `x`: Bolt center in joint coordinates.
  - `mode`: `"male"` for top recesses or `"female"` for bottom recesses.
  **Returns:** Depth in millimeters; zero retains a through hole. Recesses
  require the configured floor and side walls, including clearance to pins.
 */
function chassis_joint_bore_depth(p, x, mode) =
  let (r = plist_get("bolt_bore_d", p) / 2,
       wall = suspension_chassis_joint_bore_wall,
       h = plist_get("plate_h", p),
       base = plist_get("base_h", p),
       rail_h = plist_get("rail_h", p),
       gap = plist_get("clearance", p),
       rib_tip = plist_get("dovetail_rib", p) ? 0.05 : 0,
       inside = abs(x) + r + wall <= plist_get("rail_neck_w", p) / 2,
       outside = abs(x) - r - wall >= plist_get("rail_w", p) / 2 + gap,
       thick_side = mode == "male" ? inside : outside,
       thickness = mode == "male" ? base + rail_h - rib_tip : h - base - gap,
       edge_land = plist_get("w", p) / 2 - abs(x) - r,
       end_land = plist_get("l", p) / 2 - r
                  - (mode == "male" ? plist_get("axial_clearance", p) : 0),
       pin_land = abs(abs(x) - plist_get("pin_spacing", p) / 2)
                  - r - plist_get("pin_d", p) / 2,
       pins_clear = !plist_get("include_pin_holes", p)
                    || pin_land >= max(wall, suspension_chassis_joint_bore_pin_land)
                                   - 0.000001)
  !suspension_chassis_joint_counterbores || !thick_side
  || edge_land < wall || end_land < wall || !pins_clear
    ? 0
    : max(0, min(plist_get("bolt_bore_h", p),
                 thickness - suspension_chassis_joint_bore_floor));

/**
  ─────────────────────────────────────────────────────────────────────────────
  chassis_joint_bolt_holes
  ─────────────────────────────────────────────────────────────────────────────
  Emit through holes and supported recesses in the joint's reference box.
  **Parameters:**
  - `p`: Resolved `plate_joint_parameters()` plist.
  - `mode`: Joint half, `"male"` or `"female"`.
  - `bolt_xs`: Optional bolt-center X coordinates; undef uses the plist pattern.
  - `anchor`: Joint envelope anchor; default spans Y=-l..0 and Z=0..plate_h.
  - `countersink_fallback`: Select a full countersink if a full counterbore
    cannot fit; false permits shallow counterbores.
 */
module chassis_joint_bolt_holes(p,
                                mode,
                                bolt_xs=undef,
                                anchor=[0, -1, 1],
                                countersink_fallback=false) {
  assert(mode == "male" || mode == "female", "Invalid chassis joint mode");
  xs = is_undef(bolt_xs) ? plist_get("bolt_xs", p) : bolt_xs;
  l = plist_get("l", p);
  h = plist_get("plate_h", p);
  with_anchor(anchor=is_undef(anchor) ? [0, -1, 1] : anchor,
              size=[plist_get("w", p), l, h], centered=true) {
    translate([0, l / 2, 0]) {
      for (x = xs) {
        recess = chassis_joint_recess(p, x, mode, countersink_fallback);
        plate_joint_bolt_holes(bolt_d=plist_get("bolt_d", p),
                               plate_h=h,
                               l=l,
                               bolt_xs=[x],
                               bore_d=recess[0],
                               bore_h=recess[1],
                               no_bore=recess[2] || recess[1] == 0,
                               reverse=mode == "female");
        if (recess[2]) {
          translate([x, -l / 2, 0]) {
            counterbore(d=plist_get("bolt_d", p),
                        h=h,
                        bore_d=recess[0],
                        bore_h=recess[1],
                        sink=true,
                        reverse=mode == "female",
                        autoscale_step=0);
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  chassis_joint_bolts
  ─────────────────────────────────────────────────────────────────────────────
  Place bolt placeholders on the selected half's outer face and recess seats.
  **Parameters:**
  - `p`: Resolved `plate_joint_parameters()` plist with its bolt-center pattern.
  - `mode`: `"male"` for top heads or `"female"` for underside heads.
  - `anchor`: Joint envelope anchor; undef uses `[0, -1, 1]`.
 */
module chassis_joint_bolts(p, mode, anchor=[0, -1, 1]) {
  for (x = plist_get("bolt_xs", p)) {
    depth = chassis_joint_bore_depth(p, x, mode);
    plate_joint_bolts(plist_merge(p, ["bolt_xs", [x],
                                      "bolt_no_bore", depth == 0,
                                      "bolt_bore_h", depth]),
                      anchor=anchor,
                      flip=mode == "female");
  }
}
