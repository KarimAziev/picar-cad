/**
  * Module: Sliding multi-pack power lid with a shared dovetail and lidar mount.
  *
  * The assembled lid has its roof above the channels. Printable mode places
  * the exterior roof face on the bed, with channels and skirts facing up.
  */
include <../steering_params.scad>
use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/lidar.scad>
use <../placeholders/nut.scad>
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
  `lidar_target_h` controls standoffs above the roof (default 13).
  The roof expands symmetrically to accommodate the hardware and channels.
  `l_clearance`: Pack-cell Y clearance, shared with the case.
  `w_clearance`: Pack-cell X clearance, shared with the case.

  **Returns:**

  `size` is the oriented lid envelope, `canonical_size` its unrotated size,
  `mount_z` the channel-bottom height above the case floor underside, and
  `case_props`/`rail_props` the shared mechanical references. Hardware is
  excluded from the printed lid envelope.
 */
function multi_lipo_pack_lid_props(pl, l_clearance=0.4, w_clearance=0.4) =
  let (case_props = multi_lipo_pack_props(pl, l_clearance, w_clearance),
       rails = plist_get("rail_props", case_props),
       spec = plist_get("lid", pl, []))
  assert(plist_get("enabled", rails), "A sliding lid requires enabled case rails")
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
  assert(in_list(lidar_orientation, ["wlh", "lwh"]), "Lidar must remain upright on the roof")
  assert(is_list(lidar_offset) && len(lidar_offset) == 2 && is_num(lidar_offset[0]) && is_num(lidar_offset[1]),
         "lidar_offset must be a numeric XY vector")
  ["size", orientation_size(orientation, size), "canonical_size", size,
   "mount_z", mount_z, "roof_z", roof_z, "t", t, "side_t", side_t,
   "case_props", case_props, "rail_props", rails,
   "lidar", lidar_pl, "lidar_orientation", lidar_orientation, "lidar_offset", lidar_offset];

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
  `show_bolts`: Display transverse rail-locking bolts and nuts.
  `slot_mode`: Emit locking and lidar mounting cutters only, in the same frame.
  `l_clearance`: Pack-cell Y clearance, shared with the case.
  `w_clearance`: Pack-cell X clearance, shared with the case.

  `lid.vents` accepts the same vent properties as a case wall. Vents occupy the
  skirt above the channels; the rail grooves and roof retain solid material.
  `lid.color` overrides the case color. Lid coordinates start at the channel
  bottom, with the roof above it; mounting height is returned separately.
 */
