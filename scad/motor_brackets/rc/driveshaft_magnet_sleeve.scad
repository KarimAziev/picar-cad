/**
  * Module: Encoder magnet sleeve for the unused gearmotor shaft end.
  *
  * A keyed shaft cup with a cross-hole, an open bore and a retaining lip.
  * Its local +Z axis points from the shaft shoulder toward the encoder.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../../colors.scad>
include <../../rc_params.scad>

use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  driveshaft_magnet_sleeve_params
  ─────────────────────────────────────────────────────────────────────────────

  Resolve the sleeve dimensions and axial datums from the shaft hardware.

  **Parameters:**
  - `drive_shaft`: Hardware plist with `d`, `pad_l`, `flat_d`,
    `flat_both_sides`, `hole_d` and `hole_edge_dist`. The latter is an
    edge-to-edge gap; zero or omitted `hole_d` disables the cross-hole.
  - `magnet_d`, `magnet_h`: Actual magnet diameter and thickness.
  - `mount_thickness`, `wall_thickness`: Material outside the shaft and magnet bores.
  - `d_clearance`: Diametral shaft clearance, also added to the flat thickness.
  - `h_clearance`: Axial gap from shaft tip to the magnet pocket shoulder.
  - `magnet_d_clearance`: Diametral magnet-pocket clearance.
  - `magnet_h_clearance`: Lip height minus magnet thickness. Negative exposes
    the magnet face; positive recesses it. The magnet rests on the annular pocket shoulder.
  - `transition_h`: Length of the widening transition at the end of the cup.

  **Returns:**
  A plist in local shaft-axis coordinates. `shaft_tip_z`, `hole_z`,
  `magnet_bottom_z`, and `magnet_face_z` are measured from the cup's open end.
  `size` is the full circular reference envelope of the printed part, excluding
  a protruding magnet. Outer diameters include bore clearance plus two walls.
 */
