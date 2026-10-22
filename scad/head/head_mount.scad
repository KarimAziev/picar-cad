/**
 * Module: Robot head for two Raspberry Pi Camera Module 3 units.

 * This module defines the robot head component designed to support two
 * Raspberry Pi Camera Module 3 units.
 *
 * The front plate, two recessed side panels, and upper bridge bolt together.
 * A gusseted IR enclosure mounts above the bridge. The tilt horn bears on
 * the recessed side panel's seating floor.
 *
 * Author: Karim Aziiev <karim.aziiev@gmail.com>
 * License: GPL-3.0-or-later
 */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/placement.scad>
use <../lib/plist.scad>
use <../lib/shapes2d.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/transforms.scad>
use <../placeholders/bolt.scad>
use <../placeholders/camera.scad>
use <../placeholders/servo_horn.scad>
use <ir_case.scad>
use <servo_horn_recess.scad>

show_frame_bolts        = false;
show_frame_nuts         = false;
show_camera             = false;
show_camera_bolts       = false;
show_camera_nuts        = false;
show_ir_case            = false;
show_ir_case_bolts      = false;
show_ir_case_nuts       = false;
show_ir_led             = false;
show_ir_case_rail       = false;
show_ir_case_rail_bolts = false;
show_ir_case_rail_nuts  = false;

show_servo_horn         = false;
show_servo_horn_screws  = false;
show_servo_horn_bolt    = false;
servo_horn_single       = false;
servo_horn_screw_side   = "horizontal";  // [vertical, horizontal]

echo_bolts_info         = true;

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_tilt_horn_angle
  ─────────────────────────────────────────────────────────────────────────────
  Return the horn rotation in the side panel's XY plane, in degrees.
 */
function head_tilt_horn_angle() =
  atan2(head_side_panel_bottom - head_side_panel_curve_end,
        head_side_panel_curve_start - head_side_panel_depth);

