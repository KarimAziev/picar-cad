/**
  * Module: Telescoping RC propeller shaft with two universal-joint placeholders.
  *
  * Measured tube, socket and unequal fork lengths share explicit pivot datums.
  * The assembly length selects telescopic extension; hidden rod length, fork
  * cutouts, pivot pins and the joint-angle limit remain packaging assumptions.
  */
include <../parameters.scad>

use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/transforms.scad>

driveshaft_l    = plist_get("pivot_l", rc_driveshaft_plist);
driveshaft_drop = 0;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_driveshaft_hub_l
  ─────────────────────────────────────────────────────────────────────────────
  Return the socket's bored cylindrical length, excluding its fork.
  **Parameters:**
  - `spec`: Shaft property list.
  **Returns:** Positive hub length in mm.
 */
function rc_driveshaft_hub_l(spec=rc_driveshaft_plist) =
  let (l = plist_get("hub_l", spec))
  assert(l > 0 && l < plist_get("socket_pivot_l", spec),
         "Socket must include a hub and a fork") l;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_driveshaft_min_l
  ─────────────────────────────────────────────────────────────────────────────
  Return pivot spacing when the sliding rod has no exposed cylindrical length.
  **Parameters:**
  - `spec`: Shaft property list.
  **Returns:** Geometric closed length in mm, not a verified operating minimum.
 */
function rc_driveshaft_min_l(spec=rc_driveshaft_plist) =
  plist_get("tube_pivot_l", spec) + plist_get("rod_yoke_pivot_l", spec);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_driveshaft_max_l
  ─────────────────────────────────────────────────────────────────────────────
  Return pivot spacing at the measured maximum visible rod extension.
  **Parameters:**
  - `spec`: Shaft property list.
  **Returns:** Maximum modeled pivot spacing in mm.
 */
function rc_driveshaft_max_l(spec=rc_driveshaft_plist) =
  rc_driveshaft_min_l(spec) + plist_get("rod_max_exposed_l", spec);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_driveshaft_rod_l
  ─────────────────────────────────────────────────────────────────────────────
  Return the sliding rod's complete cylindrical length, including insertion.
  **Parameters:**
  - `spec`: Shaft property list; an undefined `rod_l` uses `tube_l` provisionally.
  **Returns:** Length in mm, not just the exposed portion.
 */
function rc_driveshaft_rod_l(spec=rc_driveshaft_plist) =
  let (l = plist_get("rod_l", spec))
  is_undef(l) ? plist_get("tube_l", spec) : l;

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
  rotate([0, acos(direction[2] / norm(direction)), atan2(direction[1], direction[0])]) {
    children();
  }
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

module _rc_driveshaft_yoke(spec, l, back_l, phase=0) {
  d = plist_get("joint_d", spec);
  pin_d = plist_get("pin_d", spec);
  // Provisional arm thickness: the perpendicular forks must not share corners.
  fork_w = d - pin_d;
  assert(l > pin_d / 2 && back_l >= pin_d / 2 && d > pin_d * 2);
  assert(fork_w > d / sqrt(2), "Perpendicular fork arms overlap");
  rotate([0, 0, phase]) {
    difference() {
      translate([0, 0, -back_l]) {
        cylinder(d=d, h=l + back_l);
      }
      translate([0, 0, -back_l * 2]) {
        cuboid([fork_w, d * 2, back_l * 2 + l - pin_d / 2],
               anchor=[0, 0, 1]);
      }
    }
    rotate([0, 90, 0]) {
      cylinder(d=pin_d, h=d, center=true);
    }
  }
}

module _rc_driveshaft_hub(spec) {
  l = rc_driveshaft_hub_l(spec);
  reach = plist_get("socket_pivot_l", spec);
  yoke_l = reach - l;
  back_l = plist_get("socket_l", spec) - reach;
  d = plist_get("joint_d", spec);
  difference() {
    translate([0, 0, yoke_l]) {
      cylinder(d=d, h=l);
    }
    translate([0, 0, yoke_l]) {
      cylinder(d=plist_get("bore_d", spec) + plist_get("bore_clearance", spec) * 2,
               h=l * 2);
    }
    translate([0, 0, yoke_l + l / 2]) {
      rotate([0, 90, 0]) {
        cylinder(d=plist_get("pin_d", spec), h=d, center=true);
      }
    }
  }
  _rc_driveshaft_yoke(spec, yoke_l, back_l);
}

