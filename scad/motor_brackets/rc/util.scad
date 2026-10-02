/**
  * Shared functions for the gear motor bracket.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../rc_params.scad>

use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/polygon_util.scad>
use <../../placeholders/motors/rc/brushed_motor.scad>
use <../../placeholders/motors/rc/gearbox.scad>
use <gearmotor_encoder_bracket.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  gearmotor_bracket_compute_params
  ─────────────────────────────────────────────────────────────────────────────

  Resolve the bracket geometry and the parent mounting-surface requirements.

  **Parameters:**
  - `plist`: Complete motor hardware plist.
  - `bolt_pad_x`: Bracket mounting-hole padding along X.
  - `bolt_pad_y`: Bracket mounting-hole padding along Y.
  - `ear_bolt_pad`: Padding around gearbox mounting ears.
  - `bolt_d`: Bracket-to-chassis through-hole diameter.
  - `bracket_thickness`: Base thickness.
  - `corner_r`: Outline rounding radius.
  - `fillet_x_w`: Base flare along X.
  - `fillet_y_w`: Base flare along Y.
  - `encoder_plist`: Shaft encoder PCB specification; `undef` omits its mount.
  - `boss_wall_thickness`: Radial boss wall; zero disables both bosses.
  - `boss_pocket_clearance`: Diametral clearance of each removable boss socket.
  - `boss_pocket_depth`: Socket depth below the top of the base.
  - `boss_h_clearances`: Front/rear gaps below the gearbox ears.
  - `motor_carrier_clearance`: Added diameter of the motor cradle cutout and
    extra vertical relief below its open top.

  **Returns:**
  A plist shared by the renderer and its consumers. Coordinates are native,
  before anchoring: X=0 is the drive-shaft axis, Y=0 is the gearbox/motor
  reference plane, and the mounting surface is Z=0. The motor extends toward
  +Y; its output shaft extends toward -Y.
  - `bounds`, `size`: Conservative bracket reference box and XYZ dimensions,
    including the flared base, support towers and removable encoder mount,
    excluding hardware. `base_bounds` retains the original bracket envelope.
  - `encoder_mount`: Encoder mounting datums and printable-part parameters, or
    `undef`. Its footprint automatically contributes to the chassis layout.
  - `side_widths`: `[left, right]` reach from the drive-shaft axis.
  - `min_parent_surface_size`: Symmetric shaft-centered width and the length
    from the bracket through the drive connection. No chassis margin is added.
  - `drive_end_y`: Sleeve's outer end; without a sleeve, the start of the
    output shaft's end flat (`shaft_end - pad_l`), expressed in native Y.
  - `mount_hole_positions`, `gearbox_hole_positions`: Native XY hole centers.
  - `pts`, `pts_2`: Top and flared-base outline points.
  - Resolved sizing inputs and `motor` permit rendering with `params=...`.
 */
