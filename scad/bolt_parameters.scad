include <colors.scad>


m1_hole_dia              = 1.2; // M1 bolt hole diameter
m2_hole_dia              = 2.4; // M2 bolt hole diameter
m25_hole_dia             = 2.6; // M2.5 bolt hole diameter
m3_hole_dia              = 3.2; // M3 bolt hole diameter
m5_hole_dia              = 5.2; // M5 bolt hole diameter
m6_hole_dia              = 6.2; // M6 bolt hole diameter

m2_hole_dia_tight        = 2.2; // M2 bolt hole diameter

m1_pan_head_dia          = 1.8;
m2_pan_head_dia          = 3.5;
m25_pan_head_dia         = 4.3;
m3_pan_head_dia          = 4.8;

m1_pan_head_h            = 0.8;
m2_pan_head_h            = 1.38;
m25_pan_head_h           = 1.6;
m3_pan_head_h            = 1.5;

m1_round_head_dia        = 2.60;
m2_round_head_dia        = 3.5;
m25_round_head_dia       = 5.2;
m3_round_head_dia        = 5.62;
m1_round_head_h          = 0.8;
m2_round_head_h          = 1.38;
m25_round_head_h         = 2.10;
m3_round_head_h          = 2.90;

m1_socket_head_dia       = 2.60;
m2_socket_head_dia       = 3.5;
m25_socket_head_dia      = 5.2;
m3_socket_head_dia       = 5.62;
m5_socket_head_dia       = 8.46;
m6_socket_head_dia       = 9.80;
m1_socket_head_h         = 0.8;
m2_socket_head_h         = 1.38;
m25_socket_head_h        = 2.10;
m3_socket_head_h         = 3.30;
m5_socket_head_h         = 5.0;
m6_socket_head_h         = 6.0;

m1_countersunk_head_dia  = 2.60;
m2_countersunk_head_dia  = 3.5;
m25_countersunk_head_dia = 4.13;
m3_countersunk_head_dia  = 5.8;
m6_countersunk_head_dia  = 14.44;
m1_countersunk_head_h    = 0.8;
m2_countersunk_head_h    = 1.38;
m25_countersunk_head_h   = 1.1;
m3_countersunk_head_h    = 1.8;
m6_countersunk_head_h    = 8.3;

m1_hex_head_dia          = 2.60;
m2_hex_head_dia          = 3.5;
m25_hex_head_dia         = 5.2;
m3_hex_head_dia          = 5.62;
m1_hex_head_h            = 0.8;
m2_hex_head_h            = 1.38;
m25_hex_head_h           = 2.10;
m3_hex_head_h            = 2.90;

m2_nut_dia               = 3.95;
m2_nut_h                 = 1.74;
m25_nut_dia              = 4.92;
m25_nut_h                = 1.98;
m3_nut_dia               = 5.5;
m3_nut_h                 = 2.34;
m6_nut_dia               = 9.96;
m6_nut_h                 = 4.86;

m2_lock_nut_dia          = 3.95;
m2_lock_nut_h            = 2.96;
m25_lock_nut_dia         = 4.92;
m25_lock_nut_h           = 3.52;
m3_lock_nut_dia          = 6.1;
m3_lock_nut_h            = 4.0;
m6_lock_nut_dia          = 13.33;
m6_lock_nut_h            = 8.92;

m2_pan_counterbore_d     = m2_pan_head_dia;
m2_pan_counterbore_h     = m2_pan_head_h + 0.2;

m3_socket_counterbore_d  = 6.1;
m3_socket_counterbore_h  = 3.3;

m3_countersunk_bore_d    = 5.9;
m3_countersunk_bore_h    = 1.95;

