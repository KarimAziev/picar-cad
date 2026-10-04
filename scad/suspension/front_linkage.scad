/**
  * Module: Rigid front suspension and wheel tie-rod assembly poses.
  *
  * Coordinates match front_suspension_assembly: chassis top is Z=0,
  * vehicle right is +X and forward is +Y. No printable dimensions change.
  * The input is a prescribed arm angle, not a spring/load simulation.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../rc_params.scad>

use <../lib/functions.scad>
use <../lib/plist.scad>
use <../placeholders/ball_stud.scad>
use <knuckle/steering_link.scad>
use <knuckle/util.scad>
use <wishbone_arms/front_lower_arm.scad>
use <wishbone_arms/front_upper_arm.scad>
use <wishbone_arms/util.scad>

function _fl_unit(v) = v / norm(v);
function _fl_columns(x, y, z) = transpose_matrix([x, y, z]);
function _fl_matrix(r) = concat([for (row = r) concat(row, [0])],
                                [[0, 0, 0, 1]]);
function _fl_turn(v, axis, a) =
  v * cos(a) + cross(axis, v) * sin(a) + axis * (axis * v) * (1 - cos(a));
function _fl_wrap(a) = a - 360 * floor((a + 180) / 360);

// Select the outboard intersection of the upper-arm and upright circles.
function _fl_upper(lower, hinge, radius, upright_l) =
  let (a = [hinge[0], hinge[2]],
       b = [lower[0], lower[2]],
       dy = hinge[1] - lower[1],
       v = b - a,
       d = norm(v),
       r2 = upright_l * upright_l - dy * dy)
  assert(d > 0 && r2 > 0, "Degenerate suspension pivot geometry")
  let (x = (radius * radius - r2 + d * d) / (2 * d),
       h2 = radius * radius - x * x)
  assert(h2 >= -1e-8,
         "Upper arm cannot reach the knuckle at this lower-arm angle")
  let (e = v / d,
       h = sqrt(max(0, h2)),
       p = a + x * e + h * [-e[1], e[0]],
       q = a + x * e - h * [-e[1], e[0]],
       out = p[0] > q[0] ? p : q)
  [out[0], hinge[1], out[1]];

// Rotate the upright around its actual inclined ball-joint axis.
function _fl_steer(lower, axis, attachment, target, length) =
  let (v = attachment - lower,
       parallel = axis * (axis * v),
       radial = v - parallel,
       tangent = cross(axis, radial),
       w = target - lower - parallel,
       a = w * radial,
       b = w * tangent,
       c = (w * w + radial * radial - length * length) / 2,
       amplitude = sqrt(a * a + b * b))
  assert(amplitude > 1e-8, "Degenerate wheel tie-rod constraint")
  assert(abs(c) <= amplitude + 1e-8,
         "Fixed-length wheel tie rod cannot reach at this suspension/bellcrank pose")
  let (phase = atan2(b, a),
       delta = acos(min(1, max(-1, c / amplitude))),
       p = _fl_wrap(phase + delta),
       q = _fl_wrap(phase - delta))
  abs(p) < abs(q) ? p : q;

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_linkage_datums
  ─────────────────────────────────────────────────────────────────────────────
  Resolve hinge axes, ball centers and mounting faces from component dimensions.
  **Returns:** A plist for the right half in the front-assembly frame. `lower`
  and `upper` contain arm `origin`, `hinge` and neutral `ball` coordinates.
  `socket` is the original lower knuckle ball-seat center; `upright_l` is the
  distance between its seats. `holes` contains the knuckle steering holes.
  `hub` is the outer bearing-face center.
  Ball seats use the modeled bushing cavity; mounting faces use actual holes.
 */
