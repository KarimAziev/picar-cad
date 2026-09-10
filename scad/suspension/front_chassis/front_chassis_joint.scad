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
include <../../parameters.scad>
include <../../steering_params.scad>
include <computed_params.scad>

use <../../lib/shapes3d.scad>
use <../../lib/slider.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../placeholders/suspension_arm_pin.scad>

joint_preview_spacing = 0; // [0:1:30]

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_joint_default_bolt_xs
  ─────────────────────────────────────────────────────────────────────────────

  Return the compact three-bolt pattern centered across the joint.

  **Parameters:**
  - spacing: Center-to-center distance between the outer bolts.

  **Returns:**
  - Bolt-center X coordinates.
 */
function front_chassis_joint_default_bolt_xs(
  spacing=front_chassis_joint_bolt_spacing
) = [-spacing / 2, 0, spacing / 2];

module front_chassis_joint_base(color=cobalt_blue_light_3,
                                w=joint_w,
                                l=joint_l,
                                rail_w=joint_rail_w,
                                extra_h=0.0,
                                extra_w=0.0,
                                extra_l=0.0,
                                clearance=0,
                                edge_land,
                                relief_depth) {
  base_h = joint_base_h + extra_h;
  base_w = w + extra_w;

  translate([0, -l - extra_l / 2, front_chassis_thickness + extra_h]) {
    rotate([-90, 0, 0]) {
      maybe_color(color) {
        linear_extrude(height=l + extra_l, center=false) {
          offset(delta=clearance) {
            slider_dovetail_rail_2d(base_w=base_w,
                                  base_h=base_h,
                                  w=rail_w,
                                  h=joint_rail_h,
                                  angle=front_chassis_joint_rail_angle,
                                  r=front_chassis_joint_rail_corner_r,
                                  center_y=false,
                                  center_x=true,
                                  reverse=true,
                                  use_dovetail_rib=front_chassis_joint_use_dovetail_rib,
                                  edge_land=front_chassis_joint_use_dovetail_rib
                                  ? edge_land : undef,
                                    relief_depth=relief_depth);
          }
        }
      }
    }
  }
}

module front_chassis_joint_bolt_holes(
  bolt_xs=front_chassis_joint_default_bolt_xs(),
  l=joint_l,
  reverse=false
) {
  for (x = bolt_xs) {
    translate([x, -l / 2, 0]) {
      counterbore(d=front_chassis_joint_bolt_d,
                  h=front_chassis_thickness,
                  reverse=reverse);
    }
  }
}

module front_chassis_pin_joint_hole(direction=-1,
                                    use_pad=false,
                                    pad_side="bottom") {
  fn = $preview ? 16 : 100;
  rotate([direction == 1 ? -90 : 90, 0, 0]) {
    if (use_pad) {
      let (groove_side = (pad_side == "bottom") == (direction == -1)
           ? "bottom"
           : "top") {
        suspension_arm_pin(d=front_chassis_joint_pin_d,
                           l=front_chassis_joint_pin_l,
                           pad_l=front_chassis_joint_pin_pad_l,
                           pad_w=front_chassis_joint_pin_pad_w,
                           color=undef,
                           fn=fn,
                           groove_side=groove_side,
                           show_e_clip=false);
      }
    } else {
      sag_compensated_hole(d=front_chassis_joint_pin_d,
                           h=front_chassis_joint_pin_l,
                           fn=fn);
    }
  }
}

module front_chassis_pin_joint_holes(direction=-1,
                                     use_pad=false,
                                     center=true,
                                     pad_side="bottom",
                                     l=joint_l,
                                     rail_w=joint_rail_w,
                                     pin_spacing) {
  default_spacing = rail_w / 2 + joint_recess_w / 2;
  spacing = is_undef(pin_spacing) ? default_spacing : pin_spacing;
  depth = (front_chassis_joint_pin_l - l) / 2;
  y = center ? depth * -direction : 0;
  jz = joint_base_h + (joint_base_h + joint_rail_h) / 2;

  mirror_copy([1, 0, 0]) {
    translate([spacing / 2, y, jz]) {
      front_chassis_pin_joint_hole(direction=direction,
                                   pad_side=pad_side,
                                   use_pad=use_pad);
    }
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
module front_chassis_joint_male(
  color=cobalt_blue_light_3,
  w=joint_w,
  l=joint_l,
  rail_w=joint_rail_w,
  bolt_xs=front_chassis_joint_default_bolt_xs(),
  pin_spacing,
  root_side=1,
  anchor=[0, -1, 1]
) {
  eps = front_chassis_joint_boolean_overlap;
  axial_clearance = front_chassis_joint_clearance;
  assert(abs(root_side) == 1, "Joint root side must be -1 or 1");
  with_anchor(anchor=anchor,
              size=[w, l, front_chassis_thickness],
              centered=true) {
    translate([0, l / 2, 0]) {
      render() {
        difference() {
          translate([0, root_side == 1 ? eps : -axial_clearance, 0]) {
            front_chassis_joint_base(color=color,
                                   w=w,
                                   l=l + eps - axial_clearance,
                                   rail_w=rail_w);
          }
          front_chassis_pin_joint_holes(use_pad=false,
                                        direction=-1,
                                        l=l,
                                        rail_w=rail_w,
                                        pin_spacing=pin_spacing);
          front_chassis_joint_bolt_holes(bolt_xs=bolt_xs,
                                         l=l,
                                         reverse=true);
        }
      }
    }
  }
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
module front_chassis_joint_female(
  color,
  w=joint_w,
  l=joint_l,
  rail_w=joint_rail_w,
  bolt_xs=front_chassis_joint_default_bolt_xs(),
  pin_spacing,
  include_pin_holes=false,
  root_side=-1,
  slot_mode=false,
  anchor=[0, -1, 1]
) {
  eps = front_chassis_joint_boolean_overlap;
  assert(abs(root_side) == 1, "Joint root side must be -1 or 1");
  module _slots() {
    front_chassis_joint_base(w=w,
                             l=l,
                             rail_w=rail_w,
                             clearance=front_chassis_joint_clearance,
                             extra_l=eps * 4,
                             color=undef);
    front_chassis_joint_bolt_holes(bolt_xs=bolt_xs, l=l);
    if (include_pin_holes) {
      front_chassis_pin_joint_holes(use_pad=false,
                                    direction=-1,
                                    l=l,
                                    rail_w=rail_w,
                                    pin_spacing=pin_spacing);
    }
  }

  with_anchor(anchor=anchor,
              size=[w, l, front_chassis_thickness],
              centered=true) {
    translate([0, l / 2, 0]) {
      if (slot_mode) {
        _slots();
      } else render() {
        difference() {
          translate([0, -l / 2 + root_side * eps / 2, 0]) {
            cuboid([w, l + eps, front_chassis_thickness],
                   anchor=[0, 0, 1]);
          }
          _slots();
        }
      }
    }
  }
}

union() {
  %front_chassis_joint_male();
  translate([0, -joint_preview_spacing, 0]) {
    front_chassis_joint_female();
  }
}
