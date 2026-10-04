/**
  * Module: Smart parametric plate joint.
  *
  * Standalone plate joint; dimensions are in millimeters.
  */

include <plate_joint_parameters.scad>

use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slider.scad>
use <../../lib/slots.scad>
use <../../lib/text.scad>
use <../../lib/transforms.scad>
use <../../placeholders/bolt.scad>
use <../../placeholders/suspension_arm_pin.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint
  ─────────────────────────────────────────────────────────────────────────────

  Build one half of a plate joint using numeric, percentage, or automatic dimensions.

  **Parameters:**
  - `plate_h`: Required positive plate thickness; numeric millimeters.
  - `bolt_d`: Required positive bolt through-hole diameter; numeric millimeters.
  - `w`: Envelope width along X; omitted/undef calculates space for rail, pins and side bolts.
  - `l`: Required positive envelope length along Y; numeric millimeters.
  - `rail_w`: Rail width; percent of `w`; auto targets 70% of w, reducing it when side bolts need room.
  - `bolt_spacing_center`: Outermost bolt-center span; percent of `w`; auto centers the outer bolts in the side strips: (w + rail_w)/2.
  - `bolt_n_center`: Integer bolt count; auto fits up to three. Zero disables bolts; one centers a bolt.
  - `base_h`: Upper base thickness; percent of `plate_h`; auto is half the height left by the rail.
  - `angle`: Numeric flank angle from vertical in degrees; default 20 degrees, as in the front joint.
  - `rail_h`: Rail height; percent of `plate_h`; auto is half the plate thickness.
  - `rail_corner_r`: Rail corner radius; percent of `rail_h`; default 0.4 mm, as in the front joint.
  - `dovetail_rib`: Use the double-taper rib; false selects a single dovetail.
  - `edge_land`: Relief land; percent of `rail_h`; default 0.45 mm.
  - `relief_depth`: Relief depth; percent of `rail_h`; auto is zero (disabled).
  - `clearance`: Female profile offset; percent of `bolt_d`; default 0.4 mm, as in the front joint.
  - `axial_clearance`: Male free-tip setback; percent of `l`; auto equals `clearance`.
  - `boolean_overlap`: Parent attachment overlap; percent of `plate_h`; default 0.02 mm, as in the front joint.
  - `wall`: Material reserved beside a side-bolt cutter during automatic sizing; percent of bolt_d; default 2 mm.
  - `bolt_bore_d`: Counterbore diameter; percent of `bolt_d`; auto uses the selected bolt head diameter.
  - `bolt_bore_h`: Counterbore depth; percent of `plate_h`; auto uses the selected bolt head height.
  - `bolt_no_bore`: Disable counterbores while retaining through holes; default true.
  - `include_pin_holes`: Cut two longitudinal reinforcing-pin passages in either half.
  - `pin_d`: Pin diameter; percent of `rail_h`; default 3.1 mm.
  - `pin_l`: Pin cutter length; percent of `l`; default 41 mm.
  - `pin_spacing`: Pin-center span; percent of `rail_w`; auto is 67.5% of rail width, as in the front joint.
  - `pin_z`: Pin-center height; percent of `plate_h`; auto centers it in the combined base-plus-rail height, before flipping.
  - `pin_use_pad`: Use a pin-shaped passage with an end flat instead of a sag-compensated hole.
  - `pin_pad_l`: Pin flat length; percent of `pin_l`; default 5.5 mm.
  - `pin_pad_w`: Pin flat thickness; percent of `pin_d`; default 2.5 mm.
  - `pin_direction`: Pin cutter direction along Y: -1 or 1.
  - `pin_center`: Center the cutter at Y=-l/2; false starts at Y=0.
  - `pin_pad_side`: End flat side: "bottom" or "top", following the source pin convention.
  - `pin_compensation`: Sag compensation width; percent of `pin_d`; default 0.4 mm, from sag_compensated_hole().
  - `color`: Optional body color.
  - `show_bolts`: Show actual bolt placeholders as preview-only background geometry.
  - `mode`: Joint half: "male" or "female".
  - `root_side`: Parent edge at Y=0 (1) or Y=-l (-1); defaults to 1 for male and -1 for female.
  - `slot_mode`: Emit holes for a male parent; emit socket and holes for a female parent.
  - `anchor`: Nominal plate-envelope anchor; 1=min, 0=center, -1=max along each axis.
  - `flip`: Mirror the complete joint in Z about the nominal plate midpoint without moving its anchor.
  - `bolt_head_type`: Head style for display and optional counterbore sizing; default "socket".
  - `bolt_cut_overlap`: Bolt cutter extension; percent of plate_h; default 0.1 mm.
  - `show_sizes`: Show a preview-only dimension table; suppressed in slot calls.
  - `sizes_min_wall`: THIN threshold in millimeters; default 1.6. Does not alter geometry.
  - `sizes_text_size`: Size table font size; default 3 mm.
  - `sizes_offset`: Extra XYZ translation of the table; default [0,0,0].

  **Examples:**
  ```scad
  plate_joint(plate_h=6, bolt_d=3, w=54, l=24, rail_w="70%");
  plate_joint(plate_h=6, bolt_d=3, w=54, l=24, mode="female");
  ```
  Pass identical dimension inputs to both halves for a matching pair.
  See README.md for coordinate, percentage, and automatic-layout rules.
 */
