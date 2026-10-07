/**
  * Module: Ventilated two-board power enclosure.
  *
  * End-to-end PCB tray, removable insert-fastened lid and chassis mounting.
  * The regulator's long axis is X; its output faces the INA on +X.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../parameters.scad>

use <../../lib/enclosure_panels.scad>
use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/shapes2d.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/text.scad>
use <../../lib/transforms.scad>
use <../../placeholders/bolt.scad>
use <../../placeholders/heat_insert_nut.scad>
use <../../placeholders/ina_current_sensor.scad>
use <../../placeholders/nut.scad>
use <../../placeholders/step-down-voltage-d24vxf5.scad>

show_hardware        = true;
show_lid             = true;
show_fasteners       = true;
show_enclosure       = true;

slot_mode            = false;

lid_color_alpha      = 0.7; // [0:0.1:1]
color_alpha          = 1.0; // [0:0.1:1]
exploded_lid_h       = 0; // [0:5:100]

show_lid_at_the_side = false;

function _power_enclosure_rect_distance(pos, size, point) =
  norm([for (axis = [0, 1])
    max(0, abs(point[axis] - pos[axis]) - size[axis] / 2)]);

function _power_enclosure_config(overrides) =
  let (base = plist_merge(step_down_enclosure_plist, overrides),
       groups = ["insert", "insert_mount", "mount", "fit", "lid", "wall_vents",
                 "header_slot", "cable_tie", "parent_slots"],
       merged = plist_merge(base, [for (key = groups)
         each [key, plist_merge(plist_get(key, step_down_enclosure_plist, []),
                                plist_get(key, overrides, []))]]),
       lid = plist_get("lid", merged),
       lid_defaults = plist_get("lid", step_down_enclosure_plist),
       lid_override = plist_get("lid", overrides, []))
  plist_merge(merged, ["lid", plist_merge(lid,
    [for (key = ["vents", "text_style"])
      each [key, plist_merge(plist_get(key, lid_defaults, []),
                             plist_get(key, lid_override, []))]])]);

function _power_enclosure_text(spec, style, size, refs, t, depth) =
  let (pl = plist_merge(style, spec),
       at = plist_get("at", pl),
       xy = is_undef(at)
             ? enclosure_dimensions(plist_get("pos", pl, ["50%", "50%"]), size)
             : plist_get(at, refs),
       delta = plist_get("translation", pl, [0, 0, 0]))
  assert(!is_undef(xy), str("Unknown text reference: ", at))
  plist_merge(pl, ["size", enclosure_dimension(plist_get("size", pl), min(size)),
                   "translation", [xy[0], xy[1], t - depth] + delta,
                   "height", depth + 0.01]);

function _power_enclosure_text_bounds(pl) =
  let (tm = textmetrics(text=plist_get("text", pl),
                        size=plist_get("size", pl),
                        font=plist_get("font", pl),
                        spacing=plist_get("spacing", pl),
                        halign=plist_get("halign", pl),
                        valign=plist_get("valign", pl)),
       angle = plist_get("rotation", pl, [0, 0, 0])[2],
       pos = plist_get("translation", pl),
       corners = [for (x = [0, 1], y = [0, 1])
         let (v = tm.offset + [x * tm.size[0], y * tm.size[1]])
         [pos[0] + v[0] * cos(angle) - v[1] * sin(angle),
          pos[1] + v[0] * sin(angle) + v[1] * cos(angle)]],
       lo = [for (i = [0, 1]) min([for (c = corners) c[i]])],
       hi = [for (i = [0, 1]) max([for (c = corners) c[i]])])
  [lo, hi - lo];

/**
   ─────────────────────────────────────────────────────────────────────────────
   step_down_enclosure_props
   ─────────────────────────────────────────────────────────────────────────────

   Resolve the two-board layout, shell, faces, fasteners and wiring interface.

   **Parameters:**
   - `plist`: Overrides for step_down_enclosure_plist. Groups merge by key;
     wall faces and their vents, lid vents and text styles merge independently.
     Opening/text lists replace the corresponding list; [] clears it.

   `inner_size` accepts mm or percentages of the automatically padded board
   envelope. `board_pos` positions the board group within the remaining XY
   space. Wall thicknesses are `walls.<face>.t`, falling back to side_thickness.
   Faces are left=-X, right=+X, rear=-Y, front=+Y in the enclosure frame.
   Panel dimensions use the inner span and height; lid dimensions use body XY.
   See docs/power-enclosure.md for percentage references and complete examples.

   **Returns:**
   Centered XY bounds above Z=0, resolved hardware placement, per-face panels,
   lid panel, insert boss dimensions/positions and the parent mounting interface.
   `size` includes the closed lid and screw heads. Slot mode uses the same frame.
 */
