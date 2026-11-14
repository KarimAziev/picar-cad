/**
 * Module: Placeholder for Servo Horn. Not printable
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */
include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/transforms.scad>
use <../lib/trapezoids.scad>
use <bolt.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  servo_horn_hole_offsets
  ─────────────────────────────────────────────────────────────────────────────
  Return positive screw-center distances from the horn axis along one arm.
  **Parameters:**
  - `center_ring_dia`: Hub diameter.
  - `screw_d`: Horn hole diameter.
  - `screw_holes_count`: Number of holes per arm.
  - `screws_gap`: Edge-to-edge gap between successive holes.
  - `initial_screws_gap`: Edge-to-edge gap from the hub to the first hole.
 */
function servo_horn_hole_offsets(center_ring_dia=servo_horn_center_ring_outer_dia,
                                 screw_d=servo_horn_screw_d,
                                 screw_holes_count=servo_horn_holes_n,
                                 screws_gap=servo_horn_screws_distance,
                                 initial_screws_gap=servo_horn_screws_initital_distance) =
  assert(center_ring_dia > 0 && screw_d > 0 && screws_gap >= 0)
  assert(initial_screws_gap >= 0)
  assert(screw_holes_count >= 0 && floor(screw_holes_count) == screw_holes_count)
  screw_holes_count == 0
  ? []
  : [for (i=[0:screw_holes_count - 1])
    (center_ring_dia / 2 + initial_screws_gap + screw_d / 2) + i * (screw_d + screws_gap)];

