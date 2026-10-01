/**
  * Module: Removable lidar adapter for the multi-pack sliding lid.
  *
  * A plate carries the sensor's actual mounting pattern and captive nuts for
  * a narrower, accessible lid-side pattern. Coordinates are centered on the
  * sensor footprint, with the plate underside at Z=0.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/nut.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_adapter_props
  ─────────────────────────────────────────────────────────────────────────────

  Resolve a sensor plate and a lid mounting pattern clear of the rail skirts.

  **Parameters:**

  `spec`: Adapter plist; undef or `enabled=false` disables it. No lidar also
  disables the adapter. Defaults: `t=4`,
  `bolt_d=3`, `clearance=0.3` (diametral), `nut_clearance=0.3` (across flats),
  `corner_r=3`, `edge_pad=1.5`, `access_d=6`. `bolt_spacing` optionally sets
  the lid-side center spacing in canonical XY. Auto uses the sensor spacing
  along the rails and at most 65% across them, reduced to preserve access and
  separation from the sensor countersinks.
  `standoff_h` raises the plate on separate printed spacers (default zero).
  `bolt_l` is the total countersunk screw length, including its head; its
  default rounds the combined roof/plate thickness up to the next even mm.
  `lid`: Resolved lid properties, before adding `adapter_props`.

  **Returns:**

  Enabled state, plate `size`, sensor/lid hole locations, hardware dimensions,
  and the shared lid screw access diameter. Plate coordinates are independent
  of the whole-case orientation; sensor rotation and pattern offsets are included.
 */
function multi_lipo_pack_adapter_props(spec, lid) =
  is_undef(spec) || !plist_get("enabled", spec, true) || is_undef(plist_get("lidar", lid))
  ? ["enabled", false] :
  let (sensor = plist_get("lidar", lid),
       rotated = plist_get("lidar_orientation", lid) == "lwh",
       sensor_size = plist_get("size", sensor),
       dims = rotated ? [sensor_size[1], sensor_size[0]] : sensor_size,
       sensor_spacing = plist_get("bolt_spacing", sensor),
       pitch = rotated ? [sensor_spacing[1], sensor_spacing[0]] : sensor_spacing,
       off = plist_get("offsets", sensor, [0, 0]),
       sensor_offset = rotated ? [-off[1], off[0]] : off,
       sensor_holes = [for (x=[-1, 1], y=[-1, 1])
           [x*pitch[0]/2 + sensor_offset[0], y*pitch[1]/2 + sensor_offset[1]]],
       t = plist_get("t", spec, 4),
       d = plist_get("bolt_d", spec, 3),
       clearance = plist_get("clearance", spec, 0.3),
       nut_clearance = plist_get("nut_clearance", spec, 0.3),
       edge = plist_get("edge_pad", spec, 1.5),
       access_d = plist_get("access_d", spec, max(6, find_bolt_head_d(d, "countersunk") + 0.6)),
       nut_h = find_nut_prop("height", d),
       nut_d = find_nut_prop("outer_dia", d) / cos(30),
       pocket_d = (find_nut_prop("outer_dia", d) + nut_clearance) / cos(30),
       sensor_d = plist_get("bolt_d", sensor),
       sensor_head_r = (find_bolt_head_d(sensor_d, "countersunk") + 0.2)/2,
       roof_t = plist_get("t", lid),
       gap = plist_get("standoff_h", spec, 0),
       bolt_l = plist_get("bolt_l", spec, 2 * ceil((roof_t + gap + t) / 2)),
       rails = plist_get("rail_props", lid),
       cross = plist_get("axis", rails) == "x" ? 1 : 0,
       pattern_half = pitch[cross]/2,
       body = plist_get("body_size", plist_get("case_props", lid)),
       centers = [for (r=plist_get("rails", rails)) plist_get("cross", r)-body[cross]/2],
       half_widths = [for (r=plist_get("rails", rails))
           plist_get("w", r)/2 + plist_get("clearance_w", rails) + plist_get("side_t", lid)],
       inner = [centers[0] + half_widths[0], centers[1]-half_widths[1]],
       offset = plist_get("lidar_offset", lid),
       safe_half = min(offset[cross]-inner[0], inner[1]-offset[cross]) - access_d / 2 - edge,
       spacing = plist_get("bolt_spacing", spec,
                           [for (i=[0:1])
                               i == cross
                                 ? min(pitch[i] * 0.65,
                                       safe_half * 2,
                                       (pattern_half -abs(sensor_offset[cross])
                                        -pocket_d / 2 - sensor_head_r - edge) * 2)
                                 : pitch[i]]),
       holes = [for (x=[-1, 1], y=[-1, 1]) [x*spacing[0]/2, y*spacing[1]/2]],
       radius = maybe_percent_string_to_num(plist_get("corner_r", spec, 3), min(dims)),
       r = calc_corner_rad(dims, radius))
       assert(t >= nut_h + 1.2 && clearance >= 0 && nut_clearance >= 0 && edge >= 0,
              "Adapter needs nonnegative clearances and at least 1 mm below its nut pockets")
       assert(d + clearance <= find_nut_prop("outer_dia", d) - 1,
              "Adapter nuts need at least 0.5 mm of shoulder around the mounting holes")
       assert(is_num(radius) && radius >= 0,
              "Adapter corner_r must be nonnegative mm or percent")
       assert(is_list(spacing) && len(spacing)==2 && min(spacing)>0
              && access_d >= find_bolt_head_d(d,"countersunk") + clearance,
              "Adapter mounting pattern must leave screw-head access between the skirts")
       assert(roof_t >= find_bolt_head_h(d,"countersunk") + 0.2,
              "Lid roof is too thin for the adapter countersinks")
       assert(gap >= 0 && bolt_l >= roof_t + gap + t - 0.1
              && bolt_l <= roof_t + gap + t + 1.5,
              "Adapter screws must engage the whole nut and extend at most 1.5 mm above the plate")
       assert(min([for (p=holes) min(p[cross] + offset[cross]-inner[0], inner[1]-p[cross]-offset[cross])])
              >= access_d/2 + edge - 0.000001,
              "Adapter screws/tool access overlap a lid skirt")
       assert(min([for (p=holes, q=sensor_holes) norm(p-q)]) >= pocket_d/2 + sensor_head_r + edge,
              "Adapter nut pockets overlap the sensor countersinks; reduce lid-side spacing")
       assert(min([for (p=concat(holes, sensor_holes), i=[0:1]) dims[i]/2-abs(p[i])])
              >= max(pocket_d/2, sensor_head_r) + edge,
              "Adapter holes need more material at the plate edges")
