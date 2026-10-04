/**
  * Module: Rigid front linkage constraints across suspension and steering poses.
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
use <../scad/lib/functions.scad>
use <../scad/lib/plist.scad>
use <../scad/suspension/front_linkage.scad>

d  = front_linkage_datums();
lo = plist_get("lower", d);
up = plist_get("upper", d);

for (angle = [-15, 0, 10, 25], steering = [-15, 0, 15], side = [-1, 1]) {
  p = front_linkage_pose(angle, steering, side);
  l = plist_get("lower_ball", p);
  u = plist_get("upper_ball", p);
  r = plist_get("rotation", p);
  a = plist_get("rod_a", p);
  b = plist_get("rod_b", p);
  // Four independent rigid-distance constraints; no scaling of components.
  assert(abs(norm(l - plist_get("hinge", lo))
             - norm(plist_get("ball", lo) - plist_get("hinge", lo))) < 1e-8);
  assert(abs(norm(u - plist_get("hinge", up))
             - norm(plist_get("ball", up) - plist_get("hinge", up))) < 1e-8);
  assert(abs(norm(u - l) - plist_get("upright_l", d)) < 1e-8);
  assert(abs(norm(b - a) - 39.7) < 1e-8);
  assert(norm(r * [0, 0, plist_get("upright_l", d)] - (u - l)) < 1e-8);
  for (i = [0:2], j = [0:2]) {
    assert(abs((r * transpose_matrix(r))[i][j] - (i == j ? 1 : 0)) < 1e-8);
  }
}

// Droop follows a circular path about a fixed hinge: X contracts as Z falls.
flat = front_linkage_pose(0);
droop = front_linkage_pose(15);
assert(plist_get("lower_ball", droop)[0] < plist_get("lower_ball", flat)[0]);
assert(plist_get("lower_ball", droop)[2] < plist_get("lower_ball", flat)[2]);
assert(abs(plist_get("heading", flat)) > 1,
       "Fixed hardware does not imply a zero-toe flat reference pose");
echo("PASS: fixed arm, upright and rod lengths; rigid transforms; circular suspension travel");
