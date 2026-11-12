/**
  * Module: Front bumper mounting datums and parameter assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/parameters.scad>
include <../scad/rc_params.scad>

use <../scad/head/head_neck.scad>
use <../scad/lib/plist.scad>
use <../scad/suspension/front_bumper/common.scad>
use <../scad/suspension/front_chassis/front_frame_util.scad>

mounts    = front_chassis_bumper_mount_positions();
extension = front_chassis_front_frame_start_y()
             - front_chassis_front_frame_start_y(extension=0);
y         = front_chassis_front_frame_start_y()
             - front_bumper_bolt_d / 2 - front_bumper_bolt_pad_y;
assert(mounts == [[-19, y - 7, chassis_thickness],
                  [0, y, chassis_thickness],
                  [19, y - 7, chassis_thickness]]);
assert(front_bumper_size(part="foam") == [163, 42, 16]);
assert(front_bumper_size(part="plate") == [110, 30, 22.4]);
assert(abs(front_chassis_head_center_y() - 70.825) < 1e-6);
assert(abs(front_chassis_front_frame_start_y()
           - (115.825 + extension)) < 1e-6);
assert(norm(front_bumper_position()
            - [-81.5, 97.225 + extension, 6]) < 1e-6);
for (pl = [[], ["foam_h", 21,
                "post_d", 9,
                "bolt_l", 30]]) {
  for (part = ["plate", "foam", "assembly"]) {
    pos = front_bumper_position(pl, part);
    holes = front_bumper_mount_positions(pl, part);
    for (i = [0:2]) {
      assert(norm(pos + holes[i] - mounts[i]) < 1e-8);
    }
    assert(pos[2] == chassis_thickness);
  }
  hardware = front_bumper_bolt_params(pl);
  top_z = front_bumper_size(pl, "plate")[2];
  assert(abs(top_z - plist_get("tip_z", hardware) - 0.1) < 1e-8);
  assert(abs(top_z - plist_get("nut_z", hardware) - 2.49) < 1e-8);
  assert(abs(plist_get("head_z", hardware) + 2.7) < 1e-8);
}
forward = front_bumper_bolt_params(["bolt_l", 35], reverse_bolts=false);
assert(abs(plist_get("head_z", forward) - 22.4) < 1e-8);
assert(plist_get("nut_z", forward) == -chassis_thickness);
echo("PASS: bumper mounting datums, reference sizes and shared fit parameters");

required = front_chassis_bumper_min_extension();
assert(abs(front_chassis_front_frame_start_y(extension="auto")
           - front_chassis_front_frame_start_y(extension=0) - required) < 1e-8);
assert(required > 13.9 && required < 14);
assert(abs(front_chassis_bumper_min_extension(tilt_range=[-90, 90])
           - front_chassis_bumper_min_extension(tilt_range=[-90, head_neck_lower_tilt_stop()])) < 1e-8);
// A circular sweep against a horizontal segment peaks at its interior.
assert(abs(front_bumper_profile_front_y([[-4, 2], [4, 2]], 5) - 3) < 1e-8);
assert(abs(front_bumper_profile_front_y([[3, 2]], 5) - 2) < 1e-8);
// The sloped segment's interior tangent is distinct from both endpoints.
assert(abs(front_bumper_profile_front_y([[-4, -4], [4, 4]], 5)
           - 5 * sqrt(2)) < 1e-8);
assert(front_chassis_bumper_min_extension(clearance=0) < required);
assert(front_chassis_bumper_min_extension(clearance=4) > required);
assert(front_chassis_bumper_min_extension(tilt_range=[0, 20]) < required);
assert(front_chassis_bumper_min_extension(["post_d", 10]) > required);
assert(front_chassis_bumper_min_extension(["foam_h", 30,
                                           "bolt_l", 39]) >= required);
echo("PASS: bumper extension follows travel, height, mounting pads and clearance");
