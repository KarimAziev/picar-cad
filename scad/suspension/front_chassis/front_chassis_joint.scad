/**
  * Module: Parametric suspension chassis joint.
  *
  * Defines the dovetail rail, matching socket, distributed fasteners, and
  * longitudinal reinforcing-pin passages used between suspension frames.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../rc_params.scad>
include <layout_params.scad>

use <../../components/plate_joint/plate_joint.scad>
use <../../lib/functions.scad>
use <../../lib/transforms.scad>

joint_preview_spacing = 0; // [0:1:30]

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_body_joint_rail_w
  ─────────────────────────────────────────────────────────────────────────────
  Size the wide rail with padded bolt lands on both sides of its socket.
  **Parameters:**
  - `w`: Shared width of the adjoining chassis edges.
  **Returns:** Rail width, excluding the female socket clearance.
 */
function front_chassis_body_joint_rail_w(w) =
  w - 2 * (front_chassis_joint_bolt_d
           + 2 * suspension_chassis_joint_wide_bolt_pad
           + front_chassis_joint_clearance);

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_body_joint_pin_spacing
  ─────────────────────────────────────────────────────────────────────────────
  Return the wide joint's reinforcing-pin center spacing.
  **Parameters:**
  - `w`: Shared width of the adjoining chassis edges.
  **Returns:** Center-to-center X distance. Percentage settings use rail width.
 */
function front_chassis_body_joint_pin_spacing(w) =
  maybe_percent_string_to_num(suspension_chassis_joint_wide_pin_spacing,
                              front_chassis_body_joint_rail_w(w));

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_body_joint_bolt_xs
  ─────────────────────────────────────────────────────────────────────────────
  Distribute wide-joint bolts with solid lands beside the reinforcing pins.
  **Parameters:**
  - `w`: Shared width of the adjoining chassis edges.
  **Returns:** Bolt-center X coordinates in ascending order.
 */
function front_chassis_body_joint_bolt_xs(w) =
  let (d = front_chassis_joint_bolt_d,
       edge_x = w / 2 - suspension_chassis_joint_wide_bolt_pad - d / 2,
       pin_x = front_chassis_body_joint_pin_spacing(w) / 2,
       land = suspension_chassis_joint_wide_pin_bolt_land,
       separation = (d + front_chassis_joint_pin_d) / 2 + land,
       n = suspension_chassis_joint_wide_bolt_cols)
  assert(n >= 2 && floor(n) == n, "Wide joint needs at least two bolt columns")
  let (xs = [for (i = [0:n - 1])
      let (x = -edge_x + i * 2 * edge_x / (n - 1))
        abs(abs(x) - pin_x) < separation
          ? sign(x) * (pin_x + separation)
          : x])
  assert(max([for (x = xs) abs(x)]) <= edge_x,
         "Wide joint bolt and pin lands must fit the chassis width")
  assert(min([for (x = xs) abs(abs(x) - pin_x)]) >= separation - 0.000001,
         "Wide joint bolts must clear the reinforcing-pin passages")
  assert(min([for (i = [1:n - 1]) xs[i] - xs[i - 1]]) >= d + land,
         "Wide joint bolt columns need separate solid lands")
  xs;

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_joint_default_bolt_xs
  ─────────────────────────────────────────────────────────────────────────────
  Return the compact three-bolt pattern centered across the joint.
  **Parameters:**
  - `spacing`: Center-to-center distance between the outer bolts.
  **Returns:** Bolt-center X coordinates.
 */
function front_chassis_joint_default_bolt_xs(spacing=front_chassis_joint_bolt_spacing)
                      = [-spacing / 2, 0, spacing / 2];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_joint
  ─────────────────────────────────────────────────────────────────────────────
  Build the front chassis preset using the shared plate joint.
  **Parameters:**
  - `mode`: `"male"` or `"female"`.
  - `color`: Optional body color.
  - `w`: Nominal width along X.
  - `l`: Nominal length along Y.
  - `rail_w`: Rail width.
  - `bolt_xs`: Bolt-center X coordinates; `[]` omits bolts.
  - `pin_spacing`: Pin-center span; undef retains the compact front pattern.
  - `include_pin_holes`: Include the longitudinal reinforcing-pin passages.
  - `root_side`: Parent edge, `1` at Y=0 or `-1` at Y=-l; undef uses mode defaults.
  - `eps`: Attachment overlap in millimeters.
  - `slot_mode`: Emit the full parent cutters instead of a solid.
  - `anchor`: Nominal envelope anchor; default spans Y=-l..0.
  **Behavior:** Retains the front joint's sag-compensated pins and bolt through holes.
  Parent calls must subtract
  slot mode from the complete plate so pin passages continue into the parent.
 */
