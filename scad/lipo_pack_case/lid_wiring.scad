/**
  * Module: Standalone LiPo power harness and wire-length schedule.
  *
  * Coordinates use the case body's XY center and case bottom Z=0. The
  * connected preview represents the seated lid; disconnect before sliding it.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../components/button_bracket/button_bracket.scad>
use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/transforms.scad>
use <../lib/wire.scad>
use <../placeholders/lipo_pack_wiring.scad>
use <../placeholders/t_plug.scad>
use <../wago/wago_pair.scad>
use <lid_equipment.scad>
use <lid_fuse.scad>
use <multi_lipo_pack_lid.scad>

function _harness_point(m, p, z) =
  concat(plist_get("pos", m), [z]) + rotZ(p, plist_get("rotation", m, 0));

function _harness_pack_point(pl, case_p, p) =
  let (pack = plist_get("lipo_packs", pl)[0],
       s = plist_get("size", pack),
       oriented = plist_get("pack_sizes", case_p)[0],
       v = orientation_matrix(plist_get("orientation", pack, "wlh")) * concat(p - [0, 0, s[2] / 2], [1]),
       body = plist_get("body_size", case_p))
  rotZ([v[0], v[1], v[2]] + oriented / 2 + plist_get("pack_positions", case_p)[0]
       - [body[0] / 2, body[1] / 2, 0], plist_get("power_rotation", pl, 0));

function _harness_route(name, controls, d, color, config) =
  let (chosen = plist_get(name, plist_get("paths", config, []), controls),
       path = rounded_wire_points(chosen, trim=plist_get("bend_trim", config, 2 * d)))
  assert(chosen[0] == controls[0] && chosen[len(chosen) - 1] == controls[len(controls) - 1],
         str("Custom path must preserve terminal endpoints: ", name))
  ["name", name,
   "path", path,
   "d", d,
   "color", color,
   "length", total_wire_length(path)];

// Stay outside the cradle's inner X wall, then approach its outward wire face.
function _harness_wago_tail(m, side, z, d) =
  let (p = plist_get("props", m),
       b = plist_get("bracket_props", p),
       bs = plist_get("size", b),
       ports = wago_pair_wire_ports(plist_get("component", m), side),
       end = ports[side == -1 ? 0 : len(ports) - 1],
       x = -bs[0] / 2 - d / 2 - 1.2,
       outside_y = end[1] + side * (2 * d + plist_get("wall_t", b)),
       upper = max(end[2], plist_get("base_t", b) + d / 2 + 1),
       points = [[-4, side * 4, -5], [-4, side * 4, upper],
                 [x, side * 4, upper], [x, outside_y, upper],
                 [end[0], outside_y, end[2]], end + [0, side * 3, 0], end])
  [for (pt = points) _harness_point(m, pt, z)];

function _harness_button_tail(m, i, z, d) =
  let (ports = button_bracket_wire_ports(plist_get("component", m)),
       end = ports[i],
       slot = plist_get("wire_pos", plist_get("props", m)),
       side = i == 0 ? 1 : -1,
       points = [end, end + [0, -d, 0],
                 [side * 4, end[1] - d, end[2]],
                 [slot[0] + side * 4, slot[1], 6],
                 [slot[0] + side * 4, slot[1], -5]])
  [for (pt = points) _harness_point(m, pt, z)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_wiring_props
  ─────────────────────────────────────────────────────────────────────────────
  Route one battery through the concealed fuse and switch to separate Wagos.
  **Parameters:**
  - `pl`: Case plist with one pack, top-routed T-plug leads, one button with
    crimps, a wago_pair and concealed fuse. wiring.d defaults to 3.8 mm;
    wiring.cut_allowance adds a configurable trimming allowance (default 20 mm).
  - `l_clearance`, `w_clearance`: Same pack-cell clearances as the assembly.
  **Returns:** Named sampled routes and lengths, plus mating connector placement.
  Case power_rotation turns the complete harness and mating connector together.
  Unsupported circuits are rejected rather than electrically joining packs.
  `wiring.paths` overrides routes in the unrotated power frame, preserving endpoints;
  `wiring.bend_trim` controls corner rounding. The default routing template
  targets the standalone dual-Wago layout; it is not an obstacle-search solver.
 */