module with_servo_horn_holes(center_ring_dia=servo_horn_center_ring_outer_dia,
                             screw_d=servo_horn_screw_d,
                             screw_holes_count=servo_horn_holes_n,
                             screws_gap=servo_horn_screws_distance,
                             initial_screws_gap=servo_horn_screws_initital_distance,
                             dir=[-1, 1]) {
  offsets = servo_horn_hole_offsets(center_ring_dia,
                                    screw_d,
                                    screw_holes_count,
                                    screws_gap,
                                    initial_screws_gap=initial_screws_gap);

  if (len(offsets) > 0) {
    for (dir=dir,
         i=[0:len(offsets) - 1]) {
      translate([0, dir * offsets[i], 0]) {
        $i = i;
        children();
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  servo_horn_profile
  ─────────────────────────────────────────────────────────────────────────────
  Draw a horn profile centered on its shaft axis in the XY plane.

  **Parameters:**
  - `shape`: "cross" for four arms, "single" for +Y, or "double" for ±Y.
  - `mode`: "all" subtracts screw holes, "shape" emits the solid outline,
    and "holes" emits the selected screw-hole circles or child geometry.
  - `cross_side_holes`: "vertical" selects Y arms, "horizontal" selects X
    arms, and "all" selects both. Single and double horns use their Y arms.
  - `arm_len`: Distance from the shaft axis to the end of an arm.
  - `center_ring_dia`: Outer hub diameter.
  - `screw_d`: Nominal hole diameter used to calculate the measured hole layout.
  - `screw_holes_count`: Number of holes on each arm.
  - `arm_bottom_width`: Arm width at the shaft axis.
  - `arm_top_width`: Width of the rounded arm tip.
  - `screws_gap`: Edge-to-edge gap between successive holes.
  - `initial_screws_gap`: Edge-to-edge gap from the hub to the first hole.

  Children replace the default hole circles at every selected hole center;
  `$i` is the zero-based hole index along an arm. The outline includes the hub;
  it does not contain a central shaft opening.
 */
module servo_horn_profile(shape="cross", // "cross" | "single" | "double",
                          mode="all", // "all" | "shape" | "holes"
                          cross_side_holes="all", // "vertical" | "horizontal" | "all"
                          arm_len=servo_horn_arm_len,
                          center_ring_dia=servo_horn_center_ring_outer_dia,
                          screw_d=servo_horn_screw_d,
                          screw_holes_count=servo_horn_holes_n,
                          arm_bottom_width=servo_horn_starting_arm_w,
                          arm_top_width=servo_horn_ending_arm_w,
                          screws_gap=servo_horn_screws_distance,
                          initial_screws_gap=servo_horn_screws_initital_distance) {

  assert(in_list(shape, ["cross", "single", "double"]),
         "Servo horn shape must be 'single', 'double' or 'cross'!");
  assert(in_list(mode, ["all", "shape", "holes"]));
  assert(in_list(cross_side_holes, ["vertical", "horizontal", "all"]));
  has_children = $children > 0;
  rad = center_ring_dia / 2;
  screw_rad = screw_d / 2;

  is_single = shape == "single";

  is_cross = shape == "cross";

  module _profile_single() {
    hull() {
      circle(r=rad, $fn=30);
      translate([0, arm_len / 2, 0]) {
        trapezoid_rounded_top(b=arm_bottom_width,
                              t=arm_top_width,
                              r_factor=0.5,
                              h=arm_len,
                              center=true);
      }
    }
  }

  module _profile() {
    _profile_single();
    if (!is_single) {
      mirror([0, 1, 0]) {
        _profile_single();
      }
    }
  }

  module _profile_holes() {
    with_servo_horn_holes(center_ring_dia=center_ring_dia,
                          screw_d=screw_d,
                          screw_holes_count=screw_holes_count,
                          screws_gap=screws_gap,
                          initial_screws_gap=initial_screws_gap,
                          dir=is_single ? [1] : [1, -1]) {
      if (has_children) {
        children();
      } else {
        circle(r=screw_rad, $fn=10);
      }
    }
  }

  module _shape() {
    _profile();

    if (is_cross) {
      rotate([0, 0, 90]) {
        _profile();
      }
    }
  }

  module _shape_holes() {
    if (screw_holes_count > 0) {
      if (!is_cross || cross_side_holes == "vertical") {
        _profile_holes() {
          children();
        }
      } else if (cross_side_holes == "horizontal") {
        rotate([0, 0, 90]) {
          _profile_holes() {
            children();
          }
        }
      } else {
        _profile_holes() {
          children();
        }
        rotate([0, 0, 90]) {
          _profile_holes() {
            children();
          }
        }
      }
    }
  }

  if (mode == "all") {
    union() {
      difference() {
        _shape();

        _shape_holes() {
          children();
        }
      }
    }
  } else if (mode == "holes") {
    _shape_holes() {
      children();
    }
  } else {
    _shape();
  }
}

module servo_horn(shape="cross", // "cross" | "single" | "double"
                  center_ring_dia=servo_horn_center_ring_outer_dia,
                  center_ring_inner_dia=servo_horn_center_ring_inner_dia,
                  center_hole_dia=servo_horn_center_hole_dia,
                  thickness=servo_horn_arm_thickness,
                  arm_z_offset=servo_horn_arm_z_offset,
                  horn_height=servo_horn_ring_height,
                  arm_len=servo_horn_arm_len,
                  screw_d=servo_horn_screw_d,
                  screw_holes_count=servo_horn_holes_n,
                  arm_bottom_width=servo_horn_starting_arm_w,
                  arm_top_width=servo_horn_ending_arm_w,
                  screws_gap=servo_horn_screws_distance,
                  bolt_color=matte_black,
                  cross_side_holes="vertical", // | "vertical" | "horizontal" | "all"
                  show_bolt=true,
                  show_screws=true,
                  initial_screws_gap=servo_horn_screws_initital_distance,
                  color=servo_horn_color,
                  reverse_screws=false,
                  reverse=false,
                  center=true) {
  rad = center_ring_dia / 2;

  translate([center ? 0 : arm_len,
             center ? 0 : arm_len,
             reverse ? horn_height : 0]) {
    maybe_rotate([0, reverse ? 180 : 0, 0]) {
      union() {
        color(color, alpha=1) {
          union() {
            translate([0, 0, arm_z_offset]) {
              linear_extrude(height=thickness, center=false) {
                difference() {
                  union() {
                    servo_horn_profile(shape=shape,
                                       mode="all",
                                       cross_side_holes="all",
                                       arm_len=arm_len,
                                       center_ring_dia=center_ring_dia,
                                       screw_d=screw_d,
                                       screw_holes_count=screw_holes_count,
                                       arm_bottom_width=arm_bottom_width,
                                       arm_top_width=arm_top_width,
                                       screws_gap=screws_gap,
                                       initial_screws_gap=initial_screws_gap);

                    circle(r=rad, $fn=60);
                  }
                  circle(r=center_hole_dia / 2, $fn=40);
                }
              }
            }

            linear_extrude(height=horn_height, center=false) {
              ring_2d(r=rad,
                      w=(center_ring_dia - center_ring_inner_dia) / 2,
                      fn=40,
                      outer=false);
            }
          }
        }
        if (show_bolt) {
          let (d = center_hole_dia,
               bolt_h = round(horn_height)) {
            translate([0, 0, -bolt_h + arm_z_offset + thickness]) {
              bolt(d=d, h=bolt_h, bolt_color=bolt_color);
            }
          }
        }

        if (show_screws) {
          let (d = screw_d,
               bolt_h = thickness + 1,
               z = arm_z_offset + thickness - bolt_h) {
            servo_horn_profile(shape=shape,
                               mode="holes",
                               cross_side_holes=cross_side_holes,
                               arm_len=arm_len,
                               center_ring_dia=center_ring_dia,
                               screw_d=screw_d,
                               screw_holes_count=screw_holes_count,
                               arm_bottom_width=arm_bottom_width,
                               arm_top_width=arm_top_width,
                               screws_gap=screws_gap,
                               initial_screws_gap=initial_screws_gap) {

              if ($i % 2 != 0 || screw_holes_count == 1) {
                translate([0, 0, z]) {
                  bolt(d=d,
                       reverse=reverse_screws,
                       h=bolt_h,
                       screw_mode=true,
                       bolt_color=metallic_silver_1);
                }
              }
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  servo_horn_profile_from_plist
  ─────────────────────────────────────────────────────────────────────────────
  Draw the horn outline or mounting holes about the shaft axis in the XY plane.

  **Parameters:**
  - `pl`: Horn dimensions keyed by servo_horn parameter names; defaults to
    `servo_horn_default_plist`. Shapes are "cross", "single" (+Y), or "double" (±Y).
  - `mode`: "shape" for a solid outline, "holes" for screw cutouts, "all" for
    the outline with screw cutouts.
  - `clearance`: Nonnegative XY outline offset per side.
  - `screw_clearance`: Nonnegative radial hole allowance; centers stay fixed.
  - `shape`: Optional override of the plist's arm arrangement.
  - `cross_side_holes`: Optional "vertical", "horizontal", or "all" selection.

  Child geometry, when supplied, is placed at each selected hole center with
  `$i` identifying the hole along its arm. Screw clearance applies to the
  default circles only. The central shaft opening is supplied by the mount.
 */
module servo_horn_profile_from_plist(pl=servo_horn_default_plist,
                                     mode="all",
                                     clearance=0,
                                     screw_clearance=0,
                                     shape=undef,
                                     cross_side_holes=undef) {
  assert(plist_is(pl) && len(pl) > 0, "Supply a hardware specification");
  assert(clearance >= 0 && screw_clearance >= 0);
  assert(in_list(mode, ["all", "shape", "holes"]));
  props = pl;
  has_children = $children > 0;
  module profile(profile_mode) {
    servo_horn_profile(shape=with_default(shape, plist_get("shape", props)),
                       mode=profile_mode,
                       cross_side_holes=with_default(cross_side_holes,
                                                     plist_get("cross_side_holes", props)),
                       arm_len=plist_get("arm_len", props),
                       center_ring_dia=plist_get("center_ring_dia", props),
                       screw_d=plist_get("screw_d", props),
                       screw_holes_count=plist_get("screw_holes_count", props),
                       arm_bottom_width=plist_get("arm_bottom_width", props),
                       arm_top_width=plist_get("arm_top_width", props),
                       screws_gap=plist_get("screws_gap", props),
                       initial_screws_gap=plist_get("initial_screws_gap", props)) {
      if (has_children) {
        children();
      } else {
        circle(d=plist_get("screw_d", props) + 2 * screw_clearance, $fn=40);
      }
    }
  }
  if (mode == "holes") {
    profile("holes") {
      children();
    }
  } else {
    difference() {
      offset(delta=clearance) {
        profile("shape");
      }
      if (mode == "all") {
        profile("holes") {
          children();
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  servo_horn_from_plist
  ─────────────────────────────────────────────────────────────────────────────
  Draw a horn with its shaft axis at XY zero and its hub bottom at Z zero.

  **Parameters:**
  - `pl`: Horn dimensions keyed by servo_horn parameter names; defaults to
    `servo_horn_default_plist`.
  - `show_bolt`: Display the central fastener.
  - `show_screws`: Display alternating arm fasteners.
  - `reverse_screws`: Reverse the arm fasteners.
  - `reverse`: Turn the horn over within its hub-height interval.
  - `center`: Keep the shaft at XY zero; false shifts XY by arm_len.
  - `shape`: Optional override of the plist's arm arrangement.
  - `cross_side_holes`: Optional override of the plist's screw-arm selection.
 */
module servo_horn_from_plist(pl=servo_horn_default_plist,
                             show_bolt=true,
                             show_screws=true,
                             reverse_screws=false,
                             reverse=false,
                             center=true,
                             shape=undef,
                             cross_side_holes=undef) {
  assert(plist_is(pl) && len(pl) > 0, "Supply a hardware specification");
  props = pl;
  servo_horn(shape=with_default(shape, plist_get("shape", props)),
             cross_side_holes=with_default(cross_side_holes,
                                           plist_get("cross_side_holes", props)),
             show_bolt=show_bolt,
             show_screws=show_screws,
             reverse_screws=reverse_screws,
             reverse=reverse,
             center=center,
             center_ring_dia=plist_get("center_ring_dia", props),
             center_ring_inner_dia=plist_get("center_ring_inner_dia", props),
             center_hole_dia=plist_get("center_hole_dia", props),
             thickness=plist_get("thickness", props),
             arm_z_offset=plist_get("arm_z_offset", props),
             horn_height=plist_get("horn_height", props),
             arm_len=plist_get("arm_len", props),
             screw_d=plist_get("screw_d", props),
             screw_holes_count=plist_get("screw_holes_count", props),
             arm_bottom_width=plist_get("arm_bottom_width", props),
             arm_top_width=plist_get("arm_top_width", props),
             screws_gap=plist_get("screws_gap", props),
             initial_screws_gap=plist_get("initial_screws_gap", props),
             color=plist_get("color", props));
}

servo_horn(center=true,
           show_screws=true,
           show_bolt=false,
           cross_side_holes="all",
           shape="cross");
