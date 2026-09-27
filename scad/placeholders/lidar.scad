/**
  * Module: Placeholder for generic Lidar
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../colors.scad>
include <../parameters.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../lib/shapes3d.scad>
use <../lib/slots.scad>
use <../lib/text.scad>
use <../lib/transforms.scad>
use <../lib/wire.scad>
use <standoff.scad>

show_lidar_mount_holes   = true;
show_standoffs           = true;

lidar_default_standoff_h = 13;

/**
  ─────────────────────────────────────────────────────────────────────────────
  lidar_size
  ─────────────────────────────────────────────────────────────────────────────

  Return the nominal lidar envelope, excluding unmodeled wiring.

  **Parameters:**
  - `plist`: Lidar property list; defaults to RPLIDAR C1.

  **Returns:** `[w, l, h]` in mm, with the body bottom at Z=0.
 */
function lidar_size(plist=rplidar_c1_plist) =
  concat(plist_get("size", plist),
         [plist_get("base_h", plist) + plist_get("top_h", plist)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  lidar_min_mount_z
  ─────────────────────────────────────────────────────────────────────────────

  Calculate a mounting height that clears both the optical band and payload.

  **Parameters:**
  - `obstacle_z`: Highest obstruction, including the head's intended swept envelope.
  - `clearance`: Vertical margin beneath the optical band.
  - `payload_z`: Highest component directly beneath the lidar.
  - `service_clearance`: Space between that component and the lidar bottom.
  - `plist`: Lidar property list; `base_h` is the optical band's lower edge.

  **Returns:** Minimum lidar bottom Z in the caller's chassis coordinates.
  Inputs are geometric envelopes, not just current component visibility states.
 */
function lidar_min_mount_z(obstacle_z,
                           clearance,
                           payload_z,
                           service_clearance,
                           plist=rplidar_c1_plist) =
  assert(clearance >= 0 && service_clearance >= 0)
  max(obstacle_z + clearance - plist_get("base_h", plist),
      payload_z + service_clearance);

/**
  ─────────────────────────────────────────────────────────────────────────────
  lidar_mount_slots
  ─────────────────────────────────────────────────────────────────────────────

  Emit the shared four-hole mounting pattern, without a head recess.

  **Parameters:**
  - `plist`: Lidar property list.
  - `h`: Cutter depth; defaults to the lidar's blind thread depth.
  - `d`: Hole diameter; defaults to nominal thread diameter, not plate clearance.
  - `anchor`: Anchor on the lidar footprint and cutter height, with Z=0..h by default.

  **Notes:** A mounting plate must supply its own clearance diameter and depth.
  The C1 permits at most 4 mm screw insertion beyond the plate into the sensor.
 */
module lidar_mount_slots(plist=rplidar_c1_plist, h, d, anchor=[0, 0, 1]) {
  depth = is_undef(h) ? plist_get("bolt_depth", plist) : h;
  dia = is_undef(d) ? plist_get("bolt_d", plist) : d;
  with_anchor(anchor, concat(plist_get("size", plist), [depth]), centered=true) {
    four_corner_children(size=plist_get("bolt_spacing", plist), center=true) {
      counterbore(h=depth, d=dia, no_bore=true, center=true, autoscale_step=0);
    }
  }
}

module lidar_standoffs(plist,
                       slot_mode=false,
                       sink=false,
                       h,
                       z_anchor=1,
                       own_holes_mode=false,
                       parent_thickness=6) {
  bolt_spacing = plist_get("bolt_spacing", plist);
  bolt_d = plist_get("bolt_d", plist);
  bore_h = plist_get("bore_h", plist);
  bore_d = plist_get("bore_d", plist);
  offsets_xy = plist_get("offsets", plist, [0, 0]);
  sink = plist_get("sink", plist, sink);
  depth = plist_get("bolt_depth", plist, h);

  if (own_holes_mode) {
    translate([with_default(offsets_xy[0], 0),
               with_default(offsets_xy[1], 0),
               0]) {
      four_corner_children(size=bolt_spacing, center=true) {
        counterbore(h=depth,
                    d=bolt_d,
                    no_bore=true,
                    autoscale_step=0);
      }
    }
  } else {
    four_corner_standoffs(h=h,
                          parent_thickness=parent_thickness,
                          cbore_d=bore_d,
                          offsets_xy=offsets_xy,
                          cbore_h=bore_h,
                          z_anchor=z_anchor,
                          slot_mode=slot_mode,
                          bolt_d=bolt_d,
                          thread_at_top=true,
                          sink=sink,
                          bolt_spacing=bolt_spacing);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  lidar
  ─────────────────────────────────────────────────────────────────────────────

  Build the generic lidar placeholder using the RPLIDAR C1 defaults.

  **Parameters:**
  - `plist`: Body, optical and underside mounting dimensions.
  - `anchor`: Anchor on the complete nominal body envelope.
  - `show_mount_holes`: Cut the blind underside threads as plain nominal holes.
  - `to`: Target orientation. One of:
         `"wlh"` (default) or `"lwh"`.
  - `rotate_z_180`: If `true`, rotate 180 degrees around the target Z axis
  through the reference box's X/Y center, after reorientation and before
  anchoring. Defaults to `false`; the reference size is unchanged.
 */
module lidar(plist=rplidar_c1_plist,
             anchor=[0, 0, 1],
             show_standoffs=true,
             show_mount_holes=show_lidar_mount_holes,
             parent_thickness=6,
             orientation="wlh",
             target_h=0,
             rotate_z_180=false,
             anchor_z_to_base_height=true,
             show_wire=true,
             sink=true,
             slot_mode=false) {
  corner_r = plist_get("corner_r", plist);

  base_h = plist_get("base_h", plist);
  top_h = plist_get("top_h", plist);

  top_round_d = plist_get("top_round_d", plist);

  bolt_depth = plist_get("bolt_depth", plist);

  ring_h = plist_get("lid_ring_h", plist, 0);
  ring_w = plist_get("lid_ring_w", plist, 0);

  total_h = base_h + top_h;
  size = lidar_size(plist);
  w = size[0];
  l = size[1];
  cube_size = concat(plist_get("size", plist), [base_h]);

  color = plist_get("color", plist, matte_black);

  texts = plist_get("texts", plist, []);

  front_texts = plist_get("front", texts);

  cable_exit = plist_get("cable_exit", plist);

  cable_side = plist_get("side", cable_exit, "rear");
  cable_side_offset = plist_get("side_offset", cable_exit, 0);
  cable_socket_z_offset= plist_get("z_offset", cable_exit, 0);

  cable_position = plist_get("position", cable_exit, "bottom");
  cable_color = plist_get("color", cable_exit, color);
  cable_d = plist_get("cable_d", cable_exit);
  cable_l = plist_get("cable_l", cable_exit);
  socket_d = plist_get("socket_d", cable_exit, cable_d);
  socket_l = plist_get("socket_l", cable_exit);

  bolt_d = plist_get("bolt_d", plist);

  standoffs_real_h = standoff_real_h(min_h=target_h, d=bolt_d);

  module _slot_or_standoffs(slot=false,
                            own_holes_mode=false,
                            z_anchor=1,
                            sink=sink,
                            parent_thickness=parent_thickness,
                            h=target_h) {
    lidar_standoffs(plist=plist,
                    slot_mode=slot,
                    sink=sink,
                    z_anchor=z_anchor,
                    own_holes_mode=own_holes_mode,
                    parent_thickness=parent_thickness,
                    h=h);
  }

  assert(bolt_depth > 0 && bolt_depth < base_h);

  translate([0, 0, show_standoffs ? standoffs_real_h : 0]) {
    with_orientation(anchor=anchor,
                     size=[w,
                           l,
                           anchor_z_to_base_height
                           ? base_h
                           : size[2]],
                     from="wlh",
                     rotate_z_180=rotate_z_180,
                     to=orientation) {
      if (slot_mode) {
        _slot_or_standoffs(slot=true);
      } else {
        union() {
          difference() {
            union() {
              maybe_color(color) {
                cuboid(size=cube_size, anchor=[0, 0, 1], r=corner_r);
                translate([0, 0, base_h]) {
                  cylinder(d=top_round_d, h=top_h, $fn=40);
                }
              }

              if (front_texts) {
                translate([0, -0.1 - l / 2, base_h / 2]) {
                  rotate([90, 0, 0]) {
                    text_rows(front_texts,
                              default_halign="center");
                  }
                }
              }
            }

            if (show_mount_holes) {
              _slot_or_standoffs(slot=false, own_holes_mode=true);
            }
            // Engrave the cosmetic top ring instead of creating a floating solid.
            if (ring_h > 0 && ring_w > 0) {
              translate([0, 0, total_h - ring_h]) {
                let (d = top_round_d / 2) {
                  ring(od=d, d=d - ring_w * 2, h=ring_h * 2, $fn=40);
                }
              }
            }
          }

          if (show_standoffs) {
            _slot_or_standoffs(slot=false, z_anchor=-1);
          }

          if (socket_d) {
            assert(in_list(cable_position, ["top", "center", "bottom"]),
                   "Invalid position");
            assert(in_list(cable_side, ["rear", "front", "left", "right"]),
                   "Invalid position");

            let (bend_exclusion_l = plist_get("bend_exclusion_l", cable_exit, 5),
                 socket_rotations = ["left", [0, -90, 0],
                                     "right", [0, 90, 0],
                                     "front", [90, 0, 0],
                                     "rear", [90, 0, 0]],
                 socket_translations = ["left", [-w / 2, 0, 0],
                                        "right", [w / 2, 0, 0],
                                        "front", [0, -l / 2, 0],
                                        "rear", [0, l / 2, 0]],
                 anchors = ["left", [1, 0, 1],
                            "right", [-1, 0, 1],
                            "front", [0, 1, 1],
                            "rear", [0, 1, -1]],
                 side_offsets = ["left", [0, cable_side_offset, 0],
                                 "right", [0, cable_side_offset, 0],
                                 "front", [cable_side_offset, 0, 0],
                                 "rear", [cable_side_offset, 0, 0],],
                 side_offst = plist_get(cable_side, side_offsets),
                 anchor = plist_get(cable_side, anchors),
                 socket_translation = plist_get(cable_side, socket_translations),
                 socket_rotation = plist_get(cable_side, socket_rotations),
                 z_position_offsets = ["top", [0, 0, base_h - socket_d
                                               + cable_socket_z_offset],
                                       "center", [0, 0, base_h / 2 - (socket_d / 2)
                                                  + cable_socket_z_offset],
                                       "bottom", [0, 0, cable_socket_z_offset]],
                 z_pos = plist_get(cable_position, z_position_offsets),
                 socket_r = socket_d / 2,
                 initial_cable_l = socket_l + bend_exclusion_l,

                 initial_pts_by_sides = ["left", [[-socket_l, 0, socket_r],
                                                  [-initial_cable_l, 0, socket_r]],
                                         "right", [[socket_l, 0, socket_r],
                                                   [initial_cable_l, 0, socket_r]],
                                         "front", [[0, -socket_l, socket_r],
                                                   [0, -initial_cable_l, socket_r]],
                                         "rear", [[0, socket_l, socket_r],
                                                  [0, initial_cable_l, socket_r]]],
                 pts_defaults = ["left", [[-initial_cable_l, 0, -cable_l * 0.3],
                                          [-cable_l * 0.2, 0, -cable_l * 0.3]],
                                 "right", [[-initial_cable_l, 0, -cable_l * 0.3],
                                           [cable_l * 0.2, 0, cable_l * 0.3]],
                                 "front", [[0, -initial_cable_l, -cable_l * 0.3],
                                           [0, -cable_l * 0.2, -cable_l * 0.3]],
                                 "rear", [[0, initial_cable_l, -cable_l * 0.3],
                                          [0, cable_l * 0.2, -cable_l * 0.5]]],

                 initial_pts = plist_get(cable_side, initial_pts_by_sides),
                 default_pts = plist_get(cable_side, pts_defaults),
                 wire_pts = concat(initial_pts,
                                   plist_get("points", cable_exit, default_pts))) {

              translate(side_offst) {
                translate(z_pos) {
                  maybe_color(cable_color) {
                    maybe_translate(socket_translation) {
                      if (show_wire) {
                        wire_path(points=wire_pts,
                                  d=cable_d,
                                  mode="centripetal",
                                  quality="medium",
                                  cut_len=0,
                                  put_joints=true,
                                  print_wire_len=true);
                      }

                      maybe_rotate(socket_rotation) {
                        cyl(d=socket_d, h=socket_l, anchor=anchor);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

lidar(anchor=[0, 0, 1],
      rotate_z_180=false,
      show_mount_holes=true,
      target_h=lidar_default_standoff_h,
      show_standoffs=true,
      anchor_z_to_base_height=false);
