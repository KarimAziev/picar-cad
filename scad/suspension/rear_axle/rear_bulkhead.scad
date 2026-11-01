/**
  * Module: Split rear differential bulkhead and lower-arm pivots.
  *
  * The reference box is centered on X/Y and begins at the mounting plane Z=0.
  * Its Y axis points toward the motor; vehicle rear is -Y. Both housing halves
  * use the same box. The main exterior follows the front suspension housing;
  * a rounded crown cover follows the gear clearance envelope. The input bearing
  * support and upper captive-nut tabs complete its interfaces.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <structure_params.scad>

use <../../lib/plist.scad>
use <../../lib/transforms.scad>
use <../../placeholders/differential.scad>
use <../../placeholders/hsp_rear_drivetrain.scad>
use <rear_lower_arm.scad>
use <rear_shock_tower.scad>
use <../bulkhead/front_bulkhead.scad>
use <../bulkhead/front_bulkhead_chassis.scad>
use <../bulkhead/front_bulkhead_housing.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_bulkhead_split_z
  ─────────────────────────────────────────────────────────────────────────────
  Return the lower housing's top mating plane.
  **Parameters:**
  - `pl`: `rear_housing_spec` from `structure_params.scad`.
 */
function rear_bulkhead_split_z(pl) = plist_get("base_h", pl);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_bulkhead_hinge_axis
  ─────────────────────────────────────────────────────────────────────────────
  Return the right inner hinge center in the axle frame.
  **Parameters:**
  - `pl`: `rear_housing_spec` from `scad/suspension/rear_axle/structure_params.scad`.
  - `arm`: `rear_lower_arm_spec` from `arm_hub_params.scad`; accepted for assembly-interface consistency. The housing owns its hinge datum.
 */
