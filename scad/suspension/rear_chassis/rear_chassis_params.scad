
include <../../parameters.scad>
include <../../rc_params.scad>
include <../rear_suspension/rear_suspension_params.scad>


// ─────────────────────────────────────────────────────────────────────────────
// A maintenance hole for easy access after the arm pad rectangular slot
// ─────────────────────────────────────────────────────────────────────────────
rear_chassis_maintenance_hole_d        = 8.40;

// Length of the transition to the wider part
rear_suspension_chassis_transition_len = 10;

// ─────────────────────────────────────────────────────────────────────────────
// RC motor slot
// ─────────────────────────────────────────────────────────────────────────────

// Gap from the sleeve's outer end to the maintenance-hole center along +Y.
// Without a sleeve, use the start of the output shaft's end flat.
rc_motor_maintenance_hole_dist         = -1.8;

// Sides refer to the mounted bracket in chassis coordinates, after rotation.
panel_stack_side                       = "auto"; // auto | left (-X) | right (+X)
panel_stack_side_x_dist_from_motor     = 0; // edge-to-edge bracket/panel gap
panel_stack_y_offset                   = 0; // from bracket footprint center, along chassis Y

// Each entry is independent: type = control | fuse | stack, side = left | right
// | auto. Auto chooses the smaller occupied side; later entries can use the
// opposite side automatically. Repeated sides are placed successively outward.
rear_panel_specs                       = [["type", "fuse",
                                           "side", "right",
                                           "orientation", "wlh"],
                                          // ["type", "fuse", "side", "auto", "orientation", "lwh"]
                                          ];

// Optional per-panel keys: gap (edge-to-edge), y_offset (from motor center).
// Set the power case to undef for the lower deck alone; [] removes all panels.
// Move controls toward the suspension, within the existing full-width deck.
// The low panel may remain beneath the case; tall levers drive the clearance.
// Combined control/fuse stacks remain beside the motor. Per-entry outside_case overrides this.
rear_control_outside_case              = true;
rear_control_case_gap                  = 3;

rear_power_case_plist                  = multi_lipo_packs_case;
rear_power_case_y_offset               = -4;
rear_power_case_clearance              = 3;
rear_power_standoff_clearance          = 2;

// Optional Wago brackets: auto tries beneath the case, then extends toward -Y.
// Each entry accepts placement, rotation (degrees), gap, service_h, bracket.
// Example: [["placement", "auto", "rotation", 90], ["placement", "after"]]
rear_wago_mounts                       = [];

// joint
rear_suspension_joint_pin_l            = 54;
