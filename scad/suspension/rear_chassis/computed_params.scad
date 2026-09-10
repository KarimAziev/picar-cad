/**
  * Module: Rear drivetrain packaging datums.
  *
  * +Y is forward. The front socket spans Y=-joint_l..0. Dimensions describing
  * the future differential are clearance reservations, not measured hardware.
  */
include <../../parameters.scad>
include <../../steering_params.scad>
include <../front_chassis/computed_params.scad>
include <../rear_suspension/computed_params.scad>
use <../../lib/plist.scad>
use <../../placeholders/rc_gearmotor.scad>
use <../../placeholders/rc_driveshaft.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis_layout
  ─────────────────────────────────────────────────────────────────────────────
  Derive a ladder frame and drivetrain datums from the hardware envelopes.
  **Parameters:**
  - `motor_spec`: Motor property list.
  - `shaft_spec`: Propeller-shaft property list.
  **Returns:** Property list of sizes and positions, in front-socket coordinates.
  The gearbox is clocked 90 degrees about Y, putting the can below the output.
 */
function rear_chassis_layout(motor_spec=rc_gearmotor_plist,
                             shaft_spec=rc_driveshaft_plist) =
  let (motor = rc_gearmotor_size(motor_spec),
       rail_w = rear_chassis_rail_w,
       cross_w = rear_chassis_cross_w,
       gap = rear_chassis_clearance,
       land = rear_chassis_mount_land,
       inner_w = max(rear_chassis_diff_size[0], motor[2] + land * 2) + gap * 2,
       ladder_w = inner_w + rail_w * 2,
       transition_l = max(0, (chassis_joint_wide_w - ladder_w) / 2),
       root_l = max(cross_w, (front_chassis_joint_pin_l - joint_l) / 2 + land),
       shoulder_y = -joint_l - root_l,
       straight_y = shoulder_y - transition_l,
       terminal_l = plist_get("terminal_l", motor_spec),
       motor_y = straight_y - gap - max(land, terminal_l) - motor[1] / 2,
       motor_z = rear_chassis_rail_h + rear_chassis_carrier_h,
       output_z = motor_z + motor[0] / 2 - rc_gearmotor_axis_x(motor_spec),
       can_z = motor_z + motor[0] / 2 - rc_gearmotor_axis_x(motor_spec, false),
       gear_front_y = motor_y - motor[1] / 2 + plist_get("gearbox_l", motor_spec),
       can_l = motor[1] - plist_get("gearbox_l", motor_spec)
               - plist_get("end_cap_l", motor_spec),
       can_y = gear_front_y + can_l / 2,
       hub_reach = plist_get("socket_l", shaft_spec),
       engagement = rc_driveshaft_hub_l(shaft_spec) / 2,
       start = [0, motor_y - motor[1] / 2
                - plist_get("rear_shaft_l", motor_spec) - hub_reach + engagement,
                output_z],
       shaft_l = plist_get("pivot_l", shaft_spec),
       input_z = front_chassis_thickness + rear_chassis_diff_input_h,
       drop = output_z - input_z,
       end = start + [0, -sqrt(shaft_l * shaft_l - drop * drop), -drop],
       dogbone_tip = end + [0, -hub_reach - plist_get("dogbone_outer_l", shaft_spec), 0],
       suspension = rear_suspension_layout(),
       suspension_y = dogbone_tip[1] + plist_get("maintenance_y", suspension),
       suspension_front_y = suspension_y - plist_get("min_y", suspension),
       suspension_w = plist_get("join_w", suspension),
       taper_l = max(rail_w, (ladder_w - suspension_w) / 2),
       rail_end_y = suspension_front_y + taper_l,
       diff_front_y = dogbone_tip[1] - rear_chassis_diff_input_l,
       diff_y = diff_front_y - rear_chassis_diff_size[1] / 2,
       rear_y = suspension_y - plist_get("max_y", suspension),
       carrier_l = motor[1] + land * 2,
       bolt_row = carrier_l / 2 - land - rear_chassis_mount_bolt_d / 2)
  assert(ladder_w <= chassis_joint_wide_w, "Rear hardware is wider than the socket adapter")
  assert(rear_chassis_rail_h >= front_chassis_thickness)
  assert(plist_get("bore_d", shaft_spec) >= plist_get("shaft_d", motor_spec),
         "Propeller-shaft hub bore is smaller than the motor output")
  assert(abs(drop) < shaft_l, "Differential drop exceeds shaft reach")
  assert(rc_driveshaft_joint_angle(end - start, [0, -1, 0])
         <= plist_get("max_angle", shaft_spec), "Shaft exceeds the provisional joint-angle limit")
  assert(rail_end_y < motor_y - motor[1] / 2 - land,
         "Shaft is too short for the motor carrier and suspension transition")
  assert(output_z - drop - rear_chassis_diff_size[2] / 2 >= 0,
         "Differential reservation extends below the frame printing plane")
  ["size", [chassis_joint_wide_w, -rear_y, rear_chassis_rail_h],
   "ladder_w", ladder_w, "rail_x", (inner_w + rail_w) / 2,
   "shoulder_y", shoulder_y, "straight_y", straight_y,
   "motor_pos", [0, motor_y, motor_z],
   "can_pos", [0, can_y, can_z], "can_l", can_l,
   "gear_front_y", gear_front_y,
   "carrier_size", [ladder_w, carrier_l, rear_chassis_carrier_h],
   "bolt_ys", [motor_y - bolt_row, motor_y + bolt_row],
   "strap_ys", [can_y - can_l / 4, can_y + can_l / 4],
   "shaft_start", start, "shaft_end", end,
   "dogbone_tip", dogbone_tip,
   "suspension_y", suspension_y, "suspension_front_y", suspension_front_y,
   "suspension_w", suspension_w, "rail_end_y", rail_end_y,
   "diff_pos", [0, diff_y, end[2] - rear_chassis_diff_size[2] / 2],
   "diff_front_y", diff_front_y,
   "rear_y", rear_y];