function step_down_enclosure_props(plist=[]) =
  let (pl = _power_enclosure_config(plist),
       regulator = plist_get("step_down_voltage", pl),
       sensor = plist_get("sensor_current", pl),
       rp = step_down_mount_props(regulator),
       ip = ina_current_sensor_props(sensor),
       rb = plist_get("placeholder_size", regulator),
       ib = plist_get("size", ip),
       gap = enclosure_dimension(plist_get("distance", pl), min(rb[0], ib[1])),
       board_span = [rb[0] + gap + ib[1], max(rb[1], ib[0])],
       board_h = max(plist_get("size", rp)[2],
                     plist_get("standoff_h", ip) + plist_get("populated_h", ip)),
       clear = enclosure_dimension(plist_get("board_clearance", pl), min(board_span)),
       end = enclosure_dimension(plist_get("end_clearance", pl), board_span[0]),
       top = enclosure_dimension(plist_get("top_clearance", pl), board_h),
       floor_t = enclosure_dimension(plist_get("bottom_thickness", pl), board_h),
       insert_spec = plist_get("insert", pl),
       insert = heat_insert_nut_props(plist_merge(insert_spec,
         [for (key = ["d", "h", "flang_d", "flang_h", "top_flang_h", "bottom_flat_h"])
           if (!is_undef(plist_get(key, insert_spec)))
             each [key, enclosure_dimension(plist_get(key, insert_spec),
                       member(key, ["d", "flang_d"]) ? min(board_span) : board_h)]])),
       mount_spec = plist_get("insert_mount", pl),
       insert_mount = plist_merge(mount_spec,
         [for (key = ["wall", "floor", "depth_clearance"])
           each [key, enclosure_dimension(plist_get(key, mount_spec),
                       key == "wall" ? min(board_span) : board_h)]]),
       insert_slot = heat_insert_nut_props(plist_merge(insert,
         ["h", plist_get("h", insert) + plist_get("depth_clearance", insert_mount)])),
       insert_depth = plist_get("h", insert_slot) - plist_get("slot_bottom", insert_slot),
       boss_d = max(plist_get("outer_d", insert), plist_get("slot_d", insert_slot))
                  + 2 * plist_get("wall", insert_mount),
       automatic = [board_span[0] + 2 * (clear + end), board_span[1] + 2 * clear,
                    max(board_h + top, insert_depth + plist_get("floor", insert_mount))],
       inner = enclosure_dimensions(plist_get("inner_size", pl), automatic),
       wall_defaults = plist_get("walls", step_down_enclosure_plist),
       wall_overrides = plist_get("walls", plist, []),
       walls = [for (name = ["left", "right", "rear", "front"])
         let (w = plist_merge(plist_get(name, wall_defaults, []),
                              plist_get(name, wall_overrides, [])),
              v = plist_merge_all([plist_get("wall_vents", pl, []),
                                   plist_get("vents", plist_get(name, wall_defaults, []), []),
                                   plist_get("vents", plist_get(name, wall_overrides, []), [])]))
         each [name, plist_merge(w, ["t", enclosure_dimension(plist_get("t", w,
                                         plist_get("side_thickness", pl)),
                                         inner[member(name, ["left", "right"]) ? 0 : 1]),
                                     "vents", v])]],
       ts = [for (name = ["left", "right", "rear", "front"])
         plist_get("t", plist_get(name, walls))],
       body = [inner[0] + ts[0] + ts[1], inner[1] + ts[2] + ts[3], inner[2] + floor_t],
       center = [(ts[0] - ts[1]) / 2, (ts[2] - ts[3]) / 2],
       inner_min = center - [inner[0], inner[1]] / 2,
       slack = [inner[0], inner[1]] - board_span,
       group_min = inner_min + enclosure_dimensions(plist_get("board_pos", pl), slack),
       regulator_pos = [group_min[0] + rb[0] / 2, group_min[1] + board_span[1] / 2, floor_t],
       sensor_pos = [group_min[0] + rb[0] + gap + ib[1] / 2, regulator_pos[1], floor_t],
       corner_r = min(enclosure_dimension(plist_get("corner_r", pl), min(body[0], body[1])),
                      min(body[0], body[1]) / 2),
       boss_insets = [for (t = ts) max(corner_r, boss_d / 2, t / 2)],
       lid_positions = [for (x = [0, 1], y = [0, 1])
         [(x == 0 ? -body[0] / 2 + boss_insets[0] : body[0] / 2 - boss_insets[1]),
          (y == 0 ? -body[1] / 2 + boss_insets[2] : body[1] / 2 - boss_insets[3]), 0]],
       lid_spec = plist_get("lid", pl),
       lid = plist_merge(lid_spec, [for (key = ["t", "lip_h", "lip_w", "clearance", "text_depth"])
         each [key, enclosure_dimension(plist_get(key, lid_spec),
                    key == "t" || key == "lip_h" ? inner[2]
                      : key == "text_depth" ? enclosure_dimension(plist_get("t", lid_spec), inner[2])
                        : min(inner[0], inner[1]))]]),
       lid_t = plist_get("t", lid),
       lid_d = plist_get("hole_d", insert) + plist_get("bolt_clearance", insert_mount),
       lid_bolt_l = plist_get("bolt_l", insert_mount, lid_t + plist_get("h", insert)),
       mount = plist_get("mount", pl),
       mount_d = plist_get("d", mount),
       mount_pitch = enclosure_dimensions(plist_get("spacing", mount), [inner[0], inner[1]]),
       mount_xy = inner_min + enclosure_dimensions(plist_get("pos", mount), [inner[0], inner[1]]),
       mount_pos = [mount_xy[0], mount_xy[1], 0],
       mount_positions = [for (x = [-1, 1], y = [-1, 1])
         mount_pos + [x * mount_pitch[0] / 2, y * mount_pitch[1] / 2, 0]],
       fit = plist_get("fit", pl),
       mount_nut_d = (find_nut_prop("outer_dia", mount_d) + plist_get("nut", fit)) / cos(30),
       board_mounts = concat([for (x = [-1, 1], y = [-1, 1])
         let (pitch = plist_get("bolt_spacing", rp))
         [regulator_pos + [x * pitch[0] / 2, y * pitch[1] / 2, -floor_t], plist_get("bolt_d", rp)]],
         [for (x = [-1, 1], y = plist_get("bolt_spacing", ip)[1] == 0 ? [0] : [-1, 1])
           let (pitch = plist_get("bolt_spacing", ip))
           [sensor_pos + rotZ([x * pitch[0] / 2,
                               y * pitch[1] / 2 + plist_get("mounting_y", ip), 0], 90)
                         - [0, 0, floor_t], plist_get("bolt_d", ip)]]),
       pcb_bore_h = max([for (m = board_mounts) find_bolt_head_h(m[1], "pan")])
                    + plist_get("head_depth", fit),
       keepouts = concat([for (m = board_mounts)
         [m[0], (find_bolt_head_d(m[1], "pan") + plist_get("head", fit)) / 2]],
         [for (pos = mount_positions)
           [pos,
            max(mount_nut_d, find_bolt_head_d(mount_d, "pan") + plist_get("head", fit)) / 2]],
         [for (pos = lid_positions) [pos, boss_d / 2]]),
       tie_spec = plist_get("cable_tie", pl),
       tie = plist_merge(tie_spec, ["slot_size", enclosure_dimensions(plist_get("slot_size", tie_spec), [inner[0], inner[1]]),
         "bridge_w", enclosure_dimension(plist_get("bridge_w", tie_spec), inner[1]),
         "recess_h", enclosure_dimension(plist_get("recess_h", tie_spec), floor_t),
         "end_dist", enclosure_dimension(plist_get("end_dist", tie_spec), inner[0]),
         "path_clearance", enclosure_dimension(plist_get("path_clearance", tie_spec), min(inner[0], inner[1])),
         "bolt_clearance", enclosure_dimension(plist_get("bolt_clearance", tie_spec), min(inner[0], inner[1]))]),
       tie_slot = plist_get("slot_size", tie),
       tie_path = [tie_slot[0] + 2 * plist_get("path_clearance", tie),
                   plist_get("bridge_w", tie) + 2 * tie_slot[1]],
       tie_end = plist_get("end_dist", tie) + tie_slot[0] / 2,
       tie_positions = !plist_get("enabled", tie) ? []
         : concat([[inner_min[0] + tie_end, center[1], 0],
                   [inner_min[0] + inner[0] - tie_end, center[1], 0]],
                  plist_get("middle", tie)
                    ? [[regulator_pos[0] + rb[0] / 2 + gap / 2, regulator_pos[1], 0]] : []),
       header_pos = sensor_pos + rotZ(plist_get("header_pos", ip), 90),
       header_size = [plist_get("header_size", ip)[1], plist_get("header_size", ip)[0]],
       terminal_pos = sensor_pos + rotZ(plist_get("terminal_pos", ip), 90),
       refs = ["regulator", [regulator_pos[0], regulator_pos[1]],
               "sensor", [sensor_pos[0], sensor_pos[1]],
               "sensor_header", [header_pos[0], header_pos[1]],
               "sensor_terminal", [terminal_pos[0], terminal_pos[1]]],
       panels = [for (name = ["left", "right", "rear", "front"])
         let (axis = member(name, ["left", "right"]) ? 1 : 0,
              wall_refs = [for (key = plist_keys(refs))
                each [key, [plist_get(key, refs)[axis] - inner_min[axis], inner[2] / 2]]],
              protected = [for (pos = lid_positions)
                [[pos[axis] - inner_min[axis] - boss_d / 2, 0], [boss_d, inner[2]]]])
         each [name, enclosure_panel_props(plist_get(name, walls), [inner[axis], inner[2]], wall_refs, protected)]],
       lid_size = [body[0], body[1]],
       lid_refs = [for (key = plist_keys(refs)) each [key, plist_get(key, refs) + lid_size / 2]],
       texts = [for (spec = plist_get("texts", lid, []))
         _power_enclosure_text(spec, plist_get("text_style", lid), lid_size, lid_refs,
                                lid_t, plist_get("text_depth", lid))],
       header_slot = plist_get("header_slot", pl),
       lid_slots = concat(plist_get("slots", lid, []),
         plist_get("enabled", header_slot) && min(header_size) > 0
           ? [["at", "sensor_header", "size", header_size
                 + 2 * enclosure_dimensions(plist_get("clearance", header_slot), header_size),
               "corner_r", plist_get("corner_r", header_slot)]] : []),
       lid_panel = enclosure_panel_props(plist_merge(lid, ["slots", lid_slots]), lid_size, lid_refs,
         [for (pos = lid_positions)
           [[pos[0] + body[0] / 2 - boss_d / 2, pos[1] + body[1] / 2 - boss_d / 2], [boss_d, boss_d]]]))
  assert(min(inner) > 0 && inner[0] >= board_span[0] && inner[1] >= board_span[1]
         && inner[2] >= board_h, "inner_size must contain the populated board group")
  assert(len([for (i = [0, 1])
    if (group_min[i] < inner_min[i] || group_min[i] + board_span[i] > inner_min[i] + inner[i] + 0.000001) 1]) == 0,
         "board_pos must keep the board group inside the cavity")
  assert(len([for (pos = lid_positions, board = [[regulator_pos, [rb[0], rb[1]]],
                                                [sensor_pos, [ib[1], ib[0]]]])
    if (_power_enclosure_rect_distance(board[0], board[1], pos) < boss_d / 2) 1]) == 0,
         "Insert bosses overlap a PCB; increase inner_size or end_clearance")
  assert(min(ts) > 0 && floor_t > pcb_bore_h && lid_t > 0, "Walls, lid and PCB counterbore floors need positive material")
  assert(plist_get("d", insert) > plist_get("hole_d", insert)
         && plist_get("h", insert) > 0 && plist_get("wall", insert_mount) > 0
         && inner[2] >= insert_depth + plist_get("floor", insert_mount),
         "Insert needs radial wall and a closed bottom beneath its full pocket depth")
  assert(lid_bolt_l > lid_t && lid_bolt_l <= lid_t + insert_depth,
         "Lid screw must engage the insert without bottoming in its pocket")
  assert(plist_get("lip_h", lid) < inner[2] && plist_get("lip_w", lid) > 0
         && plist_get("clearance", lid) >= 0 && plist_get("text_depth", lid) < lid_t,
         "Lid lip and engraving must fit the cavity and roof")
  assert(find_nut_prop("height", mount_d) + plist_get("nut_depth", fit) < floor_t,
         "Chassis nut pocket needs a closed supporting floor")
  assert(len([for (m = board_mounts, pos = mount_positions)
    if (norm(m[0] - pos) < mount_nut_d / 2
          + (find_bolt_head_d(m[1], "pan") + plist_get("head", fit)) / 2) 1]) == 0,
         "Chassis nut pockets overlap PCB screw recesses; adjust mount spacing or position")
  assert(len([for (pos = tie_positions, k = keepouts)
    if (_power_enclosure_rect_distance(pos, tie_path, k[0]) < k[1] + plist_get("bolt_clearance", tie)) 1]) == 0,
         "Cable-tie paths must clear PCB screws, chassis nuts and lid bosses")
  assert(!plist_get("enabled", tie) || plist_get("recess_h", tie) < floor_t,
         "Tie grooves must leave material in their bridges")
  assert(len([for (pos = tie_positions, i = [0, 1])
    if (abs(pos[i] - center[i]) + tie_path[i] / 2 > inner[i] / 2) 1]) == 0,
         "Cable-tie paths must stay inside the cavity")
  assert(len([for (k = keepouts, i = [0, 1])
    if (abs(k[0][i]) + k[1] > body[i] / 2 + 0.000001) 1]) == 0,
         "Mounts and their pockets must fit the enclosure footprint")
  ["plist", pl, "size", [body[0], body[1], body[2] + lid_t + find_bolt_head_h(plist_get("hole_d", insert), plist_get("bolt_head_type", insert))],
   "body_size", body, "inner_size", inner, "inner_center", center, "inner_min", inner_min,
   "corner_r", corner_r, "floor_t", floor_t, "walls", walls, "panels", panels,
   "lid", lid, "lid_panel", lid_panel, "texts", texts,
   "insert", insert, "insert_slot", insert_slot, "insert_mount", insert_mount,
   "boss_d", boss_d, "insert_depth", insert_depth,
   "lid_positions", lid_positions, "lid_bolt_d", lid_d, "lid_bolt_l", lid_bolt_l,
   "regulator", regulator, "sensor", sensor, "regulator_props", rp, "sensor_props", ip,
   "regulator_pos", regulator_pos, "sensor_pos", sensor_pos,
   "board_mounts", board_mounts, "pcb_bore_h", pcb_bore_h,
   "keepouts", keepouts, "mount_nut_d", mount_nut_d,
   "mount_pos", mount_pos, "mount_positions", mount_positions,
   "cable_tie", tie, "tie_positions", tie_positions, "tie_path_size", tie_path,
   "bolt_spacing", mount_pitch, "bolt_d", mount_d,
   "bore_d", find_bolt_head_d(mount_d, "pan") + plist_get("head", fit),
   "bore_h", find_bolt_head_h(mount_d, "pan") + plist_get("head_depth", fit),
   "sink", false, "wire_d", 0];

