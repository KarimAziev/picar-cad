/**
  * Module: Rear camber-link datums and fixed hardware checks.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/suspension/rear_axle/rear_camber_link_params.scad>

use <../scad/lib/plist.scad>
use <../scad/suspension/rear_axle/rear_camber_link.scad>

epsilon = 0.000001;
length  = rear_camber_link_ball_spacing(rear_camber_link_spec);
assert(abs(length - 39.7) < epsilon,
       "Camber link uses the steering hardware's installed ball spacing");

start   = [4, 8, 12];
for (delta = [[50, 0, 0], [50, 7, 12], [-50, -7, -12]]) {
  frame = rear_camber_link_frame(start, start + delta);
  for (axis = frame) {
    assert(abs(norm(axis) - 1) < epsilon);
  }
  assert(abs(frame[0] * frame[1]) < epsilon);
  assert(abs(frame[1] * frame[2]) < epsilon);
  assert(norm(cross(frame[0], frame[1]) - frame[2]) < epsilon);
  angle = atan2(frame[0][1], frame[2][1]);
  bushing_axis = frame[0] * sin(angle) + frame[2] * cos(angle);
  assert(norm(bushing_axis - [0, 1, 0]) < epsilon,
         "Spherical bushing bores must retain the mounting bolt's Y axis");
  fit = rear_camber_link_fit(start, start + delta, rear_camber_link_spec);
  assert(abs(norm(plist_get("hardware_end", fit) - start) - length) < epsilon,
         "Mount spacing cannot stretch the rod or its ends");
  assert(abs(plist_get("length_error", fit) - (length - norm(delta))) < epsilon);
}

fit = rear_camber_link_fit(start,
                           start + [length, 0, 0],
                           rear_camber_link_spec);
assert(abs(plist_get("length_error", fit)) < epsilon);
assert(norm(plist_get("hardware_end", fit) - (start + [length, 0, 0])) < epsilon);
echo("Rear camber-link datum checks passed");
