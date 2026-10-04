/**
  * Module: Shared Wago mounting transforms and conservative chassis placement.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../lib/plist.scad>
use <wago_bracket.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  wago_mount_size
  ─────────────────────────────────────────────────────────────────────────────
  Return a rotated bracket's axis-aligned envelope.
  **Parameters:**
  - `spec`: Mount plist with optional `bracket` plist and Z `rotation` in degrees.
 */
function wago_mount_size(spec) =
  let (s = plist_get("size", wago_bracket_props(plist_get("bracket", spec,
                                                          []))),
       a = plist_get("rotation", spec, 0))
  assert(is_num(a), "Wago rotation must be a numeric Z angle")
  [abs(cos(a)) * s[0] + abs(sin(a)) * s[1],
   abs(sin(a)) * s[0] + abs(cos(a)) * s[1], s[2]];

function _wago_bounds(pos, size, pad=0) =
  let (px = pos[0],
       py = pos[1],
       pz = pos[2],
       hx = size[0] / 2,
       hy = size[1] / 2,
       sz = size[2])
  [[px - hx - pad, py - hy - pad, pz],
   [px + hx + pad, py + hy + pad, pz + sz]];

function _wago_overlap(a, b) =
  a[0][0] < b[1][0] && a[1][0] > b[0][0]
  && a[0][1] < b[1][1] && a[1][1] > b[0][1];

function _wago_inside(a, b) =
  a[0][0] >= b[0][0] && a[1][0] <= b[1][0]
  && a[0][1] >= b[0][1] && a[1][1] <= b[1][1];

function _wago_clear(a, obstacles) =
  len([for (b = obstacles) if (_wago_overlap(a, b)) 1]) == 0;

/**
  ─────────────────────────────────────────────────────────────────────────────
  wago_chassis_mounts
  ─────────────────────────────────────────────────────────────────────────────
  Place optional brackets without moving existing motor, panel or battery holes.
  **Parameters:**
  - `specs`: List of mount plists. `placement` is auto (default), under or after.
    `rotation` is a Z angle; `bracket` holds bracket parameters; `gap` defaults
    to 3 mm around the footprint; `service_h` defaults to 12 mm above the clip.
    Optional `pos` is a native chassis XY center for under placement.
  - `payload`: Resolved raised battery mount, or undef.
  - `obstacles`: XY exclusion boxes for motor, panels and maintenance access.
  - `plate_t`: Chassis thickness, used as the bracket base Z datum.
  - `i`: Recursive entry index; callers normally omit it.
  - `placed`: Already resolved mounts; callers normally omit it.
  **Returns:**
  List of plists with `pos`, `size`, padded `bounds`, and resolved `placement`.
  Auto searches a 2 mm grid beneath the case, including its supporting columns.
  If no candidate fits, it adds a row beyond all components toward native -Y
  (the flat joining edge). This may lengthen the plate, never its hole pattern.
  Explicit under placement fails when its reserved envelope cannot fit.
 */