module _power_enclosure_outline(p, inset=0, inner=false) {
  s = plist_get(inner ? "inner_size" : "body_size", p);
  center = inner ? plist_get("inner_center", p) : [0, 0];
  ts = [for (name = ["left", "right", "rear", "front"])
    plist_get("t", plist_get(name, plist_get("walls", p)))];
  r = max(0, plist_get("corner_r", p) - (inner ? min(ts) : 0) - inset);
  translate(center) {
    rounded_rect([s[0] - 2 * inset, s[1] - 2 * inset], r=r, center=true, fn=32);
  }
}

// Local X follows the increasing span axis; local Y points up from the floor.
module _power_enclosure_wall_plane(p, name, extra=0) {
  s = plist_get("body_size", p);
  lo = plist_get("inner_min", p);
  t = plist_get("t", plist_get(name, plist_get("walls", p)));
  x_wall = member(name, ["left", "right"]);
  sign = member(name, ["left", "rear"]) ? -1 : 1;
  pos = x_wall
          ? [sign * (s[0] - t) / 2, lo[1], plist_get("floor_t", p)]
          : [lo[0], sign * (s[1] - t) / 2, plist_get("floor_t", p)];
  translate(pos) {
    rotate([90, 0, x_wall ? 90 : 0]) {
      linear_extrude(height=t + 2 * extra + 0.02, center=true) {
        children();
      }
    }
  }
}

