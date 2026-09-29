/**
  * Module: Shared dovetail interface for the multi-pack case and lid.
  *
  * Rails use canonical case coordinates; their matching channels slide along
  * X or Y. Dimensions and locking holes are shared by both printed parts.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/slider.scad>
use <../lib/slots.scad>
use <../placeholders/bolt.scad>

function _lipo_rail_segments(segments, cuts, i=0) =
  i >= len(cuts) ? segments :
  _lipo_rail_segments([for (s = segments) each
                                            cuts[i][1] <= s[0] || cuts[i][0] >= s[1] ? [s] :
                                            concat(cuts[i][0] > s[0] ? [[s[0], cuts[i][0]]] : [],
                                                   cuts[i][1] < s[1] ? [[cuts[i][1], s[1]]] : [])],
                      cuts,
                      i + 1);

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_rail_props
  ─────────────────────────────────────────────────────────────────────────────

  Resolve the shared rail profiles, supported lengths, and locking holes.

  **Parameters:**

  `pl`: Case plist. Omit `rail`, or set its `enabled=false`, to disable rails.
  `rail.axis` is "auto", "x" (rear/front walls), or "y" (left/right walls).
  Auto chooses the tallest opposing pair, preferring the longer pair on ties.
  Both supporting walls must share the highest outer-wall height. `h` defaults
  to 4 mm, `angle` to 12 degrees, and `clearance` to 0.2 mm per mating face.
  `end_pad` is an inset at both wall ends (mm or percentage of retained length),
  defaulting to the exterior corner radius. The inset grows to clear rounded
  wall-top corners. Rails stop at all top-open cutouts.
  Optional `bolt_d` enables transverse locking holes (zero disables them).
  Hole height leaves clearance for the matching nut above the case rim.
  `bolt_pad` locates two holes from the ends of each rail's longest continuous
  segment (mm or percentage, default "20%").
  `size`: Canonical case shell size, including the floor, excluding rails.
  `walls`: Resolved `wall_props` from the case layout.

  **Returns:**

  A plist with `enabled`, `axis`, `h`, `z`, `angle`, `clearance`, `bolt_d`, and
  `rails`. Each rail describes its wall, width, transverse center, start,
  length, supported segments, and locking-hole coordinates along the slide.
 */
