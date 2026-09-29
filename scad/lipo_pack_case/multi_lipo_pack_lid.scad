/**
  * Module: Sliding multi-pack power lid with a shared dovetail and lidar mount.
  *
  * The assembled lid has its roof above the channels. Printable mode places
  * the exterior roof face on the bed, with channels and skirts facing up.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../steering_params.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/lidar.scad>
use <../placeholders/standoff.scad>
use <../wago/wago_mounts.scad>
use <multi_lipo_pack_adapter.scad>
use <multi_lipo_pack_case.scad>
use <multi_lipo_pack_rail.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_lid_props
  ─────────────────────────────────────────────────────────────────────────────

  Size a lid from the case rails and optional lidar hardware.

  **Parameters:**

  `pl`: Case plist with enabled `rail` and optional `lid` properties.
  `lid.t` is roof thickness (default 3), `side_t` material beside each channel
  (default 2), and `headroom` the space above the rail before the roof (default
  10). `lidar` is a hardware plist or undef for a plain roof. `lidar_offset`
  locates its center relative to the case center; `lidar_orientation` defaults
  to "wlh". `lidar_pad` (default 2) is the margin around its footprint.
  `corner_r` rounds the roof outline and skirt tips (default zero), in mm or
  percent of the smaller roof dimension, capped at half that dimension.
  `adapter` enables a separate captive-nut sensor plate; omit it for direct
  mounting. Its interface is described by `multi_lipo_pack_adapter_props()`.
  `lidar_target_h` is the minimum sensor-base height above the roof (default
  13). With an adapter, its thickness is deducted before selecting standoffs.
  The roof expands symmetrically to accommodate the hardware and channels.
  `l_clearance`: Pack-cell Y clearance, shared with the case.
  `w_clearance`: Pack-cell X clearance, shared with the case.

  **Returns:**

  `size` is the oriented lid envelope, `canonical_size` its unrotated size,
  `mount_z` the channel-bottom height above the case floor underside, and
  `case_props`/`rail_props` the shared mechanical references. Hardware is
  excluded from the printed lid envelope, as is the separate adapter.
  `adapter_props` resolves that plate; `lidar_base_z` includes its thickness
  and the selected standoff height in the same lid-local frame.
 */