module _power_enclosure_bosses(p, clearance=0) {
  for (pos = plist_get("lid_positions", p)) {
    translate(pos) {
      cylinder(d=plist_get("boss_d", p) + 2 * clearance,
                h=plist_get("body_size", p)[2], $fn=48);
    }
  }
}

module _power_enclosure_vents(p, roof=false) {
  if (roof) {
    s = plist_get("body_size", p);
    translate([-s[0] / 2, -s[1] / 2, -0.01]) {
      linear_extrude(height=plist_get("t", plist_get("lid", p)) + 0.02) {
        enclosure_panel_vents(plist_get("lid_panel", p),
                               keepouts=[for (t = plist_get("texts", p))
                                 _power_enclosure_text_bounds(t)]);
      }
    }
  } else {
    for (name = ["left", "right", "rear", "front"]) {
      _power_enclosure_wall_plane(p, name) {
        enclosure_panel_vents(plist_get(name, plist_get("panels", p)));
      }
    }
  }
}

module _power_enclosure_ports(p, extra=0, top_only=false) {
  difference() {
    for (name = ["left", "right", "rear", "front"]) {
      _power_enclosure_wall_plane(p, name, extra) {
        enclosure_panel_openings(plist_get(name, plist_get("panels", p)), top_only);
      }
    }
    _power_enclosure_bosses(p);
  }
}

