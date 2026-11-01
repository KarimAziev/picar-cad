/**
  * Module: On-road shock absorber packaging dimensions.
  *
  * Author: Karim Aziiev <karim.aziiev@gmail.com>
  * License: GPL-3.0-or-later
  */

// Packaging preset for an on-road shock: 55 mm fixing-hole spacing and
// spring OD17 match the S102004G upgrade listing, not a measurement of 02175.
// Travel, eyes and cylinder details are design assumptions to verify.
hsp_onroad_shock_spec = ["eye_distance", 55,
                         "eye_distance_min", 42,
                         "eye_distance_max", 55,
                         "eye_d", 11,
                         "eye_bore_d", 3,
                         "eye_w", 5,
                         "eye_neck_l", 9,
                         "body_d", 12,
                         "body_l", 24,
                         "shaft_d", 3,
                         "spring_d", 17,
                         "spring_wire", 1.2,
                         "spring_turns", 7,
                         "spring_seat_h", 2,
                         "spring_coil_fn", 20,
                         "spring_wire_fn", 8,
                         "csg_epsilon", 0.02,
                         "fn", 48,
                         "body_color", "#277d9e",
                         "eye_color", "#30343b",
                         "spring_color", "#25272b",
                         "shaft_color", "silver"];