module front_chassis_joint(mode="male",
                           color,
                           w=joint_w,
                           l=joint_l,
                           rail_w=joint_rail_w,
                           bolt_xs=front_chassis_joint_default_bolt_xs(),
                           pin_spacing,
                           include_pin_holes=true,
                           root_side,
                           eps=front_chassis_joint_boolean_overlap,
                           slot_mode=false,
                           anchor=[0, -1, 1]) {
  anchor = normalize_anchor(anchor);
  spacing = is_undef(pin_spacing)
    ? rail_w / 2 + joint_recess_w / 2
    : pin_spacing;

  module _profile() {
    // Keep the established explicit bolt pattern below; the shared
    // component owns the rail, socket, root overlap, clearance and pin passages.
    plate_joint(plate_h=chassis_thickness,
                bolt_d=front_chassis_joint_bolt_d,
                w=w,
                l=l,
                rail_w=rail_w,
                rail_h=joint_rail_h,
                base_h=joint_base_h,
                angle=front_chassis_joint_rail_angle,
                rail_corner_r=front_chassis_joint_rail_corner_r,
                dovetail_rib=front_chassis_joint_use_dovetail_rib,
                clearance=front_chassis_joint_clearance,
                boolean_overlap=eps,
                bolt_n_center=0,
                include_pin_holes=include_pin_holes,
                pin_d=front_chassis_joint_pin_d,
                pin_l=front_chassis_joint_pin_l
                  + 2 * front_chassis_joint_pin_end_clearance,
                pin_spacing=spacing,
                pin_z=joint_base_h + (joint_base_h + joint_rail_h) / 2,
                pin_use_pad=false,
                mode=mode,
                root_side=root_side,
                slot_mode=slot_mode,
                anchor=anchor,
                color=color);
  }

  module _bolts() {
    with_anchor(anchor=anchor, size=[w, l, chassis_thickness], centered=true) {
      translate([0, l / 2, 0]) {
        plate_joint_bolt_holes(bolt_d=front_chassis_joint_bolt_d,
                               plate_h=chassis_thickness,
                               l=l,
                               bolt_xs=bolt_xs,
                               no_bore=true);
      }
    }
  }

  if (slot_mode) {
    _profile();
    _bolts();
  } else {
    difference() {
      _profile();
      _bolts();
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_body_joint
  ─────────────────────────────────────────────────────────────────────────────
  Build either half of the wide front-to-rear chassis connection.
  **Parameters:**
  - `mode`: `"male"` or `"female"`.
  - `w`: Shared width of the adjoining chassis edges.
  - `color`: Optional body color.
  - `slot_mode`: Emit socket/bolt/pin cutters for the parent plate.
  - `anchor`: Nominal envelope anchor; default spans Y=-joint_l..0.
  **Behavior:** Both local parents meet Y=0. In assembly the rear chassis and
  its male tongue rotate 180 degrees around Z to face the front's female socket.
 */
module front_chassis_body_joint(mode,
                                w,
                                color,
                                slot_mode=false,
                                anchor=[0, -1, 1]) {
  rail_w = front_chassis_body_joint_rail_w(w);
  bolt_xs = front_chassis_body_joint_bolt_xs(w);
  front_chassis_joint(mode=mode,
                      color=color,
                      w=w,
                      rail_w=rail_w,
                      bolt_xs=bolt_xs,
                      pin_spacing=front_chassis_body_joint_pin_spacing(w),
                      root_side=1,
                      slot_mode=slot_mode,
                      anchor=anchor);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_pin_joint_holes
  ─────────────────────────────────────────────────────────────────────────────
  Emit the front joint's pin passages at its existing directional datum.
  **Parameters:**
  - `direction`: Passage direction along Y, -1 or 1.
  - `use_pad`: Select pin end flats instead of sag compensation.
  - `center`: Center across the joint in the selected direction; false starts at Y=0.
  - `pad_side`: End flat side, `"bottom"` or `"top"`.
  - `l`: Nominal joint length.
  - `rail_w`: Rail width for the default pin span.
  - `pin_spacing`: Explicit pin-center span; undef uses the compact front pattern.
 */
module front_chassis_pin_joint_holes(direction=-1,
                                     use_pad=false,
                                     center=true,
                                     pad_side="bottom",
                                     l=joint_l,
                                     rail_w=joint_rail_w,
                                     pin_spacing) {
  spacing = is_undef(pin_spacing)
    ? rail_w / 2 + joint_recess_w / 2
    : pin_spacing;
  // The old +Y entry is referenced from the other end of the joint.
  translate([0, center && direction == 1 ? l : 0, 0]) {
    plate_joint_pin_holes(d=front_chassis_joint_pin_d,
                          pin_l=front_chassis_joint_pin_l
                            + 2 * front_chassis_joint_pin_end_clearance,
                          l=l,
                          spacing=spacing,
                          z=joint_base_h + (joint_base_h + joint_rail_h) / 2,
                          direction=direction,
                          center=center,
                          use_pad=use_pad,
                          pad_l=front_chassis_joint_pin_pad_l,
                          pad_w=front_chassis_joint_pin_pad_w,
                          pad_side=pad_side);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_joint_male
  ─────────────────────────────────────────────────────────────────────────────

  Build an anchored male dovetail joint.

  **Parameters:**
  - color: Optional display color.
  - w: Full joint width.
  - l: Joint length.
  - rail_w: Dovetail rail width.
  - bolt_xs: Bolt-center X coordinates.
  - pin_spacing: Optional center-to-center reinforcing-pin spacing.
  - `root_side`: Parent attachment edge: `1` at Y=0, `-1` at Y=-l.
    The root overlaps its parent by the boolean epsilon; the free tip has
    axial assembly clearance. The nominal anchor envelope stays unchanged.
  - anchor: Anchor vector for the joint envelope.
 */
module front_chassis_joint_male(color=cobalt_blue_light_3,
                                w=joint_w,
                                l=joint_l,
                                rail_w=joint_rail_w,
                                bolt_xs=front_chassis_joint_default_bolt_xs(),
                                pin_spacing,
                                root_side=1,
                                anchor=[0, -1, 1]) {
  front_chassis_joint(mode="male",
                      color=color,
                      w=w,
                      l=l,
                      rail_w=rail_w,
                      bolt_xs=bolt_xs,
                      pin_spacing=pin_spacing,
                      root_side=root_side,
                      anchor=anchor);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_joint_female
  ─────────────────────────────────────────────────────────────────────────────

  Build an anchored female dovetail socket.

  **Parameters:**
  - color: Optional display color.
  - w: Full joint width.
  - l: Joint length.
  - rail_w: Dovetail rail width.
  - bolt_xs: Bolt-center X coordinates.
  - pin_spacing: Optional center-to-center reinforcing-pin spacing.
  - include_pin_holes: Cut the longitudinal reinforcing-pin passages.
  - `root_side`: Parent attachment edge: `1` at Y=0, `-1` at Y=-l.
    Only this edge extends beyond the nominal envelope by the boolean epsilon.
  - `slot_mode`: Emit only the socket and fastener cutters for a parent body.
  - anchor: Anchor vector for the joint envelope.
 */
module front_chassis_joint_female(color,
                                  w=joint_w,
                                  l=joint_l,
                                  rail_w=joint_rail_w,
                                  bolt_xs=front_chassis_joint_default_bolt_xs(),
                                  pin_spacing,
                                  include_pin_holes=false,
                                  root_side=-1,
                                  eps=front_chassis_joint_boolean_overlap,
                                  slot_mode=false,
                                  anchor=[0, -1, 1]) {
  front_chassis_joint(mode="female",
                      color=color,
                      w=w,
                      l=l,
                      rail_w=rail_w,
                      bolt_xs=bolt_xs,
                      pin_spacing=pin_spacing,
                      include_pin_holes=include_pin_holes,
                      root_side=root_side,
                      eps=eps,
                      slot_mode=slot_mode,
                      anchor=anchor);
}

union() {
  %front_chassis_joint_male();
  translate([0, -joint_preview_spacing, 0]) {
    front_chassis_joint_female();
  }
}