function rear_bulkhead_hinge_axis(pl, arm) =
  [plist_get("hinge_axis_x", pl), plist_get("hinge_axis_y", pl),
   plist_get("hinge_axis_z", pl)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_bulkhead_axis
  ─────────────────────────────────────────────────────────────────────────────
  Return the differential center in the axle frame.
  **Parameters:**
  - `pl`: `rear_housing_spec` from `structure_params.scad`; `differential_axis_z` sets the axis height.
  - `differential`: `rear_differential_spec` from `hardware_params.scad`; accepted by the common housing helper interface.
 */
function rear_bulkhead_axis(pl, differential) =
  [0, 0, plist_get("differential_axis_z", pl)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_bulkhead_body_w
  ─────────────────────────────────────────────────────────────────────────────
  Return the bearing-support shell width along X.
  **Parameters:**
  - `pl`: `rear_housing_spec` from `structure_params.scad`; `body_w` defines the exterior.
  - `differential`: `rear_differential_spec` from `hardware_params.scad`; accepted by the common housing helper interface.
 */
function rear_bulkhead_body_w(pl, differential) =
  plist_get("body_w", pl);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_bulkhead_outer_r
  ─────────────────────────────────────────────────────────────────────────────
  Return half the main housing length along Y.
  **Parameters:**
  - `pl`: `rear_housing_spec` from `structure_params.scad`; `body_l` defines the exterior.
  - `differential`: `rear_differential_spec` from `hardware_params.scad`; accepted by the common housing helper interface.
 */
function rear_bulkhead_outer_r(pl, differential) =
  plist_get("body_l", pl) / 2;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_bulkhead_pinion_origin
  ─────────────────────────────────────────────────────────────────────────────
  Return the pinion gear-end center; its shaft extends in +Y.
  **Parameters:**
  - `pl`: `rear_housing_spec` from `structure_params.scad`; explicit X/Y/Z input datums.
  - `differential`: `rear_differential_spec` from `hardware_params.scad`; accepted by the common housing helper interface.
  - `pinion`: `rear_pinion_spec` from `hardware_params.scad`; its gear-end face defines the datum convention.
 */
function rear_bulkhead_pinion_origin(pl, differential, pinion) =
  [plist_get("pinion_axis_x", pl), plist_get("pinion_mesh_y", pl),
   plist_get("pinion_axis_z", pl)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_bulkhead_pinion_neck_end
  ─────────────────────────────────────────────────────────────────────────────
  Return the motor-facing end of the pinion support along Y.
  **Parameters:**
  - `pl`: `rear_housing_spec` from `structure_params.scad`.
  - `pinion`: `rear_pinion_spec` from `hardware_params.scad`; bearing centers and width.
 */
function rear_bulkhead_pinion_neck_end(pl, pinion) =
  plist_get("pinion_mesh_y", pl)
  + max(plist_get("bearing_centers_z", pinion))
  + plist_get("bearing_h", pinion) / 2 + plist_get("bearing_lip", pl);

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_bulkhead_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the shared centered-X/Y reference box for both housing halves.
  **Parameters:**
  - `pl`: `rear_housing_spec` from `structure_params.scad`.
  - `differential`: `rear_differential_spec` from `hardware_params.scad`; accepted by the common housing helper interface.
  - `pinion`: `rear_pinion_spec` from `hardware_params.scad`.
  - `tower`: `rear_tower_spec` from `structure_params.scad`; common housing helper interface.
 */
function rear_bulkhead_size(pl, differential, pinion, tower) =
  [plist_get("body_w", pl) + 2 * plist_get("barrel_w", pl),
   2 * max(plist_get("body_l", pl) / 2
             + front_bulkhead_suspension_pad_thickness
             + front_suspension_arm_pad_thickness,
           rear_bulkhead_pinion_neck_end(pl, pinion)),
   plist_get("base_h", pl) + plist_get("upper_h", pl)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_bulkhead_mount_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return the shared front housing mounting pattern in the rear axle frame.
  **Parameters:**
  - `layout`: `rear_chassis_layout()` from `../rear_chassis/computed_params.scad`; accepted for assembly-interface consistency.
  - `bolt_spacing`, `inner_row_spacing`: Accepted by the assembly helper interface. The shared front housing owns the eight-point mounting pattern.
  **Returns:** Eight XYZ points at Z=0 from `front_bulkhead_housing_mount_positions()` in `../bulkhead/front_bulkhead_chassis.scad`.
 */
function rear_bulkhead_mount_positions(layout, bolt_spacing, inner_row_spacing) =
  front_bulkhead_housing_mount_positions();

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_bulkhead_fastener_positions
  ─────────────────────────────────────────────────────────────────────────────
  Return mounting centers retained by captive nuts in the upper housing.
  **Parameters:**
  - `pl`: `rear_housing_spec` from `structure_params.scad`; explicit
    `mount_fastener_indices` select sufficiently spaced nut pockets.
  - `mounts`: Eight XYZ centers from `rear_bulkhead_mount_positions()`.
  **Returns:** XYZ positions used by upper tabs, nut pockets and assembly bolts.
 */
function rear_bulkhead_fastener_positions(pl, mounts) =
  [for (i = plist_get("mount_fastener_indices", pl))
    assert(is_num(i) && i == floor(i) && i >= 0 && i < len(mounts),
           "Mount fastener index must select a supplied mounting center")
    mounts[i]];


/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_bulkhead_link_position
  ─────────────────────────────────────────────────────────────────────────────
  Return the right camber-link hole center on the tower rear face.
  **Parameters:**
  - `pl`: `rear_housing_spec` from `structure_params.scad`.
  - `differential`: `rear_differential_spec` from `hardware_params.scad`; accepted by the common housing helper interface.
  - `tower`: `rear_tower_spec` from `structure_params.scad`; camber-link X/Z offsets.
 */
function rear_bulkhead_link_position(pl, differential, tower) =
  let (origin = rear_bulkhead_tower_origin(pl, differential, tower))
  [plist_get("link_x", tower),
   origin[1] - plist_get("thickness", tower) / 2,
   origin[2] + plist_get("link_z", tower)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_bulkhead_tower_origin
  ─────────────────────────────────────────────────────────────────────────────
  Return the tower lower-left datum at the rear mounting face.
  **Parameters:**
  - `pl`: `rear_housing_spec` from `structure_params.scad`.
  - `differential`: `rear_differential_spec` from `hardware_params.scad`; accepted by the common housing helper interface.
  - `tower`: `rear_tower_spec` from `structure_params.scad`; tower width and mounting datum.
 */
function rear_bulkhead_tower_origin(pl, differential, tower) =
  [-plist_get("w", tower) / 2,
   -plist_get("tower_mount_thickness", pl) / 2,
   plist_get("tower_lower_bolt_z", pl) - plist_get("mount_z", tower)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_bulkhead
  ─────────────────────────────────────────────────────────────────────────────
  Build the lower housing or removable lid with shared bearing and shaft seats.
  **Parameters:**
  - `pl`: `rear_housing_spec` from `structure_params.scad`, including exterior, independent shaft datums, clearances and mounting retention.
  - `differential`: `rear_differential_spec` from `hardware_params.scad`.
  - `pinion`: `rear_pinion_spec` from `hardware_params.scad`.
  - `arm`: `rear_lower_arm_spec` from `arm_hub_params.scad`; common assembly helper interface.
  - `tower`: `rear_tower_spec` from `structure_params.scad`; controls mounting bolt pattern.
  - `mounts`: `rear_bulkhead_mount_positions(layout, bolt_spacing, inner_row_spacing)`; XYZ points in the axle frame.
  - `part`: `"lower"` or `"lid"`.
  - `anchor`: Common reference-box anchor, default centered X/Y at the base.
  - `slot_mode`: Emit mounting, assembly, bearing and gear clearance cutters.
  - `show_hardware`: Show the differential and pinion in their operating datums.
 */
module rear_bulkhead(pl,
                     differential,
                     pinion,
                     arm,
                     tower,
                     mounts,
                     part="lower",
                     anchor=[0, 0, 1],
                     slot_mode=false,
                     show_hardware=false) {
  a = rear_bulkhead_axis(pl, differential);
  size = rear_bulkhead_size(pl, differential, pinion, tower);
  e = plist_get("csg_epsilon", pl);
  base_h = rear_bulkhead_split_z(pl);
  fastener_positions = rear_bulkhead_fastener_positions(pl, mounts);
  pinion_pos = rear_bulkhead_pinion_origin(pl, differential, pinion);
  neck_end = rear_bulkhead_pinion_neck_end(pl, pinion);
  tower_pos = rear_bulkhead_tower_origin(pl, differential, tower);
  bearing_clearance = plist_get("bearing_clearance", pl);
  bearing_axial = plist_get("bearing_axial_clearance", pl);
  gear = hsp_rear_differential_gear_position(differential)
           - hsp_rear_differential_axis(differential) + a;
  crown_wall = plist_get("crown_cover_wall", pl);
  crown_edge_r = plist_get("crown_cover_edge_r", pl);
  crown_cover_r = plist_get("gear_d", differential) / 2
                   + plist_get("gear_clearance", pl) + crown_wall;
  crown_cover_l = plist_get("gear_h", differential)
                   + 2 * (bearing_axial + crown_wall);
  $fn = plist_get("fn", pl);
  assert(part == "lower" || part == "lid");
  assert(base_h > 0 && plist_get("input_support_wall", pl) > 0);
  assert(crown_wall > 0 && crown_edge_r > 0 && crown_edge_r <= crown_wall,
         "Crown edge radius must be positive and at most the cover wall");
  assert(abs(gear[0]) + crown_cover_l / 2 <= size[0] / 2
           && abs(gear[1]) + crown_cover_r <= size[1] / 2
           && gear[2] + crown_cover_r <= size[2],
         "Crown cover must fit within the housing reference box");

  module x_bore(pos, d, length) {
    translate(pos) {
      rotate([0, 90, 0]) { cylinder(d=d, h=length, center=true); }
    }
  }
  module y_bore(pos, d, length) {
    translate(pos) {
      rotate([90, 0, 0]) { cylinder(d=d, h=length, center=true); }
    }
  }
  module mounting_tabs(z, h) {
    for (p = fastener_positions) {
      hull() {
        translate(p + [0, 0, z]) {
          cylinder(d=plist_get("mount_bolt_d", pl)
                     + 2 * plist_get("mount_pad", pl), h=h);
        }
        translate([0, p[1], z]) {
          cylinder(d=plist_get("mount_bolt_d", pl)
                     + 2 * plist_get("mount_pad", pl), h=h);
        }
      }
    }
  }
  module crown_cover() {
    translate(gear) {
      rotate([0, 90, 0]) {
        minkowski() {
          cylinder(r=crown_cover_r - crown_edge_r,
                   h=crown_cover_l - 2 * crown_edge_r, center=true);
          sphere(r=crown_edge_r);
        }
      }
    }
  }
  module blank() {
    if (part == "lower") {
      front_bulkhead_housing(color=plist_get("color", pl),
                             barrel_w=plist_get("barrel_w", pl),
                             barrel_thickness=base_h,
                             lower_pin_hole_d=plist_get("hinge_pin_d", pl),
                             center_y=true, center_by_hinges=false,
                             cut_hinge_holes=false,
                             cut_mount_holes=false,
                             quality_fn=plist_get("fn", pl),
                             join_overlap=e,
                             show_front_lower_arm=false,
                             show_front_lower_arm_pin=false,
                             show_front_lower_pin_e_clip=false,
                             show_front_lower_arm_ball_stud=false);

    } else {
      translate([0, 0, base_h]) {
        mirror([0, 1, 0]) {
          front_bulkhead(color=plist_get("color", pl),
                         shock_tower_color=plist_get("color", pl),
                         bulkhead_w=plist_get("body_w", pl),
                         bulkhead_l=plist_get("body_l", pl),
                         bulkhead_housing_h=base_h,
                         motor_shaft_bearing_d=0,
                         motor_shaft_axis_z=pinion_pos[2] - base_h,
                         cut_mount_holes=false,
                         cut_tower_holes=false,
                         quality_fn=plist_get("fn", pl),
                         join_overlap=e,
                         show_upper_suspension_holder=false,
                         show_shock_tower=false, show_suspension_arm_pad=false,
                         show_front_upper_arm=false, show_upper_arm_ball_stud=false,
                         show_front_upper_arm_pin=false,
                         show_front_upper_pin_e_clip=false);
        }
      }
      crown_cover();
      mounting_tabs(base_h, plist_get("mount_tab_h", pl));
      support_start = plist_get("body_l", pl) / 2;
      y_bore([pinion_pos[0], (support_start + neck_end) / 2, pinion_pos[2]],
             plist_get("bearing_d", pinion) + 2 * plist_get("input_support_wall", pl),
             neck_end - support_start);
    }
  }
  module cutters() {
    // The output casing and crown have independent swept envelopes.
    x_bore(gear, plist_get("gear_d", differential)
                   + 2 * plist_get("gear_clearance", pl),
           plist_get("gear_h", differential) + 2 * bearing_axial);
    case_l = plist_get("case_size", differential)[2];
    case_center = gear + [(plist_get("gear_h", differential) + case_l) / 2, 0, 0];
    x_bore(case_center, differential_case_swept_d(differential)
                        + 2 * plist_get("gear_clearance", pl),
           case_l + 2 * bearing_axial);
    x_bore(a, max(plist_get("support_d", differential),
                  plist_get("cup_d", differential))
               + plist_get("shaft_clearance", pl), size[0] + 2 * e);
    for (p = hsp_rear_differential_bearing_positions(differential)) {
      x_bore(a + p - hsp_rear_differential_axis(differential),
             plist_get("bearing_d", differential) + bearing_clearance,
             plist_get("bearing_h", differential) + 2 * bearing_axial);
    }
    y_bore([pinion_pos[0], neck_end / 2, pinion_pos[2]],
           plist_get("shaft_d", pinion) + plist_get("shaft_clearance", pl),
           neck_end + 2 * e);
    y_bore(pinion_pos + [0, plist_get("gear_h", pinion) / 2, 0],
           plist_get("gear_d", pinion) + 2 * plist_get("gear_clearance", pl),
           plist_get("gear_h", pinion) + 2 * plist_get("gear_clearance", pl));
    for (z = plist_get("bearing_centers_z", pinion)) {
      y_bore(pinion_pos + [0, z, 0], plist_get("bearing_d", pinion) + bearing_clearance,
             plist_get("bearing_h", pinion) + 2 * bearing_axial);
    }
    for (p = part == "lower" ? mounts : fastener_positions) {
      translate(p - [0, 0, e]) {
        cylinder(d=plist_get("mount_bolt_d", pl), h=size[2] + 2 * e);
      }
    }
    for (p = fastener_positions) {
      translate(p + [0, 0, plist_get("mount_nut_floor", pl)]) {
        cylinder(d=plist_get("mount_nut_af", pl) / cos(30),
                 h=plist_get("mount_nut_h", pl) + e, $fn=6);
      }
    }
    for (side = [-1, 1]) {
      hinge = rear_bulkhead_hinge_axis(pl, arm);
      y_bore([side * hinge[0], hinge[1], hinge[2]],
             plist_get("hinge_pin_d", pl), plist_get("barrel_l", pl) + 2 * e);
    }
    for (p = rear_shock_tower_mounts(tower)) {
      y_bore(tower_pos + [p[0], plist_get("tower_mount_thickness", pl) / 2, p[1]],
             plist_get("tower_bolt_d", pl),
             plist_get("tower_mount_thickness", pl) + 2 * e);
      translate(tower_pos + [p[0], -e, p[1]]) {
        rotate([-90, 0, 0]) {
          cylinder(d=plist_get("tower_insert_d", pl),
                   h=plist_get("tower_insert_l", pl) + e);
        }
      }
    }
    if (plist_get("base_step_h", pl) > 0) {
      gap = plist_get("base_step_clearance", pl);
      translate([-size[0] / 2 - e, plist_get("base_step_y", pl) - gap, -e]) {
        cube([size[0] + 2 * e, size[1], plist_get("base_step_h", pl) + gap + e]);
      }
    }
  }
  with_anchor(anchor, size, centered=true) {
    if (slot_mode) {
      cutters();
    } else {
      color(plist_get("color", pl)) {
        difference() {
          intersection() {
            blank();
            translate([-size[0] / 2, -size[1] / 2,
                       part == "lower" ? 0 : base_h]) {
              cube([size[0], size[1], part == "lower" ? base_h : size[2]]);
            }
          }
          cutters();
        }
      }
      if (show_hardware) {
        translate(a - hsp_rear_differential_axis(differential)) {
          hsp_rear_differential(differential, show_bearings=true);
        }
        translate(pinion_pos) {
          rotate([-90, 0, 0]) {
            hsp_rear_pinion(pinion, anchor=[0, 0, 1], show_bearings=true);
          }
        }
      }
    }
  }
}