function multi_lipo_pack_lid_props(pl, l_clearance=0.4, w_clearance=0.4) =
  let (case_props = multi_lipo_pack_props(pl, l_clearance, w_clearance),
       rails = plist_get("rail_props", case_props),
       spec = plist_get("lid", pl, []))
  assert(plist_get("enabled", rails),
         "A sliding lid requires enabled case rails")
  let (body = plist_get("body_size", case_props),
       axis = plist_get("axis", rails),
       clearance = plist_get("clearance", rails),
       channel_pad = plist_get("clearance_w", rails),
       t = plist_get("t", spec, 3),
       side_t = plist_get("side_t", spec, 2),
       headroom = plist_get("headroom", spec, 10),
       lidar_pl = plist_get("lidar", spec),
       lidar_orientation = plist_get("lidar_orientation", spec, "wlh"),
       lidar_offset = plist_get("lidar_offset", spec, [0, 0]),
       lidar_pad = plist_get("lidar_pad", spec, 2),
       lidar_dims = is_undef(lidar_pl) ? [0, 0, 0]
       : orientation_size(lidar_orientation, lidar_size(lidar_pl)),
       footprint = [for (i = [0:1]) max(body[i] + (i == (axis == "x" ? 1 : 0) ? 2 * (side_t + channel_pad) : 0),
                                        is_undef(lidar_pl) ? 0 : lidar_dims[i] + 2 * (lidar_pad + abs(lidar_offset[i])))],
       mount_z = plist_get("z", rails),
       roof_z = max(plist_get("h", rails) + clearance + headroom, body[2] - mount_z + clearance + side_t),
       size = concat(footprint, [roof_z + t]),
       orientation = plist_get("orientation", case_props))
       assert(t > 0 && side_t > 0 && headroom >= side_t && lidar_pad >= 0,
              "Lid roof and side thickness must be positive; headroom must leave material above the channels")
       assert(in_list(lidar_orientation, ["wlh", "lwh"]),
              "Lidar must remain upright on the roof")
  assert(is_list(lidar_offset) && len(lidar_offset) == 2 && is_num(lidar_offset[0]) && is_num(lidar_offset[1]),
         "lidar_offset must be a numeric XY vector")
       let (radius = maybe_percent_string_to_num(plist_get("corner_r", spec, 0), min(footprint)))
       assert(is_num(radius) && radius >= 0,
              "Lid corner_r must be nonnegative mm or percent")
       let (base = ["size", orientation_size(orientation, size), "canonical_size", size,
                    "mount_z", mount_z, "roof_z", roof_z, "t", t, "side_t", side_t,
                    "case_props", case_props, "rail_props", rails,
                    "lidar", lidar_pl, "lidar_orientation", lidar_orientation, "lidar_offset", lidar_offset,
                    "corner_r", calc_corner_rad(footprint, radius)],
            adapter = multi_lipo_pack_adapter_props(plist_get("adapter", spec), base),
            adapter_h = plist_get("enabled", adapter, false) ? plist_get("size", adapter)[2] : 0,
            target_h = plist_get("lidar_target_h", spec, 13),
            standoff_target_h = max(0, target_h - adapter_h))
       assert(is_undef(lidar_pl) || standoff_target_h > 0,
              "lidar_target_h must exceed the adapter thickness to leave room for standoffs")
       concat(base,
              ["adapter_props", adapter, "adapter_h", adapter_h,
               "standoff_target_h", standoff_target_h,
               "lidar_base_z", is_undef(lidar_pl) ? undef : size[2] + adapter_h
               + standoff_real_h(standoff_target_h, plist_get("bolt_d", lidar_pl))]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_lid_wago_mounts
  ─────────────────────────────────────────────────────────────────────────────
  Validate bracket footprints on the existing roof without moving its hardware.
  **Parameters:**
  - `pl`: Case plist; lid.wago_mounts is a list of bracket mount specs.
    Each requires XY `pos` from the canonical roof center; optional `rotation`
    is a Z angle, `bracket` its component plist, and `gap` a 2 mm margin.
  - `props`: Resolved lid properties from multi_lipo_pack_lid_props.
  **Returns:**
  The mount list, after checking roof edges, neighboring brackets and the full
  lidar/adapter XY envelope. Coordinates rotate with the case orientation.
 */
function multi_lipo_pack_lid_wago_mounts(pl, props) =
  let (mounts = plist_get("wago_mounts", plist_get("lid", pl, []), []),
       size = plist_get("canonical_size", props),
       sensor = plist_get("lidar", props),
       adapter = plist_get("adapter_props", props),
       sensor_size = is_undef(sensor) ? [0, 0, 0]
       : orientation_size(plist_get("lidar_orientation", props), lidar_size(sensor)),
       adapter_size = plist_get("size", adapter, [0, 0, 0]),
       occupied = [for (i=[0:2]) max(sensor_size[i], adapter_size[i])],
       sensor_box = _wago_bounds(concat(plist_get("lidar_offset", props), [0]), occupied),
       boxes = [for (m = mounts)
           let (pos = plist_get("pos", m), gap = plist_get("gap", m, 2))
             assert(is_list(pos) && len(pos) == 2 && is_num(pos[0]) && is_num(pos[1]),
                    "Lid Wago pos must be a canonical XY roof-center offset")
             assert(is_num(gap) && gap >= 0, "Lid Wago gap must be nonnegative")
             _wago_bounds(concat(pos, [0]), wago_mount_size(m), gap)],
       radius = plist_get("corner_r", props),
       roof = [[-size[0]/2, -size[1]/2, 0], [size[0]/2, size[1]/2, 0]],
       outside_corners = [for (b = boxes, x = [b[0][0], b[1][0]], y = [b[0][1], b[1][1]])
           if (norm([max(0, abs(x)-size[0]/2 + radius),
                     max(0, abs(y)-size[1]/2 + radius)]) > radius + 0.000001) 1])
                     assert(is_list(mounts), "lid.wago_mounts must be a list")
                     assert(len(outside_corners) == 0
                            && len([for (b = boxes) if (!_wago_inside(b, roof)) 1]) == 0,
                            "Wago bracket and margin must fit the existing lid roof")
                     assert(is_undef(sensor) || len([for (b = boxes) if (_wago_overlap(b, sensor_box)) 1]) == 0,
                            "Wago bracket overlaps the lidar or adapter envelope")
                     assert(len([for (i=[0:1:len(boxes)-1], j=[0:1:i-1])
                                    if (_wago_overlap(boxes[i], boxes[j])) 1]) == 0,
                            "Wago brackets overlap on the lid")
                     mounts;

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_lid
  ─────────────────────────────────────────────────────────────────────────────

  Render the assembled lid, its mounting cutters, or optional hardware.

  **Parameters:**

  `pl`: Case/lid plist accepted by `multi_lipo_pack_lid_props()`.
  `anchor`: Anchor on the final oriented printed lid envelope.
  `show_lid`: Display the printed lid.
  `show_lidar`: Display the lidar and its mounting standoffs, independent of lid visibility.
  `show_bolts`: Display rail-locking and adapter-to-lid bolts and nuts.
  Rail-locking heads face inward; their nuts seat on the exterior skirts.
  `show_adapter`: Display the separate adapter plate (default false).
  `slot_mode`: Emit rail-locking and active lid mounting cutters (adapter or
  direct lidar), in the same frame.
  `l_clearance`: Pack-cell Y clearance, shared with the case.
  `w_clearance`: Pack-cell X clearance, shared with the case.

  `show_wago_brackets`: Display configured brackets (default false for printing).
  `show_wagos`: Display connectors in shown brackets (default true).

  `lid.vents` accepts the same vent properties as a case wall. Vents occupy the
  skirt above the channels; the rail grooves and roof retain solid material.
  In this dedicated `vents` plist, `corner_r` is an alias for `vent_corner_r`;
  the explicit `vent_corner_r` takes precedence when both are provided.
  `lid.wago_mounts` adds bracket holes; see multi_lipo_pack_lid_wago_mounts.
  `lid.color` overrides the case color. Lid coordinates start at the channel
  bottom, with the roof above it; mounting height is returned separately.
 */
module multi_lipo_pack_lid(pl,
                           anchor=[0, 0, 1],
                           show_lid=true,
                           show_lidar=false,
                           show_bolts=false,
                           slot_mode=false,
                           l_clearance=0.4,
                           w_clearance=0.4,
                           show_adapter=false,
                           show_wago_brackets=false,
                           show_wagos=true) {
  props = multi_lipo_pack_lid_props(pl, l_clearance, w_clearance);
  spec = plist_get("lid", pl, []);
  wagos = multi_lipo_pack_lid_wago_mounts(pl, props);
  case_props = plist_get("case_props", props);
  body = plist_get("body_size", case_props);
  size = plist_get("canonical_size", props);
  rails = plist_get("rail_props", props);
  axis = plist_get("axis", rails);
  slide_axis = axis == "x" ? 0 : 1;
  cross_axis = 1 - slide_axis;
  mount_z = plist_get("mount_z", props);
  roof_z = plist_get("roof_z", props);
  t = plist_get("t", props);
  side_t = plist_get("side_t", props);
  clearance = plist_get("clearance", rails);
  rail_h = plist_get("h", rails);
  lidar_pl = plist_get("lidar", props);
  lidar_offset = plist_get("lidar_offset", props);
  adapter = plist_get("adapter_props", props);
  adapter_h = plist_get("adapter_h", props);
  lid_color = plist_get("color", spec, plist_get("color", pl));
  // Canonical XY remains relative to the body minimum for shared rail datums.
  roof_min = [(body[0] - size[0]) / 2, (body[1] - size[1]) / 2];

  module _mount_slots() {
    translate([body[0]/2, body[1]/2, 0]) {
      wago_mounts(wagos, z=size[2], slot_mode=true, parent_t=t);
    }
    if (plist_get("enabled", adapter, false)) {
      translate([body[0]/2 + lidar_offset[0],
                 body[1]/2 + lidar_offset[1],
                 roof_z]) {
        multi_lipo_pack_adapter_lid_slots(adapter);
      }
    } else if (!is_undef(lidar_pl)) {
      d = plist_get("bolt_d", lidar_pl);
      translate([body[0] / 2 + lidar_offset[0],
                 body[1] / 2 + lidar_offset[1],
                 roof_z]) {
        rotate([0, 0, plist_get("lidar_orientation", props) == "lwh" ? 90 : 0]) {
          translate(concat(plist_get("offsets", lidar_pl, [0, 0]), [0])) {
            four_corner_children(size=plist_get("bolt_spacing", lidar_pl),
                                 center=true) {
              counterbore(h=t,
                          d=d + 0.2,
                          bore_d=find_bolt_head_d(d, "countersunk") + 0.2,
                          bore_h=find_bolt_head_h(d, "countersunk") + 0.15,
                          sink=true,
                          reverse=true);
            }
          }
        }
      }
    }
  }

  module _slots() {
    _mount_slots();
    for (rail = plist_get("rails", rails)) {
      depth = plist_get("locking_depth", rail);
      multi_lipo_pack_rail_holes(rails, rail, depth + 0.2, z_offset=-mount_z);
    }
  }

  module _skirt_vents(rail, depth) {
    z = rail_h + clearance + side_t;
    vents = plist_get("vents", spec, []);
    vent = multi_lipo_pack_vent_props(plist_merge(vents,
                                                  ["vent_corner_r",
                                                   plist_get("vent_corner_r", vents,
                                                             plist_get("corner_r", vents, 0))]),
                                      size[slide_axis],
                                      max(0, roof_z - z));
    along = roof_min[slide_axis];
    cross = plist_get("cross", rail) - depth / 2 - 0.1;
    translate([axis == "x" ? along : cross, axis == "x" ? cross : along, z]) {
      multi_lipo_pack_vents(vent, depth + 0.2, axis=axis);
    }
  }

  module _locking_bolts() {
    for (rail = plist_get("rails", rails)) {
      multi_lipo_packs_rail_bolts(rails,
                                  rail,
                                  z_offset=-mount_z,
                                  show_nuts=true);
    }
  }

  with_orientation(from="wlh",
                   to=plist_get("orientation", case_props),
                   size=size,
                   anchor=anchor) {
    translate([-body[0] / 2, -body[1] / 2, 0]) {
      if (slot_mode) {
        _slots();
      } else {
        if (show_lid) {
          color(lid_color) {
            difference() {
              intersection() {
                translate(concat(roof_min, [0])) {
                  cuboid(size,
                         r=plist_get("corner_r", props),
                         anchor=[1, 1, 1]);
                }
                union() {
                  translate(concat(roof_min, [roof_z])) {
                    cube([size[0], size[1], t]);
                  }
                  for (rail = plist_get("rails", rails)) {
                    depth = plist_get("locking_depth", rail);
                    cross = plist_get("cross", rail) - depth / 2;
                    along = roof_min[slide_axis];
                    translate([axis == "x" ? along : cross,
                               axis == "x" ? cross : along,
                               0]) {
                      cube(axis == "x" ? [size[0], depth, roof_z + 0.01] : [depth, size[1], roof_z + 0.01]);
                    }
                  }
                }
              }
              for (rail = plist_get("rails", rails)) {
                depth = plist_get("locking_depth", rail);
                multi_lipo_pack_rail_shape(rails,
                                           rail,
                                           clearance=clearance,
                                           start=roof_min[slide_axis] - 0.1,
                                           l=size[slide_axis] + 0.2,
                                           z_offset=-mount_z);
                _skirt_vents(rail, depth);
              }
              _slots();
            }
          }
        }
        if (plist_get("enabled", adapter, false) && (show_adapter || show_bolts)) {
          translate([body[0]/2 + lidar_offset[0],
                     body[1]/2 + lidar_offset[1],
                     size[2]]) {
            color(lid_color) {
              multi_lipo_pack_adapter(adapter,
                                      show_plate=show_adapter,
                                      show_hardware=show_bolts);
            }
          }
        }
        if (show_lidar && !is_undef(lidar_pl)) {
          d = plist_get("bolt_d", lidar_pl);
          mount_pl = plist_merge(lidar_pl,
                                 ["bore_d", find_bolt_head_d(d, "countersunk") + 0.2,
                                  "bore_h", find_bolt_head_h(d, "countersunk") + 0.15, "sink", true]);
          translate([body[0] / 2 + lidar_offset[0],
                     body[1] / 2 + lidar_offset[1],
                     size[2] + adapter_h]) {
            lidar(plist=mount_pl,
                  parent_thickness=adapter_h > 0 ? adapter_h : t,
                  orientation=plist_get("lidar_orientation", props),
                  target_h=plist_get("standoff_target_h", props),
                  anchor=[0, 0, 1]);
          }
        }
        if (show_wago_brackets) {
          translate([body[0]/2, body[1]/2, 0]) {
            wago_mounts(wagos,
                        z=size[2],
                        parent_t=t,
                        show_wago=show_wagos,
                        show_bolts=show_bolts);
          }
        }
        if (show_bolts) {
          _locking_bolts();
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_lid_on_case
  ─────────────────────────────────────────────────────────────────────────────

  Place a lid using the case's envelope and anchor as the assembly reference.

  **Parameters:**

  `pl`: Case/lid plist with enabled rails.
  `anchor`: The same anchor passed to the case, including its mounting ears.
  `slide`: Translation along the canonical rail axis; zero seats the lid.
  `lift`: Additional Z translation for an exploded preview.
  `show_lid`: Display the printed lid.
  `show_lidar`: Display the lidar and its standoffs.
  `show_bolts`: Display the removable rail-locking and adapter hardware.
  `l_clearance`: Pack-cell Y clearance, shared with the case.
  `w_clearance`: Pack-cell X clearance, shared with the case.
  `show_adapter`: Display the adapter plate (default true).
  `show_wago_brackets`: Display configured roof brackets (default true).
  `show_wagos`: Display connectors in roof brackets (default true).
 */
module multi_lipo_pack_lid_on_case(pl,
                                   anchor=[0, 0, 1],
                                   slide=0,
                                   lift=0,
                                   show_lid=true,
                                   show_lidar=true,
                                   show_bolts=false,
                                   l_clearance=0.4,
                                   w_clearance=0.4,
                                   show_adapter=true,
                                   show_wago_brackets=true,
                                   show_wagos=true) {
  props = multi_lipo_pack_lid_props(pl, l_clearance, w_clearance);
  case_props = plist_get("case_props", props);
  axis = plist_get("axis", plist_get("rail_props", props));
  with_orientation(from="wlh",
                   to=plist_get("orientation", case_props),
                   size=plist_get("canonical_size", case_props),
                   anchor=anchor) {
    translate([axis == "x" ? slide : 0,
               axis == "y" ? slide : 0,
               plist_get("mount_z", props) + lift]) {
      multi_lipo_pack_lid(plist_merge(pl, ["orientation", "wlh"]),
                          anchor=[0, 0, 1],
                          show_lid=show_lid,
                          show_lidar=show_lidar,
                          show_bolts=show_bolts,
                          show_adapter=show_adapter,
                          show_wago_brackets=show_wago_brackets,
                          show_wagos=show_wagos,
                          l_clearance=l_clearance,
                          w_clearance=w_clearance);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_lid_printable
  ─────────────────────────────────────────────────────────────────────────────

  Place the lid roof-down on Z=0, with all hardware hidden.

  **Parameters:**

  `pl`: Case/lid properties. Printing uses canonical orientation.
  `anchor`: Anchor of the printed lid envelope after inversion.
  `l_clearance`: Pack-cell Y clearance, shared with the case.
  `w_clearance`: Pack-cell X clearance, shared with the case.
 */
module multi_lipo_pack_lid_printable(pl,
                                     anchor=[0, 0, 1],
                                     l_clearance=0.4,
                                     w_clearance=0.4) {
  canonical = plist_merge(pl, ["orientation", "wlh"]);
  size = plist_get("canonical_size",
                   multi_lipo_pack_lid_props(canonical, l_clearance, w_clearance));
  with_anchor(anchor, size, centered=true) {
    translate([0, 0, size[2]]) {
      rotate([180, 0, 0]) {
        multi_lipo_pack_lid(canonical,
                            anchor=[0, 0, 1],
                            l_clearance=l_clearance,
                            w_clearance=w_clearance);
      }
    }
  }
}

multi_lipo_pack_lid_printable(multi_lipo_packs_case);