module _rc_driveshaft_tube(spec) {
  l = plist_get("tube_l", spec);
  reach = plist_get("tube_pivot_l", spec);
  yoke_l = reach - l;
  _rc_driveshaft_yoke(spec,
                      yoke_l,
                      plist_get("tube_total_l", spec) - reach,
                      phase=90);
  translate([0, 0, yoke_l]) {
    difference() {
      cylinder(d=plist_get("tube_d", spec), h=l);
      cylinder(d=plist_get("rod_d", spec), h=l * 2);
    }
  }
}

module _rc_driveshaft_rod(spec) {
  yoke_l = plist_get("rod_yoke_pivot_l", spec);
  _rc_driveshaft_yoke(spec,
                      yoke_l,
                      plist_get("rod_yoke_l", spec) - yoke_l,
                      phase=90);
  translate([0, 0, yoke_l]) {
    cylinder(d=plist_get("rod_d", spec), h=rc_driveshaft_rod_l(spec));
  }
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
module rc_driveshaft_between(start,
                             end,
                             start_axis=[0, 1, 0],
                             end_axis=[0, -1, 0],
                             spec=rc_driveshaft_plist,
                             slot_mode=false,
                             clearance=0) {
  axis = end - start;
  l = norm(axis);
  tube_l = plist_get("tube_l", spec);
  tube_reach = plist_get("tube_pivot_l", spec);
  tube_back_l = plist_get("tube_total_l", spec) - tube_reach;
  rod_l = rc_driveshaft_rod_l(spec);
  rod_yoke_l = plist_get("rod_yoke_pivot_l", spec);
  rod_back_l = plist_get("rod_yoke_l", spec) - rod_yoke_l;
  joint_d = plist_get("joint_d", spec);
  socket_reach = plist_get("socket_pivot_l", spec);
  socket_back_l = plist_get("socket_l", spec) - socket_reach;
  // The slot capsule contains the backs of all forks, also when articulated.
  slot_d = max(plist_get("tube_d", spec),
               2 * norm([joint_d / 2, max(tube_back_l, rod_back_l, socket_back_l)]));
  assert(rc_driveshaft_min_l(spec) <= l + 0.000001
         && l <= rc_driveshaft_max_l(spec) + 0.000001,
         "Driveshaft outside measured telescopic travel");
  assert(rod_l > plist_get("rod_max_exposed_l", spec) && rod_l <= tube_l,
         "Rod must retain engagement at full extension and fit inside the tube when closed");
  assert(plist_get("rod_d", spec) < plist_get("tube_d", spec));
  assert(clearance >= 0);
  for (hub_axis = [start_axis, end_axis]) {
    assert(rc_driveshaft_joint_angle(axis, hub_axis) <= plist_get("max_angle", spec),
           "Universal-joint angle exceeds packaging limit");
  }
  $fn = $preview ? 32 : 64;

  if (slot_mode) {
    hull() {
      for (p = [start, end]) {
        translate(p) {
          sphere(d=(slot_d + clearance * 2) / pow(cos(180 / $fn), 2));
        }
      }
    }
    for (i = [0:1]) {
      translate([start, end][i]) {
        rc_driveshaft_axis([start_axis, end_axis][i]) {
          cylinder(d=(joint_d + clearance * 2) / cos(180 / $fn),
                   h=socket_reach + clearance);
        }
      }
    }
  } else {
    for (i = [0:1]) {
      translate([start, end][i]) {
        color("silver") {
          rc_driveshaft_axis([start_axis, end_axis][i]) {
            _rc_driveshaft_hub(spec);
          }
        }
      }
    }
    translate(start) {
      rc_driveshaft_axis(axis) {
        color("#b8a384") {
          _rc_driveshaft_tube(spec);
        }
      }
    }
    translate(end) {
      rc_driveshaft_axis(-axis) {
        color("silver") {
          _rc_driveshaft_rod(spec);
        }
      }
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
  reach = plist_get("socket_pivot_l", spec);
  d = max(plist_get("joint_d", spec), plist_get("tube_d", spec));
  back_l = max(plist_get("tube_total_l", spec) - plist_get("tube_pivot_l", spec),
               plist_get("rod_yoke_l", spec) - plist_get("rod_yoke_pivot_l", spec));
  bend = asin(abs(drop) / l);
  h = max(d, d * cos(bend) + back_l * sin(bend) * 2);
  projected_l = sqrt(l * l - drop * drop);
  size = [d, projected_l + reach * 2, h + abs(drop)];
  with_anchor(anchor, size, centered=true) {
    rc_driveshaft_between([0, projected_l / 2, h / 2 + max(0, drop)],
                          [0, -projected_l / 2, h / 2 + max(0, -drop)],
                          spec=spec,
                          slot_mode=slot_mode,
                          clearance=clearance);
  }
}

rc_driveshaft();