module multi_lipo_pack_lid(pl, anchor=[0, 0, 1], show_lid=true,
                            show_lidar=false, show_bolts=false, slot_mode=false,
                            l_clearance=0.4, w_clearance=0.4) {
  props = multi_lipo_pack_lid_props(pl, l_clearance, w_clearance);
  spec = plist_get("lid", pl, []);
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
  channel_pad = plist_get("clearance_w", rails);
  rail_h = plist_get("h", rails);
  lidar_pl = plist_get("lidar", props);
  lidar_offset = plist_get("lidar_offset", props);
  lid_color = plist_get("color", spec, plist_get("color", pl));
  // Canonical XY remains relative to the body minimum for shared rail datums.
  roof_min = [(body[0] - size[0]) / 2, (body[1] - size[1]) / 2];

  module _lidar_slots() {
    if (!is_undef(lidar_pl)) {
      d = plist_get("bolt_d", lidar_pl);
      translate([body[0] / 2 + lidar_offset[0], body[1] / 2 + lidar_offset[1], roof_z]) {
        rotate([0, 0, plist_get("lidar_orientation", props) == "lwh" ? 90 : 0]) {
          translate(concat(plist_get("offsets", lidar_pl, [0, 0]), [0])) {
            four_corner_children(size=plist_get("bolt_spacing", lidar_pl), center=true) {
              counterbore(h=t, d=d + 0.2,
                          bore_d=find_bolt_head_d(d, "countersunk") + 0.2,
                          bore_h=find_bolt_head_h(d, "countersunk") + 0.15,
                          sink=true, reverse=true);
            }
          }
        }
      }
    }
  }

  module _slots() {
    _lidar_slots();
    for (rail = plist_get("rails", rails)) {
      depth = plist_get("w", rail) + 2 * (channel_pad + side_t);
      multi_lipo_pack_rail_holes(rails, rail, depth + 0.2, z_offset=-mount_z);
    }
  }

  module _skirt_vents(rail, depth) {
    z = rail_h + clearance + side_t;
    vent = multi_lipo_pack_vent_props(plist_get("vents", spec, []), size[slide_axis], max(0, roof_z - z));
    if (plist_get("enabled", vent, false)) {
      count = plist_get("count", vent);
      start = plist_get("start", vent);
      gap = plist_get("gap", vent);
      slot = plist_get("slot_size", vent);
      if (count[0] > 0 && count[1] > 0) {
        for (col = [0:count[0] - 1], row = [0:count[1] - 1]) {
          along = roof_min[slide_axis] + start[0] + col * (slot[0] + gap[0]);
          cross = plist_get("cross", rail) - depth / 2 - 0.1;
          translate([axis == "x" ? along : cross, axis == "x" ? cross : along,
                     z + start[1] + row * (slot[1] + gap[1])]) {
            cube(axis == "x" ? [slot[0], depth + 0.2, slot[1]] : [depth + 0.2, slot[0], slot[1]]);
          }
        }
      }
    }
  }

  module _locking_bolts() {
    d = plist_get("bolt_d", rails);
    if (d > 0) {
      for (i = [0:1]) {
        rail = plist_get("rails", rails)[i];
        direction = i == 0 ? -1 : 1;
        depth = plist_get("w", rail) + 2 * (channel_pad + side_t);
        nut_h = find_nut_prop("height", d);
        bolt_l = ceil((depth + nut_h) / 2) * 2;
        cross = plist_get("cross", rail) + direction * (depth / 2 - bolt_l);
        for (along = plist_get("bolts", rail)) {
          translate([axis == "x" ? along : cross, axis == "x" ? cross : along, plist_get("bolt_z", rails)]) {
            rotate(axis == "x" ? [-direction * 90, 0, 0] : [0, direction * 90, 0]) {
              bolt(d=d, h=bolt_l, threaded=false, show_nut=false);
              translate([0, 0, bolt_l - depth - nut_h]) {
                nut(d=d, outer_d=find_nut_prop("outer_dia", d) / cos(30),
                    h=nut_h, show_text=false);
              }
            }
          }
        }
      }
    }
  }

  with_orientation(from="wlh", to=plist_get("orientation", case_props), size=size, anchor=anchor) {
    translate([-body[0] / 2, -body[1] / 2, 0]) {
      if (slot_mode) {
        _slots();
      } else {
        if (show_lid) {
          color(lid_color) {
            difference() {
              union() {
                translate(concat(roof_min, [roof_z])) {
                  cube([size[0], size[1], t]);
                }
                for (rail = plist_get("rails", rails)) {
                  depth = plist_get("w", rail) + 2 * (channel_pad + side_t);
                  cross = plist_get("cross", rail) - depth / 2;
                  along = roof_min[slide_axis];
                  translate([axis == "x" ? along : cross, axis == "x" ? cross : along, 0]) {
                    cube(axis == "x" ? [size[0], depth, roof_z + 0.01] : [depth, size[1], roof_z + 0.01]);
                  }
                }
              }
              for (rail = plist_get("rails", rails)) {
                depth = plist_get("w", rail) + 2 * (channel_pad + side_t);
                multi_lipo_pack_rail_shape(rails, rail, clearance=clearance,
                                           start=roof_min[slide_axis] - 0.1,
                                           l=size[slide_axis] + 0.2, z_offset=-mount_z);
                _skirt_vents(rail, depth);
              }
              _slots();
            }
          }
        }
        if (show_lidar && !is_undef(lidar_pl)) {
          d = plist_get("bolt_d", lidar_pl);
          mount_pl = plist_merge(lidar_pl,
            ["bore_d", find_bolt_head_d(d, "countersunk") + 0.2,
             "bore_h", find_bolt_head_h(d, "countersunk") + 0.15, "sink", true]);
          translate([body[0] / 2 + lidar_offset[0], body[1] / 2 + lidar_offset[1], size[2]]) {
            lidar(plist=mount_pl, parent_thickness=t,
                  orientation=plist_get("lidar_orientation", props),
                  target_h=plist_get("lidar_target_h", spec, 13), anchor=[0, 0, 1]);
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
  `show_bolts`: Display the removable rail-locking bolts and nuts.
  `l_clearance`: Pack-cell Y clearance, shared with the case.
  `w_clearance`: Pack-cell X clearance, shared with the case.
 */
module multi_lipo_pack_lid_on_case(pl, anchor=[0, 0, 1], slide=0, lift=0,
                                    show_lid=true, show_lidar=true, show_bolts=false,
                                    l_clearance=0.4, w_clearance=0.4) {
  props = multi_lipo_pack_lid_props(pl, l_clearance, w_clearance);
  case_props = plist_get("case_props", props);
  axis = plist_get("axis", plist_get("rail_props", props));
  with_orientation(from="wlh", to=plist_get("orientation", case_props),
                   size=plist_get("canonical_size", case_props), anchor=anchor) {
    translate([axis == "x" ? slide : 0, axis == "y" ? slide : 0,
               plist_get("mount_z", props) + lift]) {
      multi_lipo_pack_lid(plist_merge(pl, ["orientation", "wlh"]),
                          anchor=[0, 0, 1], show_lid=show_lid,
                          show_lidar=show_lidar, show_bolts=show_bolts,
                          l_clearance=l_clearance, w_clearance=w_clearance);
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
module multi_lipo_pack_lid_printable(pl, anchor=[0, 0, 1], l_clearance=0.4, w_clearance=0.4) {
  canonical = plist_merge(pl, ["orientation", "wlh"]);
  size = plist_get("canonical_size", multi_lipo_pack_lid_props(canonical, l_clearance, w_clearance));
  with_anchor(anchor, size, centered=true) {
    translate([0, 0, size[2]]) {
      rotate([180, 0, 0]) {
        multi_lipo_pack_lid(canonical, anchor=[0, 0, 1],
                            l_clearance=l_clearance, w_clearance=w_clearance);
      }
    }
  }
}

multi_lipo_pack_lid_printable(multi_lipo_packs_case);
