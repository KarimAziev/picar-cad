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
assert(abs(maintenance_y - rear_chassis_maintenance_hole_d / 2
           - plist_get("min_y", layout) - rear_suspension_chassis_bolt_pad) < tol);
pts = rear_suspension_outline_points();
for (i = [1:len(pts)-1]) assert(pts[i] != pts[i-1]);
echo("PASS: measured rear suspension edge gaps and nonduplicated outline");
