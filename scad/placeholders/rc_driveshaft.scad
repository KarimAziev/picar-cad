/**
  * Module: Telescoping RC propeller shaft with two universal-joint placeholders.
  *
  * Diameter, bore and socket length use measured defaults. Pivot-to-pivot
  * distance and telescopic travel remain provisional: the reported 48 mm base
  * length has not yet been identified with a pair of physical endpoint datums.
  */
include <../parameters.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>

driveshaft_l = plist_get("pivot_l", rc_driveshaft_plist);
driveshaft_drop = 0;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_driveshaft_hub_l
  ─────────────────────────────────────────────────────────────────────────────
  Derive the socket's bored cylindrical length after its fork section.
  **Parameters:**
  - `spec`: Shaft property list with measured socket length and fork length.
  **Returns:** Positive hub length in mm.
 */
function rc_driveshaft_hub_l(spec=rc_driveshaft_plist) =
  let (l = plist_get("socket_l", spec) - plist_get("yoke_l", spec))
  assert(l > 0, "Socket must extend beyond the fork") l;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_driveshaft_axis
  ─────────────────────────────────────────────────────────────────────────────
  Orient children whose local +Z axis should follow a direction vector.
  **Parameters:**
  - `direction`: Nonzero vector; its magnitude is ignored.
  **Children:** Geometry beginning at the current origin.
 */
