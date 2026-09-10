/**
  * Module: Rear ladder frame and rear-wheel-drive packaging assembly.
  *
  * One motor drives one propeller shaft. The optional translucent differential
  * is an envelope only; no rear suspension or wheel geometry is implemented.
  */
include <computed_params.scad>
use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../../placeholders/rc_gearmotor.scad>
use <../../placeholders/rc_driveshaft.scad>
use <../../placeholders/rc_dogbone.scad>
use <rear_chassis.scad>
use <rear_chassis_motor_carrier.scad>

show_rear_chassis = true;
show_rear_chassis_components = true;
show_rear_motor_carrier = true;
show_rear_motor = true;
show_rear_gearbox = true;
show_rear_driveshaft = true;
show_rear_dogbone = true;
show_rear_unused_shaft = true;
show_rear_differential_envelope = false;
show_rear_motor_slots = true;
rear_motor_spacing = 0; // [0:1:40]

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis_assembly
  ─────────────────────────────────────────────────────────────────────────────
  Compose the rear frame using the shared motor, coupling and socket datums.
  **Parameters:**
  - `motor_spec`: Motor property list.
  - `shaft_spec`: Shaft property list.
  - `show_rear_chassis`: Show the structural ladder frame.
  - `show_rear_chassis_components`: Master visibility for everything on the frame.
  - `show_rear_motor_carrier`: Show the removable can saddle.
  - `show_rear_motor`: Show the brushed motor can.
  - `show_rear_gearbox`: Show the gearbox and driven output.
  - `show_rear_driveshaft`: Show the articulated propeller shaft.
  - `show_rear_dogbone`: Show the short differential-side dogbone.
  - `show_rear_unused_shaft`: Show the unused forward output shaft.
  - `show_rear_differential_envelope`: Preview the reserved differential space.
  - `show_rear_motor_slots`: Cut the frame's carrier bolt holes.
  - `rear_motor_spacing`: Explode the entire drivetrain upward, in mm.
  - `anchor`: Anchor on the frame envelope, not the elevated drivetrain.
 */
module rear_chassis_assembly(motor_spec=rc_gearmotor_plist,
                             shaft_spec=rc_driveshaft_plist,
                             show_rear_chassis=show_rear_chassis,
                             show_rear_chassis_components=show_rear_chassis_components,
                             show_rear_motor_carrier=show_rear_motor_carrier,
                             show_rear_motor=show_rear_motor,
                             show_rear_gearbox=show_rear_gearbox,
                             show_rear_driveshaft=show_rear_driveshaft,
                             show_rear_dogbone=show_rear_dogbone,
                             show_rear_unused_shaft=show_rear_unused_shaft,
                             show_rear_differential_envelope=show_rear_differential_envelope,
                             show_rear_motor_slots=show_rear_motor_slots,
                             rear_motor_spacing=rear_motor_spacing,
                             anchor=[0, -1, 1]) {
  layout = rear_chassis_layout(motor_spec, shaft_spec);
  size = plist_get("size", layout);
  with_anchor(anchor, size, centered=true) translate([0, size[1] / 2, 0]) {
    if (show_rear_chassis) color("#dddfe5")
      rear_chassis(motor_spec, shaft_spec, show_motor_slots=show_rear_motor_slots);
    if (show_rear_chassis_components) translate([0, 0, rear_motor_spacing]) {
      if (show_rear_motor_carrier) color("#517aad")
        rear_chassis_carrier_position(motor_spec, shaft_spec)
          rear_chassis_motor_carrier(motor_spec, shaft_spec);
      rear_chassis_motor_position(motor_spec, shaft_spec)
        rc_gearmotor(spec=motor_spec, show_motor=show_rear_motor,
                      show_gearbox=show_rear_gearbox,
                      show_rear_shaft=show_rear_gearbox,
                      show_front_shaft=show_rear_unused_shaft);
      if (show_rear_driveshaft)
        rc_driveshaft_between(plist_get("shaft_start", layout),
                              plist_get("shaft_end", layout), spec=shaft_spec);
      if (show_rear_dogbone) rear_chassis_dogbone_position(motor_spec, shaft_spec)
        rc_dogbone(spec=shaft_spec);
      if (show_rear_differential_envelope) {
        %color("#39bcd2", 0.35) translate(plist_get("diff_pos", layout))
          cuboid(rear_chassis_diff_size, r=rear_chassis_mount_land);
        %color("#39bcd2", 0.35)
          translate([0, plist_get("diff_front_y", layout), plist_get("shaft_end", layout)[2]])
            rotate([-90, 0, 0]) cylinder(d=plist_get("bore_d", shaft_spec),
                                        h=rear_chassis_diff_input_l, $fn=32);
      }
    }
  }
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis_dogbone_position
  ─────────────────────────────────────────────────────────────────────────────
  Locate the cut end inside the rear socket, with the ball over the access hole.
  **Parameters:**
  - `motor_spec`: Motor property list.
  - `shaft_spec`: Shaft property list.
  **Children:** Dogbone geometry beginning at its cut end, along local +Z.
  **Notes:** The outer tip is the provisional differential-input reference.
 */
module rear_chassis_dogbone_position(motor_spec=rc_gearmotor_plist,
                                      shaft_spec=rc_driveshaft_plist) {
  layout = rear_chassis_layout(motor_spec, shaft_spec);
  l = plist_get("dogbone_outer_l", shaft_spec) + plist_get("dogbone_insert_l", shaft_spec);
  translate(plist_get("dogbone_tip", layout) + [0, l, 0])
    rotate([90, 0, 0]) children();
}

rear_chassis_assembly();
