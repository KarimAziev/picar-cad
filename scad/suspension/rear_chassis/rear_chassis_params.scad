
include <../../parameters.scad>
include <../../rc_params.scad>
include <../rear_suspension/rear_suspension_params.scad>


// ─────────────────────────────────────────────────────────────────────────────
// A maintenance hole for easy access after the arm pad rectangular slot
// ─────────────────────────────────────────────────────────────────────────────
rear_chassis_maintenance_hole_d        = 8.40;

// Material beyond deck-mounted hardware, independent of suspension bolt lands.
// Raised case/lid envelopes do not receive this margin.
rear_chassis_edge_pad                  = 2.75;

// Wheel relief at each suspension-side shoulder, in mm:
// [inward X distance, distance along the side toward vehicle front].
// Both distances start at the intersection of the taper and the side edge.
rear_chassis_wheel_relief              = [15, 15];

// Length of the transition to the wider part
rear_suspension_chassis_transition_len = 10;

// Joint inset into the main deck along native -Y (vehicle front), in mm.
// Provides screw access beside the suspension arm pad.

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

// Move controls toward the suspension, within the existing full-width deck.
// The low panel may remain beneath the case; tall levers drive the clearance.
// Combined control/fuse stacks remain beside the motor. Per-entry outside_case overrides this.
rear_control_outside_case              = true;
rear_control_case_gap                  = 3;

// Complete panel placement presets. Gap is edge-to-edge; y_offset is measured
// from the motor footprint center. Auto chooses the smaller occupied side.
rear_control_panel_plist               = ["type", "control",
                                          "side", "auto",
                                          "orientation", "wlh",
                                          "gap", panel_stack_side_x_dist_from_motor,
                                          "y_offset", panel_stack_y_offset,
                                          "outside_case", rear_control_outside_case];
rear_fuse_panel_plist                  = ["type", "fuse",
                                          "side", "auto",
                                          "orientation", "lwh",
                                          "gap", panel_stack_side_x_dist_from_motor,
                                          "y_offset", panel_stack_y_offset,
                                          "outside_case", false];
rear_panel_stack_plist                 = ["type", "stack",
                                          "side", "auto",
                                          "orientation", panel_stack_orientation,
                                          "gap", panel_stack_side_x_dist_from_motor,
                                          "y_offset", panel_stack_y_offset,
                                          "outside_case", false];

// Each entry is independent; repeated sides are placed successively outward.
// Set [] for no panels, or rear_power_case_plist=undef for the lower deck alone.
rear_panel_specs                       = [plist_merge(rear_fuse_panel_plist,
                                                     ["side", "left"])];

// Fixed mounting-center spacing for the rear battery case, in canonical X/Y.
rear_power_case_plist                  = plist_merge(multi_lipo_packs_case,
                                                     ["bolt_spacing",
                                                      [138.450853, 34.6]]);
rear_power_case_y_offset               = -4;
rear_power_case_clearance              = 3;
rear_power_standoff_clearance          = 2;

// Optional Wago brackets: auto tries beneath the case, then extends toward -Y.
// Pos is an optional native XY center for under-case placement. Service height
// reserves vertical clearance above the connector for access to its levers.
rear_wago_mount_plist                  = ["placement", "auto",
                                          "rotation", 0,
                                          "gap", 3,
                                          "service_h", 12,
                                          "pos", undef,
                                          "bracket", wago_bracket_plist];
// Select [rear_wago_mount_plist] to enable a connector mount.
rear_wago_mounts                       = [];

// Rear suspension joint: two 39.5 x 3 mm stock pins.
rear_suspension_joint_pin_l            = 39.5;
rear_suspension_joint_pin_spacing      = 14;