function driveshaft_magnet_sleeve_params(drive_shaft=plist_get("drive_shaft", motor_plist),
                                         magnet_d=motor_encoder_magnet_d,
                                         magnet_h=motor_encoder_magnet_h,
                                         mount_thickness=motor_encoder_sleeve_mount_wall_thickness,
                                         wall_thickness=motor_encoder_sleeve_wall_thickness,
                                         d_clearance=motor_encoder_sleeve_d_clearance,
                                         h_clearance=motor_encoder_sleeve_h_clearance,
                                         magnet_d_clearance=motor_encoder_magnet_d_clearance,
                                         magnet_h_clearance=motor_encoder_magnet_h_clearance,
                                         transition_h=motor_encoder_transition_h) =
  let (d = plist_get("d", drive_shaft),
       pad_l = plist_get("pad_l", drive_shaft),
       flat_d = plist_get("flat_d", drive_shaft, d / 2),
       hole_d = plist_get("hole_d", drive_shaft, 0),
       edge = plist_get("hole_edge_dist", drive_shaft, 2),
       bore_d = d + d_clearance,
       bore_flat_d = flat_d + d_clearance,
       od = bore_d + 2 * mount_thickness,
       magnet_bore_d = magnet_d + magnet_d_clearance,
       magnet_od = magnet_bore_d + 2 * wall_thickness,
       cup_h = pad_l + h_clearance,
       lip_h = magnet_h + magnet_h_clearance,
       height = cup_h + lip_h)
  assert(d > 0 && pad_l > 0 && flat_d > 0 && flat_d <= d,
         "Invalid shaft diameter, flat thickness or pad length")
  assert(min(magnet_d, magnet_h, mount_thickness, wall_thickness) > 0
         && min(d_clearance, h_clearance, magnet_d_clearance) >= 0,
         "Sleeve walls and hardware must be positive; fit clearances nonnegative")
  assert(lip_h > 0 && transition_h >= 0 && transition_h <= cup_h,
         "Magnet lip must be positive and transition must fit within the cup")
  assert(magnet_od > bore_d,
         "Magnet holder must connect to the shaft cup wall")
  assert(hole_d >= 0 && edge >= 0 && (hole_d == 0 || edge + hole_d < pad_l),
         "Cross-hole must leave material at both ends of the shaft cup")
  ["drive_shaft", drive_shaft,
   "bore_d", bore_d,
   "bore_flat_d", bore_flat_d,
   "flat_both_sides", plist_get("flat_both_sides", drive_shaft, false),
   "od", od,
   "flat_od", bore_flat_d + 2 * mount_thickness,
   "cup_h", cup_h,
   "shaft_tip_z", pad_l,
   "hole_d", hole_d,
   "hole_z", pad_l - edge - hole_d / 2,
   "magnet_d", magnet_d,
   "magnet_h", magnet_h,
   "magnet_bore_d", magnet_bore_d,
   "magnet_od", magnet_od,
   "magnet_bottom_z", cup_h,
   "magnet_face_z", cup_h + magnet_h,
   "lip_h", lip_h,
   "transition_h", transition_h,
   "size", [max(od, magnet_od), max(od, magnet_od), height]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  driveshaft_magnet_sleeve
  ─────────────────────────────────────────────────────────────────────────────

  Render the printable sleeve, magnet, or its full rotating clearance envelope.

  **Parameters:**
  - `params`: Result of `driveshaft_magnet_sleeve_params()`.
  - `anchor`: Circular reference-box anchor; default retains the axis at X=Y=0
    and the open cup end at Z=0. Body, magnet and slot share this reference.
  - `slot_mode`: Emit the complete swept cylindrical envelope, including a
    protruding magnet, for clearance cuts in surrounding parts.
  - `show_sleeve`: Display the printed part.
  - `show_magnet`: Display the magnet resting on the annular pocket shoulder.
  - `use_flat_d_form`: Flatten the outside of the shaft cup as well as its bore.
  - `use_hull`: Loft the cup profile into the round magnet holder.
  - `color`, `magnet_color`: Printable part and hardware colors.

  The shaft bore opens directly into the magnet pocket; no membrane spans it.
  A single flat faces +Y. When fitted to the unused shaft end, preserve that
  flat direction while reversing the shaft axis. The cross-hole runs along Y.
 */
module driveshaft_magnet_sleeve(params=driveshaft_magnet_sleeve_params(),
                                anchor=[0, 0, 1],
                                slot_mode=false,
                                show_sleeve=true,
                                show_magnet=false,
                                use_flat_d_form=false,
                                use_hull=false,
                                color=cobalt_blue_metallic,
                                magnet_color=metallic_silver_2) {
  fn = $preview ? 48 : 300;
  size = plist_get("size", params);
  od = plist_get("od", params);
  cup_h = plist_get("cup_h", params);
  magnet_od = plist_get("magnet_od", params);
  seat_z = plist_get("magnet_bottom_z", params);
  transition_h = plist_get("transition_h", params);
  hole_d = plist_get("hole_d", params);

  module cup_profile(h) {
    if (use_flat_d_form) {
      flatted_cyl(d=od,
                  h=h,
                  flat_d=plist_get("flat_od", params),
                  both_sides=plist_get("flat_both_sides", params),
                  $fn=fn);
    } else {
      cylinder(d=od, h=h, $fn=fn);
    }
  }

  with_anchor(size=size, anchor=anchor, centered=true) {
    if (slot_mode) {
      cylinder(d=size[0],
               h=max(size[2], plist_get("magnet_face_z", params)),
               $fn=fn);
    } else {
      if (show_sleeve) {
        color(color) {
          difference() {
            union() {
              cup_profile(cup_h);
              if (transition_h > 0) {
                translate([0, 0, cup_h - transition_h]) {
                  if (use_hull || use_flat_d_form) {
                    hull() {
                      cup_profile(0.01);
                      translate([0, 0, transition_h - 0.01]) {
                        cylinder(d=magnet_od, h=0.01, $fn=fn);
                      }
                    }
                  } else {
                    cylinder(d1=od, d2=magnet_od, h=transition_h, $fn=fn);
                  }
                }
              }
              // Overlap the cup and holder rather than joining coplanar caps.
              translate([0, 0, cup_h - 0.01]) {
                cylinder(d=magnet_od, h=size[2] - cup_h + 0.01, $fn=fn);
              }
            }
            translate([0, 0, -0.1]) {
              flatted_cyl(d=plist_get("bore_d", params),
                          h=cup_h + 0.2,
                          flat_d=plist_get("bore_flat_d", params),
                          both_sides=plist_get("flat_both_sides", params),
                          $fn=fn);
            }
            translate([0, 0, seat_z]) {
              cylinder(d=plist_get("magnet_bore_d", params),
                       h=plist_get("lip_h", params) + 0.1,
                       $fn=fn);
            }
            if (hole_d > 0) {
              translate([0, size[0] / 2 + 0.1, plist_get("hole_z", params)]) {
                rotate([90, 0, 0]) {
                  counterbore(h=size[0] + 0.2,
                              d=hole_d,
                              fn=fn,
                              teardrop_angle=45,
                              teardrop_both_sides=true);
                }
              }
            }
          }
        }
      }
      if (show_magnet) {
        translate([0, 0, seat_z]) {
          color(magnet_color) {
            cylinder(d=plist_get("magnet_d", params),
                     h=plist_get("magnet_h", params),
                     $fn=fn);
          }
        }
      }
    }
  }
}

driveshaft_magnet_sleeve();
