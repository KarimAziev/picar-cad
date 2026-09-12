/**
  * Module: Vehicle-coordinate adapter for the measured RC motor and gearbox.
  *
  * The shared nested specification lives in parameters.scad. The housing is
  * XY-centered, rests on Z=0, and its driven shaft points along -Y.
  */
include <../../../parameters.scad>

use <../../../lib/plist.scad>
use <../../../lib/transforms.scad>
use <rc_gearbox.scad>

show_motor       = true;
show_gearbox     = true;
show_rear_shaft  = true;
show_front_shaft = true;

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_gearmotor_size
  ─────────────────────────────────────────────────────────────────────────────
  Return the housing and measured motor-stack envelope in vehicle coordinates.
  **Parameters:**
  - `spec`: Nested motor property list shared with rc_motor.
  **Returns:** `[w, l, h]`, including contacts but excluding output protrusions.
 */
function rc_gearmotor_size(spec=rc_gearmotor_plist) =
  let (box = rc_gearbox_size(spec))
  [box[0], box[2] + rc_motor_total_h(spec), box[1]];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_gearmotor_axis_x
  ─────────────────────────────────────────────────────────────────────────────
  Return a shared gear-layout axis's X coordinate inside the centered housing.
  **Parameters:**
  - `spec`: Nested motor property list.
  - `output`: True selects the output; false selects the motor-can axis.
  **Returns:** X in mm; the axis placement is still an inferred packaging datum.
 */
function rc_gearmotor_axis_x(spec=rc_gearmotor_plist, output=true) =
  let (layout = rc_gearbox_layout(spec))
  plist_get("centers", layout)[output ? 3 : 0][0] - plist_get("center", layout)[0];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_gearmotor_axis_z
  ─────────────────────────────────────────────────────────────────────────────
  Return a shared gear-layout axis's height above the nominal housing bottom.
  **Parameters:**
  - `spec`: Nested motor property list.
  - `output`: True selects the output; false selects the motor-can axis.
  **Returns:** Z in mm; output and motor axes need not share a height.
 */
function rc_gearmotor_axis_z(spec=rc_gearmotor_plist, output=true) =
  rc_gearbox_size(spec)[1] / 2
  - plist_get("centers", rc_gearbox_layout(spec))[output ? 3 : 0][1];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_gearmotor_shaft_tip
  ─────────────────────────────────────────────────────────────────────────────
  Return a shaft tip from the same datum used by the visible placeholder.
  **Parameters:**
  - `spec`: Nested motor property list.
  - `rear`: Select the -Y output, or the provisional long forward output.
  **Returns:** `[x, y, z]` in default body-anchor coordinates.
 */
function rc_gearmotor_shaft_tip(spec=rc_gearmotor_plist, rear=true) =
  let (box = plist_get("gearbox", spec), size = rc_gearmotor_size(spec))
  [rc_gearmotor_axis_x(spec),
   -size[1] / 2 + (rear ? -plist_get("rear_shaft_h", box)
                   : rc_gearbox_size(spec)[2] + plist_get("front_shaft_h", box)),
   rc_gearmotor_axis_z(spec)];

/**
  ─────────────────────────────────────────────────────────────────────────────
  rc_gearmotor
  ─────────────────────────────────────────────────────────────────────────────
  Place the measured motor and gear-envelope housing in vehicle coordinates.
  **Parameters:**
  - `spec`: Nested hardware property list shared with rc_motor.
  - `show_motor`: Show the measured motor/contact stack.
  - `show_gearbox`: Show the housing.
  - `show_rear_shaft`: Show the driven rear output and bearing boss.
  - `show_front_shaft`: Show the provisional long forward output and boss.
  - `slot_mode`: Emit the conservative assembly envelope.
  - `clearance`: Radial and axial allowance in slot mode.
  - `anchor`: Housing/stack envelope anchor, excluding output protrusions.
 */
module rc_gearmotor(spec=rc_gearmotor_plist,
                    show_motor=show_motor,
                    show_gearbox=show_gearbox,
                    show_rear_shaft=show_rear_shaft,
                    show_front_shaft=show_front_shaft,
                    slot_mode=false,
                    clearance=0,
                    anchor=[0, 0, 1]) {
  size = rc_gearmotor_size(spec);
  center = plist_get("center", rc_gearbox_layout(spec));
  with_anchor(anchor, size, centered=true) {
    translate([-center[0], -size[1] / 2, size[2] / 2]) {
      rotate([-90, 0, 0]) {
        rc_motor(plist=spec,
                 show_motor=show_motor,
                 show_gearbox=show_gearbox,
                 show_gear_layout=false,
                 show_rear_shaft=show_rear_shaft,
                 show_front_shaft=show_front_shaft,
                 slot_mode=slot_mode,
                 clearance=clearance,
                 anchor=undef);
      }
    }
  }
}

rc_gearmotor();
