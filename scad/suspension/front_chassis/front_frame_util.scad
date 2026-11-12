/**
  * Module: Separate head and bulkhead sections of the front chassis.
  *
  * The removable head carries the pan-axis and bumper mounts.
  * The bulkhead and bellcrank section carries the matching head socket and
  * the rear joint for the steering-servo frame.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../colors.scad>
include <../../parameters.scad>
include <../../rc_params.scad>
include <layout_params.scad>

use <../../head/head_neck.scad>
use <../../lib/debug.scad>
use <../../lib/functions.scad>
use <../../lib/plist.scad>
use <../../lib/polygon_util.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../placeholders/bolt.scad>
use <../bellcrank/bellcrank_slots.scad>
use <../bulkhead/front_bulkhead_chassis.scad>
use <../bulkhead/util.scad>
use <../front_bumper/common.scad>
use <front_chassis_access_slots.scad>
use <front_chassis_joint.scad>
use <front_chassis_mount_recesses.scad>
use <head_frame/head_slots.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_front_frame_start_y
  ─────────────────────────────────────────────────────────────────────────────

  Locate the nose from the front ribbon passage and bumper mounting lands.

  **Parameters:**
  - `extension`: Forward length beyond the ribbon-passage mounting lands, or
    `"auto"` for `front_chassis_bumper_min_extension()`.
    Defaults to `front_chassis_bumper_extension`; zero is the base datum.

  **Returns:** Front-frame maximum Y. Bumper mounting lands include the forward
  clearance `front_chassis_bumper_extension` beyond the ribbon-passage padding.
  The head mount and chassis joints retain their vehicle datums.
 */
function front_chassis_front_frame_start_y(extension=front_chassis_bumper_extension) =
  assert(extension == "auto" || (is_num(extension) && extension >= 0),
         "Bumper extension must be auto or a non-negative length")
  front_chassis_head_center_y() + front_chassis_head_front_ribbon_y()
  + front_chassis_head_pan_servo_top_ribbon_cutout_h / 2 + front_chassis_head_wire_land
  + front_bumper_center_bolt_y_offset
  + front_bumper_bolt_d + front_bumper_bolt_pad_y * 2
  + (extension == "auto" ? _front_chassis_bumper_auto_extension : extension);

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_bumper_min_extension
  ─────────────────────────────────────────────────────────────────────────────
  Size the bumper mounting lands for the head's mechanically reachable travel.

  **Parameters:**
  - `pl`: Bumper dimension overrides, merged with `front_bumper_plist`.
  - `clearance`: Nonnegative gap in millimeters, radially and at both Z faces.
  - `tilt_range`: `"auto"` for upward travel through the camera-plate/neck stop,
    or requested numeric limits clipped at that stop.

  **Returns:** Minimum nonnegative extension for the head's component envelopes
  and the bumper's rounded rear profiles over a full pan turn. The foam,
  retainer and hardware are checked at their respective height intervals.

  **Behavior:** The head envelopes include the side-panel outline, separate
  camera components and fasteners. Cutouts, circular tessellation and bounding
  boxes around small hardware make the result conservative relative to meshes.
  Preview poses and visibility toggles do not affect the calculation.
 */
