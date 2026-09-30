/**
  * Module: Length-constrained LiPo leads folded back over the pack.
  *
  * Coordinates are pack-centered XY with the pack bottom at Z=0, before
  * orientation and anchoring. Existing side cable exits remain fixed.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../lib/plist.scad>
use <../lib/functions.scad>
use <../lib/wire.scad>
use <t_plug.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  lipo_pack_lead_exit
  ─────────────────────────────────────────────────────────────────────────────
  Return the existing side-lead bend's start, before pack orientation.
  **Parameters:**
  - `pl`: Pack plist with logical size.
  - `lead`: Power or balance lead plist.
  - `i`: Zero-based conductor index in the existing bottom-to-top stack.
  **Returns:** XYZ wire center at the existing side exit's outer bend.
 */
function lipo_pack_lead_exit(pl, lead, i) =
  let (s = plist_get("size", pl), d = plist_get("d", lead),
       side = plist_get("side", lead, "left") == "left" ? -1 : 1)
  [side * (s[0] / 2 + d / 2), -s[1] / 2 + d / 2, s[2] / 2 + i * d - max(0, plist_get("exit_l", lead, 0) - d / 2)];

function _lipo_top_path(start, end, s, d, excursion, lane, count) =
  let (rear = -s[1] / 2 - excursion,
       lane_x = start[0] + (start[0] < 0 ? -1 : 1) * lane * (d + 0.5),
       top = max(s[2] + d / 2 + 0.5, end[2]) + lane * (d + 0.4),
       under_rail = s[2] - d / 2 - 0.8 - (count - 1 - lane) * (d + 0.5),
       controls = [start, start + [0, -d, 0],
                   [lane_x, start[1] - d, start[2]],
                   [lane_x, rear, start[2]],
                   [lane_x, rear, under_rail],
                   [end[0], rear, under_rail],
                   [end[0], rear, top],
                   end + [0, -2 * d, 0], end])
  rounded_wire_points(controls, trim=d);

function _lipo_top_solve(start, end, s, d, length, lane, count,
                          lo=2, hi=undef, n=22) =
  let (upper = is_undef(hi) ? length : hi,
       mid = (lo + upper) / 2,
       path = _lipo_top_path(start, end, s, d, mid, lane, count))
  n == 0 ? path : total_wire_length(path) > length
  ? _lipo_top_solve(start, end, s, d, length, lane, count, lo, mid, n - 1)
  : _lipo_top_solve(start, end, s, d, length, lane, count, mid, upper, n - 1);

/**
  ─────────────────────────────────────────────────────────────────────────────
  lipo_pack_top_wiring_props
  ─────────────────────────────────────────────────────────────────────────────
  Resolve folded lead paths using the lead's measured free length.
  **Parameters:**
  - `pl`: Pack plist; lead_exit must be rear_side.
  - `key`: power_lead or balance_lead. Optional lead connector_pos sets the
    mating plane of a T-plug or the end of an unconnected balance bundle.
  **Returns:** Sampled paths, colors, diameter, connector position and rotation.
  All paths use the same samples for drawing and length reporting.
 */
function lipo_pack_top_wiring_props(pl, key="power_lead") =
  assert(is_list(plist_get(key, pl)), str("Missing pack lead: ", key))
  assert(plist_get("d", plist_get(key, pl), 0) > 0
         && plist_get("l", plist_get(key, pl), 0) > 0, "Lead diameter and length must be positive")
  let (s = plist_get("size", pl), lead = plist_get(key, pl),
       d = plist_get("d", lead), length = plist_get("l", lead),
       colors = plist_get("colors", lead, ["red", "black"]),
       plug = plist_get("connector", lead) == "t-plug",
       pos = plist_get("connector_pos", lead,
         plug ? [s[0] / 6, -s[1] / 2 + 26, s[2] + 0.8]
         : [s[0] / 2 - 6, -s[1] / 2 + 6, s[2] + d / 2 + 0.5]),
       ports = plug ? [for (p = plist_get("female_ports", t_plug_mated_props()))
                          pos + rotZ(p, 180)]
         : [for (i = [0:len(colors) - 1]) pos + [(i - (len(colors) - 1) / 2) * (d + 0.2), 0, 0]],
       paths = [for (i = [0:len(colors) - 1])
                  _lipo_top_solve(lipo_pack_lead_exit(pl, lead, i), ports[i], s, d, length, i, len(colors))])
  assert(plist_get("lead_exit", pl) == "rear_side", "Top routing requires rear_side exits")
  assert(!plug || len(colors) == 2, "T-plug requires positive and negative leads")
  assert(max([for (p = paths) abs(length - total_wire_length(p))]) < 0.01,
         "Lead length cannot reach its top connector position with this return loop")
  ["paths", paths, "d", d, "colors", colors, "connector", plug,
   "connector_pos", pos, "connector_rotation", 180, "length", length];

/**
  ─────────────────────────────────────────────────────────────────────────────
  lipo_pack_top_wiring
  ─────────────────────────────────────────────────────────────────────────────
  Draw folded leads and the pack's female connector.
  **Parameters:**
  - `props`: Resolved lipo_pack_top_wiring_props in the pack's logical frame.
 */
module lipo_pack_top_wiring(props) {
  for (i = [0:len(plist_get("paths", props)) - 1]) {
    wire_path(plist_get("paths", props)[i], d=plist_get("d", props),
              colr=plist_get("colors", props)[i], mode="none", cut_len=undef);
  }
  if (plist_get("connector", props)) {
    translate(plist_get("connector_pos", props)) {
      rotate([0, 0, plist_get("connector_rotation", props)]) {
        t_plug_mated(show_male=false);
      }
    }
  }
}
