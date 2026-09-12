/**
  * Module: Middle chassis computed dimensions.
  *
  * Derives the frame envelope, component anchors, structural rail positions,
  * and wide chassis-joint dimensions from the mounted components.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../../parameters.scad>
include <../../steering_params.scad>
include <../front_chassis/computed_params.scad>

use <../../placeholders/motors/rc/rc_gearmotor.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_body_size
  ─────────────────────────────────────────────────────────────────────────────

  Return the load-bearing middle-frame envelope, excluding the front joint.

  **Returns:**
  - Size as `[w, l, h]`.
 */
function middle_chassis_body_size() =
  let (electronics_l = rpi_len
         + middle_chassis_component_gap
         + rc_gearmotor_size()[1] + rear_chassis_mount_land * 2,
       w = rpi_width
         + middle_chassis_component_gap * 2
         + max(power_case_width, power_lid_width) * 2
         + middle_chassis_edge_rail_w * 2,
       l = max(power_case_length, electronics_l)
         + middle_chassis_rail_w() * 2 + joint_l)
  [w, l, middle_chassis_thickness];

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_size
  ─────────────────────────────────────────────────────────────────────────────

  Return the complete middle chassis envelope, including its front joint.

  **Returns:**
  - Size as `[w, l, h]`.
 */
function middle_chassis_size() =
  let (body_size = middle_chassis_body_size())
  [body_size[0], body_size[1] + joint_l, body_size[2]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_body_front_y
  ─────────────────────────────────────────────────────────────────────────────

  Return the local Y coordinate of the component deck's front edge.

  **Returns:**
  - Y coordinate in the centered complete-chassis coordinate system.
 */
function middle_chassis_body_front_y() =
  middle_chassis_size()[1] / 2 - joint_l;

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_component_front_y
  ─────────────────────────────────────────────────────────────────────────────

  Return the component front edge behind the solid joint crossmember.
 */
function middle_chassis_component_front_y() =
  middle_chassis_body_front_y() - middle_chassis_rail_w();

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_power_case_center_x
  ─────────────────────────────────────────────────────────────────────────────

  Return the X center of either outboard power case.

  **Parameters:**
  - `side`: Side sign, `-1` for left or `1` for right.

  **Returns:**
  - X coordinate of the power-case center.
 */
function middle_chassis_power_case_center_x(side) =
  assert(abs(side) == 1, "Power-case side must be -1 or 1")
  side * (rpi_width / 2
          + middle_chassis_component_gap
          + max(power_case_width, power_lid_width) / 2);

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_motor_center_y
  ─────────────────────────────────────────────────────────────────────────────

  Return the motor center behind the Raspberry Pi, between the power cases.

  **Parameters:**
  - `motor_spec`: Motor hardware property list.
  **Returns:** Local Y coordinate in the centered middle-frame envelope.
 */
function middle_chassis_motor_center_y(motor_spec=rc_gearmotor_plist) =
  middle_chassis_component_front_y()
  - rpi_len
  - middle_chassis_component_gap
  - rear_chassis_mount_land
  - rc_gearmotor_size(motor_spec)[1] / 2;

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_motor_carrier_w
  ─────────────────────────────────────────────────────────────────────────────
  Fit the removable carrier between the inner faces of the battery cases.
  **Returns:** Carrier width with a service gap on each side.
 */
function middle_chassis_motor_carrier_w() =
  rpi_width + middle_chassis_component_gap * 2 - rear_chassis_clearance * 2;

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_joint_w
  ─────────────────────────────────────────────────────────────────────────────

  Return the wide interface width shared with the steering-servo frame.

  **Returns:**
  - Joint width across X.
 */
function middle_chassis_joint_w() = chassis_joint_wide_w;

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_joint_rail_w
  ─────────────────────────────────────────────────────────────────────────────

  Return the dovetail width after reserving bolt lands on both sides.

  **Returns:**
  - Dovetail rail width across X.
 */
function middle_chassis_joint_rail_w() = chassis_joint_wide_rail_w;

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_joint_bolt_xs
  ─────────────────────────────────────────────────────────────────────────────

  Distribute joint bolts symmetrically across the wide interface.

  **Returns:**
  - List of bolt-center X coordinates.
 */
function middle_chassis_joint_bolt_xs() = chassis_joint_wide_bolt_xs;

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_joint_pin_spacing
  ─────────────────────────────────────────────────────────────────────────────

  Return the center-to-center spacing of the two longitudinal reinforcing pins.

  **Returns:**
  - Pin spacing across X.
 */
function middle_chassis_joint_pin_spacing() = chassis_joint_wide_pin_spacing;

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_rail_w
  ─────────────────────────────────────────────────────────────────────────────

  Size the structural rails from the largest component counterbore and the
  required material land on each side.

  **Returns:**
  - Rail width.
 */
function middle_chassis_rail_w() =
  max(power_case_bottom_cbore_dia,
      rpi_bolt_cbore_dia,
      rear_chassis_mount_bolt_d)
  + middle_chassis_mount_land * 2;

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_cross_rail_ys
  ─────────────────────────────────────────────────────────────────────────────

  Return cross-rail centers under every component mounting-hole row.

  **Returns:**
  - List of local Y coordinates.
 */
function middle_chassis_cross_rail_ys() =
  let (front_y = middle_chassis_component_front_y(),
       power_center_y = front_y - power_case_length / 2,
       power_ys = [for (side = [-1, 1])
           power_center_y
           + power_case_bolt_spacing_offset_y
           + side * power_case_bottom_bolt_spacing[1] / 2],
       rpi_rear_y = front_y - rpi_len + rpi_bolts_offset,
       rpi_ys = [rpi_rear_y,
                 rpi_rear_y + rpi_bolt_spacing[1]],
       motor_l = rc_gearmotor_size()[1] + rear_chassis_mount_land * 2,
       motor_ys = [for (side = [-1, 1])
           middle_chassis_motor_center_y()
           + side * (motor_l / 2 - rear_chassis_mount_land - rear_chassis_mount_bolt_d / 2)])
  concat(power_ys, rpi_ys, motor_ys);

/**
  ─────────────────────────────────────────────────────────────────────────────
  middle_chassis_center_rail_xs
  ─────────────────────────────────────────────────────────────────────────────

  Return longitudinal rail centers aligned with the motor-carrier holes.

  **Returns:**
  - List of symmetric local X coordinates.
 */
function middle_chassis_center_rail_xs() =
  [for (side = [-1, 1])
      side * (middle_chassis_motor_carrier_w() - rear_chassis_rail_w) / 2];