module plate_joint(plate_h,
                   bolt_d,
                   w,
                   l,
                   rail_w,
                   bolt_spacing_center,
                   bolt_n_center,
                   base_h,
                   angle,
                   rail_h,
                   rail_corner_r,
                   dovetail_rib=true,
                   edge_land,
                   relief_depth,
                   clearance,
                   axial_clearance,
                   boolean_overlap,
                   wall,
                   bolt_bore_d,
                   bolt_bore_h,
                   bolt_no_bore=true,
                   include_pin_holes=false,
                   pin_d,
                   pin_l,
                   pin_spacing,
                   pin_z,
                   pin_use_pad=true,
                   pin_pad_l,
                   pin_pad_w,
                   pin_direction=-1,
                   pin_center=true,
                   pin_pad_side="bottom",
                   pin_compensation,
                   color,
                   show_bolts=false,
                   mode="male",
                   root_side,
                   slot_mode=false,
                   anchor=[0, -1, 1],
                   flip=false,
                   bolt_head_type="socket",
                   bolt_cut_overlap,
                   show_sizes=false,
                   sizes_min_wall=1.6,
                   sizes_text_size=3,
                   sizes_offset=[0, 0, 0]) {
  mode = with_default(mode, "male");
  assert(mode == "male" || mode == "female", "mode must be male or female");
  side = is_undef(root_side) ? (mode == "male" ? 1 : -1) : root_side;
  p = plate_joint_parameters(plate_h=plate_h,
                             bolt_d=bolt_d,
                             w=w,
                             l=l,
                             rail_w=rail_w,
                             bolt_spacing_center=bolt_spacing_center,
                             bolt_n_center=bolt_n_center,
                             base_h=base_h,
                             angle=angle,
                             rail_h=rail_h,
                             rail_corner_r=rail_corner_r,
                             dovetail_rib=dovetail_rib,
                             edge_land=edge_land,
                             relief_depth=relief_depth,
                             clearance=clearance,
                             axial_clearance=axial_clearance,
                             boolean_overlap=boolean_overlap,
                             wall=wall,
                             bolt_bore_d=bolt_bore_d,
                             bolt_bore_h=bolt_bore_h,
                             bolt_no_bore=bolt_no_bore,
                             include_pin_holes=include_pin_holes,
                             pin_d=pin_d,
                             pin_l=pin_l,
                             pin_spacing=pin_spacing,
                             pin_z=pin_z,
                             pin_use_pad=pin_use_pad,
                             pin_pad_l=pin_pad_l,
                             pin_pad_w=pin_pad_w,
                             pin_direction=pin_direction,
                             pin_center=pin_center,
                             pin_pad_side=pin_pad_side,
                             pin_compensation=pin_compensation,
                             bolt_head_type=bolt_head_type,
                             bolt_cut_overlap=bolt_cut_overlap);
  if (mode == "male") {
    plate_joint_male(p,
                     color=color,
                     root_side=side,
                     anchor=anchor,
                     flip=flip,
                     slot_mode=slot_mode);
  } else {
    plate_joint_female(p,
                       color=color,
                       root_side=side,
                       slot_mode=slot_mode,
                       anchor=anchor,
                       flip=flip);
  }
  if (show_bolts && !slot_mode) {
    %plate_joint_bolts(p, anchor=anchor, flip=flip);
  }
  if ($preview && show_sizes && !slot_mode) {
    %plate_joint_sizes(p,
                       anchor=anchor,
                       mode=mode,
                       min_wall=sizes_min_wall,
                       text_size=sizes_text_size,
                       offset=sizes_offset,
                       flip=flip);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint_base
  ─────────────────────────────────────────────────────────────────────────────

  Extrude the numeric joint profile inside the nominal plate envelope.

  **Parameters:**
  - `color`: Optional display color.
  - `w`: Nominal X width.
  - `l`: Nominal Y length.
  - `base_h`: Base thickness below the top face.
  - `rail_w`: Rail width.
  - `plate_h`: Nominal plate thickness.
  - `angle`: Rail flank angle in degrees.
  - `rail_h`: Rail height.
  - `rail_corner_r`: Rail corner radius.
  - `dovetail_rib`: Select the double-taper rib.
  - `extra_h`: Increase base thickness and top Z by this amount.
  - `extra_w`: Additional full base width.
  - `extra_l`: Additional full length, split between both ends.
  - `clearance`: Outward profile offset for a socket cutter.
  - `edge_land`: Optional relief land.
  - `relief_depth`: Optional relief depth.
  - `anchor`: Nominal envelope anchor; default spans X=-w/2..w/2, Y=-l..0, Z=0..plate_h.
  - `flip`: Mirror in Z about plate_h/2 before anchoring, including any extra geometry.
 */
module plate_joint_base(color=undef,
                        w,
                        l,
                        base_h,
                        rail_w,
                        plate_h,
                        angle,
                        rail_h,
                        rail_corner_r,
                        dovetail_rib,
                        extra_h=0.0,
                        extra_w=0.0,
                        extra_l=0.0,
                        clearance=0,
                        edge_land,
                        relief_depth,
                        anchor=[0, -1, 1],
                        flip=false) {
  _base_h = base_h + extra_h;
  base_w = w + extra_w;

  with_anchor(anchor=_plate_joint_anchor_value(anchor),
              size=[w, l, plate_h],
              centered=true) {
    _plate_joint_flip(plate_h, flip=flip) {
      translate([0, -l / 2 - extra_l / 2, plate_h + extra_h]) {
        rotate([-90, 0, 0]) {
          maybe_color(color) {
            linear_extrude(height=l + extra_l, center=false) {
              offset(delta=clearance) {
                slider_dovetail_rail_2d(base_w=base_w,
                                        base_h=_base_h,
                                        w=rail_w,
                                        h=rail_h,
                                        angle=angle,
                                        r=rail_corner_r,
                                        center_y=false,
                                        center_x=true,
                                        reverse=true,
                                        use_dovetail_rib=dovetail_rib,
                                        edge_land=dovetail_rib ? edge_land : undef,
                                        relief_depth=relief_depth);
              }
            }
          }
        }
      }
    }
  }
}

// Reflect within the nominal Z envelope. Keep this inside the anchor transform:
// reflecting already-anchored geometry about Z=0 would move bottom/top anchors.
module _plate_joint_flip(plate_h, flip=false) {
  if (flip) {
    translate([0, 0, plate_h]) {
      mirror([0, 0, 1]) {
        children();
      }
    }
  } else {
    children();
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint_bolt_holes
  ─────────────────────────────────────────────────────────────────────────────

  Create a row of vertical through holes and optional counterbores.

  **Parameters:**
  - `bolt_d`: Through-hole diameter.
  - `plate_h`: Plate thickness.
  - `l`: Joint length; hole centers lie at Y=-l/2.
  - `bolt_xs`: Numeric X center coordinates; an empty list disables holes.
  - `bore_d`: Counterbore diameter.
  - `bore_h`: Counterbore depth.
  - `no_bore`: Disable counterbores.
  - `reverse`: Put counterbores on the bottom instead of the top.
  - `eps`: Cutter extension beyond the plate faces.
 */
module plate_joint_bolt_holes(bolt_d,
                              plate_h,
                              l,
                              bolt_xs=[],
                              bore_d,
                              bore_h,
                              no_bore=true,
                              reverse=false,
                              eps=0.1) {
  for (x = bolt_xs) {
    translate([x, -l / 2, 0]) {
      counterbore(d=bolt_d,
                  h=plate_h,
                  bore_d=bore_d,
                  bore_h=bore_h,
                  no_bore=no_bore,
                  reverse=reverse,
                  autoscale_step=eps);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint_pin_hole
  ─────────────────────────────────────────────────────────────────────────────

  Create one longitudinal pin passage starting at the origin.

  **Parameters:**
  - `d`: Pin diameter.
  - `l`: Passage length.
  - `direction`: Direction along Y: -1 or 1.
  - `use_pad`: Use the source pin shape with an end flat.
  - `pad_l`: End flat length.
  - `pad_w`: End flat thickness.
  - `pad_side`: End flat side: "bottom" or "top".
  - `compensation`: Sag compensation width, used without an end flat.
  - `fn`: Curve fragment count.
 */
module plate_joint_pin_hole(d,
                            l,
                            direction=-1,
                            use_pad=false,
                            pad_l=0,
                            pad_w=0,
                            pad_side="bottom",
                            compensation=0.4,
                            fn) {
  fn = with_default(fn, $preview ? 16 : 100);
  assert(direction == -1 || direction == 1, "Pin direction must be -1 or 1");
  assert(pad_side == "bottom" || pad_side == "top", "Invalid pad_side");
  rotate([direction == 1 ? -90 : 90, 0, 0]) {
    if (use_pad) {
      groove_side = (pad_side == "bottom") == (direction == -1) ? "bottom" : "top";
      suspension_arm_pin(d=d,
                         l=l,
                         pad_l=pad_l,
                         pad_w=pad_w,
                         color=undef,
                         fn=fn,
                         groove_side=groove_side,
                         show_e_clip=false,
                         groove_w=0);
    } else {
      sag_compensated_hole(d=d, h=l, fn=fn, compensation=compensation);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint_pin_holes
  ─────────────────────────────────────────────────────────────────────────────

  Create two pin passages symmetric about X=0.

  **Parameters:**
  - `d`: Pin diameter.
  - `pin_l`: Passage length.
  - `l`: Nominal joint length.
  - `spacing`: Distance between pin centers.
  - `z`: Pin-center height above the plate bottom.
  - `direction`: Direction along Y: -1 or 1.
  - `center`: Center cutter length at Y=-l/2; false starts at Y=0.
  - `use_pad`: Use end flats.
  - `pad_l`: End flat length.
  - `pad_w`: End flat thickness.
  - `pad_side`: End flat side.
  - `compensation`: Sag compensation width.
  - `fn`: Curve fragment count.
 */
module plate_joint_pin_holes(d,
                             pin_l,
                             l,
                             spacing,
                             z,
                             direction=-1,
                             center=true,
                             use_pad=false,
                             pad_l=0,
                             pad_w=0,
                             pad_side="bottom",
                             compensation=0.4,
                             fn) {
  y = center ? -l / 2 - direction * pin_l / 2 : 0;
  for (x = [-spacing / 2, spacing / 2]) {
    translate([x, y, z]) {
      plate_joint_pin_hole(d=d,
                           l=pin_l,
                           direction=direction,
                           use_pad=use_pad,
                           pad_l=pad_l,
                           pad_w=pad_w,
                           pad_side=pad_side,
                           compensation=compensation,
                           fn=fn);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint_male
  ─────────────────────────────────────────────────────────────────────────────

  Build a male rail with a free-tip setback.

  **Parameters:**
  - `params`: Validated property list from `plate_joint_parameters()`; shared by both halves.
  - `color`: Optional display color.
  - `root_side`: Parent edge: 1 at Y=0 or -1 at Y=-l; only this edge gets boolean overlap.
  - `anchor`: Nominal plate-envelope anchor, independent of clearance and overlap.
  - `flip`: Mirror in Z within the nominal plate envelope; preserve the anchor.
  - `slot_mode`: Emit full-length pin passages and bolt cutters for subtraction from a parent.
 */
module plate_joint_male(params,
                        color,
                        root_side=1,
                        anchor=[0, -1, 1],
                        flip=false,
                        slot_mode=false) {
  p = params;
  l = plist_get("l", p);
  eps = plist_get("boolean_overlap", p);
  gap = plist_get("axial_clearance", p);
  assert(root_side == -1 || root_side == 1, "root_side must be -1 or 1");
  _plate_joint_anchor(p, anchor, flip=flip) {
    if (slot_mode) {
      _plate_joint_holes(p);
    } else {
      maybe_color(color) {
        render(convexity=10) {
          difference() {
            translate([0, root_side == 1 ? eps : -gap, 0]) {
              _plate_joint_profile(p, l=l + eps - gap);
            }
            _plate_joint_holes(p);
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint_female
  ─────────────────────────────────────────────────────────────────────────────

  Build a matching female socket, or its cutters.

  **Parameters:**
  - `params`: Validated property list from `plate_joint_parameters()`; shared by both halves.
  - `color`: Optional display color.
  - `root_side`: Parent edge: 1 at Y=0 or -1 at Y=-l; only this edge gets boolean overlap.
  - `slot_mode`: Emit only socket and hole cutters for subtraction from a parent plate.
  - `anchor`: Nominal plate-envelope anchor, independent of clearance and overlap.
  - `flip`: Mirror in Z within the nominal plate envelope; preserve the anchor.
 */
module plate_joint_female(params,
                          color,
                          root_side=-1,
                          slot_mode=false,
                          anchor=[0, -1, 1],
                          flip=false) {
  p = params;
  l = plist_get("l", p);
  eps = plist_get("boolean_overlap", p);
  assert(root_side == -1 || root_side == 1, "root_side must be -1 or 1");
  module _slots() {
    _plate_joint_profile(p,
                         l=l,
                         extra_l=eps * 4,
                         clearance=plist_get("clearance", p));
    _plate_joint_holes(p, reverse=true);
  }
  _plate_joint_anchor(p, anchor, flip=flip) {
    if (slot_mode) {
      _slots();
    } else {
      render() {
        maybe_color(color) {
          difference() {
            translate([0, -l / 2 + root_side * eps / 2, 0]) {
              cuboid([plist_get("w", p), l + eps, plist_get("plate_h", p)],
                     anchor=[0, 0, 1]);
            }
            _slots();
          }
        }
      }
    }
  }
}

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
                         eps=plist_get("bolt_cut_overlap", p));
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
  with_anchor(anchor=_plate_joint_anchor_value(anchor),
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

  Show repository bolt placeholders seated at the resolved bolt centers.

  **Parameters:**
  - `params`: Validated property list from `plate_joint_parameters()`.
  - `anchor`: Nominal envelope anchor, matching the joint halves.
  - `flip`: Mirror the fasteners in Z with the joint, preserving the anchor.

  Head dimensions come from the bolt library. Recess depth lowers the bolt
  from the top face; without a counterbore, the head rests above that face.
  The high-level module uses `%` to exclude hardware from printed exports.
 */
module plate_joint_bolts(params, anchor=[0, -1, 1], flip=false) {
  p = params;
  h = plist_get("plate_h", p);
  bore_h = plist_get("bolt_bore_h", p);
  _plate_joint_anchor(p, anchor, flip=flip) {
    for (x = plist_get("bolt_xs", p)) {
      depth = plist_get("bolt_no_bore", p) ? 0 : bore_h;
      translate([x, -plist_get("l", p) / 2, -depth]) {
        bolt(d=plist_get("bolt_d", p),
             h=h,
             threaded=false,
             head_type=plist_get("bolt_head_type", p),
             head_d=plist_get("bolt_head_d", p),
             head_h=plist_get("bolt_head_h", p));
      }
    }
  }
}

// Same nominal anchor as front_chassis_joint; forwarded undef is the default.
function _plate_joint_anchor_value(anchor) =
  let (defaults = [0, -1, 1])
  is_undef(anchor) ? defaults
  : [for (i = [0:2]) with_default(anchor[i], defaults[i])];

/**
  ─────────────────────────────────────────────────────────────────────────────
  plate_joint_sizes
  ─────────────────────────────────────────────────────────────────────────────

  Show a readable size table next to the joint in preview.

  **Parameters:**
  - `params`: Resolved dimensions.
  - `anchor`: Same nominal anchor as the joint.
  - `mode`: Label identifying the displayed half.
  - `min_wall`: Mark remaining material below this threshold; default 1.6 mm.
  - `text_size`: Text size in millimeters; default 3.
  - `offset`: Extra XYZ translation for the table, after anchoring.
  - `flip`: Report the reflected pin axis while keeping the text upright.

  Text stays upright when the solid is flipped. THIN labels are dimensional
  diagnostics; they do not certify a joint's mechanical strength.
 */
module plate_joint_sizes(params,
                         anchor,
                         mode="male",
                         min_wall=1.6,
                         text_size=3,
                         offset=[0, 0, 0],
                         flip=false) {
  p = params;
  threshold = with_default(min_wall, 1.6);
  size = with_default(text_size, 3);
  rows = plate_joint_size_report(p, flip=flip);
  labels = concat([["text", str("PLATE JOINT / ", with_default(mode, "male")),
                    "color", "black"],
                   ["text", str("THIN < ", threshold, " mm"),
                    "color", "firebrick"]],
                  [for (row = rows)
                    let (thin = row[2] && row[1] < threshold)
                    ["text", str(thin ? "! THIN  " : "", row[0], ": ", round(row[1] * 100) / 100, " mm"),
                     "color", thin ? "firebrick" : "black"]]);
  if ($preview) {
    _plate_joint_anchor(p, anchor) {
      translate([plist_get("w", p) / 2 + size * 4,
                 -plist_get("l", p) / 2,
                 plist_get("plate_h", p) + 0.5]) {
        translate(with_default(offset, [0, 0, 0])) {
          text_rows(labels,
                    default_size=size,
                    default_halign="left",
                    default_height=0.1,
                    gap=size * 0.35,
                    center_x=false,
                    center_y=true);
        }
      }
    }
  }
}