// Conservative corner check: a circle around each mounting feature must fit.
       assert(min([for (p=concat(holes, sensor_holes))
                      r - norm([max(0, abs(p[0])-(dims[0]/2-r)), max(0, abs(p[1])-(dims[1]/2-r))])])
              >= min(r, max(pocket_d/2, sensor_head_r) + edge),
              "Reduce adapter corner_r to preserve mounting lands")
       assert(min([for (i=[0:1]) plist_get("canonical_size", lid)[i]/2-abs(offset[i])-dims[i]/2]) >= 0,
              "Adapter footprint must fit the lid roof")
       ["enabled", true,
        "size", concat(dims,[t]),
        "corner_r", r,
        "holes", holes,
        "sensor_holes", sensor_holes,
        "sensor_d", sensor_d,
        "bolt_d", d,
        "bolt_l", bolt_l,
        "roof_t", roof_t,
        "standoff_h", gap,
        "clearance", clearance,
        "nut_h", nut_h,
        "nut_z", t-nut_h-0.2,
        "nut_d", nut_d,
        "pocket_d", pocket_d,
        "access_d", access_d,
        "offset", offset];

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_adapter_lid_slots
  ─────────────────────────────────────────────────────────────────────────────

  Emit the adapter's lid countersinks, or straight insertion-access probes.

  **Parameters:**

  `props`: Resolved adapter properties. XY is relative to the sensor center.
  `access_h`: When supplied, emit screw/tool cylinders extending down from
  Z=0 instead of lid cutters extending up through the resolved roof thickness.
 */