function lid_wiring_props(pl, l_clearance=0.4, w_clearance=0.4) =
  let (a = plist_get("power_rotation", pl, 0),
       p = _lid_wiring_props(plist_put("power_rotation", 0, pl),
                             l_clearance, w_clearance))
  plist_put("routes", [for (r = plist_get("routes", p))
      plist_put("path", [for (pt = plist_get("path", r)) rotZ(pt, a)], r)], p);

function _lid_wiring_props(pl, l_clearance=0.4, w_clearance=0.4) =
  let (lid = multi_lipo_pack_lid_props(pl, l_clearance, w_clearance),
       c = plist_get("case_props", lid),
       spec = plist_get("lid", pl),
       pack = plist_get("lipo_packs", pl)[0],
       config = plist_get("wiring", pl, []),
       d = plist_get("d", config, 3.8),
       e = lid_equipment_layout(plist_get("equipment", spec), lid),
       buttons = [for (m = e) if (plist_get("kind", m) == "button") m],
       wagos = [for (m = e) if (plist_get("kind", m) == "wago_pair") m],
       fuse = lid_fuse_props(plist_get("fuse", spec), lid))
  assert(len(plist_get("lipo_packs", pl)) == 1 && len(buttons) == 1 && len(wagos) == 1
         && plist_get("enabled", fuse),
         "Wired preset requires one pack, button, Wago pair and fuse")
  assert(plist_get("routing", plist_get("power_lead", pack)) == "top"
         && plist_get("connector", plist_get("power_lead", pack)) == "t-plug",
         "Wired battery needs a top-routed T-plug")
  let (button = plist_get("button", plist_get("component", buttons[0])),
       crimp = plist_get("crimp_terminal", button, []))
  assert(is_list(crimp) && len(crimp) > 0,
         "Wired switch needs crimp terminals")
  assert(plist_get("terminal_hole_d", button, 0) > 0,
         "Wired switch needs terminal holes for its crimp terminals")
  assert(d > 0, "Wire diameter must be positive")
  let (roof = plist_get("mount_z", lid) + plist_get("roof_z", lid),
       top = roof + plist_get("t", lid),
       power = lipo_pack_top_wiring_props(pack),
       plug_pos = plist_get("connector_pos", power),
       plug_angle = plist_get("connector_rotation", power),
       male = [for (p = plist_get("male_ports", t_plug_mated_props()))
           _harness_pack_point(pl, c, plug_pos + rotZ(p, plug_angle))],
       fp = [for (p = lid_fuse_wire_ports(fuse)) p + [0, 0, roof]],
       bt = [for (i = [0, 1]) _harness_button_tail(buttons[0], i, top, d)],
       wt = [for (side = [-1, 1]) _harness_wago_tail(wagos[0], side, top, d)],
       pack_top = plist_get("pack_positions", c)[0][2] + plist_get("pack_sizes", c)[0][2],
       low = pack_top + d / 2 + 0.8,
       // Cross behind the flat fuse, between its body and the rear skirt.
       return_y = _lid_access_limits(lid)[1] + d / 2 + 0.1,
       button_in = bt[0][len(bt[0]) - 1],
       button_out = bt[1][len(bt[1]) - 1],
// Socket approaches follow the configured fuse's own X direction.
       fuse_in = fp[0] + rotZ([8, 0, 0], plist_get("rotation", fuse)),
       fuse_out = fp[1] + rotZ([-8, 0, 0], plist_get("rotation", fuse)),
       plug_ports = plist_get("male_ports", t_plug_mated_props()),
       solder_center = (plug_ports[0] + plug_ports[1]) / 2,
       connector_out = _harness_pack_point(pl, c,
                                           plug_pos + rotZ(solder_center - [0, 2.5 * d, 0], plug_angle)),
       routes = [_harness_route("T-plug negative -> GND Wago",
                                concat([male[1], [connector_out[0], male[1][1], male[1][2]],
                                        [connector_out[0], -7, low], [wt[0][0][0] - 8, -7, low],
                                        [wt[0][0][0] - 8, -7, wt[0][0][2]]], wt[0]), d, "#202020", config),
                 _harness_route("T-plug positive -> fuse",
                                [male[0], [connector_out[0], male[0][1], fp[0][2]],
                                 fuse_in, fp[0]], d, "#d92727", config),
                 _harness_route("Fuse -> switch input",
                                concat([fp[1], fuse_out, [button_in[0], button_in[1], fp[1][2]]], reverse(bt[0])), d, "#d92727", config),
                 _harness_route("Switch output -> positive Wago",
                                concat(bt[1], [[button_out[0], button_out[1], low],
                                               [button_out[0], return_y, low],
                                               [wt[1][0][0], return_y, low],
                                               [wt[1][0][0], wt[1][0][1], low]], wt[1]), d, "#d92727", config)])
  ["routes", routes,
   "case_props", c,
   "pack", pack,
   "power", power,
   "plug_pos", plug_pos,
   "plug_angle", plug_angle,
   "cut_allowance", plist_get("cut_allowance", config, 20)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  lid_wiring
  ─────────────────────────────────────────────────────────────────────────────
  Draw the seated harness and its male T-plug in the case assembly frame.
  **Parameters:**
  - `pl`: Case plist accepted by lid_wiring_props.
  - `anchor`: Same case-envelope anchor used by the assembly.
  - `report`: Echo measured pack leads, harness centerlines and suggested
    harness cut lengths, in mm.
  - `show_connector`: Display the male half of the connected T-plug.
  - `l_clearance`, `w_clearance`: Same pack-cell clearances as the assembly.
 */
module lid_wiring(pl,
                  anchor=[0, 0, 1],
                  report=false,
                  show_connector=true,
                  l_clearance=0.4,
                  w_clearance=0.4) {

  props = lid_wiring_props(pl, l_clearance, w_clearance);
  c = plist_get("case_props", props);
  if (report) {
    for (key = ["power_lead", "balance_lead"]) {
      lead = lipo_pack_top_wiring_props(plist_get("pack", props), key);
      for (i = [0:len(plist_get("paths", lead)) - 1]) {
        echo(key,
             conductor=i,
             measured_length_mm=total_wire_length(plist_get("paths", lead)[i]));
      }
    }
  }
  with_orientation(from="wlh",
                   to=plist_get("orientation", c),
                   size=plist_get("canonical_size", c),
                   anchor=anchor) {
    for (r = plist_get("routes", props)) {
      wire_path(plist_get("path", r),
                d=plist_get("d", r),
                colr=plist_get("color", r),
                mode="none",
                cut_len=undef);
      if (report) {
        length = plist_get("length", r);
        echo(plist_get("name", r),
             centerline_mm=length,
             suggested_cut_mm=ceil((length + plist_get("cut_allowance", props)) / 5) * 5);
      }
    }
    if (show_connector) {
      pack = plist_get("pack", props);
      s = plist_get("size", pack);
      body = plist_get("body_size", c);
      rotate([0, 0, plist_get("power_rotation", pl, 0)]) {
        translate(plist_get("pack_positions", c)[0] - [body[0] / 2, body[1] / 2, 0]) {
          with_orientation(to=plist_get("orientation", pack, "wlh"),
                           size=s,
                           anchor=[1, 1, 1]) {
            translate(plist_get("plug_pos", props)) {
              rotate([0, 0, plist_get("plug_angle", props)]) {
                t_plug_mated(show_female=false);
              }
            }
          }
        }
      }
    }
  }
}