module _power_enclosure_tie_slots(p) {
  tie = plist_get("cable_tie", p);
  slot = plist_get("slot_size", tie);
  pitch = plist_get("bridge_w", tie) + slot[1];
  path = plist_get("tie_path_size", p);
  floor_t = plist_get("floor_t", p);
  r = enclosure_dimension(plist_get("corner_r", tie), min(slot));
  for (pos = plist_get("tie_positions", p)) {
    translate(pos) {
      for (y = [-pitch / 2, pitch / 2]) {
        translate([0, y, -0.01]) {
          cuboid([slot[0], slot[1], floor_t + 0.02], r=r);
        }
      }
      translate([0, 0, -0.01]) {
        cuboid([path[0], path[1], plist_get("recess_h", tie) + 0.01], r=r);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  step_down_enclosure_parent_slots
  ─────────────────────────────────────────────────────────────────────────────

  Emit wiring cutters through the parent and tray floor in their shared frame.

  **Parameters:**
  - `p`: Resolved step_down_enclosure_props.
  - `parent_t`: Thickness below Z=0. The cutters also cross the tray floor.

  parent_slots.enabled defaults false. slots="auto" fills the available
  strips; a list of pos/size/corner_r plists restricts their footprint.
  Positions start at the inner cavity minimum; dimensions accept percentages.
  `axis` selects X or Y strips. Full-width material bridges protect every
  fastener and tie path. `margin`, `bolt_clearance`, and `min_width` constrain
  automatic and explicit openings alike. Cutting cannot isolate bolt islands.
 */
module step_down_enclosure_parent_slots(p, parent_t=0) {
  pl = plist_get("parent_slots", plist_get("plist", p));
  if (plist_get("enabled", pl)) {
    inner = plist_get("inner_size", p);
    size = [inner[0], inner[1]];
    lo = plist_get("inner_min", p);
    margin = enclosure_dimensions(plist_get("margin", pl), size);
    axis = plist_get("axis", pl) == "x" ? 0 : 1;
    other = 1 - axis;
    gap = enclosure_dimension(plist_get("bolt_clearance", pl), min(size));
    min_w = enclosure_dimension(plist_get("min_width", pl), size[axis]);
    r = enclosure_dimension(plist_get("corner_r", pl), min(size));
    intervals = concat([for (k = plist_get("keepouts", p))
      [k[0][axis] - k[1] - gap, k[0][axis] + k[1] + gap]],
      [for (pos = plist_get("tie_positions", p))
        [pos[axis] - plist_get("tie_path_size", p)[axis] / 2 - gap,
         pos[axis] + plist_get("tie_path_size", p)[axis] / 2 + gap]]);
    ends = qsort(concat([lo[axis] + margin[axis], lo[axis] + size[axis] - margin[axis]],
                       [for (v = intervals) each v]));
    slots = plist_get("slots", pl);
    assert(member(plist_get("axis", pl), ["x", "y"]), "parent_slots.axis must be x or y");
    assert(min(size - 2 * margin) > 0 && min_w > 0, "Parent slot margins must leave an interior area");
    translate([0, 0, -parent_t - 0.01]) {
      linear_extrude(height=parent_t + plist_get("floor_t", p) + 0.02) {
        intersection() {
          union() {
            for (i = [0 : len(ends) - 2]) {
              a = max(ends[i], lo[axis] + margin[axis]);
              b = min(ends[i + 1], lo[axis] + size[axis] - margin[axis]);
              if (b - a >= min_w && len([for (v = intervals)
                if (a < v[1] && b > v[0]) 1]) == 0) {
                pos = axis == 0 ? [a, lo[1] + margin[1]] : [lo[0] + margin[0], a];
                dims = axis == 0 ? [b - a, size[1] - 2 * margin[1]]
                                 : [size[0] - 2 * margin[0], b - a];
                translate(pos) {
                  rounded_rect(dims, r=min(r, min(dims) / 2), fn=32);
                }
              }
            }
          }
          if (slots == "auto") {
            translate(lo + margin) {
              square(size - 2 * margin);
            }
          } else {
            translate(lo) {
              enclosure_panel_openings(enclosure_panel_props(["slots", slots], size));
            }
          }
        }
      }
    }
  }
}

module _power_enclosure_base(p) {
  pl = plist_get("plist", p);
  s = plist_get("body_size", p);
  floor_t = plist_get("floor_t", p);
  fit = plist_get("fit", pl);
  mount_d = plist_get("bolt_d", p);
  nut_h = find_nut_prop("height", mount_d) + plist_get("nut_depth", fit);
  difference() {
    union() {
      difference() {
        linear_extrude(height=s[2]) {
          _power_enclosure_outline(p);
        }
        translate([0, 0, floor_t]) {
          linear_extrude(height=s[2]) {
            _power_enclosure_outline(p, inner=true);
          }
        }
      }
      _power_enclosure_bosses(p);
    }
    _power_enclosure_inserts(p, slot_mode=true);
    for (pos = plist_get("mount_positions", p)) {
      translate(pos + [0, 0, -0.01]) {
        cylinder(d=mount_d, h=floor_t + 0.02, $fn=32);
      }
      translate(pos + [0, 0, floor_t - nut_h]) {
        cylinder(d=plist_get("mount_nut_d", p), h=nut_h + 0.01, $fn=6);
      }
    }
    for (mount = plist_get("board_mounts", p)) {
      translate(mount[0]) {
        counterbore(d=mount[1] + plist_get("hole", fit), h=floor_t,
                    bore_d=find_bolt_head_d(mount[1], "pan") + plist_get("head", fit),
                    bore_h=plist_get("pcb_bore_h", p), reverse=true);
      }
    }
    _power_enclosure_vents(p);
    _power_enclosure_ports(p);
    _power_enclosure_tie_slots(p);
    step_down_enclosure_parent_slots(p);
  }
}

module _power_enclosure_lid(p) {
  s = plist_get("body_size", p);
  lid = plist_get("lid", p);
  t = plist_get("t", lid);
  lip_h = plist_get("lip_h", lid);
  lip_w = plist_get("lip_w", lid);
  clear = plist_get("clearance", lid);
  difference() {
    union() {
      linear_extrude(height=t) {
        _power_enclosure_outline(p);
      }
      if (lip_h > 0) {
        translate([0, 0, -lip_h]) {
          linear_extrude(height=lip_h + 0.01) {
            difference() {
              _power_enclosure_outline(p, inset=clear, inner=true);
              _power_enclosure_outline(p, inset=clear + lip_w, inner=true);
            }
          }
        }
      }
    }
    for (pos = plist_get("lid_positions", p)) {
      translate(pos + [0, 0, -lip_h - 0.01]) {
        cylinder(d=plist_get("lid_bolt_d", p), h=t + lip_h + 0.02, $fn=32);
        cylinder(d=plist_get("boss_d", p) + 2 * clear, h=lip_h + 0.01, $fn=48);
      }
    }
    _power_enclosure_vents(p, roof=true);
    translate([-s[0] / 2, -s[1] / 2, -lip_h - 0.01]) {
      linear_extrude(height=t + lip_h + 0.02) {
        enclosure_panel_openings(plist_get("lid_panel", p));
      }
    }
    intersection() {
      translate([0, 0, -s[2]]) {
        _power_enclosure_ports(p, extra=clear + lip_w, top_only=true);
      }
      translate([-s[0] / 2, -s[1] / 2, -lip_h - 0.01]) {
        cube([s[0], s[1], lip_h + 0.01]);
      }
    }
    translate([-s[0] / 2, -s[1] / 2, 0]) {
      for (spec = plist_get("texts", p)) {
        text_from_plist(plist=spec);
      }
    }
  }
}

module _power_enclosure_boards(p) {
  pl = plist_get("plist", p);
  floor_t = plist_get("floor_t", p);
  translate(plist_get("regulator_pos", p)) {
    step_down_voltage_regulator(plist_get("regulator", p),
                                stand_up=true,
                                show_bolt=true,
                                bolt_visible_h=floor_t
                                               - plist_get("pcb_bore_h", p));
  }
  translate(plist_get("sensor_pos", p)) {
    rotate([0, 0, 90]) {
      ina_current_sensor(plist_get("sensor", p),
                         anchor_z_mode="standoff",
                         show_standoffs=true,
                         show_terminal=true,
                         show_pins=true,
                         parent_thickness=floor_t,
                         cbore_h=plist_get("pcb_bore_h", p),
                         cbore_d=find_bolt_head_d(plist_get("bolt_d",
                                                            plist_get("sensor_props", p)),
                                                  "pan") + plist_get("head", plist_get("fit", pl)));
    }
  }
  mounts = plist_get("board_mounts", p);
  for (i = [0 : len(mounts) - 1]) {
    m = mounts[i];
    bp = plist_get(i < 4 ? "regulator_props" : "sensor_props", p);
    board = i < 4
            ? plist_get("placeholder_size", plist_get("regulator", p))
            : plist_get("size", bp);
    translate(m[0] + [0, 0, floor_t + plist_get("standoff_h", bp) + board[2]]) {
      nut(d=m[1],
          outer_d=find_nut_prop("outer_dia", m[1]) / cos(30),
          h=find_nut_prop("height", m[1]),
          show_text=false);
    }
  }
}

module _power_enclosure_inserts(p,
                                  slot_mode=false,
                                  show_bolt=false,
                                  exploded=0) {
  s = plist_get("body_size", p);
  for (pos = plist_get("lid_positions", p)) {
    translate(pos + [0, 0, s[2]]) {
      heat_insert_nut_from_plist(plist_get(slot_mode ? "insert_slot" : "insert", p),
                                 slot_mode=slot_mode,
                                 show_bolt=show_bolt,
                                 bolt_l=plist_get("lid_bolt_l", p),
                                 bolt_head_offset=plist_get("t", plist_get("lid", p)) + exploded,
                                 anchor=[0, 0, -1]);
    }
  }
}

module _power_enclosure_fasteners(p, show_lid=true, exploded=0) {
  pl = plist_get("plist", p);
  _power_enclosure_inserts(p, show_bolt=show_lid, exploded=exploded);
  mount_d = plist_get("bolt_d", p);
  nut_h = find_nut_prop("height", mount_d);
  for (pos = plist_get("mount_positions", p)) {
    translate(pos + [0, 0, plist_get("floor_t", p) - nut_h
                     - plist_get("nut_depth", plist_get("fit", pl))]) {
      nut(d=mount_d, outer_d=find_nut_prop("outer_dia", mount_d) / cos(30),
          h=nut_h, show_text=false);
    }
  }
}

/**
   ─────────────────────────────────────────────────────────────────────────────
   step_down_voltage_enclosure
   ─────────────────────────────────────────────────────────────────────────────

   Render the enclosed power module or its chassis mounting cutouts.

   **Parameters:**
   - `plist`: Enclosure overrides; see `step_down_enclosure_props`.
   - `anchor`: Closed enclosure envelope anchor; default positive XYZ.
   - `orientation`: Logical axis order accepted by `with_orientation`.
   - `parent_t`: Chassis thickness below the enclosure's mounting surface.
   - `slot_mode`: Emit chassis mounting holes, head recesses and enabled
     wiring passages through the parent and tray floor.
   - `show_enclosure`: Display the tray.
   - `color_alpha`: Tray opacity; the plist can override it.
   - `lid_color_alpha`: Lid opacity; the plist can override it.
   - `show_hardware`: Display both populated boards and PCB mounting hardware.
   - `show_lid`: Display the removable cover.
   - `show_fasteners`: Display lid screws, inserts and chassis captive nuts.
   - `exploded`: Lift the lid and its screws for inspection; anchor stays fixed.

   The reference box starts at the base underside and includes lid screw heads.
   The regulator's input is -X and its output is +X. The INA's terminal faces
   the regulator; its pin header faces +X. Mounting and slot modes share datums.
 */
module step_down_voltage_enclosure(plist=[],
                                   anchor=[1, 1, 1],
                                   orientation="wlh",
                                   parent_t=6,
                                   color_alpha=color_alpha,
                                   show_enclosure=show_enclosure,
                                   lid_color_alpha=lid_color_alpha,
                                   slot_mode=slot_mode,
                                   show_hardware=show_hardware,
                                   show_lid=show_lid,
                                   show_fasteners=show_fasteners,
                                   exploded=exploded_lid_h) {
  p = step_down_enclosure_props(plist);
  pl = plist_get("plist", p);
  with_orientation(to=orientation, anchor=anchor, size=plist_get("size", p)) {
    if (slot_mode) {
      translate(plist_get("mount_pos", p)) {
        pcb_mount_slots(p, parent_t);
      }
      step_down_enclosure_parent_slots(p, parent_t);
    } else {
      if (show_enclosure) {
        color(plist_get("color", pl),
              alpha=plist_get("color_alpha", pl, color_alpha)) {
          _power_enclosure_base(p);
        }
      }

      if (show_lid) {
        translate([0, 0, plist_get("body_size", p)[2] + exploded]) {
          color(plist_get("lid_color", pl),
                alpha=plist_get("lid_color_alpha", pl, lid_color_alpha)) {
            _power_enclosure_lid(p);
          }
        }
      }
      if (show_hardware) {
        _power_enclosure_boards(p);
      }
      if (show_fasteners) {
        _power_enclosure_fasteners(p=p, show_lid=show_lid, exploded=exploded);
      }
    }
  }
}

/**
   ─────────────────────────────────────────────────────────────────────────────
   step_down_enclosure_printable
   ─────────────────────────────────────────────────────────────────────────────

   Place a base or an inverted lid flat on the print bed.

   **Parameters:**
   - `part`: `"base"`, `"lid"`, or `"both"` for separated parts.
   - `plist`: Enclosure overrides accepted by `step_down_enclosure_props`.
   - `gap`: Edge gap between the base and lid in the combined layout.
 */
module step_down_enclosure_printable(part="both", plist=[], gap=6) {
  p = step_down_enclosure_props(plist);
  s = plist_get("body_size", p);
  pl = plist_get("plist", p);
  assert(member(part, ["base", "lid", "both"]),
         "Part must be base, lid or both");
  if (part != "lid") {
    _power_enclosure_base(p);
  }
  if (part != "base") {
    translate([0,
               part == "both" ? s[1] + gap : 0,
               plist_get("t", plist_get("lid", p))]) {
      rotate([180, 0, 0]) {
        _power_enclosure_lid(p);
      }
    }
  }
}

module step_down_enclosure_plate(plist=step_down_enclosure_plist) {
  props = step_down_enclosure_props(plist);
  size = plist_get("size", props);
  w = size[0];

  step_down_voltage_enclosure(plist=plist,
                              anchor=[0, 0, 1],
                              orientation="lwh");

  if (show_lid_at_the_side) {
    translate([w / 2, 0, 0]) {
      rotate([180, 0, 0]) {
        step_down_voltage_enclosure(plist,
                                    lid_color_alpha=1.0,
                                    orientation="lwh",
                                    anchor=[1, 0, -1],
                                    show_lid=true,
                                    show_enclosure=false,
                                    show_hardware=false,
                                    show_fasteners=false);
      }
    }
  }
}

step_down_enclosure_plate();
