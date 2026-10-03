/**
  * Module: Camera ribbon threading route beneath the front chassis.
  *
  * The two ribbons share transverse openings on the Pi side of the steering
  * servo, then continue beneath the center passage to the head ribbon bank.
  * Coordinates use the assembled chassis datum; Z=0 is the underside.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <computed_params.scad>

use <../../lib/functions.scad>
use <../../lib/slots.scad>
use <../../placeholders/rpi_5.scad>
use <front_chassis_front_frame.scad>
use <front_chassis_head_slots.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_ribbon_curve
  ─────────────────────────────────────────────────────────────────────────────
  Return a cubic route from the Pi-side entry to the forward threading slot.
  **Returns:** Four XY Bezier control points in chassis coordinates.
  **Behavior:** The CSI bank follows the Pi orientation and half-turn. The
  entry is inset to preserve the rear joint and plate-edge land. Horizontal
  runs enter from the Pi's right-hand side; vertical runs enter from the rear.
  The final tangent points toward the head, parallel to the vehicle Y axis.
 */
function front_chassis_ribbon_curve() =
  let (bounds = front_chassis_rpi_bounds(),
       reference = rpi_5_size(),
       csi = rpi_5_csi_centers(),
       bank = (csi[0] + csi[len(csi) - 1]) / 2,
       oriented = orientation_matrix(front_rpi_orientation)
         * concat(bank - [reference[0] / 2, reference[1] / 2, 0], [1]),
       sign = front_rpi_rotate_z_180 ? -1 : 1,
       source = [for (i = [0:1])
           (bounds[0][i] + bounds[1][i]) / 2 + sign * oriented[i]],
       w = front_chassis_head_ribbon_slot_w,
       l = front_chassis_head_ribbon_slot_l,
       land = front_chassis_ribbon_land,
       rear_y = front_chassis_y_joint_2_end + joint_l
         + land * 2 + rpi_bolt_cbore_dia / 2 + w / 2,
       end = [w / 2 + land,
              y_front_chassis_rear_frame_main_start - joint_l - land - l / 2],
       horizontal = front_rpi_orientation == "lwh",
       start = horizontal
         ? [min(bounds[1][0], front_chassis_rear_frame_w / 2) - land - l / 2,
            max(rear_y, min(source[1], end[1] - w))]
         : [max(end[0], source[0]),
            max(rear_y, min(source[1], end[1] - w * 2.5))],
       dx = start[0] - end[0],
       dy = end[1] - start[1])
  assert(w > 0 && l > 0 && land > 0)
  assert(bounds[1][0] >= end[0] + w / 2 + land,
         "Ribbon entry needs Pi-side clearance to the right of the steering servo")
  assert(dy > l + land, "Insufficient rear-frame length for ribbon threading")
  [start,
   horizontal ? start - [dx * 0.55, 0] : start + [0, dy / 2],
   end - [0, dy * (horizontal ? 0.7 : 0.5)],
   end];

function _front_ribbon_point(p, t) =
  p[0] * pow(1 - t, 3) + p[1] * 3 * pow(1 - t, 2) * t
  + p[2] * 3 * (1 - t) * t * t + p[3] * pow(t, 3);

function _front_ribbon_tangent(p, t) =
  (p[1] - p[0]) * 3 * pow(1 - t, 2)
  + (p[2] - p[1]) * 6 * (1 - t) * t
  + (p[3] - p[2]) * 3 * t * t;

// Separating-axis check for the slot rectangles enlarged by half the land.
function _front_ribbon_slots_separate(a, b, size, land) =
  let (ax = [cos(a[2]), sin(a[2])],
       ay = [-sin(a[2]), cos(a[2])],
       bx = [cos(b[2]), sin(b[2])],
       by = [-sin(b[2]), cos(b[2])],
       delta = [b[0] - a[0], b[1] - a[1]],
       half = (size + [land, land]) / 2)
  max([for (axis = [ax, ay, bx, by])
      abs(delta * axis)
      - half[0] * (abs(ax * axis) + abs(bx * axis))
      - half[1] * (abs(ay * axis) + abs(by * axis))]) >= -0.000001;

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_ribbon_path
  ─────────────────────────────────────────────────────────────────────────────
  Sample the underside route from the Pi entry to the head threading bank.
  **Parameters:**
  - `steps`: Positive integer samples per curved segment.
  **Returns:** XY centerline points, ending at the rearmost head ribbon slot.
  **Behavior:** This is a plan-view routing guide. Cable installation needs
  slack for the entry loop, weaving through the slots and head motion.
 */