function wago_chassis_mounts(specs,
                             payload,
                             obstacles,
                             plate_t,
                             i=0,
                             placed=[]) =
  assert(is_list(specs), "Wago mounts must be a list")
  i >= len(specs) ? placed :
  let (spec = specs[i],
       size = wago_mount_size(spec),
       mode = plist_get("placement", spec, "auto"),
       gap = plist_get("gap", spec, 3),
       service = plist_get("service_h", spec, 12),
       pb = is_undef(payload) ? undef : plist_get("bounds", payload),
       columns = is_undef(payload) ? []
       : [for (xy = plist_get("mount_holes", payload))
         _wago_bounds(concat(xy, [0]),
                      [2 * plist_get("radius", payload),
                       2 * plist_get("radius", payload), 0])],
       exclusions = concat(obstacles, columns,
                           [for (p = placed) plist_get("bounds", p)]),
       explicit = plist_get("pos", spec),
       headroom = is_undef(payload) ? 0 : plist_get("mount_z", payload)-plate_t,
       candidates = is_undef(pb) || headroom < size[2] + service ? []
       : !is_undef(explicit) ? [concat(explicit, [plate_t])]
       : [for (y = [pb[0][1] + size[1]/2 + gap:2:pb[1][1]-size[1]/2-gap],
               x = [pb[0][0] + size[0]/2 + gap:2:pb[1][0]-size[0]/2-gap]) [x, y, plate_t]],
       fits = [for (pos = candidates)
         let (b = _wago_bounds(pos, size, gap))
             if (_wago_inside(b, pb) && _wago_clear(b, exclusions)) pos],
       under = mode != "after" && len(fits) > 0,
       all_bounds = concat(exclusions, is_undef(pb) ? [] : [pb]),
       edge = len(all_bounds) == 0 ? 0 : min([for (b = all_bounds) b[0][1]]),
       pos = under ? fits[0] : [0, edge-gap-size[1] / 2, plate_t],
       result = plist_merge(spec, ["pos", pos,
                                   "size", size,
                                   "bounds", _wago_bounds(pos, size, gap),
                                   "placement", under ? "under" : "after"]))

    assert(mode == "auto" || mode == "under" || mode == "after",
           "Invalid Wago placement")
    assert(gap >= 0 && service >= 0,
           "Wago mounting clearances must be nonnegative")
    assert(is_undef(explicit) || (is_list(explicit) && len(explicit) == 2
                                  && is_num(explicit[0]) && is_num(explicit[1])),
           "Wago pos must be an XY center in native chassis coordinates")
    assert(mode != "under" || under,
           "Wago does not fit below the case with existing holes; use placement=auto or after")
    wago_chassis_mounts(specs,
                        payload,
                        obstacles,
                        plate_t,
                        i + 1,
                        concat(placed, [result]));

/**
  ─────────────────────────────────────────────────────────────────────────────
  wago_mounts
  ─────────────────────────────────────────────────────────────────────────────
  Render brackets or matching parent-plate holes at common mounting datums.
  **Parameters:**
  - `mounts`: Mount plists with XY or XYZ `pos`, Z `rotation`, and `bracket`.
  - `z`: Surface height used with XY positions (default zero).
  - `slot_mode`: Emit parent through holes down from each surface datum.
  - `parent_t`: Parent plate thickness for slot mode (default 3).
  - `show_wago`: Show hardware in the cradles (default true).
  - `show_bolts`: Show bracket mounting bolts (default false). Length is the
    next even mm covering parent, base and 3 mm nut allowance; per-mount bolt_l
    overrides it. Supply parent_t in both solid and slot modes for hardware.
 */
module wago_mounts(mounts=[],
                   z=0,
                   slot_mode=false,
                   parent_t=3,
                   show_wago=true,
                   show_bolts=false) {
  for (spec = mounts) {
    let (pos = plist_get("pos", spec, [0, 0]),
         bracket_props = wago_bracket_props(plist_get("bracket", spec, [])),
         base_t = plist_get("base_t", bracket_props),
         bolt_l_default = 2 * ceil((parent_t + base_t + 3) / 2)) {
      assert(is_list(pos) && (len(pos) == 2 || len(pos) == 3),
             "Wago mount needs XY or XYZ pos");
      translate(len(pos) == 2 ? concat(pos, [z]) : pos) {
        rotate([0, 0, plist_get("rotation", spec, 0)]) {
          translate([0, 0, slot_mode ? -parent_t : 0]) {
            wago_bracket(pl=plist_get("bracket", spec, []),
                         anchor=[0, 0, 1],
                         slot_mode=slot_mode,
                         slot_h=parent_t,
                         show_wago=show_wago,
                         show_bolts=show_bolts,
                         bolt_l=plist_get("bolt_l", spec, bolt_l_default));
          }
        }
      }
    }
  }
}