function front_linkage_datums() =
  let (barrel = front_lower_arm_mount_cutout_size(),
       barrel_l = barrel[1] - front_bulkhead_barrel_hinge_clearance,
       lower_origin = [front_bulkhead_w / 2 + front_bulkhead_barrel_hinge_w
                       - front_bulkhead_barrel_pin_hole_offset
                       - front_lower_arm_hinge_barrel_hole_offset
                       - front_lower_arm_hinge_barrel_hole_d,
                       front_bulkhead_len - front_lower_arm_h
                       - front_bulkhead_barrel_y_offset
                       + front_lower_arm_upper_hinge_barrel_h
                       + min(front_lower_arm_y_offset,
                             barrel[1] - barrel_l),
                       (front_bulkhead_housing_h - front_lower_arm_thickness) / 2],
       upper_origin = [front_bulkhead_pin_spacing / 2
                       - front_upper_arm_hinge_barrel_hole_d / 2
                       - front_upper_arm_hinge_barrel_hole_offset,
                       front_bulkhead_len / 2 + front_upper_arm_y_offset
                       + front_bulkhead_shock_tower_mount_thickness / 2
                       - front_upper_arm_h,
                       front_bulkhead_housing_h
                       + front_bulkhead_shock_tower_mount_offset
                       + front_upper_arm_thickness / 2],
       ball_extension = front_arm_ball_stud_unthreaded_h
                        + ball_stud_center_z(front_arm_ball_stud_shank_d,
                                             front_arm_ball_stud_ball_d,
                                             front_arm_ball_stud_len)
                        - front_arm_ball_stud_len,
       lower_ball = lower_origin + [front_lower_arm_len + ball_extension
                                    + front_lower_arm_ball_stud_insert_out_depth,
                                    front_lower_arm_ball_stud_y_pos(),
                                    front_lower_arm_thickness / 2],
       upper_ball = upper_origin + [front_upper_arm_len + ball_extension
                                    + front_upper_arm_ball_stud_insert_out_depth,
                                    front_upper_arm_ball_stud_y_pos(),
                                    front_upper_arm_thickness / 2],
       lower_hinge = [lower_origin[0] + front_lower_arm_hinge_barrel_hole_offset
                      + front_lower_arm_hinge_barrel_hole_d / 2,
                      lower_ball[1], lower_ball[2]],
       upper_hinge = [front_bulkhead_pin_spacing / 2,
                      upper_ball[1], upper_ball[2]],
       bearing = knuckle_outer_bearing_params(),
       joint = knuckle_ball_stud_joint_params(bearing[3], bearing[0]),
       k = [lower_origin[0] + knuckle_assembly_full_len()
            + max(front_lower_arm_ball_stud_insert_out_depth,
                  front_upper_arm_ball_stud_insert_out_depth),
            front_lower_arm_ball_stud_y_pos() - front_lower_arm_lower_hinge_barrel_h
            + front_bulkhead_len - front_bulkhead_barrel_y_offset - barrel[1],
            knuckle_total_len / 2 - knuckle_ball_stud_mount_outer_d / 2
            + front_bulkhead_housing_h / 2],
       socket_z = knuckle_ball_stud_house_h - front_arm_ball_stud_ball_d
                  + knuckle_bushing_thickness + knuckle_bushing_d / 2,
       socket = k + [-socket_z, 0, -joint[1]],
       planar = steering_arm_planar_params(),
       hole_z = knuckle_arm_thickness + 2 * knuckle_arm_ring_connector_l
                + planar[1] + knuckle_arm_ear_len - knuckle_arm_bolt_hole_offset
                - knuckle_arm_bolt_d / 2,
       holes = [for (i = [0:knuckle_arm_holes_n - 1])
         k + [-bearing[3] - planar[0] - knuckle_arm_narrow_w / 2,
              -hole_z + i * (knuckle_arm_bolt_d + knuckle_arm_holes_gap),
              -knuckle_arm_thickness / 2]])
  ["lower", ["origin", lower_origin,
             "hinge", lower_hinge,
             "ball", lower_ball],
   "upper", ["origin", upper_origin,
             "hinge", upper_hinge,
             "ball", upper_ball],
   "hub", k,
   "socket", socket,
   "upright_l", 2 * joint[1],
   "holes", holes];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_linkage_pose
  ─────────────────────────────────────────────────────────────────────────────
  Close both wishbones, the rigid knuckle and one fixed-length wheel tie rod.
  **Parameters:**
  - `lower_angle`: Lower arm rotation in degrees; positive lowers the wheel.
  - `bellcrank_angle`: Displayed bellcrank rotation, as in bellcrank_assembly.
  - `side`: Vehicle side, -1 left or +1 right. Returned points use right-side
    coordinates; renderers mirror them for the left side.
  - `hole`: Zero-based knuckle steering-hole index, starting at the ear tip.
  - `datums`: Component datums from front_linkage_datums().
  **Returns:** Plist with arm angles/balls, upright rotation, rod endpoints,
  rod length and wheel heading. Selects the steering branch nearest straight.
  **Behavior:** Both tie-rod bushings sit below their mounting faces. Their
  height follows the hardware. This is rigid kinematics, not load equilibrium,
  a collision check, or a servo-to-wheel calibration. Unreachable poses assert.
 */
