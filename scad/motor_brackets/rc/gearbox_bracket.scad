/**
  * Module: Gearbox bracket in the style of MN82/MN78 gearboxes
  *
  * This gearbox is quite complex and has asymetric shape.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../steering_params.scad>

use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/polygon_util.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../placeholders/motors/rc/brushed_motor.scad>
use <../../placeholders/motors/rc/gearbox.scad>
use <../../placeholders/motors/rc/gearmotor.scad>
use <../../placeholders/rpi_5.scad>

show_gearbox                  = true;
show_motor                    = true;
show_bearing                  = true;
show_drive_shaft              = true;
show_mount_bolts              = true;
show_nuts                     = true;
show_bracket                  = true;
show_shaft_seeve              = true;
show_extra_drive_shaft        = true;
show_min_parent_surface_width = false;
debug_circle_color            = matte_black;

bracket_thickness             = 6;

gearbox_bracket_bolt_d        = m3_hole_dia;
gearbox_bracket_bolt_cbore_d  = m3_hole_dia * 2 + 0.5;
gearbox_bracket_cbore_h       = 3;
gearbox_bracket_bolt_pad_x    = 3;
gearbox_bracket_bolt_pad_y    = 3;
gearbox_bracket_carrier_pad   = 2;
gearbox_bracket_ear_bolt_pad  = 3;
gearbox_bracket_corner_r      = 1;
gearbox_bracket_fillet_x_w    = 3;
gearbox_bracket_fillet_y_w    = 3;

function lerp(a, b, t) = a*(1-t) + b*t;

function lerp_pts(pts1, pts2, t) =
  [for (i=[0:len(pts1)-1])
      [lerp(pts1[i][0], pts2[i][0], t),
       lerp(pts1[i][1], pts2[i][1], t)]];

module loft_slices(pts1, pts2, h, steps=20, r=0) {
  for (i=[0:steps-1]) {
    t1 = i/steps;
    t2 = (i + 1)/steps;
    z1 = h*t1;
    z2 = h*t2;
    p1 = lerp_pts(pts1, pts2, t1);
    p2 = lerp_pts(pts1, pts2, t2);

    hull() {
      translate([0, 0, z1]) {
        linear_extrude(height=0.01) {
          offset_vertices_2d(r=r) {
            polygon(p1);
          }
        }
      }

      translate([0, 0, z2]) {
        linear_extrude(height=0.01) {
          offset_vertices_2d(r=r) {
            polygon(p2);
          }
        }
      }
    }
  }
}

module loft_polyhedron(pts1, pts2, h) {
  n = len(pts1);
  points = concat([for (p = pts1) [p[0], p[1], 0]],
                  [for (p = pts2) [p[0], p[1], h]]);

  faces = concat([[for (i=[0:n-1]) i]],                 // bottom
                 [[for (i=[0:n-1]) n + (n-1-i)]],       // top reversed
                 [for (i=[0:n-1])
                     let (j=(i + 1)%n)
                       [i, j, n + j, n + i]]);

  polyhedron(points=points, faces=faces, convexity=10);
}

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

  **Returns:**
  A plist shared by the renderer and its consumers. Coordinates are native,
  before anchoring: X=0 is the drive-shaft axis, Y=0 is the gearbox/motor
  reference plane, and the mounting surface is Z=0. The motor extends toward
  +Y; its output shaft extends toward -Y.
  - `bounds`, `size`: Conservative bracket reference box and XYZ dimensions,
    including the flared base and support towers, excluding hardware.
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
                                          fillet_y_w=gearbox_bracket_fillet_y_w) =
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
       motor_body_full_h = rc_motor_body_full_h(plist),
       carrier_w = motor_d,
       x_left = motor_outer_shaft_x_spacing + motor_d / 2,
       x_right_1 = mid_bolt_x_center + gearbox_shaft_boss_d / 2,

       front_ear_y_end = front_ear_bolt_y_center + mount_cbore_d / 2 + ear_bolt_pad,
       mid_mount_hole_center_y = front_ear_y_end + bolt_pad_y + bolt_r,
       front_ear_y_extra_bolt_end = mid_mount_hole_center_y + bolt_r + bolt_pad_y,

       rear_bolt_x_left = rear_bolt_pos_x_center - mount_cbore_d / 2,
       rear_bolt_x_left_with_pad = rear_bolt_x_left - ear_bolt_pad,

       x_straight_end = -bottom_straight_w - motor_pad,
       x_end = min(rear_bolt_x_left_with_pad, x_straight_end),

       bolt_mount_near_rear_gearbox_left_x = x_end - bolt_pad_x,
       bolt_mount_near_rear_gearbox_left_x_min = x_end - bolt_pad_x * 2 - bolt_r,
       rear_ear_bolt_y_end = rear_ear_bolt_y_center - mount_cbore_d / 2
       - ear_bolt_pad,

// holes near the motor contacts
       motor_cap_bolt_left = [-x_left, motor_body_full_h],
       motor_cap_bolt_right = [-x_left + motor_d, motor_body_full_h],

       motor_cap_bolt_left_y = motor_cap_bolt_left[1],
       motor_cap_bolt_right_y = motor_cap_bolt_right[1],

       motor_cap_bolt_left_x = motor_cap_bolt_left[0],
       motor_cap_bolt_right_x = motor_cap_bolt_right[0],
       motor_cap_bolt_right_x_max = motor_cap_bolt_right_x + bolt_r + bolt_pad_x,

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
                              [bolt_mount_near_rear_gearbox_left_x, rear_ear_bolt_y_center,
                               "Rear mount bolt", ["rotation", [0, 0, 70]]],
                              concat(motor_cap_bolt_left,
                                     ["Back motor bolt left", ["rotation", [0, 0, 90]]]),
                              concat(motor_cap_bolt_right,
                                     ["Back motor bolt right", ["rotation", [0, 0, 90]]])],

// holes for gearbox to bracket itself
       gearbox_mount_holes = [bracket_gearbox_bolt_left_center,
                              bracket_gearbox_bolt_right_center],
       all_holes = concat(bracket_mount_holes, gearbox_mount_holes),

       body_h_with_cup = body_h + contact_cup_h,

       motor_d_bolt_pad_x = motor_d + bolt_pad_x,

       x_right_bolt_x_end = x_right_1 - mount_ear_boss_d,

       bolt_chassis_x_right = -x_left + motor_d_bolt_pad_x,

       pts = [[x_right_1, 0],
              [x_right_1, mid_mount_hole_center_y],
              [x_right_1, front_ear_y_extra_bolt_end],
              [x_right_bolt_x_end, front_ear_y_extra_bolt_end],
              [bolt_chassis_x_right, body_h_with_cup],
              [bolt_chassis_x_right, motor_cap_bolt_right_y - bolt_r],
              [motor_cap_bolt_right_x_max, motor_cap_bolt_right_y - bolt_r],
              [motor_cap_bolt_right_x_max, motor_cap_bolt_right_y],
              [motor_cap_bolt_right_x_max, motor_cap_bolt_right_y
               + bolt_r + bolt_pad_y],
              [motor_cap_bolt_left_x - bolt_r - bolt_pad_x,
               motor_cap_bolt_left_y + bolt_r + bolt_pad_y],
              [motor_cap_bolt_left_x - bolt_r - bolt_pad_x, motor_cap_bolt_left_y],
              [-x_left, body_h_with_cup],
              [-x_left, 0],
              [x_end, 0],
              [bolt_mount_near_rear_gearbox_left_x_min, -gearbox_thickness],
              [bolt_mount_near_rear_gearbox_left_x_min,
               rear_ear_bolt_y_center - mount_cbore_d / 2],
              [x_end - bolt_pad_x - bolt_r, rear_ear_bolt_y_end, ["text",
                                                                  "Rear bolt Y end",
                                                                  "halign", "right",
                                                                  "offset_x", -10]],
              [rear_bolt_pos_x_center + ear_bolt_pad,
               rear_ear_bolt_y_end],

              [rear_bolt_pos_x_center + mount_cbore_d / 2 + ear_bolt_pad,
               rear_ear_bolt_y_center - mount_cbore_d / 2],
              [0, -gearbox_thickness]],

       pts_2 = [for (v = pts) let (x = v[0], y = v[1])
                                [x == 0 ? fillet_x_w : x > 0
                                 ? x + fillet_x_w : x - fillet_x_w,
                                 y == 0 ? 0 : y > 0
                                 ? y + fillet_y_w : y - fillet_y_w]],

       min_hole_x = polygon_min_x(all_holes),
       max_hole_x = polygon_max_x(all_holes),

       min_hole_y = polygon_min_y(all_holes),
       max_hole_y = polygon_max_y(all_holes),

       min_y = polygon_min_y(pts_2),
       max_y = polygon_max_y(pts_2),

       min_x = polygon_min_x(pts_2),
       max_x = polygon_max_x(pts_2),
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
       height = bracket_thickness
       + max(0.01, motor_shaft_y - motor_d * 0.2,
             front_mount_ear_y_min - 0.1, rear_mount_ear_y_min - 0.2),
       side_widths = [max(0, -min_x), max(0, max_x)],
       bounds = [[min_x, min_y, 0], [max_x, max_y, height]],
       surface_min_y = min(min_y, drive_end_y),
       surface_max_y = max(max_y, drive_end_y))
  ["motor", plist,
   "bolt_d", bolt_d,
   "bolt_pad_x", bolt_pad_x,
   "bolt_pad_y", bolt_pad_y,
   "ear_bolt_pad", ear_bolt_pad,
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

/**
  ─────────────────────────────────────────────────────────────────────────────
  gearmotor_bracket
  ─────────────────────────────────────────────────────────────────────────────

  Render the shaft-centered motor bracket, hardware, or parent mounting cutters.

  **Parameters:**
  - `plist`: Motor hardware plist; unnecessary when `params` is supplied.
  - `color`: Bracket color.
  - `bolt_pad_x`: Bracket mounting-hole padding along X.
  - `bolt_pad_y`: Bracket mounting-hole padding along Y.
  - `ear_bolt_pad`: Padding around gearbox mounting ears.
  - `bolt_d`: Bracket-to-chassis through-hole diameter.
  - `bracket_thickness`: Base thickness.
  - `corner_r`: Outline rounding radius.
  - `fillet_x_w`: Base flare along X.
  - `fillet_y_w`: Base flare along Y.
  - `show_gearbox`: Display gearbox hardware.
  - `show_motor`: Display motor hardware.
  - `show_bearing`: Display drive-shaft bearings.
  - `show_drive_shaft`: Display the gearbox's drive shaft.
  - `show_mount_bolts`: Display motor mounting bolts.
  - `show_bracket`: Display the printed bracket.
  - `show_nuts`: Display motor mounting nuts.
  - `chassis_thickness`: Additional cutter depth for the parent plate.
  - `show_shaft_seeve`: Display the shaft sleeve.
  - `show_extra_drive_shaft`: Display the sleeve's output shaft.
  - `anchor`: Legacy XY datum selector; `[0, 0, 1]` retains native coordinates.
    X=0 always retains the drive-shaft center, not the asymmetric box center.
    On X/Y, -1 selects the minimum and 1 the maximum reference coordinate.
    The mounting plane remains Z=0.
  - `anchor_mode`: `"holes_center"` selects hole-center extents; `"size"` selects
    bracket footprint extents for nonzero X/Y anchor components.
  - `debug_circle_color`: Vertex-label marker color.
  - `show_min_parent_surface_width`: Display the symmetric parent reference.
  - `slot_mode`: Emit parent mounting cutters instead of solids.
  - `debug`: Display outline and hole labels.
  - `params`: Result of `gearmotor_bracket_compute_params()`; overrides `plist`
    and sizing arguments so layout and geometry use the same specification.
 */