function multi_lipo_pack_rail_props(pl, size, walls) =
  let (spec = plist_get("rail", pl))
  is_undef(spec) || !plist_get("enabled", spec, true) ? ["enabled", false] :
  let (names = ["rear", "front", "left", "right"],
       heights = [for (name = names) let (wall = plist_get(name, walls))
                                       plist_get("l", wall) > 0 ? plist_get("h", wall) : 0],
       lengths = [for (name = names) plist_get("l", plist_get(name, walls))],
       x_h = min(heights[0], heights[1]),
       y_h = min(heights[2], heights[3]),
       request = plist_get("axis", spec, "auto"))
  assert(in_list(request, ["auto", "x", "y"]),
         "rail axis must be auto, x, or y")
  let (axis = request != "auto" ? request :
       x_h > y_h || (x_h == y_h && min(lengths[0], lengths[1]) >= min(lengths[2], lengths[3])) ? "x" : "y",
       chosen = axis == "x" ? ["rear", "front"] : ["left", "right"],
       wall_h = axis == "x" ? x_h : y_h,
       all_walls = plist_get("walls", pl),
       floor_t = plist_get("bottom_t", pl, plist_get("t", plist_get("bottom", all_walls))),
       h = plist_get("h", spec, 4),
       angle = plist_get("angle", spec, 12),
       clearance = plist_get("clearance", spec, 0.2),
       bolt_d = plist_get("bolt_d", spec, 0),
       bolt_z = bolt_d > 0 ? max(h / 2, find_nut_prop("outer_dia", bolt_d) / 2 + clearance) : h / 2)
  assert(wall_h > 0 && abs(wall_h - max(heights)) < 0.000001,
         "Dovetail rails require two opposing walls at the highest outer-wall height")
  assert(h > 0 && angle > 0 && angle < 45 && clearance >= 0 && bolt_d >= 0,
         "Invalid rail height, angle, clearance, or bolt diameter")
  assert(bolt_d == 0 || (bolt_z >= bolt_d / 2 + 0.5 && h - bolt_z >= bolt_d / 2 + 0.5),
         "Increase rail height: locking holes need 0.5 mm lands and their nuts must clear the pack")
  ["enabled", true, "axis", axis, "h", h, "z", floor_t + wall_h,
   "angle", angle, "clearance", clearance,
   "clearance_w", clearance * (1 / cos(angle) + tan(angle)),
   "bolt_d", bolt_d, "bolt_z", bolt_z,
   "rails", [for (i = [0:1])
        let (name = chosen[i],
             wall = plist_get(name, walls),
             t = plist_get(str(name, "_t"), pl, plist_get("t", plist_get(name, all_walls))),
             pad = maybe_percent_string_to_num(plist_get("end_pad", spec, plist_get("corner_r", pl, 0)), plist_get("l", wall)),
             inset = max(pad, plist_get("corner_r", wall, 0)),
             start = plist_get("offset", wall) + inset,
             end = plist_get("offset", wall) + plist_get("l", wall) - inset,
             cuts = [for (cut = plist_get("cutouts", wall))
                 if (plist_get("h", cut) > 0)
                   [plist_get("offset", wall) + plist_get("offset", cut),
                    plist_get("offset", wall) + plist_get("offset", cut) + plist_get("l", cut)]],
             segments = _lipo_rail_segments([[start, end]], cuts))
          assert(pad >= 0 && end > start && len(segments) > 0,
                 "No supported rail remains on the wall")
          assert(t - h * tan(angle) > 0.5,
                 "Rail waist must exceed 0.5 mm; increase wall thickness or reduce rail h/angle")
          assert(2 * clearance < h * tan(angle),
                 "Rail clearance removes the dovetail's retaining shoulders")
          let (longest = sort_by_idx([for (s = segments) [s[1] - s[0], s]], asc=false)[0][1],
               bolt_pad = maybe_percent_string_to_num(plist_get("bolt_pad", spec, "20%"), longest[1] - longest[0]),
               cross = i == 0 ? t / 2 : size[axis == "x" ? 1 : 0] - t / 2)
          assert(bolt_d == 0 || (bolt_pad >= bolt_d / 2 + 1
                                 && 2 * bolt_pad + bolt_d < longest[1] - longest[0]),
                 "Locking holes must fit inside a continuous rail segment")
          ["wall", name, "w", t, "cross", cross, "start", start, "l", end - start,
           "segments", segments, "bolts", bolt_d == 0 ? [] : [longest[0] + bolt_pad, longest[1] - bolt_pad]]]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_rail_shape
  ─────────────────────────────────────────────────────────────────────────────

  Emit the common rail profile or its offset sliding-channel cutter.

  **Parameters:**

  `props`: Resolved rail properties.
  `rail`: One entry from `props.rails`.
  `clearance`: Outward profile offset; zero emits the solid rail.
  `start`: Optional extrusion start along the slide axis.
  `l`: Optional extrusion length; defaults to the rail's full retained span.
  `z_offset`: Additional vertical translation, useful for lid-local coordinates.
 */
module multi_lipo_pack_rail_shape(props,
                                  rail,
                                  clearance=0,
                                  start,
                                  l,
                                  z_offset=0) {
  axis = plist_get("axis", props);
  along = is_undef(start) ? plist_get("start", rail) : start;
  length = is_undef(l) ? plist_get("l", rail) : l;
  cross = plist_get("cross", rail);
  translate([axis == "x" ? along : cross,
             axis == "x" ? cross : along,
             plist_get("z", props) + z_offset + plist_get("h", props) / 2]) {
    rotate([90, 0, axis == "x" ? 90 : 180]) {
      linear_extrude(height=length, convexity=4) {
        offset(delta=clearance) {
          dovetail_rib(w=plist_get("w", rail),
                       h=plist_get("h", props),
                       angle=plist_get("angle", props),
                       r=0,
                       center=true);
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_rail_holes
  ─────────────────────────────────────────────────────────────────────────────

  Emit the shared transverse locking-hole pattern.

  **Parameters:**

  `props`: Resolved rail properties.
  `rail`: One resolved rail.
  `depth`: Cutter length across the rail, centered on its transverse center.
  `z_offset`: Vertical translation from canonical case coordinates.
 */
module multi_lipo_pack_rail_holes(props, rail, depth, z_offset=0) {
  axis = plist_get("axis", props);
  for (along = plist_get("bolts", rail)) {
    let (bolt_d = plist_get("bolt_d", props)) {
      translate([axis == "x" ? along : plist_get("cross", rail),
                 axis == "x" ? plist_get("cross", rail) : along,
                 plist_get("z", props) + plist_get("bolt_z", props) + z_offset]) {
        rotate(axis == "x" ? [90, 0, 0] : [0, 90, 0]) {
          translate([0, 0, -depth / 2]) {
            counterbore(h=depth,
                        d=bolt_d,
                        teardrop_angle=45,
                        teardrop_both_sides=true);
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_rails
  ─────────────────────────────────────────────────────────────────────────────

  Render the supported case rails with their locking holes.

  **Parameters:**

  `props`: Resolved rail properties. Disabled rails emit no geometry.
 */
module multi_lipo_pack_rails(props) {
  if (plist_get("enabled", props, false)) {
    for (rail = plist_get("rails", props)) {
      difference() {
        union() {
          for (segment = plist_get("segments", rail)) {
            multi_lipo_pack_rail_shape(props,
                                       rail,
                                       start=segment[0],
                                       l=segment[1] - segment[0]);
          }
        }
        multi_lipo_pack_rail_holes(props,
                                   rail,
                                   depth=plist_get("w", rail) + 0.2);
      }
    }
  }
}
