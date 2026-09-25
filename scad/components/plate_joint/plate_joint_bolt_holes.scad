/**
  * Module: Plate joint bolt cutters.
  *
  * Standalone plate joint; dimensions are in millimeters.
  */

use <../../lib/slots.scad>

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
                              no_bore=false,
                              reverse=false,
                              eps=0.01) {
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
