/**
  * Module: Front bumper mounting datums and parameter assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/parameters.scad>
include <../scad/rc_params.scad>

use <../scad/suspension/front_chassis/front_frame_util.scad>
use <../scad/suspension/front_bumper/common.scad>

mounts = front_chassis_bumper_mount_positions();
y = front_chassis_front_frame_start_y()
    - front_bumper_bolt_d / 2 - front_bumper_bolt_pad_y;
assert(mounts == [[-19, y - 7, chassis_thickness],
                  [0, y, chassis_thickness],
                  [19, y - 7, chassis_thickness]]);
assert(front_bumper_size(part="foam") == [163, 42, 21]);
assert(front_bumper_size(part="plate") == [110, 30, 24]);
assert(abs(front_chassis_head_center_y() - 70.825) < 1e-6);
assert(abs(front_chassis_front_frame_start_y()
           - (115.825 + front_chassis_bumper_extension)) < 1e-6);
assert(norm(front_bumper_position()
            - [-81.5, 97.225 + front_chassis_bumper_extension, 6]) < 1e-6);
for (pl = [[], ["foam_h", 16, "post_d", 9, "bolt_l", 30]]) {
  for (part = ["plate", "foam", "assembly"]) {
    pos = front_bumper_position(pl, part);
    holes = front_bumper_mount_positions(pl, part);
    for (i = [0:2]) {
      assert(norm(pos + holes[i] - mounts[i]) < 1e-8);
    }
    assert(pos[2] == chassis_thickness);
  }
}
echo("PASS: bumper mounting datums, reference sizes and shared fit parameters");
