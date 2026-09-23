include <../scad/steering_params.scad>
use <../scad/lib/plist.scad>
use <../scad/motor_brackets/rc/gearbox_bracket.scad>
use <../scad/motor_brackets/rc/gearmotor_encoder_bracket.scad>
use <../scad/placeholders/rotary_encoder.scad>

p = gearmotor_bracket_compute_params();
e = plist_get("encoder_mount", p);
shaft = plist_get("shaft_tip", e);
magnet = plist_get("magnet_face", e);
sensor = plist_get("sensor_face", e);
bounds = plist_get("bounds", e);

module near(a, b) {
  assert(norm(a - b) < 0.000001, str(a, " != ", b));
}
near(shaft, [0, 32.42, 16.65]);
near(magnet - shaft, [0, motor_encoder_magnet_h, 0]);
near(sensor - magnet, [0, motor_encoder_magnet_distance, 0]);
near(plist_get("pcb_back", e) - sensor, [0, 2.58, 0]);
assert(plist_get("rotated", e));
assert(plist_get("pcb_h", e) == 14.75);
assert(plist_get("base_h", e) + plist_get("bottom_thickness", e)
       < shaft[2] - plist_get("pcb_h", e) / 2);
assert(plist_get("nut_pocket_h", e) < plist_get("base_h", e));
assert(bounds[1][1] < plist_get("base_bounds", p)[1][1], "No added length");
near([plist_get("size", p)[1]], [76.1]);
assert(plist_get("bounds", p)[1][0] > plist_get("base_bounds", p)[1][0]);
assert(plist_get("bounds", p)[1][0] - plist_get("base_bounds", p)[1][0] < 2.2);

// The main bracket retains its native shape and datums when the feature is off.
plain = gearmotor_bracket_compute_params(encoder_plist=undef);
assert(is_undef(plist_get("encoder_mount", plain)));
near(plist_get("bounds", plain)[1], [14.325, 44.3, 19.94]);
near(plist_get("bounds", plain)[0], [-35.75, -31.8, 0]);
assert(plist_get("mount_hole_positions", plain) == plist_get("mount_hole_positions", p));

// The unused shaft tip follows the actual shaft length, gearbox depth and
// sleeve-side protrusion; changing base thickness shifts Z only.
changed_motor = plist_put("drive_shaft",
                          plist_merge(plist_get("drive_shaft", motor_plist),
                                       ["l", 63.42, "rear_l", 12]), motor_plist);
changed = plist_get("encoder_mount", gearmotor_bracket_compute_params(changed_motor,
                                                                      bracket_thickness=8));
near(plist_get("shaft_tip", changed), shaft + [0, 1, 2]);
near(plist_get("pcb_back", changed), plist_get("pcb_back", e) + [0, 1, 2]);
// Rotate a wider/taller alternative PCB only when its X dimension is shorter.
wide_pcb = plist_put("size", [18, 14, 1.74], motor_encoder_plist);
wide = gearmotor_encoder_params(motor_plist, 6, encoder_plist=wide_pcb);
assert(!plist_get("rotated", wide));
assert(plist_get("pcb_w", wide) == 18 && plist_get("pcb_h", wide) == 14);
// A low shaft remains possible with a thinner detachable foot, when specified.
low_motor = plist_put("gearbox", plist_put("outer_shaft_y_center", 9.2,
                       plist_get("gearbox", motor_plist)), motor_plist);
low = gearmotor_encoder_params(low_motor, 6, bottom_thickness=1.2);
assert(!is_undef(low));
echo("PASS: shaft encoder alignment, removable-mount height, dimensions, opt-out and hardware changes");
