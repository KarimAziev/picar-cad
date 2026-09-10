include <../scad/parameters.scad>
include <../scad/steering_params.scad>
include <../scad/suspension/front_chassis/computed_params.scad>
include <../scad/suspension/middle_chassis/computed_params.scad>

use <../scad/lib/functions.scad>
use <../scad/suspension/front_chassis/front_chassis_front_frame.scad>
use <../scad/suspension/front_chassis/front_chassis_head_slots.scad>
use <../scad/suspension/front_chassis/front_chassis_access_slots.scad>
use <../scad/suspension/bulkhead/util.scad>

size = middle_chassis_size();
body_size = middle_chassis_body_size();
bolt_xs = middle_chassis_joint_bolt_xs();
head_size = front_chassis_head_mount_size();

assert(size[0] == body_size[0]);
assert(size[1] == body_size[1] + joint_l);
assert(size[2] == middle_chassis_thickness);
assert(size[0] >= middle_chassis_joint_w());
assert(middle_chassis_power_case_center_x(-1)
       == -middle_chassis_power_case_center_x(1));
assert(len(bolt_xs) == suspension_chassis_joint_wide_bolt_cols);
assert(bolt_xs[0] == -bolt_xs[len(bolt_xs) - 1]);
assert(bolt_xs[floor(len(bolt_xs) / 2)] == 0);
assert(middle_chassis_joint_rail_w() < middle_chassis_joint_w());
// The rear bumper-hole lands follow the ribbon passage, not the camera projection.
assert(abs(front_chassis_front_frame_start_y()
       - front_bumper_center_bolt_y_offset
       - front_bumper_bolt_d - front_bumper_bolt_pad_y * 2
       - front_chassis_head_center_y() - front_chassis_head_front_ribbon_y()
       - chassis_pan_servo_top_ribbon_cuttout_h / 2
       - front_chassis_head_wire_land) < 0.0001);
// Both routing banks are functional: preserve every head-side threading slot.
head_ribbon_ys = front_chassis_head_ribbon_slot_ys();
assert(len(head_ribbon_ys) == 3);
assert(front_chassis_head_ribbon_slot_w == 20);
assert(front_chassis_head_ribbon_slot_l == 3);
assert(front_chassis_head_ribbon_slot_gap == 3);
assert(len(front_chassis_head_ribbon_slot_ys(rows=4)) == 4);
for (row = [1:len(head_ribbon_ys) - 1]) {
  assert(abs(head_ribbon_ys[row - 1] - head_ribbon_ys[row]
             - front_chassis_head_ribbon_slot_l - front_chassis_head_ribbon_slot_gap) < 0.0001);
}
// Ribbon bank stays behind the head footprint, with its rear land at the bulkhead transition.
assert(head_ribbon_ys[0] + front_chassis_head_ribbon_slot_l / 2
       <= -head_size[1] / 2 - front_chassis_head_wire_land);
assert(abs(front_chassis_head_rear_reach()
           + head_ribbon_ys[len(head_ribbon_ys) - 1] - front_chassis_head_ribbon_slot_l / 2
           - front_chassis_head_wire_land) < 0.0001);
assert(abs(front_chassis_head_center_y() - front_chassis_head_rear_reach()
           - front_bulkhead_pad_distance_to_hinge() - bulkhead_size_y
           - bulkhead_transition_len) < 0.0001);
// The front passage follows the mounting footprint, not the camera's forward projection.
assert(abs(front_chassis_head_front_ribbon_y() - chassis_pan_servo_top_ribbon_cuttout_h / 2
           - head_size[1] / 2 - front_chassis_head_wire_land) < 0.0001);
assert(front_chassis_head_front_ribbon_y() + chassis_pan_servo_top_ribbon_cuttout_h / 2
       < front_chassis_head_front_reach());
// Components sit inside the perimeter and behind the front crossmember.
assert(size[0] / 2 - middle_chassis_power_case_center_x(1)
       - max(power_case_width, power_lid_width) / 2
       >= middle_chassis_edge_rail_w - 0.0001);
assert(middle_chassis_body_front_y() - middle_chassis_component_front_y()
       >= middle_chassis_rail_w() - 0.0001);

assert(to_anchor([1, 1, 1], [20, 30, 10], true) == [10, 15, 0]);
assert(to_anchor([0, 0, 0], [20, 30, 10], true) == [0, 0, -5]);
assert(to_anchor([-1, 0, 1], [20, 30, 10], true) == [-10, 0, 0]);
