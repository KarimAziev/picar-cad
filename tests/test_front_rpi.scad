include <../scad/suspension/front_chassis/computed_params.scad>
use <../scad/placeholders/rpi_5.scad>

module near(a, b) {
  assert(norm(a - b) < 0.000001, str(a, " != ", b));
}

near(rpi_5_size(), [56, 88, 1.9]);
near(rpi_5_oriented_size("lwh"), [88, 56, 1.9]);
near(rpi_5_oriented_size("lwh", [60, 90, 2], 5), [95, 60, 2]);

for (orientation = ["wlh", "lwh"], x = [-150, -5, 0, 120], y = [-40, -20, 0]) {
  bounds = front_chassis_rpi_bounds(orientation, x, y);
  size = rpi_5_oriented_size(orientation);
  near(bounds[1] - bounds[0], size);
  near([bounds[0][0], bounds[1][1]],
       [x, y_front_chassis_rear_frame_main_start + y]);
}

// These assertions also run under CLI orientation/offset/reversal overrides.
near([rpi_y_end], [front_rpi_bounds[0][1]]);
assert(front_rpi_mount_bounds[0][0] >= -front_chassis_rear_frame_w / 2);
assert(front_rpi_mount_bounds[1][0] <= front_chassis_rear_frame_w / 2);
assert(front_chassis_rear_frame_w >= chassis_body_min_w);
assert(front_chassis_rear_frame_w >= servo_slot_min_w * 2);
assert(front_chassis_y_joint_2_end + joint_l <= rpi_y_end);
assert(front_chassis_y_joint_2_end + joint_l <= servo_end_y);
near([chassis_joint_wide_w], [front_chassis_rear_frame_w]);
echo("PASS: oriented RPi reference, offsets, frame enclosure and rear joint");

// Independent measured rectangles exercise custom dimensions and reversal.
for (orientation = ["wlh", "lwh"], reverse = [false, true]) {
  bounds = rpi_5_mount_bounds(orientation=orientation,
                               rotate_z_180=reverse,
                               size=[60, 90, 2],
                               usb_a_y_offset=5,
                               bolt_spacing=[40, 70],
                               bolt_offset=5,
                               mount_d=6,
                               pad=2);
  expected = orientation == "wlh"
    ? (reverse ? [[10, 15, 0], [60, 95, 0]] : [[0, 0, 0], [50, 80, 0]])
    : (reverse ? [[0, 10, 0], [80, 60, 0]] : [[15, 0, 0], [95, 50, 0]]);
  near(bounds[0], expected[0]);
  near(bounds[1], expected[1]);
  anchored = rpi_5_mount_bounds(orientation=orientation,
                                 anchor=[0, -1, 1],
                                 rotate_z_180=reverse,
                                 size=[60, 90, 2],
                                 usb_a_y_offset=5,
                                 bolt_spacing=[40, 70],
                                 bolt_offset=5,
                                 mount_d=6,
                                 pad=2);
  shift = orientation == "wlh" ? [-30, -95, 0] : [-47.5, -60, 0];
  near(anchored[0], expected[0] + shift);
  near(anchored[1], expected[1] + shift);
}
echo("PASS: mounting footprint follows hardware, orientation, reversal and anchor");
