/**
  * Module: Front shock attachment and articulated mounting contracts.
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/rc_params.scad>

use <../scad/lib/plist.scad>
use <../scad/suspension/front_linkage.scad>
use <../scad/suspension/front_shocks.scad>

function near(a, b) = norm(a - b) < 0.00001;
neutral = front_shock_mounts(front_shock_settings, front_shock_spec, 1);
faces   = plist_get("faces", neutral);
assert(near(faces[0], [58.6, 35.25, 3.95]),
       "Lower eye must use the arm boss bore");
assert(near(faces[1], [22.5, 28.3, 48]),
       "Manual upper position 3 is inner/low");
assert(near(plist_get("spacers", neutral), [0.5, 7.45]));
assert(abs(plist_get("eye_distance", neutral) - norm([36.1, 0, 44.05])) < 0.00001);
assert(plist_get("eye_distance", neutral) > plist_get("eye_distance_max", front_shock_spec),
       "The mounting requirement must expose the configured shock travel mismatch");
for (position = [1:3]) {
  settings = plist_put("upper_position", position, front_shock_settings);
  r = front_shock_mounts(settings, front_shock_spec, 1);
  l = front_shock_mounts(settings, front_shock_spec, -1);
  for (i = [0:1]) {
    p = plist_get("eyes", r)[i];
    assert(near(plist_get("eyes", l)[i], [-p[0], p[1], p[2]]));
  }
  assert(plist_get("eyes", r)[0][1] == plist_get("eyes", r)[1][1],
         "Both shock eye bores must remain parallel to the mounting bolts");
  if (position < 3) {
    assert(plist_get("faces", r)[1][0] > faces[1][0]
           && plist_get("faces", r)[1][2] > faces[1][2]);
  }
}
for (side = [-1, 1], angle = [-5, 0, 5]) {
  pose = front_linkage_pose(lower_angle=angle,
                            bellcrank_angle=0,
                            side=side,
                            hole=0);
  mounts = front_shock_mounts(front_shock_settings,
                              front_shock_spec,
                              side,
                              pose);
  p = plist_get("faces", mounts)[0];
  hinge = plist_get("hinge", plist_get("lower", plist_get("datums", pose)));
  radial = faces[0][0] - hinge[0];
  assert(near(p, [side * (hinge[0] + radial * cos(angle)),
                  faces[0][1], hinge[2] - radial * sin(angle)]),
         "Lower shock mount must follow the hinged arm at every pose");
  assert(near(plist_get("faces", mounts)[1],
              [side * faces[1][0], faces[1][1], faces[1][2]]));
}
echo("PASS front shock manual numbering, mounting axes, spacers and articulated endpoints");
