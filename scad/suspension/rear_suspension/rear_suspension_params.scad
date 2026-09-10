include <../../parameters.scad>


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
