/**
  * Module: Plate joint longitudinal pin cutters.
  *
  * Standalone plate joint; dimensions are in millimeters.
  */

use <../../lib/slots.scad>
use <../../placeholders/suspension_arm_pin.scad>

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
                            compensation=0,
                            fn=60) {
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
                             compensation=0,
                             fn=60) {
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
