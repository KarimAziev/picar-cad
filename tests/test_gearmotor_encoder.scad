include <../scad/rc_params.scad>

use <../scad/lib/plist.scad>
use <../scad/motor_brackets/rc/gearbox_bracket.scad>
use <../scad/motor_brackets/rc/gearmotor_encoder_bracket.scad>
use <../scad/motor_brackets/rc/util.scad>
use <../scad/placeholders/rotary_encoder.scad>

p               = gearmotor_bracket_compute_params();
e               = plist_get("encoder_mount", p);
shaft           = plist_get("shaft_tip", e);
magnet          = plist_get("magnet_face", e);
sensor          = plist_get("sensor_face", e);
bounds          = plist_get("bounds", e);

module near(a, b) {
  assert(norm(a - b) < 0.000001, str(a, " != ", b));
}
near(shaft, [0, 30.1, 17.15]);
near(magnet - shaft,
     [0, motor_encoder_magnet_h + motor_encoder_sleeve_h_clearance, 0]);
near(sensor - magnet, [0, motor_encoder_magnet_distance, 0]);
near(plist_get("pcb_back", e) - sensor, [0, 2.58, 0]);
assert(plist_get("rotated", e));
assert(plist_get("pcb_h", e) == 14.75);
assert(plist_get("base_h", e) + plist_get("bottom_thickness", e)
       < shaft[2] - plist_get("pcb_h", e) / 2);
assert(plist_get("nut_pocket_h", e) < plist_get("base_h", e));
assert(bounds[1][1] < plist_get("base_bounds", p)[1][1], "No added length");
near([plist_get("size", p)[1]], [76.3]);
assert(plist_get("bounds", p)[1][0] > plist_get("base_bounds", p)[1][0]);
assert(plist_get("bounds", p)[1][0] - plist_get("base_bounds", p)[1][0] < 2.2);

// The main bracket retains its native shape and datums when the feature is off.
plain           = gearmotor_bracket_compute_params(encoder_plist=undef);
assert(is_undef(plist_get("encoder_mount", plain)));
near(plist_get("bounds", plain)[1], [14.325, 44.3, 18.44]);
near(plist_get("bounds", plain)[0], [-35.75, -32, 0]);
assert(plist_get("mount_hole_positions", plain) == plist_get("mount_hole_positions", p));

// The unused shaft tip follows the actual shaft length, gearbox depth and
// sleeve-side protrusion; changing base thickness shifts Z only.
changed_motor   = plist_put("drive_shaft",
                          plist_merge(plist_get("drive_shaft", motor_plist),
                                      ["l", 63.42,
                                       "rear_l", 12]),
                          motor_plist);
changed = plist_get("encoder_mount",
                    gearmotor_bracket_compute_params(changed_motor,
                                                     bracket_thickness=8));
near(plist_get("shaft_tip", changed), shaft + [0, 3.32, 1.5]);
near(plist_get("pcb_back", changed), plist_get("pcb_back", e) + [0, 3.32, 1.5]);
// Rotate a wider/taller alternative PCB only when its X dimension is shorter.
wide_pcb        = plist_put("size", [18, 14, 1.74], motor_encoder_plist);
wide          = gearmotor_encoder_params(motor_plist,
                                         6,
                                         encoder_plist=wide_pcb);
assert(!plist_get("rotated", wide));
assert(plist_get("pcb_w", wide) == 18 && plist_get("pcb_h", wide) == 14);
// A low shaft remains possible with a thinner detachable foot, when specified.
low_motor       = plist_put("gearbox",
                          plist_put("outer_shaft_y_center", 9.2,
                                    plist_get("gearbox", motor_plist)),
                          motor_plist);
low             = gearmotor_encoder_params(low_motor, 6, bottom_thickness=1.2);
assert(!is_undef(low));
echo("PASS: shaft encoder alignment, removable-mount height, dimensions, opt-out and hardware changes");

use <../scad/motor_brackets/rc/driveshaft_magnet_sleeve.scad>
s               = plist_get("sleeve", e);
near(plist_get("sleeve_origin", e),
     shaft - [0, plist_get("pad_l", plist_get("drive_shaft", motor_plist)), 0]);
near(plist_get("size", s),
     [7.5, 7.5, plist_get("pad_l", plist_get("drive_shaft", motor_plist))
      + motor_encoder_sleeve_h_clearance + motor_encoder_magnet_h
      + motor_encoder_magnet_h_clearance]);
near([plist_get("hole_z", s)],
     [plist_get("pad_l", plist_get("drive_shaft", motor_plist))
      - plist_get("hole_edge_dist", plist_get("drive_shaft", motor_plist))
      - plist_get("hole_d", plist_get("drive_shaft", motor_plist)) / 2]);
near([plist_get("magnet_face_z", s) - plist_get("size", s)[2]],
     [-motor_encoder_magnet_h_clearance]);
// Cup length changes the shoulder datum without moving the shaft-end magnet.
long_pad_motor  = plist_put("drive_shaft",
                           plist_put("pad_l", 8, plist_get("drive_shaft", motor_plist)),
                           motor_plist);
long_pad        = gearmotor_encoder_params(long_pad_motor, bracket_thickness);
near(plist_get("magnet_face", long_pad), magnet);
near(plist_get("sleeve_origin", long_pad),
     plist_get("sleeve_origin", e) - [0, 8 - plist_get("pad_l", plist_get("drive_shaft", motor_plist)), 0]);
// A deeper magnet recess changes only the lip; the seat fixes the magnet face.
recessed_sleeve = driveshaft_magnet_sleeve_params(magnet_h_clearance=0.3);
recessed = gearmotor_encoder_params(motor_plist,
                                    bracket_thickness,
                                    sleeve_params=recessed_sleeve);
near(plist_get("magnet_face", recessed), magnet);
// Axial shaft clearance moves the pocket and PCB together without adding a floor.
gap_sleeve      = driveshaft_magnet_sleeve_params(h_clearance=0.7);
gap_mount = gearmotor_encoder_params(motor_plist,
                                     bracket_thickness,
                                     sleeve_params=gap_sleeve);
near(plist_get("pcb_back", gap_mount), plist_get("pcb_back", e) + [0, 0.5, 0]);
near(plist_get("sensor_face", gap_mount) - plist_get("magnet_face", gap_mount),
     [0, 0.5, 0]);
near([plist_get("magnet_bottom_z", s)], [plist_get("cup_h", s)]);
near(magnet, [0, 32.3, 17.15]);
near(plist_get("pcb_back", e), [0, 35.38, 17.15]);
// Bosses resolve their complete heights and diametral fits once for all consumers.
near([plist_get("front", plist_get("boss_heights", p)),
      plist_get("rear", plist_get("boss_heights", p))],
     [10.93, 12.43]);
near([plist_get("boss_od", p), plist_get("boss_pocket_od", p)], [6, 8]);
custom = gearmotor_bracket_compute_params(boss_pocket_depth=1.5,
                                          boss_pocket_clearance=0.4,
                                          motor_carrier_clearance=0.5);
near([plist_get("front", plist_get("boss_heights", custom))], [10.43]);
near([plist_get("boss_pocket_od", custom)], [6.4]);
near(plist_get("base_bounds", custom)[1], [14.325, 44.3, 19.94]);
echo("PASS: sleeve seat, lip, cross-hole, changed pad length and boss fits");