module gearmotor_bracket(plist,
                         color=white_off_1,
                         bolt_pad_x=gearbox_bracket_bolt_pad_x,
                         bolt_pad_y=gearbox_bracket_bolt_pad_y,
                         ear_bolt_pad=gearbox_bracket_ear_bolt_pad,
                         bolt_d=gearbox_bracket_bolt_d,
                         bracket_thickness=bracket_thickness,
                         corner_r=gearbox_bracket_corner_r,
                         fillet_x_w=gearbox_bracket_fillet_x_w,
                         fillet_y_w=gearbox_bracket_fillet_y_w,
                         show_gearbox=show_gearbox,
                         show_motor=show_motor,
                         show_bearing=show_bearing,
                         show_drive_shaft=show_drive_shaft,
                         show_mount_bolts=show_mount_bolts,
                         show_bracket=show_bracket,
                         show_nuts=show_nuts,
                         chassis_thickness=chassis_thickness,
                         show_shaft_seeve=show_shaft_seeve,
                         show_extra_drive_shaft=show_extra_drive_shaft,
                         anchor=[0, 1, 1],
                         anchor_mode="holes_center",  // holes_center | size
                         debug_circle_color=debug_circle_color,
                         show_min_parent_surface_width=show_min_parent_surface_width,
                         slot_mode=false,
                         debug=false,
                         params=undef) {
  resolved = is_undef(params)
    ? gearmotor_bracket_compute_params(plist,
                                       bolt_pad_x,
                                       bolt_pad_y,
                                       ear_bolt_pad,
                                       bolt_d,
                                       bracket_thickness,
                                       corner_r,
                                       fillet_x_w,
                                       fillet_y_w)
    : params;
  motor = plist_get("motor", resolved);
  resolved_bolt_d = plist_get("bolt_d", resolved);
  resolved_bracket_thickness = plist_get("bracket_thickness", resolved);
  resolved_corner_r = plist_get("corner_r", resolved);
  outer_shaft_y_center = plist_get("outer_shaft_y_center", resolved);
  mount_bolt_d = plist_get("mount_bolt_d", resolved);
  mount_cbore_d = plist_get("mount_cbore_d", resolved);
  rear_mount_ear_y_min = plist_get("rear_mount_ear_y_min", resolved);
  front_mount_ear_y_min = plist_get("front_mount_ear_y_min", resolved);
  motor_outer_shaft_x_spacing = plist_get("motor_outer_shaft_x_spacing",
                                          resolved);
  motor_d = plist_get("motor_d", resolved);
  motor_shaft_y = plist_get("motor_shaft_y", resolved);
  body_h = plist_get("body_h", resolved);
  carrier_w = plist_get("carrier_w", resolved);
  bracket_gearbox_bolt_right_center = plist_get("bracket_gearbox_bolt_right_center",
                                                resolved);
  bracket_gearbox_bolt_left_center = plist_get("bracket_gearbox_bolt_left_center",
                                               resolved);
  bracket_mount_holes = plist_get("bracket_mount_holes", resolved);
  gearbox_mount_holes = plist_get("gearbox_mount_holes", resolved);
  pts = plist_get("pts", resolved);
  pts_2 = plist_get("pts_2", resolved);
  min_hole_x = plist_get("min_hole_x", resolved);
  max_hole_x = plist_get("max_hole_x", resolved);
  min_hole_y = plist_get("min_hole_y", resolved);
  max_hole_y = plist_get("max_hole_y", resolved);
  min_x = plist_get("min_x", resolved);
  max_x = plist_get("max_x", resolved);
  min_y = plist_get("min_y", resolved);
  max_y = plist_get("max_y", resolved);

  anchor_x_modes = ["holes_center",
                    [-1, -min_hole_x,
                     1, -max_hole_x],
                    "size",
                    [-1, -min_x,
                     1, -max_x]];
  anchor_y_modes = ["holes_center",
                    [-1, -min_hole_y,
                     1, -max_hole_y],
                    "size",
                    [-1, -min_y,
                     1, -max_y]];

  total_l = abs(max_y) + abs(min_y);

  x_shift = plist_get(anchor[0], plist_get(anchor_mode, anchor_x_modes, []), 0);
  y_shift = plist_get(anchor[1], plist_get(anchor_mode, anchor_y_modes, []), 0);

  module _slot_holes(holes,
                     h,
                     d=resolved_bolt_d,
                     bore_d,
                     bore_h,
                     sink=false) {
    for (pair = holes) {
      let (x = pair[0],
           y = pair[1]) {
        translate([x, y, 0]) {
          counterbore(h=h,
                      d=d,
                      sink=sink,
                      bore_d=bore_d,
                      bore_h=bore_h,
                      fn=$preview ? 16 : 300,
                      reverse=true);
        }
      }
    }
  }

  module _slot(extra_thickness=0) {
    union() {
      gearmotor(plist=motor,
                slot_mode=true,
                parent_thickness=resolved_bracket_thickness + extra_thickness);
      _slot_holes(h=resolved_bracket_thickness + outer_shaft_y_center + extra_thickness,
                  holes=gearbox_mount_holes,
                  sink=true,
                  bore_d=mount_cbore_d,
                  bore_h=resolved_bracket_thickness,
                  d=mount_bolt_d);
      _slot_holes(holes=bracket_mount_holes,
                  h=resolved_bracket_thickness + outer_shaft_y_center + extra_thickness,
                  d=resolved_bolt_d);
    }
  }

  module _bracket() {
    difference() {
      maybe_color(color) {
        loft_slices(pts_2,
                    pts,
                    resolved_bracket_thickness,
                    steps=24,
                    r=resolved_corner_r);
        translate(concat(take(bracket_gearbox_bolt_right_center, 2),
                         [resolved_bracket_thickness])) {
          ring(d=mount_bolt_d,
               outer_d=mount_cbore_d,
               h=front_mount_ear_y_min - 0.1);
        }
        translate(concat(take(bracket_gearbox_bolt_left_center, 2),
                         [resolved_bracket_thickness])) {
          ring(d=mount_bolt_d,
               outer_d=mount_cbore_d,
               h=rear_mount_ear_y_min - 0.2);
        }
        translate([-motor_outer_shaft_x_spacing, 0, 0]) {
          difference() {
            cuboid(size=[carrier_w,
                         body_h,
                         resolved_bracket_thickness + motor_shaft_y],
                   anchor=[0, 1, 1]);

            translate([0, -0.5, resolved_bracket_thickness + motor_shaft_y]) {
              rotate([-90, 0, 0]) {
                cylinder(d=motor_d, h=body_h + 1, $fn=$preview ? 30 : 300);
              }
              translate([0, 0, -motor_d * 0.2]) {
                cuboid(size=[carrier_w + 1,
                             body_h + 1,
                             resolved_bracket_thickness + motor_shaft_y],
                       anchor=[0, 1, 1]);
              }
            }
          }
        }
      }

      gearmotor(plist=motor,
                slot_mode=true,
                parent_thickness=resolved_bracket_thickness);

      for (pair = bracket_mount_holes) {
        let (x = pair[0],
             y = pair[1]) {
          translate([x, y, 0]) {
            counterbore(h=resolved_bracket_thickness + outer_shaft_y_center,
                        d=resolved_bolt_d,
                        sink=false,
                        fn=$preview ? 16 : 300,
                        reverse=false);
          }
        }
      }
    }
  }

  translate([x_shift, y_shift, 0]) {
    if (slot_mode) {
      _slot(extra_thickness=chassis_thickness);
    } else {
      if (show_bracket) {
        _bracket();
      }

      if (show_min_parent_surface_width) {
        translate([-max(plist_get("side_widths", resolved)),
                   plist_get("parent_surface_y_bounds", resolved)[0],
                   0]) {
          color(cobalt_blue_metallic, alpha=1) {
            cuboid(size=concat(plist_get("min_parent_surface_size", resolved),
                               [1]),
                   anchor=[1, 1, 1]);
          }
        }
      }

      gearmotor(plist=motor,
                show_gearbox=show_gearbox,
                show_motor=show_motor,
                show_nuts=show_nuts,
                show_bearing=show_bearing,
                show_drive_shaft=show_drive_shaft,
                show_mount_bolts=show_mount_bolts,
                parent_thickness=resolved_bracket_thickness,
                show_shaft_seeve=show_shaft_seeve,
                show_extra_drive_shaft=show_extra_drive_shaft);
    }

    if (debug) {
      let (debug_circle_r=total_l * 0.01,
           debug_font_size=total_l * 0.03) {

        translate([0,
                   0,
                   slot_mode
                   ? chassis_thickness + resolved_bracket_thickness
                   : resolved_bracket_thickness]) {
          debug_polygon_text(points=pts,
                             offset_x=5,
                             circle_r=debug_circle_r,
                             circle_color=debug_circle_color,
                             font_size=debug_font_size,
                             offset_line_w=0.1);
          debug_polygon_text(points=bracket_mount_holes,
                             color=matte_black_2,
                             circle_r=0.1,
                             circle_color=debug_circle_color,
                             font_size=resolved_bolt_d * 0.5,
                             default_txt_plist=["halign", "left"]);
          translate([0, 0, outer_shaft_y_center]) {
            debug_polygon_text(points=gearbox_mount_holes,
                               color=cobalt_blue_dark_1,
                               circle_r=0.1,
                               circle_color=debug_circle_color,
                               font_size=resolved_bolt_d * 0.5);
          }
        }
      }
    }
  }
}

gearmotor_bracket(plist=motor_plist,
                  anchor_mode="size",
                  debug=false);