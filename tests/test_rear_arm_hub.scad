/**
  * Module: Rear arm and hub mechanical interface assertions.
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/suspension/rear_axle/arm_hub_params.scad>

use <../scad/lib/plist.scad>
use <../scad/suspension/rear_axle/rear_hub.scad>
use <../scad/suspension/rear_axle/rear_lower_arm.scad>

arm             = rear_lower_arm_spec;
hub             = rear_hub_spec;
root            = rear_lower_arm_inner_pivot(arm);
tip             = rear_lower_arm_outer_pivot(arm);
arm_balls       = rear_lower_arm_ball_positions(arm);
hub_balls       = rear_hub_ball_positions(hub);
hub_translation = tip - rear_hub_pivot(hub);
assert(rear_lower_arm_size(arm) == [49, 40, front_lower_arm_thickness]);
assert(root == [front_lower_arm_thickness / 2, 20, front_lower_arm_thickness / 2]);
assert(tip == [57.5, 20, front_lower_arm_thickness / 2]);
assert(plist_get("hinge_d", arm) < front_bulkhead_housing_h,
       "Arm hinge bosses must clear the chassis below the shared housing hinge");
for (i = [0, 1]) {
  assert(norm(arm_balls[i] - hub_balls[i] - hub_translation) < 0.00001,
         "Both lower ball centers must share one hub placement");
}
bearings        = rear_hub_bearing_positions(hub);
assert(bearings[1][0] - bearings[0][0]
       == plist_get("inner_bearing_w", hub)
       + plist_get("bearing_separation", hub));
assert(bearings[1][0] + plist_get("outer_bearing_w", hub) == 10);
assert(norm(rear_hub_size(hub) - [16, 33.4, 48.1]) < 0.00001);
assert(plist_get("bearing_housing_d", hub) == 18.3);
assert(plist_get("socket_d", hub) == 12);
assert(abs(rear_hub_bearing_wall(hub) - 1.6) < 0.00001);
assert(abs(plist_get("ball_spacing", hub) - 21.4) < 0.00001);
assert(plist_get("ball_spacing", hub) == plist_get("outer_bolt_spacing", arm),
       "The arm studs and lower hub sockets must use one shared spacing");
assert(norm(rear_hub_axle(hub) - rear_hub_pivot(hub) - [0, 0, 10])
       < 0.00001);
links = rear_hub_link_positions(hub);
assert(len(links) == 2);
assert(links[0][0] < 0, "Camber arm must lean inboard of the bearing face");
assert(norm(links[0] - links[1] - [0, 0, 5.2]) < 0.00001);
assert(rear_hub_link(hub) == links[0]);
assert(rear_hub_link(plist_put("link_hole", 1, hub)) == links[1]);
assert(plist_get("link_l", hub) == knuckle_arm_thickness);
assert(plist_get("link_narrow_w", hub) == knuckle_arm_narrow_w);
assert(abs(rear_hub_link(hub)[2] - rear_hub_axle(hub)[2] - 28.5) < 0.00001);
assert(rear_hub_measured_link_axle_range == [28, 29]);
assert(rear_hub_nominal_link_axle_h >= rear_hub_measured_link_axle_range[0]
       && rear_hub_nominal_link_axle_h <= rear_hub_measured_link_axle_range[1]);

wide_arm        = plist_put("inner_span", 44, arm);
assert(rear_lower_arm_inner_pivot(wide_arm)[1] == 22);
assert(rear_lower_arm_outer_pivot(wide_arm)[1] == 22);
wide_hub        = plist_put("ball_spacing", 25, hub);
assert(rear_hub_size(wide_hub)[1] == 37);
assert(rear_hub_pivot(wide_hub)[1] == 18.5);
small_socket    = plist_put("socket_d", 11.5, hub);
assert(norm(rear_hub_axle(small_socket) - rear_hub_pivot(small_socket)
            - [0, 0, 10]) < 0.00001);
large_bearing   = plist_put("inner_bearing_od", 16, hub);
assert(abs(rear_hub_bearing_wall(large_bearing) - 1.1) < 0.00001);
thick_bearing   = plist_put("outer_bearing_w", 5, hub);
assert(rear_hub_axle(thick_bearing)[0] == 5.5);
echo("Rear lower ball, bearing and parameter interface assertions passed");
