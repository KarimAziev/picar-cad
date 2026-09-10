/**
  * Module: Removable rear motor carrier and shared mounting datums.
  *
  * A can saddle and two strap passages provide provisional retention without
  * inventing a gearbox mounting-hole pattern. Fit must be checked on hardware.
  */
include <computed_params.scad>
use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/slots.scad>
use <../../lib/transforms.scad>
use <../../placeholders/rc_gearmotor.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis_motor_position
  ─────────────────────────────────────────────────────────────────────────────
  Clock and place motor-body-anchored children onto the rear carrier.
  **Parameters:**
  - `motor_spec`: Motor property list.
  - `shaft_spec`: Shaft property list defining the shared layout.
  **Children:** Nominal XY-centered motor geometry with its bottom at Z=0.
 */
module rear_chassis_motor_position(motor_spec=rc_gearmotor_plist,
                                   shaft_spec=rc_driveshaft_plist) {
  layout = rear_chassis_layout(motor_spec, shaft_spec);
  size = rc_gearmotor_size(motor_spec);
  translate(plist_get("motor_pos", layout) + [0, 0, size[0] / 2])
    rotate([0, 90, 0]) translate([0, 0, -size[2] / 2]) children();
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis_motor_bolt_slots
  ─────────────────────────────────────────────────────────────────────────────
  Cut the same four vertical bolt passages through carrier and supporting rails.
  **Parameters:**
  - `motor_spec`: Motor property list.
  - `shaft_spec`: Shaft property list defining the shared layout.
 */
module rear_chassis_motor_bolt_slots(motor_spec=rc_gearmotor_plist,
                                    shaft_spec=rc_driveshaft_plist) {
  layout = rear_chassis_layout(motor_spec, shaft_spec);
  eps = front_chassis_joint_boolean_overlap;
  for (side = [-1, 1], y = plist_get("bolt_ys", layout))
    translate([side * plist_get("rail_x", layout), y, -eps])
      cylinder(d=rear_chassis_mount_bolt_d,
               h=rear_chassis_rail_h + rear_chassis_carrier_h + eps * 2, $fn=40);
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis_carrier_position
  ─────────────────────────────────────────────────────────────────────────────
  Place a default-anchored carrier on its supporting rear rails.
  **Parameters:**
  - `motor_spec`: Motor property list.
  - `shaft_spec`: Shaft property list defining the shared layout.
  **Children:** Carrier geometry or its slot-mode cutters.
 */
module rear_chassis_carrier_position(motor_spec=rc_gearmotor_plist,
                                     shaft_spec=rc_driveshaft_plist) {
  layout = rear_chassis_layout(motor_spec, shaft_spec);
  translate([0, plist_get("motor_pos", layout)[1], rear_chassis_rail_h]) children();
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis_motor_carrier
  ─────────────────────────────────────────────────────────────────────────────
  Build a flat-bottomed, XY-centered removable carrier resting on Z=0.
  **Parameters:**
  - `motor_spec`: Motor property list; the can diameter controls the saddle.
  - `shaft_spec`: Shaft property list defining the shared layout.
  - `slot_mode`: Emit rail mounting holes only.
  - `anchor`: Anchor on the complete plate-and-saddle envelope.
  **Notes:** The saddle has clearance for a liner. Straps and final gearbox
  fasteners are not modeled; this is not a torque-qualified motor mount.
 */
module rear_chassis_motor_carrier(motor_spec=rc_gearmotor_plist,
                                  shaft_spec=rc_driveshaft_plist,
                                  slot_mode=false,
                                  anchor=[0, 0, 1]) {
  layout = rear_chassis_layout(motor_spec, shaft_spec);
  size = plist_get("carrier_size", layout);
  motor_pos = plist_get("motor_pos", layout);
  can_pos = plist_get("can_pos", layout);
  can_l = plist_get("can_l", layout);
  can_d = plist_get("can_d", motor_spec);
  fit = rear_chassis_fit_clearance;
  land = rear_chassis_mount_land;
  eps = front_chassis_joint_boolean_overlap;
  saddle_h = can_pos[2] - rear_chassis_rail_h - can_d / 3;
  shift = [0, -motor_pos[1], -rear_chassis_rail_h];

  with_anchor(anchor, [size[0], size[1], max(size[2], saddle_h)], centered=true)
    translate(shift) if (slot_mode) {
      rear_chassis_motor_bolt_slots(motor_spec, shaft_spec);
    } else difference() {
      union() {
        translate([0, motor_pos[1], rear_chassis_rail_h])
          cuboid(size, r=land);
        translate([0, can_pos[1], rear_chassis_rail_h])
          cuboid([can_d + (fit + land) * 2, can_l, saddle_h], r=land);
      }
      translate(can_pos) rotate([90, 0, 0])
        cylinder(d=can_d + fit * 2, h=can_l + eps * 2, center=true, $fn=80);
      rear_chassis_motor_bolt_slots(motor_spec, shaft_spec);
      for (side = [-1, 1], y = plist_get("strap_ys", layout))
        translate([side * (can_d / 2 + fit + rear_chassis_strap_h / 2),
                   y, rear_chassis_rail_h - eps])
          rect_slot(size=[rear_chassis_strap_h, rear_chassis_strap_w],
                     h=saddle_h + eps * 2, center=true, r=rear_chassis_strap_h / 2);
    }
}

rear_chassis_motor_carrier();