function gearmotor_bracket_compute_params(plist=motor_plist,
                                          bolt_pad_x=gearbox_bracket_bolt_pad_x,
                                          bolt_pad_y=gearbox_bracket_bolt_pad_y,
                                          ear_bolt_pad=gearbox_bracket_ear_bolt_pad,
                                          bolt_d=gearbox_bracket_bolt_d,
                                          bracket_thickness=bracket_thickness,
                                          corner_r=gearbox_bracket_corner_r,
                                          fillet_x_w=gearbox_bracket_fillet_x_w,
                                          fillet_y_w=gearbox_bracket_fillet_y_w,
                                          encoder_plist=motor_encoder_plist,
                                          boss_wall_thickness=gearbox_bracket_boss_thickness,
                                          boss_pocket_clearance=gearbox_bracket_boss_pocket_clearance,
                                          boss_pocket_depth=gearbox_bracket_boss_pocket_depth,
                                          boss_h_clearances=gearbox_bracket_boss_pocket_h_clearances,
                                          motor_carrier_clearance=gearbox_bracket_motor_carrier_clearance,
                                          bolt_dist_from_cap=gearbox_bracket_bolt_dist_from_cap,
                                          nut_pocket_clearance=gearbox_bracket_nut_pocket_clearance,
                                          bolt_dist_y_ear_bolt=gearbox_bracket_bolt_dist_y_ear_bolt) =
  assert(bolt_d > 0 && bracket_thickness > 0,
         "Bracket hole diameter and thickness must be positive")
  assert(min(bolt_pad_x, bolt_pad_y, ear_bolt_pad, corner_r,
             fillet_x_w, fillet_y_w) >= 0,
         "Bracket padding, rounding and flare must be nonnegative")
  let (bolt_r = bolt_d / 2,
       gearbox_params = gearbox_compute_params(plist),
       gearbox_thickness = plist_get("thickness", gearbox_params),
       bottom_straight_w = plist_get("bottom_straight_w", gearbox_params),
       motor_pad = plist_get("motor_pad", gearbox_params),
       motor_shaft_y = plist_get("motor_shaft_y", gearbox_params),
       motor_outer_shaft_x_spacing = plist_get("motor_outer_shaft_x_spacing",
                                               gearbox_params),
       motor_d = plist_get("motor_d", gearbox_params),
       outer_shaft_y_center = plist_get("outer_shaft_y_center", gearbox_params),
       gearbox_shaft_boss_d = plist_get("gearbox_shaft_boss_d", gearbox_params),
       mount_bolt_d = plist_get("mount_bolt_d", gearbox_params),
       mount_cbore_d = plist_get("mount_cbore_d", gearbox_params),
       mount_ear_boss_d = plist_get("mount_ear_boss_d", gearbox_params),
       rear_mount_ear_y_min = plist_get("rear_mount_ear_y_min", gearbox_params),
       front_mount_ear_y_min = plist_get("front_mount_ear_y_min", gearbox_params),

// Project the native gearbox hole axes through gearmotor's X rotation.
       mount_hole_positions = plist_get("mount_hole_positions", gearbox_params),
       rear_mount_hole = mount_hole_positions[0],
       front_mount_hole = mount_hole_positions[1],
       mid_bolt_x_center = front_mount_hole[0],
       rear_bolt_pos_x_center = rear_mount_hole[0],
       front_ear_bolt_y_center = -front_mount_hole[2],
       rear_ear_bolt_y_center = -rear_mount_hole[2],

       contact_cup = plist_get("contact_cup", plist),
       contact_cup_h = plist_get("h", contact_cup),
       motor_body = plist_get("body", plist),
       body_h = plist_get("h", motor_body),
       body_h_with_cup = body_h + contact_cup_h,
       motor_body_full_h = rc_motor_body_full_h(plist),
       carrier_w = motor_d - motor_carrier_clearance,
       x_left = motor_outer_shaft_x_spacing + motor_d / 2,
       x_right_1 = mid_bolt_x_center + gearbox_shaft_boss_d / 2,

       front_ear_y_end = front_ear_bolt_y_center + mount_cbore_d / 2 + ear_bolt_pad,
       mid_mount_hole_center_y = front_ear_y_end + bolt_dist_y_ear_bolt + bolt_r,
       front_ear_y_extra_bolt_end = mid_mount_hole_center_y + bolt_r,

// hole near the motor cap and contacts
       motor_cap_bolt_left_y = body_h_with_cup
       + bolt_r
       + bolt_dist_from_cap,
       motor_cap_bolt_left_x = -x_left + bolt_r + bolt_pad_x + nut_pocket_clearance,
       motor_cap_bolt_left = [motor_cap_bolt_left_x,
                              motor_cap_bolt_left_y],
       motor_cap_bolt_right = [-x_left + motor_d, motor_body_full_h],

       motor_cap_bolt_right_x = motor_cap_bolt_right[0],
       motor_cap_bolt_right_x_max = motor_cap_bolt_right_x + bolt_r + bolt_pad_x,
// hole near gearbox
       rear_bolt_x_left = rear_bolt_pos_x_center - mount_cbore_d / 2,
       rear_bolt_x_left_with_pad = rear_bolt_x_left - ear_bolt_pad,

       x_straight_end = -bottom_straight_w - motor_pad,
       x_end = min(rear_bolt_x_left_with_pad, x_straight_end),

       bolt_mount_near_rear_gearbox_left_x = min(motor_cap_bolt_left_x,
                                                 x_end - bolt_pad_x),
       rear_ear_bolt_y_end = rear_ear_bolt_y_center - mount_cbore_d / 2 - ear_bolt_pad,

       bracket_gearbox_bolt_right_center = [mid_bolt_x_center,
                                            front_ear_bolt_y_center,
                                            ["text", "Front gearbox bolt",
                                             "halign", "left"]],
       bracket_gearbox_bolt_left_center = [rear_bolt_pos_x_center,
                                           rear_ear_bolt_y_center,
                                           ["text", "Rear gearbox bolt",
                                            "halign", "left",
                                            "size", 1.4]],

// holes for mounting on chassis
       bracket_mount_holes = [[mid_bolt_x_center, mid_mount_hole_center_y,
                               "Mid mount hole"],
                              [bolt_mount_near_rear_gearbox_left_x,
                               rear_ear_bolt_y_center,
                               "Rear mount bolt", ["rotation", [0, 0, 50]]],
                              concat(motor_cap_bolt_left, ["Back motor bolt left",
                                                           ["rotation", [0, 0, 40]]])],
// holes for gearbox to bracket itself
       gearbox_mount_holes = [bracket_gearbox_bolt_left_center,
                              bracket_gearbox_bolt_right_center],
       all_holes = concat(bracket_mount_holes, gearbox_mount_holes),

       x_right_bolt_x_end = x_right_1 - mount_ear_boss_d,
       cap_bolt_y_end = motor_cap_bolt_left_y + bolt_r + bolt_pad_y,

       pts = [[x_right_1, 0],
              [x_right_1, front_ear_y_extra_bolt_end - bolt_r],
              [x_right_1 - bolt_r, front_ear_y_extra_bolt_end],
              [x_right_bolt_x_end, front_ear_y_extra_bolt_end + bolt_r],
              [max(x_right_bolt_x_end, motor_cap_bolt_right_x_max), cap_bolt_y_end],
              [motor_cap_bolt_left_x, cap_bolt_y_end],
              [-x_left, cap_bolt_y_end - bolt_r - nut_pocket_clearance],
              [-x_left, rear_ear_bolt_y_end],
              [rear_bolt_pos_x_center + mount_cbore_d / 2 + ear_bolt_pad, rear_ear_bolt_y_end]],

       pts_2 = [for (v = pts) let (x = v[0], y = v[1])
                                [x == 0
                                 ? fillet_x_w
                                 : x > 0
                                 ? x + fillet_x_w
                                 : x - fillet_x_w,
                                 y == 0
                                 ? 0
                                 : y > 0
                                 ? y + fillet_y_w
                                 : y - fillet_y_w]],

       min_hole_x = polygon_min_x(all_holes),
       max_hole_x = polygon_max_x(all_holes),

       min_hole_y = polygon_min_y(all_holes),
       max_hole_y = polygon_max_y(all_holes),

       base_min_y = polygon_min_y(pts_2),
       base_max_y = polygon_max_y(pts_2),

       base_min_x = polygon_min_x(pts_2),
       base_max_x = polygon_max_x(pts_2),
       drive_seeve = plist_get("drive_seeve", plist, []),
       has_sleeve = plist_get("od", drive_seeve, 0) > 0
       && plist_get("h", drive_seeve, 0) > 0,
       shaft_start = -plist_get("outer_shaft_l", gearbox_params)
       + gearbox_thickness
       + plist_get("outer_shaft_rear_len", gearbox_params),
       drive_end_y = -(has_sleeve
                       ? gearbox_thickness
                       + plist_get("bearing_boss_h", gearbox_params)
                       + with_default(plist_get("drive_seeve_dist", gearbox_params), 0)
                       + plist_get("drive_seeve_h", gearbox_params)
                       : shaft_start + plist_get("outer_shaft_l", gearbox_params)
                       - plist_get("outer_shaft_pad_l", gearbox_params)),
       front_boss_h = front_mount_ear_y_min - plist_get("front", boss_h_clearances, 0.1),
       rear_boss_h = rear_mount_ear_y_min - plist_get("rear", boss_h_clearances, 0.2),
       base_height = bracket_thickness
       + max(0.01, motor_shaft_y - motor_d * 0.2 - motor_carrier_clearance,
             boss_wall_thickness > 0 ? front_boss_h : 0,
             boss_wall_thickness > 0 ? rear_boss_h : 0),
       encoder_mount = gearmotor_encoder_params(motor=plist,
                                                base_h=bracket_thickness,
                                                encoder_plist=encoder_plist,
                                                chassis_holes=[for (p = bracket_mount_holes)
                                                    [p[0], p[1]]],
                                                chassis_bolt_d=bolt_d),
       encoder_bounds = is_undef(encoder_mount)
       ? [[base_min_x, base_min_y, 0], [base_max_x, base_max_y, base_height]]
       : plist_get("bounds", encoder_mount),
       min_x = min(base_min_x, encoder_bounds[0][0]),
       max_x = max(base_max_x, encoder_bounds[1][0]),
       min_y = min(base_min_y, encoder_bounds[0][1]),
       max_y = max(base_max_y, encoder_bounds[1][1]),
       height = max(base_height, encoder_bounds[1][2]),
       side_widths = [max(0, -min_x), max(0, max_x)],
       bounds = [[min_x, min_y, 0], [max_x, max_y, height]],
       surface_min_y = min(min_y, drive_end_y),
       surface_max_y = max(max_y, drive_end_y),
       boss_od = mount_bolt_d + (boss_wall_thickness * 2),
       boss_pocket_od = boss_pocket_clearance + boss_od)
       assert(min(boss_wall_thickness, boss_pocket_clearance, motor_carrier_clearance) >= 0,
              "Boss walls and fit clearances must be nonnegative")
       assert(boss_pocket_depth > 0 && boss_pocket_depth < bracket_thickness
              && min(front_boss_h, rear_boss_h) > 0,
              "Boss pockets must leave a base floor and bosses must reach the gearbox")
       ["motor", plist,
        "boss_pocket_depth", boss_pocket_depth,
        "boss_heights", ["front", front_boss_h + boss_pocket_depth,
                         "rear", rear_boss_h + boss_pocket_depth],
        "motor_carrier_clearance", motor_carrier_clearance,
        "encoder_mount", encoder_mount,
        "base_bounds", [[base_min_x, base_min_y, 0], [base_max_x, base_max_y, base_height]],
        "bolt_d", bolt_d,
        "bolt_pad_x", bolt_pad_x,
        "bolt_pad_y", bolt_pad_y,
        "ear_bolt_pad", ear_bolt_pad,
        "boss_od", boss_od,
        "boss_pocket_od", boss_pocket_od,
        "bracket_thickness", bracket_thickness,
        "corner_r", corner_r,
        "fillet_x_w", fillet_x_w,
        "fillet_y_w", fillet_y_w,
        "gearbox_params", gearbox_params,
        "motor_shaft_y", motor_shaft_y,
        "motor_outer_shaft_x_spacing", motor_outer_shaft_x_spacing,
        "motor_d", motor_d,
        "outer_shaft_y_center", outer_shaft_y_center,
        "mount_bolt_d", mount_bolt_d,
        "mount_cbore_d", mount_cbore_d,
        "rear_mount_ear_y_min", rear_mount_ear_y_min,
        "front_mount_ear_y_min", front_mount_ear_y_min,
        "body_h", body_h,
        "carrier_w", carrier_w,
        "bracket_gearbox_bolt_right_center", bracket_gearbox_bolt_right_center,
        "bracket_gearbox_bolt_left_center", bracket_gearbox_bolt_left_center,
        "bracket_mount_holes", bracket_mount_holes,
        "gearbox_mount_holes", gearbox_mount_holes,
        "pts", pts,
        "pts_2", pts_2,
        "min_hole_x", min_hole_x,
        "max_hole_x", max_hole_x,
        "min_hole_y", min_hole_y,
        "max_hole_y", max_hole_y,
        "min_x", min_x,
        "max_x", max_x,
        "min_y", min_y,
        "max_y", max_y,
        "drive_end_y", drive_end_y,
        "side_widths", side_widths,
        "bounds", bounds,
        "size", bounds[1] - bounds[0],
        "mount_hole_positions", [for (p = bracket_mount_holes) [p[0], p[1]]],
        "gearbox_hole_positions", [for (p = gearbox_mount_holes) [p[0], p[1]]],
        "min_parent_surface_size", [2 * max(side_widths),
                                    surface_max_y - surface_min_y],
        "parent_surface_y_bounds", [surface_min_y, surface_max_y]];