bolt_specs               = [[1,
                             ["nut", ["outer_dia", m2_nut_dia,
                                      "height", m2_nut_h],
                              "lock_nut", ["outer_dia", m2_lock_nut_dia,
                                           "height", m2_lock_nut_h,
                                           "color", metallic_silver_2],
                              "colors", ["hex", matte_black,
                                         "pan", metallic_silver_2,
                                         "countersunk", metallic_silver_1,
                                         "round", matte_black,
                                         "socket", matte_black],
                              "head", ["pan", ["dia", m1_pan_head_dia,
                                               "height", m1_pan_head_h],
                                       "hex", ["dia", m1_hex_head_dia,
                                               "height", m1_hex_head_h],
                                       "round", ["dia", m1_round_head_dia,
                                                 "height", m1_round_head_h],
                                       "socket", ["dia", m1_socket_head_dia,
                                                  "height", m1_socket_head_h],
                                       "countersunk", ["dia", m1_countersunk_head_dia,
                                                       "height", m1_countersunk_head_h]],
                              "heights", [2, 4, 6, 10, 12, 14, 16]]] ,
                            [3,
                             ["nut", ["outer_dia", m3_nut_dia,
                                      "height", m3_nut_h],
                              "lock_nut", ["outer_dia", m3_lock_nut_dia,
                                           "height", m3_lock_nut_h,
                                           "color", metallic_silver_2],
                              "colors", ["hex", matte_black,
                                         "pan", metallic_silver_2,
                                         "countersunk", matte_black,
                                         "round", metallic_silver_3,
                                         "socket", matte_black],
                              "head", ["pan", ["dia", m3_pan_head_dia,
                                               "height", m3_pan_head_h],
                                       "hex", ["dia", m3_hex_head_dia,
                                               "height", m3_hex_head_h],
                                       "round", ["dia", m3_round_head_dia,
                                                 "height", m3_round_head_h],
                                       "socket", ["dia", m3_socket_head_dia,
                                                  "height", m3_socket_head_h],
                                       "countersunk", ["dia", m3_countersunk_head_dia,
                                                       "height", m3_countersunk_head_h]],
                              "heights", [2, 4, 6, 10, 12, 14, 16]]],
                            [2,
                             ["nut", ["outer_dia", m2_nut_dia,
                                      "height", m2_nut_h],
                              "lock_nut", ["outer_dia", m2_lock_nut_dia,
                                           "height", m2_lock_nut_h,
                                           "color", metallic_silver_2],
                              "colors", ["hex", matte_black,
                                         "pan", metallic_silver_2,
                                         "countersunk", metallic_silver_1,
                                         "round", matte_black,
                                         "socket", matte_black],
                              "head", ["pan", ["dia", m2_pan_head_dia,
                                               "height", m2_pan_head_h],
                                       "hex", ["dia", m2_hex_head_dia,
                                               "height", m2_hex_head_h],
                                       "socket", ["dia", m2_socket_head_dia,
                                                  "height", m2_socket_head_h],
                                       "round", ["dia", m2_round_head_dia,
                                                 "height", m2_round_head_h],
                                       "countersunk", ["dia", m2_countersunk_head_dia,
                                                       "height", m2_countersunk_head_h]],
                              "heights", [2, 4, 6, 10, 12, 14, 16]]],
                            [2.5,
                             ["nut", ["outer_dia", m25_nut_dia,
                                      "height", m25_nut_h],
                              "lock_nut", ["outer_dia", m25_lock_nut_dia,
                                           "height", m25_lock_nut_h,
                                           "color", metallic_silver_2],
                              "colors", ["hex", matte_black,
                                         "pan", metallic_silver_2,
                                         "countersunk", metallic_silver_1,
                                         "round", matte_black,
                                         "socket", matte_black],
                              "head", ["pan", ["dia", m25_pan_head_dia,
                                               "height", m25_pan_head_h],
                                       "hex", ["dia", m25_hex_head_dia,
                                               "height", m25_hex_head_h],
                                       "round", ["dia", m25_round_head_dia,
                                                 "height", m25_round_head_h],
                                       "socket", ["dia", m25_socket_head_dia,
                                                  "height", m25_socket_head_h],
                                       "countersunk", ["dia", m25_countersunk_head_dia,
                                                       "height", m25_countersunk_head_h]],
                              "heights", [2, 4, 6, 10, 12, 14, 16]]],
                            [5.0,
                             ["nut", ["outer_dia", m6_nut_dia,
                                      "height", m6_nut_h],
                              "lock_nut", ["outer_dia", m6_lock_nut_dia,
                                           "height", m3_lock_nut_h,
                                           "color", metallic_silver_2,
                                           "flanged_fn", 6],
                              "colors", ["hex", matte_black,
                                         "pan", metallic_silver_2,
                                         "countersunk", matte_black,
                                         "round", matte_black,
                                         "socket", metallic_silver_2],
                              "head", ["round", ["dia", m5_socket_head_dia,
                                                 "height", m5_socket_head_h],
                                       "socket", ["dia", m5_socket_head_dia,
                                                  "height", m5_socket_head_h]],
                              "heights", [22, 25, 30],
                              "shoulder", ["dia", 8]]],
                            [6.0,
                             ["nut", ["outer_dia", m6_nut_dia,
                                      "height", m6_nut_h],
                              "lock_nut", ["outer_dia", m6_lock_nut_dia,
                                           "outer_fn", 50,
                                           "height", m6_lock_nut_h,
                                           "color", metallic_silver_2,
                                           "flanged_h", 4.74,
                                           "flanged_fn", 6,
                                           "flanged_dia", 9.82,
                                           "nylon_cap_h", 1.8,
                                           "nylon_cap_dia", 9.5],
                              "colors", ["hex", matte_black,
                                         "pan", metallic_silver_2,
                                         "countersunk", metallic_silver_1,
                                         "round", matte_black,
                                         "socket", metallic_silver_2],
                              "head", ["socket", ["dia", m6_socket_head_dia,
                                                  "height", m6_socket_head_h],
                                       "countersunk", ["dia", m6_countersunk_head_dia,
                                                       "height", m6_countersunk_head_h]],
                              "heights", [8, 10, 12, 14, 16, 30],
                              "shoulder", ["dia", 8,
                                           "heights", [16, 20, 30]]]]];