function front_chassis_ribbon_path(steps=40) =
  assert(steps > 0 && steps == floor(steps))
  let (curve = front_chassis_ribbon_curve(),
       ys = front_chassis_head_ribbon_slot_ys(),
       target = [0, front_chassis_head_center_y() + ys[len(ys) - 1]],
       reach = (target[1] - curve[3][1]) / 3,
       forward = [curve[3], curve[3] + [0, reach],
                  target - [0, reach], target])
  concat([for (i = [0:steps]) _front_ribbon_point(curve, i / steps)],
         [for (i = [1:steps]) _front_ribbon_point(forward, i / steps)]);

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_ribbon_slot_poses
  ─────────────────────────────────────────────────────────────────────────────
  Locate transverse slots along the underside ribbon route.
  **Parameters:**
  - `rows`: Number of openings, including the entry and forward exit.
  **Returns:** `[[x, y, angle], ...]`; angle rotates the slot's long X axis.
  Spacing follows the shorter edge of the ribbon envelope, allowing more
  centerline distance through tight turns. Long axes are perpendicular to
  the local cable direction.
 */
function front_chassis_ribbon_slot_poses(rows=front_chassis_ribbon_slot_rows) =
  assert(rows >= 3 && rows == floor(rows), "At least three ribbon slots required")
  let (curve = front_chassis_ribbon_curve(),
       samples = 100,
       points = [for (i = [0:samples]) _front_ribbon_point(curve, i / samples)],
       tangents = [for (i = [0:samples])
           let (v = _front_ribbon_tangent(curve, i / samples)) v / norm(v)],
       lengths = [for (i = [0:samples - 1])
           let (turn = acos(constraint(tangents[i] * tangents[i + 1], -1, 1)))
             max(0.000001, norm(points[i + 1] - points[i])
                 - front_chassis_head_ribbon_slot_w * PI / 360 * turn)],
       distances = [for (i = [0:samples]) sum(lengths, i)],
       length = distances[samples])
  [for (row = [0:rows - 1])
      let (distance = length * row / (rows - 1),
           hi = max(1, min(samples,
                           len([for (d = distances) if (d < distance) d]))),
           t = (hi - 1 + (distance - distances[hi - 1]) / lengths[hi - 1])
             / samples,
           p = _front_ribbon_point(curve, t),
           tangent = _front_ribbon_tangent(curve, t))
        [p[0], p[1], atan2(tangent[1], tangent[0]) - 90]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_chassis_ribbon_slots
  ─────────────────────────────────────────────────────────────────────────────
  Cut the shared threading slots for two stacked camera ribbons.
  **Parameters:**
  - `thickness`: Plate thickness crossed by the openings, starting at Z=0.
  - `rows`: Number of transverse openings along the route. Configurations
    that leave less than `front_chassis_ribbon_land` between slots are rejected.
  **Behavior:** Opening dimensions match the head ribbon bank. Solid strips
  separate the slots; the free cable run to the head stays beneath the chassis.
 */
module front_chassis_ribbon_slots(thickness=chassis_thickness,
                                   rows=front_chassis_ribbon_slot_rows) {
  eps = front_chassis_joint_boolean_overlap;
  poses = front_chassis_ribbon_slot_poses(rows);
  size = [front_chassis_head_ribbon_slot_w, front_chassis_head_ribbon_slot_l];
  for (i = [0:len(poses) - 2], j = [i + 1:len(poses) - 1]) {
    assert(_front_ribbon_slots_separate(poses[i], poses[j], size,
                                       front_chassis_ribbon_land),
           "Ribbon slots need more material between openings; reduce rows");
  }
  for (pose = poses) {
    translate([pose[0], pose[1], -eps]) {
      rotate([0, 0, pose[2]]) {
        rect_slot(size=size,
                  h=thickness + 2 * eps,
                  center=true,
                  autoscale_step=0,
                  r=front_chassis_ribbon_slot_corner_r);
      }
    }
  }
}

front_chassis_ribbon_slots();