function front_linkage_pose(lower_angle=0,
                            bellcrank_angle=0,
                            side=1,
                            hole=0,
                            datums=front_linkage_datums()) =
  assert(side == -1 || side == 1, "Linkage side must be -1 or 1")
  assert(is_num(lower_angle) && abs(lower_angle) < 60,
         "Lower arm angle must be between -60 and 60 degrees")
  assert(hole >= 0 && hole < knuckle_arm_holes_n && floor(hole) == hole,
         "Invalid knuckle steering hole")
  let (lo = plist_get("lower", datums),
       up = plist_get("upper", datums),
       lh = plist_get("hinge", lo),
       uh = plist_get("hinge", up),
       lr = norm(plist_get("ball", lo) - lh),
       ur = norm(plist_get("ball", up) - uh),
       lower = lh + [lr * cos(lower_angle), 0, -lr * sin(lower_angle)],
       upper = _fl_upper(lower, uh, ur, plist_get("upright_l", datums)),
       axis = _fl_unit(upper - lower),
       x = _fl_unit(cross([0, 1, 0], axis)),
       y = cross(axis, x),
       initial_r = _fl_columns(x, y, axis),
       socket = plist_get("socket", datums),
       h = max(knuckle_tie_rod_bushing_h, knuckle_tie_rod_eye_h,
               knuckle_tie_rod_shank_od,
               sqrt(pow(knuckle_tie_rod_bushing_od, 2)
                    - pow(knuckle_tie_rod_bushing_d, 2))),
       rod_ref = plist_get("holes", datums)[hole] - [0, 0, h / 2],
       outer_r = bellcrank_arm_l - bellcrank_arm_bolt_d / 2
                 - bellcrank_arm_bolt_edge_offset,
       target = [chassis_bellcrank_spacing / 2
                 + side * outer_r * sin(bellcrank_angle),
                 -bellcrank_y_distance_from_bulkhead
                 + outer_r * cos(bellcrank_angle),
                 bellcrank_post_flang_h + bellcrank_arm_z - h / 2],
       length = steering_link_ball_spacing(),
       initial_a = lower + initial_r * (rod_ref - socket),
       steer = _fl_steer(lower, axis, initial_a, target, length),
       r = _fl_columns(_fl_turn(x, axis, steer), _fl_turn(y, axis, steer), axis),
       a = lower + r * (rod_ref - socket),
       forward = r * [0, 1, 0])
  ["datums", datums,
   "side", side,
   "lower_angle", lower_angle,
   "upper_angle", -atan2(upper[2] - uh[2], upper[0] - uh[0]),
   "lower_ball", lower,
   "upper_ball", upper,
   "rotation", r,
   "steer", steer,
   "heading", atan2(-forward[0], forward[1]),
   "rod_a", a,
   "rod_b", target,
   "rod_l", length,
   "rod_h", h];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_linkage_knuckle
  ─────────────────────────────────────────────────────────────────────────────
  Move an already placed neutral knuckle onto its solved ball-joint centers.
  **Parameters:**
  - `pose`: Result of front_linkage_pose(), or undef to preserve the old pose.
 */
module front_linkage_knuckle(pose) {
  if (is_undef(pose)) {
    children();
  } else {
    side = plist_get("side", pose);
    scale([side, 1, 1]) {
      translate(plist_get("lower_ball", pose)) {
        multmatrix(_fl_matrix(plist_get("rotation", pose))) {
          translate(-plist_get("socket", plist_get("datums", pose))) {
            scale([side, 1, 1]) {
              children();
            }
          }
        }
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_linkage_arm
  ─────────────────────────────────────────────────────────────────────────────
  Place one unmodified wishbone by rotating about its fixed hinge pin.
  **Parameters:**
  - `pose`: Result of front_linkage_pose().
  - `upper`: Select the upper wishbone instead of the lower one.
  - `show_ball`: Display the arm's ball stud.
 */
module front_linkage_arm(pose, upper=false, show_ball=true) {
  key = upper ? "upper" : "lower";
  arm = plist_get(key, plist_get("datums", pose));
  hinge = plist_get("hinge", arm);
  scale([plist_get("side", pose), 1, 1]) {
    translate(hinge) {
      rotate([0, plist_get(upper ? "upper_angle" : "lower_angle", pose), 0]) {
        translate(plist_get("origin", arm) - hinge) {
          if (upper) {
            front_upper_arm(show_ball_stud=show_ball);
          } else {
            front_lower_arm(show_ball_stud=show_ball);
          }
        }
      }
    }
  }
}

// Euler angles taking the local bushing Z axis onto an arbitrary unit axis.
function _fl_bushing_angles(n) =
  [-asin(min(1, max(-1, n[1]))), atan2(n[0], n[2]), 0];

/**
  ─────────────────────────────────────────────────────────────────────────────
  front_linkage_rod
  ─────────────────────────────────────────────────────────────────────────────
  Place the unchanged rod between its solved centers and orient both bushings.
  **Parameters:**
  - `pose`: Result of front_linkage_pose().
 */
module front_linkage_rod(pose) {
  a = plist_get("rod_a", pose);
  b = plist_get("rod_b", pose);
  x = _fl_unit(b - a);
  y = _fl_unit(cross([0, 0, 1], x));
  z = cross(x, y);
  r = _fl_columns(x, y, z);
  inv = transpose_matrix(r);
  knuckle_axis = plist_get("rotation", pose) * [0, 0, 1];

  left_end_bushing_angles=_fl_bushing_angles(inv * knuckle_axis);
  // The second rod end is mirrored about local X.
  right_end_bushing_angles =_fl_bushing_angles(let (n = inv * [0, 0, 1]) [-n[0], n[1], n[2]]);

  scale([plist_get("side", pose), 1, 1]) {
    translate(a) {
      multmatrix(_fl_matrix(r)) {
        translate([0, 0, -plist_get("rod_h", pose) / 2]) {
          steering_tie_rod_link(angles=[0, 0, 0],
                                left_end_bushing_angles=left_end_bushing_angles,
                                right_end_bushing_angles=right_end_bushing_angles);
        }
      }
    }
  }
}
