/**
  * Module: Touring tire support heights and shared contact-plane assertions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */
include <../scad/rc_params.scad>
use <../scad/lib/plist.scad>
use <../scad/placeholders/rc_touring_wheel.scad>
use <../scad/suspension/front_linkage.scad>
use <../scad/suspension/rc_wheels.scad>

tolerance = 0.000001;
wheel = rc_touring_wheel_spec(rc_wheel_plist);
radius = plist_get("tire_d", wheel) / 2;
half_width = plist_get("width", wheel) / 2;
bevel = plist_get("tire_bevel", wheel);

assert(abs(rc_tire_vertical_half_extent([1, 0, 0], wheel) - radius)
       < tolerance, "An upright tire reaches its nominal radius below center");
assert(abs(rc_tire_vertical_half_extent([0, 0, 1], wheel) - half_width)
       < tolerance, "An axle pointing upward makes tire width the height");
assert(abs(rc_tire_vertical_half_extent([1, 0, 1], wheel)
           - (radius + half_width - bevel) / sqrt(2)) < tolerance,
       "The bevel controls the 45-degree support distance");
square_tire = plist_put("tire_bevel", 0, wheel);
assert(abs(rc_tire_vertical_half_extent([1, 0, 1], square_tire)
           - (radius + half_width) / sqrt(2)) < tolerance);
assert(rc_tire_vertical_half_extent([1, 0, 1], wheel)
       == rc_tire_vertical_half_extent([-2, 0, -2], wheel),
       "Axle reversal and scaling preserve the tire contact envelope");

front_pose = front_linkage_pose();
axle = plist_get("rotation", front_pose) * [1, 0, 0];
center = rc_front_wheel_reference_center(wheel);
front_extent = rc_tire_vertical_half_extent(axle, wheel);
assert(front_extent > radius, "The configured front tire is inclined");
assert(abs(rc_front_wheel_ground_z(wheel) - (center[2] - front_extent))
       < tolerance);
assert(abs(rc_rear_level_wheel_center_z(wheel, wheel) - radius
           - rc_front_wheel_ground_z(wheel)) < tolerance,
       "Upright rear and inclined front tires share one contact plane");
assert(rc_rear_level_wheel_center_z(wheel, wheel) < center[2],
       "Aligned contact planes require different centers for inclined tires");

larger_rear = plist_put("tire_d", plist_get("tire_d", wheel) + 4, wheel);
assert(abs(rc_rear_level_wheel_center_z(larger_rear, wheel)
           - rc_rear_level_wheel_center_z(wheel, wheel) - 2) < tolerance,
       "A rear diameter change raises its center by the radius change");
shifted_mount = plist_put("mount_z", plist_get("mount_z", wheel) + 1, wheel);
assert(abs(rc_front_wheel_ground_z(shifted_mount)
           - rc_front_wheel_ground_z(wheel) + axle[2]) < tolerance,
       "Backspacing on an inclined axle also affects tire-center height");

echo("Tire support-height and contact-plane assertions passed",
     "front_vertical_half_extent", front_extent,
     "front_ground_z", rc_front_wheel_ground_z(wheel),
     "rear_center_z", rc_rear_level_wheel_center_z(wheel, wheel));