function front_chassis_bumper_min_extension(pl=front_bumper_plist,
                                            clearance=front_chassis_bumper_head_clearance,
                                            tilt_range=front_chassis_bumper_tilt_range) =
  assert(is_num(clearance) && clearance >= 0,
         "Bumper head clearance must be a non-negative length")
  assert(tilt_range == "auto" || (is_list(tilt_range) && len(tilt_range) == 2
                                  && is_num(tilt_range[0]) && is_num(tilt_range[1])
                                  && tilt_range[0] <= tilt_range[1]),
         "Bumper tilt range must be auto or ordered numeric limits")
  let (p=front_bumper_params(pl),
       travel=tilt_range == "auto"
              ? [-90, head_neck_lower_tilt_stop()]
              : [max(-90, tilt_range[0]),
                 min(head_neck_lower_tilt_stop(), tilt_range[1])],
       foam_h=plist_get("foam_h", p),
       top=front_bumper_size(p)[2],
       z=front_chassis_head_pan_servo_slot_recess,
       foam_reach=head_neck_swept_front_reach([z - clearance, z + foam_h + clearance], [-180, 180], travel),
       plate_reach=head_neck_swept_front_reach([z + foam_h - clearance, z + top + clearance], [-180, 180], travel),
       foam=front_bumper_foam_profile(p),
       foam_w=front_bumper_size(p, "foam")[0],
       plate_w=front_bumper_size(p, "plate")[0],
       foam_path=[for (v=concat(foam[0], [foam[0][0]])) v - [foam_w / 2, 0]],
       plate_path=[for (v=front_bumper_plate_rear_path(p)) v - [plate_w / 2, 0]],
       mounts=[for (v=front_bumper_mount_positions(p, "plate"))
         [v[0] - plate_w / 2, v[1]]],
       post_r=plist_get("post_d", p) / 2,
       hardware=front_bumper_bolt_params(p),
       head_type=front_bumper_use_countersunk ? "countersunk" : "socket",
       head_h=find_bolt_head_h(front_bumper_bolt_d, head_type),
       head_z=plist_get("head_z", hardware),
       nut_z=plist_get("nut_z", hardware),
       tip_z=plist_get("tip_z", hardware),
       bottom=min(0, tip_z, nut_z,
                  head_z - (front_bumper_reverse_bolts ? head_h : 0)),
       hardware_top=max(top, tip_z,
                        nut_z + find_nut_prop("height", front_bumper_bolt_d),
                        head_z + (front_bumper_reverse_bolts ? 0 : head_h)),
       hardware_r=max(find_bolt_head_prop("dia", front_bumper_bolt_d, head_type),
                      find_nut_prop("outer_dia", front_bumper_bolt_d) / cos(30)) / 2,
       hardware_reach=head_neck_swept_front_reach([z + bottom - clearance, z + hardware_top + clearance], [-180, 180], travel),
       required_y=max(concat([front_bumper_profile_front_y(foam_path, foam_reach + clearance + foam[1]),
                              front_bumper_profile_front_y(plate_path,
                                                           plate_reach + clearance + plist_get("rib_w", p) / 2)],
                             [for (v=mounts)
                               max(front_bumper_profile_front_y([v], plate_reach + clearance + post_r + 2),
                                   front_bumper_profile_front_y([v], foam_reach + clearance + post_r),
                                   front_bumper_profile_front_y([v], hardware_reach + clearance + hardware_r))])),
       rear_y=front_chassis_front_frame_start_y(extension=0)
              - front_chassis_head_center_y()
              - front_bumper_bolt_d / 2 - front_bumper_bolt_pad_y
              - front_bumper_center_bolt_y_offset
              - front_bumper_mount_positions(p)[0][1])
  max(0, required_y - rear_y);

// Shared by the frame outline and all three mounting datums.
_front_chassis_bumper_auto_extension = front_chassis_bumper_min_extension();

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_bumper_mount_positions
  ─────────────────────────────────────────────────────────────────────────────
  Locate the three vertical bumper fasteners in the front-frame coordinates.
  **Returns:** `[left, center, right]` XYZ centers at the chassis top face.
 */