module multi_lipo_pack_adapter_lid_slots(props, access_h) {
  if (plist_get("enabled", props, false)) {
    d = plist_get("bolt_d", props);
    for (p=plist_get("holes", props)) {
      translate(concat(p,[is_undef(access_h) ? 0 : -access_h])) {
        if (is_undef(access_h)) {
          let (clearance = plist_get("clearance", props),
               bolt_head_d = find_bolt_head_d(d, "countersunk"),
               bore_d = bolt_head_d + clearance,
               bore_h = find_bolt_head_h(d, "countersunk") + 0.15,
               hole_d = d + plist_get("clearance", props)) {
            counterbore(h=plist_get("roof_t", props),
                        d=hole_d,
                        bore_d=bore_d,
                        bore_h=bore_h,
                        sink=true,
                        reverse=true);
          }
        } else {
          cylinder(d=plist_get("access_d", props),
                   h=access_h,
                   $fn=40);
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_adapter
  ─────────────────────────────────────────────────────────────────────────────

  Render the sensor plate, matching slots, or its captured mounting hardware.

  **Parameters:**

  `props`: Resolved adapter properties; disabled emits no geometry.
  `anchor`: Anchor on the plate envelope (default centered XY, bottom at zero).
  `show_plate`: Show the printed plate (default true).
  `show_hardware`: Show four nuts and lid screws (default false).
  `slot_mode`: Emit all plate holes and nut pockets in the same frame.
 */
module multi_lipo_pack_adapter(props,
                               anchor=[0, 0, 1],
                               show_plate=true,
                               show_hardware=false,
                               slot_mode=false) {
  size=plist_get("size", props);
  d=plist_get("bolt_d", props);
  sensor_d=plist_get("sensor_d", props);

  module slots() {
    // lidar holes
    for (p=plist_get("sensor_holes", props)) {
      translate(concat(p,[0])) {
        counterbore(h=size[2],
                    d=sensor_d + 0.2,
                    bore_d=find_bolt_head_d(sensor_d, "pan") + 0.4,
                    bore_h=find_bolt_head_h(sensor_d, "pan") + 0.4,
                    sink=false,
                    reverse=true);
      }
    }
    // lid holes
    for (p=plist_get("holes", props)) {
      translate(concat(p, [-0.01])) {
        cylinder(d=d + plist_get("clearance", props),
                 h=size[2] + 0.02,
                 $fn=40);
      }
      translate(concat(p, [plist_get("nut_z", props)])) {
        echo("pocket_d", plist_get("pocket_d", props))
          cylinder(d=plist_get("pocket_d", props),
                   h=plist_get("nut_h", props) + 0.24,
                   $fn=6);
      }
    }
  }
  if (plist_get("enabled", props, false)) {
    with_anchor(anchor, size, centered=true) {
      if (slot_mode) {
        slots();
      } else {
        if (show_plate) {
          difference() {
            cuboid(size, r=plist_get("corner_r", props), anchor=[0, 0, 1]);
            slots();
          }
        }
        if (show_hardware) {
          for (p=plist_get("holes", props)) {
            translate(concat(p,[plist_get("nut_z", props)])) {
              nut(d=d,
                  outer_d=plist_get("nut_d", props),
                  h=plist_get("nut_h", props),
                  show_text=false);
            }
            translate(concat(p, [-plist_get("roof_t", props)
                                 - plist_get("standoff_h", props, 0)])) {
              bolt(d=d,
                   h=plist_get("bolt_l", props) - find_bolt_head_h(d,"countersunk"),
                   head_type="countersunk",
                   reverse=true,
                   threaded=false,
                   show_nut=false);
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_adapter_printable
  ─────────────────────────────────────────────────────────────────────────────

  Place the plate underside on the bed, with nut pockets facing up.

  **Parameters:**

  `props`: Resolved adapter properties.
  `anchor`: Anchor on the plate envelope.
 */
module multi_lipo_pack_adapter_printable(props, anchor=[0, 0, 1]) {
  multi_lipo_pack_adapter(props, anchor=anchor);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  multi_lipo_pack_adapter_spacers
  ─────────────────────────────────────────────────────────────────────────────
  Render four separate through-bored spacers below the adapter plate.
  **Parameters:**
  - `props`: Resolved adapter properties; the spacer bottoms are at Z=0.
 */
module multi_lipo_pack_adapter_spacers(props) {
  h = plist_get("standoff_h", props, 0);
  if (plist_get("enabled", props, false) && h > 0) {
    for (p = plist_get("holes", props)) {
      translate(concat(p, [0])) {
        difference() {
          cylinder(d=plist_get("pocket_d", props), h=h, $fn=48);
          translate([0, 0, -0.01]) {
            cylinder(d=plist_get("bolt_d", props) + plist_get("clearance", props),
                     h=h + 0.02,
                     $fn=40);
          }
        }
      }
    }
  }
}