module rc_driveshaft_axis(direction) {
  assert(norm(direction) > 0, "A shaft axis must be nonzero");
  rotate([0, acos(direction[2] / norm(direction)), atan2(direction[1], direction[0])])
    children();
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_driveshaft_joint_angle
  ─────────────────────────────────────────────────────────────────────────────
  Return the acute bend angle between shaft and coupling axes.
  **Parameters:**
  - `shaft_axis`: Nonzero vector between joint pivots.
  - `hub_axis`: Nonzero vector pointing outward toward the mating shaft.
  **Returns:** Angle in degrees; opposite collinear vectors have zero bend.
 */
function rc_driveshaft_joint_angle(shaft_axis, hub_axis) =
  assert(norm(shaft_axis) > 0 && norm(hub_axis) > 0)
  acos(min(1, abs(shaft_axis * hub_axis) / norm(shaft_axis) / norm(hub_axis)));

module _rc_driveshaft_yoke(spec, phase=0) {
  d = plist_get("joint_d", spec);
  pin_d = plist_get("pin_d", spec);
  l = plist_get("yoke_l", spec);
  rotate([0, 0, phase]) {
    difference() {
      translate([0, 0, -pin_d / 2]) cylinder(d=d, h=l + pin_d / 2);
      translate([0, 0, -pin_d])
        cuboid([d - pin_d * 2, d * 2, l], anchor=[0, 0, 1]);
    }
    rotate([0, 90, 0]) cylinder(d=pin_d, h=d, center=true);
  }
}

module _rc_driveshaft_hub(spec) {
  l = rc_driveshaft_hub_l(spec);
  yoke_l = plist_get("yoke_l", spec);
  d = plist_get("joint_d", spec);
  difference() {
    translate([0, 0, yoke_l]) cylinder(d=d, h=l);
    translate([0, 0, yoke_l])
      cylinder(d=plist_get("bore_d", spec) + plist_get("bore_clearance", spec) * 2,
                h=l * 2);
    translate([0, 0, yoke_l + l / 2]) rotate([0, 90, 0])
      cylinder(d=plist_get("pin_d", spec), h=d, center=true);
  }
  _rc_driveshaft_yoke(spec);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_driveshaft_between
  ─────────────────────────────────────────────────────────────────────────────
  Join two explicit universal-joint pivot centers with a telescoping shaft.
  **Parameters:**
  - `start`: Motor-side pivot `[x, y, z]`.
  - `end`: Differential-side pivot `[x, y, z]`.
  - `start_axis`: Axis from the start pivot toward the motor.
  - `end_axis`: Axis from the end pivot toward the differential.
  - `spec`: Shaft property list, including allowed travel and joint angle.
  - `slot_mode`: Emit a conservative clearance capsule and hub envelopes.
  - `clearance`: Radial allowance for slot mode.
  **Notes:** The joint endpoints remain fixed when the shaft articulates.
  This placement helper uses explicit datums, not a bounding-box anchor.
 */
module rc_driveshaft_between(start, end,
                             start_axis=[0, 1, 0],
                             end_axis=[0, -1, 0],
                             spec=rc_driveshaft_plist,
                             slot_mode=false,
                             clearance=0) {
  axis = end - start;
  l = norm(axis);
  yoke_l = plist_get("yoke_l", spec);
  hub_l = rc_driveshaft_hub_l(spec);
  joint_d = plist_get("joint_d", spec);
  min_l = plist_get("min_pivot_l", spec);
  max_l = plist_get("max_pivot_l", spec);
  // Both telescopic sections have constant physical length. Only engagement changes.
  section_l = min_l - yoke_l * 2;
  assert(min_l <= l && l <= max_l, "Driveshaft outside provisional telescopic travel");
  assert(section_l * 2 > max_l - yoke_l * 2, "No telescopic engagement");
  assert(plist_get("rod_d", spec) < plist_get("tube_d", spec));
  assert(clearance >= 0);
  for (hub_axis = [start_axis, end_axis])
    assert(rc_driveshaft_joint_angle(axis, hub_axis) <= plist_get("max_angle", spec),
           "Universal-joint angle exceeds packaging limit");
  $fn = $preview ? 32 : 64;

  if (slot_mode) {
    hull() {
      for (p = [start, end]) translate(p) sphere(d=joint_d + clearance * 2);
    }
    for (i = [0:1])
      translate([start, end][i]) rc_driveshaft_axis([start_axis, end_axis][i])
        cylinder(d=joint_d + clearance * 2, h=yoke_l + hub_l + clearance);
  } else {
    for (i = [0:1]) {
      translate([start, end][i]) {
        color("silver") rc_driveshaft_axis([start_axis, end_axis][i])
          _rc_driveshaft_hub(spec);
        color("#b8a384") rc_driveshaft_axis(i == 0 ? axis : -axis)
          _rc_driveshaft_yoke(spec, phase=90);
      }
    }
    translate(start) rc_driveshaft_axis(axis) {
      color("#b8a384") translate([0, 0, yoke_l]) difference() {
        cylinder(d=plist_get("tube_d", spec), h=section_l);
        cylinder(d=plist_get("rod_d", spec), h=section_l * 2);
      }
      color("silver") translate([0, 0, l - yoke_l - section_l])
        cylinder(d=plist_get("rod_d", spec), h=section_l);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_driveshaft
  ─────────────────────────────────────────────────────────────────────────────
  Build an anchored shaft extending rearward along -Y, optionally dropping in Z.
  **Parameters:**
  - `l`: Actual pivot-to-pivot length, not horizontal projection.
  - `drop`: Height difference from the motor pivot down to the rear pivot.
  - `spec`: Shaft property list.
  - `slot_mode`: Emit clearance geometry instead of visible metal parts.
  - `clearance`: Radial allowance for slot mode.
  - `anchor`: Anchor on the complete conservative coupling envelope.
 */
module rc_driveshaft(l=driveshaft_l,
                     drop=driveshaft_drop,
                     spec=rc_driveshaft_plist,
                     slot_mode=false,
                     clearance=0,
                     anchor=[0, 0, 1]) {
  assert(abs(drop) < l);
  reach = plist_get("socket_l", spec);
  d = plist_get("joint_d", spec);
  projected_l = sqrt(l * l - drop * drop);
  size = [d, projected_l + reach * 2, d + abs(drop)];
  with_anchor(anchor, size, centered=true)
    rc_driveshaft_between([0, projected_l / 2, d / 2 + max(0, drop)],
                          [0, -projected_l / 2, d / 2 + max(0, -drop)],
                          spec=spec, slot_mode=slot_mode, clearance=clearance);
}

rc_driveshaft();
