/**
  * Module: Rear ladder chassis with a wide female front socket.
  *
  * The measured suspension plate terminates the open ladder. Raised rails stop
  * ahead of the suspension; its maintenance opening locates the input dogbone.
  * The frame prints on its flat Z=0 bottom, with the motor carrier removed.
  */
include <computed_params.scad>
use <../../lib/plist.scad>
use <../../lib/shapes3d.scad>
use <../../lib/transforms.scad>
use <../front_chassis/front_chassis_joint.scad>
use <rear_chassis_motor_carrier.scad>
use <../rear_suspension/rear_suspension_chassis.scad>
use <../rear_suspension/rear_suspension_slots.scad>

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis_suspension_position
  ─────────────────────────────────────────────────────────────────────────────
  Place native suspension geometry with its maintenance opening toward the motor.
  **Parameters:**
  - `motor_spec`: Motor property list.
  - `shaft_spec`: Shaft property list.
  **Children:** Plate outline, body or cutters in native holder-row coordinates.
 */
module rear_chassis_suspension_position(motor_spec=rc_gearmotor_plist,
                                        shaft_spec=rc_driveshaft_plist) {
  layout = rear_chassis_layout(motor_spec, shaft_spec);
  translate([0, plist_get("suspension_y", layout), 0]) rotate([0, 0, 180]) children();
}

/**
  ─────────────────────────────────────────────────────────────────────────────
  rear_chassis
  ─────────────────────────────────────────────────────────────────────────────
  Build the connected rear rails, crossmembers, socket and motor-carrier holes.
  **Parameters:**
  - `motor_spec`: Motor property list.
  - `shaft_spec`: Shaft property list.
  - `show_motor_slots`: Cut the shared carrier bolt pattern.
  - `anchor`: Envelope anchor; default places the front socket edge at Y=0.
 */
module rear_chassis(motor_spec=rc_gearmotor_plist,
                    shaft_spec=rc_driveshaft_plist,
                    show_motor_slots=true,
                    anchor=[0, -1, 1]) {
  layout = rear_chassis_layout(motor_spec, shaft_spec);
  size = plist_get("size", layout);
  w = size[0];
  rail_w = rear_chassis_rail_w;
  ladder_w = plist_get("ladder_w", layout);
  shoulder_y = plist_get("shoulder_y", layout);
  straight_y = plist_get("straight_y", layout);
  rail_end_y = plist_get("rail_end_y", layout);
  suspension_front_y = plist_get("suspension_front_y", layout);
  suspension_w = plist_get("suspension_w", layout);
  eps = front_chassis_joint_boolean_overlap;

  module _rails_2d() {
    for (side = [-1, 1]) scale([side, 1])
      polygon([[w / 2, -joint_l], [w / 2, shoulder_y],
               [ladder_w / 2, straight_y], [ladder_w / 2, rail_end_y],
               [ladder_w / 2 - rail_w, rail_end_y],
               [ladder_w / 2 - rail_w, straight_y],
               [w / 2 - rail_w, shoulder_y], [w / 2 - rail_w, -joint_l]]);
  }

  module _suspension_transition_2d() {
    // A full-width low crossmember joins both rails and the square plate edge.
    polygon([[-ladder_w / 2, rail_end_y + rear_chassis_cross_w],
             [ladder_w / 2, rail_end_y + rear_chassis_cross_w],
             [ladder_w / 2, rail_end_y],
             [suspension_w / 2, suspension_front_y],
             [-suspension_w / 2, suspension_front_y],
             [-ladder_w / 2, rail_end_y]]);
  }

  with_anchor(anchor, size, centered=true) translate([0, size[1] / 2, 0])
    render(convexity=4) difference() {
      union() {
        linear_extrude(height=front_chassis_thickness) union() {
          translate([-w / 2, shoulder_y]) square([w, -shoulder_y]);
          _rails_2d();
          _suspension_transition_2d();
          rear_chassis_suspension_position(motor_spec, shaft_spec)
            rear_suspension_outline();
        }
        if (rear_chassis_rail_h > front_chassis_thickness)
          translate([0, 0, front_chassis_thickness - eps])
            linear_extrude(height=rear_chassis_rail_h - front_chassis_thickness + eps)
              _rails_2d();
      }
      front_chassis_joint_female(w=chassis_joint_wide_w,
                                 rail_w=chassis_joint_wide_rail_w,
                                 bolt_xs=chassis_joint_wide_bolt_xs,
                                 pin_spacing=chassis_joint_wide_pin_spacing,
                                 include_pin_holes=true,
                                 slot_mode=true);
      if (show_motor_slots) rear_chassis_carrier_position(motor_spec, shaft_spec)
        rear_chassis_motor_carrier(motor_spec, shaft_spec, slot_mode=true);
      rear_chassis_suspension_position(motor_spec, shaft_spec) rear_suspension_slots();
    }
}

rear_chassis();
