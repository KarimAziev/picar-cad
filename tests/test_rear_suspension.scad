include <../scad/suspension/rear_suspension/computed_params.scad>
use <../scad/lib/plist.scad>

layout = rear_suspension_layout();
d = rear_suspension_chassis_bolt_bore_d;
bh_1 = plist_get("bulkhead_1_y", layout);
bh_2 = plist_get("bulkhead_2_y", layout);
rect_y = plist_get("rect_y", layout);
maintenance_y = plist_get("maintenance_y", layout);
tol = 0.000001;
assert(abs(-bh_1 - d - rear_bulkhead_bolt_spacing_1_holder_dist) < tol);
assert(abs(bh_1 - rear_bulkhead_bolt_spacing_1[1] / 2 - d
           - bh_2 - rear_bulkhead_bolt_spacing_2[1] / 2
           - rear_bulkhead_bolt_spacing_1_2_edge_dist) < tol);
assert(abs(bh_2 - rear_bulkhead_bolt_spacing_2[1] / 2 - d / 2
           - rect_y - rear_suspension_arm_pad_rect_slot_size[1] / 2
           - rear_suspension_arm_pad_bulkhead_slot_dist) < tol);
assert(abs(rect_y - rear_suspension_arm_pad_rect_slot_size[1] / 2
           - maintenance_y - rear_chassis_maintenance_hole_d / 2
           - rear_chassis_maintenance_hole_arm_pad_dist) < tol);
// The joining edge now encloses the motor and panel, not just the maintenance hole.
assert(plist_get("min_y", layout) < maintenance_y - rear_chassis_maintenance_hole_d / 2);
pts = rear_suspension_outline_points();
for (i = [1:len(pts)-1]) {
  assert(pts[i] != pts[i-1]);
}
echo("PASS: measured rear suspension edge gaps and nonduplicated outline");

use <../scad/motor_brackets/rc/gearbox_bracket.scad>
use <../scad/panel_stack/panel_stack.scad>
use <../scad/suspension/rear_chassis/rear_chassis_frame.scad>

module near(actual, expected) {
  assert(norm(actual - expected) < tol, str(actual, " != ", expected));
}

bracket = gearmotor_bracket_compute_params(motor_plist);
bounds = plist_get("bounds", bracket);
near(plist_get("side_widths", bracket), [35.75, 14.325]);
near([plist_get("drive_end_y", bracket)], [-48]);
near(plist_get("size", bracket), bounds[1] - bounds[0]);
assert(plist_get("min_parent_surface_size", bracket)[0] == 71.5);
assert(plist_get("min_parent_surface_size", bracket)[1]
       >= bounds[1][1] - plist_get("drive_end_y", bracket));

// Reversing the bracket swaps its sides, but keeps the drive shaft on X=0.
near(plist_get("motor_side_widths", layout), [14.325, 35.75]);
assert(plist_get("motor_pos", layout)[0] == 0);
assert(plist_get("panel_side", layout) == "left");
for (side = ["left", "right", "auto"], orientation = ["wlh", "lwh"],
     y_offset = [-20, 0, 15], gap = [0, 3, 8]) {
  current = rear_suspension_layout(side=side, orientation=orientation,
                                    panel_y_offset=y_offset, panel_gap=gap);
  motor = plist_get("motor_bounds", current);
  panel = plist_get("panel_bounds", current);
  left = plist_get("panel_side", current) == "left";
  near([left ? motor[0][0] - panel[1][0] : panel[0][0] - motor[1][0]], [gap]);
  near([plist_get("panel_pos", current)[1]],
       [(motor[0][1] + motor[1][1]) / 2 + y_offset]);
  near(plist_get("panel_size", current), panel_stack_oriented_size(orientation));
  near(rear_chassis_size(current), rear_suspension_chassis_size(current));
  assert(plist_get("join_w", current) == 2 * plist_get("max_half_w", current));
  assert(plist_get("size", current)[0] >= plist_get("join_w", current));
  for (part = [motor, panel]) {
    assert(part[0][0] >= -plist_get("max_half_w", current) + rear_suspension_chassis_bolt_pad - tol);
    assert(part[1][0] <= plist_get("max_half_w", current) - rear_suspension_chassis_bolt_pad + tol);
    assert(part[0][1] >= plist_get("min_y", current) + rear_suspension_chassis_bolt_pad - tol);
    assert(part[1][1] <= plist_get("transition_y_end", current) - rear_suspension_chassis_bolt_pad + tol);
  }
  if (side == "auto") {
    assert(plist_get("max_half_w", current) == min(plist_get("candidate_half_widths", current)));
  }
}

// Changing hardware can reverse the smaller side; changing bracket padding
// must propagate through the exact same computed specification to the chassis.
changed_motor = plist_put("gearbox",
                          plist_put("mount_ear_x_dist", 30, plist_get("gearbox", motor_plist)),
                          motor_plist);
changed_bracket = gearmotor_bracket_compute_params(changed_motor, fillet_x_w=5,
                                                   bolt_pad_y=5, bracket_thickness=8);
changed = rear_suspension_layout(bracket=changed_bracket);
assert(plist_get("panel_side", changed) == "right");
assert(plist_get("size", changed)[0] != plist_get("size", layout)[0]);
assert(plist_get("size", changed)[1] > plist_get("size", layout)[1]);

// The connection datum is derived from the same sleeve/shaft geometry as the
// placeholder; removing the sleeve uses the bare shaft's end-flat shoulder.
no_sleeve_motor = plist_remove("drive_seeve", motor_plist);
no_sleeve = gearmotor_bracket_compute_params(no_sleeve_motor);
near([plist_get("drive_end_y", no_sleeve)], [-22.2]);
no_sleeve_layout = rear_suspension_layout(bracket=no_sleeve);
near([plist_get("motor_pos", no_sleeve_layout)[1]
      - plist_get("drive_end_y", no_sleeve)],
     [maintenance_y - rc_motor_maintenance_hole_dist]);
zero_gap = rear_suspension_layout(motor_dist=0);
near([plist_get("motor_pos", zero_gap)[1] - plist_get("drive_end_y", bracket)],
     [maintenance_y]);
no_sleeve_gap = plist_put("drive_seeve", plist_remove("outer_dist", plist_get("drive_seeve", motor_plist)), motor_plist);
near([plist_get("drive_end_y", gearmotor_bracket_compute_params(no_sleeve_gap))], [-46.2]);
echo("PASS: bracket datums, left/right/auto layouts, panel orientation/offsets, sleeve fallback and chassis envelope");
