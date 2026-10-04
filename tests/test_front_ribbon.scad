/**
  * Module: Front camera ribbon route and head alignment assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/suspension/front_chassis/computed_params.scad>

use <../scad/suspension/front_chassis/front_chassis_front_frame.scad>
use <../scad/suspension/front_chassis/front_chassis_head_slots.scad>
use <../scad/suspension/front_chassis/front_chassis_ribbon_slots.scad>

curve = front_chassis_ribbon_curve();
path  = front_chassis_ribbon_path();
ys    = front_chassis_head_ribbon_slot_ys();
assert(norm(path[0] - curve[0]) < 1e-6);
assert(norm(path[len(path) - 1]
            - [0, front_chassis_head_center_y() + ys[len(ys) - 1]]) < 1e-6);
assert(norm(curve[3] - curve[2]) > 0);
assert(curve[3][1] > curve[2][1]);
assert(curve[3][0] == curve[2][0]);
for (rows = [3, 5, 6]) {
  poses = front_chassis_ribbon_slot_poses(rows);
  assert(len(poses) == rows);
  assert(norm([poses[0][0], poses[0][1]] - curve[0]) < 1e-6);
  assert(norm([poses[rows - 1][0], poses[rows - 1][1]] - curve[3]) < 1e-6);
  assert(abs(poses[rows - 1][2]) < 1e-6);
  assert(abs(poses[0][2] - (front_rpi_orientation == "lwh" ? 90 : 0)) < 1e-6);
}
echo("PASS: Pi-side ribbon direction, configurable slot count and head endpoint");