function front_chassis_bumper_mount_positions() =
  let (y = front_chassis_front_frame_start_y()
           - front_bumper_bolt_d / 2 - front_bumper_bolt_pad_y)
  [[-front_bumper_bolt_spacing_x / 2,
    y - front_bumper_center_bolt_y_offset, chassis_thickness],
   [0, y, chassis_thickness],
   [front_bumper_bolt_spacing_x / 2,
    y - front_bumper_center_bolt_y_offset, chassis_thickness]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_center_y
  ─────────────────────────────────────────────────────────────────────────────

  Return the pan-axis center of the head mounting pad.

  **Returns:**
  - Head center on the front-frame Y axis.
 */
function front_chassis_head_center_y() =
  front_bulkhead_pad_distance_to_hinge() + bulkhead_size_y
  + front_chassis_head_rear_reach();

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_head_mount_z
  ─────────────────────────────────────────────────────────────────────────────

  Return the head-neck assembly height at the top of the horn recess.

  **Returns:**
  - Head-neck placement coordinate on Z.
 */
function front_chassis_head_mount_z() =
  chassis_thickness - front_chassis_head_pan_servo_slot_recess;

function front_chassis_ear_pts() =
  let (ear_y = front_chassis_ear_w / 2,
       l = front_chassis_ear_l,
       pts = [[0, ear_y + front_chassis_ear_extra_w],
              [l * 0.4, ear_y],
              [l * 0.75, ear_y * 0.85],
              [l * 0.9, ear_y * 0.6],
              [l * 0.97, ear_y * 0.3],
              [l, 0],
              [0, 0]],
       mirrored_pts = [for (p = reverse(pts))
         [p[0], -p[1]]])
  concat(pts, mirrored_pts);

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_front_frame_bounds
  ─────────────────────────────────────────────────────────────────────────────
  Return a bounding box for the head, suspension outline and compact tongue.
  **Returns:** `[minimum_xyz, maximum_xyz]` in assembled chassis coordinates.
  The box includes the head mounting margins and bulkhead ears.
 */
function front_chassis_front_frame_bounds() =
  let (half_w = max(front_frame_x_end,
                    bulkhead_size_x / 2 + front_chassis_ear_l,
                    front_bumper_bolt_spacing_x / 2
                    + front_bumper_bolt_d / 2 + front_bumper_bolt_pad_x,
                    front_chassis_head_mount_size()[0] / 2
                    + front_chassis_head_side_slot_w + front_chassis_head_wire_land * 2))
  [[-half_w, y_front_chassis_rear_frame_joint_1_start - joint_l, 0],
   [half_w, front_chassis_front_frame_start_y(), chassis_thickness]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_front_frame_points
  ─────────────────────────────────────────────────────────────────────────────
  Locate the right half of the front-frame outline in vehicle coordinates.
  **Parameters:**
  - `rear_joint`: End at the rear joint; false overlaps the adjoining plate.
  **Returns:** Ordered XY polygon vertices, including the centerline edge.
  Vertex 4 is the bulkhead ear root.
 */
function front_chassis_front_frame_points(rear_joint=split_front_chassis) =
  let (start_y0 = front_chassis_front_frame_start_y(),
       head_mount_size = front_chassis_head_mount_size(),
       head_center_y = front_chassis_head_center_y(),
       bumper_x = front_bumper_bolt_spacing_x / 2
                  + front_bumper_bolt_d / 2 + front_bumper_bolt_pad_x,
       x1 = max(bumper_x,
                head_mount_size[0] / 2
                + front_chassis_head_side_slot_w + front_chassis_head_wire_land * 2),
       start_y1 = start_y0 - front_bumper_center_bolt_y_offset,
       x2 = bulkhead_size_x / 2,
       y2 = front_bulkhead_pad_distance_to_hinge()
            + bulkhead_transition_len + front_bumper_bolt_y_offset
            + front_bumper_bolt_d,
       head_rear_y = head_center_y - front_chassis_head_rear_reach()
                     + bulkhead_transition_len,
       y3 = bulkhead_transition_len
            + front_chassis_bellcrank_tool_access_hole_d / 2
            - front_lower_arm_lower_hinge_barrel_h,
       x_end = front_frame_x_end,
       y_end = y_front_chassis_rear_frame_joint_1_start
               - (rear_joint ? 0 : front_chassis_joint_boolean_overlap))
  [[0, start_y0],
   [bumper_x, start_y1],
   [x1, head_center_y + head_mount_size[1] / 2],
   [x1, head_rear_y],
   [x2, y2],
   [bumper_x, y3],
   [x_end, y3 - bellcrank_mount_r],
   [x_end, y_end],
   [0, y_end]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_front_frame_labels
  ─────────────────────────────────────────────────────────────────────────────
  Label both halves of the front-frame outline above the plate.
  **Parameters:**
  - `font`: Outline label font.
  - `color`: Outline label color.
  - `rear_joint`: Select the joint or overlapping rear boundary.
 */
module front_chassis_front_frame_labels(font="Gill Sans:style=Bold",
                                        color=green_2,
                                        rear_joint=split_front_chassis) {
  pts = front_chassis_front_frame_points(rear_joint);
  module _debug(rotation) {
    let (x_size = polygon_x_len(pts) * 2,
         font_size = constraint(x_size * 0.04, 1, 5)) {
      debug_polygon_text(pts,
                         rotation=rotation,
                         font_size=font_size,
                         font=font,
                         offset_x=font_size,
                         offset_x_exclude=[0, len(pts) - 1],
                         color=color);
    }
  }

  translate([0, 0, chassis_thickness + 0.1]) {
    _debug();
    mirror([1, 0, 0]) {
      _debug(rotation=[0, 180, 0]);
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_front_frame_blank
  ─────────────────────────────────────────────────────────────────────────────
  Build the unperforated head and suspension plate in vehicle coordinates.
  **Parameters:**
  - `debug`: Display outline labels.
  - `debug_font`: Outline label font.
  - `debug_color`: Outline label color.
  - `color`: Plate color; undef inherits the caller's color.
  - `rear_joint`: End the plate at the steering joint; false overlaps the adjoining plate.
 */
module front_chassis_front_frame_blank(debug=false,
                                       debug_font="Gill Sans:style=Bold",
                                       debug_color=green_2,
                                       color=white_smoke_1,
                                       rear_joint=split_front_chassis) {

  pts = front_chassis_front_frame_points(rear_joint);

  maybe_color(color) {
    linear_extrude(height=chassis_thickness,
                   center=false,
                   convexity=2) {
      mirror_copy([1, 0, 0]) {
        polygon(pts);
        // The chassis ears
        translate(concat(pts[4], [0])) {
          polygon(front_chassis_ear_pts());
        }
      }
    }
  }
  if (debug) {
    front_chassis_front_frame_labels(font=debug_font,
                                     color=debug_color,
                                     rear_joint=rear_joint);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_front_frame_head_slots
  ─────────────────────────────────────────────────────────────────────────────
  Cut bumper fasteners, the head mount and cable passages in vehicle coordinates.
  **Parameters:**
  - `show_access_slots`: Include the head-side and front cable passages.
 */
module front_chassis_front_frame_head_slots(show_access_slots=true) {
  head_center_y = front_chassis_head_center_y();
  for (pos = front_chassis_bumper_mount_positions()) {
    translate([pos[0], pos[1], 0]) {
      counterbore(h=chassis_thickness,
                  d=front_bumper_bolt_d,
                  bore_h=front_bumper_bolt_cbore_h,
                  sink=front_bumper_use_countersunk,
                  bore_d=front_bumper_bolt_cbore_d,
                  reverse=true);
    }
  }
  // Head zone
  translate([0, head_center_y, 0]) {
    front_chassis_head_slots();
  }
  if (show_access_slots) {
    front_chassis_access_slots(head_center_y);
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_front_frame_unsplit
  ─────────────────────────────────────────────────────────────────────────────
  Build the head and suspension plate body in vehicle coordinates.
  **Parameters:**
  - `debug`: Display outline labels.
  - `show_access_slots`: Include head cable passages.
  - `debug_font`: Outline label font.
  - `debug_color`: Outline label color.
  - `color`: Plate color; undef inherits the caller's color.
  - `rear_joint`: Include the steering-plate tongue and retaining-pin passages.
 */
module front_chassis_front_frame_unsplit(debug=false,
                                         show_access_slots=true,
                                         debug_font="Gill Sans:style=Bold",
                                         debug_color=green_2,
                                         color=white_smoke_1,
                                         rear_joint=split_front_chassis) {

  y_end = y_front_chassis_rear_frame_joint_1_start;
  difference() {
    union() {
      difference() {
        front_chassis_front_frame_blank(color=color,
                                        rear_joint=rear_joint);
        front_chassis_front_frame_head_slots(show_access_slots=show_access_slots);

        // The bulkhead slots
        front_bulkhead_housing_slots_non_center_y();

        // Two holes for the bellcrank slots
        translate([0, -bellcrank_y_distance_from_bulkhead, 0]) {
          bellcrank_slots();
        }

        // Two through holes for metal pins used in the joint with the rear frame
        if (rear_joint) {
          translate([0, y_end, 0]) {
            front_chassis_pin_joint_holes(center=true,
                                          direction=-1,
                                          use_pad=false,
                                          pad_side="top");
          }
        }
      }

      // Male joint for connection to the front rear frame
      if (rear_joint) {
        translate([0, y_end, 0]) {
          front_chassis_joint_male(color=color);
        }
      }
    }
    front_chassis_suspension_mount_recess();
  }
  if (debug) {
    front_chassis_front_frame_labels(font=debug_font,
                                     color=debug_color,
                                     rear_joint=rear_joint);
  }
}

front_chassis_front_frame_unsplit();
