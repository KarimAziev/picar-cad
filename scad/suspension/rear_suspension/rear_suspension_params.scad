include <../../parameters.scad>
include <../../steering_params.scad>


// ─────────────────────────────────────────────────────────────────────────────
// Common rear suspension slot parameters
// ─────────────────────────────────────────────────────────────────────────────
rear_suspension_chassis_bolt_d             = m3_hole_dia;
rear_suspension_chassis_bolt_bore_d        = m3_countersunk_head_dia + 0.2;
rear_suspension_chassis_bolt_bore_h        = m3_countersunk_head_h + 0.15;
rear_suspension_chassis_sink               = true;

// ─────────────────────────────────────────────────────────────────────────────
// Suspension holder pad slot at the very end of the chassis
// ─────────────────────────────────────────────────────────────────────────────
// The outermost slot at the very end of the chassis.
rear_suspension_holder_bolt_spacing_x      = 22;

// ─────────────────────────────────────────────────────────────────────────────
// Rear bulkhead bolt spacing with 6 (or 8) holes
// ─────────────────────────────────────────────────────────────────────────────
rear_bulkhead_bolt_spacing_x               = 34;

// Distance between the bore edges (not centers) of `rear_bulkhead_bolt_spacing_1`
// and `rear_suspension_holder_bolt_spacing_x`.
rear_bulkhead_bolt_spacing_1_holder_dist   = 9.22;

// First two holes.
rear_bulkhead_bolt_spacing_1               = [rear_bulkhead_bolt_spacing_x, 0];

// Second two holes.
rear_bulkhead_bolt_spacing_2               = [rear_bulkhead_bolt_spacing_x, 11.1];

// Distance between the bore edges (not centers) of
// `rear_bulkhead_bolt_spacing_1` and `rear_bulkhead_bolt_spacing_2`.
rear_bulkhead_bolt_spacing_1_2_edge_dist   = 1.7;

// ─────────────────────────────────────────────────────────────────────────────
// Rectangular slot for the arm pad
// ─────────────────────────────────────────────────────────────────────────────
rear_suspension_arm_pad_rect_slot_size     = [5.71, 3.6];
rear_suspension_arm_pad_rect_corner_r      = 2;

// Distance between the edge of the last row of holes in
// `rear_bulkhead_bolt_spacing_2` and the rectangular slot.
rear_suspension_arm_pad_bulkhead_slot_dist = 7.47;

// ─────────────────────────────────────────────────────────────────────────────
// A maintenance hole for easy access after the arm pad rectangular slot
// ─────────────────────────────────────────────────────────────────────────────
rear_chassis_maintenance_hole_d            = 8.40;

// Distance between the edge of the maintenance hole and the edge of the
// `rear_suspension_arm_pad_rect_slot_size` slot.
rear_chassis_maintenance_hole_arm_pad_dist = 8.40;

// Rear part of the chassis with suspension.
rear_suspension_chassis_bolt_pad           = 2.75;
rear_suspension_chassis_corner_r           = 1;

// length of the transition to the wider part
rear_suspension_chassis_transition_len     = 10;

// ─────────────────────────────────────────────────────────────────────────────
// RC motor slot
// ─────────────────────────────────────────────────────────────────────────────

// Gap from the sleeve's outer end to the maintenance-hole center along +Y.
// Without a sleeve, use the start of the output shaft's end flat.
rc_motor_maintenance_hole_dist             = -1.8;

// Sides refer to the mounted bracket in chassis coordinates, after rotation.
panel_stack_side                           = "auto"; // auto | left (-X) | right (+X)
panel_stack_side_x_dist_from_motor         = 0; // edge-to-edge bracket/panel gap
panel_stack_y_offset                       = 0; // from bracket footprint center, along chassis Y

// Each entry is independent: type = control | fuse | stack, side = left | right
// | auto. Auto chooses the smaller occupied side; later entries can use the
// opposite side automatically. Repeated sides are placed successively outward.
rear_panel_specs                           = [["type", "fuse", "side", "right", "orientation", "wlh"],
                                              // ["type", "fuse", "side", "auto", "orientation", "lwh"]
                                              ];

// Optional per-panel keys: gap (edge-to-edge), y_offset (from motor center).
// Set the power case to undef for the lower deck alone; [] removes all panels.
// Move controls toward the suspension, within the existing full-width deck.
// The low panel may remain beneath the case; tall levers drive the clearance.
// Combined control/fuse stacks remain beside the motor. Per-entry outside_case overrides this.
rear_control_outside_case                  = true;
rear_control_case_gap                      = 3;

rear_power_case_plist                      = multi_lipo_packs_case;
rear_power_case_y_offset                   = -4;
rear_power_case_clearance                  = 3;
rear_power_case_headroom                   = 2; // beneath the sliding lid, above the pack
rear_power_standoff_clearance              = 2;
rear_lidar_plist                           = rplidar_c1_plist;
rear_lidar_lid_thickness                   = 3;
rear_lidar_standoff_h                      = 13;

// Optional Wago brackets: auto tries beneath the case, then extends toward -Y.
// Each entry accepts placement, rotation (degrees), gap, service_h, bracket.
// Example: [["placement", "auto", "rotation", 90], ["placement", "after"]]
rear_wago_mounts                           = [];
