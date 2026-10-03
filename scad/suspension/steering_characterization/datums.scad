/**
  * Module: Neutral steering datum audit.
  *
  * Extracts hole axes and displayed rod centers for the legacy unlinked pose.
  * This does not describe the solved linkage in rc_robot_assembly.scad.
  * Coordinates use the bellcrank midpoint at chassis-top height as the origin;
  * X is across the chassis, Y points forward, Z points up. Dimensions are mm.
  */
include <../../rc_params.scad>
use <../../lib/functions.scad>
use <../../placeholders/dservo.scad>
use <../../placeholders/tie_rod.scad>
use <../bellcrank/bellcrank_drive.scad>
use <../bellcrank_steering_slots.scad>
use <../knuckle/util.scad>
use <../wishbone_arms/util.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  steering_audit_knuckle_point
  ─────────────────────────────────────────────────────────────────────────────

  Transform a native knuckle point into the neutral audit frame.

  **Parameters:**
  - `p`: Native knuckle point [x, y, z].
  - `side`: -1 for the negative-X knuckle, +1 for its mirrored counterpart.
  **Returns:** Point [x, y, z] with the production assembly's translations.
  **Notes:** Only zero knuckle angles and zero suspension displacement are audited.
 */
function steering_audit_knuckle_point(p, side=-1) =
  assert(knuckle_angles == [0, 0, 0] && knuckle_z_shift == 0,
         "Neutral audit requires zero knuckle angles and suspension displacement")
  let (barrel = front_lower_arm_mount_cutout_size(),
       barrel_y = front_bulkhead_len - front_bulkhead_barrel_y_offset - barrel[1],
       lower_offset = front_lower_arm_hinge_barrel_hole_offset
         + front_bulkhead_barrel_pin_hole_offset + front_lower_arm_hinge_barrel_hole_d,
       base = [-(front_bulkhead_w + front_bulkhead_barrel_hinge_w * 2) / 2
                 + lower_offset - knuckle_assembly_full_len(),
               bellcrank_y_distance_from_bulkhead + front_lower_arm_ball_stud_y_pos()
                 - front_lower_arm_lower_hinge_barrel_h + barrel_y,
               knuckle_total_len / 2 - knuckle_ball_stud_mount_outer_d / 2
                 + front_bulkhead_housing_h / 2],
       q = base + rotate_euler_xyz(p + [0, 0,
                 -max(front_upper_arm_ball_stud_insert_out_depth,
                      front_lower_arm_ball_stud_insert_out_depth)], [0, 90, 0]))
  [-side * q[0], q[1], q[2]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  steering_audit_arm_point
  ─────────────────────────────────────────────────────────────────────────────

  Transform a point from the steering-arm module to the neutral audit frame.

  **Parameters:**
  - `p`: Steering-arm point [x, y, z].
  - `side`: -1 or +1 for the chassis side.
  **Returns:** Point [x, y, z].
 */
function steering_audit_arm_point(p, side=-1) =
  steering_audit_knuckle_point([0, 0, knuckle_outer_bearing_params()[3]]
    + rotate_euler_xyz(rotate_euler_xyz(p, [0, 0, 90]), [90, 0, 0]), side);

/**
  ─────────────────────────────────────────────────────────────────────────────
  steering_audit_servo_point
  ─────────────────────────────────────────────────────────────────────────────

  Transform an output-attachment point before horn rotation into the audit frame.

  **Parameters:**
  - `p`: Point relative to the servo output attachment, in servo coordinates.
  **Returns:** Point [x, y, z], with production bracket and body transforms.
  **Notes:** Animation time must be zero; this is a neutral assembly audit.
 */
function steering_audit_servo_point(p) =
  let (pos = bellcrank_steering_servo_position(),
       output = [-dsservo_size[0] / 2 + dsservo_gearbox_d1 / 2,
                  0, dsservo_output_attachment_height()],
       body = rotate_euler_xyz(output + p, [0, 0, 180]),
       bracket = rotate_euler_xyz([0, 0, dsservo_size[1] / 2]
         + rotate_euler_xyz(body, [-90, 0, 90]), [180, 0, 0]))
  [pos[0], pos[1] - dsservo_flange_w / 2, dsservo_size[1]] + bracket;

/**
  ─────────────────────────────────────────────────────────────────────────────
  steering_audit_datums
  ─────────────────────────────────────────────────────────────────────────────

  Return nominal neutral joint geometry and displayed rod-end centers.

  **Returns:** Flat plist of named points, hole-axis point lists and lengths.
  **Notes:** Bore points are at the part's mounting face, not inferred ball
  centers. A rod endpoint may lie elsewhere along its mating bolt axis.
  Hardware truth and acceptable fit tolerances must be confirmed separately.
 */
function steering_audit_datums() =
  assert($t == 0, "Neutral audit requires animation time zero")
  assert(knuckle_tie_rod_angle == 0 && knuckle_tie_tilt_shift == 0,
         "Legacy audit requires zero tie-rod yaw and tilt-shift overrides")
  let (outer_r = bellcrank_arm_l - bellcrank_arm_bolt_d / 2 - bellcrank_arm_bolt_edge_offset,
       inner_r = outer_r - bellcrank_arm_bolt_spacing,
       plate_r = bellcrank_arm_l - bellcrank_arm_bolt_edge_offset
         - (steering_center_link_boss_od - steering_center_link_hole_d) / 2
         - bellcrank_arm_bolt_spacing,
       plate_l = steering_center_link_len - steering_center_link_boss_od,
       arm_z = bellcrank_post_flang_h + bellcrank_arm_z + bellcrank_arm_thickness,
       planar = steering_arm_planar_params(),
       arm_x = planar[0] + knuckle_arm_narrow_w / 2,
       // Follow knuckle_steering_arm._main/_base_shape and rows_children.
       hole_z = knuckle_arm_thickness + 2 * knuckle_arm_ring_connector_l
         + planar[1] + knuckle_arm_ear_len - knuckle_arm_bolt_hole_offset
         - knuckle_arm_bolt_d / 2,
       rod_z = steering_arm_bolt_pos_from_planar(planar),
       rod_h = max(knuckle_tie_rod_bushing_h, knuckle_tie_rod_eye_od, knuckle_tie_rod_link_od),
       rod_l = knuckle_tie_rod_eye_od + 2 * knuckle_tie_rod_shank_len + knuckle_tie_rod_link_len,
       rod_angles = knuckle_tie_rod_angles,
       rod_bbox = rotated_bbox(repeat(knuckle_tie_rod_eye_od, 3), rod_angles),
       rod_shift = [-rod_bbox[0] / 2, -knuckle_tie_rod_eye_od / 2, 0],
       rod_origin = [arm_x, -knuckle_arm_thickness / 2 - rod_h, rod_z],
       rod_centers = [for (end = [0, 1])
           rod_origin + rotate_euler_xyz(rod_shift + rotate_euler_xyz(
             [knuckle_tie_rod_eye_od / 2 + end * rod_l,
              knuckle_tie_rod_eye_od / 2, rod_h / 2], rod_angles), [-90, 0, 0])],
       rod_a = rod_centers[0],
       rod_b = rod_centers[1],
       servo_dims = tie_rod_full_len(shaft_body_len=steering_servo_tie_rod_body_len,
         shaft_thread_len=steering_servo_tie_rod_thread_len,
         shaft_thread_d=steering_servo_tie_rod_thread_d, show_shaft_nuts=true,
         tie_rod_a_screw_out_depth=servo_tie_rod_a_screw_out_depth,
         tie_rod_a_eye_od=servo_tie_rod_a_eye_od, tie_rod_a_shank_len=servo_tie_rod_a_shank_len,
         tie_rod_b_eye_od=servo_tie_rod_b_eye_od, tie_rod_b_shank_len=servo_tie_rod_b_shank_len,
         tie_rod_b_screw_out_depth=servo_tie_rod_b_screw_out_depth, limit_max_depth=true),
       servo_l = servo_dims[0] - (servo_tie_rod_a_eye_od + servo_tie_rod_b_eye_od) / 2,
       servo_a = [-steering_servo_arm_w / 2 + servo_tie_rod_a_eye_od / 2,
                  steering_servo_y_tie_rod(), -dservo_tie_rod_a_max_h() / 2],
       servo_b = servo_a + rotate_euler_xyz([-servo_l, 0, 0],
                    [0, 0, steering_servo_tie_rod_angle(bellcrank_servo_lever_z_coords()[1])]))
  ["bellcrank_pivots", [for (s = [-1, 1]) [s * chassis_bellcrank_spacing / 2, 0, 0]],
   "center_mounts", [for (s = [-1, 1]) [s * chassis_bellcrank_spacing / 2, inner_r,
                                      bellcrank_post_flang_h + bellcrank_arm_z]],
   "center_plate_holes", [for (s = [-1, 1]) [s * plate_l / 2, plate_r,
                                      bellcrank_arm_z - steering_center_link_thickness]],
   "center_link_l", plate_l,
   "outer_mounts", [for (s = [-1, 1]) [s * chassis_bellcrank_spacing / 2, outer_r, arm_z]],
   "knuckle_holes", [for (s = [-1, 1]) [for (i = [0:knuckle_arm_holes_n - 1])
     steering_audit_arm_point([arm_x, -knuckle_arm_thickness / 2,
       hole_z - i * (knuckle_arm_bolt_d + knuckle_arm_holes_gap)], s)]],
   "wheel_rod_a", [for (s = [-1, 1]) steering_audit_arm_point(rod_a, s)],
   "wheel_rod_b", [for (s = [-1, 1]) steering_audit_arm_point(rod_b, s)],
   "wheel_rod_l", rod_l,
   "servo_axis", steering_audit_servo_point([0, 0, 0]),
   "servo_rod_a", steering_audit_servo_point(rotate_euler_xyz(servo_a, [0, 0, 180])),
   "servo_rod_b", steering_audit_servo_point(rotate_euler_xyz(servo_b, [0, 0, 180])),
   "servo_rod_l", servo_l,
   "servo_lever_holes", [for (i = [0:bellcrank_servo_lever_holes_n - 1])
     [-chassis_bellcrank_spacing / 2 - bellcrank_servo_lever_l
       + bellcrank_servo_lever_holes_edge_offset + bellcrank_arm_bolt_d / 2
       + i * (bellcrank_arm_bolt_d + bellcrank_servo_lever_holes_gap),
      0, bellcrank_servo_lever_z_coords()[1]]],
   "knuckle_angle", knuckle_arm_angle];

echo(steering_audit=steering_audit_datums());
