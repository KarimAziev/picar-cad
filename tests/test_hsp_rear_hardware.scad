/**
  * Module: Rear drivetrain hardware datum checks.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

include <../scad/suspension/rear_axle/hardware_params.scad>

use <../scad/lib/plist.scad>
use <../scad/placeholders/differential.scad>
use <../scad/placeholders/hsp_rear_drivetrain.scad>
use <../scad/placeholders/hsp_shock_absorber.scad>

diff_size       = hsp_rear_differential_size(rear_differential_spec);
diff_axis       = hsp_rear_differential_axis(rear_differential_spec);
diff_bearings   = hsp_rear_differential_bearing_positions(rear_differential_spec);
diff_outputs    = hsp_rear_differential_output_positions(rear_differential_spec);
diff_gear       = hsp_rear_differential_gear_position(rear_differential_spec);
bearing_h       = plist_get("bearing_h", rear_differential_spec);
body_l          = differential_case_span(rear_differential_spec);
support_l       = plist_get("support_l", rear_differential_spec);
tolerance       = 0.000001;
cup_l           = plist_get("cup_l", rear_differential_spec);

assert(norm(diff_size - [45.1, 38, 38]) < tolerance,
       "Measured differential overall envelope");
assert(abs(body_l - 16.6) < tolerance);
assert(plist_get("case_size", rear_differential_spec) == [25, 20, 12.6]);
assert(plist_get("support_d", rear_differential_spec) == 9.17);
assert(abs(plist_get("cup_bore_d", rear_differential_spec) - 5.91) < tolerance);
assert(plist_get("cup_bore_depth", rear_differential_spec) == 10);
assert(plist_get("cup_slot_depth", rear_differential_spec) == 8.3);
assert(norm(diff_gear - [16.25, 19, 19]) < tolerance);
assert(norm(diff_bearings[0] - [12.25, 19, 19]) < tolerance);
assert(norm(diff_bearings[1] - [32.85, 19, 19]) < tolerance);
assert(abs(diff_bearings[1][0] - diff_bearings[0][0] - bearing_h - body_l)
       < tolerance,
       "Differential bearing shoulders must meet the case envelope");
assert(abs(diff_bearings[0][0] - bearing_h / 2
           - (cup_l + support_l - bearing_h)) < tolerance);
assert(diff_outputs[0][0] < diff_bearings[0][0] - bearing_h / 2);
assert(diff_outputs[1][0] > diff_bearings[1][0] + bearing_h / 2);
assert(norm(diff_outputs[0] + diff_outputs[1] - 2 * diff_axis) < tolerance);
assert(diff_gear[0] - plist_get("gear_h", rear_differential_spec) / 2
       == cup_l + support_l);

wide_cup        = plist_put("cup_l", cup_l + 2, rear_differential_spec);
assert(abs(hsp_rear_differential_size(wide_cup)[0] - diff_size[0] - 4)
       < tolerance,
       "Cup changes must propagate to the hardware bounds");
assert(abs(hsp_rear_differential_bearing_positions(wide_cup)[0][0]
           - diff_bearings[0][0] - 2) < tolerance);

long_support    = plist_put("support_l", support_l + 1, rear_differential_spec);
assert(abs(hsp_rear_differential_size(long_support)[0] - diff_size[0] - 2)
       < tolerance,
       "Journal length must drive the overall stack");
assert(abs(hsp_rear_differential_bearing_positions(long_support)[0][0]
           - diff_bearings[0][0] - 1) < tolerance);
assert(plist_get("bearing_h", long_support) == bearing_h,
       "Support length and bearing width are independent");

pinion_bearings = hsp_rear_pinion_bearing_positions(rear_pinion_spec);
pinion_end      = hsp_rear_pinion_shaft_end(rear_pinion_spec);
assert(pinion_end[2] > pinion_bearings[1][2]
       + plist_get("bearing_h", rear_pinion_spec) / 2);
assert(plist_get("motor_bore_d", rear_motor_sleeve_spec) == 4);
assert(plist_get("pinion_bore_d", rear_motor_sleeve_spec)
       == plist_get("shaft_d", rear_pinion_spec));
assert(hsp_motor_sleeve_size(rear_motor_sleeve_spec)[2]
       == plist_get("motor_engagement", rear_motor_sleeve_spec)
       + plist_get("pinion_engagement", rear_motor_sleeve_spec)
       + plist_get("shaft_end_gap", rear_motor_sleeve_spec));
assert(abs(plist_get("pin_center_l", rear_dogbone_spec) - 55.4) < 0.000001);
assert(abs(plist_get("pin_center_l", rear_dogbone_spec)
           + plist_get("ball_d", rear_dogbone_spec) - 61.2) < 0.000001);
assert(plist_get("ball_d", rear_dogbone_spec) == 5.8
       && plist_get("shank_d", rear_dogbone_spec) == 3.8
       && plist_get("pin_l", rear_dogbone_spec) == 9.82
       && plist_get("pin_d", rear_dogbone_spec) == 2,
       "Dogbone dimensions follow the caliper reference model");

wheel_bearings  = hsp_rear_wheel_axle_bearing_positions(rear_wheel_axle_spec);
wheel_ball      = hsp_rear_wheel_axle_ball_position(rear_wheel_axle_spec);
wheel_bearing_h = plist_get("bearing_h", rear_wheel_axle_spec);
wheel_pin_z     = plist_get("pin_center_z", rear_wheel_axle_spec);
assert(hsp_rear_wheel_axle_size(rear_wheel_axle_spec)[2] == 31,
       "02168 reference overall length");
assert(wheel_ball[2] + plist_get("ball_d", rear_dogbone_spec) / 2
       < plist_get("cup_slot_depth", rear_wheel_axle_spec),
       "Dogbone ball must remain inside the cup cavity before the solid shaft");
assert(wheel_bearings[0][2] + wheel_bearing_h / 2
       == plist_get("cup_l", rear_wheel_axle_spec),
       "Inner bearing must seat on the cup barrel");
assert(wheel_bearings[1][2] + wheel_bearing_h / 2
       <= wheel_pin_z - plist_get("pin_d", rear_wheel_axle_spec) / 2,
       "Wheel drive pin must lie beyond the outer bearing");
assert(plist_get("cup_bore_d", rear_wheel_axle_spec)
       > plist_get("ball_d", rear_dogbone_spec));

for (eye_l = [plist_get("eye_distance_min", rear_shock_spec),
              plist_get("eye_distance_max", rear_shock_spec)]) {
  eyes = hsp_shock_eye_positions(rear_shock_spec, eye_l);
  assert(norm(eyes[1] - eyes[0]) == eye_l,
         "Shock eye spacing must follow articulation");
  assert(hsp_shock_size(rear_shock_spec, eye_l)[2]
         == eye_l + plist_get("eye_d", rear_shock_spec));
}

echo("Rear hardware datum checks passed");
