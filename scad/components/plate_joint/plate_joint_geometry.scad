/**
  * Module: Shared resolved plate joint geometry.
  *
  * Standalone plate joint; dimensions are in millimeters.
  */

use <../../lib/plist.scad>
use <../../lib/transforms.scad>
use <plate_joint_base.scad>
use <plate_joint_bolt_holes.scad>
use <plate_joint_pin_holes.scad>

// Internal adapters consume the validated property list from plate_joint_parameters().
// Their unanchored geometry spans Y=-l..0 and Z=0..plate_h.
module _plate_joint_profile(p, l, extra_l=0, clearance=0) {
  plate_joint_base(w=plist_get("w", p),
                   l=l,
                   plate_h=plist_get("plate_h", p),
                   base_h=plist_get("base_h", p),
                   rail_w=plist_get("rail_w", p),
                   rail_h=plist_get("rail_h", p),
                   angle=plist_get("angle", p),
                   rail_corner_r=plist_get("rail_corner_r", p),
                   dovetail_rib=plist_get("dovetail_rib", p),
                   edge_land=plist_get("relief_depth", p) > 0 ? plist_get("edge_land", p) : undef,
                   relief_depth=plist_get("relief_depth", p),
                   extra_l=extra_l,
                   clearance=clearance);
}

module _plate_joint_holes(p, reverse=false) {
  plate_joint_bolt_holes(bolt_d=plist_get("bolt_d", p),
                         plate_h=plist_get("plate_h", p),
                         l=plist_get("l", p),
                         bolt_xs=plist_get("bolt_xs", p),
                         bore_d=plist_get("bolt_bore_d", p),
                         bore_h=plist_get("bolt_bore_h", p),
                         no_bore=plist_get("bolt_no_bore", p),
                         reverse=reverse,
                         eps=plist_get("boolean_overlap", p));
  if (plist_get("include_pin_holes", p)) {
    plate_joint_pin_holes(d=plist_get("pin_d", p),
                          pin_l=plist_get("pin_l", p),
                          l=plist_get("l", p),
                          spacing=plist_get("pin_spacing", p),
                          z=plist_get("pin_z", p),
                          direction=plist_get("pin_direction", p),
                          center=plist_get("pin_center", p),
                          use_pad=plist_get("pin_use_pad", p),
                          pad_l=plist_get("pin_pad_l", p),
                          pad_w=plist_get("pin_pad_w", p),
                          pad_side=plist_get("pin_pad_side", p),
                          compensation=plist_get("pin_compensation", p));
  }
}

module _plate_joint_anchor(p, anchor, flip=false) {
  with_anchor(anchor=anchor,
              size=[plist_get("w", p), plist_get("l", p),
                    plist_get("plate_h", p)],
              centered=true) {
    translate([0, plist_get("l", p) / 2, 0]) {
      _plate_joint_flip(plist_get("plate_h", p), flip=flip) {
        children();
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint_bolts
  ─────────────────────────────────────────────────────────────────────────────

  Show simple unthreaded fastener envelopes at the resolved bolt centers.

  **Parameters:**
  - `params`: Validated property list from `plate_joint_parameters()`.
  - `anchor`: Nominal envelope anchor, matching the joint halves.
  - `flip`: Mirror the fasteners in Z with the joint, preserving the anchor.

  These are schematic cylinders sized to the holes, not a hardware standard.
  The high-level module displays them with `%` so they are excluded from exports.
 */
module plate_joint_bolts(params, anchor=[0, -1, 1], flip=false) {
  p = params;
  h = plist_get("plate_h", p);
  bore_h = plist_get("bolt_bore_h", p);
  _plate_joint_anchor(p, anchor, flip=flip) {
    color("silver") {
      for (x = plist_get("bolt_xs", p)) {
        translate([x, -plist_get("l", p) / 2, 0]) {
          cylinder(d=plist_get("bolt_d", p), h=h, $fn=40);
          if (!plist_get("bolt_no_bore", p) && bore_h > 0) {
            translate([0, 0, h - bore_h]) {
              cylinder(d=plist_get("bolt_bore_d", p), h=bore_h, $fn=40);
            }
          }
        }
      }
    }
  }
}
