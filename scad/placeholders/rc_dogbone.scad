/**
  * Module: Short cut dogbone retained in the differential-side shaft socket.
  * Only exposed length and nominal shank diameter are measured. Ball, pin and
  * insertion dimensions are packaging placeholders, not machining dimensions.
  */
include <../parameters.scad>
use <../lib/plist.scad>
use <../lib/transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_dogbone
  ─────────────────────────────────────────────────────────────────────────────
  Build a cut shank, ball and transverse drive pin along local +Z.
  **Parameters:**
  - `spec`: Shaft property list containing dogbone dimensions.
  - `slot_mode`: Emit a conservative cylindrical clearance envelope.
  - `clearance`: Radial and end allowance for slot mode.
  - `anchor`: Envelope anchor; default puts the cut end on Z=0.
 */
module rc_dogbone(spec=rc_driveshaft_plist,
                  slot_mode=false,
                  clearance=0,
                  anchor=[0, 0, 1]) {
  insert_l = plist_get("dogbone_insert_l", spec);
  outer_l = plist_get("dogbone_outer_l", spec);
  ball_d = plist_get("dogbone_ball_d", spec);
  pin_d = plist_get("dogbone_pin_d", spec);
  pin_l = plist_get("dogbone_pin_l", spec);
  shank_d = plist_get("bore_d", spec);
  l = insert_l + outer_l;
  ball_z = l - ball_d / 2;
  d = max(shank_d, ball_d, pin_l);
  assert(outer_l >= ball_d && insert_l > 0 && pin_d <= ball_d && clearance >= 0);
  $fn = $preview ? 32 : 64;
  with_anchor(anchor, [d, max(shank_d, ball_d), l], centered=true)
    if (slot_mode) translate([0, 0, -clearance])
      cylinder(d=d + clearance * 2, h=l + clearance * 2);
    else color("silver") union() {
      cylinder(d=shank_d, h=ball_z);
      translate([0, 0, ball_z]) {
        sphere(d=ball_d);
        rotate([0, 90, 0]) cylinder(d=pin_d, h=pin_l, center=true);
      }
    }
}

rc_dogbone();