side_panel_points       = [[0, -head_side_panel_top],
                           [head_side_panel_curve_start, -
                            head_side_panel_notch_y],
                           [head_side_panel_depth, -head_side_panel_notch_y],
                           [head_side_panel_depth, -head_side_panel_bottom],
                           [head_side_panel_curve_start,
                            -head_side_panel_curve_end],
                           [0, -head_side_panel_curve_end]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_tilt_axis_position
  ─────────────────────────────────────────────────────────────────────────────
  Return the horn center [depth, height] in printable side-panel coordinates.
 */
function head_tilt_axis_position() =
  [head_side_panel_depth / 2,
   head_side_panel_curve_end - head_side_panel_height / 2];

function head_camera_y(i) =
  (i == 0 ? 0 : sum([for (j = [0 : i - 1]) head_cameras[j][0][1]]))
  + i * head_camera_gap;

/**
  ─────────────────────────────────────────────────────────────────────────────
  Head frame dimensions and placements
  ─────────────────────────────────────────────────────────────────────────────
  Sizes are [width, length, height] for each printable part. Joint points are
  [depth, height] in side-panel coordinates. head_bridge_underside_y is
  the roof underside
  in the frame before head_mount's outer rotation. In that frame depth behind
  the camera face is negative Z. head_ir_position uses head_mount coordinates,
  where rearward depth is positive Z.
 */
function head_bridge_underside_y() = head_front_height / 2 + head_bridge_rise;
function head_bridge_size() =
  [head_front_width + 2 * head_side_panel_thickness,
   head_bridge_depth, head_bridge_thickness + head_bridge_flange_height];
function head_side_panel_size() =
  [head_side_panel_depth, head_front_height / 2 + head_bridge_underside_y(),
   head_side_panel_thickness];
function head_front_joint_points() =
  [for (v=[head_front_bolt_edge, head_front_height - head_front_bolt_edge])
    [head_front_bolt_depth, v]];
function head_bridge_joint_points() =
  [for (u=[head_bridge_bolt_edge, head_bridge_depth - head_bridge_bolt_edge])
    [u, head_side_panel_size()[1] - head_bridge_bolt_drop]];
function head_mount_printable_size(gap=6) =
  [max(head_front_width + gap + head_bridge_size()[0],
       2 * head_side_panel_size()[0] + gap),
   max(head_front_height, head_bridge_size()[1]) + gap + head_side_panel_size()[1],
   max(head_front_flange_depth,
       head_bridge_size()[2],
       head_side_panel_size()[2])];
function head_ir_position() =
  let (foot=ir_case_mount_foot_size())
  [-foot[0] / 2,
   head_bridge_underside_y() + head_bridge_thickness + foot[2],
   head_ir_setback];

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_bridge_corner_setback
  ─────────────────────────────────────────────────────────────────────────────
  Locate the side panel's front corner at its top edge.
  **Returns:**
  Setback behind the camera face where the slope meets the roof underside.
 */
function head_bridge_corner_setback() =
  let (rise=head_side_panel_top - head_side_panel_notch_y,
       y=head_side_panel_size()[1],
       start=head_side_panel_curve_end - head_side_panel_top)
  assert(rise > 0, "The side panel's upper edge must rise toward the rear")
  max(0, head_side_panel_curve_start * (y - start) / rise);

module head_frame_hardware(joint="both", show_nuts=false) {
  grip = head_side_panel_thickness + head_mount_flange_thickness
         + head_joint_clearance;
  assert(in_list(joint, ["front", "bridge", "both"]),
         "Unknown head frame joint");
  points = joint == "front"
           ? head_front_joint_points()
           : joint == "bridge"
             ? head_bridge_joint_points()
             : concat(head_front_joint_points(), head_bridge_joint_points());
  mirror_copy([1, 0, 0]) {
    for (p=points) {
      translate([head_front_width / 2 + head_side_panel_thickness
                 - head_frame_bolt_l,
                 p[1] - head_front_height / 2,
                 -p[0]]) {
        rotate([0, 90, 0]) {
          bolt(d=head_frame_bolt_d,
               h=head_frame_bolt_l,
               show_nut=show_nuts,
               nut_head_distance=grip);
        }
      }
    }
  }
}

module head_front_camera(spec,
                         i,
                         slot_mode=true,
                         do_place_camera=false,
                         echo_bolts_info=echo_bolts_info,
                         show_bolts=true,
                         show_nuts=true,
                         corner_side) {
  slot_size = spec[0];
  bolt_hole_y = spec[1];
  bolt_spacing = spec[2];
  final_y = head_camera_y(i);

  hole_r = slot_size[0] / 2;

  hole_y_pos = bolt_spacing[1] / 2 + head_camera_bolt_d / 2
               + bolt_hole_y;

  translate([-hole_r, final_y, 0]) {
    if (slot_mode) {
      rounded_rect(slot_size,
                   r=head_camera_slot_corner_r,
                   center=false,
                   side=corner_side);

      translate([hole_r,
                 hole_y_pos,
                 0]) {
        four_corner_holes_2d(size = bolt_spacing,
                             center = true,
                             d = head_camera_bolt_d,
                             fn = 360);
      }
    }

    if (do_place_camera) {
      board_color = is_undef(spec[3]) ? green_2 : spec[3];
      translate([slot_size[0] / 2,
                 bolt_spacing[1] / 2 + head_camera_bolt_d / 2
                 + bolt_hole_y
                 + camera_h / 2
                 - camera_holes_size[1] / 2
                 - camera_bolt_hole_dia / 2
                 - camera_holes_distance_from_top,
                 0]) {
        rotate([0, 0, 180]) {
          camera_module(board_color=board_color);
        }
      }
    }

    let (nut_spec = find_nut_spec(inner_d=head_camera_bolt_d,
                                  lock=false),
         nut_h = plist_get("height", nut_spec, 2),
         bolt_h = ceil(camera_thickness + head_front_thickness + nut_h),
         bolt_d = snap_bolt_d(head_camera_bolt_d)) {
      if (echo_bolts_info) {
        echo(str("Camera bolt: M", bolt_d, "x", bolt_h, "mm"));
      }
      if (show_bolts) {
        translate([hole_r,
                   hole_y_pos,
                   head_front_thickness + camera_thickness - bolt_h]) {
          four_corner_children(size = bolt_spacing,
                               center = true) {
            bolt(h=bolt_h,
                 show_nut=show_nuts,
                 nut_head_distance=head_front_thickness
                                   + camera_thickness,
                 d=head_camera_bolt_d);
          }
        }
      }
    }
  }
}

module _head_camera_plate() {
  cameras_len = len(head_cameras);
  single_shift = cameras_len > 1 ? 0 : head_camera_gap / 2;
  translate([0, 0, -head_front_thickness]) {
    linear_extrude(height=head_front_thickness) {
      difference() {
        translate([-head_front_width / 2, 0]) {
          rounded_rect([head_front_width, head_front_height],
                       center=false,
                       side="top",
                       r=head_face_corner_r);
        }
        translate([0, single_shift]) {
          for (i=[0:cameras_len - 1]) {
            head_front_camera(spec=head_cameras[i],
                              i=i,
                              show_bolts=false,
                              show_nuts=false,
                              slot_mode=true,
                              do_place_camera=false,
                              corner_side=i == 0 ? "top" : undef);
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_front_plate
  ─────────────────────────────────────────────────────────────────────────────
  Camera plate with rearward side-panel mounting flanges.
  **Parameters:**
  - `show_camera`, `show_nuts`, `show_bolts`: Camera hardware visibility.
  - `head_color`: Printed part color.
  - `slot_mode`: Emit the flange mounting holes only.
  - `anchor`: Anchor on the complete part; [0,1,-1] locates its front face.
  - `show_frame_bolts`, `show_frame_nuts`: Side-panel joint hardware.
  **Behavior:**
  At the default anchor, X is centered, Y spans 0..head_front_height, and the
  front face is Z=0.
  The flanges extend toward negative Z. Use head_front_printable for printing.
 */
module head_front_plate(show_camera=false,
                        head_color="white",
                        show_nuts=false,
                        show_bolts=false,
                        slot_mode=false,
                        anchor=[0, 1, -1],
                        show_frame_bolts=false,
                        show_frame_nuts=false) {
  assert(head_front_flange_depth > head_front_bolt_depth + head_frame_bolt_d);
  assert(head_front_bolt_edge > head_bridge_flange_height
         - head_bridge_rise + head_joint_clearance + head_frame_bolt_d);
  module slots() {
    for (p=head_front_joint_points()) {
      translate([-head_front_width / 2 - 1,
                 head_front_height - p[1],
                 -p[0]]) {
        rotate([0, 90, 0]) {
          rotate([0, 0, 90]) {
            counterbore(d=head_frame_bolt_d,
                        h=head_front_width + 2,
                        teardrop_angle=45,
                        teardrop_both_sides=true);
          }
        }
      }
    }
  }

  size = [head_front_width, head_front_height, head_front_flange_depth];

  with_anchor(size=size, anchor=anchor) {
    translate([size[0] / 2, 0, size[2]]) {
      if (slot_mode) {
        slots();
      } else {
        color(head_color) {
          difference() {
            union() {
              _head_camera_plate();
              mirror_copy([1, 0, 0]) {
                translate([head_front_width / 2 - head_joint_clearance
                           - head_mount_flange_thickness,
                           head_bridge_flange_height - head_bridge_rise
                           + head_joint_clearance,
                           -head_front_flange_depth]) {

                  cuboid([head_mount_flange_thickness,
                          head_front_height - head_bridge_flange_height
                          + head_bridge_rise - head_joint_clearance,
                          head_front_flange_depth - head_front_thickness + 0.1],
                         anchor=[1, 1, 1],
                         side="top",
                         r=head_joint_corner_r);
                }
              }
            }
            slots();
          }
        }
        // Camera placeholders share the camera plate's placement.
        if (show_camera || show_bolts || show_nuts) {
          cameras_len = len(head_cameras);
          single_shift = cameras_len > 1 ? 0 : head_camera_gap / 2;
          translate([0,
                     single_shift,
                     -head_front_thickness - camera_thickness]) {
            for (i=[0:cameras_len - 1]) {
              head_front_camera(spec=head_cameras[i],
                                i=i,
                                slot_mode=false,
                                do_place_camera=show_camera,
                                show_bolts=show_bolts,
                                show_nuts=show_nuts);
            }
          }
        }
        if (show_frame_bolts) {
          translate([0, head_front_height / 2, 0]) {
            rotate([0, 0, 180]) {
              head_frame_hardware(joint="front", show_nuts=show_frame_nuts);
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_bridge_ir_mount
  ─────────────────────────────────────────────────────────────────────────────
  Return the IR mounting interface in printable bridge coordinates.
  **Returns:**
  Property list with `origin` [X, Y] at the minimum corner of the hole grid,
  `bolt_spacing`, `bolt_d`, and `rear_y` at the rear edge of the foot.
 */
function head_bridge_ir_mount() =
  let (mount=ir_case_mount_interface(),
       foot=plist_get("size", mount),
       spacing=plist_get("bolt_spacing", mount),
       origin=plist_get("bolt_origin", mount),
       size=head_bridge_size())
  ["origin", [(size[0] - foot[0]) / 2 + origin[0],
              size[1] - head_ir_setback - origin[1] - spacing[1]],
   "bolt_spacing", spacing,
   "bolt_d", plist_get("bolt_d", mount),
   "rear_y", size[1] - head_ir_setback - foot[1]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_bridge_slot_layout
  ─────────────────────────────────────────────────────────────────────────────
  Fit rounded slots between the bridge flanges and behind the IR foot.
  **Returns:**
  Property list with `size` [X length, Y width], `count`, and `limit_y`.
  Slot centers start at Y=0, exposing half of the first slot at the rear edge.
  A count of zero means the available depth cannot hold the first half-slot.
 */
function head_bridge_slot_layout() =
  let (size=head_bridge_size(),
       flange_x=head_side_panel_thickness + head_joint_clearance,
       width=head_bridge_slot_width,
       gap=head_bridge_slot_gap,
       length=size[0] - 2 * (flange_x + head_mount_flange_thickness
                             + head_bridge_slot_side_pad),
       limit=plist_get("rear_y", head_bridge_ir_mount())
             - head_bridge_slot_mount_pad,
       count=max(0, floor((limit - width / 2) / (width + gap)) + 1))
  assert(width > 0 && gap > 0 && length >= width,
         "Bridge slots require positive width, webs, and sufficient span")
  assert(head_bridge_slot_side_pad >= 0 && head_bridge_slot_mount_pad >= 0,
         "Bridge slot pads must be nonnegative")
  ["size", [length, width],
   "count", count,
   "limit_y", limit];

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_bridge
  ─────────────────────────────────────────────────────────────────────────────
  Printable upper bridge with side flanges and IR-foot mounting holes.
  **Parameters:**
  - `anchor`: Anchor on head_bridge_size(); default [1,1,1].
  - `slot_mode`: Emit joint holes, IR mounting holes, and rear slots.
  - `show_bolts`, `show_nuts`: Side-panel joint hardware.
  - `color`: Printed part color.
  **Behavior:**
  The roof lies on Z=0 with the flanges extending upward.
  Its front outline tapers from the side-panel corner to each flange's front end.
  The roof covers the full mounting-flange footprints.
  The rectangular front lip spans the width between the mounting flanges.
  Rear slots end before the IR foot, with a half-slot centered on Y=0.
 */
module head_bridge(anchor=[1, 1, 1],
                   slot_mode=false,
                   show_bolts=false,
                   show_nuts=false,
                   color="white") {
  size = head_bridge_size();
  flange_x = head_side_panel_thickness + head_joint_clearance;
  front_lip = head_front_thickness + head_joint_clearance;
  corner_depth = head_bridge_corner_setback();

  assert(head_bridge_flange_height > head_bridge_bolt_drop + head_frame_bolt_d / 2);
  assert(head_bridge_depth > 2 * head_bridge_bolt_edge + head_frame_bolt_d);
  assert(head_ir_setback >= 0
         && head_ir_setback + ir_case_mount_foot_size()[1] <= size[1],
         "IR foot must fit on the roof");
  assert(ir_case_width + head_joint_clearance * 2
         <= head_front_width - 2 * head_mount_flange_thickness,
         "IR foot hardware must clear the roof flanges");
  assert(corner_depth >= front_lip
         && corner_depth < min(size[1], head_side_panel_curve_start),
         "The roof corners must meet the side panel's upper-front slope");

  w = size[0];
  l = size[1];

  ir_mount = head_bridge_ir_mount();
  slot_layout = head_bridge_slot_layout();

  module roof_outline() {
    intersection() {
      rounded_rect([w, l],
                   side="bottom",
                   fn=36,
                   r=head_bridge_corner_r);
      polygon([[0, 0],
               [w, 0],
               [w, l - corner_depth],
               [w - flange_x, l - front_lip],
               [w - flange_x, l],
               [flange_x, l],
               [flange_x, l - front_lip],
               [0, l - corner_depth]]);
    }
  }

  module slots() {
    slot_size = plist_get("size", slot_layout);
    extra_cutout_n = plist_get("count", slot_layout);

    for (p=head_bridge_joint_points()) {
      translate([-1, l - p[0], head_bridge_thickness + head_bridge_bolt_drop]) {
        rotate([0, 90, 0]) {
          rotate([0, 0, 90]) {
            counterbore(d=head_frame_bolt_d,
                        h=w + 2,
                        teardrop_angle=45,
                        teardrop_both_sides=true);
          }
        }
      }
    }
    origin = plist_get("origin", ir_mount);
    translate([origin[0], origin[1], -0.1]) {
      four_corner_children(size=plist_get("bolt_spacing", ir_mount),
                           center=false) {
        cylinder(d=plist_get("bolt_d", ir_mount),
                 h=head_bridge_thickness + 0.2,
                 $fn=40);
      }
    }

    if (extra_cutout_n > 0) {
      translate([w / 2, -slot_size[1] / 2, -0.1]) {
        rows_children(rows=extra_cutout_n,
                      w=slot_size[1],
                      gap=head_bridge_slot_gap,
                      anchor=1) {
          cuboid(size=[slot_size[0], slot_size[1], head_bridge_thickness + 0.2],
                 anchor=[0, 0, 1],
                 r=head_cutout_corner_r);
        }
      }
    }
  }

  with_anchor(size=size, anchor=anchor) {
    if (slot_mode) {
      slots();
    } else {
      difference() {
        union() {
          color(color) {
            linear_extrude(height=head_bridge_thickness) {
              roof_outline();
            }
          }
          for (x=[flange_x, w - flange_x - head_mount_flange_thickness]) {
            color(color) {
              translate([0, 0, head_bridge_thickness - 0.1]) {
                linear_extrude(height=head_bridge_flange_height + 0.1) {
                  intersection() {
                    roof_outline();
                    translate([x, 0]) {
                      rounded_rect([head_mount_flange_thickness,
                                    l - front_lip],
                                   side="bottom",
                                   fn=36,
                                   r=head_joint_corner_r);
                    }
                  }
                }
              }
            }
          }
        }
        slots();
      }
      if (show_bolts) {
        rotate([-90, 0, 0]) {
          translate([w / 2,
                     -head_bridge_underside_y() - head_bridge_thickness,
                     l]) {
            head_frame_hardware(joint="bridge", show_nuts=show_nuts);
          }
        }
      }
    }
  }
}

module head_bridge_assembled(slot_mode=false) {
  size = head_bridge_size();
  translate([-size[0] / 2,
             head_bridge_underside_y() + head_bridge_thickness,
             -size[1]]) {
    rotate([90, 0, 0]) {
      head_bridge(slot_mode=slot_mode);
    }
  }
}

module head_side_panel_cutouts() {
  edge = (head_side_panel_depth - head_side_slot_span) / 2;
  start = max(edge, head_front_flange_depth + 3);
  for (slot_y=head_side_slot_y) {
    if (head_side_panel_depth - edge > start) {
      translate([start, slot_y]) {
        rounded_rect([head_side_panel_depth - edge - start,
                      head_side_slot_width],
                     r=head_cutout_corner_r,
                     fn=48);
      }
    }
  }
  hole_points = concat([for (off=head_side_aux_row_offsets,
                             x=head_side_aux_hole_depths)
    [x, (off >= 0 ? head_side_slot_y[1]
         : head_side_slot_y[0]) + off]],
                       [for (x=[0.50, 0.66, 0.85])
                         [head_side_panel_depth * x,
                          head_side_aux_pitch * 5]]);
  for (p=hole_points) {
    clearances = [for (joint=concat(head_front_joint_points(),
                                    head_bridge_joint_points()))
      norm(p + [0, head_side_panel_curve_end] - joint)];
    if (min(clearances) > 5 + head_side_aux_hole_d / 2) {
      translate(p) {
        circle(d=head_side_aux_hole_d, $fn=40);
      }
    }
  }
}

module at_head_tilt_axis() {
  translate(head_tilt_axis_position()) {
    children();
  }
}

module head_tilt_horn(show_servo_horn_screws=show_servo_horn_screws,
                      show_servo_horn_bolt=show_servo_horn_bolt,
                      servo_horn_single=servo_horn_single,
                      servo_horn_screw_side=servo_horn_screw_side) {
  translate([0, 0, head_horn_seat_thickness]) {

    at_head_tilt_axis() {
      rotate([0, 0, head_tilt_horn_angle()]) {
        translate([0,
                   0,
                   -servo_horn_arm_z_offset]) {
          servo_horn(center=true,
                     show_screws=show_servo_horn_screws,
                     single=servo_horn_single,
                     show_bolt=false,
                     screw_side=servo_horn_screw_side);
        }

        if (show_servo_horn_bolt) {
          head_z = servo_horn_ring_height - servo_horn_arm_z_offset;
          bolt_l = ceil(head_horn_seat_thickness + head_z);
          translate([0, 0, head_z - bolt_l]) {
            bolt(d=servo_horn_center_hole_dia,
                 head_type="pan",
                 bolt_color=matte_black,
                 h=bolt_l);
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_tilt_horn_holes
  ─────────────────────────────────────────────────────────────────────────────
  Cut the hub opening and clearance holes matching the tilt horn's cross arm.
  Coordinates use the printable side panel's positive X/Y frame.
  The fixed recess bounds the mounting holes independently of panel height.
 */
module head_tilt_horn_holes() {
  offsets = servo_horn_hole_offsets();
  recess = head_servo_horn_recess_size();
  assert(len(offsets) > 0, "The tilt horn requires mounting holes");
  assert(max(offsets) + head_servo_horn_screw_dia / 2 < recess[0] / 2,
         "The tilt horn screw pattern must fit the fixed horn recess");
  at_head_tilt_axis() {
    circle(d=head_servo_mount_dia, $fn=100);
    rotate([0, 0, head_tilt_horn_angle() + 90]) {
      with_servo_horn_holes() {
        circle(d=head_servo_horn_screw_dia, $fn=40);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_side_panel_outline
  ─────────────────────────────────────────────────────────────────────────────
  Return the solid side-panel perimeter in printable depth/height coordinates.
  Cutouts and fastener holes are excluded from this outer profile.
 */
function head_side_panel_outline() =
  let (points=[for (p=side_panel_points) p + [0, head_side_panel_curve_end]],
       size=head_side_panel_size())
  _head_side_clip(_head_side_clip(
    _head_side_clip(_head_side_clip(points, 0, 0, true), 0, size[0], false),
    1, 0, true), 1, size[1], false);

function _head_side_clip(points, axis, boundary, above) =
  [for (i=[0:len(points) - 1])
    let (a=points[i], b=points[(i + 1) % len(points)],
         inside_a=above ? a[axis] >= boundary : a[axis] <= boundary,
         inside_b=above ? b[axis] >= boundary : b[axis] <= boundary)
    each concat(inside_a ? [a] : [],
                inside_a != inside_b
                ? [a + (b - a) * ((boundary - a[axis]) / (b[axis] - a[axis]))]
                : [])];

module head_side_panel_profile() {
  difference() {
    polygon(head_side_panel_outline());
    translate([0, head_side_panel_curve_end]) {
      head_side_panel_cutouts();
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_side_panel
  ─────────────────────────────────────────────────────────────────────────────
  Flat printable side panel with an outward-facing horn recess.
  **Parameters:**
  - `anchor`: Anchor on head_side_panel_size(); default [1,1,1].
  - `slot_mode`: Emit frame holes and, when enabled, the horn interface.
  - `with_horn_mount`: Include the hub hole, horn screw holes, and recess.
  - `show_servo_horn`, `show_servo_horn_screws`, `show_servo_horn_bolt`:
    Toggle hardware in solid mode when with_horn_mount is true.
  - `servo_horn_single`, `servo_horn_screw_side`: Horn placeholder options.
  - `color`: Printed panel color.
  **Behavior:**
  X is head depth, Y is height, Z is outward thickness. The horn seat remains
  head_horn_seat_thickness above the inside face. The driven panel uses
  with_horn_mount=true; the opposite cover panel uses false.
 */
module head_side_panel(anchor=[1, 1, 1],
                       slot_mode=false,
                       with_horn_mount=false,
                       show_servo_horn=false,
                       show_servo_horn_screws=false,
                       show_servo_horn_bolt=false,
                       servo_horn_single=false,
                       servo_horn_screw_side="horizontal",
                       color="white") {
  size = head_side_panel_size();
  assert(head_side_panel_thickness >= head_horn_seat_thickness);
  assert(head_horn_seat_thickness > 0 && head_horn_seat_thickness <= 2,
         "The tilt horn requires at most 2 mm of material beneath its seat");
  module slots() {
    for (p=concat(head_front_joint_points(), head_bridge_joint_points())) {
      translate([p[0], p[1], -0.1]) {
        cylinder(d=head_frame_bolt_d, h=size[2] + 0.2, $fn=40);
      }
    }
    if (with_horn_mount) {
      translate([0, 0, -0.1]) {
        linear_extrude(height=size[2] + 0.2) {
          head_tilt_horn_holes();
        }
      }
      if (head_side_panel_thickness > head_horn_seat_thickness) {

        translate([0, 0, head_horn_seat_thickness]) {
          at_head_tilt_axis() {
            rotate([0, 0, head_tilt_horn_angle()]) {
              linear_extrude(height=size[2] - head_horn_seat_thickness + 0.1) {
                head_servo_horn_recess_2d();
              }
            }
          }
        }
      }
    }
  }
  with_anchor(size=size, anchor=anchor) {
    if (slot_mode) {
      slots();
    } else {
      color(color) {
        difference() {
          linear_extrude(height=size[2], convexity=2) {
            head_side_panel_profile();
          }
          slots();
        }
      }
      if (with_horn_mount && show_servo_horn) {
        head_tilt_horn(show_servo_horn_screws=show_servo_horn_screws,
                       show_servo_horn_bolt=show_servo_horn_bolt,
                       servo_horn_single=servo_horn_single,
                       servo_horn_screw_side=servo_horn_screw_side);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_side_panel_assembled
  ─────────────────────────────────────────────────────────────────────────────
  Place a side panel in the head frame before its outer Y rotation.
  **Parameters:**
  - `is_left`: Left cover if true; right horn-mount panel if false.
  - `show_servo_horn`, `show_servo_horn_screws`, `show_servo_horn_bolt`:
    Hardware visibility on the horn-mount panel.
  - `servo_horn_single`, `servo_horn_screw_side`: Horn placeholder options.
  - `color`: Printed panel color.
 */
module head_side_panel_assembled(is_left=true,
                                 show_servo_horn=false,
                                 show_servo_horn_screws=false,
                                 show_servo_horn_bolt=false,
                                 servo_horn_single=false,
                                 servo_horn_screw_side="horizontal",
                                 color="white") {
  side = is_left ? -1 : 1;
  translate([side * head_front_width / 2, -head_front_height / 2, 0]) {
    scale([side, 1, 1]) {
      rotate([0, 90, 0]) {
        head_side_panel(with_horn_mount=!is_left,
                        show_servo_horn=show_servo_horn,
                        show_servo_horn_screws=show_servo_horn_screws,
                        show_servo_horn_bolt=show_servo_horn_bolt,
                        servo_horn_single=servo_horn_single,
                        servo_horn_screw_side=servo_horn_screw_side,
                        color=color);
      }
    }
  }
}

module head_ir_case(ir_case_color=jet_black,
                    ir_rail_color=cobalt_blue_metallic,
                    show_ir_led=show_ir_led,
                    show_ir_case_rail=show_ir_case_rail,
                    show_ir_case_bolts=show_ir_case_bolts,
                    show_ir_case_nuts=show_ir_case_nuts,
                    show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                    show_ir_case_rail_nuts=show_ir_case_rail_nuts,
                    echo_bolts_info=echo_bolts_info) {
  translate(head_ir_position()) {
    ir_case_assembly(mount="top",
                     show_rail=show_ir_case_rail,
                     case_color=ir_case_color,
                     rail_color=ir_rail_color,
                     show_ir_led=show_ir_led,
                     show_ir_case_nuts=show_ir_case_nuts,
                     show_ir_case_bolts=show_ir_case_bolts,
                     show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                     show_ir_case_rail_nuts=show_ir_case_rail_nuts,
                     mount_thickness=head_bridge_thickness,
                     echo_bolts_info=echo_bolts_info);
  }
}
module head_mount(head_color="white",
                  show_frame_bolts=show_frame_bolts,
                  show_frame_nuts=show_frame_nuts,
                  show_front=true,
                  show_bridge=true,
                  show_sides=true,
                  ir_case_color="white",
                  ir_rail_color="white",
                  show_camera=show_camera,
                  show_ir_case=show_ir_case,
                  show_ir_led=show_ir_led,
                  show_ir_case_rail=show_ir_case_rail,
                  show_ir_case_bolts=show_ir_case_bolts,
                  show_ir_case_nuts=show_ir_case_nuts,
                  show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                  show_ir_case_rail_nuts=show_ir_case_rail_nuts,
                  show_camera_nuts=show_camera_nuts,
                  show_camera_bolts=show_camera_bolts,
                  show_servo_horn=show_servo_horn,
                  show_servo_horn_screws=show_servo_horn_screws,
                  show_servo_horn_bolt=show_servo_horn_bolt,
                  servo_horn_single=servo_horn_single,
                  servo_horn_screw_side=servo_horn_screw_side) {

  module _head_ir_case() {
    head_ir_case(ir_rail_color=ir_rail_color,
                 ir_case_color=ir_case_color,
                 show_ir_led=show_ir_led,
                 show_ir_case_rail=show_ir_case_rail,
                 show_ir_case_bolts=show_ir_case_bolts,
                 show_ir_case_nuts=show_ir_case_nuts,
                 show_ir_case_rail_bolts=show_ir_case_rail_bolts,
                 show_ir_case_rail_nuts=show_ir_case_rail_nuts);
  }
  rotate([0, 180, 0]) {

    union() {
      if (show_front) {
        translate([0, head_front_height / 2, 0]) {
          rotate([0, 0, 180]) {
            head_front_plate(show_camera=show_camera,
                             head_color=head_color,
                             show_nuts=show_camera_nuts,
                             show_bolts=show_camera_bolts);
          }
        }
      }
      color(head_color, alpha=1) {
        if (show_bridge) {
          head_bridge_assembled();
        }
        if (show_sides) {
          head_side_panel_assembled(is_left=true, color=head_color);
        }
      }
      if (show_sides) {
        head_side_panel_assembled(is_left=false,
                                  show_servo_horn=show_servo_horn,
                                  show_servo_horn_screws=show_servo_horn_screws,
                                  show_servo_horn_bolt=show_servo_horn_bolt,
                                  servo_horn_single=servo_horn_single,
                                  servo_horn_screw_side=servo_horn_screw_side,
                                  color=head_color);
      }
    }
    if (show_frame_bolts) {
      head_frame_hardware(show_nuts=show_frame_nuts);
    }
  }

  if (show_ir_case || show_ir_case_rail || show_ir_led) {
    _head_ir_case();
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_front_printable
  ─────────────────────────────────────────────────────────────────────────────
  Front plate with its outward face on Z=0 and rear flanges pointing upward.
  **Parameters:**
  - `anchor`: Anchor on [head_front_width, head_front_height, flange depth].
  - `slot_mode`: Emit the flange holes in printable coordinates.
 */
module head_front_printable(anchor=[1, 1, 1], slot_mode=false) {
  size = [head_front_width, head_front_height, head_front_flange_depth];
  with_anchor(size=size, anchor=anchor) {
    translate([head_front_width / 2, 0, 0]) {
      mirror([0, 0, 1]) {
        head_front_plate(slot_mode=slot_mode);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  head_mount_printable
  ─────────────────────────────────────────────────────────────────────────────
  Lay out the front plate, top bridge, and two side panels on Z=0.
 */
module head_mount_printable() {
  gap = 6;
  head_front_printable();
  translate([head_front_width + gap, 0, 0]) {
    head_bridge();
  }
  for (i=[0, 1]) {
    let (with_horn_mount = i == 1,
         rotation = with_horn_mount ? 0 : 180,
         size = head_side_panel_size(),
         w = size[0]) {
      translate([i * (w + gap) + (with_horn_mount ? 0 : w),
                 max(head_front_height, head_bridge_size()[1]) + gap,
                 0]) {
        rotate([rotation, 0, rotation]) {
          head_side_panel(with_horn_mount=with_horn_mount);
        }
      }
    }
  }
}

// head_mount(show_ir_case=true);

head_mount_printable();
